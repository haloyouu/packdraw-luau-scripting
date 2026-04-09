-- =============================================================================
-- StoreUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Builds and manages the pack store ScreenGui.
-- All UI is created programmatically so the module works without Studio.
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

-- ---------------------------------------------------------------------------
local StoreUI = {}
StoreUI.__index = StoreUI

function StoreUI.new(playerGui)
    local self = setmetatable({}, StoreUI)
    self.playerGui  = playerGui
    self.packCards  = {}         -- [packId] = { card, openBtn, pack }
    self.onPackSelect = nil      -- callback(packId)
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
-- Build the static skeleton (title bar, scroll area).
-- Pack cards are populated separately via :populate().
-- ---------------------------------------------------------------------------
function StoreUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name            = "PackStoreGui"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.Enabled         = false
    sg.Parent          = self.playerGui
    self.screenGui = sg

    -- Semi-transparent backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Size                  = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3      = DARK_BG
    backdrop.BackgroundTransparency= 0.25
    backdrop.BorderSizePixel       = 0
    backdrop.Parent                = sg

    -- Main panel
    local panel = Instance.new("Frame")
    panel.Name            = "Panel"
    panel.Size            = UDim2.fromScale(0.88, 0.86)
    panel.Position        = UDim2.fromScale(0.06, 0.07)
    panel.BackgroundColor3= PANEL_BG
    panel.BorderSizePixel = 0
    panel.Parent          = sg
    self.panel = panel
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

    -- ---- Header bar -------------------------------------------------------
    local header = Instance.new("Frame")
    header.Size            = UDim2.new(1, 0, 0, 62)
    header.BackgroundColor3= HEADER_BG
    header.BorderSizePixel = 0
    header.Parent          = panel
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

    -- Cover rounded bottom corners of header
    local headerFill = Instance.new("Frame")
    headerFill.Size            = UDim2.new(1, 0, 0, 14)
    headerFill.Position        = UDim2.new(0, 0, 1, -14)
    headerFill.BackgroundColor3= HEADER_BG
    headerFill.BorderSizePixel = 0
    headerFill.Parent          = header

    -- Title
    local title = Instance.new("TextLabel")
    title.Size                = UDim2.new(0.5, 0, 1, 0)
    title.Position            = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.Text                = "PACK STORE"
    title.TextColor3          = TEXT_W
    title.Font                = Enum.Font.GothamBold
    title.TextSize            = 22
    title.TextXAlignment      = Enum.TextXAlignment.Left
    title.Parent              = header

    -- Balance label (centred in header)
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

    -- ---- Scrolling grid ---------------------------------------------------
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "PackGrid"
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
    grid.CellSize             = UDim2.new(0, 210, 0, 295)
    grid.CellPadding          = UDim2.new(0, 16, 0, 16)
    grid.SortOrder            = Enum.SortOrder.LayoutOrder
    grid.HorizontalAlignment  = Enum.HorizontalAlignment.Center
    grid.Parent               = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent        = scroll
end

