-- =============================================================================
-- PackServer  (Script — ServerScriptService)
-- =============================================================================

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local DataStoreService   = game:GetService("DataStoreService")

local PackModule = require(ReplicatedStorage:WaitForChild("PackModule"))

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

local OpenPackFunction   = makeRF("OpenPack")
local SellItemFunction   = makeRF("SellItem")
local GetDataFunction    = makeRF("GetData")
local UpdateBalanceEvent = makeRE("UpdateBalance")
local FlexItemEvent      = makeRE("FlexItem")   -- client → server: show billboard
local StopFlexEvent      = makeRE("StopFlex")   -- client → server: hide billboard

-- ---------------------------------------------------------------------------
local Store = DataStoreService:GetDataStore("PackDraw_v2")
local cache = {}

local function defaultData()
    return {
        balance     = 1000,
        cooldowns   = {},   -- [packId] = timestamp
        inventory   = {},   -- [tostring(itemId)] = { name, imageId, sellValue, rarity }
        nextItemId  = 0,
        totalOpened = 0,
    }
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
end

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
GetDataFunction.OnServerInvoke = function(player)
    local data = cache[player.UserId]
    if not data then return nil end
    return { balance = data.balance, cooldowns = data.cooldowns,
             inventory = data.inventory, totalOpened = data.totalOpened }
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

    -- Always store inventory with STRING keys so DataStore round-trips are safe
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
            id        = itemId,          -- string, always
            name      = reward.name,
            imageId   = reward.imageId,
            sellValue = reward.sellValue,
            rarity    = reward.rarity,
        },
        newBalance = data.balance,
    }
end

-- ---------------------------------------------------------------------------
-- FIX: accept string OR number itemId (DataStore converts numeric keys to strings)
-- ---------------------------------------------------------------------------
SellItemFunction.OnServerInvoke = function(player, itemId)
    -- Normalise: whatever the client sends, turn it into the string key we store
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
-- FLEX: create a BillboardGui on the player's character (replicates to all)
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
    bg.Size                    = UDim2.fromScale(1, 1)
    bg.BackgroundColor3        = Color3.fromRGB(10, 10, 22)
    bg.BackgroundTransparency  = 0.15
    bg.BorderSizePixel         = 0
    bg.Parent                  = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    -- Coloured left accent bar
    local bar = Instance.new("Frame")
    bar.Size            = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3= rarityInfo.color
    bar.BorderSizePixel = 0
    bar.Parent          = bg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                 = UDim2.new(1, -14, 0, 36)
    nameLbl.Position             = UDim2.new(0, 10, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                 = itemName
    nameLbl.TextColor3           = rarityInfo.color
    nameLbl.Font                 = Enum.Font.GothamBold
    nameLbl.TextSize             = 14
    nameLbl.TextWrapped          = true
    nameLbl.TextXAlignment       = Enum.TextXAlignment.Left
    nameLbl.Parent               = bg

    local valLbl = Instance.new("TextLabel")
    valLbl.Size                  = UDim2.new(1, -14, 0, 24)
    valLbl.Position              = UDim2.new(0, 10, 0, 42)
    valLbl.BackgroundTransparency = 1
    valLbl.Text                  = "$" .. PackModule.formatNumber(sellValue) .. "  ·  " .. rarityKey
    valLbl.TextColor3            = Color3.fromRGB(255, 220, 50)
    valLbl.Font                  = Enum.Font.Gotham
    valLbl.TextSize              = 12
    valLbl.TextXAlignment        = Enum.TextXAlignment.Left
    valLbl.Parent                = bg
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
    for _, player in ipairs(Players:GetPlayers()) do saveData(player) end
end)
