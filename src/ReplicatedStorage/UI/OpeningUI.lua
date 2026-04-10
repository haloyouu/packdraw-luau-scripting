-- =============================================================================
-- OpeningUI  (ModuleScript — ReplicatedStorage/UI)
--
-- CS:GO-style scrolling reel (case opening / loot strip) animation.
--
-- Flow:
--   1. showOpening(pack)  – container pops in, reel area shows a "spinning" hint
--   2. revealItem(item)   – populates a 40-card strip, scrolls it with a
--                           Quint ease-out over ~5.5 s, stops winner at centre
--   3. Winner highlighted – glow border pulses, info labels appear
--   4. SELL / KEEP buttons appear – callbacks fire on click
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

-- Reel geometry (pixels)
local SLOT_W      = 142   -- width of each reel slot (card + gap)
local CARD_W      = 130   -- visible card width
local CARD_H      = 162   -- visible card height
local REEL_H      = 190   -- height of the clipping container
local TOTAL_CARDS = 42    -- total cards in the strip
local WINNER_IDX  = 34    -- 0-indexed position of the winner (leaves buffer at end)

-- Colours
local PANEL_BG = Color3.fromRGB(18,  18,  32)
local DARK_BG  = Color3.fromRGB( 8,   8,  18)
local TEXT_W   = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(160, 160, 200)
local GOLD     = Color3.fromRGB(255, 220,  50)

-- ---------------------------------------------------------------------------
local OpeningUI = {}
OpeningUI.__index = OpeningUI

function OpeningUI.new(playerGui)
    local self = setmetatable({}, OpeningUI)
    self.playerGui     = playerGui
    self.onSell        = nil
    self.onKeep        = nil
    self._currentItem  = nil
    self._currentPack  = nil
    self._glowTween    = nil
    self:_build()
    return self
end

