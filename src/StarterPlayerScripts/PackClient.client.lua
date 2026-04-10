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
local PreviewUI   = require(UI:WaitForChild("PreviewUI"))

local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFn        = Remotes:WaitForChild("OpenPack")      :: RemoteFunction
local SellItemFn        = Remotes:WaitForChild("SellItem")      :: RemoteFunction
local GetDataFn         = Remotes:WaitForChild("GetData")       :: RemoteFunction
local ClaimWorkFn       = Remotes:WaitForChild("ClaimWork")     :: RemoteFunction
local UpdateBalanceEvt  = Remotes:WaitForChild("UpdateBalance") :: RemoteEvent
local FlexItemEvt       = Remotes:WaitForChild("FlexItem")      :: RemoteEvent
local StopFlexEvt       = Remotes:WaitForChild("StopFlex")      :: RemoteEvent

-- =========================================================================
-- Constants
-- =========================================================================
local WORK_COOLDOWN  = 60
local WORK_CLR       = Color3.fromRGB( 35, 150,  70)
local WORK_HOV       = Color3.fromRGB( 50, 195,  95)
local WORK_CD_CLR    = Color3.fromRGB( 55,  55,  55)

-- =========================================================================
-- State
-- =========================================================================
local playerData = { balance = 0, cooldowns = {}, inventory = {}, lastWork = 0 }
local isOpening  = false
local isFlexing  = false

local store     = StoreUI.new(playerGui)
local opening   = OpeningUI.new(playerGui)
local inventory = InventoryUI.new(playerGui)
local preview   = PreviewUI.new(playerGui)

-- =========================================================================
-- Toast notification  (slides in from the top, auto-dismisses)
-- =========================================================================
local function showToast(msg, color)
    color = color or Color3.fromRGB(80, 220, 80)

    local sg = Instance.new("ScreenGui")
    sg.Name           = "ToastGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent         = playerGui

    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.fromOffset(320, 50)
    lbl.Position              = UDim2.new(0.5, -160, 0, -60)
    lbl.BackgroundColor3      = Color3.fromRGB(18, 18, 32)
    lbl.BorderSizePixel       = 0
    lbl.Text                  = msg
    lbl.TextColor3            = color
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize              = 16
    lbl.BackgroundTransparency= 0
    lbl.Parent                = sg
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 12)

    -- Slide in
    TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -160, 0, 18),
    }):Play()

    -- Slide out after a delay
    task.delay(2.8, function()
        TweenService:Create(lbl, TweenInfo.new(0.35), {
            Position              = UDim2.new(0.5, -160, 0, -60),
            BackgroundTransparency= 1,
            TextTransparency      = 1,
        }):Play()
        task.delay(0.4, function() sg:Destroy() end)
    end)
end

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
-- UpdateBalanceEvt may carry optional (eventType, amount) for toasts
-- =========================================================================
UpdateBalanceEvt.OnClientEvent:Connect(function(newBalance, eventType, amount)
    playerData.balance = newBalance
    store:updateBalance(newBalance)
    inventory:updateBalance(newBalance)

    if eventType == "daily" then
        showToast("Daily Bonus!  +$" .. PackModule.formatNumber(amount),
                  Color3.fromRGB(255, 220, 50))
    end
end)

-- =========================================================================
-- Pack opening flow
-- =========================================================================
local function openPack(packId)
    if isOpening then return end
    local pack = PackModule.getPackById(packId)
    if not pack then return end

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

        task.delay(0.5, function()
            opening:revealItem(result.item)
        end)

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
        opening.onKeep = function(_)
            isOpening = false
            refreshStore()
            store:show()
        end
    end
end

store.onPackSelect = openPack

-- =========================================================================
-- Pack preview  (click card body → show contents modal)
-- =========================================================================
store.onPackPreview = function(packId)
    if isOpening then return end
    local pack = PackModule.getPackById(packId)
    if pack then
        preview:show(pack)
    end
end

-- =========================================================================
-- Inventory SELL callback
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
-- Layout (left→right): [STORE] [WORK] [INVENTORY]
-- =========================================================================
local btnGui = Instance.new("ScreenGui")
btnGui.Name           = "BottomBarGui"
btnGui.ResetOnSpawn   = false
btnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
btnGui.Parent         = playerGui

