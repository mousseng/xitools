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

local sets = {
    Idle = Equip.NewSet {
        Main  = Gear.MaficCudgel,
        Sub   = Gear.Culminus, -- TODO: genbu/genmei shield
        Range = Gear.Displaced,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.GEO.EmpyHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.ShriekerCuffs,
        Legs  = Gear.DoyenPants,
        Feet  = Gear.GEO.AfFeet,

        Neck  = Gear.SanctityNeck,
        -- Ear1  = "",
        -- Ear2  = "",
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.ShneddickRing,
        Back  = Gear.GEO.IdleCape,
        Waist = Gear.LatriaSash,
    },
    Auto = Equip.NewSet {
        Main  = Gear.MaficCudgel,
        Sub   = Gear.Culminus, -- TODO: genbu/genmei shield
        Range = Gear.Displaced,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.GEO.EmpyHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.ShriekerCuffs,
        Legs  = Gear.DoyenPants,
        Feet  = Gear.GEO.AfFeet,

        Neck  = Gear.SanctityNeck,
        -- Ear1  = "",
        -- Ear2  = "",
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.ShneddickRing,
        Back  = Gear.GEO.IdleCape,
        Waist = Gear.LatriaSash,
    },
    ColureIdle = Equip.NewSet {
        -- TODO: stack regen, refresh, dt

        Main  = Gear.Solstice,
        Sub   = Gear.Culminus, -- TODO: genbu/genmei shield
        Range = Gear.Dunna,
        Ammo  = Gear.Displaced,

        Head  = Gear.GEO.EmpyHead,
        Body  = nil,
        Hands = Gear.GEO.AfHands,
        Legs  = nil,
        Feet  = Gear.GEO.RelicFeet,

        Neck  = Gear.GEO.Neck,
        Ear1  = Gear.HypaspistEar,
        Ear2  = nil, -- TODO: odnowa earring
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.ShneddickRing,
        Back  = Gear.GEO.IdleCape,
        Waist = nil,
    },
    ColureCast = Equip.NewSet {
        -- TODO: stack sid, dt

        Main  = Gear.Gada,
        Sub   = Gear.Culminus, -- TODO: genbu/genmei shield
        Range = Gear.Dunna,
        Ammo  = Gear.Displaced,

        Head  = Gear.GEO.EmpyHead,
        Body  = Gear.GEO.RelicBody,
        Hands = Gear.GEO.AfHands,
        Legs  = Gear.GEO.RelicLegs,
        Feet  = Gear.GEO.EmpyFeet,

        Neck  = Gear.GEO.Neck,
        Ear1  = nil,
        Ear2  = Gear.GEO.Ear,
        Ring1 = Gear.DefendingRing,
        Ring2 = nil,
        Back  = Gear.GEO.GeoCape,
        Waist = nil,
    },
    Nuke = Equip.NewSet {
        Main  = Gear.Staccato,
        Sub   = Gear.EnkiStrap,
        Range = Gear.Displaced,
        Ammo  = Gear.GhastlyTath,

        Head  = Gear.GEO.EmpyHead,
        Body  = Gear.JhakriBody, -- TODO: amalric doublet +1
        Hands = Gear.JhakriHands, -- TODO: amalric gages +1
        Legs  = Gear.JhakriLegs,
        Feet  = Gear.GEO.EmpyFeet,

        Neck  = Gear.SanctityNeck, -- TODO: baetyl pendant
        Ear1  = Gear.FriomisiEar, -- TODO: barkarole earring, malignance earring
        Ear2  = Gear.GEO.Ear, -- TODO: azi +1, azi +2, regal earring
        Ring1 = Gear.JhakriRing, -- TODO: shiva +1
        Ring2 = Gear.ShivaRing, -- TODO: freke ring
        Back  = Gear.GEO.NukeCape,
        Waist = Gear.SkrymirCord,
    },
    Drain = Equip.NewSet {
        Main  = Gear.Staccato,
        Sub   = Gear.EnkiStrap,
        Range = Gear.Displaced,
        Ammo  = Gear.StaunchTath, -- TODO: pemphredo tathlum

        Head  = Gear.GEO.RelicHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.JhakriHands,
        Legs  = Gear.GEO.EmpyLegs,
        Feet  = Gear.JhakriFeet, -- TODO: merlinic crackows, agwu's pigaches

        Neck  = Gear.ErraPendant,
        Ear1  = Gear.MendicantEar, -- TODO: hirudinea earring
        Ear2  = Gear.GEO.Ear,
        Ring1 = Gear.JhakriRing, -- TODO: evanescence ring
        Ring2 = nil, -- TODO: archon ring
        Back  = Gear.GEO.NukeCape,
        Waist = Gear.AusterityBelt,
    },
    Enfeeble = Equip.NewSet {
        Main  = Gear.Gada,
        Sub   = Gear.Culminus, -- TODO: macc?
        Range = Gear.Displaced,
        Ammo  = Gear.GhastlyTath, -- TODO: macc or skill

        Head  = Gear.GEO.EmpyHead, -- TODO: macc or skill
        Body  = Gear.JhakriBody, -- TODO: macc or skill
        Hands = Gear.GEO.EmpyHands,
        Legs  = Gear.JhakriLegs, -- TODO: macc or skill
        Feet  = Gear.GEO.RelicFeet,

        Neck  = Gear.GEO.Neck,
        Ear1  = Gear.MendicantEar, -- TODO: macc or skill
        Ear2  = Gear.GEO.Ear,
        Ring1 = Gear.JhakriRing, -- TODO: macc or skill
        Ring2 = Gear.ShivaRing,
        Back  = Gear.GEO.NukeCape,
        Waist = Gear.LatriaSash, -- TODO: macc or skill
    },
    Heal = Equip.NewSet {
        Main  = Gear.Gada,
        Sub   = Gear.Culminus,
        Range = Gear.Displaced,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.GEO.AfHead, -- TODO: anything with more than MND
        Body  = Gear.JhakriBody, -- TODO: anything with more than MND
        Hands = Gear.AyaoGages,
        Legs  = Gear.JhakriLegs, -- TODO: anything with more than MND
        Feet  = Gear.JhakriFeet, -- TODO: anything with more than MND

        Neck  = Gear.SanctityNeck,
        Ear1  = Gear.MendicantEar,
        -- Ear2  = Gear.GEO.Ear,
        Ring1 = Gear.LebecheRing,
        Ring2 = nil,
        Back  = Gear.GEO.NukeCape,
        Waist = Gear.LatriaSash,
    },
    FastCast = Equip.NewSet {
        Main  = Gear.Solstice,
        Sub   = Gear.Culminus,
        Range = Gear.Dunna,
        Ammo  = Gear.Displaced,

        Head  = Gear.NaresCap,
        Body  = Gear.JhakriBody,
        Hands = Gear.JhakriHands,
        Legs  = Gear.GEO.AfLegs,
        Feet  = Gear.JhakriFeet,

        Neck  = Gear.VoltsurgeTorque,
        Ring1 = Gear.JhakriRing,
        Ring2 = nil,
        Back  = Gear.GEO.CastCape,
    },
}

