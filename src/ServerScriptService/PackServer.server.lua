-- =============================================================================
-- PackServer  (Script — ServerScriptService)
-- =============================================================================

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local DataStoreService   = game:GetService("DataStoreService")

local PackModule     = require(ReplicatedStorage:WaitForChild("PackModule"))
local BusinessConfig = require(ReplicatedStorage:WaitForChild("BusinessConfig"))

-- ---------------------------------------------------------------------------
-- Create all Remotes (server owns them; clients WaitForChild)
-- ---------------------------------------------------------------------------
local Remotes = Instance.new("Folder")
Remotes.Name   = "Remotes"
Remotes.Parent = ReplicatedStorage

local function makeRF(name)
    local rf = Instance.new("RemoteFunction"); rf.Name = name; rf.Parent = Remotes; return rf
end
local function makeRE(name)
    local re = Instance.new("RemoteEvent");    re.Name = name; re.Parent = Remotes; return re
end

local OpenPackFunction    = makeRF("OpenPack")
local SellItemFunction    = makeRF("SellItem")
local GetDataFunction     = makeRF("GetData")
local ClaimWorkFunction   = makeRF("ClaimWork")
local BuyBusinessFunction = makeRF("BuyBusiness")
local UpdateBalanceEvent  = makeRE("UpdateBalance")
local FlexItemEvent       = makeRE("FlexItem")
local StopFlexEvent       = makeRE("StopFlex")

-- ---------------------------------------------------------------------------
local Store = DataStoreService:GetDataStore("PackDraw_v2")
local cache = {}

local WORK_COOLDOWN  = 60
local WORK_MIN       = 150
local WORK_MAX       = 400

-- Streak rewards for days 1-7; day 7 repeats if they keep the streak going
local STREAK_REWARDS = { 500, 1000, 2000, 3500, 5000, 8000, 15000 }

local function defaultData()
    return {
        balance          = 1000,
        cooldowns        = {},
        inventory        = {},
        nextItemId       = 0,
        totalOpened      = 0,
        lastWork         = 0,
        lastDailyBonus   = 0,
        streakDays       = 0,
        businesses       = {},   -- [businessId] = true when owned
        lastPassiveCalc  = 0,    -- os.time() at last offline-income calculation
    }
end

-- ---------------------------------------------------------------------------
-- saveData and syncBalance must be defined before loadData so they are
-- in scope as upvalues (Lua compiles forward references as globals = nil).
-- ---------------------------------------------------------------------------
local function saveData(player)
    local data = cache[player.UserId]
    if not data then return end
    local ok, err = pcall(function() Store:SetAsync(tostring(player.UserId), data) end)
    if not ok then warn("[PackServer] Save failed for", player.Name, "–", err) end
end

local function syncBalance(player)
    local data = cache[player.UserId]
    if not data then return end
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local c = ls:FindFirstChild("Cash")
        if c then c.Value = data.balance end
    end
    UpdateBalanceEvent:FireClient(player, data.balance)
end

