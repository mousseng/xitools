require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local sets = {
    Idle = Equip.NewSet {
        Main = "Crimson Blade",
        Sub = "Crimson Blade",
        Range = Equip.Special.Displaced,
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Savage Separates",
        Hands = "Windurstian Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Mountain Gaiters",
    },
    Auto = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Savage Separates",
        Hands = "Windurstian Tekko",
        Ring1 = "Balance Ring",
        Ring2 = "Woodsman Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Throw = Equip.NewSet {
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",
        Ring1 = "Horn Ring",
        Ring2 = "Woodsman Ring",
        Legs = "Nokizaru Hakama",
    },
    Shadows = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Savage Separates",
        Hands = "Savage Gauntlets",
        Ring1 = "Sattva Ring",
        Ring2 = "Reflex Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Mountain Gaiters",
    },
    Ninjutsu = Equip.NewSet {
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Morion Earring",
        Ear2 = "Moldavite Earring",

        Body = "Savage Separates",
        Hands = "Savage Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Mountain Gaiters",
    },
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
end

local function handleMidshot()
    Equip.Set(sets.Throw)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Stealth()
    elseif Status.IsShadows(spell) or Status.IsDrain(spell) then
        Equip.Set(sets.Shadows)
    elseif Status.IsNuke(spell) or Status.IsPotencyNinjutsu(spell) or Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.Ninjutsu)
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
