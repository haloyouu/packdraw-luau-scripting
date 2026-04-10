-- =============================================================================
-- PackConfig  (ModuleScript — ReplicatedStorage)
--
-- THE MAIN CUSTOMIZATION FILE.
-- Add / remove / edit packs and items here. No other file needs to change.
-- =============================================================================

local PackConfig = {}

-- =============================================================================
-- ITEM RARITY DEFINITIONS
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
    -- ── New case tiers ────────────────────────────────────────────────────
    Birkon = {
        displayName    = "BIRKON",
        primaryColor   = Color3.fromRGB(175, 115,  50),
        secondaryColor = Color3.fromRGB(110,  70,  25),
        glowColor      = Color3.fromRGB(230, 165,  80),
        textColor      = Color3.fromRGB(255, 240, 210),
    },
    Patrick = {
        displayName    = "PATRICK",
        primaryColor   = Color3.fromRGB(195, 155,  20),
        secondaryColor = Color3.fromRGB(120,  90,  10),
        glowColor      = Color3.fromRGB(255, 215,  60),
        textColor      = Color3.fromRGB( 30,  20,   0),
    },
    Obsessed = {
        displayName    = "OBSESSED",
        primaryColor   = Color3.fromRGB(180,  25,  25),
        secondaryColor = Color3.fromRGB(100,  10,  10),
        glowColor      = Color3.fromRGB(255,  70,  70),
        textColor      = Color3.fromRGB(255, 220, 220),
    },
    Ageless = {
        displayName    = "AGELESS",
        primaryColor   = Color3.fromRGB(155, 155, 165),
        secondaryColor = Color3.fromRGB( 90,  90, 100),
        glowColor      = Color3.fromRGB(225, 225, 235),
        textColor      = Color3.fromRGB( 20,  20,  30),
    },
    Arthur = {
        displayName    = "ARTHUR",
        primaryColor   = Color3.fromRGB( 28,  50, 115),
        secondaryColor = Color3.fromRGB( 15,  25,  65),
        glowColor      = Color3.fromRGB( 90, 130, 240),
        textColor      = Color3.fromRGB(200, 215, 255),
    },
    Bvlgori = {
        displayName    = "BVLGORI",
        primaryColor   = Color3.fromRGB(115,  20, 140),
        secondaryColor = Color3.fromRGB( 65,  10,  80),
        glowColor      = Color3.fromRGB(200,  80, 230),
        textColor      = Color3.fromRGB(255, 220, 255),
    },
    Miner = {
        displayName    = "MINER",
        primaryColor   = Color3.fromRGB( 30,  95,  55),
        secondaryColor = Color3.fromRGB( 15,  55,  30),
        glowColor      = Color3.fromRGB( 70, 200, 110),
        textColor      = Color3.fromRGB(210, 255, 225),
    },
    Frost = {
        displayName    = "FROST VAULT",
        primaryColor   = Color3.fromRGB( 55, 155, 220),
        secondaryColor = Color3.fromRGB( 25,  90, 140),
        glowColor      = Color3.fromRGB(150, 230, 255),
        textColor      = Color3.fromRGB(  0,  30,  60),
    },
    VanLeaf = {
        displayName    = "VAN LEAF",
        primaryColor   = Color3.fromRGB(215,  75, 135),
        secondaryColor = Color3.fromRGB(140,  40,  85),
        glowColor      = Color3.fromRGB(255, 150, 195),
        textColor      = Color3.fromRGB(255, 240, 248),
    },
    Lavish = {
        displayName    = "LAVISH",
        primaryColor   = Color3.fromRGB(200, 148,  18),
        secondaryColor = Color3.fromRGB(130,  90,   8),
        glowColor      = Color3.fromRGB(255, 210,  65),
        textColor      = Color3.fromRGB( 30,  18,   0),
    },
    IcedOut = {
        displayName    = "ICED OUT",
        primaryColor   = Color3.fromRGB(140, 205, 245),
        secondaryColor = Color3.fromRGB( 80, 145, 195),
        glowColor      = Color3.fromRGB(220, 248, 255),
        textColor      = Color3.fromRGB(  0,  30,  55),
    },
}