-- ---------------------------------------------------------------------------
-- BUILD
-- ---------------------------------------------------------------------------
function OpeningUI:_build()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "PackOpeningGui"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 10   -- above BottomBarGui (0) so sell/keep buttons win input
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    -- Full-screen dim
    local dim = Instance.new("Frame")
    dim.Size                   = UDim2.fromScale(1, 1)
    dim.BackgroundColor3       = DARK_BG
    dim.BackgroundTransparency = 0.3
    dim.BorderSizePixel        = 0
    dim.Parent                 = sg

    -- Animated glow border (sits 6px outside the container)
    local glowBorder = Instance.new("Frame")
    glowBorder.Name             = "GlowBorder"
    glowBorder.AnchorPoint      = Vector2.new(0.5, 0.5)
    glowBorder.Size             = UDim2.fromOffset(852, 582)
    glowBorder.Position         = UDim2.fromScale(0.5, 0.5)
    glowBorder.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    glowBorder.BorderSizePixel  = 0
    glowBorder.ZIndex           = 1
    glowBorder.Parent           = sg
    Instance.new("UICorner", glowBorder).CornerRadius = UDim.new(0, 20)
    self.glowBorder = glowBorder

    -- Main container
    local container = Instance.new("Frame")
    container.Name             = "Container"
    container.AnchorPoint      = Vector2.new(0.5, 0.5)
    container.Size             = UDim2.fromOffset(840, 570)
    container.Position         = UDim2.fromScale(0.5, 0.5)
    container.BackgroundColor3 = PANEL_BG
    container.BorderSizePixel  = 0
    container.ZIndex           = 2
    container.Parent           = sg
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

    -- ── REEL AREA ─────────────────────────────────────────────────────────

    -- Clipping container
    local reelClip = Instance.new("Frame")
    reelClip.Name              = "ReelClip"
    reelClip.Size              = UDim2.new(1, 0, 0, REEL_H)
    reelClip.Position          = UDim2.new(0, 0, 0, 56)
    reelClip.BackgroundColor3  = Color3.fromRGB(10, 10, 20)
    reelClip.BorderSizePixel   = 0
    reelClip.ClipsDescendants  = true
    reelClip.ZIndex            = 3
    reelClip.Parent            = container
    self.reelClip = reelClip

    -- Scrolling strip (populated in revealItem)
    local strip = Instance.new("Frame")
    strip.Name            = "Strip"
    strip.Size            = UDim2.fromOffset(TOTAL_CARDS * SLOT_W, REEL_H)
    strip.Position        = UDim2.fromOffset(9999, 0)   -- hidden until reel starts
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel = 0
    strip.ZIndex          = 3
    strip.Parent          = reelClip
    self.strip = strip

    -- Centre pointer line
    local pointer = Instance.new("Frame")
    pointer.Name            = "Pointer"
    pointer.Size            = UDim2.new(0, 3, 1, 0)
    pointer.Position        = UDim2.new(0.5, -1, 0, 0)
    pointer.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    pointer.BorderSizePixel = 0
    pointer.ZIndex          = 10
    pointer.Parent          = reelClip

    -- Top tick
    local topTick = Instance.new("Frame")
    topTick.Size            = UDim2.fromOffset(14, 10)
    topTick.Position        = UDim2.new(0.5, -7, 0, 0)
    topTick.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    topTick.BorderSizePixel = 0
    topTick.ZIndex          = 10
    topTick.Parent          = reelClip

    -- Bottom tick
    local botTick = Instance.new("Frame")
    botTick.Size            = UDim2.fromOffset(14, 10)
    botTick.Position        = UDim2.new(0.5, -7, 1, -10)
    botTick.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    botTick.BorderSizePixel = 0
    botTick.ZIndex          = 10
    botTick.Parent          = reelClip

    -- Left gradient fade
    local leftFade = Instance.new("Frame")
    leftFade.Size            = UDim2.new(0.12, 0, 1, 0)
    leftFade.BackgroundColor3= Color3.fromRGB(10, 10, 20)
    leftFade.BackgroundTransparency = 0.1
    leftFade.BorderSizePixel = 0
    leftFade.ZIndex          = 8
    leftFade.Parent          = reelClip
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Rotation = 90
    leftGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    leftGrad.Parent = leftFade

    -- Right gradient fade
    local rightFade = Instance.new("Frame")
    rightFade.Size            = UDim2.new(0.12, 0, 1, 0)
    rightFade.Position        = UDim2.new(0.88, 0, 0, 0)
    rightFade.BackgroundColor3= Color3.fromRGB(10, 10, 20)
    rightFade.BackgroundTransparency = 0.1
    rightFade.BorderSizePixel = 0
    rightFade.ZIndex          = 8
    rightFade.Parent          = reelClip
    local rightGrad = Instance.new("UIGradient")
    rightGrad.Rotation = 270
    rightGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    rightGrad.Parent = rightFade

    -- ── POST-REEL INFO (hidden until winner lands) ─────────────────────────

    local rarityBadge = Instance.new("Frame")
    rarityBadge.AnchorPoint     = Vector2.new(0.5, 0)
    rarityBadge.Size            = UDim2.fromOffset(180, 30)
    rarityBadge.Position        = UDim2.new(0.5, 0, 0, 258)
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

    local itemName = Instance.new("TextLabel")
    itemName.Size                  = UDim2.new(1, -30, 0, 48)
    itemName.Position              = UDim2.new(0, 15, 0, 294)
    itemName.BackgroundTransparency= 1
    itemName.Text                  = ""
    itemName.TextColor3            = TEXT_W
    itemName.Font                  = Enum.Font.GothamBold
    itemName.TextSize              = 22
    itemName.TextWrapped           = true
    itemName.Visible               = false
    itemName.ZIndex                = 3
    itemName.Parent                = container
    self.itemName = itemName

    local sellLbl = Instance.new("TextLabel")
    sellLbl.Size                  = UDim2.new(1, -30, 0, 28)
    sellLbl.Position              = UDim2.new(0, 15, 0, 346)
    sellLbl.BackgroundTransparency= 1
    sellLbl.Text                  = ""
    sellLbl.TextColor3            = TEXT_DIM
    sellLbl.Font                  = Enum.Font.Gotham
    sellLbl.TextSize              = 15
    sellLbl.Visible               = false
    sellLbl.ZIndex                = 3
    sellLbl.Parent                = container
    self.sellLbl = sellLbl

    -- ── SELL / KEEP buttons ────────────────────────────────────────────────

    local function makeBtn(text, color, xPos, xSize)
        local btn = Instance.new("TextButton")
        btn.Size            = UDim2.new(xSize, -12, 0, 50)
        btn.Position        = UDim2.new(xPos, 6, 1, -66)
        btn.BackgroundColor3= color
        btn.Text            = text
        btn.TextColor3      = TEXT_W
        btn.Font            = Enum.Font.GothamBold
        btn.TextSize        = 16
        btn.BorderSizePixel = 0
        btn.Visible         = false
        btn.ZIndex          = 3
        btn.Parent          = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        return btn
    end

    local sellBtn = makeBtn("SELL", Color3.fromRGB(50, 200, 100), 0, 0.5)
    local keepBtn = makeBtn("KEEP", Color3.fromRGB(60, 80, 180),  0.5, 0.5)
    self.sellBtn  = sellBtn
    self.keepBtn  = keepBtn

    sellBtn.MouseEnter:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(70, 230, 120) }):Play()
    end)
    sellBtn.MouseLeave:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(50, 200, 100) }):Play()
    end)
    keepBtn.MouseEnter:Connect(function()
        TweenService:Create(keepBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(80, 110, 220) }):Play()
    end)
    keepBtn.MouseLeave:Connect(function()
        TweenService:Create(keepBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(60, 80, 180) }):Play()
    end)

    sellBtn.MouseButton1Click:Connect(function()
        if not self._currentItem then return end
        if self._glowTween then self._glowTween:Cancel() end
        local item = self._currentItem
        self:_close()
        if self.onSell then self.onSell(item) end
    end)
    keepBtn.MouseButton1Click:Connect(function()
        if not self._currentItem then return end
        if self._glowTween then self._glowTween:Cancel() end
        local item = self._currentItem
        self:_close()
        if self.onKeep then self.onKeep(item) end
    end)
