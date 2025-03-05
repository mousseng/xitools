require('common')
local noop = function() end
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.gear'
local Gear = gFunc.LoadFile('common/gear.lua')
---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Subjob = 'NON',
    Grimoire = nil,
}

local sets = {
    Idle = Equip.NewSet {
        Main  = Gear.Naegling,
        Sub   = Gear.Culminus,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.JhakriHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.ShriekerCuffs,
        Legs  = Gear.JhakriLegs,
        Feet  = Gear.InspiritedBoots,

        Neck  = Gear.SanctityNeck,
        Ear1  = Gear.MendicantEar,
        Ear2  = Gear.RDM.Ear,
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.ShneddickRing,
        Back  = Gear.RDM.IdleCape,
        Waist = Gear.SailfiBelt,
    },
    Enhance = {
        Aquaveil = Equip.NewSet {
        },
        Stoneskin = Equip.NewSet {
        },
        Duration = Equip.NewSet {
        },
    },
    Enfeeble = {
        Macc = Equip.NewSet {
            Main  = Gear.Naegling,
            Sub   = Gear.Culminus,
            Ammo  = Gear.StaunchTath,

            Head  = Gear.JhakriHead,
            Body  = Gear.JhakriBody,
            Hands = Gear.JhakriHands,
            Legs  = Gear.JhakriLegs,
            Feet  = Gear.JhakriFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = nil,
            Ear2  = Gear.RDM.Ear,
            Ring1 = Gear.JhakriRing,
            Ring2 = Gear.AyanmoRing,
            Back  = Gear.RDM.CastCape,
            Waist = Gear.SkrymirCord,
        },
        Skill = Equip.NewSet {
            Main  = Gear.Naegling,
            Sub   = Gear.Culminus,
            Ammo  = Gear.StaunchTath,

            Head  = Gear.JhakriHead,
            Body  = Gear.JhakriBody,
            Hands = Gear.JhakriHands,
            Legs  = Gear.JhakriLegs,
            Feet  = Gear.JhakriFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = nil,
            Ear2  = Gear.RDM.Ear,
            Ring1 = Gear.JhakriRing,
            Ring2 = Gear.AyanmoRing,
            Back  = Gear.RDM.CastCape,
            Waist = Gear.SkrymirCord,
        },
        Int = Equip.NewSet {
            Main  = Gear.Staccato,
            Sub   = Gear.EnkiStrap,
            Ammo  = Gear.StaunchTath,

            Head  = Gear.JhakriHead,
            Body  = Gear.JhakriBody,
            Hands = Gear.JhakriHands,
            Legs  = Gear.JhakriLegs,
            Feet  = Gear.JhakriFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = nil,
            Ear2  = Gear.RDM.Ear,
            Ring1 = Gear.JhakriRing,
            Ring2 = Gear.ShivaRing,
            Back  = Gear.RDM.NukeCape,
            Waist = Gear.SkrymirCord,
        },
        Mnd = Equip.NewSet {
            Main  = Gear.Staccato,
            Sub   = Gear.EnkiStrap,
            Ammo  = Gear.StaunchTath,

            Head  = Gear.JhakriHead,
            Body  = Gear.JhakriBody,
            Hands = Gear.JhakriHands,
            Legs  = Gear.JhakriLegs,
            Feet  = Gear.JhakriFeet,

            Neck  = Gear.SanctityNeck,
            Ear1  = nil,
            Ear2  = Gear.RDM.Ear,
            Ring1 = Gear.JhakriRing,
            Ring2 = Gear.AyanmoRing,
            Back  = Gear.RDM.CastCape,
            Waist = Gear.SkrymirCord,
        },
        Inundation = Equip.NewSet {
        },
    },
    FastCast = Equip.NewSet {
        Main  = Gear.Colada,
        Sub   = Gear.Culminus,
        Ammo  = Gear.SapienceOrb,

        Head  = Gear.NaresCap,
        Body  = Gear.JhakriBody,
        Hands = Gear.JhakriHands,
        Legs  = Gear.DoyenPants,
        Feet  = Gear.JhakriFeet,

        Neck  = Gear.VoltsurgeTorque,
        Ear1  = Gear.MendicantEar,
        Ear2  = Gear.RDM.Ear,
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.JhakriRing,
        Back  = Gear.RDM.CastCape,
        Waist = Gear.SiegelSash,
    },
    Heal = Equip.NewSet {
        Main  = Gear.ChatoyantStaff,
        Sub   = Gear.EnkiStrap,

        Head  = Gear.JhakriHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.AyaoGages,
        Legs  = Gear.JhakriLegs,
        Feet  = Gear.JhakriFeet,

        Neck  = Gear.SanctityNeck,
        Ear1  = Gear.MendicantEar,
        Ear2  = Gear.HecateEar, -- TODO: cure or defensive
        Ring1 = Gear.DefendingRing,
        Ring2 = Gear.LebecheRing,
        Back  = Gear.RDM.HealCape,
        Waist = Gear.AusterityBelt,
    },
    Nuke = Equip.NewSet {
        Main  = Gear.Staccato,
        Sub   = Gear.EnkiStrap,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.JhakriHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.JhakriHands,
        Legs  = Gear.JhakriLegs,
        Feet  = Gear.JhakriFeet,

        Neck  = Gear.SanctityNeck,
        Ear1  = Gear.FriomisiEar,
        Ear2  = Gear.HecateEar,
        Ring1 = Gear.JhakriRing,
        Ring2 = Gear.ShivaRing,
        Back  = Gear.RDM.NukeCape,
        Waist = Gear.SkrymirCord,
    },
    Drain = Equip.NewSet {
        Main  = Gear.Naegling,
        Sub   = Gear.Culminus,
        Ammo  = Gear.StaunchTath,

        Head  = Gear.JhakriHead,
        Body  = Gear.JhakriBody,
        Hands = Gear.JhakriHands,
        Legs  = Gear.JhakriLegs,
        Feet  = Gear.JhakriFeet,

        Neck  = Gear.ErraPendant,
        Ear1  = Gear.MendicantEar,
        Ear2  = Gear.RDM.Ear,
        Ring1 = Gear.JhakriRing,
        Ring2 = Gear.ShivaRing,
        Back  = Gear.RDM.NukeCape,
        Waist = Gear.AusterityBelt,
    },
}

