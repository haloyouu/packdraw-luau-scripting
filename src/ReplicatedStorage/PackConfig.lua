-- =============================================================================
-- PackConfig  (ModuleScript — ReplicatedStorage)
--
-- THE MAIN CUSTOMIZATION FILE.
-- Add / remove / edit packs and items here. No other file needs to change.
-- =============================================================================

local PackConfig = {}

-- =============================================================================
-- ITEM RARITY DEFINITIONS
-- Controls badge colors on reward reveal.
-- Add new keys here and use them in any reward's `rarity` field below.
-- =============================================================================
PackConfig.ItemRarities = {
    Common = {
        displayName = "Common",
        color       = Color3.fromRGB(180, 180, 180),
    },
    Uncommon = {
        displayName = "Uncommon",
        color       = Color3.fromRGB(30,  200,  30),
    },
    Rare = {
        displayName = "Rare",
        color       = Color3.fromRGB(0,  112, 221),
    },
    Epic = {
        displayName = "Epic",
        color       = Color3.fromRGB(163,  53, 238),
    },
    Legendary = {
        displayName = "Legendary",
        color       = Color3.fromRGB(255, 140,   0),
    },
}

-- =============================================================================
-- PACK TIER / THEME DEFINITIONS
-- Each tier has its own color scheme for the store card.
-- Add new themes here and reference them with the `tier` key on a pack.
--
--   displayName   – label shown on the tier badge
--   primaryColor  – main accent (stripe, button, glow border)
--   secondaryColor– darker shade for backgrounds
--   glowColor     – bright highlight shown during the reveal animation
--   textColor     – text drawn on top of primaryColor
-- =============================================================================
PackConfig.PackTiers = {
    Free = {
        displayName    = "FREE",
        primaryColor   = Color3.fromRGB( 80, 200,  80),
        secondaryColor = Color3.fromRGB( 40, 120,  40),
        glowColor      = Color3.fromRGB(130, 255, 130),
        textColor      = Color3.fromRGB(255, 255, 255),
    },
    Rare = {
        displayName    = "RARE",
        primaryColor   = Color3.fromRGB(  0, 112, 221),
        secondaryColor = Color3.fromRGB(  0,  60, 140),
        glowColor      = Color3.fromRGB( 50, 180, 255),
        textColor      = Color3.fromRGB(255, 255, 255),
    },
    Epic = {
        displayName    = "EPIC",
        primaryColor   = Color3.fromRGB(163,  53, 238),
        secondaryColor = Color3.fromRGB( 90,  20, 140),
        glowColor      = Color3.fromRGB(200, 100, 255),
        textColor      = Color3.fromRGB(255, 255, 255),
    },
    Legendary = {
        displayName    = "LEGENDARY",
        primaryColor   = Color3.fromRGB(255, 140,   0),
        secondaryColor = Color3.fromRGB(180,  80,   0),
        glowColor      = Color3.fromRGB(255, 220,  50),
        textColor      = Color3.fromRGB(255, 255, 255),
    },
    Gold = {
        displayName    = "GOLD",
        primaryColor   = Color3.fromRGB(212, 175,  55),
        secondaryColor = Color3.fromRGB(140, 110,  20),
        glowColor      = Color3.fromRGB(255, 235, 100),
        textColor      = Color3.fromRGB( 40,  20,   0),
    },
    Diamond = {
        displayName    = "DIAMOND",
        primaryColor   = Color3.fromRGB(185, 242, 255),
        secondaryColor = Color3.fromRGB(100, 200, 230),
        glowColor      = Color3.fromRGB(220, 255, 255),
        textColor      = Color3.fromRGB(  0,  50,  80),
    },
}

