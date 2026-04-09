-- =============================================================================
-- OpeningUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Pack-opening animation and item reveal.
-- Flow:
--   1. showOpening(pack)   – shows the pack image + "Opening…" header
--   2. revealItem(item)    – card-flip reveals the item + SELL / KEEP buttons
--   3. Player clicks SELL  → onSell(item) callback fires
--      Player clicks KEEP  → onKeep(item) callback fires
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local DARK_BG  = Color3.fromRGB(10,  10,  20)
local PANEL_BG = Color3.fromRGB(20,  20,  36)
local TEXT_W   = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(160, 160, 200)
local GOLD     = Color3.fromRGB(255, 220,  50)

local IMG_SIZE = 200

-- ---------------------------------------------------------------------------
local OpeningUI = {}
OpeningUI.__index = OpeningUI

function OpeningUI.new(playerGui)
    local self  = setmetatable({}, OpeningUI)
    self.playerGui   = playerGui
    self.onSell      = nil  -- callback(item)
    self.onKeep      = nil  -- callback(item)
    self._currentItem = nil
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
function OpeningUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "PackOpeningGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    -- Dim overlay
    local dim = Instance.new("Frame")
    dim.Size                   = UDim2.fromScale(1, 1)
    dim.BackgroundColor3       = DARK_BG
    dim.BackgroundTransparency = 0.35
    dim.BorderSizePixel        = 0
    dim.Parent                 = sg

    -- Glow border
    local glowBorder = Instance.new("Frame")
    glowBorder.Name            = "GlowBorder"
    glowBorder.AnchorPoint     = Vector2.new(0.5, 0.5)
    glowBorder.Size            = UDim2.fromOffset(444, 564)
    glowBorder.Position        = UDim2.fromScale(0.5, 0.5)
    glowBorder.BackgroundColor3= Color3.fromRGB(100, 100, 255)
    glowBorder.BorderSizePixel = 0
    glowBorder.ZIndex          = 1
    glowBorder.Parent          = sg
    Instance.new("UICorner", glowBorder).CornerRadius = UDim.new(0, 20)
    self.glowBorder = glowBorder

    -- Main container
    local container = Instance.new("Frame")
    container.Name            = "Container"
    container.AnchorPoint     = Vector2.new(0.5, 0.5)
    container.Size            = UDim2.fromOffset(432, 552)
    container.Position        = UDim2.fromScale(0.5, 0.5)
    container.BackgroundColor3= PANEL_BG
    container.BorderSizePixel = 0
    container.ZIndex          = 2
    container.Parent          = sg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    self.container = container

    -- Header
    local header = Instance.new("TextLabel")
    header.Size                  = UDim2.new(1, -20, 0, 48)
    header.Position              = UDim2.new(0, 10, 0, 4)
    header.BackgroundTransparency= 1
    header.Text                  = "Opening Pack..."
    header.TextColor3            = TEXT_W
    header.Font                  = Enum.Font.GothamBold
    header.TextSize              = 22
    header.ZIndex                = 3
    header.Parent                = container
    self.header = header

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Name            = "ItemImage"
    img.AnchorPoint     = Vector2.new(0.5, 0)
    img.Size            = UDim2.fromOffset(IMG_SIZE, IMG_SIZE)
    img.Position        = UDim2.new(0.5, 0, 0, 56)
    img.BackgroundColor3= Color3.fromRGB(38, 38, 60)
    img.BorderSizePixel = 0
    img.ScaleType       = Enum.ScaleType.Fit
    img.ZIndex          = 3
    img.Parent          = container
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 12)
    self.img = img

    -- Rarity badge
    local rarityBadge = Instance.new("Frame")
    rarityBadge.AnchorPoint     = Vector2.new(0.5, 0)
    rarityBadge.Size            = UDim2.fromOffset(170, 28)
    rarityBadge.Position        = UDim2.new(0.5, 0, 0, 264)
    rarityBadge.BackgroundColor3= Color3.fromRGB(100, 100, 100)
    rarityBadge.BorderSizePixel = 0
    rarityBadge.Visible         = false
    rarityBadge.ZIndex          = 3
    rarityBadge.Parent          = container
    Instance.new("UICorner", rarityBadge).CornerRadius = UDim.new(0, 8)
    self.rarityBadge = rarityBadge

    local rarityLbl = Instance.new("TextLabel")
    rarityLbl.Size                  = UDim2.fromScale(1, 1)
    rarityLbl.BackgroundTransparency= 1
    rarityLbl.Font                  = Enum.Font.GothamBold
    rarityLbl.TextSize              = 13
    rarityLbl.TextColor3            = TEXT_W
    rarityLbl.ZIndex                = 4
    rarityLbl.Parent                = rarityBadge
    self.rarityLbl = rarityLbl

    -- Item name
    local itemName = Instance.new("TextLabel")
    itemName.Size                  = UDim2.new(1, -30, 0, 40)
    itemName.Position              = UDim2.new(0, 15, 0, 300)
    itemName.BackgroundTransparency= 1
    itemName.Text                  = ""
    itemName.TextColor3            = TEXT_W
    itemName.Font                  = Enum.Font.GothamBold
    itemName.TextSize              = 20
    itemName.TextWrapped           = true
    itemName.Visible               = false
    itemName.ZIndex                = 3
    itemName.Parent                = container
    self.itemName = itemName

    -- Sell value label
    local sellLbl = Instance.new("TextLabel")
    sellLbl.Size                  = UDim2.new(1, -30, 0, 28)
    sellLbl.Position              = UDim2.new(0, 15, 0, 342)
    sellLbl.BackgroundTransparency= 1
    sellLbl.Text                  = ""
    sellLbl.TextColor3            = TEXT_DIM
    sellLbl.Font                  = Enum.Font.Gotham
    sellLbl.TextSize              = 14
    sellLbl.Visible               = false
    sellLbl.ZIndex                = 3
    sellLbl.Parent                = container
    self.sellLbl = sellLbl

    -- ---- SELL button -------------------------------------------------------
    local sellBtn = Instance.new("TextButton")
    sellBtn.Size            = UDim2.new(0.5, -25, 0, 48)
    sellBtn.Position        = UDim2.new(0, 15, 1, -62)
    sellBtn.BackgroundColor3= Color3.fromRGB(50, 200, 100)
    sellBtn.BorderSizePixel = 0
    sellBtn.Font            = Enum.Font.GothamBold
    sellBtn.TextSize        = 15
    sellBtn.TextColor3      = TEXT_W
    sellBtn.Text            = "SELL"
    sellBtn.Visible         = false
    sellBtn.ZIndex          = 3
    sellBtn.Parent          = container
    Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 10)
    self.sellBtn = sellBtn

    sellBtn.MouseEnter:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(70, 230, 120)
        }):Play()
    end)
    sellBtn.MouseLeave:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        }):Play()
    end)
    sellBtn.MouseButton1Click:Connect(function()
        if self._currentItem and self.onSell then
            self.onSell(self._currentItem)
        end
        self:_close()
    end)

    -- ---- KEEP button -------------------------------------------------------
    local keepBtn = Instance.new("TextButton")
    keepBtn.Size            = UDim2.new(0.5, -25, 0, 48)
    keepBtn.Position        = UDim2.new(0.5, 10, 1, -62)
    keepBtn.BackgroundColor3= Color3.fromRGB(60, 80, 180)
    keepBtn.BorderSizePixel = 0
    keepBtn.Font            = Enum.Font.GothamBold
    keepBtn.TextSize        = 15
    keepBtn.TextColor3      = TEXT_W
    keepBtn.Text            = "KEEP"
    keepBtn.Visible         = false
    keepBtn.ZIndex          = 3
    keepBtn.Parent          = container
    Instance.new("UICorner", keepBtn).CornerRadius = UDim.new(0, 10)
    self.keepBtn = keepBtn

    keepBtn.MouseEnter:Connect(function()
        TweenService:Create(keepBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(80, 110, 220)
        }):Play()
    end)
    keepBtn.MouseLeave:Connect(function()
        TweenService:Create(keepBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(60, 80, 180)
        }):Play()
    end)
    keepBtn.MouseButton1Click:Connect(function()
        if self._currentItem and self.onKeep then
            self.onKeep(self._currentItem)
        end
        self:_close()
    end)
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Step 1: Show the pack card while waiting for the server to respond
function OpeningUI:showOpening(pack)
    local tier = PackModule.getPackTier(pack.tier)

    self._currentItem       = nil
    self.rarityBadge.Visible= false
    self.itemName.Visible   = false
    self.sellLbl.Visible    = false
    self.sellBtn.Visible    = false
    self.keepBtn.Visible    = false
    self.header.Text        = "Opening " .. pack.name .. "..."
    self.img.Image          = pack.imageId
    self.img.BackgroundColor3 = Color3.fromRGB(38, 38, 60)
    self.glowBorder.BackgroundColor3 = tier.glowColor

    self.screenGui.Enabled = true
    self.container.Size    = UDim2.fromOffset(4, 4)
    self.glowBorder.Size   = UDim2.fromOffset(8, 8)
    TweenService:Create(self.container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(432, 552)
    }):Play()
    TweenService:Create(self.glowBorder, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(444, 564)
    }):Play()
