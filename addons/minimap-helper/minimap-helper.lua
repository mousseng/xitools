addon.name    = 'minimap-helper'
addon.author  = 'lin'
addon.version = '1.2.0'
addon.desc    = 'Automates minimap scale changes'

local Packets = require('lin.packets')
local Zones = require('minimap-zones')

local CurrentZone = nil
local Scales = {
    Dungeon = 0.4,
    City = 0.5,
    Field = 0.16,
}

local function Contains(array, value)
    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end

    return false
end

local function SetMinimapScale()
    local scale = Scales.Field
    if Contains(Zones.cities, CurrentZone) then
        scale = Scales.City
    elseif Contains(Zones.dungeons, CurrentZone) then
        scale = Scales.Dungeon
    end

    print(string.format('Setting scale for zone %d to %s', CurrentZone, tostring(scale)))
    AshitaCore:GetChatManager():QueueCommand(1, '/minimap zoom ' .. scale)
end

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x000A then
        CurrentZone = Packets.ParseZoneIn(e.data).zone
        SetMinimapScale()
    end
end)

ashita.events.register('load', 'load_cb', function()
    CurrentZone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    SetMinimapScale()
end)
