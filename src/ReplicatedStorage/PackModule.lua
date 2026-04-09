-- =============================================================================
-- PackModule  (ModuleScript — ReplicatedStorage)
--
-- Shared logic used by both the server and the client.
-- Do not put game-specific configuration here; use PackConfig instead.
-- =============================================================================

local PackConfig = require(script.Parent.PackConfig)

local PackModule = {}

-- ---------------------------------------------------------------------------
-- Utility: comma-format a number  (1234567 → "1,234,567")
-- ---------------------------------------------------------------------------
function PackModule.formatNumber(n: number): string
    local s = tostring(math.floor(n))
    local result = ""
    local len = #s
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then
            result ..= ","
        end
        result ..= s:sub(i, i)
    end
    return result
end

-- ---------------------------------------------------------------------------
-- Roll a reward from `pack` using weighted random selection.
-- Returns one reward table from pack.rewards.
-- ---------------------------------------------------------------------------
function PackModule.rollReward(pack)
    local rewards = pack.rewards
    local totalWeight = 0
    for _, reward in ipairs(rewards) do
        totalWeight += reward.weight
    end

    local roll = math.random(1, totalWeight)
    local cumulative = 0
    for _, reward in ipairs(rewards) do
        cumulative += reward.weight
        if roll <= cumulative then
            return reward
        end
    end
    return rewards[#rewards] -- unreachable fallback
end

-- ---------------------------------------------------------------------------
-- Look up a pack by its unique string id.
-- Returns the pack table, or nil if not found.
-- ---------------------------------------------------------------------------
function PackModule.getPackById(packId: string)
    for _, pack in ipairs(PackConfig.Packs) do
        if pack.id == packId then
            return pack
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Return a list of all packs with enabled = true.
-- ---------------------------------------------------------------------------
function PackModule.getEnabledPacks()
    local result = {}
    for _, pack in ipairs(PackConfig.Packs) do
        if pack.enabled then
            table.insert(result, pack)
        end
    end
    return result
end

-- ---------------------------------------------------------------------------
-- Convenience accessors for config sub-tables.
-- ---------------------------------------------------------------------------
function PackModule.getItemRarity(rarityKey: string)
    return PackConfig.ItemRarities[rarityKey] or PackConfig.ItemRarities.Common
end

function PackModule.getPackTier(tierKey: string)
    return PackConfig.PackTiers[tierKey] or PackConfig.PackTiers.Free
end

-- ---------------------------------------------------------------------------
-- Compute per-item drop-chance percentages for a pack (UI display only).
-- Returns: { { name, rarity, chance }, … }
-- ---------------------------------------------------------------------------
function PackModule.getDropChances(pack)
    local total = 0
    for _, r in ipairs(pack.rewards) do total += r.weight end

    local out = {}
    for _, r in ipairs(pack.rewards) do
        table.insert(out, {
            name   = r.name,
            rarity = r.rarity,
            chance = (r.weight / total) * 100,
        })
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Validate whether a player may open a pack right now.
-- `balance`       – player's current coin count
-- `lastOpenTime`  – os.time() timestamp of their last open (or nil)
--
-- Returns: canOpen (bool), reason (string)
-- ---------------------------------------------------------------------------
function PackModule.canOpenPack(pack, balance: number, lastOpenTime: number?)
    if not pack.enabled then
        return false, "This pack is currently unavailable."
    end

    if pack.price > 0 and balance < pack.price then
        return false,
            string.format("You need $%s. You have $%s.",
                PackModule.formatNumber(pack.price),
                PackModule.formatNumber(balance))
    end

    if pack.cooldown > 0 and lastOpenTime then
        local elapsed = os.time() - lastOpenTime
        if elapsed < pack.cooldown then
            local rem = pack.cooldown - elapsed
            return false, string.format("Available in %02d:%02d:%02d",
                math.floor(rem / 3600),
                math.floor((rem % 3600) / 60),
                rem % 60)
        end
    end

    return true, ""
end

-- ---------------------------------------------------------------------------
-- Format a cooldown remaining time as "HH:MM:SS", given a lastOpenTime and
-- cooldown duration. Returns nil if not on cooldown.
-- ---------------------------------------------------------------------------
function PackModule.getCooldownString(pack, lastOpenTime: number?): string?
    if pack.cooldown <= 0 or not lastOpenTime then return nil end
    local elapsed = os.time() - lastOpenTime
    if elapsed >= pack.cooldown then return nil end
    local rem = pack.cooldown - elapsed
    return string.format("%02d:%02d:%02d",
        math.floor(rem / 3600),
        math.floor((rem % 3600) / 60),
        rem % 60)
end

return PackModule
