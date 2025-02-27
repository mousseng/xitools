require('common')
local noop = function() end
local chat = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local gear = {
    Displaced = "displaced",
    Artifact = {
    },
    Relic = {
    },
    Empyrean = {
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
    },
}

local settings = {
    Subjob = 'NON',
    Grimoire = nil,
    Capes = {
    },
}

local sets = {
    Idle = Equip.NewSet {
        Main  = "Colada",
        Ammo  = "Staunch Tathlum",

        Head  = gear.Jhakri.Head,
        Body  = gear.Jhakri.Body,
        Hands = "Shrieker's Cuffs",
        Legs  = gear.Jhakri.Legs,
        Feet  = "Inspirited Boots",

        Neck  = "Sanctity Necklace",
        Ear1  = "Mendi. Earring",
        Ear2  = "Lethargy Earring",
        Ring1 = "Defending Ring",
        Ring2 = "Shneddick Ring",
        Back  = "Sucellos's Cape",
        Waist = "Sailfi Belt +1",
    },
    Magic = {
        FastCast = Equip.NewSet {
            Main = "Colada",
            Ammo = "Sapience Orb",

            Head  = "Nares Cap",
            Legs  = "Doyen Pants",

            Ear1  = "Mendi. Earring",
            Ear2  = "Lethargy Earring",
            Back  = "Sucellos's Cape",
        },
        Enfeeble = Equip.NewSet {
            Main  = "Colada",
            Ammo  = "Staunch Tathlum",

            Head  = gear.Jhakri.Head,
            Body  = gear.Jhakri.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Jhakri.Legs,
            Feet  = gear.Jhakri.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Mendi. Earring",
            Ear2  = "Lethargy Earring",
            Ring1 = "Weather. Ring +1",
            Ring2 = "Shiva Ring",
            Back  = "Sucellos's Cape",
            Waist = "Skrymir Cord",
        },
        Heal = Equip.NewSet {
            Main  = "Chatoyant Staff",
            Sub   = "Enki Strap",

            Head  = gear.Jhakri.Head,
            Body  = gear.Jhakri.Body,
            Hands = gear.Jhakri.Hands,
            Legs  = gear.Jhakri.Legs,
            Feet  = gear.Jhakri.Feet,

            Neck  = "Sanctity Necklace",
            Ear1  = "Mendi. Earring",
            Ear2  = "Hecate's Earring",
            -- Ring1 = "Mephitas's Ring +1",
            Ring2 = "Lebeche Ring",
            Back  = "Sucellos's Cape",
            Waist = "Skrymir Cord",
        },
        Nuke = Equip.NewSet {
            Main  = "Colada",
            Ammo  = "Staunch Tathlum",

            Head  = "Jhakri Coronal +1",
            Body  = "Jhakri Robe +1",
            Hands = "Jhakri Cuffs +1",
            Legs  = "Jhakri Slops +1",
            Feet  = "Jhakri Pigaches +1",

            Neck  = "Sanctity Necklace",
            Ear1  = "Friomisi Earring",
            Ear2  = "Hecate's Earring",
            Ring1 = "Jhakri Ring",
            Ring2 = "Shiva Ring",
            Back  = "Sucellos's Cape",
            Waist = "Skrymir Cord",
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
        chat:QueueCommand(1, thotbarCmd:format('SCH', grimoire or ''))
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
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'

    if Status.IsNuke(spell) then
        Equip.Set(sets.Magic.Nuke)
    elseif Status.IsHeal(spell) then
        Equip.Set(sets.Magic.Heal)
    elseif Status.IsEnfeebInt(spell) then
        Equip.Set(sets.Magic.Enfeeble)
    elseif Status.IsEnfeebMnd(spell) then
        Equip.Set(sets.Magic.Enfeeble)

        if spell.Name:match('Addle') then
            Equip.Feet('Muddle Pumps')
        end
    end

    Equip.Obi(spell)
end

local function onLoad()
end

local function onUnload()
end

return {
    Sets              = sets,
    OnLoad            = onLoad,
    OnUnload          = onUnload,
    HandleCommand     = noop,
    HandleDefault     = handleDefault,
    HandleAbility     = noop,
    HandleItem        = gFunc.LoadFile('common/items.lua'),
    HandlePrecast     = handlePrecast,
    HandleMidcast     = handleMidcast,
    HandlePreshot     = noop,
    HandleMidshot     = noop,
    HandleWeaponskill = noop,
}