local function handleDefault()
    local player = gData.GetPlayer()
    local luopan = gData.GetPet()

    if Status.IsNewlyIdle(player, luopan) then
        Equip.Set(sets.Idle)
    elseif luopan then
        Equip.Set(sets.ColureIdle)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Auto)
    end
end

local function handleAbility()
    Status.currentStatus = 'Abilitying'
    local ability = gData.GetAction()
    if ability.Name == 'Life Cycle' then
        Equip.Body(Gear.GEO.AfBody)
    elseif ability.Name == 'Full Circle' then
        Equip.Head(Gear.GEO.EmpyHead)
    end
end

local function handlePrecast()
    local spell = gData.GetAction()
    Equip.Set(sets.FastCast)
    if spell.Skill == 'Elemental Magic' then
        Equip.Hands(Gear.GEO.RelicHands)
    elseif spell.Skill == 'Healing Magic' then
        Equip.Ear1(Gear.MendicantEar)
        Equip.Legs(Gear.DoyenPants)
    end
end

local function handleMidcast()
    Status.currentStatus = 'Casting'
    local spell = gData.GetAction()

    if Status.IsColure(spell) then
        Equip.Set(sets.ColureCast)
    elseif Status.IsNuke(spell) then
        Equip.Set(sets.Nuke)
        Equip.Obi(spell)
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Drain)
        Equip.Obi(spell)
    elseif Status.IsHeal(spell) then
        Equip.Set(sets.Heal)
        Equip.Obi(spell)
    end
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'idle' then
        Equip.Set(sets.Idle, true)
    elseif args[1] == 'validate' then
        Gear:Validate()
    end
end

local function onLoad()
    chatMgr:QueueCommand(-1, '/addon reload colure')

    ashita.tasks.once(1, function()
        chatMgr:QueueCommand(1, '/colure lock')
    end)
end

local function onUnload()
    chatMgr:QueueCommand(-1, '/addon unload colure')
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
    HandleWeaponskill = noop,
}
