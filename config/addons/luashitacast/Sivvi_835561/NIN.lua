require('common')
local noop = function() end
local chat = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Subjob = 'NON',
    MeleeSet = 'Dps',
    Default = {
        Main = "Kaja Katana",
        Sub  = "Ternion Dagger +1",
        Ammo = "Date Shuriken",
    },
    Merit = {
        Main = "Ternion Dagger +1",
        Sub  = "Kaja Katana",
        Ammo = "Date Shuriken",
    },
    Capes = {
        Auto  = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+20', [2] = '"Dbl.Atk."+10', } },
        -- StrWs = { Name = "Andartia's Mantle", Augment = { [1] = 'STR+30', [2] = 'Weapon skill damage +10%', } },
        DexWs = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+29', [2] = 'Weapon skill damage +10%', } },
        -- AgiWs = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+30', [2] = 'Weapon skill damage +10%', } },
        -- Cast = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+30', [2] = 'Fast Cast +10%', } },
        Nuke  = { Name = "Andartia's Mantle", Augment = { [1] = 'INT+30', [2] = '"Mag. Atk. Bns."+9' } },
    },
}

local sets = {
    Idle = Equip.NewSet {
        Feet = "Hachiya Kyahan +2",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
    },
    Melee = {
        Dt = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Hattori Zukin +2",
            Body  = "Hiza. Haramaki +2",
            Hands = "Hizamaru Kote +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Hizamaru Ring",
            Back  = settings.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Dps = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Hattori Zukin +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Hizamaru Ring",
            Back  = settings.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Eva = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Hiza. Somen +2",
            Body  = "Hiza. Haramaki +2",
            Hands = "Hizamaru Kote +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Hizamaru Ring",
            Back  = settings.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Throw = Equip.NewSet {
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Hands = "Taeon Gloves",

            Ring1 = "Weather. Ring",
        },
        Shadows = Equip.NewSet {
            Feet  = "Hattori Kyahan",
        },
        Enfeeble = Equip.NewSet {
            Body  = "Herculean Vest",
        },
        Nuke = Equip.NewSet {
            Head  = "Taeon Chapeau",
            Body  = "Herculean Vest",
            Hands = "Hattori Tekko +1",
            Legs  = "Taeon Tights",
            Feet  = "Hachiya Kyahan +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ring1 = "Weather. Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = settings.Capes.Nuke,
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Seething Bomblet",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Blade: Ku'] = Equip.NewSet {
            Ammo  = "Seething Bomblet",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Blade: Shun'] = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
            Waist = "Thunder Belt",
        },
        ['Blade: Hi'] = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Hattori Kyahan +2",

            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Aeolian Edge'] = Equip.NewSet {
            Ammo  = "Seething Bomblet",

            Head  = "Taeon Chapeau",
            Body  = "Herculean Vest",
            Hands = "Herculean Gloves",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hachiya Kyahan +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Weather. Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = settings.Capes.DexWs,
            Waist = "Thunder Belt",
        },
        ['Exenterator'] = Equip.NewSet {
            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
    },
}

local function changeThotbarPalette(subjob)
    if subjob == nil or subjob == 'NON' or subjob == settings.Subjob then
        return
    end

    local thotbarCmd = '/tb palette change %s'
    chat:QueueCommand(1, thotbarCmd:format(subjob))
    settings.Subjob = subjob
end

local function handleDefault()
    local player = gData.GetPlayer()

    changeThotbarPalette(player.SubJob)

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Melee.Dps)
    else
        Equip.Feet(sets.Idle.Feet)
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()
    local wsSet = sets.Weaponskills[ws.Name]
    local fallback = sets.Weaponskills.Base

    Equip.Set(wsSet or fallback)
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'gear' then
        Equip.Main(settings.Default.Main, true)
        Equip.Sub(settings.Default.Sub, true)
        Equip.Ammo(settings.Default.Ammo, true)
    elseif args[1] == 'merit' then
        Equip.Main(settings.Merit.Main, true)
        Equip.Sub(settings.Merit.Sub, true)
        Equip.Ammo(settings.Merit.Ammo, true)
    end
end

local function onLoad()
    chat:QueueCommand(-1, '/addon reload wheel')

    ashita.tasks.once(1, function()
        chat:QueueCommand(1, '/wheel level ni')
        chat:QueueCommand(1, '/wheel alt san')
        chat:QueueCommand(1, '/wheel lock')
    end)
end

local function onUnload()
    chat:QueueCommand(-1, '/addon unload wheel')
end

return {
    Sets              = sets,
    OnLoad            = onLoad,
    OnUnload          = onUnload,
    HandleCommand     = handleCommand,
    HandleDefault     = handleDefault,
    HandleAbility     = noop,
    HandleItem        = gFunc.LoadFile('common/items.lua'),
    HandlePrecast     = handlePrecast,
    HandleMidcast     = handleMidcast,
    HandlePreshot     = noop,
    HandleMidshot     = noop,
    HandleWeaponskill = handleWeaponskill,
}
