require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Main = "Fudo", -- Senjuinrikio
    Sub  = "Fudo",
    Ammo = "Dart",
}

local sets = {
    Idle = Equip.NewSet {
        Main = Equip.Staves.Earth,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = settings.Ammo,

        Head = "Arhat's Jinpachi",
        Neck = "Evasion Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Arhat's Gi",
        Hands = "Koga Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Nokizaru Hakama",
        Feet = "Mountain Gaiters",

        AtNight = {
            Legs = "Ninja Hakama",
            Feet = "Ninja Kyahan",
        },
    },
    Auto = Equip.NewSet {
        Main = settings.Main,
        Sub = settings.Sub,
        Range = Equip.Special.Displaced,
        Ammo = "Bomb Core",

        Head = "Super Ribbon", -- upgrade to Optical Hat or Panther Mask
        Neck = "Spike Necklace", -- upgrade to PCC or Sandy Conquest
        Ear1 = "Merman's Earring", -- upgrade to Stealth
        Ear2 = "Brutal Earring",

        Body = "Ninja Chainmail", -- upgrade to Relic? or AF+1
        Hands = "Windurstian Tekko", -- upgrade to Dusk, H/O/B-Kote, AF+1
        Ring1 = "Sattva Ring",
        Ring2 = "Woodsman Ring",

        Back = "Psilos Mantle", -- upgrade to Forager's
        Waist = "Swift Belt",
        Legs = "Koga Hakama", -- upgrade to Byakko's
        Feet = "Fed. Kyahan", -- upgrade to Fuma

        AtNight = {
            Hands = "Koga Tekko",
        },
    },
    Weaponskill = Equip.NewSet {
        Main = settings.Main,
        Sub = settings.Sub,
        Range = Equip.Special.Displaced,
        Ammo = "Bomb Core",

        Head = "Super Ribbon", -- upgrade to Optical Hat or Walkure
        Neck = "Spike Necklace", -- upgrade to gorget?
        Ear1 = "Merman's Earring",
        Ear2 = "Brutal Earring",

        Body = "Assault Jerkin", -- upgrade to Hauby or Relic
        Hands = "Windurstian Tekko", -- upgrade to H/O/B-Kote, AF+1
        Ring1 = "Balance Ring", -- upgrade to Flame/Thunder Ring?
        Ring2 = "Balance Ring", -- upgrade to Flame/Thunder Ring?

        Back = "Psilos Mantle", -- upgrade to Forager's
        Waist = "Ryl.Kgt. Belt", -- upgrade to Warwolf
        Legs = "Republic Subligar", -- upgrade to Byakko's
        Feet = "Fed. Kyahan", -- upgrade to Rutters or Shura

        AtNight = {
            Hands = "Koga Tekko",
        },
    },
    Throw = Equip.NewSet {
        Main = Equip.Staves.Earth,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = settings.Ammo,

        Head = "Arhat's Jinpachi",
        Neck = "Harmonia's Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Arhat's Gi",
        Hands = "Ninja Tekko",
        Ring1 = "Woodsman Ring",
        Ring2 = "Horn Ring",

        Back = "High Brth. Mantle",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Ninja Hakama",
        Feet = "Fed. Kyahan",
    },
    Shadows = Equip.NewSet {
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = settings.Ammo,

        Head = "Yasha Jinpachi",
        Neck = "Evasion Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Yasha Samue",
        Hands = "Koga Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Reflex Ring", -- upgrade to Loquacious

        Back = "High Brth. Mantle",
        Waist = "Swift Belt",
        Legs = "Yasha Hakama",
        Feet = "Yasha Sune-ate", -- upgrade to Fuma

        AtNight = {
            Legs = "Ninja Hakama",
        },
    },
    Enfeeble = Equip.NewSet {
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Yasha Jinpachi",
        Neck = "Harmonia's Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Yasha Samue",
        Hands = "Koga Tekko",
        Ring1 = "Sattva Ring",
        Ring2 = "Reflex Ring",

        Back = "High Brth. Mantle",
        Waist = "Swift Belt", -- upgrade to Koga Sarashi
        Legs = "Yasha Hakama",
        Feet = "Yasha Sune-ate",
    },
    Nuke = Equip.NewSet {
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Yasha Jinpachi",
        Neck = "Rep.Mythril Medal", -- upgrade to Torque for high-eva?
        Ear1 = "Morion Earring", -- upgrade to Morion Earring +1 or Novio
        Ear2 = "Moldavite Earring",

        Body = "Yasha Samue", -- upgrade to Kirin's Osode
        Hands = "Koga Tekko",
        Ring1 = "Snow Ring",
        Ring2 = "Snow Ring",

        Back = "High Brth. Mantle", -- upgrade to Windy Conquest or Astute Cape
        Waist = "Swift Belt", -- upgrade to Jungle Rope
        Legs = "Yasha Hakama",
        Feet = "Yasha Sune-ate", -- upgrade to AF+1

        AtHalfMp = {
            Neck = "Uggalepih Pendant",
        },
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
        Equip.Set(sets.Nuke)
        Equip.Staff(spell)
    elseif Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.Enfeeble)
        Equip.Staff(spell)
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