-- ---------------------------------------------------------------------------
-- Create one pack card inside the scroll frame.
-- ---------------------------------------------------------------------------
function StoreUI:_makeCard(pack, order: number)
    local tier = PackModule.getPackTier(pack.tier)

    local card = Instance.new("Frame")
    card.Name             = pack.id
    card.BackgroundColor3 = CARD_BG
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order
    card.Parent           = self.scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Coloured top strip
    local strip = Instance.new("Frame")
    strip.Size            = UDim2.new(1, 0, 0, 6)
    strip.BackgroundColor3= tier.primaryColor
    strip.BorderSizePixel = 0
    strip.ZIndex          = 2
    strip.Parent          = card
    Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 12)
    -- hide bottom rounding of the strip
    local stripFill = Instance.new("Frame")
    stripFill.Size            = UDim2.new(1, 0, 0.5, 0)
    stripFill.Position        = UDim2.new(0, 0, 0.5, 0)
    stripFill.BackgroundColor3= tier.primaryColor
    stripFill.BorderSizePixel = 0
    stripFill.ZIndex          = 2
    stripFill.Parent          = strip

    -- Tier badge
    local badge = Instance.new("Frame")
    badge.Size            = UDim2.new(1, -20, 0, 24)
    badge.Position        = UDim2.new(0, 10, 0, 12)
    badge.BackgroundColor3= tier.primaryColor
    badge.BorderSizePixel = 0
    badge.ZIndex          = 3
    badge.Parent          = card
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size                 = UDim2.fromScale(1, 1)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Text                 = tier.displayName
    badgeLbl.TextColor3           = tier.textColor
    badgeLbl.Font                 = Enum.Font.GothamBold
    badgeLbl.TextSize             = 12
    badgeLbl.ZIndex               = 4
    badgeLbl.Parent               = badge

    -- Pack image
    local img = Instance.new("ImageLabel")
    img.Size            = UDim2.new(1, -20, 0, 130)
    img.Position        = UDim2.new(0, 10, 0, 44)
    img.BackgroundColor3= Color3.fromRGB(35, 35, 55)
    img.BorderSizePixel = 0
    img.Image           = pack.imageId
    img.ScaleType       = Enum.ScaleType.Fit
    img.Parent          = card
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)

    -- Pack name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -20, 0, 28)
    nameLbl.Position              = UDim2.new(0, 10, 0, 182)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = pack.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 15
    nameLbl.TextWrapped           = true
    nameLbl.Parent                = card

    -- Description
    local descLbl = Instance.new("TextLabel")
    descLbl.Size                  = UDim2.new(1, -20, 0, 38)
    descLbl.Position              = UDim2.new(0, 10, 0, 208)
    descLbl.BackgroundTransparency= 1
    descLbl.Text                  = pack.description
    descLbl.TextColor3            = TEXT_DIM
    descLbl.Font                  = Enum.Font.Gotham
    descLbl.TextSize              = 11
    descLbl.TextWrapped           = true
    descLbl.TextYAlignment        = Enum.TextYAlignment.Top
    descLbl.Parent                = card

    -- Open button
    local openBtn = Instance.new("TextButton")
    openBtn.Name            = "OpenBtn"
    openBtn.Size            = UDim2.new(1, -20, 0, 38)
    openBtn.Position        = UDim2.new(0, 10, 1, -48)
    openBtn.BackgroundColor3= tier.primaryColor
    openBtn.BorderSizePixel = 0
    openBtn.Font            = Enum.Font.GothamBold
    openBtn.TextSize        = 14
    openBtn.TextColor3      = tier.textColor
    openBtn.Parent          = card
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)

    if pack.price == 0 then
        openBtn.Text = "FREE  —  OPEN"
    else
        openBtn.Text = "OPEN  —  $" .. PackModule.formatNumber(pack.price)
    end

    -- Hover effect
    openBtn.MouseEnter:Connect(function()
        TweenService:Create(openBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = tier.glowColor
        }):Play()
    end)
    openBtn.MouseLeave:Connect(function()
        TweenService:Create(openBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = tier.primaryColor
        }):Play()
    end)

    openBtn.MouseButton1Click:Connect(function()
        if self.onPackSelect then
            self.onPackSelect(pack.id)
        end
    end)

    self.packCards[pack.id] = { card = card, openBtn = openBtn, pack = pack }
    return card
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Rebuild pack grid from PackConfig (call when store opens or data changes)
function StoreUI:populate()
    for _, entry in pairs(self.packCards) do
        entry.card:Destroy()
    end
    self.packCards = {}

    for i, pack in ipairs(PackModule.getEnabledPacks()) do
        self:_makeCard(pack, i)
    end
end

-- Update the balance display in the header
function StoreUI:updateBalance(balance: number)
    self.balanceLabel.Text = "$" .. PackModule.formatNumber(balance)
end

-- Refresh open-button text for packs that have a cooldown
-- `cooldowns` = { [packId] = lastOpenTimestamp }
function StoreUI:updateCooldowns(cooldowns)
    local now = os.time()
    for packId, entry in pairs(self.packCards) do
        local pack = entry.pack
        if pack.cooldown > 0 then
            local last = cooldowns[packId]
            if last then
                local elapsed = now - last
                if elapsed < pack.cooldown then
                    local rem = pack.cooldown - elapsed
                    entry.openBtn.Text = string.format("READY IN  %02d:%02d:%02d",
                        math.floor(rem / 3600),
                        math.floor((rem % 3600) / 60),
                        rem % 60)
                    entry.openBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                else
                    -- Cooldown expired
                    entry.openBtn.Text = "FREE  —  OPEN"
                    local tier = PackModule.getPackTier(pack.tier)
                    entry.openBtn.BackgroundColor3 = tier.primaryColor
                end
            end
        end
    end
end

function StoreUI:show()
    self.screenGui.Enabled = true
    self.panel.Position = UDim2.fromScale(0.06, 0.00)
    TweenService:Create(self.panel, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.06, 0.07),
    }):Play()
end

function StoreUI:hide()
    self.screenGui.Enabled = false
end

return StoreUI
