addon.name    = 'bluspells'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'Build BLU spell sets visually'

require('common')
local ui = require('bluspells-ui')
local state = require('bluspells-state')

ashita.events.register('load', 'load_bluspells', function()
    state:FilterSpells(ui.ShowAllSpells[1])
end)

ashita.events.register('command', 'command_bluspells', function(e)
    local args = e.command:args()
    local cmd = args[1]
    local verb = args[2]

    if cmd ~= '/bluspells' then
        return
    end
end)

ashita.events.register('d3d_present', 'render_bluspells', function()
    ui:Render()
end)
