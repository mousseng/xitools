--[[
* Ashita - Copyright (c) 2014 - 2016 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'atom0s';
_addon.name     = 'recast';
_addon.version  = '3.2.0';

require 'common'
require 'ffxi.recast'

----------------------------------------------------------------------------------------------------
-- Configurations
----------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        family      = 'Arial',
        size        = 10,
        color       = 0xFFFF0000,
        position    = { 50, 125 },
        bgcolor     = 0xA0000000,
        bgvisible   = true
    }
};
local recast_config = default_config;
local SCHJP = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
local FORMAT = '%4is  %s';

---------------------------------------------------------------------------------------------------
-- func: color_recast_entry
-- desc: Colors a recast entry based on the time left to use it..
---------------------------------------------------------------------------------------------------
local function color_recast_entry( s, t )
    if (t >= 1200) then
        return s;
    elseif (t < 1200 and t > 300) then
        return string.format('|cFFFFFF00|%s|r', s);
    else
        return string.format('|cFF00FF00|%s|r', s);
    end
end

----------------------------------------------------------------------------------------------------
-- func: naturalsum
-- desc: Gets the sum of the natural numbers of 1 to n. (n(n+1))/2
----------------------------------------------------------------------------------------------------
local function naturalsum(n)
    local val = 0;
    for i = n, 0, -1 do
        val = val + i;
    end
    return val;
end

----------------------------------------------------------------------------------------------------
-- func: sum
-- desc: Gets the sum of a tables values.
----------------------------------------------------------------------------------------------------
local function sum(t)
    local sum = 0;
    for k, v in pairs(t) do
        sum = sum + naturalsum(v);
    end
    return sum;
end

----------------------------------------------------------------------------------------------------
-- func: spairs
-- desc: Iterates over a table, sorted by the given function.
----------------------------------------------------------------------------------------------------
local function spairs(t, sort)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return sort(t,a,b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the fps configuration..
    recast_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', recast_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():Create('__recast_addon');
    f:SetColor(recast_config.font.color);
    f:SetFontFamily(recast_config.font.family);
    f:SetFontHeight(recast_config.font.size);
    f:SetBold(false);
    f:SetPositionX(recast_config.font.position[1]);
    f:SetPositionY(recast_config.font.position[2]);
    f:SetText('Recast ~ by atom0s');
    f:SetVisibility(true);
    f:GetBackground():SetColor(recast_config.font.bgcolor);
    f:GetBackground():SetVisibility(recast_config.font.bgvisible);
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():Get('__recast_addon');
    recast_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    -- Save the configuration..
    ashita.settings.save(_addon.path .. 'settings/settings.json', recast_config);

    -- Unload our font object..
    AshitaCore:GetFontManager():Delete('__recast_addon');
end );

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():Get('__recast_addon');
    local r = AshitaCore:GetResourceManager();
    local e = T{ };

    -- Read the ability recasts..
    for x = 0, 31 do
        local recastId      = ashita.ffxi.recast.get_ability_id_from_index(x);
        local recastTimer   = ashita.ffxi.recast.get_ability_recast_by_index(x);

        -- Ensure the ability has a current cooldown..
        if ((recastId ~= 0 or x == 0) and recastTimer > 0) then
            local ability = r:GetAbilityByTimerId(recastId);
            local recastName = '[Unknown]';

            -- Get the abilities name..
            if (x == 0) then
                recastName = 'Two Hour';
            elseif (recastId == 231) then
                local SCHLevel = 0;
                if (AshitaCore:GetDataManager():GetPlayer():GetMainJob() == 20) then
                    SCHLevel = AshitaCore:GetDataManager():GetPlayer():GetMainJobLevel();
                else
                    SCHLevel = AshitaCore:GetDataManager():GetPlayer():GetSubJobLevel();
                end

                local Val = 48;
                if (SCHLevel < 30) then
                    Val = 240;
                elseif (SCHLevel < 50) then
                    Val = 120;
                elseif (SCHLevel < 70)then
                    Val = 80;
                elseif (SCHLevel < 90) then
                    Val = 60;
                end

                local stratagems = 0;
                if (SCHLevel == 99) and (sum(SCHJP) >= 550) then
                    Val = 33;
                    stratagems = math.floor((165 - (recastTimer / 60)) / 33);
                else
                    stratagems = math.floor((240 - (recastTimer / 60)) / Val);
                end

                recastName = 'Stratagems[' .. tostring(stratagems) .. ']';
                recastTimer = math.fmod(recastTimer, (Val * 60));
            elseif (ability ~= nil) then
                recastName = ability.Name[0];
            end

            if (#recastName == 0) then
                recastName = string.format('Unknown Ability: %d', recastId);
            end

            -- Add the recast to the table..
            table.insert(e, color_recast_entry(string.format(FORMAT, recastTimer / 60, recastName), recastTimer));
        end
      end

    -- Read the spell recasts..
    for x = 1, 1024 do
        local recastId      = x;
        local recastTimer   = ashita.ffxi.recast.get_spell_recast_by_index(x);

        -- Ensure the spell has a current cooldown..
        if (recastTimer > 0) then
            local spell = r:GetSpellById(recastId);
            local recastName = '';

            -- Get the spells name..
            if (spell ~= nil) then
                recastName = spell.Name[0];
            end
            if (spell == nil or #recastName == 0) then
                recastName = string.format('Unknown Spell: %d', recastId);
            end

            -- Add the recast to the table..
            table.insert(e, color_recast_entry(string.format(FORMAT, recastTimer / 60, recastName), recastTimer));
        end
    end

    -- Display the recast timers..
    f:SetText(e:concat('\n'));
end);

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Event called when the addon is asked to handle an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, data)
    -- Job Points Packet
    if (id == 0x008D) then
        local count = ((size - 1) / 4) - 1;
        for x = 0, count do
            if (bit.band(struct.unpack('H', data, 0x07 + (x * 4)), 0xFF03) > 0) then
                local entry = struct.unpack('H', data, 0x04 + 1 + (x * 4));
                local job = math.floor(entry / 32);
                local index = entry - (job * 32);
                local value = bit.band(struct.unpack('B', data, 0x07 + 1 + (x * 4)), 0xFC) / 4;
                if (job == 20) then
                    SCHJP[index + 1] = value;
                end
            end
        end
        return false;
    end

    return false;
end);