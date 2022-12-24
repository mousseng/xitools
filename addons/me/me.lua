addon.name    = 'me'
addon.author  = 'lin'
addon.version = '2.0.0'
addon.desc    = 'A simple text-based HUD for player status'

---@class MeModule
---@field config MeSettings

---@class MeSettings
---@field position_x integer
---@field position_y integer

local Me = require('me-core')

ashita.events.register('load',        'on_load',        Me.OnLoad)
ashita.events.register('unload',      'on_unload',      Me.OnUnload)
ashita.events.register('command',     'on_command',     Me.OnCommand)
ashita.events.register('d3d_present', 'on_d3d_present', Me.OnPresent)