local function changeThotbarPalette(subjob)
    if subjob == nil or subjob == 'NON' or subjob == settings.Subjob then
        return
    end

    local thotbarCmd = '/tb palette change %s'
    chatMgr:QueueCommand(1, thotbarCmd:format(subjob))
    settings.Subjob = subjob
end

local function changeScholarPalette()
    if settings.Subjob ~= 'SCH' then
        return
    end

    local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs()
    local thotbarCmd = '/tb palette change %s%s'
    local lightArts = 358
    local lightGrim = 401
    local darkArts = 359
    local darkGrim = 402
    local grimoire = nil

    for i = 0, 32 do
        local buff = buffs[i]
        if buff == lightArts or buff == lightGrim then
            grimoire = 'L'
            break
        elseif buff == darkArts or buff == darkGrim then
            grimoire = 'D'
            break
        end
    end

    if settings.Grimoire ~= grimoire then
        settings.Grimoire = grimoire
        chatMgr:QueueCommand(1, thotbarCmd:format('SCH', grimoire or ''))
    end
end

local function handleDefault()
    local player = gData.GetPlayer()

    changeThotbarPalette(player.SubJob)
    changeScholarPalette()

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)
    end
end

local function handlePrecast()
    Equip.Set(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'

    if Status.IsNuke(spell) then
        Equip.Set(sets.Nuke)
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Drain)
    elseif Status.IsHeal(spell) then
        Equip.Set(sets.Heal)
    elseif Status.IsEnhancement(spell) then
        local spellSet = sets.Enhance[spell.Name]
        local fallback = sets.Enhance.Duration
        Equip.Set(spellSet or fallback)
    elseif Status.IsEnfeeble(spell) then
        local spellSet = sets.Enfeeble[spell.Name]
        local fallback = sets.Enfeeble.Macc
        Equip.Set(spellSet or fallback)
    end

    Equip.Obi(spell)
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
    sets.Enfeeble['Frazzle III']  = sets.Enfeeble.Skill
    sets.Enfeeble['Distract III'] = sets.Enfeeble.Skill
    sets.Enfeeble['Poison']       = sets.Enfeeble.Skill
    sets.Enfeeble['Poison II']    = sets.Enfeeble.Skill

    sets.Enfeeble['Frazzle II']   = sets.Enfeeble.Macc
    sets.Enfeeble['Dispel']       = sets.Enfeeble.Macc

    -- these macc spells benefit from duration
    sets.Enfeeble['Sleep']        = sets.Enfeeble.Macc
    sets.Enfeeble['Sleep II']     = sets.Enfeeble.Macc
    sets.Enfeeble['Bind']         = sets.Enfeeble.Macc
    sets.Enfeeble['Break']        = sets.Enfeeble.Macc
    sets.Enfeeble['Silence']      = sets.Enfeeble.Macc

    -- these macc spells also benefit from potency
    sets.Enfeeble['Gravity']      = sets.Enfeeble.Macc
    sets.Enfeeble['Gravity II']   = sets.Enfeeble.Macc

    sets.Enfeeble['Paralyze']     = sets.Enfeeble.Mnd
    sets.Enfeeble['Paralyze II']  = sets.Enfeeble.Mnd
    sets.Enfeeble['Addle']        = sets.Enfeeble.Mnd
    sets.Enfeeble['Addle II']     = sets.Enfeeble.Mnd
    sets.Enfeeble['Slow']         = sets.Enfeeble.Mnd
    sets.Enfeeble['Slow II']      = sets.Enfeeble.Mnd

    sets.Enfeeble['Blind']        = sets.Enfeeble.Int
    sets.Enfeeble['Blind II']     = sets.Enfeeble.Int

    chatMgr:QueueCommand(-1, '/addon reload strats')
end

local function onUnload()
    chatMgr:QueueCommand(-1, '/addon unload strats')
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
    HandleWeaponskill = noop,
}
