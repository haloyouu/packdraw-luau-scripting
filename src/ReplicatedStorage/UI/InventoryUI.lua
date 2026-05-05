-- =============================================================================
-- InventoryUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Scrollable grid of held items. Each card has SELL and FLEX buttons.
-- Sell button only removes the card after the server confirms success.
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local FONT_BOLD = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Bold)
local FONT_REG  = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
local DARK_BG   = Color3.fromRGB(14,  14,  14)
local PANEL_BG  = Color3.fromRGB(28,  28,  28)
local HEADER_BG = Color3.fromRGB(40,  40,  40)
local CARD_BG   = Color3.fromRGB(46,  46,  46)
local TEXT_W    = Color3.fromRGB(255, 255, 255)
local TEXT_DIM  = Color3.fromRGB(170, 170, 170)
local GOLD      = Color3.fromRGB(255, 220,  50)
local SELL_CLR  = Color3.fromRGB( 50, 200, 100)
local SELL_HOV  = Color3.fromRGB( 70, 230, 120)
local FLEX_CLR  = Color3.fromRGB(130,  40, 210)
local FLEX_HOV  = Color3.fromRGB(160,  70, 240)

-- ---------------------------------------------------------------------------
local InventoryUI = {}
InventoryUI.__index = InventoryUI

