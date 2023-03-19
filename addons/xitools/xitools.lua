addon.name    = 'xitools'
addon.author  = 'lin'
addon.version = '0.11'
addon.desc    = 'A humble UI toolkit'

require('common')
local ffxi = require('utils.ffxi')
local imgui = require('imgui')
local settings = require('settings')
local ui = require('ui')

---@class xitool
---@field Name            string
---@field Aliases         string[]?
---@field DefaultSettings table
---@field UpdateSettings  function?
---@field Load            function?
---@field HandlePacket    function?
---@field HandlePacketOut function?
---@field HandleCommand   function?
---@field DrawConfig      function
---@field DrawMain        function

local me = require('me')
local us = require('us')
local tgt = require('tgt')
local pet = require('pet')
local inv = require('inv')
local tracker = require('tracker')
local crafty = require('crafty')
local fishe = require('fishe')
local logger = require('logger')

local tools = {
    me,
    us,
    tgt,
    pet,
    inv,
    tracker,
    crafty,
    fishe,
    logger,
}

local defaultOptions = T{
    globals = T{
        showDemo = T{ false },
        hideUnderMap = T{ true },
        hideUnderChat = T{ true },
        hideWhileLoading = T{ true },
        uiScale = T{ 1.0 },
        baseW = 7,
        baseH = 14,
    },
    tools = T{
        config = T{
            isEnabled = T{ true },
            isVisible = T{ false },
            name = 'xitools.config',
            size = T{ -1, -1 },
            pos = T{ 100, 100 },
            flags = ImGuiWindowFlags_NoResize,
        },
        me = me.DefaultSettings,
        us = us.DefaultSettings,
        tgt = tgt.DefaultSettings,
        pet = pet.DefaultSettings,
        inv = inv.DefaultSettings,
        tracker = tracker.DefaultSettings,
        crafty = crafty.DefaultSettings,
        fishe = fishe.DefaultSettings,
        logger = logger.DefaultSettings,
    },
}

local options = settings.load(defaultOptions)

local function DrawConfig()
    if not options.tools.config.isVisible then return end

    ui.DrawNormalWindow(options.tools.config, options.globals, function()
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, ui.Styles.FramePaddingSome)

        imgui.Text('Global settings')
        imgui.Separator()
        imgui.Checkbox('Hide while map open', options.globals.hideUnderMap)
        imgui.Checkbox('Hide while chat open', options.globals.hideUnderChat)
        imgui.Checkbox('Hide while loading', options.globals.hideWhileLoading)
        if imgui.InputFloat('UI Scale', options.globals.uiScale, 0.01, 0.025) then
            imgui.SetWindowFontScale(options.globals.uiScale[1])
            options.globals.baseH, options.globals.baseH = imgui.CalcTextSize('A')
        end
        imgui.NewLine()

        imgui.Text('Tool settings')
        imgui.Separator()
        if imgui.BeginTabBar('xitools.config.tabs') then
            for i, tool in ipairs(tools) do
                tool.DrawConfig(options.tools[tool.Name], options.globals)
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

    for _, tool in ipairs(tools) do
        if tool.UpdateSettings ~= nil then
            tool.UpdateSettings(options.tools[tool.Name], options.globals)
        end
    end
end)

ashita.events.register('load', 'load_handler', function()
    for _, tool in ipairs(tools) do
        if tool.Load ~= nil then
            tool.Load(options.tools[tool.Name], options.globals)
        end
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
            tool.DrawMain(options.tools[tool.Name], options.globals)
        end
    end
end)

ashita.events.register('packet_out', 'packet_out_handler', function(e)
    for _, tool in ipairs(tools) do
        if options.tools[tool.Name].isEnabled[1] and tool.HandlePacketOut ~= nil then
            tool.HandlePacketOut(e, options.tools[tool.Name], options.globals)
        end
    end
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    for _, tool in ipairs(tools) do
        if options.tools[tool.Name].isEnabled[1] and tool.HandlePacket ~= nil then
            tool.HandlePacket(e, options.tools[tool.Name], options.globals)
        end
    end
end)

ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()
    local cmd = args[1]
    local verb = args[2]

    if cmd == nil or (cmd ~= '/xit' and cmd ~= '/xitools') then
        return
    end

    if verb == nil or verb == 'config' then
        options.tools.config.isVisible[1] = not options.tools.config.isVisible[1]
    end

    if verb == 'demo' then
        options.globals.showDemo[1] = true
    end

    for _, tool in ipairs(tools) do
        if tool.HandleCommand ~= nil and (verb == tool.Name or (tool.Aliases and tool.Aliases:contains(verb))) then
            local remainder = args:slice(3, #args - 2)
            tool.HandleCommand(remainder, options.tools[tool.Name], options.globals)
        end
    end
end)
