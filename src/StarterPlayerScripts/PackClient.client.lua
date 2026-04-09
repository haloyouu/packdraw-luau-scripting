-- =============================================================================
-- PackClient  (LocalScript — StarterPlayerScripts)
--
-- Entry point for all client-side pack-opening logic.
-- Wires together StoreUI, OpeningUI, and the server remotes.
-- =============================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local PackModule = require(ReplicatedStorage:WaitForChild("PackModule"))
local UI         = ReplicatedStorage:WaitForChild("UI")
local StoreUI    = require(UI:WaitForChild("StoreUI"))
local OpeningUI  = require(UI:WaitForChild("OpeningUI"))

-- Remotes
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFn        = Remotes:WaitForChild("OpenPack")    :: RemoteFunction
local GetDataFn         = Remotes:WaitForChild("GetData")     :: RemoteFunction
local UpdateBalanceEvt  = Remotes:WaitForChild("UpdateBalance") :: RemoteEvent

-- =========================================================================
-- State
-- =========================================================================
local playerData = { balance = 0, cooldowns = {} }
local isOpening  = false

-- Build UIs
local store   = StoreUI.new(playerGui)
local opening = OpeningUI.new(playerGui)

-- =========================================================================
-- Helpers
-- =========================================================================
local function refreshStore()
    local data = GetDataFn:InvokeServer()
    if data then
        playerData = data
    end
    store:populate()
    store:updateBalance(playerData.balance)
    store:updateCooldowns(playerData.cooldowns)
end

-- =========================================================================
-- Balance updates from server
-- =========================================================================
UpdateBalanceEvt.OnClientEvent:Connect(function(newBalance: number)
    playerData.balance = newBalance
    store:updateBalance(newBalance)
end)

-- =========================================================================
-- Pack opening flow
-- =========================================================================
local function openPack(packId: string)
    if isOpening then return end

    local pack = PackModule.getPackById(packId)
    if not pack then return end

    -- Optimistic client-side cooldown check (server is authoritative)
    local canOpen, reason = PackModule.canOpenPack(pack, playerData.balance, playerData.cooldowns[packId])
    if not canOpen then
        -- Briefly flash the open button to signal rejection (no popup needed)
        local entry = store.packCards[packId]
        if entry then
            TweenService:Create(entry.openBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            }).Completed:Connect(function()
                task.wait(0.8)
                local tier = PackModule.getPackTier(pack.tier)
                TweenService:Create(entry.openBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = tier.primaryColor
                }):Play()
            end)
            TweenService:Create(entry.openBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            }):Play()
            entry.openBtn.Text = reason
            task.delay(1.5, function()
                store:updateCooldowns(playerData.cooldowns)
            end)
        end
        return
    end

    isOpening = true
    store:hide()
    opening:showOpening(pack)

    -- Ask the server to roll and grant the reward
    local result = OpenPackFn:InvokeServer(packId)

    if result and result.success then
        -- Update local cooldown cache immediately so the timer starts right away
        if pack.cooldown > 0 then
            playerData.cooldowns[packId] = os.time()
        end
        playerData.balance = result.newBalance

        -- Small dramatic pause before flipping the card
        task.delay(0.9, function()
            opening:revealReward(result.reward)
        end)
    else
        opening:showError(result and result.reason or "Something went wrong. Try again.")
    end

    -- When the player clicks COLLECT, return to the store
    opening.onClose = function()
        isOpening = false
        refreshStore()
        store:show()
    end
end

-- Wire the store's pack-select callback
store.onPackSelect = openPack

-- =========================================================================
-- "Open Store" button  (bottom-centre of the screen)
-- =========================================================================
local btnGui = Instance.new("ScreenGui")
btnGui.Name          = "OpenStoreBtnGui"
btnGui.ResetOnSpawn  = false
btnGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
btnGui.Parent        = playerGui

local storeBtn = Instance.new("TextButton")
storeBtn.Size            = UDim2.fromOffset(170, 50)
storeBtn.Position        = UDim2.new(0.5, -85, 1, -68)
storeBtn.BackgroundColor3= Color3.fromRGB(75, 55, 200)
storeBtn.Text            = "Open Store"
storeBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
storeBtn.Font            = Enum.Font.GothamBold
storeBtn.TextSize        = 16
storeBtn.BorderSizePixel = 0
storeBtn.Parent          = btnGui
Instance.new("UICorner", storeBtn).CornerRadius = UDim.new(0, 10)

storeBtn.MouseEnter:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(100, 80, 230)
    }):Play()
end)
storeBtn.MouseLeave:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(75, 55, 200)
    }):Play()
end)

storeBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or isOpening then return end
    refreshStore()
    store:show()
end)

-- =========================================================================
-- Cooldown countdown ticker (1 Hz)
-- =========================================================================
task.spawn(function()
    while true do
        task.wait(1)
        if store.screenGui.Enabled then
            store:updateCooldowns(playerData.cooldowns)
        end
    end
end)

-- =========================================================================
-- Initial data load
-- =========================================================================
refreshStore()
