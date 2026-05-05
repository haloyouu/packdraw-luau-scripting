-- =============================================================================
-- OpeningUI  (ModuleScript — ReplicatedStorage/UI)
-- CS:GO / Packdraw style reel UI
-- =============================================================================

local TweenService = game:GetService("TweenService")
local PackModule   = require(script.Parent.Parent.PackModule)

local SLOT_W      = 138
local CARD_W      = 126
local CARD_H      = 170
local REEL_H      = 200
local TOTAL_CARDS = 42
local WINNER_IDX  = 34

local BG        = Color3.fromRGB( 15,  15,  20)
local REEL_BG   = Color3.fromRGB( 22,  22,  30)
local CARD_BG   = Color3.fromRGB( 30,  30,  42)
local TEXT_W    = Color3.fromRGB(255, 255, 255)
local TEXT_DIM  = Color3.fromRGB(160, 160, 200)
local GOLD      = Color3.fromRGB(255, 220,  50)
local GREEN     = Color3.fromRGB( 90, 220, 100)

-- ---------------------------------------------------------------------------
local COMMENTARY = {
    Common    = { "Not bad...", "A start!", "Keep trying.", "Could be worse!" },
    Uncommon  = { "Nice one!", "That's decent!", "Getting warmer!", "Solid pick." },
    Rare      = { "Ooh nice!", "Now we're talking!", "Fire!", "Clean pull!" },
    Epic      = { "EPIC!", "You crazy?!", "Wild pull!", "LET'S GO!", "CHAT!" },
    Legendary = { "LEGENDARY!!!", "INSANE!", "GOATED!", "ABSOLUTELY MENTAL!", "W PULL!!!!" },
}

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
    self.onSell       = nil   -- callback(item)
    self.onReroll     = nil   -- callback(item) – item auto-kept, open again
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

    -- Full-screen dark overlay
    local overlay = Instance.new("Frame")
    overlay.Size                   = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 1
    overlay.Parent                 = sg

    -- ── Main panel (wide, not too tall) ────────────────────────────────────
    local panel = Instance.new("Frame")
    panel.Name             = "Panel"
    panel.AnchorPoint      = Vector2.new(0.5, 0.5)
    panel.Size             = UDim2.new(0.92, 0, 0, 420)
    panel.Position         = UDim2.fromScale(0.5, 0.5)
    panel.BackgroundColor3 = BG
    panel.BorderSizePixel  = 0
    panel.ZIndex           = 2
    panel.Parent           = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
    self.panel = panel

    -- Glow border (coloured outline that pulses on win)
    local glowBorder = Instance.new("UIStroke")
    glowBorder.Color     = Color3.fromRGB(100, 100, 255)
    glowBorder.Thickness = 2
    glowBorder.Parent    = panel
    self.glowStroke      = glowBorder

    -- ── Item name strip (top of panel, hidden until spin ends) ─────────────
    local nameStrip = Instance.new("Frame")
    nameStrip.Size            = UDim2.new(1, 0, 0, 52)
    nameStrip.BackgroundColor3= Color3.fromRGB(18, 18, 26)
    nameStrip.BorderSizePixel = 0
    nameStrip.ZIndex          = 3
    nameStrip.Visible         = false
    nameStrip.Parent          = panel
    self.nameStrip = nameStrip

    local itemNameLbl = Instance.new("TextLabel")
    itemNameLbl.Size                   = UDim2.new(1, -20, 1, 0)
    itemNameLbl.Position               = UDim2.new(0, 10, 0, 0)
    itemNameLbl.BackgroundTransparency = 1
    itemNameLbl.Text                   = ""
    itemNameLbl.TextColor3             = TEXT_W
    itemNameLbl.Font                   = Enum.Font.GothamBold
    itemNameLbl.TextSize               = 18
    itemNameLbl.TextXAlignment         = Enum.TextXAlignment.Left
    itemNameLbl.ZIndex                 = 4
    itemNameLbl.Parent                 = nameStrip
    self.itemNameLbl = itemNameLbl

    local rarityTagLbl = Instance.new("TextLabel")
    rarityTagLbl.Size                   = UDim2.new(0, 180, 1, 0)
    rarityTagLbl.Position               = UDim2.new(1, -190, 0, 0)
    rarityTagLbl.BackgroundTransparency = 1
    rarityTagLbl.Text                   = ""
    rarityTagLbl.TextColor3             = GOLD
    rarityTagLbl.Font                   = Enum.Font.GothamBold
    rarityTagLbl.TextSize               = 15
    rarityTagLbl.TextXAlignment         = Enum.TextXAlignment.Right
    rarityTagLbl.ZIndex                 = 4
    rarityTagLbl.Parent                 = nameStrip
    self.rarityTagLbl = rarityTagLbl

    -- Opening pack label (shown while spinning)
    local spinLbl = Instance.new("TextLabel")
    spinLbl.Name                   = "SpinLbl"
    spinLbl.Size                   = UDim2.new(1, -20, 0, 52)
    spinLbl.Position               = UDim2.new(0, 10, 0, 0)
    spinLbl.BackgroundTransparency = 1
    spinLbl.Text                   = "Opening..."
    spinLbl.TextColor3             = TEXT_DIM
    spinLbl.Font                   = Enum.Font.GothamBold
    spinLbl.TextSize               = 16
    spinLbl.TextXAlignment         = Enum.TextXAlignment.Left
    spinLbl.ZIndex                 = 3
    spinLbl.Parent                 = panel
    self.spinLbl = spinLbl

    -- ── Reel area ──────────────────────────────────────────────────────────
    local reelClip = Instance.new("Frame")
    reelClip.Name             = "ReelClip"
    reelClip.Size             = UDim2.new(1, 0, 0, REEL_H)
    reelClip.Position         = UDim2.new(0, 0, 0, 52)
    reelClip.BackgroundColor3 = REEL_BG
    reelClip.BorderSizePixel  = 0
    reelClip.ClipsDescendants = true
    reelClip.ZIndex           = 3
    reelClip.Parent           = panel
    self.reelClip = reelClip

    -- Left edge fade
    local function makeSideFade(anchorRight)
        local f = Instance.new("Frame")
        f.Size                   = UDim2.new(0.10, 0, 1, 0)
        f.Position               = anchorRight and UDim2.new(0.90, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        f.BackgroundColor3       = REEL_BG
        f.BackgroundTransparency = 0
        f.BorderSizePixel        = 0
        f.ZIndex                 = 7
        f.Parent                 = reelClip
        local g = Instance.new("UIGradient")
        g.Rotation    = anchorRight and 270 or 90
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        g.Parent = f
    end
    makeSideFade(false)
    makeSideFade(true)

    -- Strip
    local strip = Instance.new("Frame")
    strip.Name                = "Strip"
    strip.Size                = UDim2.fromOffset(TOTAL_CARDS * SLOT_W, REEL_H)
    strip.Position            = UDim2.fromOffset(9999, 0)
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel     = 0
    strip.ZIndex              = 4
    strip.Parent              = reelClip
    self.strip = strip

    -- Center triangle pointers (CS:GO style)
    local function makeTriangle(bottom)
        local t = Instance.new("Frame")
        t.AnchorPoint      = Vector2.new(0.5, bottom and 1 or 0)
        t.Size             = UDim2.fromOffset(18, 14)
        t.Position         = UDim2.new(0.5, 0, bottom and 1 or 0, 0)
        t.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        t.BorderSizePixel  = 0
        t.ZIndex           = 10
        t.Parent           = reelClip
        -- Use rotation trick for triangle look
        local g = Instance.new("UIGradient")
        g.Rotation    = bottom and 180 or 0
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        g.Parent = t
    end
    makeTriangle(false)
    makeTriangle(true)

    -- Center vertical line
    local centerLine = Instance.new("Frame")
    centerLine.AnchorPoint      = Vector2.new(0.5, 0)
    centerLine.Size             = UDim2.new(0, 2, 1, 0)
    centerLine.Position         = UDim2.new(0.5, 0, 0, 0)
    centerLine.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    centerLine.BackgroundTransparency = 0.4
    centerLine.BorderSizePixel  = 0
    centerLine.ZIndex           = 9
    centerLine.Parent           = reelClip

    -- ── Flash overlay ─────────────────────────────────────────────────────
    local flashOverlay = Instance.new("Frame")
    flashOverlay.Size                   = UDim2.fromScale(1, 1)
    flashOverlay.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    flashOverlay.BackgroundTransparency = 1
    flashOverlay.BorderSizePixel        = 0
    flashOverlay.ZIndex                 = 8
    flashOverlay.Parent                 = panel
    Instance.new("UICorner", flashOverlay).CornerRadius = UDim.new(0, 6)
    self.flashOverlay = flashOverlay

    -- ── Buttons row ────────────────────────────────────────────────────────
    local btnRow = Instance.new("Frame")
    btnRow.Size            = UDim2.new(1, 0, 0, 64)
    btnRow.Position        = UDim2.new(0, 0, 0, 52 + REEL_H)
    btnRow.BackgroundColor3= Color3.fromRGB(18, 18, 26)
    btnRow.BorderSizePixel = 0
    btnRow.ZIndex          = 3
    btnRow.Visible         = false
    btnRow.Parent          = panel
    self.btnRow = btnRow

    -- Sell button (outlined green, CS:GO style)
    local sellBtn = Instance.new("TextButton")
    sellBtn.Size             = UDim2.new(0.48, -16, 0, 40)
    sellBtn.Position         = UDim2.new(0.02, 8, 0.5, -20)
    sellBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 25)
    sellBtn.Text             = "Sell for $0"
    sellBtn.TextColor3       = GREEN
    sellBtn.Font             = Enum.Font.GothamBold
    sellBtn.TextSize         = 15
    sellBtn.BorderSizePixel  = 0
    sellBtn.ZIndex           = 4
    sellBtn.Parent           = btnRow
    Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 4)
    local sellStroke = Instance.new("UIStroke")
    sellStroke.Color     = GREEN
    sellStroke.Thickness = 1.5
    sellStroke.Parent    = sellBtn
    self.sellBtn   = sellBtn
    self.sellStroke = sellStroke

    -- Reroll button (dark)
    local rerollBtn = Instance.new("TextButton")
    rerollBtn.Size             = UDim2.new(0.48, -16, 0, 40)
    rerollBtn.Position         = UDim2.new(0.50, 8, 0.5, -20)
    rerollBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    rerollBtn.Text             = "Reroll"
    rerollBtn.TextColor3       = TEXT_W
    rerollBtn.Font             = Enum.Font.GothamBold
    rerollBtn.TextSize         = 15
    rerollBtn.BorderSizePixel  = 0
    rerollBtn.ZIndex           = 4
    rerollBtn.Parent           = btnRow
    Instance.new("UICorner", rerollBtn).CornerRadius = UDim.new(0, 4)
    local rerollStroke = Instance.new("UIStroke")
    rerollStroke.Color     = Color3.fromRGB(80, 80, 100)
    rerollStroke.Thickness = 1.5
    rerollStroke.Parent    = rerollBtn
    self.rerollBtn = rerollBtn

    -- Button hover effects
    sellBtn.MouseEnter:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 70, 35)
        }):Play()
    end)
    sellBtn.MouseLeave:Connect(function()
        TweenService:Create(sellBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(20, 50, 25)
        }):Play()
    end)
    rerollBtn.MouseEnter:Connect(function()
        TweenService:Create(rerollBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        }):Play()
    end)
    rerollBtn.MouseLeave:Connect(function()
        TweenService:Create(rerollBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(38, 38, 52)
        }):Play()
    end)

    sellBtn.MouseButton1Click:Connect(function()
        if not self._currentItem then return end
        if self._glowTween then self._glowTween:Cancel() end
        local item = self._currentItem
        self:_close()
        if self.onSell then self.onSell(item) end
    end)

    -- Reroll: item already in inventory (server added it), just open again
    rerollBtn.MouseButton1Click:Connect(function()
        if not self._currentItem then return end
        if self._glowTween then self._glowTween:Cancel() end
        local item = self._currentItem
        local pack = self._currentPack
        self:_close()
        if self.onReroll then self.onReroll(item, pack) end
    end)

    -- ── Commentary label ───────────────────────────────────────────────────
    local commentaryLbl = Instance.new("TextLabel")
    commentaryLbl.AnchorPoint            = Vector2.new(0.5, 0.5)
    commentaryLbl.Size                   = UDim2.new(0.7, 0, 0, 70)
    commentaryLbl.Position               = UDim2.fromScale(0.5, 0.38)
    commentaryLbl.BackgroundTransparency = 1
    commentaryLbl.Text                   = ""
    commentaryLbl.TextColor3             = GOLD
    commentaryLbl.Font                   = Enum.Font.GothamBold
    commentaryLbl.TextSize               = 28
    commentaryLbl.TextTransparency       = 1
    commentaryLbl.TextStrokeTransparency = 0.6
    commentaryLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    commentaryLbl.Visible                = false
    commentaryLbl.ZIndex                 = 20
    commentaryLbl.Parent                 = sg
    self.commentaryLbl = commentaryLbl
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
    card.BackgroundColor3= CARD_BG
    card.BorderSizePixel = 0
    card.ZIndex          = 5
    card.Parent          = self.strip
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

    -- Rarity color left bar (CS:GO style)
    local bar = Instance.new("Frame")
    bar.Size            = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3= rarityInfo.color
    bar.BorderSizePixel = 0
    bar.ZIndex          = 6
    bar.Parent          = card
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    -- Subtle rarity tint
    local tint = Instance.new("Frame")
    tint.Size                   = UDim2.fromScale(1, 1)
    tint.BackgroundColor3       = rarityInfo.color
    tint.BackgroundTransparency = 0.88
    tint.BorderSizePixel        = 0
    tint.ZIndex                 = 5
    tint.Parent                 = card
    Instance.new("UICorner", tint).CornerRadius = UDim.new(0, 4)

    -- Item image
    local img = Instance.new("ImageLabel")
    img.Size                = UDim2.new(1, -14, 0, 108)
    img.Position            = UDim2.new(0, 8, 0, 8)
    img.BackgroundTransparency = 1
    img.Image               = item.imageId
    img.ScaleType           = Enum.ScaleType.Fit
    img.ZIndex              = 6
    img.Parent              = card

    -- Item name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -14, 0, 38)
    nameLbl.Position              = UDim2.new(0, 8, 0, 120)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = item.name
    nameLbl.TextColor3            = TEXT_W
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 11
    nameLbl.TextWrapped           = true
    nameLbl.TextYAlignment        = Enum.TextYAlignment.Top
    nameLbl.ZIndex                = 6
    nameLbl.Parent                = card

    -- Value
    local valLbl = Instance.new("TextLabel")
    valLbl.Size                  = UDim2.new(1, -14, 0, 18)
    valLbl.Position              = UDim2.new(0, 8, 1, -22)
    valLbl.BackgroundTransparency= 1
    valLbl.Text                  = "$" .. PackModule.formatNumber(item.sellValue)
    valLbl.TextColor3            = rarityInfo.color
    valLbl.Font                  = Enum.Font.GothamBold
    valLbl.TextSize              = 11
    valLbl.ZIndex                = 6
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

    if cfg.shakes > 0 then
        task.spawn(function()
            for _ = 1, cfg.shakes do
                local dx = (math.random() - 0.5) * 14
                local dy = (math.random() - 0.5) * 8
                TweenService:Create(self.panel,
                    TweenInfo.new(0.04, Enum.EasingStyle.Sine),
                    { Position = UDim2.new(0.5, dx, 0.5, dy) }):Play()
                task.wait(0.04)
            end
            TweenService:Create(self.panel, TweenInfo.new(0.12), {
                Position = UDim2.fromScale(0.5, 0.5)
            }):Play()
        end)
    end

    if cfg.sparks > 0 then
        local cx = 0.5
        local cy = (52 + REEL_H * 0.5) / 420
        for i = 1, cfg.sparks do
            task.delay(i * 0.028, function()
                if not self.panel.Parent then return end
                local spark  = Instance.new("Frame")
                local angle  = (2 * math.pi * i / cfg.sparks) + (math.random() - 0.5) * 0.8
                local dist   = math.random(50, 110)
                spark.AnchorPoint      = Vector2.new(0.5, 0.5)
                spark.Size             = UDim2.fromOffset(6, 6)
                spark.Position         = UDim2.new(cx, 0, cy, 0)
                spark.BackgroundColor3 = color
                spark.BorderSizePixel  = 0
                spark.ZIndex           = 6
                spark.Parent           = self.panel
                Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)
                TweenService:Create(spark,
                    TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position            = UDim2.new(cx, math.cos(angle)*dist, cy, math.sin(angle)*dist),
                    BackgroundTransparency = 1,
                    Size                = UDim2.fromOffset(2, 2),
                }):Play()
                task.delay(0.57, function()
                    if spark and spark.Parent then spark:Destroy() end
                end)
            end)
        end
    end

    -- Legendary: pulse the border stroke
    if item.rarity == "Legendary" then
        task.spawn(function()
            for _ = 1, 3 do
                TweenService:Create(self.glowStroke, TweenInfo.new(0.1), { Thickness = 5 }):Play()
                task.wait(0.12)
                TweenService:Create(self.glowStroke, TweenInfo.new(0.1), { Thickness = 2 }):Play()
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
    self.commentaryLbl.Position         = UDim2.fromScale(0.5, 0.42)
    self.commentaryLbl.Visible          = true

    TweenService:Create(self.commentaryLbl,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        Position         = UDim2.fromScale(0.5, 0.38),
    }):Play()

    task.delay(cfg.commentDuration, function()
        if not self.commentaryLbl.Parent then return end
        TweenService:Create(self.commentaryLbl, TweenInfo.new(0.4), {
            TextTransparency = 1,
            Position         = UDim2.fromScale(0.5, 0.33),
        }):Play()
        task.delay(0.45, function()
            if self.commentaryLbl.Parent then
                self.commentaryLbl.Visible = false
            end
        end)
    end)
