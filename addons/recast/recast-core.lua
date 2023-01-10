require('common')
local Ffxi = require('lin.ffxi')
local Imgui = require('lin.imgui')
local Settings = require('settings')
local Defaults = require('recast-settings')
local TwoHours = require('recast-twohours')

---@class RecastSettings
---@field position_x integer
---@field position_y integer

---@class RecastModule
---@field config               RecastSettings
---@field windowName           string
---@field windowSize           Vec2
---@field isWindowOpen         boolean[]

---@type RecastModule
local Module = {
    config = Settings.load(Defaults),
    sch_jp = 0,
    windowName = 'Recast',
    windowSize = { -1, -1 },
}

---@param s RecastSettings?
function Module.UpdateSettings(s)
    if (s ~= nil) then
        Module.config = s
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

function Module.OnPresent()
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
                if (lvl == 99 and Module.sch_jp >= 550) then
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
        Imgui.Lin.DrawWindow(Module.windowName, Module.windowSize, { Module.config.position_x, Module.config.position_y }, function()
            DrawRecast(timers)
        end)
    end
end

function Module.OnLoad()
end

function Module.OnUnload()
    Module.UpdateSettings()
end

---@param e PacketInEventArgs
function Module.OnPacket(e)
    -- Packet: Job Points
    if (e.id == 0x0063) then
        if (struct.unpack('B', e.data_modified, 0x04 + 0x01) == 5) then
            Module.sch_jp = struct.unpack('H', e.data_modified, 0x88 + 0x01)
        end
    end
end

Settings.register('settings', 'settings_update', Module.UpdateSettings)
return Module
