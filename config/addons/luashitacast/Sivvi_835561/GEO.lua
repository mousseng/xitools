require('common')
local noop = function() end
local chat = require('chat')
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local gear = {
    Displaced = "displaced",
    Artifact = {
        Head  = "Geo. Galero +2",
        Body  = "Geo. Tunic +1",
        Hands = "Geo. Mitaines +2",
        Legs  = "Geo. Pants +2",
        Feet  = "Geo. Sandals +2",
    },
    Relic = {
        Head  = "Bagua Galero",
        Body  = "Bagua Tunic +1",
        Hands = "Bagua Mitaines",
        Legs  = "Bagua Pants +2",
        Feet  = "Bagua Sandals +1",
        Neck  = "Bagua Charm +1",
    },
    Empyrean = {
        Head  = "Azimuth Hood +2",
        Body  = "Azimuth Coat",
        Hands = "Azimuth Gloves",
        Legs  = "Azimuth Tights",
        Feet  = "Azimuth Gaiters +2",
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
        Idle  = { Name = "Nantosuelta's Cape", Augment = { [1] = 'VIT+20', [2] = 'Pet: "Regen"+10' } },
        Cast  = { Name = "Nantosuelta's Cape", Augment = { [1] = 'VIT+10', [2] = 'Fast Cast +10%' } },
        -- Nuke  = { Name = "Nantosuelta's Cape", Augment = { [1] = 'INT+20', [2] = '"Mag. Atk. Bns."+10' } },
    },
}

