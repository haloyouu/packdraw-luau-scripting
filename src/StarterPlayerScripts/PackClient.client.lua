-- =============================================================================
-- PackClient  (LocalScript — StarterPlayerScripts)
--
-- Entry point for all client-side logic.
-- Wires together StoreUI, OpeningUI, InventoryUI, and the server remotes.
-- =============================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local PackModule  = require(ReplicatedStorage:WaitForChild("PackModule"))
local UI          = ReplicatedStorage:WaitForChild("UI")
local StoreUI     = require(UI:WaitForChild("StoreUI"))
local OpeningUI   = require(UI:WaitForChild("OpeningUI"))
local InventoryUI = require(UI:WaitForChild("InventoryUI"))

-- Remotes
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFn        = Remotes:WaitForChild("OpenPack")     :: RemoteFunction
local SellItemFn        = Remotes:WaitForChild("SellItem")     :: RemoteFunction
local GetDataFn         = Remotes:WaitForChild("GetData")      :: RemoteFunction
local UpdateBalanceEvt  = Remotes:WaitForChild("UpdateBalance") :: RemoteEvent

-- =========================================================================
-- State
-- =========================================================================
local playerData = { balance = 0, cooldowns = {}, inventory = {} }
local isOpening  = false

-- Build UIs
local store     = StoreUI.new(playerGui)
local opening   = OpeningUI.new(playerGui)
local inventory = InventoryUI.new(playerGui)

-- =========================================================================
-- Data helpers
-- =========================================================================
local function refreshData()
    local data = GetDataFn:InvokeServer()
    if data then
        playerData = data
    end
end

local function refreshStore()
    refreshData()
    store:populate()
    store:updateBalance(playerData.balance)
    store:updateCooldowns(playerData.cooldowns)
end

local function refreshInventory()
    inventory:populate(playerData.inventory)
    inventory:updateBalance(playerData.balance)
end

-- =========================================================================
-- Balance updates pushed from the server
-- =========================================================================
UpdateBalanceEvt.OnClientEvent:Connect(function(newBalance: number)
    playerData.balance = newBalance
    store:updateBalance(newBalance)
    inventory:updateBalance(newBalance)
end)

-- =========================================================================
-- Pack opening flow
-- =========================================================================
local function openPack(packId: string)
    if isOpening then return end

    local pack = PackModule.getPackById(packId)
    if not pack then return end

    -- Optimistic client-side check (server re-validates authoritatively)
    local canOpen, reason = PackModule.canOpenPack(pack, playerData.balance, playerData.cooldowns[packId])
    if not canOpen then
        local entry = store.packCards[packId]
        if entry then
            local tier = PackModule.getPackTier(pack.tier)
            TweenService:Create(entry.openBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            }):Play()
            entry.openBtn.Text = reason
            task.delay(1.8, function()
                TweenService:Create(entry.openBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = tier.primaryColor
                }):Play()
                store:updateCooldowns(playerData.cooldowns)
            end)
        end
        return
    end

    isOpening = true
    store:hide()
    opening:showOpening(pack)

    -- Ask the server to open the pack
    local result = OpenPackFn:InvokeServer(packId)

    if result and result.success then
        -- Update local cooldown cache
        if pack.cooldown > 0 then
            playerData.cooldowns[packId] = os.time()
        end
        -- Deduct price locally (server already did it; keep display in sync)
        playerData.balance = result.newBalance

        -- Dramatic pause before flipping the card
        task.delay(0.9, function()
            opening:revealItem(result.item)
        end)

        -- SELL callback: call server, then return to store
        opening.onSell = function(item)
            local sellResult = SellItemFn:InvokeServer(item.id)
            if sellResult and sellResult.success then
                playerData.balance = sellResult.newBalance
                -- Remove from local inventory cache
                playerData.inventory[item.id] = nil
            end
            isOpening = false
            refreshStore()
            store:show()
        end

        -- KEEP callback: add to local inventory cache, badge the inventory button
        opening.onKeep = function(item)
            playerData.inventory[item.id] = {
                name      = item.name,
                imageId   = item.imageId,
                sellValue = item.sellValue,
                rarity    = item.rarity,
            }
            inventory:addItem(item.id, playerData.inventory[item.id])
            isOpening = false
            refreshStore()
            store:show()
            -- Pulse the inventory button to hint at the new item
            _pulseInventoryBtn()
        end
    else
        opening:showError(result and result.reason or "Something went wrong. Try again.")
        task.delay(2.8, function()
            isOpening = false
            refreshStore()
            store:show()
        end)
    end
end

store.onPackSelect = openPack

-- =========================================================================
-- Inventory sell callback (from the inventory screen)
-- =========================================================================
inventory.onSellItem = function(itemId: number)
    local item = playerData.inventory[itemId]
    if not item then return end

    local result = SellItemFn:InvokeServer(itemId)
    if result and result.success then
        playerData.balance = result.newBalance
        playerData.inventory[itemId] = nil
        -- inventory:removeItem is called inside the card's click handler
    end
end

-- =========================================================================
-- Bottom-bar buttons
-- =========================================================================
local btnGui = Instance.new("ScreenGui")
btnGui.Name          = "BottomBarGui"
btnGui.ResetOnSpawn  = false
btnGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
btnGui.Parent        = playerGui

-- Helper to create a bottom bar button
local function makeBarBtn(text, bgColor, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.fromOffset(160, 50)
    btn.Position        = UDim2.new(0.5, xOffset, 1, -68)
    btn.BackgroundColor3= bgColor
    btn.Text            = text
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.Font            = Enum.Font.GothamBold
    btn.TextSize        = 15
    btn.BorderSizePixel = 0
    btn.Parent          = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

-- Store button (left of centre)
local storeBtn = makeBarBtn("Open Store", Color3.fromRGB(75, 55, 200), -170)
storeBtn.MouseEnter:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(100, 80, 230)
    }):Play()
end)
storeBtn.MouseLeave:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(75, 55, 200)
    }):Play()
end)
storeBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled or isOpening then return end
    refreshStore()
    store:show()
end)

-- Inventory button (right of centre)
local invBtn = makeBarBtn("Inventory", Color3.fromRGB(40, 120, 160), 10)
invBtn.MouseEnter:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(55, 160, 200)
    }):Play()
end)
invBtn.MouseLeave:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(40, 120, 160)
    }):Play()
end)
invBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled or isOpening then return end
    refreshData()
    refreshInventory()
    inventory:show()
end)

-- Pulse animation for the inventory button (called after KEEP)
function _pulseInventoryBtn()
    local orig = Color3.fromRGB(40, 120, 160)
    local bright = Color3.fromRGB(80, 220, 255)
    TweenService:Create(invBtn, TweenInfo.new(0.3), { BackgroundColor3 = bright }):Play()
    task.delay(0.35, function()
        TweenService:Create(invBtn, TweenInfo.new(0.4), { BackgroundColor3 = orig }):Play()
    end)
end

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
-- Initial load
-- =========================================================================
refreshStore()
