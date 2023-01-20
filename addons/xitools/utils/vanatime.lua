--[[
* Ashita - Copyright (c) 2014 - 2017 atom0s [atom0s@live.com]
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

local vanatime = { }

ashita                  = ashita or { };
ashita.ffxi             = ashita.ffxi or { };
ashita.ffxi.vanatime    = ashita.ffxi.vanatime or { };

-- Scan for patterns..
ashita.ffxi.vanatime.pointer = ashita.memory.find('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0x34, 0);

-- Signature validation..
if (ashita.ffxi.vanatime.pointer == 0) then
    error('vanatime.lua -- signature validation failed!');
end

----------------------------------------------------------------------------------------------------
-- func: get_raw_timestamp
-- desc: Returns the current raw Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
function vanatime.get_raw_timestamp()
    local pointer = ashita.memory.read_uint32(ashita.ffxi.vanatime.pointer);
    return ashita.memory.read_uint32(pointer + 0x0C);
end

----------------------------------------------------------------------------------------------------
-- func: get_timestamp
-- desc: Returns the current formatted Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
function vanatime.get_timestamp()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local h = (ts / 3600) % 24;
    local m = (ts / 60) % 60;
    local s = ((ts - (math.floor(ts / 60) * 60)));

    return string.format('%02i:%02i:%02i', h, m, s);
end

----------------------------------------------------------------------------------------------------
-- func: get_current_time
-- desc: Returns a table with the hour, minutes, and seconds in Vana'diel time.
----------------------------------------------------------------------------------------------------
function vanatime.get_current_time()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local h = (ts / 3600) % 24;
    local m = (ts / 60) % 60;
    local s = ((ts - (math.floor(ts / 60) * 60)));

    local vana = { };
    vana.h = h;
    vana.m = m;
    vana.s = s;

    return vana;
end

----------------------------------------------------------------------------------------------------
-- func: get_current_hour
-- desc: Returns the current Vana'diel hour.
----------------------------------------------------------------------------------------------------
function vanatime.get_current_hour()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return (ts / 3600) % 24;
end

----------------------------------------------------------------------------------------------------
-- func: get_current_minute
-- desc: Returns the current Vana'diel minute.
----------------------------------------------------------------------------------------------------
function vanatime.get_current_minute()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return (ts / 60) % 60;
end

----------------------------------------------------------------------------------------------------
-- func: get_current_second
-- desc: Returns the current Vana'diel second.
----------------------------------------------------------------------------------------------------
function vanatime.get_current_second()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    return ((ts - (math.floor(ts / 60) * 60)));
end

----------------------------------------------------------------------------------------------------
-- func: get_current_date
-- desc: Returns a table with the current Vana'diel date.
----------------------------------------------------------------------------------------------------
function vanatime.get_current_date()
    local timestamp = vanatime.get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local day = math.floor(ts / 86400);

    -- Calculate the moon information..
    local mphase = (day + 26) % 84;
    local mpercent = (((42 - mphase) * 100)  / 42);
    if (0 > mpercent) then
        mpercent = math.abs(mpercent);
    end

    -- Build the date information..
    local vanadate          = { };
    vanadate.weekday        = (day % 8);
    vanadate.day            = (day % 30) + 1;
    vanadate.month          = ((day % 360) / 30) + 1;
    vanadate.year           = (day / 360);
    vanadate.moon_percent   = math.floor(mpercent + 0.5);

    if (38 <= mphase) then
        vanadate.moon_phase = math.floor((mphase - 38) / 7);
    else
        vanadate.moon_phase = math.floor((mphase + 46) / 7);
    end

    return vanadate;
end

return vanatime
