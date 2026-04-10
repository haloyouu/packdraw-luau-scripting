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
    -- ── Image-based case tiers ────────────────────────────────────────────
    GenWealth = {
        displayName    = "GENERATIONAL WEALTH",
        primaryColor   = Color3.fromRGB(158,  18,  28),
        secondaryColor = Color3.fromRGB( 88,   8,  14),
        glowColor      = Color3.fromRGB(255,  58,  58),
        textColor      = Color3.fromRGB(255, 220, 220),
    },
    BigLeague = {
        displayName    = "BIG LEAGUE",
        primaryColor   = Color3.fromRGB(182, 146,  26),
        secondaryColor = Color3.fromRGB( 98,  76,  10),
        glowColor      = Color3.fromRGB(255, 218,  72),
        textColor      = Color3.fromRGB( 20,  14,   0),
    },
    Desire = {
        displayName    = "DESIRE",
        primaryColor   = Color3.fromRGB(218,  74,  16),
        secondaryColor = Color3.fromRGB(132,  36,   8),
        glowColor      = Color3.fromRGB(255, 142,  48),
        textColor      = Color3.fromRGB(255, 238, 220),
    },
    Bravery = {
        displayName    = "BRAVERY",
        primaryColor   = Color3.fromRGB( 16, 136, 156),
        secondaryColor = Color3.fromRGB(  8,  76,  96),
        glowColor      = Color3.fromRGB( 52, 224, 244),
        textColor      = Color3.fromRGB(220, 255, 255),
    },
    RollsRoyce = {
        displayName    = "ROLLS ROYCE",
        primaryColor   = Color3.fromRGB(202, 202, 218),
        secondaryColor = Color3.fromRGB(128, 128, 148),
        glowColor      = Color3.fromRGB(245, 245, 255),
        textColor      = Color3.fromRGB( 18,  18,  38),
    },
}

