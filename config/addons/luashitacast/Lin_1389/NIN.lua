require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Ammo = "Pebble",
}

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

        Body = "Ninja Chainmail",
        Hands = "Windurstian Tekko",
        Ring1 = "Sattva Ring",
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
        Main = "Yoto",
        Sub = "Yoto",
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Super Ribbon",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Ninja Chainmail",
        Hands = "Windurstian Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Woodsman Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Naked = Equip.NewSet {
        Main = Equip.Staves.Earth,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Ninja Chainmail",
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
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Dart",

        Head = "Ninja Hatsuburi",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Ninja Chainmail",
        Hands = "Savage Gauntlets",
        Ring1 = "Reflex Ring",
        Ring2 = "Sattva Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Ninja Kyahan",

        AtNight = {
            Legs = "Ninja Hakama",
        },
    },
    Ninjutsu = Equip.NewSet {
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Ninja Hatsuburi",
        Neck = "Rep.Mythril Medal",
        Ear1 = "Morion Earring",
        Ear2 = "Moldavite Earring",

        Body = "Brigandine", -- black cote? yasha?
        Hands = "Savage Gauntlets", -- yasha?
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Ninja Kyahan", -- river gaiters? yasha?
    },
    Weaponskill = Equip.NewSet {
        Main = "Yoto",
        Sub = "Yoto",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Super Ribbon",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Ninja Chainmail",
        Hands = "Windurstian Tekko",
        Ring1 = "Courage Ring",
        Ring2 = "Courage Ring",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
}

local function onLoad()
    AshitaCore:GetChatManager():QueueCommand(-1, '/addon reload wheel')
    ashita.tasks.once(1, function()
        AshitaCore:GetChatManager():QueueCommand( 1, '/wheel level ni')
        AshitaCore:GetChatManager():QueueCommand( 1, '/wheel lock')
    end)
end

local function onUnload()
    AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload wheel')
end

local function handleCommand(args)
    if args[1] == 'ammo' then
        settings.Ammo = args[2] or "Pebble"
    end
end

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

local function handlePreshot()
    Equip.Ammo(settings.Ammo)
end

local function handleMidshot()
    Equip.Set(sets.Throw)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Set(sets.Shadows)
        Equip.Stealth()
    elseif Status.IsShadows(spell) then
        Equip.Set(sets.Shadows)
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Shadows)
        Equip.Staff(spell)
    elseif Status.IsNuke(spell) or Status.IsPotencyNinjutsu(spell) then
        Equip.Set(sets.Ninjutsu)
        Equip.Staff(spell)
    elseif Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.Ninjutsu)
        Equip.Staff(spell)
        Equip.Ring2("Sattva Ring")
    end
end

local function handleWeaponskill()
    local weaponskill = gData.GetAction().Name

    if weaponskill == 'Blade: Teki'
    or weaponskill == 'Blade: To'
    or weaponskill == 'Blade: Chi' then
        Equip.Set(sets.Weaponskill)
    end
end

return {
    Sets = sets,
    OnLoad = onLoad,
    OnUnload = onUnload,
    HandleCommand = handleCommand,
    HandleDefault = handleDefault,
    HandleAbility = noop,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = noop,
    HandlePreshot = handlePreshot,
    HandleMidcast = handleMidcast,
    HandleMidshot = handleMidshot,
    HandleWeaponskill = handleWeaponskill,
}
