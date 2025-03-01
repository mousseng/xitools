require('common')
local noop = function() end
local chat = require('chat')
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.gear'
local Gear = gFunc.LoadFile('common/gear.lua')
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
        Main = Gear.Kikoku,
        Sub  = Gear.Ternion,
        Ammo = Gear.DateShuriken,
    },
    Merit = {
        Main = Gear.Tauret,
        Sub  = Gear.Naegling,
        Ammo = Gear.DateShuriken,
    },
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = Gear.StaunchTath,

        Head  = Gear.NIN.EmpyHead,
        Body  = Gear.HizamaruBody,
        Hands = Gear.HizamaruHands,
        Legs  = Gear.NIN.EmpyLegs,
        Feet  = Gear.NIN.AfFeet,

        Neck  = Gear.SanctityNeck,
        Ear1  = Gear.BrutalEar,
        Ear2  = Gear.NIN.Ear,
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.ShneddickRing,
        Back  = Gear.NIN.AutoCape,
        Waist = Gear.SailfiBelt,
    },
    TreasureHunter = Equip.NewSet {
        Ammo  = Gear.LuckyEgg,
        Legs  = Gear.HercLegs,
    },
    Melee = {
        Dt = Equip.NewSet {
            Ammo  = Gear.DateShuriken,

            Head  = Gear.NIN.EmpyHead,
            Body  = Gear.NIN.EmpyBody,
            Hands = Gear.HizamaruHands,
            Legs  = Gear.NIN.EmpyLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.MoonbeamNodowa,
            Ear1  = Gear.BrutalEar,
            Ear2  = Gear.NIN.Ear,
            Ring1 = Gear.EponaRing,
            Ring2 = Gear.DefendingRing,
            Back  = Gear.NIN.AutoCape,
            Waist = Gear.SailfiBelt,
        },
        Dps = Equip.NewSet {
            Ammo  = Gear.DateShuriken,

            Head  = Gear.NIN.EmpyHead,
            Body  = Gear.MummuBody,
            Hands = Gear.AdhemarHands,
            Legs  = Gear.MummuLegs,
            Feet  = Gear.MummuFeet,

            Neck  = Gear.MoonbeamNodowa,
            Ear1  = Gear.BrutalEar,
            Ear2  = Gear.NIN.Ear,
            Ring1 = Gear.EponaRing,
            Ring2 = Gear.RajasRing,
            Back  = Gear.NIN.AutoCape,
            Waist = Gear.SailfiBelt,
        },
        Eva = Equip.NewSet {
            Ammo  = Gear.DateShuriken,

            Head  = Gear.HizamaruHead,
            Body  = Gear.HizamaruBody,
            Hands = Gear.HizamaruHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.MoonbeamNodowa,
            Ear1  = Gear.BrutalEar,
            Ear2  = Gear.NIN.Ear,
            Ring1 = Gear.EponaRing,
            Ring2 = Gear.RajasRing,
            Back  = Gear.NIN.AutoCape,
            Waist = Gear.SailfiBelt,
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = Gear.SapienceOrb,
            Body  = Gear.NIN.RelicBody,
            Neck  = Gear.VoltsurgeTorque,
            -- Ring1 = "Weather. Ring",
            -- Ring2 = "Lebeche Ring",
            Back  = Gear.NIN.CastCape,
        },
        Shadows = Equip.NewSet {
            Ammo  = Gear.StaunchTath,
            Feet  = Gear.NIN.EmpyFeet,
            Back  = Gear.NIN.CastCape,
        },
        Enfeeble = Equip.NewSet {
            Ammo  = Gear.SapienceOrb,
            Body  = Gear.HercBody,
            Back  = Gear.NIN.NukeCape,
        },
        Nuke = Equip.NewSet {
            Ammo  = Gear.SapienceOrb,

            Head  = Gear.NIN.RelicHead,
            Body  = Gear.HercBody,
            Hands = Gear.HercHands,
            Legs  = Gear.HercLegs,
            Feet  = Gear.NIN.AfFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = Gear.HecateEar,
            Ear2  = Gear.FriomisiEar,
            Ring1 = Gear.ShivaRing,
            Ring2 = Gear.MephitasRing,
            Back  = Gear.NIN.NukeCape,
            Waist = Gear.SkrymirCord,
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = Gear.SeethingBomb,

            Head  = Gear.MummuHead,
            Body  = Gear.MummuBody,
            Hands = Gear.MummuHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Ear1  = Gear.OdrEar,
            Ear2  = Gear.LugraEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.MummuRing,
            Back  = Gear.NIN.DexCape,
        },
        ['Blade: Metsu'] = Equip.NewSet {
            Ammo  = Gear.DateShuriken,

            Head  = Gear.NIN.EmpyHead,
            Body  = Gear.NIN.EmpyBody,
            Hands = Gear.NIN.EmpyHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.NIN.Neck,
            Ear1  = Gear.OdrEar,
            Ear2  = Gear.LugraEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.RajasRing,
            Back  = Gear.NIN.DexCape,
            Waist = Gear.SailfiBelt,
        },
        ['Blade: Ku'] = Equip.NewSet {
            Ammo  = Gear.SeethingBomb,

            Head  = Gear.MummuHead,
            Body  = Gear.MummuBody,
            Hands = Gear.MummuHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.FotiaGorget,
            Ear1  = Gear.OdrEar,
            Ear2  = Gear.LugraEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.MummuRing,
            Back  = Gear.NIN.DexCape,
            Waist = Gear.FotiaBelt,
        },
        ['Blade: Shun'] = Equip.NewSet {
            Ammo  = Gear.DateShuriken,

            Head  = Gear.MummuHead,
            Body  = Gear.MummuBody,
            Hands = Gear.MummuHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.FotiaGorget,
            Ear1  = Gear.OdrEar,
            Ear2  = Gear.LugraEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.MummuRing,
            Back  = Gear.NIN.DexCape,
            Waist = Gear.FotiaBelt,
        },
        ['Blade: Hi'] = Equip.NewSet {
            Ammo  = Gear.Yetshila,

            Head  = Gear.MummuHead,
            Body  = Gear.MummuBody,
            Hands = Gear.MummuHands,
            Legs  = Gear.MummuLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.NIN.Neck,
            Ear1  = Gear.OdrEar,
            Ear2  = Gear.LugraEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.MummuRing,
            Back  = Gear.NIN.AgiCape,
            Waist = Gear.SailfiBelt,
        },
        ['Blade: Kamu'] = Equip.NewSet {
            Ammo  = Gear.SeethingBomb,

            Head  = Gear.NIN.RelicHead,
            Body  = Gear.NIN.EmpyBody,
            Hands = Gear.NIN.EmpyHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.NIN.Neck,
            Ear1  = Gear.LugraEar,
            Ear2  = Gear.NIN.Ear,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.ShivaRing,
            Back  = Gear.NIN.DexCape,
            Waist = Gear.SailfiBelt,
        },
        ['Blade: Ten'] = Equip.NewSet {
            Ammo  = Gear.SeethingBomb,

            Head  = Gear.NIN.EmpyHead,
            Body  = Gear.NIN.EmpyBody,
            Hands = Gear.NIN.EmpyHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.NIN.Neck,
            Ear1  = Gear.LugraEar,
            Ear2  = Gear.OdrEar,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.RajasRing,
            Back  = Gear.NIN.StrCape,
            Waist = Gear.SailfiBelt,
        },
        ['Aeolian Edge'] = Equip.NewSet {
            Ammo  = Gear.GhastlyTath,

            Head  = Gear.NIN.RelicHead,
            Body  = Gear.HercBody,
            Hands = Gear.HercHands,
            Legs  = Gear.HercLegs,
            Feet  = Gear.HercFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = Gear.HecateEar,
            Ear2  = Gear.FriomisiEar,
            Ring1 = Gear.ShivaRing,
            -- Ring2 = "Weather. Ring",
            Back  = Gear.NIN.DexCape,
            Waist = Gear.SkrymirCord,
        },
        ['Evisceration'] = Equip.NewSet {
            Ammo = Gear.Yetshila,
        },
        ['Savage Blade'] = Equip.NewSet {
            Ammo  = Gear.SeethingBomb,

            Head  = Gear.NIN.RelicHead,
            Body  = Gear.NIN.EmpyBody,
            Hands = Gear.NIN.EmpyHands,
            Legs  = Gear.HizamaruLegs,
            Feet  = Gear.NIN.EmpyFeet,

            Neck  = Gear.FotiaGorget,
            Ear1  = Gear.LugraEar,
            Ear2  = Gear.NIN.Ear,
            Ring1 = Gear.RegalRing,
            Ring2 = Gear.EponaRing,
            Back  = Gear.NIN.StrCape,
            Waist = Gear.SailfiBelt,
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
            Equip.Hands(Gear.NIN.EmpyHands)
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
    elseif args[1] == 'validate' then
        Gear:Validate()
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
