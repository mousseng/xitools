require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local sets = {
    Idle = Equip.NewSet {
        Main = Equip.Staves.Earth,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Gold Hairpin",
        Neck = "Black Neckerchief",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = "Warlock's Boots",
    },
    Cast = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",
        Neck = "Wing Pendant",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Cmb.Cst. Slacks",
        Feet = "Warlock's Boots",
    },
    Rest = Equip.NewSet {
        Main = Equip.Staves.Dark,
    },
    MaxMp = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Gold Hairpin",
        Neck = "Black Neckerchief",
        Ear1 = "Morion Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",

        Back = "White Cape",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = "Warlock's Boots",
    },
    EnfeebMnd = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Warlock's Chapeau",
        Neck = "Justice Badge",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "White Cape",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Warlock's Tights",
        Feet = "Warlock's Boots",
    },
    EnfeebInt = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Warlock's Chapeau",
        Neck = "Black Neckerchief",
        Ear1 = "Cunning Earring",
        Ear2 = "Morion Earring",

        Body = "Warlock's Tabard",
        Hands = "Sly Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Black Cape",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Magic Cuisses",
        Feet = "Warlock's Boots",
    },
    MaxMnd = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Super Ribbon",
        Neck = "Justice Badge",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "White Cape",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Warlock's Tights",
        Feet = "Warlock's Boots",
    },
    MaxInt = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Warlock's Chapeau",
        Neck = "Black Neckerchief",
        Ear1 = "Cunning Earring",
        Ear2 = "Morion Earring",

        Body = "Warlock's Tabard",
        Hands = "Sly Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Black Cape",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Magic Cuisses",
        Feet = "Warlock's Boots",
    },
}

local settings = {
    IsRested = false,
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    Equip.Set(sets.Idle)

    if Status.IsInSandoria(env) then
        Equip.Body("Kingdom Aketon")
    elseif Status.IsInBastok(env) then
        Equip.Body("Republic Aketon")
    elseif Status.IsInWindurst(env) then
        Equip.Body("Federation Aketon")
    end

    if Status.IsResting(player, settings) then
        Equip.Set(sets.Rest)
    end
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name == 'Convert' then
        gFunc.LockSet(sets.MaxMp, 10)
    end
end

local function handlePrecast()
    Equip.Set(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Set(sets.Stealth)
    elseif Status.IsHeal(spell) then
        Equip.Set(sets.MaxMND)
        Equip.Staff(spell)
    elseif Status.IsStoneskin(spell)
    or Status.IsEnhancement(spell) then
        Equip.Set(sets.MaxMND)
    elseif Status.IsDrain(spell)
    or Status.IsNuke(spell) then
        Equip.Set(sets.MaxINT)
        Equip.Staff(spell)
    elseif Status.IsEnfeebMnd(spell) then
        Equip.Set(sets.MaxMND)
        Equip.Staff(spell)
    elseif Status.IsEnfeebInt(spell) then
        Equip.Set(sets.MaxINT)
        Equip.Staff(spell)
    elseif Status.IsPotencyNinjutsu(spell)
    or Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.MaxINT)
        Equip.Staff(spell)
    end
end

return {
    Sets = sets,
    OnLoad = noop,
    OnUnload = noop,
    HandleCommand = noop,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = handlePrecast,
    HandleMidcast = handleMidcast,
    HandlePreshot = noop,
    HandleMidshot = noop,
    HandleWeaponskill = noop,
}
