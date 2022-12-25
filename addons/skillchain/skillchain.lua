addon.name    = 'skillchain'
addon.author  = 'lin'
addon.version = '3.0.0'
addon.desc    = 'A little skillchain tracker so you know when things happen'

local Skillchain = require('skillchain-core')

ashita.events.register('load',        'on_load',        Skillchain.OnLoad)
ashita.events.register('unload',      'on_unload',      Skillchain.OnUnload)
ashita.events.register('command',     'on_command',     Skillchain.OnCommand)
ashita.events.register('d3d_present', 'on_d3d_present', Skillchain.OnPresent)
ashita.events.register('packet_in',   'on_packet_in',   Skillchain.OnPacket)