-- ---------------------------------------------------------------------------
local function loadData(player)
    local ok, stored = pcall(function() return Store:GetAsync(tostring(player.UserId)) end)
    local data = defaultData()
    if ok and type(stored) == "table" then
        for k, v in pairs(stored) do data[k] = v end
    elseif not ok then
        warn("[PackServer] DataStore load failed for", player.Name, "— using defaults.")
    end
    cache[player.UserId] = data

    local ls   = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player
    local cash = Instance.new("IntValue"); cash.Name = "Cash"; cash.Value = data.balance; cash.Parent = ls

    -- ── Offline passive income ─────────────────────────────────────────────
    -- lastPassiveCalc = 0 means first ever login; start the clock, no payout.
    -- PlayerRemoving stamps it on logout, so elapsed = true offline time.
    local lastCalc = data.lastPassiveCalc or 0
    if lastCalc == 0 then
        data.lastPassiveCalc = os.time()
    else
        local offlineSecs   = math.min(os.time() - lastCalc,
                                       BusinessConfig.MAX_OFFLINE_HOURS * 3600)
        local hourlyRate    = BusinessConfig.getHourlyRate(data.businesses or {})
        local offlineEarned = math.floor((offlineSecs / 3600) * hourlyRate)
        data.lastPassiveCalc = os.time()
        if offlineEarned > 0 then
            data.balance += offlineEarned
            task.delay(5, function()
                if player and player.Parent then
                    syncBalance(player)
                    UpdateBalanceEvent:FireClient(player, data.balance, "offline", offlineEarned)
                end
            end)
        end
    end

    -- ── Daily streak bonus ─────────────────────────────────────────────────
    local lastBonus     = data.lastDailyBonus or 0
    local secsSinceLast = os.time() - lastBonus
    if secsSinceLast >= 86400 then
        -- Within 48 h → maintain streak; beyond → reset
        if secsSinceLast < 172800 then
            data.streakDays = math.min((data.streakDays or 0) + 1, 7)
        else
            data.streakDays = 1
        end
        local streakAmt     = STREAK_REWARDS[data.streakDays] or STREAK_REWARDS[1]
        data.balance        += streakAmt
        data.lastDailyBonus  = os.time()
        task.spawn(saveData, player)
        task.delay(3, function()
            if player and player.Parent then
                syncBalance(player)
                UpdateBalanceEvent:FireClient(
                    player, data.balance, "streak", streakAmt, data.streakDays)
            end
        end)
    end
end

-- ---------------------------------------------------------------------------
GetDataFunction.OnServerInvoke = function(player)
    local data = cache[player.UserId]
    if not data then return nil end
    return {
        balance    = data.balance,
        cooldowns  = data.cooldowns,
        inventory  = data.inventory,
        totalOpened= data.totalOpened,
        lastWork   = data.lastWork   or 0,
        businesses = data.businesses or {},
        streakDays = data.streakDays or 0,
        hourlyRate = BusinessConfig.getHourlyRate(data.businesses or {}),
    }
end

-- ---------------------------------------------------------------------------
ClaimWorkFunction.OnServerInvoke = function(player)
    local data = cache[player.UserId]
    if not data then return { success = false, reason = "Data not ready." } end

    local elapsed = os.time() - (data.lastWork or 0)
    if elapsed < WORK_COOLDOWN then
        local remaining = WORK_COOLDOWN - elapsed
        return { success = false, remaining = remaining,
                 reason = string.format("Work again in %ds", remaining) }
    end

    local earned     = math.random(WORK_MIN, WORK_MAX)
    data.balance    += earned
    data.lastWork    = os.time()

    syncBalance(player)
    task.spawn(saveData, player)

    return { success = true, earned = earned, newBalance = data.balance }
end

-- ---------------------------------------------------------------------------
BuyBusinessFunction.OnServerInvoke = function(player, businessId)
    if type(businessId) ~= "string" then
        return { success = false, reason = "Invalid request." }
    end
    local data = cache[player.UserId]
    if not data then return { success = false, reason = "Data not ready." } end

    local business = BusinessConfig.getById(businessId)
    if not business then return { success = false, reason = "Business not found." } end

    data.businesses = data.businesses or {}
    if data.businesses[businessId] then
        return { success = false, reason = "Already owned." }
    end
    if data.balance < business.cost then
        return { success = false, reason = "Not enough cash." }
    end

    data.balance -= business.cost
    data.businesses[businessId] = true

    syncBalance(player)
    task.spawn(saveData, player)

    return {
        success    = true,
        newBalance = data.balance,
        hourlyRate = BusinessConfig.getHourlyRate(data.businesses),
    }
end

