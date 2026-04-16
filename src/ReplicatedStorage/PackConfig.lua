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
	Vision = {
		displayName    = "ELITE VISION",
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
	Cosmic = {
		displayName    = "COSMIC RELICS",
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
	Players = {
		displayName    = "ROBLOX PLAYERS",
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
	Limited = {
		displayName    = "ROBLOX LIMITEDS",
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
	RollsJoice = {
		displayName    = "ROLLS JOICE",
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
		imageId     = "rbxassetid://10392521132",
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
		imageId     = "rbxassetid://78246317178159",
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
		imageId     = "rbxassetid://12284661176",
		price       = 2000,
		tier        = "Epic",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Electric Scooter",  imageId = "rbxassetid://713583389",         sellValue = 500,   weight = 40, rarity = "Rare"      },
			{ name = "MackNote Pro",      imageId = "rbxassetid://18151538607",        sellValue = 1000,  weight = 28, rarity = "Rare"      },
			{ name = "Luxury Submariner",  imageId = "rbxassetid://107237501834105",    sellValue = 3000,  weight = 16, rarity = "Epic"      },
			{ name = "Audimares Chrono", imageId = "rbxassetid://133046684762808",    sellValue = 8000,  weight = 8,  rarity = "Epic"      },
			{ name = "Porscha 9X1 Turbo",       imageId = "rbxassetid://71089144666318",     sellValue = 25000, weight = 2,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://81264272960785",
		price       = 10000,
		tier        = "Legendary",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Rari Italia 458",           imageId = "rbxassetid://18896467217", sellValue = 5000,   weight = 42, rarity = "Rare"      },
			{ name = "Lamborgherino Turbo", imageId = "rbxassetid://13558025717", sellValue = 12000,  weight = 26, rarity = "Epic"      },
			{ name = "Private Helicopter", imageId = "rbxassetid://1582944920", sellValue = 30000,  weight = 18, rarity = "Epic"      },
			{ name = "SuperSport Chirron",   imageId = "rbxassetid://92258118111854", sellValue = 75000,  weight = 8,  rarity = "Legendary" },
			{ name = "Private Yacht",      imageId = "rbxassetid://72218258244677", sellValue = 250000, weight = 1,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://13506500866",
		price       = 3000,
		tier        = "Gold",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Gold Ring",     imageId = "rbxassetid://9294746912", sellValue = 750,   weight = 46, rarity = "Uncommon"  },
			{ name = "Gold Bracelet", imageId = "rbxassetid://118879612794010", sellValue = 2000,  weight = 28, rarity = "Rare"      },
			{ name = "Gold Necklace", imageId = "rbxassetid://12115046307", sellValue = 5000,  weight = 16, rarity = "Epic"      },
			{ name = "Gold Watch",    imageId = "rbxassetid://109505445131880", sellValue = 15000, weight = 6,  rarity = "Epic"      },
			{ name = "Gold Bar",      imageId = "rbxassetid://127706766599030", sellValue = 50000, weight = 1,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://11168800609",
		price       = 7500,
		tier        = "Diamond",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Diamond Earrings", imageId = "rbxassetid://121129942064759",           sellValue = 2500,   weight = 40, rarity = "Rare"      },
			{ name = "Diamond Ring",     imageId = "rbxassetid://118085664696875",           sellValue = 6000,   weight = 28, rarity = "Rare"      },
			{ name = "Diamond Necklace", imageId = "rbxassetid://16339821098",           sellValue = 15000,  weight = 18, rarity = "Epic"      },
			{ name = "Diamond Watch",    imageId = "rbxassetid://135484245577291",      sellValue = 40000,  weight = 8,  rarity = "Legendary" },
			{ name = "Diamond Crown",    imageId = "rbxassetid://116741097187108",           sellValue = 120000, weight = 2,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://9287880382",
		price       = 8000,
		tier        = "GenWealth",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Luxury Gold Pen Set",       imageId = "rbxassetid://133361953578199", sellValue = 800,    weight = 26, rarity = "Common"    },
			{ name = "Carbon Fibre Wallet",       imageId = "rbxassetid://81216018468232", sellValue = 600,    weight = 22, rarity = "Common"    },
			{ name = "AD Royal Oak Strap",        imageId = "rbxassetid://118756353559919", sellValue = 3500,   weight = 14, rarity = "Uncommon"  },
			{ name = "C-Wagon Scale Model",       imageId = "rbxassetid://82443578490223", sellValue = 2500,   weight = 11, rarity = "Uncommon"  },
			{ name = "Audemares Pigeont Elite Maroon",imageId = "rbxassetid://119608813822417",sellValue = 18000,  weight = 8,  rarity = "Rare"      },
			{ name = "Rari Italia SF90",        imageId = "rbxassetid://121027287106650", sellValue = 35000,  weight = 6,  rarity = "Rare"      },
			{ name = "Mircedes G63 ANG",          imageId = "rbxassetid://115843775424205", sellValue = 55000,  weight = 4,  rarity = "Epic"      },
			{ name = "C-Wagon Drabus 800",        imageId = "rbxassetid://87230759644162", sellValue = 90000,  weight = 3,  rarity = "Epic"      },
			{ name = "Black VVS IceBox",       imageId = "rbxassetid://124584715846610", sellValue = 300000, weight = 1,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://81739553733363",
		price       = 5000,
		tier        = "BigLeague",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Designer Leather Briefcase", imageId = "rbxassetid://137851919275293", sellValue = 700,    weight = 26, rarity = "Common"    },
			{ name = "Gold Tie Bar",               imageId = "rbxassetid://15803507621", sellValue = 500,    weight = 22, rarity = "Common"    },
			{ name = "Cadiolac CT5 Watch",         imageId = "rbxassetid://105999145114280", sellValue = 2500,   weight = 14, rarity = "Uncommon"  },
			{ name = "Solid Gold Cufflinks",       imageId = "rbxassetid://5869895330", sellValue = 2000,   weight = 11, rarity = "Uncommon"  },
			{ name = "Cadiolac Escalade",          imageId = "rbxassetid://87932148329586", sellValue = 12000,  weight = 8,  rarity = "Rare"      },
			{ name = "David & Ko Tourbillon",      imageId = "rbxassetid://93491561545122", sellValue = 15000,  weight = 6,  rarity = "Rare"      },
			{ name = "Richard Million RM 011",     imageId = "rbxassetid://108138973509439", sellValue = 45000,  weight = 4,  rarity = "Epic"      },
			{ name = "Cadiolac Escalade ESV Black",imageId = "rbxassetid://88940695654159", sellValue = 38000,  weight = 3,  rarity = "Epic"      },
			{ name = "David & Ko Astro",      imageId = "rbxassetid://101007322445320", sellValue = 180000, weight = 1,  rarity = "Legendary" },
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
		imageId     = "rbxassetid://16167382297",
		price       = 6000,
		tier        = "Desire",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Pearl Necklace",             imageId = "rbxassetid://114368938654180", sellValue = 800,    weight = 26, rarity = "Common"    },
			{ name = "Silver Diamond Pendant",     imageId = "rbxassetid://140691580088739", sellValue = 600,    weight = 22, rarity = "Common"    },
			{ name = "Diamond Cluster Pendant",    imageId = "rbxassetid://103893554168333", sellValue = 4000,   weight = 14, rarity = "Uncommon"  },
			{ name = "BMR M8 Competition",         imageId = "rbxassetid://7162184356", sellValue = 10000,  weight = 11, rarity = "Uncommon"  },
			{ name = "Shepard Happy Diamonds",     imageId = "rbxassetid://89626689261603", sellValue = 12000,  weight = 8,  rarity = "Rare"      },
			{ name = "DDGE HellMeow",                  imageId = "rbxassetid://18299295305", sellValue = 14000,  weight = 6,  rarity = "Rare"      },
			{ name = "Diamond Tennis Necklace",    imageId = "rbxassetid://128528925543272", sellValue = 40000,  weight = 4,  rarity = "Epic"      },
			{ name = "David & Ko Flour de Gardin", imageId = "rbxassetid://79674236901034", sellValue = 50000,  weight = 3,  rarity = "Epic"      },
			{ name = "Full VVS Diamond 1417",       imageId = "rbxassetid://15415540532", sellValue = 200000, weight = 1,  rarity = "Legendary" },
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
		description = "Rare Cola, orchid collections, and bold SUVs for the fearless.",
		imageId     = "rbxassetid://112771602321532",
		price       = 3500,
		tier        = "Bravery",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Rare Orchid Arrangement",       imageId = "rbxassetid://94174858473945", sellValue = 400,    weight = 30, rarity = "Common"    },
			{ name = "Premium Cola Bottle",           imageId = "rbxassetid://7203369576", sellValue = 300,    weight = 26, rarity = "Common"    },
			{ name = "Cola Barrel (25 yr)",           imageId = "rbxassetid://163851304", sellValue = 2000,   weight = 14, rarity = "Uncommon"  },
			{ name = "Exotic Flower Collection",      imageId = "rbxassetid://93562363843364", sellValue = 1500,   weight = 11, rarity = "Uncommon"  },
			{ name = "Porscha Cayaenne Turbo",         imageId = "rbxassetid://876852596", sellValue = 12000,  weight = 7,  rarity = "Rare"      },
			{ name = "Luxury Watch Display",     imageId = "rbxassetid://91370607730319", sellValue = 8000,   weight = 5,  rarity = "Rare"      },
			{ name = "Lamborgher Urus",               imageId = "rbxassetid://78292234586233", sellValue = 28000,  weight = 3,  rarity = "Epic"      },
			{ name = "Bloxiade 50yr Purple Collection", imageId = "rbxassetid://15254937052", sellValue = 22000,  weight = 2,  rarity = "Epic"      },
			{ name = "Private Mountain Estate",       imageId = "rbxassetid://73789710010888", sellValue = 120000, weight = 1,  rarity = "Legendary" },
		},
	},

	-- =========================================================================
	-- ROLLS ROISCE  –  Cullinans, Ghosts, rainbow Rolexes
	-- Cullinan ($350k) in $12k pack = 29x ratio → weight 1
	-- =========================================================================
	{
		id          = "rollsroyce_pack",
		name        = "Rolls Joice",
		description = "The pinnacle of luxury. Rainbow Rolez and Rolls Joices.",
		imageId     = "rbxassetid://14907821278",
		price       = 12000,
		tier        = "RollsJoice",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Rolls Joice Keychain",      imageId = "rbxassetid://114034779830056", sellValue = 1200,   weight = 24, rarity = "Common"    },
			{ name = "RR Bespoke Umbrella",        imageId = "rbxassetid://120265439687066", sellValue = 900,    weight = 20, rarity = "Common"    },
			{ name = "TSY Perfume", imageId = "rbxassetid://12804366112", sellValue = 4000,   weight = 14, rarity = "Uncommon"  },
			{ name = "Steak Dinner Unlimited", imageId = "rbxassetid://123644178045901", sellValue = 5000,   weight = 11, rarity = "Uncommon"  },
			{ name = "Rolez Daytona Rainbow",      imageId = "rbxassetid://110702820294837", sellValue = 35000,  weight = 8,  rarity = "Rare"      },
			{ name = "Rolls Joice Spook",         imageId = "rbxassetid://119753949575866", sellValue = 55000,  weight = 6,  rarity = "Rare"      },
			{ name = "Rolls Joice Wrath",        imageId = "rbxassetid://113542876545899", sellValue = 90000,  weight = 5,  rarity = "Epic"      },
			{ name = "Rainbow AP Royal Oak",       imageId = "rbxassetid://111075914536741", sellValue = 75000,  weight = 4,  rarity = "Epic"      },
			{ name = "Rolls Joice Elite",      imageId = "rbxassetid://108020063953803", sellValue = 350000, weight = 1,  rarity = "Legendary" },
		},
	},
	-- ROBLOX LIMITED
	{
		id          = "robloxlimited_pack",
		name        = "Roblox Limited",
		description = "Exclusive Roblox limited edition items and collectible avatars.",
		imageId     = "rbxassetid://1234567890",
		price       = 4500,
		tier        = "Limited",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Random Egg",       imageId = "rbxassetid://1234567890", sellValue = 450,    weight = 30, rarity = "Common"    },
			{ name = "Sinister Branches",      imageId = "rbxassetid://1234567890", sellValue = 350,    weight = 26, rarity = "Common"    },
			{ name = "Legitimate Buisness Fedora",   imageId = "rbxassetid://1234567890", sellValue = 2200,   weight = 14, rarity = "Uncommon"  },
			{ name = "8-Bit Crown",      imageId = "rbxassetid://1234567890", sellValue = 1800,   weight = 11, rarity = "Uncommon"  },
			{ name = "Pretty Pretty Princess",      imageId = "rbxassetid://1234567890", sellValue = 13000,  weight = 7,  rarity = "Rare"      },
			{ name = "Silver King Of The Night",        imageId = "rbxassetid://1234567890", sellValue = 9500,   weight = 5,  rarity = "Rare"      },
			{ name = "Dominus Verspertilio",     imageId = "rbxassetid://1234567890", sellValue = 35000,  weight = 3,  rarity = "Epic"      },
			{ name = "Valkyrie",  imageId = "rbxassetid://1234567890", sellValue = 24000,  weight = 2,  rarity = "Epic"      },
			{ name = "SparkleTime Fedora",  imageId = "rbxassetid://1234567890", sellValue = 90000,  weight = 1,  rarity = "Legendary" },
		},
	},

	-- ROBLOX PLAYERS
	{
		id          = "robloxplayers_pack",
		name        = "Roblox Players",
		description = "Player-exclusive cosmetics, gamepasses, and collectible avatars.",
		imageId     = "rbxassetid://1234567890",
		price       = 3000,
		tier        = "Players",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Steak",    imageId = "rbxassetid://1234567890", sellValue = 300,    weight = 30, rarity = "Common"    },
			{ name = "Kreekcraft",              imageId = "rbxassetid://1234567890", sellValue = 250,    weight = 26, rarity = "Common"    },
			{ name = "Socksfor1",         imageId = "rbxassetid://1234567890", sellValue = 1800,   weight = 14, rarity = "Uncommon"  },
			{ name = "Haz3mn",         imageId = "rbxassetid://1234567890", sellValue = 1400,   weight = 11, rarity = "Uncommon"  },
			{ name = "Gussi1203",    imageId = "rbxassetid://1234567890", sellValue = 10000,  weight = 7,  rarity = "Rare"      },
			{ name = "HolyGrail",      imageId = "rbxassetid://1234567890", sellValue = 6500,   weight = 5,  rarity = "Rare"      },
			{ name = "Rip_indra",      imageId = "rbxassetid://1234567890", sellValue = 25000,  weight = 3,  rarity = "Epic"      },
			{ name = "Simoon68",  imageId = "rbxassetid://1234567890", sellValue = 18000,  weight = 2,  rarity = "Epic"      },
			{ name = "Linkmon99",        imageId = "rbxassetid://1234567890", sellValue = 75000,  weight = 1,  rarity = "Legendary" },
		},
	},

	-- COSMIC RELICS
	{
		id          = "cosmicrelic_pack",
		name        = "Cosmic Relics Case",
		description = "Ancient cosmic artifacts and celestial treasures from beyond.",
		imageId     = "rbxassetid://1234567890",
		price       = 5500,
		tier        = "Cosmic",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Meteor Fragment",               imageId = "rbxassetid://1234567890", sellValue = 500,    weight = 30, rarity = "Common"    },
			{ name = "Star Dust Vial",                imageId = "rbxassetid://1234567890", sellValue = 400,    weight = 26, rarity = "Common"    },
			{ name = "Celestial Crystal Cluster",     imageId = "rbxassetid://1234567890", sellValue = 2400,   weight = 14, rarity = "Uncommon"  },
			{ name = "Ancient Space Artifact",        imageId = "rbxassetid://1234567890", sellValue = 1900,   weight = 11, rarity = "Uncommon"  },
			{ name = "Nebula Stone",                  imageId = "rbxassetid://1234567890", sellValue = 14000,  weight = 7,  rarity = "Rare"      },
			{ name = "Cosmic Relic Crown",            imageId = "rbxassetid://1234567890", sellValue = 10000,  weight = 5,  rarity = "Rare"      },
			{ name = "Supernova Gem Collection",      imageId = "rbxassetid://1234567890", sellValue = 32000,  weight = 3,  rarity = "Epic"      },
			{ name = "Black Hole Core Fragment",      imageId = "rbxassetid://1234567890", sellValue = 26000,  weight = 2,  rarity = "Epic"      },
			{ name = "Ancient Cosmic Relic Throne",   imageId = "rbxassetid://1234567890", sellValue = 120000, weight = 1,  rarity = "Legendary" },
		},
	},

	-- ELITE VISION (Glasses/Sunglasses/Aura Eyewear)
	{
		id          = "elitevision_pack",
		name        = "Elite Vision Case",
		description = "Premium eyewear collection. From designer shades to diamond-encrusted frames.",
		imageId     = "rbxassetid://1234567890",
		price       = 4200,
		tier        = "Vision",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Classic Aviator Sunglasses",    imageId = "rbxassetid://1234567890", sellValue = 350,    weight = 30, rarity = "Common"    },
			{ name = "Tinted Cartimmer Frames",        imageId = "rbxassetid://1234567890", sellValue = 400,    weight = 26, rarity = "Common"    },
			{ name = "Meti Smart Glasses",     imageId = "rbxassetid://1234567890", sellValue = 2600,   weight = 14, rarity = "Uncommon"  },
			{ name = "Chrome Eyes Eyewear",      imageId = "rbxassetid://1234567890", sellValue = 1700,   weight = 11, rarity = "Uncommon"  },
			{ name = "Platinum Frame Shades",         imageId = "rbxassetid://1234567890", sellValue = 11500,  weight = 7,  rarity = "Rare"      },
			{ name = "Gold Rimmed Cartimmer Glasses",     imageId = "rbxassetid://1234567890", sellValue = 8200,   weight = 5,  rarity = "Rare"      },
			{ name = "VVS Diamond Studded Frames",    imageId = "rbxassetid://1234567890", sellValue = 29000,  weight = 3,  rarity = "Epic"      },
			{ name = "Rainbow Aura Cosmic Shades",    imageId = "rbxassetid://1234567890", sellValue = 21000,  weight = 2,  rarity = "Epic"      },
			{ name = "Cartimmer Diamond-Encrusted Shades",imageId = "rbxassetid://1234567890", sellValue = 100000, weight = 1,  rarity = "Legendary" },
		},
	},

	-- LUXURY LIFE
	{
		id          = "luxurylife_pack",
		name        = "Luxury Life",
		description = "Exclusive lifestyle items. Mansions, yachts, and lifetime memberships.",
		imageId     = "rbxassetid://1234567890",
		price       = 5800,
		tier        = "Lavish",
		cooldown    = 0,
		enabled     = true,
		rewards     = {
			{ name = "Luxury Spa Day Package",        imageId = "rbxassetid://1234567890", sellValue = 550,    weight = 30, rarity = "Common"    },
			{ name = "Premium Wine Bottle",           imageId = "rbxassetid://1234567890", sellValue = 480,    weight = 26, rarity = "Common"    },
			{ name = "Private Jet Pass (1 Flight)",   imageId = "rbxassetid://1234567890", sellValue = 2800,   weight = 14, rarity = "Uncommon"  },
			{ name = "Penthouse Key Card",            imageId = "rbxassetid://1234567890", sellValue = 2100,   weight = 11, rarity = "Uncommon"  },
			{ name = "Luxury Yacht Weekend Pass",     imageId = "rbxassetid://1234567890", sellValue = 15000,  weight = 7,  rarity = "Rare"      },
			{ name = "Mansion Blueprint Collection",  imageId = "rbxassetid://1234567890", sellValue = 11000,  weight = 5,  rarity = "Rare"      },
			{ name = "Private Island Deed",           imageId = "rbxassetid://1234567890", sellValue = 35000,  weight = 3,  rarity = "Epic"      },
			{ name = "Luxury Estate Portfolio",       imageId = "rbxassetid://1234567890", sellValue = 28000,  weight = 2,  rarity = "Epic"      },
			{ name = "Lifetime Luxury Membership",    imageId = "rbxassetid://1234567890", sellValue = 145000, weight = 1,  rarity = "Legendary" },
		},
	},
}
-- =============================================================================
-- VALUE SCRAMBLER (adds slight randomness to sell values)
-- =============================================================================

local function scrambleValue(value)
	-- random variation between -12% and +18%
	local variation = math.random(-12, 18) / 100
	local newValue = math.floor(value * (1 + variation))

	-- make numbers feel "natural" (not clean like 1000)
	local endings = {3, 7, 9, 11, 23, 47, 69}
	local ending = endings[math.random(1, #endings)]

	return newValue + ending
end

for _, pack in ipairs(PackConfig.Packs) do
	for _, item in ipairs(pack.rewards) do
		item.sellValue = scrambleValue(item.sellValue)
	end
end
return PackConfig