local sets = {
    Idle = Equip.NewSet {
        Main  = "Mafic Cudgel",
        Sub   = gear.Displaced, -- TODO: genbu/genmei shield
        Range = gear.Displaced,
        Ammo  = "Staunch Tathlum",

        Head  = gear.Empyrean.Head,
        Body  = gear.Jhakri.Body,
        Hands = "Shrieker's Cuffs",
        Legs  = "Doyen Pants",
        Feet  = gear.Artifact.Feet,

        Neck  = "Sanctity Necklace",
        -- Ear1  = "",
        -- Ear2  = "",
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = gear.Capes.Idle,
        Waist = "Latria Sash",
    },
    Auto = Equip.NewSet {
        Main  = "Mafic Cudgel",
        Sub   = gear.Displaced, -- TODO: genbu/genmei shield
        Range = gear.Displaced,
        Ammo  = "Staunch Tathlum",

        Head  = gear.Empyrean.Head,
        Body  = gear.Jhakri.Body,
        Hands = "Shrieker's Cuffs",
        Legs  = "Doyen Pants",
        Feet  = gear.Artifact.Feet,

        Neck  = "Sanctity Necklace",
        -- Ear1  = "",
        -- Ear2  = "",
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = gear.Capes.Idle,
        Waist = "Latria Sash",
    },
    ColureIdle = Equip.NewSet {
        -- TODO: stack regen, refresh, dt

        Main  = "Solstice",
        Sub   = gear.Displaced, -- TODO: genbu/genmei shield
        Range = "Dunna",
        Ammo  = gear.Displaced,

        Head  = gear.Empyrean.Head,
        Body  = nil,
        Hands = gear.Artifact.Hands,
        Legs  = nil,
        Feet  = gear.Relic.Feet,

        Neck  = gear.Relic.Neck,
        Ear1  = "Hypaspist Earring",
        Ear2  = nil, -- TODO: odnowa earring
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = gear.Capes.Idle,
        Waist = nil,
    },
    ColureCast = Equip.NewSet {
        -- TODO: stack sid, dt

        Main  = "Gada",
        Sub   = gear.Displaced, -- TODO: genbu/genmei shield
        Range = "Dunna",
        Ammo  = gear.Displaced,

        Head  = gear.Empyrean.Head,
        Body  = gear.Relic.Body,
        Hands = gear.Artifact.Hands,
        Legs  = gear.Relic.Legs,
        Feet  = gear.Empyrean.Feet,

        Neck  = gear.Relic.Neck,
        Ear1  = nil,
        Ear2  = "Azimuth Earring",
        Ring1 = "Defending Ring",
        Ring2 = nil,
        Back  = gear.Capes.Idle,
        Waist = nil,
    },
    Nuke = Equip.NewSet {
        Main  = "Staccato Staff",
        Sub   = "Enki Strap",
        Range = gear.Displaced,
        Ammo  = "Ghastly Tathlum +1",

        Head  = gear.Empyrean.Head,
        Body  = gear.Jhakri.Body, -- TODO: amalric doublet +1
        Hands = gear.Jhakri.Hands, -- TODO: amalric gages +1
        Legs  = gear.Jhakri.Legs,
        Feet  = gear.Empyrean.Feet,

        Neck  = "Sanctity Necklace", -- TODO: baetyl pendant
        Ear1  = "Friomisi Earring", -- TODO: barkarole earring, malignance earring
        Ear2  = "Azimuth Earring", -- TODO: azi +1, azi +2, regal earring
        Ring1 = gear.Jhakri.Ring, -- TODO: shiva +1
        Ring2 = "Shiva Ring", -- TODO: freke ring
        Back  = gear.Capes.Nuke,
        Waist = "Skrymir Cord",
    },
    Drain = Equip.NewSet {
        Main  = "Staccato Staff",
        Sub   = "Enki Strap",
        Range = gear.Displaced,
        Ammo  = "Staunch Tathlum", -- TODO: pemphredo tathlum

        Head  = gear.Relic.Head,
        Body  = gear.Jhakri.Body,
        Hands = gear.Jhakri.Hands,
        Legs  = gear.Empyrean.Legs,
        Feet  = gear.Jhakri.Feet, -- TODO: merlinic crackows, agwu's pigaches

        Neck  = "Erra Pendant",
        Ear1  = "Mendi. Earring", -- TODO: hirudinea earring
        Ear2  = "Azimuth Earring",
        Ring1 = gear.Jhakri.Ring, -- TODO: evanescence ring
        Ring2 = nil, -- TODO: archon ring
        Back  = gear.Capes.Nuke,
        -- Waist = "Skrymir Cord", -- TODO: macc or skill
    },
    Enfeeble = Equip.NewSet {
        Main  = "Gada",
        Sub   = gear.Displaced,
        Range = gear.Displaced,
        Ammo  = "Ghastly Tathlum +1", -- TODO: macc or skill

        Head  = gear.Empyrean.Head, -- TODO: macc or skill
        Body  = gear.Jhakri.Body, -- TODO: macc or skill
        Hands = gear.Empyrean.Hands,
        Legs  = gear.Jhakri.Legs, -- TODO: macc or skill
        Feet  = gear.Relic.Feet,

        Neck  = gear.Relic.Neck,
        Ear1  = "Mendi. Earring", -- TODO: macc or skill
        Ear2  = "Azimuth Earring",
        Ring1 = gear.Jhakri.Ring, -- TODO: macc or skill
        Ring2 = "Shiva Ring",
        Back  = gear.Capes.Nuke,
        Waist = "Latria Sash", -- TODO: macc or skill
    },
    Heal = Equip.NewSet {
        Main  = "Gada",
        Sub   = gear.Displaced,
        Range = gear.Displaced,
        Ammo  = "Staunch Tathlum",

        Head  = gear.Artifact.Head, -- TODO: anything with more than MND
        Body  = gear.Jhakri.Body, -- TODO: anything with more than MND
        Hands = "Ayao's Gages",
        Legs  = gear.Jhakri.Legs, -- TODO: anything with more than MND
        Feet  = gear.Jhakri.Feet, -- TODO: anything with more than MND

        Neck  = "Sanctity Necklace",
        Ear1  = "Mendi. Earring",
        -- Ear2  = "Azimuth Earring",
        Ring1 = "Lebeche Ring",
        Ring2 = nil,
        Back  = gear.Capes.Nuke,
        Waist = "Latria Sash",
    },
    FastCast = Equip.NewSet {
        Main  = "Solstice",
        Sub   = gear.Displaced,
        Range = "Dunna",
        Ammo  = gear.Displaced,

        Head  = "Nares Cap",
        Body  = gear.Jhakri.Body,
        Hands = gear.Jhakri.Hands,
        Legs  = gear.Artifact.Legs,
        Feet  = gear.Jhakri.Feet,

        Neck  = "Voltsurge Torque",
        Ring1 = gear.Jhakri.Ring,
        Ring2 = nil,
        Back  = gear.Capes.Cast,
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
        Equip.Body(gear.Artifact.Body)
    elseif ability.Name == 'Full Circle' then
        Equip.Head(gear.Empyrean.Head)
    end
end

local function handlePrecast()
    local spell = gData.GetAction()
    Equip.Set(sets.FastCast)
    if spell.Skill == 'Elemental Magic' then
        Equip.Hands(gear.Relic.Hands)
    elseif spell.Skill == 'Healing Magic' then
        Equip.Ear1("Mendi. Earring")
        Equip.Legs("Doyen Pants")
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
