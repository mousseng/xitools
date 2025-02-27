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
    Diffusion = false,
    MeleeSet = 'Dps',
    Default = {
        Main = "Naegling",
        Sub  = "Colada",
        Ammo = "Staunch Tathlum",
    },
}

local gear = {
    Displaced = "displaced",
    Artifact = {
        Head  = "Assim. Keffiyeh",
        Body  = "Assim. Jubbah",
        Hands = "Assim. Bazu.",
        Legs  = "Assim. Shalwar",
        Feet  = "Assim. Charuqs",
    },
    Relic = {
        -- Head  = "Luhlaza",
        -- Body  = "Luhlaza",
        -- Hands = "Luhlaza",
        -- Legs  = "Luhlaza",
        Feet  = "Luhlaza Charuqs",
        Neck  = "Mirage Stole +1",
    },
    Empyrean = {
        Head  = "Hashishin Kavuk +2",
        Body  = "Hashishin Mintan +2",
        Hands = "Hashi. Bazu. +2",
        Legs  = "Hashishin Tayt +2",
        Feet  = "Hashi. Basmak +2",
        Ear   = "Hashishin Earring",
    },
    Ayanmo = {
        Head  = "Aya. Zucchetto +2",
        Body  = "Ayanmo Corazza +1",
        Hands = "Aya. Manopolas +1",
        Legs  = "Aya. Cosciales +1",
        Feet  = "Aya. Gambieras +1",
        Ring  = "Ayanmo Ring",
    },
    Jhakri = {
        Head  = "Jhakri Coronal +1",
        Body  = "Jhakri Robe +1",
        Hands = "Jhakri Cuffs +2",
        Legs  = "Jhakri Slops +1",
        Feet  = "Jhakri Pigaches +1",
        Ring  = "Jhakri Ring",
    },
    Capes = {
        Idle  = { Name = "Rosemerta's Cape", Augment = { 'DEX+30' } }, -- doesn't exist yet
        Auto  = { Name = "Rosemerta's Cape", Augment = { 'DEX+30' } },
        DexWs = { Name = "Rosemerta's Cape", Augment = { 'DEX+30' } }, -- just using the TP cape for now
        StrWs = { Name = "Rosemerta's Cape", Augment = { 'DEX+30' } }, -- doesn't exist yet
        Cast  = { Name = "Rosemerta's Cape", Augment = { 'INT+20' } }, -- doesn't exist yet
        Nuke  = { Name = "Rosemerta's Cape", Augment = { 'INT+20' } },
    },
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = "Staunch Tathlum",

        Head  = gear.Ayanmo.Head,
        Body  = gear.Empyrean.Body,
        Hands = gear.Empyrean.Hands,
        Legs  = gear.Empyrean.Legs,
        Feet  = gear.Ayanmo.Feet,

        Neck  = "Sanctity Necklace",
        Ear1  = "Brutal Earring",
        Ear2  = gear.Empyrean.Ear,
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = gear.Capes.Idle,
        Waist = "Sailfi Belt +1",
    },
    Melee = {
        Dps = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = gear.Ayanmo.Head,
            Body  = gear.Ayanmo.Body,
            Hands = gear.Ayanmo.Hands,
            Legs  = gear.Jhakri.Legs,
            Feet  = gear.Ayanmo.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Epona's Ring",
            Ring2 = gear.Ayanmo.Ring,
            Back  = gear.Capes.Auto,
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = gear.Jhakri.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Ayanmo.Legs,
            Feet  = gear.Jhakri.Feet,

            Neck  = "Voltsurge Torque",
            -- Ring1 = "Weather. Ring",
            Ring2 = gear.Jhakri.Ring,
            Back  = gear.Capes.Cast,
        },
        Nuke = Equip.NewSet {
            -- Ammo  = "Sapience Orb",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Empyrean.Hands,
            Legs  = gear.Empyrean.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Friomisi Earring",
            Ear2  = "Hecate's Earring",
            Ring1 = "Shiva Ring",
            Ring2 = gear.Jhakri.Ring,
            Back  = gear.Capes.Nuke,
            Waist = "Skrymir Cord",
        }
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = gear.Jhakri.Head,
            Body  = gear.Jhakri.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Jhakri.Legs,
            Feet  = gear.Jhakri.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Epona's Ring",
            Ring2 = gear.Jhakri.Ring,
            Back  = "Aptitude Mantle +1",
            Waist = "Sailfi Belt +1",
        },
        ['Chant du Cygne'] = Equip.NewSet {
            Ammo  = "Staunch Tathlum",

            Head  = gear.Empyrean.Head,
            Body  = gear.Ayanmo.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Empyrean.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = "Rajas Ring",
            Ring2 = gear.Ayanmo.Ring,
            Back  = gear.Capes.DexWs,
            Waist = "Fotia Belt",
        },
        ['Savage Blade'] = Equip.NewSet {
            Ammo  = "Staunch Tathlum",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Empyrean.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = gear.Relic.Neck,
            Ear1  = "Odr Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = gear.Jhakri.Ring,
            Ring2 = gear.Ayanmo.Ring,
            Back  = gear.Capes.StrWs,
            Waist = "Latria Sash",
        },
        ['Requiescat'] = Equip.NewSet {
            Ammo  = "Staunch Tathlum",

            Head  = gear.Empyrean.Head,
            Body  = gear.Empyrean.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Empyrean.Legs,
            Feet  = gear.Empyrean.Feet,

            Neck  = "Fotia Gorget",
            Ear1  = "Odr Earring",
            Ear2  = gear.Empyrean.Ear,
            Ring1 = gear.Jhakri.Ring,
            Ring2 = gear.Ayanmo.Ring,
            Back  = gear.Capes.MndWs,
            Waist = "Fotia Belt",
        },
    },
}

local function watchDiffusion(e)
    if e.message:match("Sivvi's Diffusion effect wears off")
    or e.message:match("Sivvi casts") then
        settings.Diffusion = false
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
    if ability.Name == 'Diffusion' then
        settings.Diffusion = true
    end
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'
    Equip.Set(sets.Magic.Nuke)
    Equip.Obi(spell)

    if settings.Diffusion then
        Equip.Feet(gear.Relic.Feet)
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
        if T{ 'Dps', }:contains(meleeSet) then
            settings.MeleeSet = meleeSet
            print(chat.header(addon.name):append(chat.message('Melee set: ')):append(chat.success(meleeSet:upper())))
        end
    elseif args[1] == 'gear' then
        Equip.Main(settings.Default.Main, true)
        Equip.Sub(settings.Default.Sub, true)
        Equip.Ammo(settings.Default.Ammo, true)
    end
end

local function onLoad()
    ashita.events.register('text_in', 'lac_blu_watch_diffusion', watchDiffusion)
    chatMgr:QueueCommand(-1, '/addon reload blumon')
    chatMgr:QueueCommand(-1, '/addon reload blusets')
    chatMgr:QueueCommand(-1, '/addon reload blucheck')
end

local function onUnload()
    ashita.events.unregister('text_in', 'lac_blu_watch_diffusion')
    chatMgr:QueueCommand(-1, '/addon unload blumon')
    chatMgr:QueueCommand(-1, '/addon unload blusets')
    chatMgr:QueueCommand(-1, '/addon unload blucheck')
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
