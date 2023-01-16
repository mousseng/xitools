addon.name    = 'xitools'
addon.author  = 'lin'
addon.version = '0.5'
addon.desc    = 'A humble UI toolkit'

require('common')
local bit = require('bit')
local ffxi = require('utils.ffxi')
local imgui = require('imgui')
local settings = require('settings')
local ui = require('ui')

---@class xitool
---@field Load            function
---@field DrawMain        function
---@field DrawConfig      function
---@field HandlePacket    function
---@field HandlePacketOut function

local tools = {
    require('me'),
    require('us'),
    require('tgt'),
    require('crafty'),
    require('logger'),
}

local defaultOptions = T{
    globals = T{
        showDemo = T{ false },
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
        crafty = T{
            isVisible = T{ false },
            isEnabled = T{ true },
            name = 'xitools.crafty',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = ImGuiWindowFlags_NoResize,
            skills = T{
                [0] = T{ 0.0 },
                [1] = T{ 0.0 },
                [2] = T{ 0.0 },
                [3] = T{ 0.0 },
                [4] = T{ 0.0 },
                [5] = T{ 0.0 },
                [6] = T{ 0.0 },
                [7] = T{ 0.0 },
                [8] = T{ 0.0 },
            },
            history = T{},
        },
        logger = T{
            isVisible = T{ false },
            loggedPackets = T{
                inbound = T{
                    [0x028] = { true },
                    [0x029] = { true },
                    [0x030] = { true },
                    [0x062] = { true },
                    [0x06F] = { true },
                    [0x070] = { true },
                },
                outbound = T{
                    [0x096] = { true },
                },
            }
        },
    },
}

local options = settings.load(defaultOptions)

local function DrawConfig()
    if not options.tools.config.isVisible then return end

    ui.DrawNormalWindow(options.tools.config, function()
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
            for i, tool in ipairs(tools) do
                tool.DrawConfig(options.tools[tool.Name])
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
    for i, tool in ipairs(tools) do
        tool.Load(options.tools[tool.Name])
    end
end)

ashita.events.register('unload', 'unload_handler', function()
    settings.save()
end)

local demo = { true }
ashita.events.register('d3d_present', 'd3d_present_handler', function()
    if options.globals.showDemo[1] then
        imgui.ShowDemoWindow(options.globals.showDemo)
    end

    DrawConfig()

    if (options.globals.hideUnderChat[1] and ffxi.IsChatExpanded())
    or (options.globals.hideUnderMap[1] and ffxi.IsMapOpen())
    or (options.globals.hideWhileLoading[1] and GetPlayerEntity() == nil) then
        return
    end

    for i, tool in ipairs(tools) do
        if options.tools[tool.Name].isVisible[1] then
            tool.DrawMain(options.tools[tool.Name])
        end
    end
end)

ashita.events.register('packet_out', 'packet_out_handler', function(e)
    for i, tool in ipairs(tools) do
        tool.HandlePacketOut(e, options.tools[tool.Name])
    end
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    for i, tool in ipairs(tools) do
        tool.HandlePacket(e, options.tools[tool.Name])
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

    if #args == 2 and args[2] == 'demo' then
        demo[1] = true
    end

    if #args == 2 and T{'craft','crafty'}:contains(args[2]) then
        options.tools.crafty.isVisible[1] = not options.tools.crafty.isVisible[1]
    end

    if #args == 3 and T{'craft','crafty'}:contains(args[2]) and T{'cl','clear'}:contains(args[3]) then
        options.tools.crafty.history = T{}
    end
end)
