addon.name    = 'chatty'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'A (hopefully) nicer chat window'

require('common')
require('jit').off()
local state = require('chatty-state')
local config = require('chatty-config')
local ui = require('chatty-ui')

ashita.events.register('load', 'load_chatty', function()
    state:LoadSettings()
end)

ashita.events.register('command', 'command_chatty', function(e)
    local args = e.command:args()
    local cmd = args[1]
    local verb = args[2]

    if cmd ~= '/chatty' then
        return
    end

    if verb == 'debug' then
        state.IsDebugOn = not state.IsDebugOn
    elseif verb == 'config' then
        config.IsVisible[1] = not config.IsVisible[1]
    end
end)

ashita.events.register('text_in', 'append_chatty', function(e)
    if string.match(e.message, 'chatty%-debug') then
        return
    end

    state:AddMessage(e)
end)

ashita.events.register('d3d_present', 'render_chatty', function()
    config:Render()
    ui:Render()
end)