-- =============================================================================
-- PACK DEFINITIONS
-- Each entry in this table is one pack shown in the store.
--
-- Top-level pack fields
-- ─────────────────────
--   id          (string)  Unique identifier. DO NOT change after launch —
--                         it is used as the DataStore key for cooldowns.
--   name        (string)  Display name on the store card.
--   description (string)  Short flavour text on the card.
--   imageId     (string)  "rbxassetid://..." artwork for the pack.
--   price       (number)  Cost in coins. 0 = free to open.
--   tier        (string)  Key into PackTiers above (sets card colour theme).
--   cooldown    (number)  Seconds the player must wait between opens.
--                         0 = unlimited. 86400 = 24 hours.
--   enabled     (boolean) false hides the pack without deleting config.
--
-- Reward item fields (inside `rewards = { … }`)
-- ─────────────────────────────────────────────
--   name        (string)  Display name shown on the reward card.
--   imageId     (string)  "rbxassetid://..." artwork for the reward.
--   moneyAmount (number)  Cash granted to the player on winning this item.
--   weight      (number)  Drop weight. Higher = more common.
--                         E.g. weight=50 is 50× more likely than weight=1.
--   rarity      (string)  Key into ItemRarities above (badge colour).
-- =============================================================================
PackConfig.Packs = {

    -- =========================================================================
    -- FREE PACK
    -- =========================================================================
    {
        id          = "free_pack",
        name        = "Free Pack",
        description = "Open once every 24 h. A free taste of the draw!",
        imageId     = "rbxassetid://6034871478",
        price       = 0,
        tier        = "Free",
        cooldown    = 86400,
        enabled     = true,
        rewards     = {
            { name = "$10",  imageId = "rbxassetid://6034871478", moneyAmount = 10,  weight = 50, rarity = "Common"    },
            { name = "$25",  imageId = "rbxassetid://6034871478", moneyAmount = 25,  weight = 30, rarity = "Uncommon"  },
            { name = "$50",  imageId = "rbxassetid://6034871478", moneyAmount = 50,  weight = 14, rarity = "Rare"      },
            { name = "$150", imageId = "rbxassetid://6034871478", moneyAmount = 150, weight = 5,  rarity = "Epic"      },
            { name = "$500", imageId = "rbxassetid://6034871478", moneyAmount = 500, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- RARE PACK
    -- =========================================================================
    {
        id          = "rare_pack",
        name        = "Rare Pack",
        description = "Improved drop rates. Worth every coin.",
        imageId     = "rbxassetid://6034871478",
        price       = 500,
        tier        = "Rare",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "$100",  imageId = "rbxassetid://6034871478", moneyAmount = 100,  weight = 40, rarity = "Uncommon"  },
            { name = "$250",  imageId = "rbxassetid://6034871478", moneyAmount = 250,  weight = 30, rarity = "Rare"      },
            { name = "$600",  imageId = "rbxassetid://6034871478", moneyAmount = 600,  weight = 18, rarity = "Rare"      },
            { name = "$1,500", imageId = "rbxassetid://6034871478", moneyAmount = 1500, weight = 10, rarity = "Epic"      },
            { name = "$5,000", imageId = "rbxassetid://6034871478", moneyAmount = 5000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- EPIC PACK
    -- =========================================================================
    {
        id          = "epic_pack",
        name        = "Epic Pack",
        description = "High-value rewards. Epic & Legendary chances boosted.",
        imageId     = "rbxassetid://6034871478",
        price       = 2000,
        tier        = "Epic",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "$500",    imageId = "rbxassetid://6034871478", moneyAmount = 500,   weight = 35, rarity = "Rare"      },
            { name = "$1,000",  imageId = "rbxassetid://6034871478", moneyAmount = 1000,  weight = 30, rarity = "Rare"      },
            { name = "$3,000",  imageId = "rbxassetid://6034871478", moneyAmount = 3000,  weight = 20, rarity = "Epic"      },
            { name = "$8,000",  imageId = "rbxassetid://6034871478", moneyAmount = 8000,  weight = 12, rarity = "Epic"      },
            { name = "$25,000", imageId = "rbxassetid://6034871478", moneyAmount = 25000, weight = 3,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- LEGENDARY PACK
    -- =========================================================================
    {
        id          = "legendary_pack",
        name        = "Legendary Pack",
        description = "The ultimate pack. Massive rewards and real prestige.",
        imageId     = "rbxassetid://6034871478",
        price       = 10000,
        tier        = "Legendary",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "$5,000",   imageId = "rbxassetid://6034871478", moneyAmount = 5000,   weight = 30, rarity = "Rare"      },
            { name = "$12,000",  imageId = "rbxassetid://6034871478", moneyAmount = 12000,  weight = 28, rarity = "Epic"      },
            { name = "$30,000",  imageId = "rbxassetid://6034871478", moneyAmount = 30000,  weight = 22, rarity = "Epic"      },
            { name = "$75,000",  imageId = "rbxassetid://6034871478", moneyAmount = 75000,  weight = 15, rarity = "Legendary" },
            { name = "$250,000", imageId = "rbxassetid://6034871478", moneyAmount = 250000, weight = 5,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- GOLD PACK  (theme pack)
    -- =========================================================================
    {
        id          = "gold_pack",
        name        = "Gold Pack",
        description = "Gilded riches await. Fortune favors the bold.",
        imageId     = "rbxassetid://6034871478",
        price       = 3000,
        tier        = "Gold",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "$750 Gold",   imageId = "rbxassetid://6034871478", moneyAmount = 750,   weight = 40, rarity = "Uncommon"  },
            { name = "$2,000 Gold", imageId = "rbxassetid://6034871478", moneyAmount = 2000,  weight = 30, rarity = "Rare"      },
            { name = "$5,000 Gold", imageId = "rbxassetid://6034871478", moneyAmount = 5000,  weight = 18, rarity = "Epic"      },
            { name = "$15,000 Gold",imageId = "rbxassetid://6034871478", moneyAmount = 15000, weight = 10, rarity = "Epic"      },
            { name = "$50,000 Gold",imageId = "rbxassetid://6034871478", moneyAmount = 50000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- DIAMOND PACK  (theme pack)
    -- =========================================================================
    {
        id          = "diamond_pack",
        name        = "Diamond Pack",
        description = "Crystalline perfection. Only the finest rewards inside.",
        imageId     = "rbxassetid://6034871478",
        price       = 7500,
        tier        = "Diamond",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "2500 Diamonds",   imageId = "rbxassetid://6034871478", moneyAmount = 2500,   weight = 35, rarity = "Rare"      },
            { name = "6000 Diamonds",   imageId = "rbxassetid://6034871478", moneyAmount = 6000,   weight = 28, rarity = "Rare"      },
            { name = "15000 Diamonds",  imageId = "rbxassetid://6034871478", moneyAmount = 15000,  weight = 20, rarity = "Epic"      },
            { name = "40000 Diamonds",  imageId = "rbxassetid://6034871478", moneyAmount = 40000,  weight = 12, rarity = "Legendary" },
            { name = "120000 Diamonds", imageId = "rbxassetid://6034871478", moneyAmount = 120000, weight = 5,  rarity = "Legendary" },
        },
    },
}

return PackConfig
