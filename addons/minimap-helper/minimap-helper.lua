addon.name    = 'minimap-helper'
addon.author  = 'lin'
addon.version = '1.2.0'
addon.desc    = 'Automates minimap scale changes'

local Defaults = require('defaults')
local Settings = require('settings')
local Packets = require('lin.packets')

---@class MinimapHelperModule
---@field config MinimapHelperSettings
---@field currentZone number?

---@type MinimapHelperModule
local Module = {
    config = Settings.load(Defaults),
    currentZone = nil,
}

---@param scale number
---@param shouldSave boolean
local function SetMinimapScale(scale, shouldSave)
    print(string.format('Setting scale for zone %d to %s', Module.currentZone, tostring(scale)))

    if shouldSave then
        print('Saving config...')
        Module.config.zoneScales[Module.currentZone] = scale
        Settings.save()
    end

    AshitaCore:GetChatManager():QueueCommand(1, '/minimap zoom ' .. scale)
end

local function ApplyConfiguredMinimapScale()
    local zone = Module.currentZone
    local scale = Module.config.zoneScales[zone]
    SetMinimapScale(scale, false)
end

ashita.events.register('command', 'command_cb', function(e)
    ---@type string[]
    local args = e.command:args()

    if #args == 0 or args[1] ~= '/mmh' then
        return false
    end

    local scale = tonumber(args[2])
    if scale ~= nil then
        SetMinimapScale(scale, true)
    end

    return true
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x000A then
        local zone = Packets.ParseZoneIn(e.data).zone
        Module.currentZone = zone
        ApplyConfiguredMinimapScale()
    end
end)

ashita.events.register('load', 'load_cb', function()
    local zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    Module.currentZone = zone
    ApplyConfiguredMinimapScale()
end)

ashita.events.register('unload', 'unload_cb', function()
    Settings.save()
end)
