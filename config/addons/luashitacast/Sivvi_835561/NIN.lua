require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Main = "Senjuinrikio",
    Sub  = "Fudo",
    Ammo = "Dart",
}

local sets = {
    Idle = Equip.NewSet {
    },
    Melee = {
        Auto = Equip.NewSet {
        },
        Throw = Equip.NewSet {
        },
        BladeKu = Equip.NewSet {
        },
        BladeShun = Equip.NewSet {
        },
        BladeHi = Equip.NewSet {
        },
    },
    Magic = {
        Shadows = Equip.NewSet {
        },
        Enfeeble = Equip.NewSet {
        },
        Nuke = Equip.NewSet {
        },
    },
}

local function handleWeaponskill()
    local ws = gData.GetAction()
    if ws.Name == 'Blade: Shun' then
    elseif ws.Name == 'Blade: Hi' then
    elseif ws.Name == 'Blade: Ku' then
    end
end

local function onLoad()
    AshitaCore:GetChatManager():QueueCommand(-1, '/addon reload wheel')
    ashita.tasks.once(1, function()
        AshitaCore:GetChatManager():QueueCommand( 1, '/wheel level san')
        AshitaCore:GetChatManager():QueueCommand( 1, '/wheel lock')
    end)
end

local function onUnload()
    AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload wheel')
end

return {
    Sets = sets,
    OnLoad = onLoad,
    OnUnload = onUnload,
    HandleCommand = noop,
    HandleDefault = noop,
    HandleAbility = noop,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = noop,
    HandlePreshot = noop,
    HandleMidcast = noop,
    HandleMidshot = noop,
    HandleWeaponskill = handleWeaponskill,
}
