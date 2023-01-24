addon.name    = 'xitools'
addon.author  = 'lin'
addon.version = '0.6'
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
    require('tracker'),
    require('crafty'),
    require('fishe'),
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
            isEnabled = T{ true },
            isVisible = T{ true },
            name = 'xitools.config',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = ImGuiWindowFlags_NoResize,
        },
        me = T{
            isEnabled = T{ false },
            isVisible = T{ true },
            name = 'xitools.me',
            size = T{ 277, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        us = T{
            isEnabled = T{ false },
            isVisible = T{ true },
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
            isEnabled = T{ false },
            isVisible = T{ true },
            showStatus = T{ false },
            name = 'xitools.tgt',
            size = T{ 277, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        tracker = T{
            isEnabled = T{ false },
            isVisible = T{ true },
            name = 'xitools.tracker',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
            trackers = T{
                -- for type: 4 is spell, 6 is job ability
                T{ IsEnabled = T{ false }, Id = 547, Name = '', Type = 6, Duration =  30, ActiveItems = T{}, }, -- provoke
                T{ IsEnabled = T{ false }, Id = 556, Name = '', Type = 6, Duration =  60, ActiveItems = T{}, }, -- sneak
                T{ IsEnabled = T{ false }, Id = 588, Name = '', Type = 6, Duration =  60, ActiveItems = T{}, }, -- trick
                T{ IsEnabled = T{ false }, Id =  57, Name = '', Type = 4, Duration = 180, ActiveItems = T{}, }, -- haste
                T{ IsEnabled = T{ false }, Id = 109, Name = '', Type = 4, Duration = 150, ActiveItems = T{}, }, -- refresh
                T{ IsEnabled = T{ false }, Id = 108, Name = '', Type = 4, Duration =  75, ActiveItems = T{}, }, -- regen i
                T{ IsEnabled = T{ false }, Id = 110, Name = '', Type = 4, Duration =  60, ActiveItems = T{}, }, -- regen ii
                T{ IsEnabled = T{ false }, Id = 111, Name = '', Type = 4, Duration =  60, ActiveItems = T{}, }, -- regen iii
                T{ IsEnabled = T{ false }, Id = 386, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- ballad i
                T{ IsEnabled = T{ false }, Id = 387, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- ballad ii
                T{ IsEnabled = T{ false }, Id = 394, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet i
                T{ IsEnabled = T{ false }, Id = 395, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet ii
                T{ IsEnabled = T{ false }, Id = 396, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet iii
                T{ IsEnabled = T{ false }, Id = 397, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet iv
                T{ IsEnabled = T{ false }, Id = 399, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- sword madrigal
                T{ IsEnabled = T{ false }, Id = 400, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- blade madrigal
            },
        },
        crafty = T{
            isEnabled = T{ false },
            isVisible = T{ true },
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
        fishe = T{
            isEnabled = T{ false },
            isVisible = T{ true },
            name = 'xitools.fishe',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = ImGuiWindowFlags_None,
            skill = T{ 0.0 },
            history = T{},
        },
        logger = T{
            isEnabled = T{ false },
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
        if options.tools[tool.Name].isEnabled[1] then
            tool.DrawMain(options.tools[tool.Name])
        end
    end
end)

ashita.events.register('packet_out', 'packet_out_handler', function(e)
    for i, tool in ipairs(tools) do
        if options.tools[tool.Name].isEnabled[1] then
            tool.HandlePacketOut(e, options.tools[tool.Name])
        end
    end
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    for i, tool in ipairs(tools) do
        if options.tools[tool.Name].isEnabled[1] then
            tool.HandlePacket(e, options.tools[tool.Name])
        end
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
        options.globals.showDemo[1] = true
    end

    if #args == 2 and T{'craft','crafty'}:contains(args[2]) then
        options.tools.crafty.isVisible[1] = not options.tools.crafty.isVisible[1]
    end

    if #args == 3 and T{'craft','crafty'}:contains(args[2]) and T{'cl','clear'}:contains(args[3]) then
        options.tools.crafty.history = T{}
    end

    if #args == 2 and T{'fish','fishe'}:contains(args[2]) then
        options.tools.fishe.isVisible[1] = not options.tools.fishe.isVisible[1]
    end

    if #args == 3 and T{'fish','fishe'}:contains(args[2]) and T{'cl','clear'}:contains(args[3]) then
        options.tools.fishe.history = T{}
    end
end)
