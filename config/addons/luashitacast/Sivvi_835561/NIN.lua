require('common')
local noop = function() end
local chat = require('chat')
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Subjob = 'NON',
    MeleeSet = 'Dps',
    TreasureHunter = false,
    Futae = false,
    Default = {
        Main = "Kikoku",
        Sub  = "Ternion Dagger +1",
        Ammo = "Date Shuriken",
    },
    Merit = {
        Main = "Kaja Knife",
        Sub  = "Naegling",
        Ammo = "Date Shuriken",
    },
}

local gear = {
    Artifact = {
        Head  = "Hachi. Hatsu. +1",
        Body  = "Hachi. Chain. +1",
        Hands = "Hachiya Tekko +1",
        Legs  = "Hachi. Hakama +1",
        Feet  = "Hachiya Kyahan +2",
        Neck  = "Ninja Nodowa +1",
        Ring  = "Regal Ring",
    },
    Relic = {
        Head  = "Mochi. Hatsuburi +2",
        Body  = "Mochi. Chainmail +1",
        Hands = "Mochizuki Tekko +1",
        Legs  = "Mochi. Hakama +1",
        Feet  = "Mochi. Kyahan +1",
    },
    Empyrean = {
        Head  = "Hattori Zukin +2",
        Body  = "Hattori Ningi +2",
        Hands = "Hattori Tekko +2",
        Legs  = "Hattori Hakama +2",
        Feet  = "Hattori Kyahan +2",
        Ear   = "Hattori Earring",
    },
    Herculean = {
        Head  = nil, -- "Herculean Helm"
        Body  = "Herculean Vest",
        Hands = "Herculean Gloves",
        Legs  = "Herculean Trousers",
        Feet  = "Herculean Boots",
    },
    Adhemar = {
        Hands = "Adhemar Wrist. +1",
    },
    Mummu = {
        Head  = "Mummu Bonnet +2",
        Body  = "Mummu Jacket +2",
        Hands = "Mummu Wrists +2",
        Legs  = "Mummu Kecks +2",
        Feet  = "Mummu Gamash. +2",
        Ring  = "Mummu Ring",
    },
    Hizamaru = {
        Head  = "Hiza. Somen +2",
        Body  = "Hiza. Haramaki +2",
        Hands = "Hizamaru Kote +2",
        Legs  = "Hiza. Hizayoroi +2",
        Feet  = "Hiza. Sune-Ate +2",
    },
    Capes = {
        Auto  = { Name = "Andartia's Mantle", Augment = { 'DEX+20', '"Dbl.Atk."+10' } },
        StrWs = { Name = "Andartia's Mantle", Augment = { 'DEX+30', 'Weapon skill damage +10%' } },
        DexWs = { Name = "Andartia's Mantle", Augment = { 'DEX+30', 'Weapon skill damage +10%' } },
        AgiWs = { Name = "Andartia's Mantle", Augment = { 'DEX+30', 'Weapon skill damage +10%' } },
        Cast  = { Name = "Andartia's Mantle", Augment = { 'AGI+20', 'Fast Cast +10%' } },
        Nuke  = { Name = "Andartia's Mantle", Augment = { 'INT+20', '"Mag. Atk. Bns."+10' } },
    },
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = "Staunch Tathlum",

        Head  = gear.Empyrean.Head,
        Body  = gear.Hizamaru.Body,
        Hands = gear.Hizamaru.Hands,
        Legs  = gear.Empyrean.Legs,
        Feet  = gear.Artifact.Feet,

        Neck  = "Sanctity Necklace",
        Ear1  = "Brutal Earring",
        Ear2  = gear.Empyrean.Ear,
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = gear.Capes.Auto,
        Waist = "Sailfi Belt +1",
    },
    TreasureHunter = Equip.NewSet {
        Ammo  = "Per. Lucky Egg",
        Legs  = "Herculean Trousers",
    },
    Melee = {
        Dt = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Hizamaru.Hands,
            Legs  = gear.Empyrean.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Epona's Ring",
            Ring2 = "Defending Ring",
            Back  = gear.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Dps = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = gear.Empyrean.Head,
            Body  = gear.Mummu.Body,
            Hands = gear.Adhemar.Hands,
            Legs  = gear.Mummu.Legs,
            Feet  = gear.Mummu.Feet,

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Epona's Ring",
            Ring2 = "Rajas Ring",
            Back  = gear.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Eva = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = gear.Hizamaru.Head,
            Body  = gear.Hizamaru.Body,
            Hands = gear.Hizamaru.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Epona's Ring",
            Ring2 = "Rajas Ring",
            Back  = gear.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Body  = gear.Relic.Body,
            Neck  = "Voltsurge Torque",
            -- Ring1 = "Weather. Ring",
            -- Ring2 = "Lebeche Ring",
            Back  = gear.Capes.Cast,
        },
        Shadows = Equip.NewSet {
            Ammo  = "Staunch Tathlum",
            Feet  = gear.Empyrean.Feet,
            Back  = gear.Capes.Cast,
        },
        Enfeeble = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Body  = gear.Herculean.Body,
            Back  = gear.Capes.Nuke,
        },
        Nuke = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = gear.Relic.Head,
            Body  = gear.Herculean.Body,
            Hands = gear.Herculean.Hands,
            Legs  = gear.Herculean.Legs,
            Feet  = gear.Artifact.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Friomisi Earring",
            Ring1 = "Shiva Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = gear.Capes.Nuke,
            Waist = "Skrymir Cord",
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = gear.Mummu.Head,
            Body  = gear.Mummu.Body,
            Hands = gear.Mummu.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = gear.Artifact.Ring,
            Ring2 = gear.Mummu.Ring,
            Back  = gear.Capes.DexWs,
        },
        ['Blade: Metsu'] = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = gear.Artifact.Neck,
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = gear.Artifact.Ring,
            Ring2 = "Rajas Ring",
            Back  = gear.Capes.DexWs,
            Waist = "Sailfi Belt +1",
        },
        ['Blade: Ku'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = gear.Mummu.Head,
            Body  = gear.Mummu.Body,
            Hands = gear.Mummu.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = gear.Artifact.Ring,
            Ring2 = gear.Mummu.Ring,
            Back  = gear.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Blade: Shun'] = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = gear.Mummu.Head,
            Body  = gear.Mummu.Body,
            Hands = gear.Mummu.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = gear.Artifact.Ring,
            Ring2 = gear.Mummu.Ring,
            Back  = gear.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Blade: Hi'] = Equip.NewSet {
            Ammo  = "Yetshila",

            Head  = gear.Mummu.Head,
            Body  = gear.Mummu.Body,
            Hands = gear.Mummu.Hands,
            Legs  = gear.Mummu.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = gear.Artifact.Neck,
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = gear.Artifact.Ring,
            Ring2 = gear.Mummu.Ring,
            Back  = gear.Capes.AgiWs,
            Waist = "Sailfi Belt +1",
        },
        ['Blade: Kamu'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = gear.Relic.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = gear.Artifact.Neck,
            Ear1  = "Lugra Earring +1",
            Ear2  = "Hattori Earring",
            Ring1 = gear.Artifact.Ring,
            Ring2 = "Shiva Ring",
            Back  = gear.Capes.DexWs,
            Waist = "Sailfi Belt +1",
        },
        ['Blade: Ten'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = gear.Artifact.Neck,
            Ear1  = "Lugra Earring +1",
            Ear2  = "Odr Earring",
            Ring1 = gear.Artifact.Ring,
            Ring2 = "Rajas Ring",
            Back  = gear.Capes.StrWs,
            Waist = "Sailfi Belt +1",
        },
        ['Aeolian Edge'] = Equip.NewSet {
            Ammo  = "Ghastly Tathlum +1",

            Head  = gear.Relic.Head,
            Body  = gear.Herculean.Body,
            Hands = gear.Herculean.Hands,
            Legs  = gear.Herculean.Legs,
            Feet  = gear.Herculean.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Friomisi Earring",
            Ring1 = "Shiva Ring",
            -- Ring2 = "Weather. Ring",
            Back  = gear.Capes.DexWs,
            Waist = "Skrymir Cord",
        },
        ['Evisceration'] = Equip.NewSet {
            Ammo = "Yetshila",
        },
        ['Savage Blade'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = gear.Relic.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Hizamaru.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Fotia Gorget",
            Ear1  = "Lugra Earring +1",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = gear.Artifact.Ring,
            Ring2 = "Epona's Ring",
            Back  = gear.Capes.StrWs,
            Waist = "Sailfi Belt +1",
        },
    },
}

