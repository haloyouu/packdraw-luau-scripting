-- =============================================================================
-- InventoryUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Shows all items the player currently holds and lets them sell any of them.
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local DARK_BG   = Color3.fromRGB(12,  12,  22)
local PANEL_BG  = Color3.fromRGB(20,  20,  36)
local HEADER_BG = Color3.fromRGB(26,  26,  48)
local CARD_BG   = Color3.fromRGB(28,  28,  48)
local TEXT_W    = Color3.fromRGB(255, 255, 255)
local TEXT_DIM  = Color3.fromRGB(160, 160, 200)
local GOLD      = Color3.fromRGB(255, 220,  50)
local SELL_CLR  = Color3.fromRGB(50,  200, 100)
local SELL_HOV  = Color3.fromRGB(70,  230, 120)

-- ---------------------------------------------------------------------------
local InventoryUI = {}
InventoryUI.__index = InventoryUI

function InventoryUI.new(playerGui)
    local self = setmetatable({}, InventoryUI)
    self.playerGui   = playerGui
    self.itemCards   = {}    -- [itemId] = card Frame
    self.onSellItem  = nil   -- callback(itemId)
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
function InventoryUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "InventoryGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    -- Backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Size                  = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3      = DARK_BG
    backdrop.BackgroundTransparency= 0.25
    backdrop.BorderSizePixel       = 0
    backdrop.Parent                = sg

    -- Panel
    local panel = Instance.new("Frame")
    panel.Name            = "Panel"
    panel.Size            = UDim2.fromScale(0.88, 0.86)
    panel.Position        = UDim2.fromScale(0.06, 0.07)
    panel.BackgroundColor3= PANEL_BG
    panel.BorderSizePixel = 0
    panel.Parent          = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    self.panel = panel

    -- Header bar
    local header = Instance.new("Frame")
    header.Size            = UDim2.new(1, 0, 0, 62)
    header.BackgroundColor3= HEADER_BG
    header.BorderSizePixel = 0
    header.Parent          = panel
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

    local headerFill = Instance.new("Frame")
    headerFill.Size            = UDim2.new(1, 0, 0, 14)
    headerFill.Position        = UDim2.new(0, 0, 1, -14)
    headerFill.BackgroundColor3= HEADER_BG
    headerFill.BorderSizePixel = 0
    headerFill.Parent          = header

    local title = Instance.new("TextLabel")
    title.Size                = UDim2.new(0.5, 0, 1, 0)
    title.Position            = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.Text                = "MY INVENTORY"
    title.TextColor3          = TEXT_W
    title.Font                = Enum.Font.GothamBold
    title.TextSize            = 22
    title.TextXAlignment      = Enum.TextXAlignment.Left
    title.Parent              = header

    -- Balance label
    local balance = Instance.new("TextLabel")
    balance.Name                 = "Balance"
    balance.Size                 = UDim2.new(0, 220, 1, 0)
    balance.Position             = UDim2.new(0.5, -110, 0, 0)
    balance.BackgroundTransparency = 1
    balance.Text                 = "$0"
    balance.TextColor3           = GOLD
    balance.Font                 = Enum.Font.GothamBold
    balance.TextSize             = 18
    balance.Parent               = header
    self.balanceLabel = balance

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size            = UDim2.new(0, 38, 0, 38)
    closeBtn.Position        = UDim2.new(1, -52, 0.5, -19)
    closeBtn.BackgroundColor3= Color3.fromRGB(200, 50, 50)
    closeBtn.Text            = "X"
    closeBtn.TextColor3      = TEXT_W
    closeBtn.Font            = Enum.Font.GothamBold
    closeBtn.TextSize        = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent          = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() self:hide() end)

    -- Empty state label
    local emptyLbl = Instance.new("TextLabel")
    emptyLbl.Name                  = "EmptyLabel"
    emptyLbl.Size                  = UDim2.new(1, 0, 1, -80)
    emptyLbl.Position              = UDim2.new(0, 0, 0, 70)
    emptyLbl.BackgroundTransparency= 1
    emptyLbl.Text                  = "Your inventory is empty.\nOpen some packs!"
    emptyLbl.TextColor3            = TEXT_DIM
    emptyLbl.Font                  = Enum.Font.Gotham
    emptyLbl.TextSize              = 18
    emptyLbl.Visible               = false
    emptyLbl.Parent                = panel
    self.emptyLbl = emptyLbl

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "ItemGrid"
    scroll.Size                  = UDim2.new(1, -20, 1, -74)
    scroll.Position              = UDim2.new(0, 10, 0, 66)
    scroll.BackgroundTransparency= 1
    scroll.BorderSizePixel       = 0
    scroll.ScrollBarThickness    = 5
    scroll.ScrollBarImageColor3  = Color3.fromRGB(90, 90, 140)
    scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.Parent                = panel
    self.scroll = scroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize            = UDim2.new(0, 200, 0, 280)
    grid.CellPadding         = UDim2.new(0, 16, 0, 16)
    grid.SortOrder           = Enum.SortOrder.LayoutOrder
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.Parent              = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent        = scroll
end

