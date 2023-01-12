addon.name    = 'xitools'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'A humble UI toolkit'

require('common')
local bit = require('bit')
local ffxi = require('utils.ffxi')
local imgui = require('imgui')
local settings = require('settings')
local ui = require('ui')

---@class xitool
---@field Load         function
---@field DrawMain     function
---@field DrawConfig   function
---@field HandlePacket function

local tools = {
    me = require('me'),
    us = require('us'),
    tgt = require('tgt'),
}

local defaultOptions = T{
    globals = T{
        hideUnderMap = T{ true },
        hideUnderChat = T{ true },
        hideWhileLoading = T{ true },
    },
    tools = T{
        config = T{
            isVisible = T{ false },
            name = 'xitools.config',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = ImGuiWindowFlags_NoResize,
        },
        me = T{
            isVisible = T{ false },
            name = 'xitools.me',
            size = T{ 277, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        us = T{
            isVisible = T{ false },
            hideWhenSolo = T{ false },
            showCastbar = T{ true },
            alliance1 = T{
                isVisible = T{ true },
                name = 'xitools.us.1',
                size = T{ 277, -1 },
                pos = T{ 392, 628 },
                flags = bit.bor(ImGuiWindowFlags_NoDecoration),
            },
            alliance2 = T{
                isVisible = T{ true },
                name = 'xitools.us.2',
                size = T{ 277, -1 },
                pos = T{ 107, 628 },
                flags = bit.bor(ImGuiWindowFlags_NoDecoration),
            },
            alliance3 = T{
                isVisible = T{ true },
                name = 'xitools.us.3',
                size = T{ 277, -1 },
                pos = T{ 000, 628 },
                flags = bit.bor(ImGuiWindowFlags_NoDecoration),
            },
        },
        tgt = T{
            isVisible = T{ false },
            showStatus = T{ false },
            name = 'xitools.tgt',
            size = T{ 277, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
    },
}

local options = settings.load(defaultOptions)

local function DrawConfig()
    if not options.tools.config.isVisible then return end

    ui.DrawWindow(options.tools.config, function()
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, ui.Styles.FramePaddingSome)

        imgui.Text('Global settings')
        imgui.Separator()
        imgui.Checkbox('Hide while map open', options.globals.hideUnderMap)
        imgui.Checkbox('Hide while chat open', options.globals.hideUnderChat)
        imgui.Checkbox('Hide while loading', options.globals.hideWhileLoading)
        imgui.NewLine()

        imgui.Text('Tool settings')
        imgui.Separator()
        if imgui.BeginTabBar('xitools.config.tabs') then
            for name, tool in pairs(tools) do
                tool.DrawConfig(options.tools[name])
            end

            imgui.EndTabBar()
        end

        imgui.PopStyleVar()
    end)
end

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        options = s
    end

    settings.save()
end)

ashita.events.register('load', 'load_handler', function()
    for name, tool in pairs(tools) do
        tool.Load(options.tools[name])
    end
end)

ashita.events.register('unload', 'unload_handler', function()
    settings.save()
end)

ashita.events.register('d3d_present', 'd3d_present_handler', function()
    DrawConfig()

    if (options.globals.hideUnderChat[1] and ffxi.IsChatExpanded())
    or (options.globals.hideUnderMap[1] and ffxi.IsMapOpen())
    or (options.globals.hideWhileLoading[1] and GetPlayerEntity() == nil) then
        return
    end

    for name, tool in pairs(tools) do
        if options.tools[name].isVisible[1] then
            tool.DrawMain(options.tools[name])
        end
    end
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    for name, tool in pairs(tools) do
        tool.HandlePacket(e, options.tools[name])
    end
end)

ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()

    if #args == 0 or not T{'/xit','/xitools'}:contains(args[1]) then
        return
    end

    if #args == 1 or args[2] == 'config' then
        options.tools.config.isVisible[1] = not options.tools.config.isVisible[1]
    end
end)