local function watchFutae(e)
    if e.message:match("Sivvi's Futae effect wears off")
    or e.message:match("Sivvi casts") then
        settings.Futae = false
    end
end

local function changeThotbarPalette(subjob)
    if subjob == nil or subjob == 'NON' or subjob == settings.Subjob then
        return
    end

    local thotbarCmd = '/tb palette change %s'
    chatMgr:QueueCommand(1, thotbarCmd:format(subjob))
    settings.Subjob = subjob
end

local function handleDefault()
    local player = gData.GetPlayer()

    changeThotbarPalette(player.SubJob)

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Melee[settings.MeleeSet])

        if settings.TreasureHunter then
            Equip.Set(sets.TreasureHunter)
        end
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()
    local wsSet = sets.Weaponskills[ws.Name]
    local fallback = sets.Weaponskills.Base

    Equip.Set(wsSet or fallback)
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name == 'Futae' then
        settings.Futae = true
    end
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'

    if Status.IsNuke(spell)
    or Status.IsPotencyNinjutsu(spell)
    or Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.Magic.Nuke)

        if settings.Futae then
            Equip.Hands(gear.Empyrean.Hands)
        end
    end
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'idle' then
        Equip.Set(sets.Idle, true)
    elseif args[1] == 'tp' then
        Equip.Set(sets.Melee[settings.MeleeSet], true)
        ashita.tasks.once(1, function()
            chatMgr:QueueCommand(1, '/checkparam <me>')
            Equip.Set(sets.Idle, true)
        end)
    elseif args[1] == 'melee' and #args == 2 then
        local meleeSet = args[2]:proper()
        if T{ 'Dt', 'Dps', 'Eva' }:contains(meleeSet) then
            settings.MeleeSet = meleeSet
            print(chat.header(addon.name):append(chat.message('Melee set: ')):append(chat.success(meleeSet:upper())))
        end
    elseif args[1] == 'th' then
        settings.TreasureHunter = not settings.TreasureHunter

        if settings.TreasureHunter then
            print(chat.header(addon.name):append(chat.message('Treasure Hunter ')):append(chat.success('ON')))
        else
            print(chat.header(addon.name):append(chat.message('Treasure Hunter ')):append(chat.error('OFF')))
        end
    elseif args[1] == 'gear' then
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
    ashita.events.register('text_in', 'lac_nin_watch_futae', watchFutae)
    chatMgr:QueueCommand(-1, '/addon reload wheel')

    ashita.tasks.once(1, function()
        chatMgr:QueueCommand(1, '/wheel level ni')
        chatMgr:QueueCommand(1, '/wheel alt san')
        chatMgr:QueueCommand(1, '/wheel lock')
    end)
end

local function onUnload()
    ashita.events.unregister('text_in', 'lac_nin_watch_futae')
    chatMgr:QueueCommand(-1, '/addon unload wheel')
end

return {
    Sets              = sets,
    OnLoad            = onLoad,
    OnUnload          = onUnload,
    HandleCommand     = handleCommand,
    HandleDefault     = handleDefault,
    HandleAbility     = handleAbility,
    HandleItem        = gFunc.LoadFile('common/items.lua'),
    HandlePrecast     = handlePrecast,
    HandleMidcast     = handleMidcast,
    HandlePreshot     = noop,
    HandleMidshot     = noop,
    HandleWeaponskill = handleWeaponskill,
}