-- =============================================================================
-- PACK DEFINITIONS
--
-- Weight guide (steeper = rarer legendary relative to pack price):
--   ∞  ratio (free pack)      → legendary weight 1
--   ~10x ratio ($500 pack)    → legendary weight 2
--   ~12x ratio ($2k pack)     → legendary weight 2
--   ~17x ratio ($3k pack)     → legendary weight 1
--   ~25x ratio ($10k pack)    → legendary weight 1 (yacht) / 8 (Bugratti)
--   30x+ ratio (new cases)    → legendary weight 1, epics ≤ 4
-- =============================================================================
PackConfig.Packs = {

    -- =========================================================================
    -- FREE PACK  –  open once per 24 h
    -- Legendary ($500) is effectively infinite ratio vs price ($0) → weight 1
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
            { name = "Used Bicycle",      imageId = "rbxassetid://129581269",       sellValue = 10,  weight = 50, rarity = "Common"    },
            { name = "Vintage Poster",    imageId = "rbxassetid://6175214243",      sellValue = 25,  weight = 30, rarity = "Uncommon"  },
            { name = "Old Skateboard",    imageId = "rbxassetid://129581269",       sellValue = 50,  weight = 14, rarity = "Rare"      },
            { name = "Retro Game Console",imageId = "rbxassetid://72555931276894",  sellValue = 150, weight = 5,  rarity = "Epic"      },
            { name = "Signed Jersey",     imageId = "rbxassetid://12014860760",     sellValue = 500, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- RARE PACK  –  consumer electronics & gear
    -- Dirt Bike ($5k) in $500 pack = 10x ratio → legendary weight 2
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
            { name = "Smartphone",       imageId = "rbxassetid://2683970547",       sellValue = 100,  weight = 42, rarity = "Uncommon"  },
            { name = "Gaming Chair",     imageId = "rbxassetid://116336938089060",  sellValue = 250,  weight = 22, rarity = "Rare"      },
            { name = "Designer Sneakers",imageId = "rbxassetid://83420334893740",   sellValue = 600,  weight = 14, rarity = "Rare"      },
            { name = "Gaming PC Setup",  imageId = "rbxassetid://79915626369911",   sellValue = 1500, weight = 8,  rarity = "Epic"      },
            { name = "Dirt Bike",        imageId = "rbxassetid://80524967222557",   sellValue = 5000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- EPIC PACK  –  luxury goods and sports cars
    -- Porsche ($25k) in $2k pack = 12.5x ratio → legendary weight 2
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
            { name = "Electric Scooter",  imageId = "rbxassetid://713583389",         sellValue = 500,   weight = 40, rarity = "Rare"      },
            { name = "MackBook Pro",      imageId = "rbxassetid://18151538607",        sellValue = 1000,  weight = 28, rarity = "Rare"      },
            { name = "Rolez Submariner",  imageId = "rbxassetid://113378471023632",    sellValue = 3000,  weight = 16, rarity = "Epic"      },
            { name = "Audemares Pigeont", imageId = "rbxassetid://115622973392208",    sellValue = 8000,  weight = 8,  rarity = "Epic"      },
            { name = "Porsche 911",       imageId = "rbxassetid://71089144666318",     sellValue = 25000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- LEGENDARY PACK  –  supercars, helicopters, yachts
    -- Yacht ($250k) in $10k pack = 25x ratio → weight 1
    -- Bugratti ($75k) = 7.5x → weight 8 (still feels rare but catchable)
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
            { name = "Rari 458",           imageId = "rbxassetid://6034871478", sellValue = 5000,   weight = 42, rarity = "Rare"      },
            { name = "Lamborgher Huracam", imageId = "rbxassetid://6034871478", sellValue = 12000,  weight = 26, rarity = "Epic"      },
            { name = "Private Helicopter", imageId = "rbxassetid://6034871478", sellValue = 30000,  weight = 18, rarity = "Epic"      },
            { name = "Bugratti Chirton",   imageId = "rbxassetid://6034871478", sellValue = 75000,  weight = 8,  rarity = "Legendary" },
            { name = "Private Yacht",      imageId = "rbxassetid://6034871478", sellValue = 250000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- GOLD PACK  –  gold jewellery and bullion
    -- Gold Bar ($50k) in $3k pack = 17x ratio → weight 1
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
            { name = "Gold Ring",     imageId = "rbxassetid://6034871478", sellValue = 750,   weight = 46, rarity = "Uncommon"  },
            { name = "Gold Bracelet", imageId = "rbxassetid://6034871478", sellValue = 2000,  weight = 28, rarity = "Rare"      },
            { name = "Gold Necklace", imageId = "rbxassetid://6034871478", sellValue = 5000,  weight = 16, rarity = "Epic"      },
            { name = "Gold Watch",    imageId = "rbxassetid://6034871478", sellValue = 15000, weight = 6,  rarity = "Epic"      },
            { name = "Gold Bar",      imageId = "rbxassetid://6034871478", sellValue = 50000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- DIAMOND PACK  –  diamond jewellery
    -- Diamond Crown ($120k) in $7.5k pack = 16x ratio → weight 2
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
            { name = "Diamond Earrings", imageId = "rbxassetid://6034871478",           sellValue = 2500,   weight = 40, rarity = "Rare"      },
            { name = "Diamond Ring",     imageId = "rbxassetid://6034871478",           sellValue = 6000,   weight = 28, rarity = "Rare"      },
            { name = "Diamond Necklace", imageId = "rbxassetid://6034871478",           sellValue = 15000,  weight = 18, rarity = "Epic"      },
            { name = "Diamond Watch",    imageId = "rbxassetid://135484245577291",      sellValue = 40000,  weight = 8,  rarity = "Legendary" },
            { name = "Diamond Crown",    imageId = "rbxassetid://6034871478",           sellValue = 120000, weight = 2,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- GENERATIONAL WEALTH  –  supercars, G-Wagons, heirloom watches
    -- Rainbow AD ($300k) in $8k pack = 37.5x ratio → weight 1
    -- Epics capped at 4/3, Rares at 8/6
    -- =========================================================================
    {
        id          = "genwealth_pack",
        name        = "Generational Wealth",
        description = "C-Wagons, Ferraris, and watches worth more than your house.",
        imageId     = "rbxassetid://6034871478",
        price       = 8000,
        tier        = "GenWealth",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Luxury Gold Pen Set",       imageId = "rbxassetid://6034871478", sellValue = 800,    weight = 26, rarity = "Common"    },
            { name = "Carbon Fibre Wallet",       imageId = "rbxassetid://6034871478", sellValue = 600,    weight = 22, rarity = "Common"    },
            { name = "AD Royal Oak Strap",        imageId = "rbxassetid://6034871478", sellValue = 3500,   weight = 14, rarity = "Uncommon"  },
            { name = "C-Wagon Scale Model",       imageId = "rbxassetid://6034871478", sellValue = 2500,   weight = 11, rarity = "Uncommon"  },
            { name = "Audemares Pigeont Royal Oak",imageId = "rbxassetid://6034871478",sellValue = 18000,  weight = 8,  rarity = "Rare"      },
            { name = "Rari SF90 Stradale",        imageId = "rbxassetid://6034871478", sellValue = 35000,  weight = 6,  rarity = "Rare"      },
            { name = "Nercedes G63 AMG",          imageId = "rbxassetid://6034871478", sellValue = 55000,  weight = 4,  rarity = "Epic"      },
            { name = "C-Wagon Drabus 800",        imageId = "rbxassetid://6034871478", sellValue = 90000,  weight = 3,  rarity = "Epic"      },
            { name = "Rainbow AD Offshore",       imageId = "rbxassetid://6034871478", sellValue = 300000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- BIG LEAGUE  –  tourbillon watches and Cadiolac Escalades
    -- Astronomia ($180k) in $5k pack = 36x ratio → weight 1
    -- =========================================================================
    {
        id          = "bigleague_pack",
        name        = "Big League",
        description = "Elite tourbillons and the biggest SUVs on the road.",
        imageId     = "rbxassetid://6034871478",
        price       = 5000,
        tier        = "BigLeague",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Designer Leather Briefcase", imageId = "rbxassetid://6034871478", sellValue = 700,    weight = 26, rarity = "Common"    },
            { name = "Gold Tie Bar",               imageId = "rbxassetid://6034871478", sellValue = 500,    weight = 22, rarity = "Common"    },
            { name = "Cadiolac CT5 Watch",         imageId = "rbxassetid://6034871478", sellValue = 2500,   weight = 14, rarity = "Uncommon"  },
            { name = "Solid Gold Cufflinks",       imageId = "rbxassetid://6034871478", sellValue = 2000,   weight = 11, rarity = "Uncommon"  },
            { name = "Cadiolac Escalade",          imageId = "rbxassetid://6034871478", sellValue = 12000,  weight = 8,  rarity = "Rare"      },
            { name = "Jacob & Ko Tourbillon",      imageId = "rbxassetid://6034871478", sellValue = 15000,  weight = 6,  rarity = "Rare"      },
            { name = "Richard Million RM 011",     imageId = "rbxassetid://6034871478", sellValue = 45000,  weight = 4,  rarity = "Epic"      },
            { name = "Cadiolac Escalade ESV Black",imageId = "rbxassetid://6034871478", sellValue = 38000,  weight = 3,  rarity = "Epic"      },
            { name = "Jacob & Ko Astronomia",      imageId = "rbxassetid://6034871478", sellValue = 180000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- DESIRE  –  jewellery, tourbillons, and BMRs
    -- Full VVS Set ($200k) in $6k pack = 33x ratio → weight 1
    -- =========================================================================
    {
        id          = "desire_pack",
        name        = "Desire",
        description = "Exquisite jewellery, rare watches, and the BMR of your dreams.",
        imageId     = "rbxassetid://6034871478",
        price       = 6000,
        tier        = "Desire",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Pearl Necklace",             imageId = "rbxassetid://6034871478", sellValue = 800,    weight = 26, rarity = "Common"    },
            { name = "Silver Diamond Pendant",     imageId = "rbxassetid://6034871478", sellValue = 600,    weight = 22, rarity = "Common"    },
            { name = "Diamond Cluster Pendant",    imageId = "rbxassetid://6034871478", sellValue = 4000,   weight = 14, rarity = "Uncommon"  },
            { name = "BMR M8 Competition",         imageId = "rbxassetid://6034871478", sellValue = 10000,  weight = 11, rarity = "Uncommon"  },
            { name = "Shopard Happy Diamonds",     imageId = "rbxassetid://6034871478", sellValue = 12000,  weight = 8,  rarity = "Rare"      },
            { name = "BMR M5 CS",                  imageId = "rbxassetid://6034871478", sellValue = 14000,  weight = 6,  rarity = "Rare"      },
            { name = "Diamond Tennis Necklace",    imageId = "rbxassetid://6034871478", sellValue = 40000,  weight = 4,  rarity = "Epic"      },
            { name = "Jacob & Ko Fleur de Jardin", imageId = "rbxassetid://6034871478", sellValue = 50000,  weight = 3,  rarity = "Epic"      },
            { name = "Full VVS Diamond Set",       imageId = "rbxassetid://6034871478", sellValue = 200000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- BRAVERY  –  luxury SUVs, vintage whisky, rare flowers
    -- Mountain Estate ($120k) in $3.5k pack = 34x ratio — STEEPEST curve here
    -- Epics at 3/2, Rares at 7/5, Legendaries at 1
    -- =========================================================================
    {
        id          = "bravery_pack",
        name        = "Bravery",
        description = "Rare whisky, orchid collections, and bold SUVs for the fearless.",
        imageId     = "rbxassetid://6034871478",
        price       = 3500,
        tier        = "Bravery",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Rare Orchid Arrangement",       imageId = "rbxassetid://6034871478", sellValue = 400,    weight = 30, rarity = "Common"    },
            { name = "Premium Cola Bottle",           imageId = "rbxassetid://6034871478", sellValue = 300,    weight = 26, rarity = "Common"    },
            { name = "Cola Barrel (25 yr)",           imageId = "rbxassetid://6034871478", sellValue = 2000,   weight = 14, rarity = "Uncommon"  },
            { name = "Exotic Flower Collection",      imageId = "rbxassetid://6034871478", sellValue = 1500,   weight = 11, rarity = "Uncommon"  },
            { name = "Porscha Cayenne Turbo",         imageId = "rbxassetid://6034871478", sellValue = 12000,  weight = 7,  rarity = "Rare"      },
            { name = "Macalolan 30yr Collection",     imageId = "rbxassetid://6034871478", sellValue = 8000,   weight = 5,  rarity = "Rare"      },
            { name = "Lamborgher Urus",               imageId = "rbxassetid://6034871478", sellValue = 28000,  weight = 3,  rarity = "Epic"      },
            { name = "Macalolan 50yr Red Collection", imageId = "rbxassetid://6034871478", sellValue = 22000,  weight = 2,  rarity = "Epic"      },
            { name = "Private Mountain Estate",       imageId = "rbxassetid://6034871478", sellValue = 120000, weight = 1,  rarity = "Legendary" },
        },
    },

    -- =========================================================================
    -- ROLLS ROISCE  –  Cullinans, Ghosts, rainbow Rolexes
    -- Cullinan ($350k) in $12k pack = 29x ratio → weight 1
    -- =========================================================================
    {
        id          = "rollsroyce_pack",
        name        = "Rolls Royce",
        description = "The pinnacle of luxury. Rainbow Rolexes and Rolls Roisces.",
        imageId     = "rbxassetid://6034871478",
        price       = 12000,
        tier        = "RollsRoyce",
        cooldown    = 0,
        enabled     = true,
        rewards     = {
            { name = "Rolls Roisce Keychain",      imageId = "rbxassetid://6034871478", sellValue = 1200,   weight = 24, rarity = "Common"    },
            { name = "RR Bespoke Umbrella",        imageId = "rbxassetid://6034871478", sellValue = 900,    weight = 20, rarity = "Common"    },
            { name = "Rolls Roisce Ghost Perfume", imageId = "rbxassetid://6034871478", sellValue = 4000,   weight = 14, rarity = "Uncommon"  },
            { name = "RR Bespoke Accessories Kit", imageId = "rbxassetid://6034871478", sellValue = 5000,   weight = 11, rarity = "Uncommon"  },
            { name = "Rolez Daytona Rainbow",      imageId = "rbxassetid://6034871478", sellValue = 35000,  weight = 8,  rarity = "Rare"      },
            { name = "Rolls Roisce Ghost",         imageId = "rbxassetid://6034871478", sellValue = 55000,  weight = 6,  rarity = "Rare"      },
            { name = "Rolls Roisce Wraith",        imageId = "rbxassetid://6034871478", sellValue = 90000,  weight = 5,  rarity = "Epic"      },
            { name = "Rainbow AP Royal Oak",       imageId = "rbxassetid://6034871478", sellValue = 75000,  weight = 4,  rarity = "Epic"      },
            { name = "Rolls Roisce Cullinan",      imageId = "rbxassetid://6034871478", sellValue = 350000, weight = 1,  rarity = "Legendary" },
        },
    },
}

return PackConfig
