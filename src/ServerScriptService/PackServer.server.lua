-- =============================================================================
-- PackServer  (Script — ServerScriptService)
--
-- Authoritative server script.
-- Opening a pack gives the player an ITEM stored in their inventory.
-- Players sell items via the SellItem remote to receive cash.
-- =============================================================================

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local DataStoreService   = game:GetService("DataStoreService")

local PackModule = require(ReplicatedStorage:WaitForChild("PackModule"))

-- Create the Remotes folder and all remote instances.
-- The server owns these; clients use WaitForChild to find them.
local Remotes = Instance.new("Folder")
Remotes.Name   = "Remotes"
Remotes.Parent = ReplicatedStorage

local OpenPackFunction   = Instance.new("RemoteFunction")
OpenPackFunction.Name    = "OpenPack"
OpenPackFunction.Parent  = Remotes

local SellItemFunction   = Instance.new("RemoteFunction")
SellItemFunction.Name    = "SellItem"
SellItemFunction.Parent  = Remotes

local GetDataFunction    = Instance.new("RemoteFunction")
GetDataFunction.Name     = "GetData"
GetDataFunction.Parent   = Remotes

local UpdateBalanceEvent = Instance.new("RemoteEvent")
UpdateBalanceEvent.Name   = "UpdateBalance"
UpdateBalanceEvent.Parent = Remotes

-- DataStore
local Store = DataStoreService:GetDataStore("PackDraw_v2")

-- In-memory cache
local cache = {}

-- ---------------------------------------------------------------------------
-- Default data for a new player
-- ---------------------------------------------------------------------------
local function defaultData()
    return {
        balance     = 1000,   -- starting cash
        cooldowns   = {},     -- [packId] = unix timestamp of last open
        inventory   = {},     -- [itemId] = { name, imageId, sellValue, rarity }
        nextItemId  = 0,      -- auto-increment counter for inventory slots
        totalOpened = 0,
    }
end

-- ---------------------------------------------------------------------------
-- Load from DataStore, merge over defaults
-- ---------------------------------------------------------------------------
local function loadData(player: Player)
    local ok, stored = pcall(function()
        return Store:GetAsync(tostring(player.UserId))
    end)

    local data = defaultData()
    if ok and type(stored) == "table" then
        for k, v in pairs(stored) do
            data[k] = v
        end
    elseif not ok then
        warn("[PackServer] DataStore load failed for", player.Name, "— using defaults.")
    end

    cache[player.UserId] = data

    local leaderstats = Instance.new("Folder")
    leaderstats.Name   = "leaderstats"
    leaderstats.Parent = player

    local cash = Instance.new("IntValue")
    cash.Name   = "Cash"
    cash.Value  = data.balance
    cash.Parent = leaderstats
end

-- ---------------------------------------------------------------------------
-- Persist to DataStore
-- ---------------------------------------------------------------------------
local function saveData(player: Player)
    local data = cache[player.UserId]
    if not data then return end
    local ok, err = pcall(function()
        Store:SetAsync(tostring(player.UserId), data)
    end)
    if not ok then
        warn("[PackServer] DataStore save failed for", player.Name, "–", err)
    end
end

-- ---------------------------------------------------------------------------
-- Sync leaderstats + fire client balance event
-- ---------------------------------------------------------------------------
local function syncBalance(player: Player)
    local data = cache[player.UserId]
    if not data then return end
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash")
        if cash then cash.Value = data.balance end
    end
    UpdateBalanceEvent:FireClient(player, data.balance)
end

-- ---------------------------------------------------------------------------
-- RemoteFunction: GetData
-- Returns balance, cooldowns, and full inventory to the client.
-- ---------------------------------------------------------------------------
GetDataFunction.OnServerInvoke = function(player: Player)
    local data = cache[player.UserId]
    if not data then return nil end
    return {
        balance     = data.balance,
        cooldowns   = data.cooldowns,
        inventory   = data.inventory,
        totalOpened = data.totalOpened,
    }
end

-- ---------------------------------------------------------------------------
-- RemoteFunction: OpenPack
-- Deducts price, rolls reward, stores item in inventory — does NOT give cash.
-- Returns the item the player won (including its inventory slot id).
-- ---------------------------------------------------------------------------
OpenPackFunction.OnServerInvoke = function(player: Player, packId: string)
    if type(packId) ~= "string" then
        return { success = false, reason = "Invalid request." }
    end

    local data = cache[player.UserId]
    if not data then
        return { success = false, reason = "Player data not ready. Try again." }
    end

    local pack = PackModule.getPackById(packId)
    if not pack then
        return { success = false, reason = "Pack not found." }
    end

    local canOpen, reason = PackModule.canOpenPack(pack, data.balance, data.cooldowns[packId])
    if not canOpen then
        return { success = false, reason = reason }
    end

    -- Deduct pack price
    if pack.price > 0 then
        data.balance -= pack.price
    end

    -- Record cooldown
    if pack.cooldown > 0 then
        data.cooldowns[packId] = os.time()
    end

    -- Roll reward
    local reward = PackModule.rollReward(pack)

    -- Add item to inventory
    data.nextItemId = (data.nextItemId or 0) + 1
    local itemId = data.nextItemId
    data.inventory[itemId] = {
        name      = reward.name,
        imageId   = reward.imageId,
        sellValue = reward.sellValue,
        rarity    = reward.rarity,
    }

    data.totalOpened += 1

    -- Sync balance (pack price was deducted)
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
-- RemoteFunction: SellItem
-- Removes item from inventory and adds its sellValue to the player's balance.
-- ---------------------------------------------------------------------------
SellItemFunction.OnServerInvoke = function(player: Player, itemId: number)
    if type(itemId) ~= "number" then
        return { success = false, reason = "Invalid item." }
    end

    local data = cache[player.UserId]
    if not data then
        return { success = false, reason = "Player data not ready." }
    end

    local item = data.inventory[itemId]
    if not item then
        return { success = false, reason = "Item not found in inventory." }
    end

    data.balance += item.sellValue
    data.inventory[itemId] = nil

    syncBalance(player)
    task.spawn(saveData, player)

    return {
        success    = true,
        newBalance = data.balance,
        earned     = item.sellValue,
    }
end

-- ---------------------------------------------------------------------------
-- Player lifecycle
-- ---------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
    loadData(player)
    syncBalance(player)
end)

Players.PlayerRemoving:Connect(function(player)
    saveData(player)
    cache[player.UserId] = nil
end)

-- Handle players already present (Studio solo play)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        loadData(player)
        syncBalance(player)
    end)
end

-- Auto-save every 5 minutes
task.spawn(function()
    while true do
        task.wait(300)
        for _, player in ipairs(Players:GetPlayers()) do
            task.spawn(saveData, player)
        end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        saveData(player)
    end
end)
