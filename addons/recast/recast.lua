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

require('common')
local Settings = require('settings')
local Ffxi = require('lin.ffxi')
local Imgui = require('lin.imgui')

---@class RecastSettings
---@field windowName string
---@field windowSize Vec2
---@field windowPos Vec2

---@type RecastSettings
local Defaults = {
    windowName = 'Recast',
    windowSize = { -1, -1 },
    windowPos = { 100, 100 },
}

---@type RecastSettings
local Config = Settings.load(Defaults)

---@type integer
local SchJp = 0

local TwoHours = {
    [ 1] = 'Mighty Strikes',
    [ 2] = 'Hundred Fists',
    [ 3] = 'Benediction',
    [ 4] = 'Manafont',
    [ 5] = 'Chainspell',
    [ 6] = 'Perfect Dodge',
    [ 7] = 'Invincible',
    [ 8] = 'Blood Weapon',
    [ 9] = 'Familiar',
    [10] = 'Soul Voice',
    [11] = 'Eagle Eye Shot',
    [12] = 'Meikyo Shisui',
    [13] = 'Mijin Gakure',
    [14] = 'Spirit Surge',
    [15] = 'Astral Flow',
    [16] = 'Azure Lore',
    [17] = 'Wild Card',
    [18] = 'Overdrive',
    [19] = 'Trance',
    [20] = 'Tabula Rasa',
    [21] = 'Bolster',
    [22] = 'Elemental Sforzo',
}

---@param s RecastSettings?
local function UpdateSettings(s)
    if (s ~= nil) then
        Config = s
    end

    Settings.save()
end

--[[
* Returns a formatted recast timestamp.
*
* @param {number} timer - The recast timestamp to format.
* @return {string} The formatted timestamp.
--]]
local function format_timestamp(timer)
    local t = timer / 60
    local h = math.floor(t / (60 * 60))
    local m = math.floor(t / 60 - h * 60)
    local s = math.floor(t - (m + h * 60) * 60)

    if h > 0 then
        return ('%ih %im %is'):fmt(h, m, s)
    elseif m > 0 then
        return ('%im %is'):fmt(m, s)
    else
        return ('%is'):fmt(s)
    end
end

--[[
* Returns an abilities name as a fallback if the ability is not known to the player.
*
* @param {number} id - The recast timer id of the ability to obtain.
* @return {object} The ability if found, nil otherwise.
* @note
*
* This is not guaranteed to get the desired ability as the game shares recast timer ids based on the players
* job combo. Because of this, another ability may be returned instead of what was expected if it was found first.
--]]
local function get_ability_fallback(id)
    local resMgr = AshitaCore:GetResourceManager()
    for x = 0, 2048 do
        local ability = resMgr:GetAbilityById(x)
        if (ability ~= nil and ability.RecastTimerId == id) then
            return ability
        end
    end
    return nil
end

local function DrawTimer(timer)
    if timer.timer >= 1200 then
        Imgui.PushStyleColor(ImGuiCol_Text, Imgui.Lin.Colors.White)
    elseif timer.timer < 1200 and timer.timer > 300 then
        Imgui.PushStyleColor(ImGuiCol_Text, Imgui.Lin.Colors.Yellow)
    else
        Imgui.PushStyleColor(ImGuiCol_Text, Imgui.Lin.Colors.Red)
    end

    local text = string.format('%s - %s', timer.name, format_timestamp(timer.timer))
    Imgui.Text(text)
    Imgui.PopStyleColor()
end

local function DrawRecast(timers)
    for _, timer in pairs(timers) do
        DrawTimer(timer)
    end
end

local function OnPresent()
    local resMgr    = AshitaCore:GetResourceManager()
    local mmPlayer  = AshitaCore:GetMemoryManager():GetPlayer()
    local mmRecast  = AshitaCore:GetMemoryManager():GetRecast()
    local timers    = T{}

    local playerJob = mmPlayer:GetMainJob()
    if playerJob == nil or playerJob == 0 or Ffxi.IsChatExpanded() then
        return
    end

    -- Obtain the players ability recasts..
    for x = 0, 31 do
        local id = mmRecast:GetAbilityTimerId(x)
        local timer = mmRecast:GetAbilityTimer(x)

        -- Ensure the ability is valid and has a current recast timer..
        if ((id ~= 0 or x == 0) and timer > 0) then
            -- Obtain the resource entry for the ability..
            local ability = resMgr:GetAbilityByTimerId(id)
            local name = ('(Unknown: %d)'):fmt(id)

            -- Determine the name to be displayed..
            if (x == 0) then
                name = TwoHours[playerJob]
            elseif (id == 231) then
                -- Determine the players SCH level..
                local lvl = (playerJob == 20) and mmPlayer:GetMainJobLevel() or mmPlayer:GetSubJobLevel()

                -- Adjust the timer offset by the players level..
                local val = 48
                if (lvl < 30) then
                    val = 240
                elseif (lvl < 50) then
                    val = 120
                elseif (lvl < 70)then
                    val = 80
                elseif (lvl < 90) then
                    val = 60
                end

                -- Calculate the stratagems amount..
                local stratagems = 0
                if (lvl == 99 and SchJp >= 550) then
                    val = 33
                    stratagems = math.floor((165 - (timer / 60)) / val)
                else
                    stratagems = math.floor((240 - (timer / 60)) / val)
                end

                -- Update the name and timer..
                name = ('Stratagems[%d]'):fmt(stratagems)
                timer = math.fmod(timer, val * 60)
            elseif (ability ~= nil) then
                name = ability.Name[1]
            elseif (ability == nil) then
                ability = get_ability_fallback(id)
                if (ability ~= nil) then
                    name = ability.Name[1]
                end
            end

            -- Append the timer to the table..
            local newTimer = {
                name = name,
                timer = timer,
            }
            timers:insert(newTimer)
        end
    end

    -- Obtain the players spell recasts..
    for x = 0, 1024 do
        local id = x
        local timer = mmRecast:GetSpellTimer(x)

        -- Ensure the spell has a current recast timer..
        if (timer > 0) then
            local spell = resMgr:GetSpellById(id)
            local name = '(Unknown Spell)'

            -- Determine the name to be displayed..
            if (spell ~= nil) then
                name = spell.Name[1]
            end
            if (spell == nil or name:len() == 0) then
                name = ('Unknown Spell: %d'):fmt(id)
            end

            -- Append the timer to the table..
            local newTimer = {
                name = name,
                timer = timer,
            }
            timers:insert(newTimer)
        end
    end

    if #timers > 0 then
        Imgui.Lin.DrawWindow(Config.windowName, Config.windowSize, Config.windowPos, function()
            DrawRecast(timers)
        end)
    end
end

local function OnLoad()
end

local function OnUnload()
    UpdateSettings()
end

---@param e PacketInEventArgs
local function OnPacket(e)
    -- Packet: Job Points
    if (e.id == 0x0063) then
        if (struct.unpack('B', e.data_modified, 0x04 + 0x01) == 5) then
            SchJp = struct.unpack('H', e.data_modified, 0x88 + 0x01)
        end
    end
end

Settings.register('settings', 'settings_update', UpdateSettings)
ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('unload', 'on_unload', OnUnload)
ashita.events.register('packet_in', 'on_packet_in', OnPacket)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
