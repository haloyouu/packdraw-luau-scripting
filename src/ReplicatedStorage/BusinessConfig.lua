-- =============================================================================
-- BusinessConfig  (ModuleScript — ReplicatedStorage)
-- Passive income businesses — shared by server and client.
-- =============================================================================
local BusinessConfig = {}

BusinessConfig.BASE_HOURLY_INCOME = 25   -- earned per hour with no businesses owned
BusinessConfig.MAX_OFFLINE_HOURS  = 8    -- offline earnings cap

BusinessConfig.Businesses = {
    {
        id           = "lemonade_stand",
        name         = "Lemonade Stand",
        description  = "A humble start. Every empire begins here.",
        imageId      = "rbxassetid://6034871478",
        color        = Color3.fromRGB(255, 210,  40),
        cost         = 1500,
        hourlyIncome = 100,
    },
    {
        id           = "food_truck",
        name         = "Food Truck",
        description  = "Rolling in profit, 24 hours a day.",
        imageId      = "rbxassetid://6034871478",
        color        = Color3.fromRGB(255, 140,  40),
        cost         = 5000,
        hourlyIncome = 400,
    },
    {
        id           = "restaurant",
        name         = "Restaurant",
        description  = "Fine dining. Even finer earnings.",
        imageId      = "rbxassetid://6034871478",
        color        = Color3.fromRGB(220,  55,  55),
        cost         = 15000,
        hourlyIncome = 1200,
    },
    {
        id           = "shopping_mall",
        name         = "Shopping Mall",
        description  = "Hundreds of shops, all paying you rent.",
        imageId      = "rbxassetid://6034871478",
        color        = Color3.fromRGB( 60, 110, 220),
        cost         = 50000,
        hourlyIncome = 3500,
    },
    {
        id           = "mega_casino",
        name         = "Mega Casino",
        description  = "The house always wins. You are the house.",
        imageId      = "rbxassetid://6034871478",
        color        = Color3.fromRGB(160,  40, 230),
        cost         = 200000,
        hourlyIncome = 10000,
    },
}

function BusinessConfig.getById(id)
    for _, b in ipairs(BusinessConfig.Businesses) do
        if b.id == id then return b end
    end
end

-- Sum of all hourly incomes for the businesses a player owns, plus base rate
function BusinessConfig.getHourlyRate(owned)
    local rate = BusinessConfig.BASE_HOURLY_INCOME
    for _, b in ipairs(BusinessConfig.Businesses) do
        if owned[b.id] then
            rate = rate + b.hourlyIncome
        end
    end
    return rate
end

return BusinessConfig