-- ---------------------------------------------------------------------------
OpenPackFunction.OnServerInvoke = function(player, packId)
    if type(packId) ~= "string" then
        return { success = false, reason = "Invalid request." }
    end
    local data = cache[player.UserId]
    if not data then return { success = false, reason = "Data not ready." } end

    local pack = PackModule.getPackById(packId)
    if not pack then return { success = false, reason = "Pack not found." } end

    local canOpen, reason = PackModule.canOpenPack(pack, data.balance, data.cooldowns[packId])
    if not canOpen then return { success = false, reason = reason } end

    if pack.price > 0 then data.balance -= pack.price end
    if pack.cooldown > 0 then data.cooldowns[packId] = os.time() end

    local reward = PackModule.rollReward(pack)

    data.nextItemId = (data.nextItemId or 0) + 1
    local itemId = tostring(data.nextItemId)
    data.inventory[itemId] = {
        name      = reward.name,
        imageId   = reward.imageId,
        sellValue = reward.sellValue,
        rarity    = reward.rarity,
    }
    data.totalOpened += 1

    syncBalance(player)
    task.spawn(saveData, player)

    return {
        success = true,
        item = {
            id        = itemId,
            name      = reward.name,
            imageId   = reward.imageId,
            sellValue = reward.sellValue,
            rarity    = reward.rarity,
        },
        newBalance = data.balance,
    }
end

-- ---------------------------------------------------------------------------
SellItemFunction.OnServerInvoke = function(player, itemId)
    local strId = tostring(itemId)
    if strId == "nil" or strId == "" then
        return { success = false, reason = "Invalid item." }
    end

    local data = cache[player.UserId]
    if not data then return { success = false, reason = "Data not ready." } end

    local item = data.inventory[strId]
    if not item then
        return { success = false, reason = "Item not found in inventory." }
    end

    data.balance += item.sellValue
    data.inventory[strId] = nil

    syncBalance(player)
    task.spawn(saveData, player)

    return { success = true, newBalance = data.balance, earned = item.sellValue }
end

-- ---------------------------------------------------------------------------
-- FLEX billboard
-- ---------------------------------------------------------------------------
FlexItemEvent.OnServerEvent:Connect(function(player, itemName, rarityKey, sellValue)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local old = hrp:FindFirstChild("FlexBillboard")
    if old then old:Destroy() end

    local rarityInfo = PackModule.getItemRarity(rarityKey)

    local bb = Instance.new("BillboardGui")
    bb.Name           = "FlexBillboard"
    bb.Size           = UDim2.fromOffset(230, 72)
    bb.StudsOffset    = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop    = false
    bb.ResetOnSpawn   = false
    bb.Parent         = hrp

    local bg = Instance.new("Frame")
    bg.Size                   = UDim2.fromScale(1, 1)
    bg.BackgroundColor3       = Color3.fromRGB(10, 10, 22)
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel        = 0
    bg.Parent                 = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size            = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3= rarityInfo.color
    bar.BorderSizePixel = 0
    bar.Parent          = bg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -14, 0, 36)
    nameLbl.Position              = UDim2.new(0, 10, 0, 4)
    nameLbl.BackgroundTransparency= 1
    nameLbl.Text                  = itemName
    nameLbl.TextColor3            = rarityInfo.color
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextSize              = 14
    nameLbl.TextWrapped           = true
    nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
    nameLbl.Parent                = bg

    local valLbl = Instance.new("TextLabel")
    valLbl.Size                   = UDim2.new(1, -14, 0, 24)
    valLbl.Position               = UDim2.new(0, 10, 0, 42)
    valLbl.BackgroundTransparency = 1
    valLbl.Text                   = "$" .. PackModule.formatNumber(sellValue) .. "  ·  " .. rarityKey
    valLbl.TextColor3             = Color3.fromRGB(255, 220, 50)
    valLbl.Font                   = Enum.Font.Gotham
    valLbl.TextSize               = 12
    valLbl.TextXAlignment         = Enum.TextXAlignment.Left
    valLbl.Parent                 = bg
end)

StopFlexEvent.OnServerEvent:Connect(function(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bb = hrp:FindFirstChild("FlexBillboard")
    if bb then bb:Destroy() end
end)

-- ---------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
    loadData(player)
    syncBalance(player)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Stamp logout time so offline earnings start from here, not last login
    local data = cache[player.UserId]
    if data then data.lastPassiveCalc = os.time() end
    saveData(player)
    cache[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function() loadData(player); syncBalance(player) end)
end

task.spawn(function()
    while true do
        task.wait(300)
        for _, player in ipairs(Players:GetPlayers()) do task.spawn(saveData, player) end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local data = cache[player.UserId]
        if data then data.lastPassiveCalc = os.time() end
        saveData(player)
    end
end)
