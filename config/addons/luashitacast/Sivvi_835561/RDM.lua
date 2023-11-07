require('common')
local noop = function() end
local chat = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Subjob = 'NON',
    Capes = {
    },
}

local sets = {
    Idle = Equip.NewSet {
        Main  = "Emissary",
        Ammo  = "Sapience Orb",

        Head  = "Jhakri Coronal",
        Body  = "Jhakri Robe",
        Hands = "Shrieker's Cuffs",
        Legs  = "Jhakri Slops",
        Feet  = "Inspirited Boots",

        Neck  = "Sanctity Necklace",
        Ear1  = "Mendi. Earring",
        Ear2  = "Lethargy Earring",
        Ring1 = "Mephitas's Ring +1",
        Ring2 = "Warp Ring",
        Back  = "Buquwik Cape",
        Waist = "Sailfi Belt +1",
    },
    Melee = {
        Auto = Equip.NewSet {
        },
        GeneralWs = Equip.NewSet {
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Main = "Emissary",
            Ammo = "Sapience Orb",

            Legs  = "Doyen Pants",

            Ear1  = "Mendi. Earring",
            Ear2  = "Lethargy Earring",
            Ring2 = "Weather. Ring",
        },
        Shadows = Equip.NewSet {
        },
        Enfeeble = Equip.NewSet {
        },
        Nuke = Equip.NewSet {
            Main  = "Emissary",
            Ammo  = "Sapience Orb",

            Head  = "Jhakri Coronal",
            Body  = "Jhakri Robe",
            Hands = "Jhakri Cuffs",
            Legs  = "Jhakri Slops",
            Feet  = "Jhakri Pigaches",

            Neck  = "Sanctity Necklace",
            Ear1  = "Mendi. Earring",
            Ear2  = "Hecate's Earring", -- replace mendi later, mp for now
            Ring1 = "Mephitas's Ring +1",
            Ring2 = "Warp Ring",
            Back  = "Buquwik Cape",
            Waist = "Sailfi Belt +1",
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
        Equip.Set(sets.Melee.Auto)
    end
end

local function handleWeaponskill()
    Equip.Set(sets.Melee.GeneralWs)
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsNuke(spell) then
        Equip.Set(sets.Magic.Nuke)
    end
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
    HandleWeaponskill = handleWeaponskill,
}
