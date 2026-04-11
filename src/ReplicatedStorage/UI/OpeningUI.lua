-- =============================================================================
-- OpeningUI  (ModuleScript — ReplicatedStorage/UI)
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local SLOT_W      = 142
local CARD_W      = 130
local CARD_H      = 162
local REEL_H      = 190
local TOTAL_CARDS = 42
local WINNER_IDX  = 34

local PANEL_BG = Color3.fromRGB(18, 18, 32)
local DARK_BG  = Color3.fromRGB( 8,  8, 18)
local TEXT_W   = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(160, 160, 200)
local GOLD     = Color3.fromRGB(255, 220,  50)

-- ---------------------------------------------------------------------------
-- Rarity commentary pools
-- ---------------------------------------------------------------------------
local COMMENTARY = {
    Common    = { "Not bad...", "A start!", "Keep trying.", "Could be worse!", "Better luck next time.", "Ehh, it's something." },
    Uncommon  = { "Nice one!", "That's decent!", "Getting warmer!", "Solid pick.", "Not too shabby!", "I'll take it!" },
    Rare      = { "Ooh nice!", "Now we're talking!", "That's rare!", "Fire!", "Clean pull!", "Let's go!", "Respect." },
    Epic      = { "EPIC!", "You crazy?!", "Wild pull!", "THIS IS IT!", "LET'S GO!", "No way...", "CHAT!", "That's dirty." },
    Legendary = { "LEGENDARY!!!", "INSANE!", "Are you kidding?!", "GOATED!", "ABSOLUTELY MENTAL!", "CHAT IS LOSING IT!", "This cannot be real!", "W PULL!!!!", "BRO.", "THE RAREST!!!!" },
}

-- Per-rarity hit effect settings
local HIT_FX = {
    Common    = { shakes = 0, flashes = 1, flashAlpha = 0.10, bounceSize = 1.06, sparks = 0,  commentSize = 20, commentDuration = 1.6 },
    Uncommon  = { shakes = 0, flashes = 1, flashAlpha = 0.16, bounceSize = 1.09, sparks = 0,  commentSize = 24, commentDuration = 1.8 },
    Rare      = { shakes = 3, flashes = 1, flashAlpha = 0.24, bounceSize = 1.13, sparks = 6,  commentSize = 30, commentDuration = 2.0 },
    Epic      = { shakes = 5, flashes = 2, flashAlpha = 0.36, bounceSize = 1.20, sparks = 14, commentSize = 38, commentDuration = 2.4 },
    Legendary = { shakes = 8, flashes = 3, flashAlpha = 0.50, bounceSize = 1.30, sparks = 24, commentSize = 48, commentDuration = 3.2 },
}

-- ---------------------------------------------------------------------------
local OpeningUI = {}
OpeningUI.__index = OpeningUI