end

-- ---------------------------------------------------------------------------
-- REEL STOP
-- ---------------------------------------------------------------------------
function OpeningUI:_onReelStop(item, winnerCard)
    local rarityInfo = PackModule.getItemRarity(item.rarity)
    local color = rarityInfo.color

    -- Pulsing stroke on winner card
    local stroke = Instance.new("UIStroke")
    stroke.Color     = color
    stroke.Thickness = 2
    stroke.Parent    = winnerCard
    self._glowTween  = TweenService:Create(stroke,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Thickness = 6 })
    self._glowTween:Play()

    -- Colour the panel border
    TweenService:Create(self.glowStroke, TweenInfo.new(0.4), {
        Color = color, Thickness = 2
    }):Play()

    -- Show item name strip
    self.spinLbl.Visible         = false
    self.nameStrip.Visible       = true
    self.itemNameLbl.Text        = item.name
    self.itemNameLbl.TextColor3  = TEXT_W
    self.rarityTagLbl.Text       = rarityInfo.displayName:upper()
    self.rarityTagLbl.TextColor3 = color

    -- Fade in name strip
    self.nameStrip.BackgroundTransparency = 1
    TweenService:Create(self.nameStrip, TweenInfo.new(0.3), {
        BackgroundTransparency = 0
    }):Play()

    self:_playHitEffect(item, winnerCard)
    self:_showCommentary(item.rarity, color)

    -- Show buttons
    self.sellBtn.Text = "Sell for $" .. PackModule.formatNumber(item.sellValue)
    task.delay(0.3, function()
        self.btnRow.Visible = true
    end)
