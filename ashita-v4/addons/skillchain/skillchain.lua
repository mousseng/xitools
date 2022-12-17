addon.name    = 'skillchain'
addon.author  = 'lin'
addon.version = '2.0.0'
addon.desc    = 'A little skillchain tracker so you know when things happen'

local Defaults = require('defaults')
local Skillchain = require('skillchain-core')
local Packets = require('lin.packets')

local Settings = require('settings')
local Fonts = require('fonts')

---@class SkillchainModule
---@field config SkillchainSettings
---@field chains table
---@field font Font|nil
---@field gc table|nil
local Module = {
    config = Settings.load(Defaults),
    chains = { },
    font = nil,
    gc = nil,
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

ashita.events.register('load', 'load_cb', function()
    Module.font = Fonts.new(Module.config.font)
    Module.gc = Skillchain.BeginGarbageCollection(Module.chains)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (Module.font ~= nil) then
        Module.font:destroy()
        Module.font = nil
    end

    if (Module.gc ~= nil) then
        Module.gc:kill()
        Module.gc = nil
    end

    Settings.save()
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x28 then
        local action = Packets.parse_action(e.data)

        if action.category == 3 then
            Skillchain.HandleWeaponskill(action, Module.chains)
        elseif action.category == 4 then
            Skillchain.HandleMagicAbility(action, Module.chains)
        elseif action.category == 13 then
            Skillchain.HandlePetAbility(action, Module.chains)
        end
    end

    return false
end)

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    Module.font.text = Skillchain.Draw(Module.chains)
end)
