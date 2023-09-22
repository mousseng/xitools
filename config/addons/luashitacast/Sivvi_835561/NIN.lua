require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Main = "Kanaria",
    Sub  = "Shigi",
    Ammo = "Date Shuriken",
}

local sets = {
    Idle = Equip.NewSet {
        Feet = "Hachi. Kyahan +1",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
    },
    Melee = {
        Auto = Equip.NewSet {
            Head = "Hizamaru Somen +1",
            Neck = "Sanctity Necklace",
            Ear1 = "Brutal Earring",
            Ear2 = "Odr Earring",

            Body = "Hiza. Haramaki +2",
            Hands = "Hizamaru Kote +1",
            Ring1 = "Epona's Ring",
            Ring2 = "Mummu Ring",

            Back = "Andartia's Mantle",
            Waist = "Sailfi Belt +1",
            Legs = "Hiza. Hizayoroi +2",
            Feet = "Hiz. Sune-Ate +1",
        },
        Throw = Equip.NewSet {
        },
        BladeKu = Equip.NewSet {
        },
        BladeShun = Equip.NewSet {
        },
        BladeHi = Equip.NewSet {
            Hands = "Mummu Wrists +1",
            Feet = "Mummu Gamash. +1",
        },
        AeolianEdge = Equip.NewSet {
            Head = "Taeon Chapeau",
            Hands = "Taeon Gloves",
            Feet = "Hachi. Kyahan +1",
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

local function handleDefault()
    local player = gData.GetPlayer()

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Melee.Auto)
    else
        Equip.Feet(sets.Idle.Feet)
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()

    if ws.Name == 'Blade: Shun' then
        Equip.Set(sets.Melee.BladeShun)
    elseif ws.Name == 'Blade: Hi' then
        Equip.Set(sets.Melee.BladeHi)
    elseif ws.Name == 'Blade: Ku' then
        Equip.Set(sets.Melee.BladeKu)
    elseif ws.Name == 'Aeolian Edge' then
        Equip.Set(sets.Melee.AeolianEdge)
    end
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'gear' then
        Equip.Main(settings.Main, true)
        Equip.Sub(settings.Sub, true)
        Equip.Ammo(settings.Ammo, true)
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
    HandleCommand = handleCommand,
    HandleDefault = handleDefault,
    HandleAbility = noop,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = noop,
    HandlePreshot = noop,
    HandleMidcast = noop,
    HandleMidshot = noop,
    HandleWeaponskill = handleWeaponskill,
}
