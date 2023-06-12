require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/Status.lua')

local sets = {
    Idle = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = nil,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Brass Hairpin",
        Neck = "Black Neckerchief",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Savage Separates",
        Hands = "Savage Gauntlets",
        Ring1 = "San d'Orian Ring",
        Ring2 = "Sattva Ring",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = "Savage Gaiters",
    },
    Cast = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = nil,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Brass Hairpin",
        Neck = "Black Neckerchief",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Savage Separates",
        Hands = "Savage Gauntlets",
        Ring1 = "San d'Orian Ring",
        Ring2 = "Sattva Ring",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = "Savage Gaiters",
    },
    Rest = Equip.NewSet {
        Main = "Pilgrim's Wand",
    },
    MaxMp = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = nil,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Brass Hairpin",
        Neck = nil,
        Ear1 = "Morion Earring",
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets",
        Ring1 = nil,
        Ring2 = nil,

        Back = nil,
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = nil,
    },
    EnfeebMnd = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = nil,
        Ammo = nil,

        Head = nil,
        Neck = "Justice Badge",
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "White Cape",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = nil,
    },
    EnfeebInt = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = Equip.Special.Displaced,
        Neck = "Black Neckerchief",
        Ear1 = "Cunning Earring",
        Ear2 = "Morion Earring",

        Body = "Ryl.Ftm. Tunic",
        Hands = nil,
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Black Cape",
        Waist = "Wizard's Belt",
        Legs = nil,
        Feet = nil,
    },
    MaxMnd = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = nil,
        Neck = "Justice Badge",
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "White Cape",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = nil,
    },
    MaxInt = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = Equip.Special.Displaced,
        Neck = "Black Neckerchief",
        Ear1 = "Cunning Earring",
        Ear2 = "Morion Earring",

        Body = "Ryl.Ftm. Tunic",
        Hands = nil,
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Black Cape",
        Waist = "Wizard's Belt",
        Legs = nil,
        Feet = nil,
    },
}

local settings = {
    IsRested = false,
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    Equip.Set(sets.Idle)

    if Status.IsAttacking(player) then
        Equip.Set(sets.Auto)
    end

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

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Stealth()
    elseif Status.IsHeal(spell)
    or Status.IsStoneskin(spell) then
        Equip.Set(sets.MaxMnd)
    elseif Status.IsNuke(spell)
    or Status.IsDrain(spell)
    or Status.IsPotencyNinjutsu(spell)
    or Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.MaxInt)
    elseif Status.IsEnfeebMnd(spell) then
        Equip.Set(sets.EnfeebMnd)
    elseif Status.IsEnfeebInt(spell) then
        Equip.Set(sets.EnfeebInt)
    else
        Equip.Set(sets.Cast)
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
    HandlePrecast = noop,
    HandleMidcast = handleMidcast,
    HandlePreshot = noop,
    HandleMidshot = noop,
    HandleWeaponskill = noop,
}
