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
        Ammo = "Dart",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Brigandine", -- Ninja Chainmail
        Hands = "Windurstian Tekko",
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Ninja Kyahan",

        AtNight = {
            Legs = "Ninja Hakama",
            Feet = "Ninja Kyahan",
        },
    },
    Auto = Equip.NewSet {
        Main = "Zushio",
        Sub = "Anju",
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Brigandine", -- Ninja Chainmail
        Hands = "Windurstian Tekko",
        Ring1 = "Balance Ring",
        Ring2 = "Woodsman Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Naked = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Brigandine", -- Ninja Chainmail
        Hands = "Windurstian Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Woodsman Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Fed. Kyahan",

        AtNight = {
            Legs = "Ninja Hakama",
        },
    },
    Throw = Equip.NewSet {
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Hands = "Ninja Tekko",
        Ring1 = "Horn Ring",
        Ring2 = "Woodsman Ring",

        Legs = "Ninja Hakama",
        Feet = "Fed. Kyahan",
    },
    Shadows = Equip.NewSet {
        Main = "Parrying Knife",
        Sub = "Parrying Knife",
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Brigandine", -- Ninja Chainmail
        Hands = "Savage Gauntlets",
        Ring1 = "Reflex Ring",
        Ring2 = "Peridot Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Ninja Kyahan",

        AtNight = {
            Legs = "Ninja Hakama",
        },
    },
    Ninjutsu = Equip.NewSet {
        Main = "Parrying Knife",
        Sub = "Parrying Knife",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband", -- Ninja Hatsuburi
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Morion Earring",
        Ear2 = "Moldavite Earring",

        Body = "Brigandine",
        Hands = "Savage Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Ninja Kyahan",
    },
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    Equip.Set(sets.Idle)

    if Status.IsAttacking(player) and Status.HasStatus('Copy Image') then
        Equip.Set(sets.Auto)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Naked)
    end

    if Status.IsInSandoria(env) then
        Equip.Body("Kingdom Aketon")
    elseif Status.IsInBastok(env) then
        Equip.Body("Republic Aketon")
    elseif Status.IsInWindurst(env) then
        Equip.Body("Federation Aketon")
    end
end

local function handleMidshot()
    Equip.Set(sets.Throw)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Set(sets.Stealth)
    elseif Status.IsShadows(spell) then
        Equip.Set(sets.Shadows)
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Shadows)
        Equip.Staff(spell)
    elseif Status.IsNuke(spell) or Status.IsPotencyNinjutsu(spell) or Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.Ninjutsu)
        Equip.Staff(spell)
    end
end

local function handleWeaponskill()
    local weaponskill = gData.GetAction().Name

    if weaponskill == 'Blade: Teki'
    or weaponskill == 'Blade: To' then
        Equip.Set(sets.Ninjutsu)
    end
end

return {
    Sets = sets,
    OnLoad = noop,
    OnUnload = noop,
    HandleCommand = noop,
    HandleDefault = handleDefault,
    HandleAbility = noop,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = noop,
    HandlePreshot = noop,
    HandleMidcast = handleMidcast,
    HandleMidshot = handleMidshot,
    HandleWeaponskill = handleWeaponskill,
}