end

-- ---------------------------------------------------------------------------
-- REEL HELPERS
-- ---------------------------------------------------------------------------

-- Build an array of 42 display items, winner forced at WINNER_IDX (0-indexed)
function OpeningUI:_buildReelItems(winnerItem)
    local rewards = self._currentPack.rewards
    local items   = {}
    for i = 1, TOTAL_CARDS do
        if i == WINNER_IDX + 1 then          -- convert to 1-indexed
            items[i] = winnerItem
        else
            local r = rewards[math.random(1, #rewards)]
            items[i] = { name = r.name, imageId = r.imageId,
                         sellValue = r.sellValue, rarity = r.rarity }
        end
    end
    return items
end

-- Create one card inside the strip
function OpeningUI:_makeReelCard(item, slotIndex)
    local rarityInfo = PackModule.getItemRarity(item.rarity)
    local xOff = slotIndex * SLOT_W + math.floor((SLOT_W - CARD_W) / 2)
    local yOff = math.floor((REEL_H - CARD_H) / 2)

    local card = Instance.new("Frame")
    card.Size            = UDim2.fromOffset(CARD_W, CARD_H)
    card.Position        = UDim2.fromOffset(xOff, yOff)
    card.BackgroundColor3= Color3.fromRGB(22, 22, 38)
    card.BorderSizePixel = 0
    card.ZIndex          = 4
    card.Parent          = self.strip
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    -- Rarity colour top bar
    local topBar = Instance.new("Frame")
    topBar.Size            = UDim2.new(1, 0, 0, 5)
    topBar.BackgroundColor3= rarityInfo.color
    topBar.BorderSizePixel = 0
    topBar.ZIndex          = 5
    topBar.Parent          = card
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
    -- cover bottom rounding of top bar
    local topBarFill = Instance.new("Frame")
    topBarFill.Size = UDim2.new(1, 0, 0.5, 0)
    topBarFill.Position = UDim2.new(0, 0, 0.5, 0)
    topBarFill.BackgroundColor3 = rarityInfo.color
    topBarFill.BorderSizePixel = 0
    topBarFill.ZIndex = 5
    topBarFill.Parent = topBar

    -- Coloured background tint matching rarity
    local tint = Instance.new("Frame")
    tint.Size                   = UDim2.fromScale(1, 1)
    tint.BackgroundColor3       = rarityInfo.color
    tint.BackgroundTransparency = 0.82
    tint.BorderSizePixel        = 0
    tint.ZIndex                 = 4
    tint.Parent                 = card
    Instance.new("UICorner", tint).CornerRadius = UDim.new(0, 8)

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Size                = UDim2.new(1, -12, 0, 96)
    img.Position            = UDim2.new(0, 6, 0, 12)
    img.BackgroundTransparency = 1
    img.Image               = item.imageId
    img.ScaleType           = Enum.ScaleType.Fit
    img.ZIndex              = 5
    img.Parent              = card

    -- Item name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -8, 0, 46)
    nameLbl.Position              = UDim2.new(0, 4, 0, 112)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = item.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 11
    nameLbl.TextWrapped           = true
    nameLbl.TextYAlignment        = Enum.TextYAlignment.Top
    nameLbl.ZIndex                = 5
    nameLbl.Parent                = card

    -- Value label
    local valLbl = Instance.new("TextLabel")
    valLbl.Size                  = UDim2.new(1, -8, 0, 18)
    valLbl.Position              = UDim2.new(0, 4, 1, -20)
    valLbl.BackgroundTransparency= 1
    valLbl.Text                  = "$" .. PackModule.formatNumber(item.sellValue)
    valLbl.TextColor3            = GOLD
    valLbl.Font                  = Enum.Font.GothamBold
    valLbl.TextSize              = 11
    valLbl.ZIndex                = 5
    valLbl.Parent                = card

    return card
end

-- Called after the reel tween completes
function OpeningUI:_onReelStop(item, winnerCard)
    local rarityInfo = PackModule.getItemRarity(item.rarity)

    -- Glow outline on the winner card using UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color     = rarityInfo.color
    stroke.Thickness = 3
    stroke.Parent    = winnerCard

    -- Pulse the stroke thickness
    self._glowTween = TweenService:Create(stroke,
        TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Thickness = 7 })
    self._glowTween:Play()

    -- Update glow border colour
    TweenService:Create(self.glowBorder, TweenInfo.new(0.4), {
        BackgroundColor3 = rarityInfo.color
    }):Play()

    -- Reveal info
    self.header.Text = "You got..."

    self.rarityBadge.BackgroundColor3 = rarityInfo.color
    self.rarityLbl.Text               = rarityInfo.displayName:upper()
    self.rarityBadge.Visible          = true

    self.itemName.Text    = item.name
    self.itemName.Visible = true

    self.sellLbl.Text    = "Sell value:  $" .. PackModule.formatNumber(item.sellValue)
    self.sellLbl.Visible = true

    self.sellBtn.Text = "SELL  $" .. PackModule.formatNumber(item.sellValue)

    task.delay(0.25, function()
        self.sellBtn.Visible = true
        self.keepBtn.Visible = true
    end)