function OpeningUI.new(playerGui)
    local self = setmetatable({}, OpeningUI)
    self.playerGui    = playerGui
    self.onSell       = nil
    self.onKeep       = nil
    self._currentItem = nil
    self._currentPack = nil
    self._glowTween   = nil
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
    sg.DisplayOrder   = 10
    sg.Enabled        = false
    sg.Parent         = self.playerGui
    self.screenGui    = sg

    -- ── Animated dim background ────────────────────────────────────────────
    local dim = Instance.new("Frame")
    dim.Size                   = UDim2.fromScale(1, 1)
    dim.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    dim.BackgroundTransparency = 0.15
    dim.BorderSizePixel        = 0
    dim.Parent                 = sg

    local dimGrad = Instance.new("UIGradient")
    dimGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 10, 45)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB( 8,  8, 22)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 20, 50)),
    })
    dimGrad.Rotation = 45
    dimGrad.Parent   = dim

    -- Slowly rotate background gradient for subtle motion
    task.spawn(function()
        local r = 45
        while sg.Parent do
            task.wait(0.05)
            r = (r + 0.15) % 360
            dimGrad.Rotation = r
        end
    end)

    -- ── Glow border ────────────────────────────────────────────────────────
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

    -- ── Main container ─────────────────────────────────────────────────────
    local container = Instance.new("Frame")
    container.Name             = "Container"
    container.AnchorPoint      = Vector2.new(0.5, 0.5)
    container.Size             = UDim2.fromOffset(840, 570)
    container.Position         = UDim2.fromScale(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BorderSizePixel  = 0
    container.ZIndex           = 2
    container.Parent           = sg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    self.container = container

    local containerGrad = Instance.new("UIGradient")
    containerGrad.Rotation = 90
    containerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 30, 54)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 32)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 10, 20)),
    })
    containerGrad.Parent = container

    -- ── Header ─────────────────────────────────────────────────────────────
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

    -- ── Reel clip ──────────────────────────────────────────────────────────
    local reelClip = Instance.new("Frame")
    reelClip.Name             = "ReelClip"
    reelClip.Size             = UDim2.new(1, 0, 0, REEL_H)
    reelClip.Position         = UDim2.new(0, 0, 0, 56)
    reelClip.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    reelClip.BorderSizePixel  = 0
    reelClip.ClipsDescendants = true
    reelClip.ZIndex           = 3
    reelClip.Parent           = container
    self.reelClip = reelClip

    -- Top vignette on reel
    local reelTopFade = Instance.new("Frame")
    reelTopFade.Size                   = UDim2.new(1, 0, 0, 30)
    reelTopFade.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
    reelTopFade.BackgroundTransparency = 0
    reelTopFade.BorderSizePixel        = 0
    reelTopFade.ZIndex                 = 7
    reelTopFade.Parent                 = reelClip
    local topFadeGrad = Instance.new("UIGradient")
    topFadeGrad.Rotation = 90
    topFadeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    topFadeGrad.Parent = reelTopFade

    -- Bottom vignette on reel
    local reelBotFade = Instance.new("Frame")
    reelBotFade.Size                   = UDim2.new(1, 0, 0, 30)
    reelBotFade.Position               = UDim2.new(0, 0, 1, -30)
    reelBotFade.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
    reelBotFade.BackgroundTransparency = 0
    reelBotFade.BorderSizePixel        = 0
    reelBotFade.ZIndex                 = 7
    reelBotFade.Parent                 = reelClip
    local botFadeGrad = Instance.new("UIGradient")
    botFadeGrad.Rotation = 270
    botFadeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    botFadeGrad.Parent = reelBotFade

    -- Strip
    local strip = Instance.new("Frame")
    strip.Name                = "Strip"
    strip.Size                = UDim2.fromOffset(TOTAL_CARDS * SLOT_W, REEL_H)
    strip.Position            = UDim2.fromOffset(9999, 0)
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel     = 0
    strip.ZIndex              = 3
    strip.Parent              = reelClip
    self.strip = strip

    -- Centre pointer
    local pointer = Instance.new("Frame")
    pointer.Size            = UDim2.new(0, 3, 1, 0)
    pointer.Position        = UDim2.new(0.5, -1, 0, 0)
    pointer.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    pointer.BorderSizePixel = 0
    pointer.ZIndex          = 10
    pointer.Parent          = reelClip

    local topTick = Instance.new("Frame")
    topTick.Size            = UDim2.fromOffset(14, 10)
    topTick.Position        = UDim2.new(0.5, -7, 0, 0)
    topTick.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    topTick.BorderSizePixel = 0
    topTick.ZIndex          = 10
    topTick.Parent          = reelClip

    local botTick = Instance.new("Frame")
    botTick.Size            = UDim2.fromOffset(14, 10)
    botTick.Position        = UDim2.new(0.5, -7, 1, -10)
    botTick.BackgroundColor3= Color3.fromRGB(255, 255, 255)
    botTick.BorderSizePixel = 0
    botTick.ZIndex          = 10
    botTick.Parent          = reelClip

    -- Left edge fade
    local leftFade = Instance.new("Frame")
    leftFade.Size                   = UDim2.new(0.12, 0, 1, 0)
    leftFade.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
    leftFade.BackgroundTransparency = 0.1
    leftFade.BorderSizePixel        = 0
    leftFade.ZIndex                 = 8
    leftFade.Parent                 = reelClip
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Rotation    = 90
    leftGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    leftGrad.Parent = leftFade

    -- Right edge fade
    local rightFade = Instance.new("Frame")
    rightFade.Size                   = UDim2.new(0.12, 0, 1, 0)
    rightFade.Position               = UDim2.new(0.88, 0, 0, 0)
    rightFade.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
    rightFade.BackgroundTransparency = 0.1
    rightFade.BorderSizePixel        = 0
    rightFade.ZIndex                 = 8
    rightFade.Parent                 = reelClip
    local rightGrad = Instance.new("UIGradient")
    rightGrad.Rotation    = 270
    rightGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    rightGrad.Parent = rightFade

    -- ── Flash overlay (full container, used for hit effects) ───────────────
    local flashOverlay = Instance.new("Frame")
    flashOverlay.Size                   = UDim2.fromScale(1, 1)
    flashOverlay.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    flashOverlay.BackgroundTransparency = 1
    flashOverlay.BorderSizePixel        = 0
    flashOverlay.ZIndex                 = 9
    flashOverlay.Parent                 = container
    Instance.new("UICorner", flashOverlay).CornerRadius = UDim.new(0, 16)
    self.flashOverlay = flashOverlay

    -- ── Post-reel info ─────────────────────────────────────────────────────
    local rarityBadge = Instance.new("Frame")
    rarityBadge.AnchorPoint      = Vector2.new(0.5, 0)
    rarityBadge.Size             = UDim2.fromOffset(180, 30)
    rarityBadge.Position         = UDim2.new(0.5, 0, 0, 258)
    rarityBadge.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    rarityBadge.BorderSizePixel  = 0
    rarityBadge.Visible          = false
    rarityBadge.ZIndex           = 3
    rarityBadge.Parent           = container
    Instance.new("UICorner", rarityBadge).CornerRadius = UDim.new(0, 8)
    self.rarityBadge = rarityBadge

    -- Subtle gradient on badge (top lighter)
    local badgeGrad = Instance.new("UIGradient")
    badgeGrad.Rotation    = 90
    badgeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.5),
    })
    badgeGrad.Parent = rarityBadge

    local rarityLbl = Instance.new("TextLabel")
    rarityLbl.Size                   = UDim2.fromScale(1, 1)
    rarityLbl.BackgroundTransparency = 1
    rarityLbl.Font                   = Enum.Font.GothamBold
    rarityLbl.TextSize               = 14
    rarityLbl.TextColor3             = TEXT_W
    rarityLbl.ZIndex                 = 4
    rarityLbl.Parent                 = rarityBadge
    self.rarityLbl = rarityLbl

    local itemName = Instance.new("TextLabel")
    itemName.Size                   = UDim2.new(1, -30, 0, 48)
    itemName.Position               = UDim2.new(0, 15, 0, 294)
    itemName.BackgroundTransparency = 1
    itemName.Text                   = ""
    itemName.TextColor3             = TEXT_W
    itemName.Font                   = Enum.Font.GothamBold
    itemName.TextSize               = 22
    itemName.TextWrapped            = true
    itemName.Visible                = false
    itemName.ZIndex                 = 3
    itemName.Parent                 = container
    self.itemName = itemName

    local sellLbl = Instance.new("TextLabel")
    sellLbl.Size                   = UDim2.new(1, -30, 0, 28)
    sellLbl.Position               = UDim2.new(0, 15, 0, 346)
    sellLbl.BackgroundTransparency = 1
    sellLbl.Text                   = ""
    sellLbl.TextColor3             = TEXT_DIM
    sellLbl.Font                   = Enum.Font.Gotham
    sellLbl.TextSize               = 15
    sellLbl.Visible                = false
    sellLbl.ZIndex                 = 3
    sellLbl.Parent                 = container
    self.sellLbl = sellLbl

    -- ── Commentary label (parented to sg so it floats above everything) ────
    local commentaryLbl = Instance.new("TextLabel")
    commentaryLbl.AnchorPoint          = Vector2.new(0.5, 0.5)
    commentaryLbl.Size                 = UDim2.new(0.7, 0, 0, 70)
    commentaryLbl.Position             = UDim2.fromScale(0.5, 0.30)
    commentaryLbl.BackgroundTransparency = 1
    commentaryLbl.Text                 = ""
    commentaryLbl.TextColor3           = GOLD
    commentaryLbl.Font                 = Enum.Font.GothamBold
    commentaryLbl.TextSize             = 28
    commentaryLbl.TextTransparency     = 1
    commentaryLbl.TextStrokeTransparency = 0.6
    commentaryLbl.TextStrokeColor3     = Color3.fromRGB(0, 0, 0)
    commentaryLbl.Visible              = false
    commentaryLbl.ZIndex               = 20
    commentaryLbl.Parent               = sg
    self.commentaryLbl = commentaryLbl

    -- ── SELL / KEEP buttons ─────────────────────────────────────────────────
    local function makeBtn(text, colorTop, colorBot, xPos, xSize)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(xSize, -12, 0, 50)
        btn.Position         = UDim2.new(xPos, 6, 1, -66)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text             = text
        btn.TextColor3       = TEXT_W
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 16
        btn.BorderSizePixel  = 0
        btn.Visible          = false
        btn.ZIndex           = 3
        btn.Parent           = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorTop),
            ColorSequenceKeypoint.new(1, colorBot),
        })
        grad.Parent = btn
        return btn, grad
    end

    local sellBtn, sellGrad = makeBtn("SELL",
        Color3.fromRGB(55, 210, 105), Color3.fromRGB(25, 130, 60), 0, 0.5)
    local keepBtn, keepGrad = makeBtn("KEEP",
        Color3.fromRGB(70, 95, 210),  Color3.fromRGB(35, 50, 140), 0.5, 0.5)
    self.sellBtn  = sellBtn
    self.keepBtn  = keepBtn

    sellBtn.MouseEnter:Connect(function()
        sellGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 240, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 165, 80)),
        })
    end)
    sellBtn.MouseLeave:Connect(function()
        sellGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 210, 105)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 130, 60)),
        })
    end)
    keepBtn.MouseEnter:Connect(function()
        keepGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 125, 245)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 75, 185)),
        })
    end)
    keepBtn.MouseLeave:Connect(function()
        keepGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 95, 210)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 50, 140)),
        })
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
function OpeningUI:_buildReelItems(winnerItem)
    local rewards = self._currentPack.rewards
    local items   = {}
    for i = 1, TOTAL_CARDS do
        if i == WINNER_IDX + 1 then
            items[i] = winnerItem
        else
            local r = rewards[math.random(1, #rewards)]
            items[i] = { name = r.name, imageId = r.imageId,
                         sellValue = r.sellValue, rarity = r.rarity }
        end
    end
    return items
end

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

    local topBar = Instance.new("Frame")
    topBar.Size            = UDim2.new(1, 0, 0, 5)
    topBar.BackgroundColor3= rarityInfo.color
    topBar.BorderSizePixel = 0
    topBar.ZIndex          = 5
    topBar.Parent          = card
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
    local topBarFill = Instance.new("Frame")
    topBarFill.Size            = UDim2.new(1, 0, 0.5, 0)
    topBarFill.Position        = UDim2.new(0, 0, 0.5, 0)
    topBarFill.BackgroundColor3= rarityInfo.color
    topBarFill.BorderSizePixel = 0
    topBarFill.ZIndex          = 5
    topBarFill.Parent          = topBar

    local tint = Instance.new("Frame")
    tint.Size                   = UDim2.fromScale(1, 1)
    tint.BackgroundColor3       = rarityInfo.color
    tint.BackgroundTransparency = 0.82
    tint.BorderSizePixel        = 0
    tint.ZIndex                 = 4
    tint.Parent                 = card
    Instance.new("UICorner", tint).CornerRadius = UDim.new(0, 8)

    local img = Instance.new("ImageLabel")
    img.Size                = UDim2.new(1, -12, 0, 96)
    img.Position            = UDim2.new(0, 6, 0, 12)
    img.BackgroundTransparency = 1
    img.Image               = item.imageId
    img.ScaleType           = Enum.ScaleType.Fit
    img.ZIndex              = 5
    img.Parent              = card

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

-- ---------------------------------------------------------------------------
-- HIT EFFECTS
-- ---------------------------------------------------------------------------
function OpeningUI:_playHitEffect(item, winnerCard)
    local rarityInfo = PackModule.getItemRarity(item.rarity)
    local color = rarityInfo.color
    local cfg   = HIT_FX[item.rarity] or HIT_FX.Common

    -- 1. Flash overlay (multiple flashes for Epic/Legendary)
    for i = 1, cfg.flashes do
        task.delay((i - 1) * 0.22, function()
            if not self.flashOverlay.Parent then return end
            self.flashOverlay.BackgroundColor3 = color
            TweenService:Create(self.flashOverlay, TweenInfo.new(0.08), {
                BackgroundTransparency = 1 - cfg.flashAlpha
            }):Play()
            task.delay(0.15, function()
                if self.flashOverlay.Parent then
                    TweenService:Create(self.flashOverlay, TweenInfo.new(0.28), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end)
        end)
    end

    -- 2. Bounce the winner card via UIScale
    if winnerCard and winnerCard.Parent then
        local uiScale = Instance.new("UIScale")
        uiScale.Scale  = 1
        uiScale.Parent = winnerCard
        TweenService:Create(uiScale,
            TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Scale = cfg.bounceSize }):Play()
        task.delay(0.18, function()
            if uiScale and uiScale.Parent then
                TweenService:Create(uiScale,
                    TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
                    { Scale = 1 }):Play()
            end
        end)
    end

    -- 3. Container shake (Rare+)
    if cfg.shakes > 0 then
        task.spawn(function()
            for _ = 1, cfg.shakes do
                local dx = (math.random() - 0.5) * 18
                local dy = (math.random() - 0.5) * 12
                TweenService:Create(self.container,
                    TweenInfo.new(0.04, Enum.EasingStyle.Sine),
                    { Position = UDim2.new(0.5, dx, 0.5, dy) }):Play()
                task.wait(0.04)
            end
            TweenService:Create(self.container, TweenInfo.new(0.12), {
                Position = UDim2.fromScale(0.5, 0.5)
            }):Play()
        end)
    end

    -- 4. Sparks radiating from reel centre (Rare+)
    if cfg.sparks > 0 then
        -- Reel centre as fraction of container: x=50%, y=(56+95)/570≈26.5%
        local cx = 0.5
        local cy = (56 + REEL_H * 0.5) / 570
        for i = 1, cfg.sparks do
            task.delay(i * 0.028, function()
                if not self.container.Parent then return end
                local spark  = Instance.new("Frame")
                local angle  = (2 * math.pi * i / cfg.sparks) + (math.random() - 0.5) * 0.8
                local dist   = math.random(55, 115)
                spark.AnchorPoint      = Vector2.new(0.5, 0.5)
                spark.Size             = UDim2.fromOffset(7, 7)
                spark.Position         = UDim2.new(cx, 0, cy, 0)
                spark.BackgroundColor3 = color
                spark.BorderSizePixel  = 0
                spark.ZIndex           = 6
                spark.Parent           = self.container
                Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)
                TweenService:Create(spark, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position            = UDim2.new(cx, math.cos(angle) * dist, cy, math.sin(angle) * dist),
                    BackgroundTransparency = 1,
                    Size                = UDim2.fromOffset(3, 3),
                }):Play()
                task.delay(0.57, function()
                    if spark and spark.Parent then spark:Destroy() end
                end)
            end)
        end
    end

    -- 5. Legendary: rapid glow border pulses
    if item.rarity == "Legendary" then
        task.spawn(function()
            for _ = 1, 3 do
                TweenService:Create(self.glowBorder, TweenInfo.new(0.1), {
                    Size = UDim2.fromOffset(876, 606)
                }):Play()
                task.wait(0.12)
                TweenService:Create(self.glowBorder, TweenInfo.new(0.1), {
                    Size = UDim2.fromOffset(852, 582)
                }):Play()
                task.wait(0.13)
            end
        end)
    end
