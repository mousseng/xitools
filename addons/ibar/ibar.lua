--[[
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2014 Vicrelant
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to
 *	deal in the Software without restriction, including without limitation the
 *	rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *	sell copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
]]--

addon.author   = 'Vicrelant';
addon.name     = 'ibar';
addon.version  = '3.0.2';

require 'common'
local Fonts = require('fonts')
local Defaults = require('defaults')
local Settings = require('settings')

mb_data = {};
arraySize = 0;

jobs = {
	[1]  = 'WAR',
	[2]  = 'MNK',
	[3]  = 'WHM',
	[4]  = 'BLM',
	[5]  = 'RDM',
	[6]  = 'THF',
	[7]  = 'PLD',
	[8]  = 'DRK',
	[9]  = 'BST',
	[10] = 'BRD',
	[11] = 'RNG',
	[12] = 'SAM',
	[13] = 'NIN',
	[14] = 'DRG',
	[15] = 'SMN',
	[16] = 'BLU',
	[17] = 'COR',
	[18] = 'PUP',
	[19] = 'DNC',
	[20] = 'SCH',
	[21] = 'GEO',
	[22] = 'RUN'
};

---------------------------------------------------------------------------------------------------
-- desc: Default ibar configuration table.
---------------------------------------------------------------------------------------------------
---@class IbarModule
---@field config IbarSettings
---@field font Font?

---@type IbarModule
local Module = {
    config = Settings.load(Defaults),
    font = nil,
}

Settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        Module.config = s
    end

    if (Module.font ~= nil) then
        Module.font:apply(Module.config.font)
    end

    Settings.save()
end)

---------------------------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
---------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
    Module.font = Fonts.new(Module.config.font)

	local ZoneID	= AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);

	local _, mb_data = pcall(require, 'data.' .. tostring(ZoneID));
    if (mb_data == nil or type(mb_data) ~= 'table') then
        mb_data = { };
    end

	arraySize = table.getn(mb_data);
end );

