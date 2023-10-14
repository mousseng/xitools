addon.name    = 'minimap-helper'
addon.author  = 'lin'
addon.version = '2.0'
addon.desc    = 'Automates minimap scale changes'

require('common')
local chat = require('chat')
local settings = require('settings')

local defaultScale = '0.5'
local defaultConfig = T{ }
local config = settings.load(defaultConfig)

settings.register('settings', 'settings_update', function (newConfig)
    if newConfig ~= nil then
        config = newConfig
    end

    settings.save()
end)

---@param str string
local function LogInfo(str, ...)
    print(chat.header(addon.name):append(chat.message(str)):format(...))
end

---@param str string
local function LogError(str, ...)
    print(chat.header(addon.name):append(chat.error(str)):format(...))
end

---Sets the minimap scale and saves to character configuration.
---@param zone  number
---@param scale string
local function SetMinimapScale(zone, scale)
    if tonumber(scale, 10) == nil then
        LogError('%s is not a number', scale)
        return
    end

    config[zone] = scale
    settings.save()

    LogInfo('setting scale for zone %d to %s', zone, tostring(scale))
    AshitaCore:GetChatManager():QueueCommand(1, '/minimap zoom ' .. scale)
end

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()
    if #args < 2 or args[1] ~= '/mmh' then
        return
    end

    local zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    SetMinimapScale(zone, args[2])
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x0A then
        local zone = struct.unpack('i2', e.data, 0x30 + 1)
        SetMinimapScale(zone, config[zone] or defaultScale)
    end
end)

ashita.events.register('load', 'load_cb', function()
    local zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    SetMinimapScale(zone, config[zone] or defaultScale)
end)
