-- =============================================================================
-- PackClient  (LocalScript — StarterPlayerScripts)
-- =============================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PackModule  = require(ReplicatedStorage:WaitForChild("PackModule"))
local UI          = ReplicatedStorage:WaitForChild("UI")
local StoreUI     = require(UI:WaitForChild("StoreUI"))
local OpeningUI   = require(UI:WaitForChild("OpeningUI"))
local InventoryUI = require(UI:WaitForChild("InventoryUI"))

local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFn        = Remotes:WaitForChild("OpenPack")      :: RemoteFunction
local SellItemFn        = Remotes:WaitForChild("SellItem")      :: RemoteFunction
local GetDataFn         = Remotes:WaitForChild("GetData")       :: RemoteFunction
local UpdateBalanceEvt  = Remotes:WaitForChild("UpdateBalance") :: RemoteEvent
local FlexItemEvt       = Remotes:WaitForChild("FlexItem")      :: RemoteEvent
local StopFlexEvt       = Remotes:WaitForChild("StopFlex")      :: RemoteEvent

-- =========================================================================
-- State
-- =========================================================================
local playerData = { balance = 0, cooldowns = {}, inventory = {} }
local isOpening  = false
local isFlexing  = false

local store     = StoreUI.new(playerGui)
local opening   = OpeningUI.new(playerGui)
local inventory = InventoryUI.new(playerGui)

-- =========================================================================
-- Data helpers
-- =========================================================================
local function refreshData()
    local data = GetDataFn:InvokeServer()
    if data then playerData = data end
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
-- Balance updates from server
-- =========================================================================
UpdateBalanceEvt.OnClientEvent:Connect(function(newBalance)
    playerData.balance = newBalance
    store:updateBalance(newBalance)
    inventory:updateBalance(newBalance)
end)

-- =========================================================================
-- Pack opening flow
-- =========================================================================
local function openPack(packId)
    if isOpening then return end
    local pack = PackModule.getPackById(packId)
    if not pack then return end

    -- Optimistic client-side gate (server re-validates authoritatively)
    local canOpen, reason = PackModule.canOpenPack(pack, playerData.balance, playerData.cooldowns[packId])
    if not canOpen then
        local entry = store.packCards[packId]
        if entry then
            local tier = PackModule.getPackTier(pack.tier)
            entry.openBtn.Text = reason
            TweenService:Create(entry.openBtn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            }):Play()
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

    local result = OpenPackFn:InvokeServer(packId)

    if result and result.success then
        if pack.cooldown > 0 then playerData.cooldowns[packId] = os.time() end
        playerData.balance = result.newBalance

        -- Small pause so the pop-in animation finishes before the reel starts
        task.delay(0.5, function()
            opening:revealItem(result.item)
        end)

        -- SELL: server call, then return to store
        opening.onSell = function(item)
            if not item then isOpening = false; return end
            local sellResult = SellItemFn:InvokeServer(item.id)
            if sellResult and sellResult.success then
                playerData.balance = sellResult.newBalance
                playerData.inventory[item.id] = nil
                inventory:removeItem(item.id)
            end
            isOpening = false
            refreshStore()
            store:show()
        end

        -- KEEP: stash in local inventory cache, pulse the button
        opening.onKeep = function(item)
            if not item then isOpening = false; return end
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
            _pulseInventoryBtn()
        end
    else
        opening:showError(result and result.reason or "Something went wrong.")
        -- onKeep is used as the "dismiss" path from showError
        opening.onKeep = function(_)
            isOpening = false
            refreshStore()
            store:show()
        end
    end
end

store.onPackSelect = openPack

-- =========================================================================
-- Inventory SELL callback
-- Returns true if server confirmed, false otherwise (so button knows)
-- =========================================================================
inventory.onSellItem = function(itemId)
    local item = playerData.inventory[itemId]
    if not item then return false end

    local result = SellItemFn:InvokeServer(itemId)
    if result and result.success then
        playerData.balance = result.newBalance
        playerData.inventory[itemId] = nil
        return true
    end
    return false
end

-- =========================================================================
-- Inventory FLEX callback
-- =========================================================================
inventory.onFlexItem = function(itemId, item)
    FlexItemEvt:FireServer(item.name, item.rarity, item.sellValue)
    isFlexing = true
    stopFlexBtn.Visible = true
    inventory:hide()
end

-- =========================================================================
-- Bottom bar buttons
-- =========================================================================
local btnGui = Instance.new("ScreenGui")
btnGui.Name          = "BottomBarGui"
btnGui.ResetOnSpawn  = false
btnGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
btnGui.Parent        = playerGui

local function makeBarBtn(text, color, xOffset, width)
    width = width or 160
    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.fromOffset(width, 50)
    btn.Position        = UDim2.new(0.5, xOffset, 1, -68)
    btn.BackgroundColor3= color
    btn.Text            = text
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.Font            = Enum.Font.GothamBold
    btn.TextSize        = 15
    btn.BorderSizePixel = 0
    btn.Parent          = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

-- Store button
local storeBtn = makeBarBtn("Open Store", Color3.fromRGB(75, 55, 200), -175)
storeBtn.MouseEnter:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(100, 80, 230) }):Play()
end)
storeBtn.MouseLeave:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(75, 55, 200) }):Play()
end)
storeBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled or isOpening then return end
    refreshStore()
    store:show()
end)

-- Inventory button
local invBtn = makeBarBtn("Inventory", Color3.fromRGB(40, 120, 160), 10)
invBtn.MouseEnter:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(55, 160, 200) }):Play()
end)
invBtn.MouseLeave:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(40, 120, 160) }):Play()
end)
invBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled or isOpening then return end
    refreshData()
    refreshInventory()
    inventory:show()
end)

-- Stop Flexing button (hidden until FLEX is active)
-- Placed above the normal buttons so it's noticeable
local stopFlexBtn = Instance.new("TextButton")
stopFlexBtn.Size            = UDim2.fromOffset(180, 44)
stopFlexBtn.Position        = UDim2.new(0.5, -90, 1, -126)  -- above bar buttons
stopFlexBtn.BackgroundColor3= Color3.fromRGB(200, 40, 40)
stopFlexBtn.Text            = "Stop Flexing"
stopFlexBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
stopFlexBtn.Font            = Enum.Font.GothamBold
stopFlexBtn.TextSize        = 14
stopFlexBtn.BorderSizePixel = 0
stopFlexBtn.Visible         = false
stopFlexBtn.Parent          = btnGui
Instance.new("UICorner", stopFlexBtn).CornerRadius = UDim.new(0, 10)

stopFlexBtn.MouseButton1Click:Connect(function()
    StopFlexEvt:FireServer()
    isFlexing = false
    stopFlexBtn.Visible = false
end)

-- Pulse the inventory button after KEEP (forward declared here so it's in scope)
function _pulseInventoryBtn()
    local orig   = Color3.fromRGB(40, 120, 160)
    local bright = Color3.fromRGB(80, 220, 255)
    TweenService:Create(invBtn, TweenInfo.new(0.3), { BackgroundColor3 = bright }):Play()
    task.delay(0.35, function()
        TweenService:Create(invBtn, TweenInfo.new(0.4), { BackgroundColor3 = orig }):Play()
    end)
end

-- =========================================================================
-- Cooldown countdown (1 Hz)
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
