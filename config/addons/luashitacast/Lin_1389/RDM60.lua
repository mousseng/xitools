require('common')
local Status = gFunc.LoadFile('common/status.lua')
local Staves = gFunc.LoadFile('common/staves.lua')
local Const = gFunc.LoadFile('common/const.lua')
local EquipSlots = gFunc.LoadFile('common/equipSlots.lua')
local noop = function() end

local sets = {
    Idle = {
        -- preferred stats: MP, DEF, EVA
        Main = Staves.Earth,
        Sub = Const.Displaced,
        Range = Const.Displaced,
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Gold Hairpin",      -- MP+30
        Neck = "Black Neckerchief", -- DEF+2
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets", -- MP+16, DEF+6
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",      -- DT-5

        Back = "High Brth. Mantle", -- DEF+5
        Waist = "Friar's Rope",     -- MP+5, DEF+2
        Legs = "Savage Loincloth",  -- MP+32, DEF+12
        Feet = "Warlock's Boots",
    },
    Rest = {
        -- preferred stats: hMP
        Main = Staves.Dark,         -- hMP+10
    },
    MaxMp = {
        -- preferred stats: MP
        Main = "Fencing Degen",     -- MP+10
        Sub = Const.Displaced,
        Range = Const.Displaced,
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Gold Hairpin",      -- MP+30
        Neck = "Black Neckerchief",
        Ear1 = "Morion Earring",    -- MP+4
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets", -- MP+16,
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",      -- DT-5

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",     -- MP+5
        Legs = "Savage Loincloth",  -- MP+32
        Feet = "Warlock's Boots",
    },
    Stealth = {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Waist = "Swift Belt",
        Feet = "Dream Boots +1",
    },
    MaxMND = {
        Main = "Fencing Degen",     -- Enfeeb+3, MND+3
        Sub = "Yew Wand +1",        -- MND+4
        Range = Const.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Super Ribbon",
        Neck = "Justice Badge",     -- MND+3
        -- Ear1 = "Cunning Earring",
        -- Ear2 = "Abyssal Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Ryl.Kgt. Belt",    -- MND+2
        Legs = "Warlock's Tights",     -- MND+3
        Feet = "Warlock's Boots",
    },
    MaxINT = {
        Main = "Fencing Degen",     -- Enfeeb+3, INT+3
        Sub = "Yew Wand +1",        -- INT+4
        Range = Const.Displaced,
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Warlock's Chapeau",
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = "Morion Earring",    -- INT+1

        Body = "Warlock's Tabard",
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Ryl.Kgt. Belt",    -- INT+2
        Legs = "Magic Cuisses",     -- INT+3
        Feet = "Warlock's Boots",
    },
}

local settings = {
    Rested  = false,
}

local equipSlot = gFunc.Equip
local equipSet = gFunc.EquipSet

local function handleCommand(args)
end

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    equipSet(sets.Idle)

    if Status.IsInSandoria(env) then
        equipSlot(EquipSlots.Body, "Kingdom Aketon")
    elseif Status.IsInBastok(env) then
        equipSlot(EquipSlots.Body, "Republic Aketon")
    elseif Status.IsInWindurst(env) then
        equipSlot(EquipSlots.Body, "Federation Aketon")
    end

    if Status.IsResting(player, settings) then
        equipSet('Rest')
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
        equipSlot(EquipSlots.Legs, "Dream Pants +1")
    end
end

local function handlePrecast()
    equipSet(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        equipSet(sets.Stealth)
    elseif Status.IsHeal(spell) then
        equipSet(sets.MaxMND)
        Staves.Equip(spell)
    elseif Status.IsDrain(spell) then
        equipSet(sets.MaxINT)
        Staves.Equip(spell)
    elseif Status.IsStoneskin(spell) then
        equipSet(sets.MaxMND)
    elseif Status.IsEnhancement(spell) then
        equipSet(sets.MaxMND)
    elseif Status.IsNuke(spell) then
        equipSet(sets.MaxINT)
        Staves.Equip(spell)
    elseif Status.IsEnfeebMnd(spell) then
        equipSet(sets.MaxMND)
        Staves.Equip(spell)
    elseif Status.IsEnfeebInt(spell) then
        equipSet(sets.MaxINT)
        Staves.Equip(spell)
    elseif Status.IsPotencyNinjutsu(spell) then
        equipSet(sets.MaxINT)
        Staves.Equip(spell)
    elseif Status.IsAccuracyNinjutsu(spell) then
        equipSet(sets.MaxINT)
        Staves.Equip(spell)
    end
end

local function handleWeaponskill()
end

return {
    Sets = sets,
    OnLoad = noop,
    OnUnload = noop,
    HandleCommand = handleCommand,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = handleItem,
    HandlePrecast = handlePrecast,
    HandleMidcast = handleMidcast,
    HandlePreshot = noop,
    HandleMidshot = noop,
    HandleWeaponskill = handleWeaponskill,
}
