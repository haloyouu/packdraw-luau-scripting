-- =============================================================================
-- BusinessUI  (ModuleScript — ReplicatedStorage/UI)
-- Passive income business shop. Buy once, earn forever.
-- =============================================================================

local TweenService   = game:GetService("TweenService")
local PackModule     = require(script.Parent.Parent.PackModule)
local BusinessConfig = require(script.Parent.Parent.BusinessConfig)

local PANEL_BG  = Color3.fromRGB(20,  20,  36)
local HEADER_BG = Color3.fromRGB(26,  26,  48)
local DARK_BG   = Color3.fromRGB(12,  12,  22)
local CARD_BG   = Color3.fromRGB(28,  28,  48)
local TEXT_W    = Color3.fromRGB(255, 255, 255)
local TEXT_DIM  = Color3.fromRGB(160, 160, 200)
local GOLD      = Color3.fromRGB(255, 220,  50)
local GREEN     = Color3.fromRGB( 80, 220,  80)

-- ---------------------------------------------------------------------------
local BusinessUI = {}
BusinessUI.__index = BusinessUI

function BusinessUI.new(playerGui)
    local self = setmetatable({}, BusinessUI)
    self.playerGui     = playerGui
    self.onBuy         = nil       -- callback(businessId)
    self.businessCards = {}
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
function BusinessUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "BusinessGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    local backdrop = Instance.new("Frame")
    backdrop.Size                   = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3       = DARK_BG
    backdrop.BackgroundTransparency = 0.25
    backdrop.BorderSizePixel        = 0
    backdrop.Parent                 = sg

    local panel = Instance.new("Frame")
    panel.Name             = "Panel"
    panel.Size             = UDim2.fromScale(0.88, 0.86)
    panel.Position         = UDim2.fromScale(0.06, 0.07)
    panel.BackgroundColor3 = PANEL_BG
    panel.BorderSizePixel  = 0
    panel.Parent           = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    self.panel = panel

    -- ── Header ────────────────────────────────────────────────────────────
    local header = Instance.new("Frame")
    header.Size            = UDim2.new(1, 0, 0, 70)
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
    title.Size                  = UDim2.new(0.4, 0, 0, 26)
    title.Position              = UDim2.new(0, 18, 0, 8)
    title.BackgroundTransparency= 1
    title.Text                  = "YOUR BUSINESSES"
    title.TextColor3            = TEXT_W
    title.Font                  = Enum.Font.GothamBold
    title.TextSize              = 20
    title.TextXAlignment        = Enum.TextXAlignment.Left
    title.Parent                = header

    local rateLbl = Instance.new("TextLabel")
    rateLbl.Size                  = UDim2.new(0.6, 0, 0, 18)
    rateLbl.Position              = UDim2.new(0, 18, 0, 44)
    rateLbl.BackgroundTransparency= 1
    rateLbl.Text                  = "$25/hr  ·  Max offline: $200"
    rateLbl.TextColor3            = GREEN
    rateLbl.Font                  = Enum.Font.Gotham
    rateLbl.TextSize              = 13
    rateLbl.TextXAlignment        = Enum.TextXAlignment.Left
    rateLbl.Parent                = header
    self.rateLbl = rateLbl

    local balance = Instance.new("TextLabel")
    balance.Name                  = "Balance"
    balance.Size                  = UDim2.new(0, 220, 0, 30)
    balance.Position              = UDim2.new(0.5, -110, 0, 20)
    balance.BackgroundTransparency= 1
    balance.Text                  = "$0"
    balance.TextColor3            = GOLD
    balance.Font                  = Enum.Font.GothamBold
    balance.TextSize              = 18
    balance.Parent                = header
    self.balanceLabel = balance

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size            = UDim2.new(0, 38, 0, 38)
    closeBtn.Position        = UDim2.new(1, -52, 0, 16)
    closeBtn.BackgroundColor3= Color3.fromRGB(200, 50, 50)
    closeBtn.Text            = "X"
    closeBtn.TextColor3      = TEXT_W
    closeBtn.Font            = Enum.Font.GothamBold
    closeBtn.TextSize        = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent          = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() self:hide() end)

    -- ── Scroll grid ───────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "BusinessGrid"
    scroll.Size                  = UDim2.new(1, -20, 1, -82)
    scroll.Position              = UDim2.new(0, 10, 0, 74)
    scroll.BackgroundTransparency= 1
    scroll.BorderSizePixel       = 0
    scroll.ScrollBarThickness    = 5
    scroll.ScrollBarImageColor3  = Color3.fromRGB(90, 90, 140)
    scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.Parent                = panel
    self.scroll = scroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize            = UDim2.new(0, 210, 0, 295)
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
function BusinessUI:_makeCard(business, order, isOwned, playerBalance)
    local color = business.color

    local card = Instance.new("Frame")
    card.Name             = business.id
    card.BackgroundColor3 = CARD_BG
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order
    card.Parent           = self.scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Coloured top strip
    local strip = Instance.new("Frame")
    strip.Size            = UDim2.new(1, 0, 0, 6)
    strip.BackgroundColor3= color
    strip.BorderSizePixel = 0
    strip.ZIndex          = 2
    strip.Parent          = card
    Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 12)
    local stripFill = Instance.new("Frame")
    stripFill.Size            = UDim2.new(1, 0, 0.5, 0)
    stripFill.Position        = UDim2.new(0, 0, 0.5, 0)
    stripFill.BackgroundColor3= color
    stripFill.BorderSizePixel = 0
    stripFill.ZIndex          = 2
    stripFill.Parent          = strip

    -- Image
    local img = Instance.new("ImageLabel")
    img.Size                = UDim2.new(1, -20, 0, 118)
    img.Position            = UDim2.new(0, 10, 0, 12)
    img.BackgroundColor3    = Color3.fromRGB(35, 35, 55)
    img.BorderSizePixel     = 0
    img.Image               = business.imageId
    img.ScaleType           = Enum.ScaleType.Fit
    img.Parent              = card
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)

    -- Hourly income (prominent)
    local incomeLbl = Instance.new("TextLabel")
    incomeLbl.Size                  = UDim2.new(1, -20, 0, 30)
    incomeLbl.Position              = UDim2.new(0, 10, 0, 138)
    incomeLbl.BackgroundTransparency= 1
    incomeLbl.Text                  = "+" .. PackModule.formatNumber(business.hourlyIncome) .. "/hr"
    incomeLbl.TextColor3            = GREEN
    incomeLbl.Font                  = Enum.Font.GothamBold
    incomeLbl.TextSize              = 18
    incomeLbl.Parent                = card

    -- Name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -20, 0, 24)
    nameLbl.Position              = UDim2.new(0, 10, 0, 170)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = business.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 14
    nameLbl.TextWrapped           = true
    nameLbl.Parent                = card

    -- Description
    local descLbl = Instance.new("TextLabel")
    descLbl.Size                  = UDim2.new(1, -20, 0, 36)
    descLbl.Position              = UDim2.new(0, 10, 0, 196)
    descLbl.BackgroundTransparency= 1
    descLbl.Text                  = business.description
    descLbl.TextColor3            = TEXT_DIM
    descLbl.Font                  = Enum.Font.Gotham
    descLbl.TextSize              = 11
    descLbl.TextWrapped           = true
    descLbl.TextYAlignment        = Enum.TextYAlignment.Top
    descLbl.Parent                = card

    -- BUY button or OWNED badge
    if isOwned then
        local badge = Instance.new("Frame")
        badge.Size            = UDim2.new(1, -20, 0, 38)
        badge.Position        = UDim2.new(0, 10, 1, -48)
        badge.BackgroundColor3= Color3.fromRGB(20, 80, 35)
        badge.BorderSizePixel = 0
        badge.Parent          = card
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 8)
        local ownedLbl = Instance.new("TextLabel")
        ownedLbl.Size                  = UDim2.fromScale(1, 1)
        ownedLbl.BackgroundTransparency= 1
        ownedLbl.Text                  = "OWNED"
        ownedLbl.TextColor3            = GREEN
        ownedLbl.Font                  = Enum.Font.GothamBold
        ownedLbl.TextSize              = 14
        ownedLbl.Parent                = badge
    else
        local canAfford = playerBalance >= business.cost
        local btnColor  = canAfford and color or Color3.fromRGB(55, 55, 55)

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size            = UDim2.new(1, -20, 0, 38)
        buyBtn.Position        = UDim2.new(0, 10, 1, -48)
        buyBtn.BackgroundColor3= btnColor
        buyBtn.Text            = "BUY  $" .. PackModule.formatNumber(business.cost)
        buyBtn.TextColor3      = canAfford and Color3.fromRGB(15, 15, 15) or TEXT_DIM
        buyBtn.Font            = Enum.Font.GothamBold
        buyBtn.TextSize        = 13
        buyBtn.BorderSizePixel = 0
        buyBtn.Parent          = card
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 8)

        if canAfford then
            local hoverColor = color:Lerp(Color3.new(1, 1, 1), 0.2)
            buyBtn.MouseEnter:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(0.12), { BackgroundColor3 = hoverColor }):Play()
            end)
            buyBtn.MouseLeave:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
            end)
            buyBtn.MouseButton1Click:Connect(function()
                if self.onBuy then self.onBuy(business.id) end
            end)
        end
    end

    self.businessCards[business.id] = card
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function BusinessUI:populate(ownedBusinesses, playerBalance)
    for _, card in pairs(self.businessCards) do card:Destroy() end
    self.businessCards = {}

    for i, business in ipairs(BusinessConfig.Businesses) do
        local owned = ownedBusinesses[business.id] == true
        self:_makeCard(business, i, owned, playerBalance)
    end

    local rate       = BusinessConfig.getHourlyRate(ownedBusinesses)
    local maxOffline = rate * BusinessConfig.MAX_OFFLINE_HOURS
    self.rateLbl.Text = string.format("$%s/hr  ·  Max offline: $%s",
        PackModule.formatNumber(rate),
        PackModule.formatNumber(maxOffline))
end

function BusinessUI:updateBalance(balance)
    self.balanceLabel.Text = "$" .. PackModule.formatNumber(balance)
end

function BusinessUI:show()
    self.screenGui.Enabled = true
    self.panel.Position    = UDim2.fromScale(0.06, 0.00)
    TweenService:Create(self.panel, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.06, 0.07),
    }):Play()
end

function BusinessUI:hide()
    self.screenGui.Enabled = false
end

return BusinessUI
