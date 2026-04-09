-- =============================================================================
-- PackServer  (Script — ServerScriptService)
--
-- Authoritative server script.
-- Owns player data (balance + cooldowns), validates every pack-open request,
-- grants rewards, and persists data via DataStoreService.
-- =============================================================================

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local DataStoreService   = game:GetService("DataStoreService")

local PackModule = require(ReplicatedStorage:WaitForChild("PackModule"))

-- Remotes (created by Rojo / project.json at startup)
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local OpenPackFunction  = Remotes:WaitForChild("OpenPack")   :: RemoteFunction
local GetDataFunction   = Remotes:WaitForChild("GetData")    :: RemoteFunction
local UpdateBalanceEvent= Remotes:WaitForChild("UpdateBalance") :: RemoteEvent

-- DataStore – bump version suffix if you wipe saves intentionally
local Store = DataStoreService:GetDataStore("PackDraw_v1")

-- In-memory cache:  [UserId] = { balance, cooldowns, totalOpened }
local cache: { [number]: { balance: number, cooldowns: { [string]: number }, totalOpened: number } } = {}

-- ---------------------------------------------------------------------------
-- Default data for a brand-new player
-- ---------------------------------------------------------------------------
local function defaultData()
    return {
        balance     = 1000,  -- starting coins (adjust freely)
        cooldowns   = {},    -- [packId] = unix timestamp of last open
        totalOpened = 0,
    }
end

-- ---------------------------------------------------------------------------
-- Load + merge with defaults (safe against new keys added to defaultData)
-- ---------------------------------------------------------------------------
local function loadData(player: Player)
    local ok, stored = pcall(function()
        return Store:GetAsync(tostring(player.UserId))
    end)

    local data = defaultData()
    if ok and type(stored) == "table" then
        -- Merge stored values over defaults (handles new fields gracefully)
        for k, v in pairs(stored) do
            data[k] = v
        end
    elseif not ok then
        warn("[PackServer] DataStore load failed for", player.Name, "— using defaults.")
    end

    cache[player.UserId] = data

    -- Create leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name  = "Coins"
    coins.Value = data.balance
    coins.Parent = leaderstats
end

-- ---------------------------------------------------------------------------
-- Persist a player's current cache to the DataStore
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
-- Push the current balance to leaderstats and fire the client event
-- ---------------------------------------------------------------------------
local function syncBalance(player: Player)
    local data = cache[player.UserId]
    if not data then return end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local coins = ls:FindFirstChild("Coins")
        if coins then coins.Value = data.balance end
    end

    UpdateBalanceEvent:FireClient(player, data.balance)
end

-- ---------------------------------------------------------------------------
-- RemoteFunction: GetData
-- Returns a safe copy of the player's data for the client.
-- ---------------------------------------------------------------------------
GetDataFunction.OnServerInvoke = function(player: Player)
    local data = cache[player.UserId]
    if not data then return nil end
    return {
        balance     = data.balance,
        cooldowns   = data.cooldowns,
        totalOpened = data.totalOpened,
    }
end

-- ---------------------------------------------------------------------------
-- RemoteFunction: OpenPack
-- The only place rewards are rolled and granted — always server-authoritative.
-- ---------------------------------------------------------------------------
OpenPackFunction.OnServerInvoke = function(player: Player, packId: string)
    -- Basic type guard
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

    local lastOpen = data.cooldowns[packId]
    local canOpen, reason = PackModule.canOpenPack(pack, data.balance, lastOpen)
    if not canOpen then
        return { success = false, reason = reason }
    end

    -- Deduct price
    if pack.price > 0 then
        data.balance -= pack.price
    end

    -- Record cooldown timestamp (for free / limited packs)
    if pack.cooldown > 0 then
        data.cooldowns[packId] = os.time()
    end

    -- Roll reward
    local reward = PackModule.rollReward(pack)

    -- Grant reward
    data.balance    += reward.moneyAmount
    data.totalOpened += 1

    -- Sync client display
    syncBalance(player)

    -- Fire-and-forget save
    task.spawn(saveData, player)

    return {
        success = true,
        reward = {
            name        = reward.name,
            imageId     = reward.imageId,
            moneyAmount = reward.moneyAmount,
            rarity      = reward.rarity,
        },
        newBalance = data.balance,
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

-- Bind on close (final save attempt before shutdown)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        saveData(player)
    end
end)
