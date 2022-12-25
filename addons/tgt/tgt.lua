addon.name    = 'tgt'
addon.author  = 'lin'
addon.version = '3.0.0'
addon.desc    = 'A simple text-based HUD for target status'

local Tgt = require('tgt-core')

ashita.events.register('load',        'on_load',        Tgt.OnLoad)
ashita.events.register('unload',      'on_unload',      Tgt.OnUnload)
ashita.events.register('command',     'on_command',     Tgt.OnCommand)
ashita.events.register('d3d_present', 'on_d3d_present', Tgt.OnPresent)
ashita.events.register('packet_in',   'on_packet_in',   Tgt.OnPacket)
