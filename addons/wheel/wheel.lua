addon.name    = 'wheel'
addon.author  = 'lin'
addon.version = '1.0'
addon.desc    = 'gavlan wheel, gavlan deal'

require('common')
local ffxi = require('ffxi')
local state = require('state')
local renderer = require('renderer')

local LevelMap = {
    ['Ichi'] = true,
    ['Ni']   = true,
    ['San']  = true,
}

local function AdvanceWheelTo(position)
    if position % 6 == renderer.animation.targetPos then
        return
    end

    renderer.animation.currentPos = state.position
    renderer.animation.targetPos = position % 6
    state.position = position % 6
end

local function PrintHelp()
    -- TODO
end

local function GetLevelFromArgs(args)
    local level = args[3]:proper()
    if LevelMap[level] == nil then
        PrintHelp()
        return nil
    end

    return level
end

local function OnLoad()
    renderer.init(state)
end

local function OnCommand(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/wheel' then
        return
    end

    if #args == 1 then
        PrintHelp()
        return
    end

    local verb = args[2]:lower()
    if verb == 'level' then
        if #args == 2 then
            PrintHelp()
            return
        end

        local level = GetLevelFromArgs(args)
        state.level = level
    elseif verb == 'alt' then
        if #args == 2 then
            PrintHelp()
            return
        end

        local level = GetLevelFromArgs(args)
        state.alt = level
    elseif verb == 'spin' then
        if #args == 2 then
            state.cast(state.position, state.level)
            return
        end

        local level = GetLevelFromArgs(args)
        state.cast(state.position, level)
    elseif verb == 'lock' then
        renderer.lock()
    elseif verb == 'unlock' then
        renderer.unlock()
    elseif verb == 'go' then
        AdvanceWheelTo(args[3] or state.position + 1)
    elseif verb == 'debug' then
        state.debug = not state.debug
    else
        PrintHelp()
    end
end

---@param e PacketInEventArgs
local function OnPacketIn(e)
    if e.id ~= 0x28 then return end

    local entity = GetPlayerEntity()
    if entity == nil then return end

    local actor = ashita.bits.unpack_be(e.data_raw, 40, 32)
    if actor ~= entity.ServerId then return end

    local type = ashita.bits.unpack_be(e.data_raw, 82, 4)
    if type ~= 4 then return end

    local spell = ashita.bits.unpack_be(e.data_raw, 86, 16)
    if spell < 320 or spell > 337 then return end

    AdvanceWheelTo(state.lookup[spell] + 1)
end

local function OnPresent()
    renderer.calc(state)

    if GetPlayerEntity() == nil
    or ffxi.IsMapOpen()
    or ffxi.IsChatExpanded()
    or ffxi.IsEventHappening()
    or ffxi.IsInterfaceHidden() then
        return
    end

    renderer.draw(state)
end

ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('packet_in', 'on_packet_in', OnPacketIn)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