end

-- Step 2: Flip animation then show item details and SELL / KEEP buttons
-- `item` = { id, name, imageId, sellValue, rarity }
function OpeningUI:revealItem(item)
    self._currentItem = item
    local rarityInfo  = PackModule.getItemRarity(item.rarity)

    -- Flip: shrink on X axis
    local shrink = TweenService:Create(
        self.img,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(0, IMG_SIZE) }
    )
    shrink.Completed:Connect(function()
        self.img.Image             = item.imageId
        self.img.BackgroundColor3  = rarityInfo.color

        TweenService:Create(self.img, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
            Size = UDim2.fromOffset(IMG_SIZE, IMG_SIZE)
        }):Play()

        TweenService:Create(self.glowBorder, TweenInfo.new(0.3), {
            BackgroundColor3 = rarityInfo.color
        }):Play()

        task.delay(0.35, function()
            self.header.Text = "You got..."

            self.rarityBadge.BackgroundColor3 = rarityInfo.color
            self.rarityLbl.Text               = rarityInfo.displayName:upper()
            self.rarityBadge.Visible          = true

            self.itemName.Text    = item.name
            self.itemName.Visible = true

            self.sellLbl.Text    = "Sell value: $" .. PackModule.formatNumber(item.sellValue)
            self.sellLbl.Visible = true

            -- Update SELL button text with the value
            self.sellBtn.Text = "SELL  $" .. PackModule.formatNumber(item.sellValue)

            task.delay(0.2, function()
                self.sellBtn.Visible = true
                self.keepBtn.Visible = true
            end)
        end)
    end)
    shrink:Play()
end

-- Show an error message and auto-dismiss
function OpeningUI:showError(msg: string)
    self.header.Text = msg
    task.delay(2.5, function()
        self:_close()
    end)
end

-- ---------------------------------------------------------------------------
function OpeningUI:_close()
    local t1 = TweenService:Create(self.container,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(4, 4) })
    local t2 = TweenService:Create(self.glowBorder,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(8, 8) })
    t1.Completed:Connect(function()
        self.screenGui.Enabled = false
    end)
    t1:Play()
    t2:Play()
end

return OpeningUI