function InventoryUI.new(playerGui)
    local self = setmetatable({}, InventoryUI)
    self.playerGui   = playerGui
    self.itemCards   = {}    -- [itemId] = card Frame
    self.onSellItem  = nil   -- callback(itemId) → must return true/false
    self.onFlexItem  = nil   -- callback(itemId, item)
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

    local backdrop = Instance.new("Frame")
    backdrop.Size                  = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3      = DARK_BG
    backdrop.BackgroundTransparency= 0.25
    backdrop.BorderSizePixel       = 0
    backdrop.Parent                = sg

    local panel = Instance.new("Frame")
    panel.Name            = "Panel"
    panel.Size            = UDim2.fromScale(0.88, 0.86)
    panel.Position        = UDim2.fromScale(0.06, 0.07)
    panel.BackgroundColor3= PANEL_BG
    panel.BorderSizePixel = 0
    panel.Parent          = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local panelGrad = Instance.new("UIGradient")
    panelGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    })
    panelGrad.Rotation = 90
    panelGrad.Parent = panel
    self.panel = panel

    -- Header
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
    title.FontFace            = FONT_BOLD
    title.TextSize            = 22
    title.TextXAlignment      = Enum.TextXAlignment.Left
    title.Parent              = header

    local balance = Instance.new("TextLabel")
    balance.Name                 = "Balance"
    balance.Size                 = UDim2.new(0, 220, 1, 0)
    balance.Position             = UDim2.new(0.5, -110, 0, 0)
    balance.BackgroundTransparency = 1
    balance.Text                 = "$0"
    balance.TextColor3           = GOLD
    balance.FontFace             = FONT_BOLD
    balance.TextSize             = 18
    balance.Parent               = header
    self.balanceLabel = balance

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size            = UDim2.new(0, 38, 0, 38)
    closeBtn.Position        = UDim2.new(1, -52, 0.5, -19)
    closeBtn.BackgroundColor3= Color3.fromRGB(200, 50, 50)
    closeBtn.Text            = "X"
    closeBtn.TextColor3      = TEXT_W
    closeBtn.FontFace        = FONT_BOLD
    closeBtn.TextSize        = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent          = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() self:hide() end)

    -- Empty state
    local emptyLbl = Instance.new("TextLabel")
    emptyLbl.Name                  = "EmptyLabel"
    emptyLbl.Size                  = UDim2.new(1, 0, 1, -80)
    emptyLbl.Position              = UDim2.new(0, 0, 0, 70)
    emptyLbl.BackgroundTransparency= 1
    emptyLbl.Text                  = "Your inventory is empty.\nOpen some packs!"
    emptyLbl.TextColor3            = TEXT_DIM
    emptyLbl.FontFace              = FONT_REG
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
    scroll.ScrollBarImageColor3  = Color3.fromRGB(90, 90, 90)
    scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.Parent                = panel
    self.scroll = scroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize            = UDim2.new(0, 200, 0, 320)
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
function InventoryUI:_makeCard(itemId, item, order)
    local rarityInfo = PackModule.getItemRarity(item.rarity)

    local card = Instance.new("Frame")
    card.Name             = tostring(itemId)
    card.BackgroundColor3 = CARD_BG
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order
    card.Parent           = self.scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Rarity top strip
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
    badgeLbl.FontFace             = FONT_BOLD
    badgeLbl.TextSize             = 11
    badgeLbl.ZIndex               = 4
    badgeLbl.Parent               = badge

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Size                 = UDim2.new(1, -20, 0, 118)
    img.Position             = UDim2.new(0, 10, 0, 42)
    img.BackgroundColor3     = rarityInfo.color
    img.BackgroundTransparency = 0.75
    img.BorderSizePixel      = 0
    img.Image                = item.imageId
    img.ScaleType            = Enum.ScaleType.Fit
    img.Parent               = card
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)

    -- Item name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -20, 0, 40)
    nameLbl.Position              = UDim2.new(0, 10, 0, 168)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = item.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.FontFace              = FONT_BOLD
    nameLbl.TextSize              = 13
    nameLbl.TextWrapped           = true
    nameLbl.TextYAlignment        = Enum.TextYAlignment.Top
    nameLbl.Parent                = card

    -- Sell value
    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size                  = UDim2.new(1, -20, 0, 20)
    valueLbl.Position              = UDim2.new(0, 10, 0, 210)
    valueLbl.BackgroundTransparency= 1
    valueLbl.Text                  = "Sell: $" .. PackModule.formatNumber(item.sellValue)
    valueLbl.TextColor3            = GOLD
    valueLbl.FontFace              = FONT_BOLD
    valueLbl.TextSize              = 12
    valueLbl.Parent                = card

    -- ── SELL button ──────────────────────────────────────────────────────
    local sellBtn = Instance.new("TextButton")
    sellBtn.Size            = UDim2.new(1, -20, 0, 34)
    sellBtn.Position        = UDim2.new(0, 10, 1, -82)
    sellBtn.BackgroundColor3= SELL_CLR
    sellBtn.BorderSizePixel = 0
    sellBtn.FontFace        = FONT_BOLD
    sellBtn.TextSize        = 13
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
        sellBtn.Active = false
        sellBtn.Text   = "Selling..."
        sellBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

        local success = false
        if self.onSellItem then
            success = self.onSellItem(itemId)
        end

        if success then
            card:Destroy()
            self.itemCards[itemId] = nil
            self:_checkEmpty()
        else
            sellBtn.Active           = true
            sellBtn.Text             = "SELL"
            sellBtn.BackgroundColor3 = SELL_CLR
        end
    end)

    -- ── FLEX button ──────────────────────────────────────────────────────
    local flexBtn = Instance.new("TextButton")
    flexBtn.Size            = UDim2.new(1, -20, 0, 34)
    flexBtn.Position        = UDim2.new(0, 10, 1, -44)
    flexBtn.BackgroundColor3= FLEX_CLR
    flexBtn.BorderSizePixel = 0
    flexBtn.FontFace        = FONT_BOLD
    flexBtn.TextSize        = 13
    flexBtn.TextColor3      = TEXT_W
    flexBtn.Text            = "FLEX IT"
    flexBtn.Parent          = card
    Instance.new("UICorner", flexBtn).CornerRadius = UDim.new(0, 8)

    flexBtn.MouseEnter:Connect(function()
        TweenService:Create(flexBtn, TweenInfo.new(0.12), { BackgroundColor3 = FLEX_HOV }):Play()
    end)
    flexBtn.MouseLeave:Connect(function()
        TweenService:Create(flexBtn, TweenInfo.new(0.12), { BackgroundColor3 = FLEX_CLR }):Play()
    end)
    flexBtn.MouseButton1Click:Connect(function()
        if self.onFlexItem then
            self.onFlexItem(itemId, item)
        end
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

function InventoryUI:populate(inventory)
    for _, card in pairs(self.itemCards) do card:Destroy() end
    self.itemCards = {}

    local order = 1
    for itemId, item in pairs(inventory) do
        self:_makeCard(itemId, item, order)
        order += 1
    end
    self:_checkEmpty()
end

function InventoryUI:addItem(itemId, item)
    local maxOrder = 0
    for _, card in pairs(self.itemCards) do
        maxOrder = math.max(maxOrder, card.LayoutOrder)
    end
    self:_makeCard(itemId, item, maxOrder + 1)
    self:_checkEmpty()
end

function InventoryUI:removeItem(itemId)
    local card = self.itemCards[itemId]
    if card then card:Destroy(); self.itemCards[itemId] = nil end
    self:_checkEmpty()
end

function InventoryUI:updateBalance(balance)
    self.balanceLabel.Text = "$" .. PackModule.formatNumber(balance)
end

function InventoryUI:show()
    self.screenGui.Enabled = true
    self.panel.Position = UDim2.fromScale(0.06, 0)
    TweenService:Create(self.panel, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.06, 0.07)
    }):Play()
end

function InventoryUI:hide()
    self.screenGui.Enabled = false
end

return InventoryUI
