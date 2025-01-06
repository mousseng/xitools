require('common')
local noop = function() end
local chat = require('chat')
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Capes = {},
}

local sets = {
    Idle = Equip.NewSet {
        Ammo = "Staunch Tathlum",

        Ring1 = "Defending Ring",
        Ring2 = "Warp Ring",
    },
    ColureIdle = Equip.NewSet {
        Range = "Filiae Bell",
    },
    ColureCast = Equip.NewSet {
        Range = "Filiae Bell",
    },
    Nuke = Equip.NewSet {
    },
    FastCast = Equip.NewSet {
        Ammo = "Sapience Orb",
        Head = "Nares Cap",
        Hands = "Jhakri Cuffs +2",
        Ring1 = "Jhakri Ring",
        Ring2 = "Weather. Ring",
    },
}

local function handleDefault()
    local player = gData.GetPlayer()
    local luopan = gData.GetPet()

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)

        if luopan then
            Equip.Set(sets.ColureIdle)
        end
    end
end

local function handlePrecast()
    Equip.Set(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'

    if Status.IsColure(spell) then
        Equip.Set(sets.ColureCast)
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
    HandleAbility     = noop,
    HandleItem        = gFunc.LoadFile('common/items.lua'),
    HandlePrecast     = handlePrecast,
    HandleMidcast     = handleMidcast,
    HandlePreshot     = noop,
    HandleMidshot     = noop,
    HandleWeaponskill = noop,
}
