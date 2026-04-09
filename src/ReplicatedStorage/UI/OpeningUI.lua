-- =============================================================================
-- OpeningUI  (ModuleScript — ReplicatedStorage/UI)
--
-- Manages the pack-opening animation and reward-reveal screen.
-- Flow:
--   1.  showOpening(pack)   – displays the pack image + "opening…" header
--   2.  revealReward(reward)– flips the card to show the reward + rarity badge
--   3.  Player clicks COLLECT → onClose callback fires
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local DARK_BG  = Color3.fromRGB(10,  10,  20)
local PANEL_BG = Color3.fromRGB(20,  20,  36)
local TEXT_W   = Color3.fromRGB(255, 255, 255)
local GOLD     = Color3.fromRGB(255, 220,  50)

local IMG_SIZE = 220  -- width & height of the reward image in pixels

-- ---------------------------------------------------------------------------
local OpeningUI = {}
OpeningUI.__index = OpeningUI

function OpeningUI.new(playerGui)
    local self = setmetatable({}, OpeningUI)
    self.playerGui = playerGui
    self.onClose   = nil   -- callback fired after the player collects
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

    -- Full-screen dim overlay
    local dim = Instance.new("Frame")
    dim.Size                   = UDim2.fromScale(1, 1)
    dim.BackgroundColor3       = DARK_BG
    dim.BackgroundTransparency = 0.35
    dim.BorderSizePixel        = 0
    dim.Parent                 = sg

    -- Glow border (sits behind the container, same size + 4 px bleed)
    local glowBorder = Instance.new("Frame")
    glowBorder.Name            = "GlowBorder"
    glowBorder.AnchorPoint     = Vector2.new(0.5, 0.5)
    glowBorder.Size            = UDim2.fromOffset(432, 532)
    glowBorder.Position        = UDim2.fromScale(0.5, 0.5)
    glowBorder.BackgroundColor3= Color3.fromRGB(100, 100, 255)
    glowBorder.BorderSizePixel = 0
    glowBorder.ZIndex          = 1
    glowBorder.Parent          = sg
    Instance.new("UICorner", glowBorder).CornerRadius = UDim.new(0, 18)
    self.glowBorder = glowBorder

    -- Main container
    local container = Instance.new("Frame")
    container.Name            = "Container"
    container.AnchorPoint     = Vector2.new(0.5, 0.5)
    container.Size            = UDim2.fromOffset(420, 520)
    container.Position        = UDim2.fromScale(0.5, 0.5)
    container.BackgroundColor3= PANEL_BG
    container.BorderSizePixel = 0
    container.ZIndex          = 2
    container.Parent          = sg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    self.container = container

    -- Header text
    local header = Instance.new("TextLabel")
    header.Size                  = UDim2.new(1, -20, 0, 50)
    header.Position              = UDim2.new(0, 10, 0, 4)
    header.BackgroundTransparency= 1
    header.Text                  = "Opening Pack..."
    header.TextColor3            = TEXT_W
    header.Font                  = Enum.Font.GothamBold
    header.TextSize              = 22
    header.ZIndex                = 3
    header.Parent                = container
    self.header = header

    -- Pack / reward image (card face)
    local img = Instance.new("ImageLabel")
    img.Name            = "RewardImage"
    img.AnchorPoint     = Vector2.new(0.5, 0)
    img.Size            = UDim2.fromOffset(IMG_SIZE, IMG_SIZE)
    img.Position        = UDim2.new(0.5, 0, 0, 58)
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
    rarityBadge.Size            = UDim2.fromOffset(170, 30)
    rarityBadge.Position        = UDim2.new(0.5, 0, 0, 288)
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
    rarityLbl.TextSize              = 14
    rarityLbl.TextColor3            = TEXT_W
    rarityLbl.ZIndex                = 4
    rarityLbl.Parent                = rarityBadge
    self.rarityLbl = rarityLbl

    -- Reward name
    local rewardName = Instance.new("TextLabel")
    rewardName.Size                  = UDim2.new(1, -30, 0, 40)
    rewardName.Position              = UDim2.new(0, 15, 0, 328)
    rewardName.BackgroundTransparency= 1
    rewardName.Text                  = ""
    rewardName.TextColor3            = TEXT_W
    rewardName.Font                  = Enum.Font.GothamBold
    rewardName.TextSize              = 20
    rewardName.TextWrapped           = true
    rewardName.Visible               = false
    rewardName.ZIndex                = 3
    rewardName.Parent                = container
    self.rewardName = rewardName

    -- Money amount
    local moneyLbl = Instance.new("TextLabel")
    moneyLbl.Size                  = UDim2.new(1, -30, 0, 36)
    moneyLbl.Position              = UDim2.new(0, 15, 0, 372)
    moneyLbl.BackgroundTransparency= 1
    moneyLbl.Text                  = ""
    moneyLbl.TextColor3            = GOLD
    moneyLbl.Font                  = Enum.Font.GothamBold
    moneyLbl.TextSize              = 26
    moneyLbl.Visible               = false
    moneyLbl.ZIndex                = 3
    moneyLbl.Parent                = container
    self.moneyLbl = moneyLbl

    -- Collect button
    local collectBtn = Instance.new("TextButton")
    collectBtn.Size            = UDim2.new(1, -40, 0, 48)
    collectBtn.Position        = UDim2.new(0, 20, 1, -64)
    collectBtn.BackgroundColor3= Color3.fromRGB(50, 200, 100)
    collectBtn.Text            = "COLLECT"
    collectBtn.TextColor3      = TEXT_W
    collectBtn.Font            = Enum.Font.GothamBold
    collectBtn.TextSize        = 18
    collectBtn.BorderSizePixel = 0
    collectBtn.Visible         = false
    collectBtn.ZIndex          = 3
    collectBtn.Parent          = container
    Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 10)
    self.collectBtn = collectBtn

    collectBtn.MouseEnter:Connect(function()
        TweenService:Create(collectBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(70, 230, 120)
        }):Play()
    end)
    collectBtn.MouseLeave:Connect(function()
        TweenService:Create(collectBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        }):Play()
    end)
    collectBtn.MouseButton1Click:Connect(function()
        self:_close()
    end)
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Step 1: Show the pack card (called before the server responds)
function OpeningUI:showOpening(pack)
    local tier = PackModule.getPackTier(pack.tier)

    -- Reset all reward elements
    self.rarityBadge.Visible = false
    self.rewardName.Visible  = false
    self.moneyLbl.Visible    = false
    self.collectBtn.Visible  = false
    self.header.Text         = "Opening " .. pack.name .. "..."
    self.img.Image           = pack.imageId
    self.img.BackgroundColor3= Color3.fromRGB(38, 38, 60)
    self.glowBorder.BackgroundColor3 = tier.glowColor

    -- Pop-in animation
    self.screenGui.Enabled = true
    self.container.Size    = UDim2.fromOffset(4, 4)
    self.glowBorder.Size   = UDim2.fromOffset(8, 8)
    TweenService:Create(self.container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(420, 520)
    }):Play()
    TweenService:Create(self.glowBorder, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(432, 532)
    }):Play()
