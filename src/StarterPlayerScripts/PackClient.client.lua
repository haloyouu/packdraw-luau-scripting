-- =============================================================================
-- PackClient  (LocalScript — StarterPlayerScripts)
-- =============================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PackModule   = require(ReplicatedStorage:WaitForChild("PackModule"))
local UI           = ReplicatedStorage:WaitForChild("UI")
local StoreUI      = require(UI:WaitForChild("StoreUI"))
local OpeningUI    = require(UI:WaitForChild("OpeningUI"))
local InventoryUI  = require(UI:WaitForChild("InventoryUI"))
local PreviewUI    = require(UI:WaitForChild("PreviewUI"))
local BusinessUI   = require(UI:WaitForChild("BusinessUI"))

local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFn        = Remotes:WaitForChild("OpenPack")       :: RemoteFunction
local SellItemFn        = Remotes:WaitForChild("SellItem")       :: RemoteFunction
local GetDataFn         = Remotes:WaitForChild("GetData")        :: RemoteFunction
local ClaimWorkFn       = Remotes:WaitForChild("ClaimWork")      :: RemoteFunction
local BuyBusinessFn     = Remotes:WaitForChild("BuyBusiness")    :: RemoteFunction
local UpdateBalanceEvt  = Remotes:WaitForChild("UpdateBalance")  :: RemoteEvent
local FlexItemEvt       = Remotes:WaitForChild("FlexItem")       :: RemoteEvent
local StopFlexEvt       = Remotes:WaitForChild("StopFlex")       :: RemoteEvent

-- =========================================================================
-- Constants
-- =========================================================================
local WORK_COOLDOWN  = 60
local WORK_CLR       = Color3.fromRGB( 35, 150,  70)
local WORK_HOV       = Color3.fromRGB( 50, 195,  95)
local WORK_CD_CLR    = Color3.fromRGB( 55,  55,  55)
local BIZ_CLR        = Color3.fromRGB(160, 110,  15)
local BIZ_HOV        = Color3.fromRGB(200, 145,  25)

-- =========================================================================
-- State
-- =========================================================================
local playerData = {
    balance    = 0,
    cooldowns  = {},
    inventory  = {},
    lastWork   = 0,
    businesses = {},
    hourlyRate = 25,
    streakDays = 0,
}
local isOpening  = false
local isFlexing  = false

local store    = StoreUI.new(playerGui)
local opening  = OpeningUI.new(playerGui)
local inventory= InventoryUI.new(playerGui)
local preview  = PreviewUI.new(playerGui)
local business = BusinessUI.new(playerGui)

