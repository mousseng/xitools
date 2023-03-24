addon.name      = 'clock'
addon.author    = 'badbeat'
addon.version   = '1.0.0'
addon.desc      = 'Addon to display real life time in the game.'

require('common')
local Settings = require('settings')
local Ffxi = require('lin.ffxi')
local Imgui = require('lin.imgui')

local Defaults = {
    windowName ='Clock',
    windowSize = { 75, 10 },
    windowPos = { 100, 100}
}

local Config = Settings.load(Defaults)

local Windows = {}

local function DrawTimer(notes)
    Imgui.Text(os.date("%H:%M:%S"))
end

local function removeWindow() 
end

local function removeMob(name)
end

local function UpdateSettings(s)
    if (s ~= nil) then
        Config = s
    end

    Settings.save()
end

local function OnLoad()
end

local function OnPacket(e)
end

local function OnUnload()
    UpdateSettings()
end

---@param e CommandEventArgs
local function OnCommand(e)
end

local function OnPresent()
    if not Ffxi.IsChatExpanded() then
        Imgui.Lin.DrawWindow(Config.windowName, Config.windowSize, Config.windowPos, function()
            DrawTimer()
        end)
    end
end


Settings.register('settings', 'settings_update', UpdateSettings)
ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('unload', 'on_unload', OnUnload)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('packet_in', 'on_packet_in', OnPacket)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
