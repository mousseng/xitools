require('common')
local status = gFunc.LoadFile('common/status.lua')
local EquipSlots = gData.Constants.EquipSlots

local sets = {
    Idle = {
        -- preferred stats: MP, DEF, EVA
        Main = "Fencing Degen",     -- MP+10
        Sub = "Hornetneedle",       -- AGI+1
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Gold Hairpin",      -- MP+30
        Neck = "Black Neckerchief", -- DEF+2
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Brigandine",        -- DEF+32
        Hands = "Savage Gauntlets", -- MP+16, DEF+6
        Ring1 = "San d'Orian Ring", -- DEF+1
        Ring2 = "Sattva Ring",      -- DT-5

        Back = "High Brth. Mantle", -- DEF+5
        Waist = "Friar's Rope",     -- MP+5, DEF+2
        Legs = "Savage Loincloth",  -- MP+32, DEF+12
        Feet = "Savage Gaiters",    -- DEF+5
    },
    Rest = {
        -- preferred stats: hMP
        Main = "Pilgrim's Wand",    -- hMP+2
    },
    MaxMp = {
        -- preferred stats: MP
        Main = "Fencing Degen",     -- MP+10
        Sub = "Hornetneedle",
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Gold Hairpin",      -- MP+30
        Neck = "Black Neckerchief",
        Ear1 = "Morion Earring",    -- MP+4
        Ear2 = "Drone Earring",

        Body = "Brigandine",
        Hands = "Savage Gauntlets", -- MP+16,
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",     -- MP+5
        Legs = "Savage Loincloth",  -- MP+32
        Feet = "Savage Gaiters",
    },
    Stealth = {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Waist = "Swift Belt",
        Feet = "Dream Boots +1",
    },
    Shadows = {
        -- preferred stats: SID, Parry, Eva
        Main = "Fencing Degen",
        Sub = "Hornetneedle",       -- AGI+1
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",     -- Eva+3
        Neck = "Wing Pendant",      -- AGI+1
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Brigandine",
        Hands = "Savage Gauntlets",
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",    -- AGI+2
        Legs = "Cmb.Cst. Slacks",   -- Eva+5
        Feet = "Savage Gaiters",
    },
    EnfeebInt = {
        -- preferred stats: Enfeeb, INT, Enm-
        Main = "Fencing Degen",     -- Enfeeb+3, INT+3
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Erd. Headband",     -- INT+1
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = "Morion Earring",    -- INT+1

        -- Body = "",
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Ryl.Kgt. Belt",    -- INT+2
        Legs = "Magic Cuisses",     -- INT+3
        -- Feet = "",
    },
    EnfeebMnd = {
        -- preferred stats: Enfeeb, MND, Enm-
        Main = "Fencing Degen",     -- Enfeeb+3, MND+3
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",
        Neck = "Justice Badge",     -- MND+3
        -- Ear1 = "Cunning Earring",
        -- Ear2 = "Abyssal Earring",

        -- Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Ryl.Kgt. Belt",    -- MND+2
        Legs = "Magic Cuisses",     -- MND+3
        -- Feet = "Wise Pigaches",     -- MND+4, Enm-1
    },
    MaxMND = {
        -- preferred stats: MND, Enhancing
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",
        Neck = "Justice Badge",     -- MND+3
        -- Ear1 = "",
        -- Ear2 = "",

        -- Body = "",
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Ryl.Kgt. Belt",    -- MND+2
        Legs = "Magic Cuisses",     -- MND+3
        -- Feet = "",
    },
    MaxINT = {
        -- preferred stats: MAB, INT, Ele, Enm-
        Main = "Yew Wand +1",       -- INT+4
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Erd. Headband",     -- INT+1
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = "Morion Earring",    -- INT+1

        -- Body = "",
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Ryl.Kgt. Belt",    -- INT+2
        Legs = "Magic Cuisses",     -- INT+3
        -- Feet = "",
    },
}

local settings = {
    Rested  = false,
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    gFunc.EquipSet(sets.Idle)

    if status.IsInSandoria(env) then
        gFunc.Equip(EquipSlots.Body, "Kingdom Aketon")
    elseif status.IsInBastok(env) then
        gFunc.Equip(EquipSlots.Body, "Republic Aketon")
    elseif status.IsInWindurst(env) then
        gFunc.Equip(EquipSlots.Body, "Federation Aketon")
    end

    if status.IsResting(player, settings) then
        gFunc.EquipSet('Rest')
    end
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name == 'Convert' then
        gFunc.LockSet(sets.MaxMp, 10)
    end
end

local function handleItem()
    local item = gData.GetAction()
    if item.Name == 'Orange Juice' then
        gFunc.Equip(EquipSlots.Legs, "Dream Pants +1")
    end
end

local function handleMidcast()
    local spell = gData.GetAction()

    if status.IsStealth(spell) then
        gFunc.EquipSet(sets.Stealth)
    elseif status.IsShadows(spell) then
        gFunc.EquipSet(sets.Shadows)
    elseif status.IsEnfeebMnd(spell) then
        gFunc.EquipSet(sets.EnfeebMnd)
    elseif status.IsEnfeebInt(spell) then
        gFunc.EquipSet(sets.EnfeebInt)
    elseif status.IsHeal(spell) or status.IsStoneskin(spell) then
        gFunc.EquipSet(sets.MaxMND)
    else
        gFunc.EquipSet(sets.MaxINT)
    end
end

return {
    Sets = sets,
    OnLoad = nil,
    OnUnload = nil,
    HandleCommand = nil,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = handleItem,
    HandlePrecast = nil,
    HandleMidcast = handleMidcast,
    HandlePreshot = nil,
    HandleMidshot = nil,
    HandleWeaponskill = nil,
}