-- =========================================================================
-- Offline earnings reveal  (suspense sequence, not a plain toast)
-- =========================================================================
local function showOfflineReveal(amount)
    local sg = Instance.new("ScreenGui")
    sg.Name           = "OfflineRevealGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 8
    sg.Parent         = playerGui

    local backdrop = Instance.new("Frame")
    backdrop.Size                   = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3       = Color3.fromRGB(4, 6, 18)
    backdrop.BackgroundTransparency = 0.35
    backdrop.BorderSizePixel        = 0
    backdrop.Parent                 = sg

    local panel = Instance.new("Frame")
    panel.AnchorPoint      = Vector2.new(0.5, 0.5)
    panel.Size             = UDim2.fromOffset(4, 4)   -- starts tiny, pops in
    panel.Position         = UDim2.fromScale(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    panel.BorderSizePixel  = 0
    panel.ClipsDescendants = true
    panel.Parent           = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)

    local panelGrad = Instance.new("UIGradient")
    panelGrad.Rotation = 110
    panelGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 22, 52)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB( 8, 10, 26)),
    })
    panelGrad.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color     = Color3.fromRGB(60, 150, 255)
    stroke.Thickness = 2
    stroke.Parent    = panel

    -- Header
    local header = Instance.new("TextLabel")
    header.Size                  = UDim2.new(1, 0, 0, 38)
    header.Position              = UDim2.new(0, 0, 0, 10)
    header.BackgroundTransparency= 1
    header.Text                  = "OFFLINE EARNINGS"
    header.TextColor3            = Color3.fromRGB(70, 165, 255)
    header.Font                  = Enum.Font.GothamBold
    header.TextSize              = 15
    header.Parent                = panel

    -- "While you were away..."
    local awayLbl = Instance.new("TextLabel")
    awayLbl.Size                  = UDim2.new(1, -20, 0, 28)
    awayLbl.Position              = UDim2.new(0, 10, 0, 52)
    awayLbl.BackgroundTransparency= 1
    awayLbl.Text                  = "While you were away..."
    awayLbl.TextColor3            = Color3.fromRGB(150, 175, 220)
    awayLbl.Font                  = Enum.Font.Gotham
    awayLbl.TextSize              = 15
    awayLbl.TextTransparency      = 1
    awayLbl.Parent                = panel

    -- Big amount (counts up)
    local amountLbl = Instance.new("TextLabel")
    amountLbl.AnchorPoint          = Vector2.new(0.5, 0)
    amountLbl.Size                 = UDim2.new(1, -20, 0, 72)
    amountLbl.Position             = UDim2.new(0.5, 0, 0, 90)
    amountLbl.BackgroundTransparency= 1
    amountLbl.Text                 = "$0"
    amountLbl.TextColor3           = Color3.fromRGB(255, 220, 50)
    amountLbl.Font                 = Enum.Font.GothamBold
    amountLbl.TextSize             = 54
    amountLbl.TextTransparency     = 1
    amountLbl.Parent               = panel

    -- "you earned while offline"
    local subLbl = Instance.new("TextLabel")
    subLbl.Size                  = UDim2.new(1, -20, 0, 22)
    subLbl.Position              = UDim2.new(0, 10, 0, 166)
    subLbl.BackgroundTransparency= 1
    subLbl.Text                  = "you earned while offline"
    subLbl.TextColor3            = Color3.fromRGB(110, 135, 180)
    subLbl.Font                  = Enum.Font.Gotham
    subLbl.TextSize              = 13
    subLbl.TextTransparency      = 1
    subLbl.Parent                = panel

    -- COLLECT button
    local collectBtn = Instance.new("TextButton")
    collectBtn.AnchorPoint      = Vector2.new(0.5, 0)
    collectBtn.Size             = UDim2.fromOffset(170, 44)
    collectBtn.Position         = UDim2.new(0.5, 0, 0, 200)
    collectBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 255)
    collectBtn.Text             = "COLLECT"
    collectBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    collectBtn.Font             = Enum.Font.GothamBold
    collectBtn.TextSize         = 15
    collectBtn.BorderSizePixel  = 0
    collectBtn.Visible          = false
    collectBtn.Parent           = panel
    Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 10)
    collectBtn.MouseEnter:Connect(function()
        TweenService:Create(collectBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(70, 160, 255)
        }):Play()
    end)
    collectBtn.MouseLeave:Connect(function()
        TweenService:Create(collectBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(40, 130, 255)
        }):Play()
    end)

    local function dismiss()
        TweenService:Create(panel,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Size = UDim2.fromOffset(4, 4) }):Play()
        task.delay(0.28, function() sg:Destroy() end)
    end
    collectBtn.MouseButton1Click:Connect(dismiss)

    -- ── Reveal sequence ────────────────────────────────────────────────────
    -- 1. Panel pops in
    TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(430, 262)
    }):Play()

    -- 2. "While you were away..." fades in
    task.delay(0.5, function()
        TweenService:Create(awayLbl, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
    end)

    -- 3. Amount appears then counts up
    task.delay(1.3, function()
        TweenService:Create(amountLbl, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
            TextTransparency = 0
        }):Play()
        task.spawn(function()
            local steps    = 28
            local duration = 1.8
            for i = 1, steps do
                task.wait(duration / steps)
                -- ease-out curve so it slows down at the end
                local t = i / steps
                local eased = 1 - (1 - t) ^ 3
                amountLbl.Text = "$" .. PackModule.formatNumber(math.floor(amount * eased))
            end
            amountLbl.Text = "$" .. PackModule.formatNumber(amount)
        end)
    end)

    -- 4. Sub-label and button appear once count-up is almost done
    task.delay(2.8, function()
        TweenService:Create(subLbl, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
        collectBtn.Visible = true
    end)

    -- 5. Auto-dismiss after 10 s if player ignores it
    task.delay(10, function()
        if sg.Parent then dismiss() end
    end)
end

-- =========================================================================
-- Toast notification
-- =========================================================================
local function showToast(msg, color)
    color = color or Color3.fromRGB(80, 220, 80)

    local sg = Instance.new("ScreenGui")
    sg.Name           = "ToastGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent         = playerGui

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.fromOffset(340, 54)
    lbl.Position               = UDim2.new(0.5, -170, 0, -64)
    lbl.BackgroundColor3       = Color3.fromRGB(18, 18, 32)
    lbl.BorderSizePixel        = 0
    lbl.Text                   = msg
    lbl.TextColor3             = color
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 15
    lbl.TextWrapped            = true
    lbl.BackgroundTransparency = 0
    lbl.Parent                 = sg
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 12)

    TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -170, 0, 18),
    }):Play()

    task.delay(3.0, function()
        TweenService:Create(lbl, TweenInfo.new(0.35), {
            Position              = UDim2.new(0.5, -170, 0, -64),
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

local function refreshBusiness()
    business:populate(playerData.businesses or {}, playerData.balance)
    business:updateBalance(playerData.balance)
end

-- =========================================================================
-- Balance / event updates from server
-- eventType: "streak" | "offline"
-- =========================================================================
UpdateBalanceEvt.OnClientEvent:Connect(function(newBalance, eventType, amount, extra)
    playerData.balance = newBalance
    store:updateBalance(newBalance)
    inventory:updateBalance(newBalance)
    business:updateBalance(newBalance)

    if eventType == "streak" then
        local day = extra or 1
        local streakStr = day == 7 and "MAX STREAK! " or string.format("Day %d Streak!  ", day)
        showToast(streakStr .. "+$" .. PackModule.formatNumber(amount),
                  Color3.fromRGB(255, 210, 50))
    elseif eventType == "offline" then
        showOfflineReveal(amount)
    elseif eventType == "daily" then   -- legacy fallback
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
                -- Reset text AND color back to normal
                entry.openBtn.Text = pack.price == 0
                    and "FREE  —  OPEN"
                    or  "OPEN  —  $" .. PackModule.formatNumber(pack.price)
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

        -- Helper: register the item locally (already saved server-side)
        local function keepItemLocally(item)
            if not item then return end
            playerData.inventory[item.id] = {
                name      = item.name,
                imageId   = item.imageId,
                sellValue = item.sellValue,
                rarity    = item.rarity,
            }
            inventory:addItem(item.id, playerData.inventory[item.id])
            _pulseInventoryBtn()
        end

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

        -- Reroll: item auto-kept, immediately open the same pack again
        opening.onReroll = function(item, pack)
            keepItemLocally(item)
            isOpening = false
            refreshData()
            if pack then
                openPack(pack.id)
            else
                refreshStore()
                store:show()
            end
        end
    else
        opening:showError(result and result.reason or "Something went wrong.")
        opening.onReroll = function(_, _)
            isOpening = false
            refreshStore()
            store:show()
        end
    end
end

store.onPackSelect = openPack

-- =========================================================================
-- Pack preview
-- =========================================================================
store.onPackPreview = function(packId)
    if isOpening then return end
    local pack = PackModule.getPackById(packId)
    if pack then preview:show(pack) end
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
-- Business BUY callback
-- =========================================================================
local isBuying = false
business.onBuy = function(businessId)
    if isBuying then return end
    isBuying = true
    local result = BuyBusinessFn:InvokeServer(businessId)
    isBuying = false
    if result and result.success then
        playerData.balance = result.newBalance
        playerData.businesses = playerData.businesses or {}
        playerData.businesses[businessId] = true
        playerData.hourlyRate = result.hourlyRate
        store:updateBalance(result.newBalance)
        inventory:updateBalance(result.newBalance)
        business:populate(playerData.businesses, result.newBalance)
        business:updateBalance(result.newBalance)
        showToast("Business purchased!  +" .. PackModule.formatNumber(result.hourlyRate) .. "/hr total",
                  Color3.fromRGB(255, 200, 50))
    else
        showToast(result and result.reason or "Purchase failed.", Color3.fromRGB(200, 60, 60))
    end
end

-- =========================================================================
-- Flex callback
-- stopFlexBtn forward-declared; assigned below in bottom bar section.
-- =========================================================================
local stopFlexBtn

inventory.onFlexItem = function(itemId, item)
    FlexItemEvt:FireServer(item.name, item.rarity, item.sellValue)
    isFlexing = true
    if stopFlexBtn then stopFlexBtn.Visible = true end
    inventory:hide()
end

-- =========================================================================
-- Bottom bar  (4 buttons, 120 px wide, 12 px gap, centred)
-- Layout: [STORE] [WORK] [BUSINESS] [INVENTORY]
-- =========================================================================
local btnGui = Instance.new("ScreenGui")
btnGui.Name           = "BottomBarGui"
btnGui.ResetOnSpawn   = false
btnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
btnGui.Parent         = playerGui

local function makeBarBtn(text, color, xOffset, width)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.fromOffset(width, 50)
    btn.Position         = UDim2.new(0.5, xOffset, 1, -68)
    btn.BackgroundColor3 = color
    btn.Text             = text
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 13
    btn.BorderSizePixel  = 0
    btn.Parent           = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

-- xOffsets: 4 × 120 px + 3 × 12 px gap = 516 px total, centred at 0
-- left edges: -258, -126, 6, 138
local storeBtn    = makeBarBtn("Open Store",  Color3.fromRGB( 75,  55, 200), -258, 120)
local workBtn     = makeBarBtn("WORK  +$$$",  WORK_CLR,                      -126, 120)
local businessBtn = makeBarBtn("Business",    BIZ_CLR,                          6, 120)
local invBtn      = makeBarBtn("Inventory",   Color3.fromRGB( 40, 120, 160),  138, 120)

-- Store
storeBtn.MouseEnter:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(100, 80, 230) }):Play()
end)
storeBtn.MouseLeave:Connect(function()
    TweenService:Create(storeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(75, 55, 200) }):Play()
end)
storeBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled
       or business.screenGui.Enabled or isOpening then return end
    refreshStore()
    store:show()
