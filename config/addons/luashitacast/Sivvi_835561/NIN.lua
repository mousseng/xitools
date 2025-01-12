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
        Main = "Naegling",
        Sub  = "Ternion Dagger +1",
        Ammo = "Date Shuriken",
    },
    Merit = {
        Main = "Kaja Knife",
        Sub  = "Naegling",
        Ammo = "Date Shuriken",
    },
    Capes = {
        Auto  = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+20', [2] = '"Dbl.Atk."+10', } },
        -- StrWs = { Name = "Andartia's Mantle", Augment = { [1] = 'STR+30', [2] = 'Weapon skill damage +10%', } },
        DexWs = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+30', [2] = 'Weapon skill damage +10%', } },
        -- AgiWs = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+30', [2] = 'Weapon skill damage +10%', } },
        Cast  = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+20', [2] = 'Fast Cast +10%', } },
        Nuke  = { Name = "Andartia's Mantle", Augment = { [1] = 'INT+20', [2] = '"Mag. Atk. Bns."+10' } },
    },
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = "Date Shuriken",

        Head  = "Hattori Zukin +2",
        Body  = "Hiza. Haramaki +2",
        Hands = "Hizamaru Kote +2",
        Legs  = "Hattori Hakama +2",
        Feet  = "Hachiya Kyahan +2",

        Neck  = "Sanctity Necklace",
        Ear1  = "Brutal Earring",
        Ear2  = "Hattori Earring",
        Ring1 = "Defending Ring",
        Ring2 = "Warp Ring",
        Back  = settings.Capes.Auto,
        Waist = "Sailfi Belt +1",
    },
    TreasureHunter = Equip.NewSet {
        Legs  = "Herculean Trousers",
    },
    Melee = {
        Dt = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Hattori Zukin +2",
            Body  = "Hattori Ningi +2",
            Hands = "Hizamaru Kote +2",
            Legs  = "Hattori Hakama +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = "Hattori Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Defending Ring",
            Back  = settings.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
        Dps = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Hattori Zukin +2",
            Body  = "Mummu Jacket +2",
            Hands = "Adhemar Wrist. +1",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Moonbeam Nodowa",
            Ear1  = "Brutal Earring",
            Ear2  = "Hattori Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Rajas Ring",
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
            Ear2  = "Hattori Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Rajas Ring",
            Back  = settings.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Body  = "Mochi. Chainmail +1",
            Ring1 = "Weather. Ring",
            Ring2 = "Lebeche Ring",
            Back  = settings.Capes.Cast,
        },
        Shadows = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Feet  = "Hattori Kyahan",
            Back  = settings.Capes.Cast,
        },
        Enfeeble = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Body  = "Herculean Vest",
            Back  = settings.Capes.Nuke,
        },
        Nuke = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = "Mochi. Hatsuburi +2",
            Body  = "Herculean Vest",
            Hands = "Herculean Gloves",
            Legs  = "Herculean Trousers",
            Feet  = "Hachiya Kyahan +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Friomisi Earring",
            Ring1 = "Shiva Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = settings.Capes.Nuke,
            Waist = "Skrymir Cord",
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Blade: Ku'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Blade: Shun'] = Equip.NewSet {
            Ammo  = "Date Shuriken",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Blade: Hi'] = Equip.NewSet {
            Ammo  = "Yetshila",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Hattori Kyahan +2",

            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Blade: Kamu'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mochi. Hatsuburi +2",
            Body  = "Hattori Ningi +2",
            Hands = "Hattori Tekko +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Hattori Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Shiva Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Aeolian Edge'] = Equip.NewSet {
            Ammo  = "Ghastly Tathlum +1",

            Head  = "Mochi. Hatsuburi +2",
            Body  = "Herculean Vest",
            Hands = "Herculean Gloves",
            Legs  = "Herculean Trousers",
            Feet  = "Herculean Boots",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Friomisi Earring",
            Ring1 = "Shiva Ring",
            Ring2 = "Weather. Ring",
            Back  = settings.Capes.DexWs,
            Waist = "Skrymir Cord",
        },
        ['Exenterator'] = Equip.NewSet {
            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = settings.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Evisceration'] = Equip.NewSet {
            Ammo = "Yetshila",
        },
        ['Savage Blade'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mochi. Hatsuburi +2",
            Body  = "Hattori Ningi +2",
            Hands = "Hattori Tekko +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Hattori Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Epona's Ring",
            Back  = settings.Capes.DexWs,
        },
        ['Circle Blade'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mochi. Hatsuburi +2",
            Body  = "Hattori Ningi +2",
            Hands = "Hattori Tekko +2",
            Legs  = "Hiza. Hizayoroi +2",
            Feet  = "Hattori Kyahan +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Hattori Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Epona's Ring",
            Back  = settings.Capes.DexWs,
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
            Equip.Hands("Hattori Tekko +2")
        end
    end
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'idle' then
        Equip.Set(sets.Idle, true)
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
