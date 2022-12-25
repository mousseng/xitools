--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'recast';
addon.author    = 'atom0s, Thorny, RZN, lin';
addon.version   = '2.0';
addon.desc      = 'Displays ability and spell recast times.';
addon.link      = 'https://ashitaxi.com/';

local Recast = require('recast-core')

ashita.events.register('load',        'on_load',        Recast.OnLoad)
ashita.events.register('unload',      'on_unload',      Recast.OnUnload)
ashita.events.register('packet_in',   'on_packet_in',   Recast.OnPacket)
ashita.events.register('d3d_present', 'on_d3d_present', Recast.OnPresent)