end)

-- Work
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
    local elapsed = os.time() - (playerData.lastWork or 0)
    if elapsed < WORK_COOLDOWN then return end

    workBtn.Active            = false
    workBtn.Text              = "Working..."
    workBtn.BackgroundColor3  = WORK_CD_CLR

    local result = ClaimWorkFn:InvokeServer()
    if result and result.success then
        playerData.balance  = result.newBalance
        playerData.lastWork = os.time()
        store:updateBalance(result.newBalance)
        inventory:updateBalance(result.newBalance)
        business:updateBalance(result.newBalance)
        showToast("You worked!  +$" .. PackModule.formatNumber(result.earned),
                  Color3.fromRGB(80, 220, 120))
    end
    workBtn.Active = true
end)

-- Business
businessBtn.MouseEnter:Connect(function()
    TweenService:Create(businessBtn, TweenInfo.new(0.12), { BackgroundColor3 = BIZ_HOV }):Play()
end)
businessBtn.MouseLeave:Connect(function()
    TweenService:Create(businessBtn, TweenInfo.new(0.12), { BackgroundColor3 = BIZ_CLR }):Play()
end)
businessBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled
       or business.screenGui.Enabled or isOpening then return end
    refreshBusiness()
    business:show()
end)

-- Inventory
invBtn.MouseEnter:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(55, 160, 200) }):Play()
end)
invBtn.MouseLeave:Connect(function()
    TweenService:Create(invBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(40, 120, 160) }):Play()