end

-- ---------------------------------------------------------------------------
-- PUBLIC API
-- ---------------------------------------------------------------------------
function OpeningUI:showOpening(pack)
    self._currentPack = pack
    self._currentItem = nil

    self.nameStrip.Visible  = false
    self.spinLbl.Visible    = true
    self.spinLbl.Text       = "Opening " .. pack.name .. "..."
    self.btnRow.Visible     = false
    self.commentaryLbl.Visible = false
    self.strip.Position     = UDim2.fromOffset(9999, 0)

    local tier = PackModule.getPackTier(pack.tier)
    self.glowStroke.Color = tier.glowColor

    self.panel.Size     = UDim2.new(0.92, 0, 0, 4)
    self.screenGui.Enabled = true

    TweenService:Create(self.panel,
        TweenInfo.new(0.35, Enum.EasingStyle.Back),
        { Size = UDim2.new(0.92, 0, 0, 420) }):Play()
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
    self.spinLbl.Text = msg
    task.delay(2.5, function()
        self:_close()
        if self.onReroll then self.onReroll(nil, self._currentPack) end
    end)
end

function OpeningUI:_close()
    if self._glowTween then self._glowTween:Cancel(); self._glowTween = nil end
    self.commentaryLbl.Visible = false
    local t = TweenService:Create(self.panel,
        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.new(0.92, 0, 0, 4) })
    t.Completed:Connect(function() self.screenGui.Enabled = false end)
    t:Play()
end

return OpeningUI
