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
        Body  = "Bagua Tunic",
        Hands = "Bagua Mitaines",
        Legs  = "Bagua Pants +1",
        Feet  = "Bagua Sandals",
    },
    Empyrean = {
        Head  = "Azimuth Hood",
        Body  = "Azimuth Coat",
        Hands = "Azimuth Gloves",
        Legs  = "Azimuth Tights",
        Feet  = "Azimuth Gaiters",
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
        Range = nil,
        Ammo  = "Staunch Tathlum",

        Head  = gear.Jhakri.Head,
        Body  = gear.Jhakri.Body,
        Hands = "Shrieker's Cuffs",
        Legs  = "Doyen Pants",
        Feet  = gear.Artifact.Feet,

        Neck  = "Sanctity Necklace",
        -- Ear1  = "",
        -- Ear2  = "",
        Ring1 = "Defending Ring",
        Ring2 = "Warp Ring",
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
        -- Body  = "",
        Hands = gear.Artifact.Hands,
        -- Legs  = "",
        Feet  = gear.Relic.Feet,

        -- Neck  = "",
        Ear1  = "Hypaspist Earring",
        -- Ear2  = "",
        -- Ring1 = "",
        -- Ring2 = "",
        Back  = gear.Capes.Idle,
        -- Waist = "",
    },
    ColureCast = Equip.NewSet {
        -- TODO: stack sid, dt

        Main  = "Solstice",
        Sub   = gear.Displaced, -- TODO: genbu/genmei shield
        Range = "Dunna",
        Ammo  = nil,

        Head  = gear.Empyrean.Head,
        Body  = gear.Relic.Body,
        Hands = gear.Artifact.Hands,
        Legs  = gear.Relic.Legs,
        Feet  = gear.Empyrean.Feet,

        -- Neck  = "",
        -- Ear1  = "",
        Ear2  = "Azimuth Earring",
        -- Ring1 = "",
        -- Ring2 = "",
        Back  = gear.Capes.Idle,
        -- Waist = "",
    },
    Nuke = Equip.NewSet {
        Main  = "Staccato Staff",
        Sub   = "Enki Strap",
        Range = nil,
        Ammo  = "Ghastly Tathlum +1",

        Head  = gear.Jhakri.Head,
        Body  = gear.Jhakri.Body, -- TODO: amalric doublet +1
        Hands = gear.Jhakri.Hands, -- TODO: amalric gages +1
        Legs  = gear.Jhakri.Legs,
        Feet  = gear.Jhakri.Feet,

        Neck  = "Sanctity Necklace", -- TODO: baetyl pendant
        Ear1  = "Friomisi Earring", -- TODO: barkarole earring, malignance earring
        Ear2  = "Azimuth Earring", -- TODO: azi +1, azi +2, regal earring
        Ring1 = gear.Jhakri.Ring, -- TODO: shiva +1
        Ring2 = "Weather. Ring", -- TODO: freke ring
        -- Back  = gear.Capes.Nuke,
        Waist = "Skrymir Cord",
    },
    Heal = Equip.NewSet {
        Main  = "Chatoyant Staff",
        Sub   = "Enki Strap",
        Range = nil,
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
        Ring2 = "Weather. Ring",
        -- Back  = gear.Capes.Nuke,
        Waist = "Latria Sash",
    },
    Enfeeble = Equip.NewSet {
    },
    FastCast = Equip.NewSet {
        Range = "Dunna",
        Ammo  = gear.Displaced,

        Head  = "Nares Cap",
        Body  = gear.Jhakri.Body,
        Hands = gear.Jhakri.Hands,
        Legs  = gear.Artifact.Legs,
        Feet  = gear.Jhakri.Feet,

        Neck  = "Voltsurge Torque",
        Ring1 = gear.Jhakri.Ring,
        Ring2 = "Weather. Ring",
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
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Nuke)
        Equip.Head(gear.Relic.Head)
        Equip.Neck("Erra Pendant")
    elseif Status.IsHeal(spell) then
        Equip.Set(sets.Heal)
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