---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function()
    if (Module.font ~= nil) then
        Module.config.font.position_x = Module.font.position_x
        Module.config.font.position_y = Module.font.position_y
        Module.font:destroy()
        Module.font = nil
    end

    Settings.save()
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'd3d_present_cb', function()
    local f         = Module.font
	local Entity	= AshitaCore:GetMemoryManager():GetEntity();
    local party     = AshitaCore:GetMemoryManager():GetParty();
	local player	= AshitaCore:GetMemoryManager():GetPlayer();
	local target    = AshitaCore:GetMemoryManager():GetTarget();
	local ZoneName	= AshitaCore:GetResourceManager():GetString('zones.names', party:GetMemberZone(0));

	-- disable view if no player
	if (player:GetMainJobLevel() == 0) then
		f.visible = false;
		return;
	end

	f.visible = true;

	-- obtain values from json configuration.
	local s_target = Module.config.layout.player;

	local name = string.find(s_target,'$name');
	local zone = string.find(s_target,'$zone');
	local z_id = string.find(s_target,'$z_id');
	local mlvl = string.find(s_target,'$level');
	local gpos = string.find(s_target,'$position');
	local ecom = string.find(s_target,'$ecompass');
	local scom = string.find(s_target,'$scompass');
	local p_hp = string.find(s_target,'$hpp');
	local m_id = string.find(s_target,'$id');
	local m_ix = string.find(s_target,'$m_index');

	-- obtain player position.
	local pX = string.format('%2.3f',Entity:GetLocalPositionX(party:GetMemberTargetIndex(0)));
	local pY = string.format('%2.3f',Entity:GetLocalPositionY(party:GetMemberTargetIndex(0)));
	local pZ = string.format('%2.3f',Entity:GetLocalPositionZ(party:GetMemberTargetIndex(0)));
	local pH = string.format('%2.3f',Entity:GetLocalPositionYaw(party:GetMemberTargetIndex(0)));

	local sResult = '';
	local eResult = '';

	if (ecom ~= nil or scom ~= nil) then
		local degrees = pH * (180 / math.pi) + 90;

		if (degrees > 360) then
			degrees = degrees - 360;
		elseif (degrees < 0) then
			degrees = degrees + 360;
		end

		sResult = math.floor(degrees);

		if (337 < degrees or 23 >= degrees) then
            eResult = string.format('|cff787878|N|r');
            sResult = 'N';
        elseif (23 < degrees and 68 >= degrees) then
            eResult = string.format('|cFFFFFFFF|NE|r');
            sResult = 'NE';
        elseif (68 < degrees and 113 >= degrees) then
            eResult = string.format('|cff2cf0e8|E|r');
            sResult = 'E';
        elseif (113 < degrees and 158 >= degrees) then
            eResult = string.format('|cff49ff49|SE|r');
            sResult = 'SE';
        elseif (158 < degrees and 203 >= degrees) then
            eResult = string.format('|cffffc900|S|r');
            sResult = 'S';
        elseif (203 < degrees and 248 >= degrees) then
            eResult = string.format('|cffcd18cd|SW|r');
            sResult = 'SW';
        elseif (248 < degrees and 293 >= degrees) then
            eResult = string.format('|cff4949ff|W|r');
            sResult = 'W';
        elseif (293 < degrees and 337 >= degrees) then
            eResult = string.format('|cffff1900|NW|r');
            sResult = 'NW';
        end
	end

	-- attempt to display player information.
	-- check if player selected and or nothing selected.

	if (target:GetEntityPointer(0) == 0 or
		target:GetServerId(0) == 0 or
		target:GetServerId(0) == party:GetMemberServerId(0)) then

		-- player does not have a sub-job unlocked.
		if (player:GetSubJobLevel() == 0) then

			if (name ~= nil) then s_target = string.gsub(s_target,'$name',party:GetMemberName(0)); end
			if (z_id ~= nil) then s_target = string.gsub(s_target,'$z_id',party:GetMemberZone(0)); end
			if (zone ~= nil) then s_target = string.gsub(s_target,'$zone',ZoneName); end
			if (p_hp ~= nil) then s_target = string.gsub(s_target,'$hpp',party:GetMemberHPP(0)); end
			if (m_id ~= nil) then s_target = string.gsub(s_target,'$id',target:GetServerId(0)); end
			if (m_ix ~= nil) then s_target = string.gsub(s_target,'$m_index',target:GetTargetIndex(0)); end

			if (mlvl ~= nil) then
				s_target = string.gsub(s_target,'$level',
				jobs[player:GetMainJob()] ..
				player:GetMainJobLevel());
			end

			if (gpos ~= nil) then s_target = string.gsub(s_target,'$position',pX .. ', ' .. pY .. ', ' .. pZ); end
			if (ecom ~= nil) then s_target = string.gsub(s_target,'$ecompass',eResult); end
			if (scom ~= nil) then s_target = string.gsub(s_target,'$scompass',sResult); end

			f.text = string.format(s_target);
			return;

		--	player has sub-job unlocked.
		elseif (player:GetSubJobLevel() > 0) then

			if (name ~= nil) then s_target = string.gsub(s_target,'$name',party:GetMemberName(0)); end
			if (z_id ~= nil) then s_target = string.gsub(s_target,'$z_id',party:GetMemberZone(0)); end
			if (zone ~= nil) then s_target = string.gsub(s_target,'$zone',ZoneName); end
			if (p_hp ~= nil) then s_target = string.gsub(s_target,'$hpp',party:GetMemberHPP(0)); end
			if (m_id ~= nil) then s_target = string.gsub(s_target,'$id',target:GetServerId(0)); end
			if (m_ix ~= nil) then s_target = string.gsub(s_target,'$m_index',target:GetTargetIndex(0)); end

			if (party:GetMemberZone(0) ~= 285) then
				if (mlvl ~= nil) then
					s_target = string.gsub(s_target,'$level',
					jobs[player:GetMainJob()] ..
					player:GetMainJobLevel() .. '/' ..
					jobs[player:GetSubJob()] ..
					player:GetSubJobLevel());
				end
			elseif (party:GetMemberZone(0) == 285) then
				if (mlvl ~= nil) then
					s_target = string.gsub(s_target,'$level',
					tostring(jobs[player:GetMainJob()]));
				end
			end

			if (gpos ~= nil) then s_target = string.gsub(s_target,'$position',pX .. ', ' .. pY .. ', ' .. pZ); end
			if (ecom ~= nil) then s_target = string.gsub(s_target,'$ecompass',eResult); end
			if (scom ~= nil) then s_target = string.gsub(s_target,'$scompass',sResult); end

			f.text = string.format(s_target);
			return;
		end
	end

	local m_target = Module.config.layout.target;

		  name = string.find(m_target,'$target');
		  zone = string.find(m_target,'$zone');
		  mlvl = string.find(m_target,'$level');
		  gpos = string.find(m_target,'$position');
		  m_id = string.find(m_target,'$id');
		  m_ix = string.find(m_target,'$m_index');
	local flag = string.find(m_target,'$aggro');
	local mjob = string.find(m_target,'$job');
	local weak = string.find(m_target,'$weak');
	local m_hp = string.find(m_target,'$hpp');

	-- attempt to obtain target information.
	if (target:GetServerId(0) ~= nil) then
		for i = 1, arraySize do
			if (tonumber(mb_data[i].id) == target:GetServerId(0)) then
				if (mb_data[i].sj == mb_data[i].mj) then

					local tentity = GetEntity(target:GetTargetIndex(0));
					pX = string.format('%2.3f',tentity.Movement.LocalPosition.X);
					pY = string.format('%2.3f',tentity.Movement.LocalPosition.Y);
					pZ = string.format('%2.3f',tentity.Movement.LocalPosition.Z);

					if (name ~= nil) then m_target = string.gsub(m_target,'$target',tentity.Name); end
					if (zone ~= nil) then m_target = string.gsub(m_target,'$zone',ZoneName); end
					if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetServerId(0)); end
					if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex(0)); end
					if (mjob ~= nil) then m_target = string.gsub(m_target,'$job',jobs[tonumber(mb_data[i].mj)]); end
					if (mlvl ~= nil) then m_target = string.gsub(m_target,'$level',mb_data[i].mlvl); end
					if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
					if (weak ~= nil) then m_target = string.gsub(m_target,'$weak',mb_data[i].weak); end
					if (m_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',tentity.HealthPercent); end

					if (flag ~= nil) then
						if (mb_data[i].links == 'Y') then
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro .. ',L');
						else
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro);
						end
					end

					f.text = string.format(m_target);
					return;

				else

					local tentity = GetEntity(target:GetTargetIndex(0));
					pX = string.format('%2.3f',tentity.Movement.LocalPosition.X);
					pY = string.format('%2.3f',tentity.Movement.LocalPosition.Y);
					pZ = string.format('%2.3f',tentity.Movement.LocalPosition.Z);

					if (name ~= nil) then m_target = string.gsub(m_target,'$target',tentity.Name); end
					if (zone ~= nil) then m_target = string.gsub(m_target,'$zone',ZoneName); end
					if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetServerId(0)); end
					if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex(0)); end
					if (mlvl ~= nil) then m_target = string.gsub(m_target,'$level',mb_data[i].mlvl); end
					if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
					if (weak ~= nil) then m_target = string.gsub(m_target,'$weak',mb_data[i].weak); end
					if (m_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',tentity.HealthPercent);  end

					if (mjob ~= nil) then
						m_target = string.gsub(m_target,'$job',
						jobs[tonumber(mb_data[i].mj)] .. '/' ..
						jobs[tonumber(mb_data[i].sj)]);
					end

					if (flag ~= nil) then
						if (mb_data[i].links == 'Y') then
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro .. ',L');
						else
							m_target = string.gsub(m_target,'$aggro',mb_data[i].aggro);
						end
					end

					f.text = string.format(m_target);
					return;

				end
			end
		end

		m_target = Module.config.layout.npc;

		m_id = string.find(m_target,'$id');
		m_ix = string.find(m_target,'$m_index');
		gpos = string.find(m_target,'$position');
		n_hp = string.find(m_target,'$hpp');

		local tentity = GetEntity(target:GetTargetIndex(0));
		if (tentity ~= nil) then
			pX = string.format('%2.3f',tentity.Movement.LocalPosition.X);
			pY = string.format('%2.3f',tentity.Movement.LocalPosition.Y);
			pZ = string.format('%2.3f',tentity.Movement.LocalPosition.Z);

			if (name ~= nil) then m_target = string.gsub(m_target,'$target',tentity.Name); end
			if (m_id ~= nil) then m_target = string.gsub(m_target,'$id',target:GetServerId(0)); end
			if (m_ix ~= nil) then m_target = string.gsub(m_target,'$m_index',target:GetTargetIndex(0)); end
			if (gpos ~= nil) then m_target = string.gsub(m_target,'$position', pX .. ',' .. pY .. ',' .. pZ); end
			if (n_hp ~= nil) then m_target = string.gsub(m_target,'$hpp',tentity.HealthPercent); end

			f.text = string.format(m_target);
			return;
		else
			f.text = '';
		end
	end
end );

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
---@param e PacketInEventArgs
ashita.events.register('packet_in', 'packet_in_cb', function(e)
    -- Check for zone-in packets..
    if (e.id == 0x0A) then
        -- Are we zoning into a mog house..
        if (struct.unpack('b', e.data, 0x80 + 1) == 1) then
            return false;
        end

        -- Pull the zone id from the packet..
        local zoneId = struct.unpack('H', e.data, 0x30 + 1);
        if (zoneId == 0) then
            zoneId = struct.unpack('H', e.data, 0x42 + 1);
        end

        -- Update our mob list..
		--mb_data = require('data.' .. tostring(zoneId));
		_, mb_data = pcall(require, 'data.' .. tostring(zoneId));
        if (mb_data == nil or type(mb_data) ~= 'table') then
            mb_data = { };
        end

		arraySize = table.getn(mb_data);
    end

    return false;
end );
