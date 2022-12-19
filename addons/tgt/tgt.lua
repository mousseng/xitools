addon.name    = 'tgt'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for target status'

local Defaults = require('defaults')
local Settings = require('settings')
local Fonts = require('fonts')

local Packets = require('lin.packets')
local Tgt = require('tgt-core')

---@class Debuffs
---@field dia number
---@field bio number
---@field para number
---@field slow number
---@field grav number
---@field blind number
---@field silence number
---@field sleep number
---@field bind number
---@field stun number
---@field virus number
---@field curse number
---@field poison number
---@field shock number
---@field rasp number
---@field choke number
---@field frost number
---@field burn number
---@field drown number

---@alias TrackedEnemies { [number]: Debuffs }

---@class TgtModule
---@field config TgtSettings
---@field debuffs TrackedEnemies
---@field font Font?

---@type TgtModule
local Module = {
    config = Settings.load(Defaults),
    debuffs = { },
    font = nil,
}

Settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        Module.config = s
    end

    if (Module.font ~= nil) then
        Module.font:apply(Module.config.font)
    end

    Settings.save()
end)

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    Module.font.text = Tgt.Draw(
        Module.debuffs,
        Module.config.status,
        Module.config.dependent)
end)

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()

    if #args < 2 or args[1] ~= '/tgt' then
        return false
    end

    if args[2] == 'line' then
        Module.config.dependent = not Module.config.dependent
    elseif args[2] == 'status' then
        Module.config.status = not Module.config.status
    elseif args[2] == 'dump' then
        print(tostring(Module.debuffs))

        for id, mob in pairs(Module.debuffs) do
            print(string.format(
                '[%s] id %i: '
                .. 'dia %s, bio %s, para %s, slow %s, grav %s, bld %s, '
                .. 'sil %s, slp %s, bind %s, pois %s, '
                .. 'sh %s, ra %s, ch %s, fr %s, bu %s, dr %s',
                tostring(mob), id,
                tostring(mob.dia),
                tostring(mob.bio),
                tostring(mob.para),
                tostring(mob.slow),
                tostring(mob.grav),
                tostring(mob.blind),
                tostring(mob.silence),
                tostring(mob.sleep),
                tostring(mob.bind),
                tostring(mob.poison),
                tostring(mob.shock),
                tostring(mob.rasp),
                tostring(mob.choke),
                tostring(mob.frost),
                tostring(mob.burn),
                tostring(mob.drown)
            ))
        end
    end

    return false
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    -- don't track anything if we're not displaying it
    if not Module.config.status then return end

    -- clear state on zone changes
    if e.id == 0x0A then
        Module.debuffs = { }
    elseif e.id == 0x0028 then
        Tgt.HandleAction(Module.debuffs, Packets.parse_action(e.data))
    elseif e.id == 0x0029 then
        Tgt.HandleBasic(Module.debuffs, Packets.parse_basic(e.data))
    end

    return false
end)

ashita.events.register('load', 'load_cb', function()
    Module.font = Fonts.new(Module.config.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (Module.font ~= nil) then
        -- TODO: do we need to manually persist location changes?
        --       if so, maybe just :apply() to the settings object
        Module.font:destroy()
        Module.font = nil
    end

    Settings.save()
end)