-- ---------------------------------------------------------------------------
-- Create one item card inside the scroll frame
-- ---------------------------------------------------------------------------
function InventoryUI:_makeCard(itemId: number, item, order: number)
    local rarityInfo = PackModule.getItemRarity(item.rarity)

    local card = Instance.new("Frame")
    card.Name             = tostring(itemId)
    card.BackgroundColor3 = CARD_BG
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order
    card.Parent           = self.scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Rarity colour top strip
    local strip = Instance.new("Frame")
    strip.Size            = UDim2.new(1, 0, 0, 6)
    strip.BackgroundColor3= rarityInfo.color
    strip.BorderSizePixel = 0
    strip.ZIndex          = 2
    strip.Parent          = card
    Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 12)
    local stripFill = Instance.new("Frame")
    stripFill.Size            = UDim2.new(1, 0, 0.5, 0)
    stripFill.Position        = UDim2.new(0, 0, 0.5, 0)
    stripFill.BackgroundColor3= rarityInfo.color
    stripFill.BorderSizePixel = 0
    stripFill.ZIndex          = 2
    stripFill.Parent          = strip

    -- Rarity badge
    local badge = Instance.new("Frame")
    badge.Size            = UDim2.new(1, -20, 0, 22)
    badge.Position        = UDim2.new(0, 10, 0, 12)
    badge.BackgroundColor3= rarityInfo.color
    badge.BorderSizePixel = 0
    badge.ZIndex          = 3
    badge.Parent          = card
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size                 = UDim2.fromScale(1, 1)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Text                 = item.rarity:upper()
    badgeLbl.TextColor3           = TEXT_W
    badgeLbl.Font                 = Enum.Font.GothamBold
    badgeLbl.TextSize             = 11
    badgeLbl.ZIndex               = 4
    badgeLbl.Parent               = badge

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Size            = UDim2.new(1, -20, 0, 120)
    img.Position        = UDim2.new(0, 10, 0, 42)
    img.BackgroundColor3= rarityInfo.color
    img.BackgroundTransparency = 0.7
    img.BorderSizePixel = 0
    img.Image           = item.imageId
    img.ScaleType       = Enum.ScaleType.Fit
    img.Parent          = card
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)

    -- Item name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -20, 0, 44)
    nameLbl.Position              = UDim2.new(0, 10, 0, 170)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = item.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 14
    nameLbl.TextWrapped           = true
    nameLbl.TextYAlignment        = Enum.TextYAlignment.Top
    nameLbl.Parent                = card

    -- Sell value
    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size                  = UDim2.new(1, -20, 0, 22)
    valueLbl.Position              = UDim2.new(0, 10, 0, 212)
    valueLbl.BackgroundTransparency= 1
    valueLbl.Text                  = "Sell: $" .. PackModule.formatNumber(item.sellValue)
    valueLbl.TextColor3            = GOLD
    valueLbl.Font                  = Enum.Font.GothamBold
    valueLbl.TextSize              = 13
    valueLbl.Parent                = card

    -- Sell button
    local sellBtn = Instance.new("TextButton")
    sellBtn.Size            = UDim2.new(1, -20, 0, 36)
    sellBtn.Position        = UDim2.new(0, 10, 1, -46)
    sellBtn.BackgroundColor3= SELL_CLR
    sellBtn.BorderSizePixel = 0
    sellBtn.Font            = Enum.Font.GothamBold
    sellBtn.TextSize        = 14
    sellBtn.TextColor3      = TEXT_W
    sellBtn.Text            = "SELL"
    sellBtn.Parent          = card
    Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 8)

    sellBtn.MouseEnter:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), { BackgroundColor3 = SELL_HOV }):Play()
    end)
    sellBtn.MouseLeave:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), { BackgroundColor3 = SELL_CLR }):Play()
    end)
    sellBtn.MouseButton1Click:Connect(function()
        if self.onSellItem then
            self.onSellItem(itemId)
        end
        -- Remove card immediately for responsiveness
        card:Destroy()
        self.itemCards[itemId] = nil
        self:_checkEmpty()
    end)

    self.itemCards[itemId] = card
    return card
end

function InventoryUI:_checkEmpty()
    local hasItems = next(self.itemCards) ~= nil
    self.emptyLbl.Visible = not hasItems
    self.scroll.Visible   = hasItems
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Rebuild the grid from an inventory table: { [itemId] = itemData, ... }
function InventoryUI:populate(inventory)
    for _, card in pairs(self.itemCards) do
        card:Destroy()
    end
    self.itemCards = {}

    local order = 1
    for itemId, item in pairs(inventory) do
        self:_makeCard(itemId, item, order)
        order += 1
    end

    self:_checkEmpty()
end

-- Add a single new item card without rebuilding the whole grid
function InventoryUI:addItem(itemId: number, item)
    local order = 0
    for _, card in pairs(self.itemCards) do
        order = math.max(order, card.LayoutOrder)
    end
    self:_makeCard(itemId, item, order + 1)
    self:_checkEmpty()
end

-- Remove a card by itemId (e.g. after selling from the opening screen)
function InventoryUI:removeItem(itemId: number)
    local card = self.itemCards[itemId]
    if card then
        card:Destroy()
        self.itemCards[itemId] = nil
    end
    self:_checkEmpty()
end

function InventoryUI:updateBalance(balance: number)
    self.balanceLabel.Text = "$" .. PackModule.formatNumber(balance)
end

function InventoryUI:show()
    self.screenGui.Enabled = true
    self.panel.Position = UDim2.fromScale(0.06, 0.00)
    TweenService:Create(self.panel, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.06, 0.07),
    }):Play()
end

function InventoryUI:hide()
    self.screenGui.Enabled = false
end

return InventoryUI
