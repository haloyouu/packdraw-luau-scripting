-- =============================================================================
-- PreviewUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Shows all possible rewards in a pack when the player clicks the card body.
-- Items are sorted best-first (highest sell value at top).
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local DARK_BG   = Color3.fromRGB(12,  12,  22)
local PANEL_BG  = Color3.fromRGB(20,  20,  36)
local HEADER_BG = Color3.fromRGB(26,  26,  48)
local ROW_BG    = Color3.fromRGB(28,  28,  48)
local TEXT_W    = Color3.fromRGB(255, 255, 255)
local TEXT_DIM  = Color3.fromRGB(160, 160, 200)
local GOLD      = Color3.fromRGB(255, 220,  50)

-- ---------------------------------------------------------------------------
local PreviewUI = {}
PreviewUI.__index = PreviewUI

function PreviewUI.new(playerGui)
    local self = setmetatable({}, PreviewUI)
    self.playerGui    = playerGui
    self._totalWeight = 0
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
function PreviewUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "PackPreviewGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    -- Dim backdrop (also acts as a click-outside-to-close zone)
    local backdrop = Instance.new("TextButton")
    backdrop.Size                  = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3      = DARK_BG
    backdrop.BackgroundTransparency= 0.22
    backdrop.BorderSizePixel       = 0
    backdrop.Text                  = ""
    backdrop.AutoButtonColor       = false
    backdrop.Parent                = sg
    backdrop.MouseButton1Click:Connect(function() self:hide() end)

    -- Main panel
    local panel = Instance.new("Frame")
    panel.Name            = "Panel"
    panel.Size            = UDim2.fromScale(0.54, 0.84)
    panel.Position        = UDim2.fromScale(0.23, 0.08)
    panel.BackgroundColor3= PANEL_BG
    panel.BorderSizePixel = 0
    panel.Parent          = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
    self.panel = panel

    -- ---- Header ------------------------------------------------------------
    local header = Instance.new("Frame")
    header.Size            = UDim2.new(1, 0, 0, 62)
    header.BackgroundColor3= HEADER_BG
    header.BorderSizePixel = 0
    header.Parent          = panel
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
    -- cover bottom rounding
    local hFill = Instance.new("Frame")
    hFill.Size            = UDim2.new(1, 0, 0, 16)
    hFill.Position        = UDim2.new(0, 0, 1, -16)
    hFill.BackgroundColor3= HEADER_BG
    hFill.BorderSizePixel = 0
    hFill.Parent          = header

    -- Tier badge
    local tierBadge = Instance.new("Frame")
    tierBadge.Name             = "TierBadge"
    tierBadge.Size             = UDim2.new(0, 80, 0, 26)
    tierBadge.Position         = UDim2.new(0, 14, 0.5, -13)
    tierBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    tierBadge.BorderSizePixel  = 0
    tierBadge.Parent           = header
    Instance.new("UICorner", tierBadge).CornerRadius = UDim.new(0, 6)

    local tierLbl = Instance.new("TextLabel")
    tierLbl.Size                  = UDim2.fromScale(1, 1)
    tierLbl.BackgroundTransparency= 1
    tierLbl.Text                  = "TIER"
    tierLbl.TextColor3            = TEXT_W
    tierLbl.Font                  = Enum.Font.GothamBold
    tierLbl.TextSize              = 12
    tierLbl.Parent                = tierBadge
    self.tierBadge = tierBadge
    self.tierLbl   = tierLbl

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name                  = "Title"
    titleLbl.Size                  = UDim2.new(0.55, 0, 1, 0)
    titleLbl.Position              = UDim2.new(0, 106, 0, 0)
    titleLbl.BackgroundTransparency= 1
    titleLbl.Text                  = "WHAT'S INSIDE"
    titleLbl.TextColor3            = TEXT_W
    titleLbl.Font                  = Enum.Font.GothamBold
    titleLbl.TextSize              = 17
    titleLbl.TextXAlignment        = Enum.TextXAlignment.Left
    titleLbl.Parent                = header
    self.titleLbl = titleLbl

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size            = UDim2.new(0, 38, 0, 38)
    closeBtn.Position        = UDim2.new(1, -50, 0.5, -19)
    closeBtn.BackgroundColor3= Color3.fromRGB(200, 50, 50)
    closeBtn.Text            = "X"
    closeBtn.TextColor3      = TEXT_W
    closeBtn.Font            = Enum.Font.GothamBold
    closeBtn.TextSize        = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent          = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() self:hide() end)

    -- ---- Scrolling list ----------------------------------------------------
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "ItemList"
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

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding   = UDim.new(0, 6)
    list.Parent    = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft   = UDim.new(0, 2)
    pad.PaddingRight  = UDim.new(0, 2)
    pad.Parent        = scroll
end

