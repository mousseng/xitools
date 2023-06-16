addon.name    = 'wheel'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'gavlan wheel, gavlan deal'

require('common')
local ffxi = require('ffxi')
local state = require('state')
local renderer = require('renderer')

local function AdvanceWheelTo(position)
    renderer.animation.current = 0
    renderer.animation.progress = 0
    renderer.animation.distance = (position - state.position + 6) % 6
    state.position = position % 6
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
        -- TODO: print help
        return
    end

    if args[2]:lower() == 'level' then
        if #args == 2 then
            -- TODO: print help
            return
        end

        state.level = args[3]:proper()
    elseif args[2]:lower() == 'lock' then
        renderer.lock()
    elseif args[2]:lower() == 'unlock' then
        renderer.unlock()
    elseif args[2]:lower() == 'ichi' or args[2] == '1' then
        state.cast(state.position, 'Ichi')
    elseif args[2]:lower() == 'ni' or args[2] == '2' then
        state.cast(state.position, 'Ni')
    elseif args[2]:lower() == 'san' or args[2] == '3' then
        state.cast(state.position, 'San')
    end
end

---@param e PacketInEventArgs
local function OnPacketIn(e)
    if e.id == 0x028 then
        local actor = ashita.bits.unpack_be(e.data_raw, 40, 32)
        local type = ashita.bits.unpack_be(e.data_raw, 82, 4)
        local spell = ashita.bits.unpack_be(e.data_raw, 86, 16)

        if actor == GetPlayerEntity().ServerId and type == 4 and spell >= 320 and spell <= 337 then
            AdvanceWheelTo(state.lookup[spell] + 1)
        end
    end
end

local function OnPresent()
    renderer.calc(state)

    if GetPlayerEntity() == nil or ffxi.IsMapOpen() or ffxi.IsChatExpanded() then
        return
    end

    renderer.draw(state)
end

ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('packet_in', 'on_packet_in', OnPacketIn)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