end

-- Step 2: Animate the card flip and display the reward
function OpeningUI:revealReward(reward)
    local rarityInfo = PackModule.getItemRarity(reward.rarity)

    -- Flip: shrink to nothing on X axis
    local shrink = TweenService:Create(self.img, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, IMG_SIZE)
    })
    shrink.Completed:Connect(function()
        -- Swap to reward image at zero width (invisible)
        self.img.Image            = reward.imageId
        self.img.BackgroundColor3 = rarityInfo.color

        -- Expand back
        TweenService:Create(self.img, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
            Size = UDim2.fromOffset(IMG_SIZE, IMG_SIZE)
        }):Play()

        -- Update glow to rarity colour
        TweenService:Create(self.glowBorder, TweenInfo.new(0.3), {
            BackgroundColor3 = rarityInfo.color
        }):Play()

        -- Reveal info labels after the flip settles
        task.delay(0.35, function()
            self.header.Text = "You got..."

            self.rarityBadge.BackgroundColor3 = rarityInfo.color
            self.rarityLbl.Text               = rarityInfo.displayName:upper()
            self.rarityBadge.Visible          = true

            self.rewardName.Text    = reward.name
            self.rewardName.Visible = true

            self.moneyLbl.Text    = "+ " .. PackModule.formatNumber(reward.moneyAmount) .. " Coins"
            self.moneyLbl.Visible = true

            task.delay(0.25, function()
                self.collectBtn.Visible = true
            end)
        end)
    end)
    shrink:Play()
end

-- Show an error message then auto-dismiss
function OpeningUI:showError(msg: string)
    self.header.Text = msg
    task.delay(2.5, function()
        self:_close()
    end)
end

-- ---------------------------------------------------------------------------
-- Internal: shrink-out animation then fire onClose
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
        if self.onClose then self.onClose() end
    end)
    t1:Play()
    t2:Play()
end

return OpeningUI