-- =============================================================================
-- PACK DEFINITIONS
--
-- Top-level pack fields:
--   id          (string)  Unique ID — do NOT change after launch.
--   name        (string)  Display name in the store.
--   description (string)  Flavour text on the pack card.
--   imageId     (string)  "rbxassetid://..." artwork for the pack.
--   price       (number)  Cost in cash. 0 = free.
--   tier        (string)  Key into PackTiers (controls card colour theme).
--   cooldown    (number)  Seconds between opens. 0 = unlimited. 86400 = 24 h.
--   enabled     (boolean) false hides the pack without removing config.
--
-- Reward item fields (inside `rewards = { … }`):
--   name        (string)  The real-life item the player receives.
--   imageId     (string)  "rbxassetid://..." artwork for the item.
--   sellValue   (number)  How much cash the player gets when they sell it.
--   weight      (number)  Drop weight — higher = more common.
--   rarity      (string)  Key into ItemRarities (badge colour).
-- =============================================================================
PackConfig.Packs = {

    -- =========================================================================
    -- FREE PACK  –  basic everyday items, open once per 24 h
    -- =========================================================================
    {
        id          = "free_pack",
        name        = "Free Pack",
        description = "Open once every 24 h. Real items, real (game) value!",
        imageId     = "rbxassetid://6034871478",
        price       = 0,
        tier        = "Free",
        cooldown    = 86400,
        enabled     = true,
        rewards     = {
            { name = "Used Bicycle",      imageId = "rbxassetid://6034871478", sellValue = 10,  weight = 50, rarity = "Common"    },
            { name = "Vintage Poster",    imageId = "rbxassetid://6034871478", sellValue = 25,  weight = 30, rarity = "Uncommon"  },
            { name = "Old Skateboard",    imageId = "rbxassetid://6034871478", sellValue = 50,  weight = 14, rarity = "Rare"      },
            { name = "Retro Game Console",imageId = "rbxassetid://6034871478", sellValue = 150, weight = 5,  rarity = "Epic"      },
            { name = "Signed Jersey",     imageId = "rbxassetid://6034871478", sellValue = 500, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- RARE PACK  –  consumer electronics & gear
    -- =========================================================================
    {
        id          = "rare_pack",
        name        = "Rare Pack",
        description = "Consumer tech and gear. Better odds, better hauls.",
        imageId     = "rbxassetid://6034871478",
        price       = 500,
        tier        = "Rare",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Smartphone",      imageId = "rbxassetid://6034871478", sellValue = 100,  weight = 40, rarity = "Uncommon"  },
            { name = "Gaming Chair",    imageId = "rbxassetid://6034871478", sellValue = 250,  weight = 30, rarity = "Rare"      },
            { name = "Designer Sneakers",imageId = "rbxassetid://6034871478", sellValue = 600,  weight = 18, rarity = "Rare"      },
            { name = "Gaming PC Setup", imageId = "rbxassetid://6034871478", sellValue = 1500, weight = 10, rarity = "Epic"      },
            { name = "Dirt Bike",       imageId = "rbxassetid://6034871478", sellValue = 5000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- EPIC PACK  –  luxury goods and sports cars
    -- =========================================================================
    {
        id          = "epic_pack",
        name        = "Epic Pack",
        description = "Luxury goods and sports cars. Epic drops guaranteed.",
        imageId     = "rbxassetid://6034871478",
        price       = 2000,
        tier        = "Epic",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Electric Scooter", imageId = "rbxassetid://6034871478", sellValue = 500,   weight = 35, rarity = "Rare"      },
            { name = "MacBook Pro",      imageId = "rbxassetid://6034871478", sellValue = 1000,  weight = 30, rarity = "Rare"      },
            { name = "Rolex Submariner", imageId = "rbxassetid://6034871478", sellValue = 3000,  weight = 20, rarity = "Epic"      },
            { name = "Audemars Piguet",  imageId = "rbxassetid://6034871478", sellValue = 8000,  weight = 12, rarity = "Epic"      },
            { name = "Porsche 911",      imageId = "rbxassetid://6034871478", sellValue = 25000, weight = 3,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- LEGENDARY PACK  –  supercars, helicopters, yachts
    -- =========================================================================
    {
        id          = "legendary_pack",
        name        = "Legendary Pack",
        description = "Supercars, helicopters, yachts. The ultimate haul.",
        imageId     = "rbxassetid://6034871478",
        price       = 10000,
        tier        = "Legendary",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Ferrari 458",         imageId = "rbxassetid://6034871478", sellValue = 5000,   weight = 30, rarity = "Rare"      },
            { name = "Lamborghini Huracan", imageId = "rbxassetid://6034871478", sellValue = 12000,  weight = 28, rarity = "Epic"      },
            { name = "Private Helicopter",  imageId = "rbxassetid://6034871478", sellValue = 30000,  weight = 22, rarity = "Epic"      },
            { name = "Bugatti Chiron",      imageId = "rbxassetid://6034871478", sellValue = 75000,  weight = 15, rarity = "Legendary" },
            { name = "Private Yacht",       imageId = "rbxassetid://6034871478", sellValue = 250000, weight = 5,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- GOLD PACK  –  gold jewellery and bullion
    -- =========================================================================
    {
        id          = "gold_pack",
        name        = "Gold Pack",
        description = "Gold jewellery and bullion. Gilded riches await.",
        imageId     = "rbxassetid://6034871478",
        price       = 3000,
        tier        = "Gold",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Gold Ring",     imageId = "rbxassetid://6034871478", sellValue = 750,   weight = 40, rarity = "Uncommon"  },
            { name = "Gold Bracelet", imageId = "rbxassetid://6034871478", sellValue = 2000,  weight = 30, rarity = "Rare"      },
            { name = "Gold Necklace", imageId = "rbxassetid://6034871478", sellValue = 5000,  weight = 18, rarity = "Epic"      },
            { name = "Gold Watch",    imageId = "rbxassetid://6034871478", sellValue = 15000, weight = 10, rarity = "Epic"      },
            { name = "Gold Bar",      imageId = "rbxassetid://6034871478", sellValue = 50000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- DIAMOND PACK  –  diamond jewellery
    -- =========================================================================
    {
        id          = "diamond_pack",
        name        = "Diamond Pack",
        description = "Diamond jewellery. Only the finest rewards inside.",
        imageId     = "rbxassetid://6034871478",
        price       = 7500,
        tier        = "Diamond",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Diamond Earrings", imageId = "rbxassetid://6034871478", sellValue = 2500,   weight = 35, rarity = "Rare"      },
            { name = "Diamond Ring",     imageId = "rbxassetid://6034871478", sellValue = 6000,   weight = 28, rarity = "Rare"      },
            { name = "Diamond Necklace", imageId = "rbxassetid://6034871478", sellValue = 15000,  weight = 20, rarity = "Epic"      },
            { name = "Diamond Watch",    imageId = "rbxassetid://6034871478", sellValue = 40000,  weight = 12, rarity = "Legendary" },
            { name = "Diamond Crown",    imageId = "rbxassetid://6034871478", sellValue = 120000, weight = 5,  rarity = "Legendary" },
        },
    },
}

return PackConfig