end)
invBtn.MouseButton1Click:Connect(function()
    if store.screenGui.Enabled or inventory.screenGui.Enabled
       or business.screenGui.Enabled or isOpening then return end
    refreshData()
    refreshInventory()
    inventory:show()
end)

-- Stop Flex (above bar, hidden until FLEX active)
stopFlexBtn = Instance.new("TextButton")
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

function _pulseInventoryBtn()
    local orig   = Color3.fromRGB(40, 120, 160)
    local bright = Color3.fromRGB(80, 220, 255)
    TweenService:Create(invBtn, TweenInfo.new(0.3), { BackgroundColor3 = bright }):Play()
    task.delay(0.35, function()
        TweenService:Create(invBtn, TweenInfo.new(0.4), { BackgroundColor3 = orig }):Play()
    end)
end

-- =========================================================================
-- 1 Hz tick: cooldowns + work countdown + business rate label
-- =========================================================================
task.spawn(function()
    while true do
        task.wait(1)

        if store.screenGui.Enabled then
            store:updateCooldowns(playerData.cooldowns)
        end

        -- Work button countdown
        local elapsed = os.time() - (playerData.lastWork or 0)
        if elapsed < WORK_COOLDOWN then
            workBtn.Text             = string.format("WORK  %ds", WORK_COOLDOWN - elapsed)
            workBtn.BackgroundColor3 = WORK_CD_CLR
        else
            workBtn.Text             = "WORK  +$$$"
            workBtn.BackgroundColor3 = WORK_CLR
        end

        -- Business button shows current passive rate
        local rate = playerData.hourlyRate or 25
        businessBtn.Text = "$" .. PackModule.formatNumber(rate) .. "/hr"
    end
end)

-- =========================================================================
-- Initial load
-- =========================================================================
refreshStore()