-- ---------------------------------------------------------------------------
function PreviewUI:_makeRow(item, order)
    local rarityInfo = PackModule.getItemRarity(item.rarity)
    local chancePct  = self._totalWeight > 0 and (item.weight / self._totalWeight * 100) or 0

    local row = Instance.new("Frame")
    row.Name             = tostring(order)
    row.Size             = UDim2.new(1, 0, 0, 68)
    row.BackgroundColor3 = ROW_BG
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.Parent           = self.scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    -- Left rarity strip
    local strip = Instance.new("Frame")
    strip.Size            = UDim2.new(0, 5, 1, 0)
    strip.BackgroundColor3= rarityInfo.color
    strip.BorderSizePixel = 0
    strip.Parent          = row
    Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 10)
    -- Cover right side rounding of strip
    local stripFill = Instance.new("Frame")
    stripFill.Size            = UDim2.new(0.5, 0, 1, 0)
    stripFill.Position        = UDim2.new(0.5, 0, 0, 0)
    stripFill.BackgroundColor3= rarityInfo.color
    stripFill.BorderSizePixel = 0
    stripFill.Parent          = strip

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Size                  = UDim2.new(0, 52, 0, 52)
    img.Position              = UDim2.new(0, 14, 0.5, -26)
    img.BackgroundColor3      = rarityInfo.color
    img.BackgroundTransparency= 0.82
    img.BorderSizePixel       = 0
    img.Image                 = item.imageId
    img.ScaleType             = Enum.ScaleType.Fit
    img.Parent                = row
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)

    -- Item name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(0.44, 0, 0, 24)
    nameLbl.Position              = UDim2.new(0, 76, 0.5, -24)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = item.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 13
    nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
    nameLbl.TextWrapped           = true
    nameLbl.Parent                = row

    -- Rarity badge
    local badge = Instance.new("Frame")
    badge.Size            = UDim2.new(0, 82, 0, 20)
    badge.Position        = UDim2.new(0, 76, 0.5, 4)
    badge.BackgroundColor3= rarityInfo.color
    badge.BorderSizePixel = 0
    badge.Parent          = row
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)

    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size                  = UDim2.fromScale(1, 1)
    badgeLbl.BackgroundTransparency= 1
    badgeLbl.Text                  = item.rarity:upper()
    badgeLbl.TextColor3            = TEXT_W
    badgeLbl.Font                  = Enum.Font.GothamBold
    badgeLbl.TextSize              = 10
    badgeLbl.Parent                = badge

    -- Sell value
    local valLbl = Instance.new("TextLabel")
    valLbl.Size                  = UDim2.new(0.27, 0, 0, 22)
    valLbl.Position              = UDim2.new(1, -14, 0.5, -26)
    valLbl.AnchorPoint           = Vector2.new(1, 0)
    valLbl.BackgroundTransparency= 1
    valLbl.Text                  = "$" .. PackModule.formatNumber(item.sellValue)
    valLbl.TextColor3            = GOLD
    valLbl.Font                  = Enum.Font.GothamBold
    valLbl.TextSize              = 13
    valLbl.TextXAlignment        = Enum.TextXAlignment.Right
    valLbl.Parent                = row

    -- Drop chance
    local chanceLbl = Instance.new("TextLabel")
    chanceLbl.Size                  = UDim2.new(0.27, 0, 0, 18)
    chanceLbl.Position              = UDim2.new(1, -14, 0.5, 6)
    chanceLbl.AnchorPoint           = Vector2.new(1, 0)
    chanceLbl.BackgroundTransparency= 1
    chanceLbl.Text                  = string.format("%.1f%% chance", chancePct)
    chanceLbl.TextColor3            = TEXT_DIM
    chanceLbl.Font                  = Enum.Font.Gotham
    chanceLbl.TextSize              = 11
    chanceLbl.TextXAlignment        = Enum.TextXAlignment.Right
    chanceLbl.Parent                = row
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function PreviewUI:show(pack)
    -- Clear previous rows
    for _, child in ipairs(self.scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- Update header tier badge
    local tier = PackModule.getPackTier(pack.tier)
    self.tierBadge.BackgroundColor3 = tier.primaryColor
    self.tierLbl.TextColor3         = tier.textColor
    self.tierLbl.Text               = tier.displayName
    self.titleLbl.Text              = pack.name .. "  —  What's Inside"

    -- Compute total weight for drop % display
    self._totalWeight = 0
    for _, item in ipairs(pack.rewards) do
        self._totalWeight += item.weight
    end

    -- Sort best-first (Legendary at top — more exciting)
    local sorted = {}
    for _, item in ipairs(pack.rewards) do
        table.insert(sorted, item)
    end
    table.sort(sorted, function(a, b) return a.sellValue > b.sellValue end)

    for i, item in ipairs(sorted) do
        self:_makeRow(item, i)
    end

    -- Slide-in animation
    self.screenGui.Enabled = true
    self.panel.Position    = UDim2.fromScale(0.23, 0.02)
    TweenService:Create(self.panel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.23, 0.08),
    }):Play()
end

function PreviewUI:hide()
    self.screenGui.Enabled = false
end

return PreviewUI