end

-- ---------------------------------------------------------------------------
-- COMMENTARY
-- ---------------------------------------------------------------------------
function OpeningUI:_showCommentary(rarity, color)
    local lines = COMMENTARY[rarity] or COMMENTARY.Common
    local cfg   = HIT_FX[rarity] or HIT_FX.Common
    local text  = lines[math.random(1, #lines)]

    self.commentaryLbl.Text             = text
    self.commentaryLbl.TextColor3       = color
    self.commentaryLbl.TextSize         = cfg.commentSize
    self.commentaryLbl.TextTransparency = 1
    self.commentaryLbl.Position         = UDim2.fromScale(0.5, 0.32)
    self.commentaryLbl.Visible          = true

    TweenService:Create(self.commentaryLbl, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        Position         = UDim2.fromScale(0.5, 0.29),
    }):Play()

    task.delay(cfg.commentDuration, function()
        if not self.commentaryLbl.Parent then return end
        TweenService:Create(self.commentaryLbl, TweenInfo.new(0.45), {
            TextTransparency = 1,
            Position         = UDim2.fromScale(0.5, 0.24),
        }):Play()
        task.delay(0.5, function()
            if self.commentaryLbl.Parent then
                self.commentaryLbl.Visible = false
            end
        end)
    end)
end

-- ---------------------------------------------------------------------------
-- REEL STOP — called when the spin tween finishes
-- ---------------------------------------------------------------------------
function OpeningUI:_onReelStop(item, winnerCard)
    local rarityInfo = PackModule.getItemRarity(item.rarity)

    -- Pulsing glow stroke on winner card
    local stroke = Instance.new("UIStroke")
    stroke.Color     = rarityInfo.color
    stroke.Thickness = 3
    stroke.Parent    = winnerCard
    self._glowTween  = TweenService:Create(stroke,
        TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Thickness = 8 })
    self._glowTween:Play()

    -- Glow border colour
    TweenService:Create(self.glowBorder, TweenInfo.new(0.4), {
        BackgroundColor3 = rarityInfo.color
    }):Play()

    self.header.Text = "You got..."

    -- Fire hit effects and commentary immediately
    self:_playHitEffect(item, winnerCard)
    self:_showCommentary(item.rarity, rarityInfo.color)

    -- Staggered info reveal
    self.rarityBadge.BackgroundColor3 = rarityInfo.color
    self.rarityLbl.Text               = rarityInfo.displayName:upper()
    self.rarityBadge.Visible          = true

    task.delay(0.2, function()
        self.itemName.Text    = item.name
        self.itemName.Visible = true
    end)

    task.delay(0.8, function()
        self.sellLbl.Text    = "Sell value:  $" .. PackModule.formatNumber(item.sellValue)
        self.sellLbl.Visible = true
    end)

    self.sellBtn.Text = "SELL  $" .. PackModule.formatNumber(item.sellValue)
    task.delay(0.35, function()
        self.sellBtn.Visible = true
        self.keepBtn.Visible = true
    end)
