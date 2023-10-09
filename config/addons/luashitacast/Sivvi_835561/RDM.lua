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
        Main = "Tokko Knife",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
    },
    Melee = {
        Auto = Equip.NewSet {
        },
        GeneralWs = Equip.NewSet {
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ring1 = "Weather. Ring",
        },
        Shadows = Equip.NewSet {
        },
        Enfeeble = Equip.NewSet {
        },
        Nuke = Equip.NewSet {
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

    if Status.IsAttacking(player) then
        Equip.Set(sets.Melee.Auto)
    else
        Equip.Set(sets.Idle)
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()
    Equip.Set(sets.Melee.GeneralWs)
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    Equip.Main("Chatoyant Staff")
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