local function makeBarBtn(text, color, xOffset, width)
    width = width or 150
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.fromOffset(width, 50)
    btn.Position         = UDim2.new(0.5, xOffset, 1, -68)
    btn.BackgroundColor3 = color
    btn.Text             = text
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 14
    btn.BorderSizePixel  = 0
    btn.Parent           = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

-- Store button  (leftmost)
local storeBtn = makeBarBtn("Open Store", Color3.fromRGB(75, 55, 200), -270, 145)
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

-- Work button (middle)  — earn money on a 60 s cooldown
local workBtn = makeBarBtn("WORK  +$$$", WORK_CLR, -113, 120)
workBtn.MouseEnter:Connect(function()
    if workBtn.BackgroundColor3 ~= WORK_CD_CLR then
        TweenService:Create(workBtn, TweenInfo.new(0.12), { BackgroundColor3 = WORK_HOV }):Play()
    end
end)
workBtn.MouseLeave:Connect(function()
    if workBtn.BackgroundColor3 ~= WORK_CD_CLR then
        TweenService:Create(workBtn, TweenInfo.new(0.12), { BackgroundColor3 = WORK_CLR }):Play()
    end
end)
workBtn.MouseButton1Click:Connect(function()
    -- Optimistic client-side cooldown check
    local elapsed = os.time() - (playerData.lastWork or 0)
    if elapsed < WORK_COOLDOWN then return end

    workBtn.Active = false
    workBtn.Text   = "Working..."
    workBtn.BackgroundColor3 = WORK_CD_CLR

    local result = ClaimWorkFn:InvokeServer()
    if result and result.success then
        playerData.balance  = result.newBalance
        playerData.lastWork = os.time()
        store:updateBalance(result.newBalance)
        inventory:updateBalance(result.newBalance)
        showToast("You worked!  +$" .. PackModule.formatNumber(result.earned),
                  Color3.fromRGB(80, 220, 120))
    end
    workBtn.Active = true
end)

-- Inventory button (rightmost)
local invBtn = makeBarBtn("Inventory", Color3.fromRGB(40, 120, 160), 20, 140)
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

-- Stop Flexing button (above bar, hidden until FLEX active)
local stopFlexBtn = Instance.new("TextButton")
stopFlexBtn.Size             = UDim2.fromOffset(180, 44)
stopFlexBtn.Position         = UDim2.new(0.5, -90, 1, -126)
stopFlexBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
stopFlexBtn.Text             = "Stop Flexing"
stopFlexBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
stopFlexBtn.Font             = Enum.Font.GothamBold
stopFlexBtn.TextSize         = 14
stopFlexBtn.BorderSizePixel  = 0
stopFlexBtn.Visible          = false
stopFlexBtn.Parent           = btnGui
Instance.new("UICorner", stopFlexBtn).CornerRadius = UDim.new(0, 10)

stopFlexBtn.MouseButton1Click:Connect(function()
    StopFlexEvt:FireServer()
    isFlexing = false
    stopFlexBtn.Visible = false
end)

-- Pulse inventory button after KEEP (forward declared so it's in scope above)
function _pulseInventoryBtn()
    local orig   = Color3.fromRGB(40, 120, 160)
    local bright = Color3.fromRGB(80, 220, 255)
    TweenService:Create(invBtn, TweenInfo.new(0.3), { BackgroundColor3 = bright }):Play()
    task.delay(0.35, function()
        TweenService:Create(invBtn, TweenInfo.new(0.4), { BackgroundColor3 = orig }):Play()
    end)
end

-- =========================================================================
-- 1 Hz tick: update pack cooldowns + work button countdown
-- =========================================================================
task.spawn(function()
    while true do
        task.wait(1)
        if store.screenGui.Enabled then
            store:updateCooldowns(playerData.cooldowns)
        end
        -- Update Work button label
        local elapsed = os.time() - (playerData.lastWork or 0)
        if elapsed < WORK_COOLDOWN then
            local rem = WORK_COOLDOWN - elapsed
            workBtn.Text             = string.format("WORK  %ds", rem)
            workBtn.BackgroundColor3 = WORK_CD_CLR
        else
            workBtn.Text             = "WORK  +$$$"
            workBtn.BackgroundColor3 = WORK_CLR
        end
    end
end)

-- =========================================================================
-- Initial load
-- =========================================================================
refreshStore()