end

-- ---------------------------------------------------------------------------
-- PUBLIC API
-- ---------------------------------------------------------------------------
function OpeningUI:showOpening(pack)
    self._currentPack = pack
    self._currentItem = nil

    self.rarityBadge.Visible  = false
    self.itemName.Visible     = false
    self.sellLbl.Visible      = false
    self.sellBtn.Visible      = false
    self.keepBtn.Visible      = false
    self.commentaryLbl.Visible = false
    self.header.Text          = "Opening " .. pack.name .. "..."
    self.strip.Position       = UDim2.fromOffset(9999, 0)

    local tier = PackModule.getPackTier(pack.tier)
    self.glowBorder.BackgroundColor3 = tier.glowColor

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

function OpeningUI:revealItem(item)
    self._currentItem = item

    for _, child in ipairs(self.strip:GetChildren()) do child:Destroy() end

    local reelItems = self:_buildReelItems(item)
    local winnerCard = nil
    for i, reelItem in ipairs(reelItems) do
        local card = self:_makeReelCard(reelItem, i - 1)
        if i == WINNER_IDX + 1 then winnerCard = card end
    end

    self.strip.Size     = UDim2.fromOffset(TOTAL_CARDS * SLOT_W, REEL_H)
    self.strip.Position = UDim2.fromOffset(9999, 0)

    task.wait()

    local containerW = self.reelClip.AbsoluteSize.X
    if containerW < 10 then containerW = 840 end

    local startX = containerW + 10
    self.strip.Position = UDim2.fromOffset(startX, 0)

    local winnerCentreInStrip = WINNER_IDX * SLOT_W + SLOT_W / 2
    local endX = math.floor(containerW / 2 - winnerCentreInStrip)

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

function OpeningUI:showError(msg)
    self.header.Text = msg
    task.delay(2.5, function()
        self:_close()
        if self.onKeep then self.onKeep(nil) end
    end)
end

function OpeningUI:_close()
    if self._glowTween then self._glowTween:Cancel(); self._glowTween = nil end
    self.commentaryLbl.Visible = false
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