end

-- ---------------------------------------------------------------------------
-- PUBLIC API
-- ---------------------------------------------------------------------------

-- Step 1 – show the container, clear any previous reel state
function OpeningUI:showOpening(pack)
    self._currentPack  = pack
    self._currentItem  = nil

    -- Reset info elements
    self.rarityBadge.Visible = false
    self.itemName.Visible    = false
    self.sellLbl.Visible     = false
    self.sellBtn.Visible     = false
    self.keepBtn.Visible     = false
    self.header.Text         = "Opening " .. pack.name .. "..."
    self.strip.Position      = UDim2.fromOffset(9999, 0)

    -- Reset glow border colour to pack tier colour
    local tier = PackModule.getPackTier(pack.tier)
    self.glowBorder.BackgroundColor3 = tier.glowColor

    -- Pop-in animation
    self.screenGui.Enabled = true
    self.container.Size    = UDim2.fromOffset(4, 4)
    self.glowBorder.Size   = UDim2.fromOffset(8, 8)
    TweenService:Create(self.container,
        TweenInfo.new(0.4, Enum.EasingStyle.Back),
        { Size = UDim2.fromOffset(840, 570) }):Play()
    TweenService:Create(self.glowBorder,
        TweenInfo.new(0.4, Enum.EasingStyle.Back),
        { Size = UDim2.fromOffset(852, 582) }):Play()
end

-- Step 2 – populate the reel and spin it; winner lands under the pointer
function OpeningUI:revealItem(item)
    self._currentItem = item

    -- Clear previous strip content
    for _, child in ipairs(self.strip:GetChildren()) do child:Destroy() end

    -- Build and populate reel cards
    local reelItems = self:_buildReelItems(item)
    local winnerCard = nil
    for i, reelItem in ipairs(reelItems) do
        local card = self:_makeReelCard(reelItem, i - 1)   -- 0-indexed slot
        if i == WINNER_IDX + 1 then
            winnerCard = card
        end
    end

    -- Set strip size and move it off-screen while sizes are computed
    self.strip.Size     = UDim2.fromOffset(TOTAL_CARDS * SLOT_W, REEL_H)
    self.strip.Position = UDim2.fromOffset(9999, 0)

    -- Wait one frame so AbsoluteSize is valid
    task.wait()

    local containerW = self.reelClip.AbsoluteSize.X
    if containerW < 10 then containerW = 840 end  -- Studio fallback

    -- Start: strip just off the right edge of the clip
    local startX = containerW + 10
    self.strip.Position = UDim2.fromOffset(startX, 0)

    -- End: winner card's centre aligns with the container's centre
    local winnerCentreInStrip = WINNER_IDX * SLOT_W + SLOT_W / 2
    local endX = math.floor(containerW / 2 - winnerCentreInStrip)

    -- Spin tween — Quint ease-out gives that authentic deceleration feel
    local tween = TweenService:Create(
        self.strip,
        TweenInfo.new(5.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = UDim2.fromOffset(endX, 0) }
    )
    tween.Completed:Connect(function()
        if winnerCard and winnerCard.Parent then
            self:_onReelStop(item, winnerCard)
        end
    end)
    tween:Play()
end

-- Show an error message, then auto-dismiss and fire onKeep (returns to store)
function OpeningUI:showError(msg)
    self.header.Text = msg
    task.delay(2.5, function()
        self:_close()
        if self.onKeep then self.onKeep(nil) end
    end)
end

function OpeningUI:_close()
    if self._glowTween then self._glowTween:Cancel(); self._glowTween = nil end
    local t1 = TweenService:Create(self.container,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(4, 4) })
    local t2 = TweenService:Create(self.glowBorder,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(8, 8) })
    t1.Completed:Connect(function() self.screenGui.Enabled = false end)
    t1:Play(); t2:Play()
end

return OpeningUI
