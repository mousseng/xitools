addon.name    = 'me'
addon.author  = 'lin'
addon.version = '3.1.0'
addon.desc    = 'A simple HUD for player status'

require('common')
local Settings = require('settings')
local Ffxi = require('lin.ffxi')
local Imgui = require('lin.imgui')
local Jobs = require('lin.jobs')
local Text = require('lin.text')

---@class MeSettings
---@field windowName string
---@field windowSize Vec2
---@field windowPos Vec2

---@type MeSettings
local Defaults = {
    windowName = 'Me',
    windowSize = { 277, -1 },
    windowPos = { 100, 100 },
}

---@type MeSettings
local Config = Settings.load(Defaults)

---@param name     string
---@param job      integer
---@param jobLevel integer
---@param sub      integer?
---@param subLevel integer?
local function DrawHeader(name, job, jobLevel, sub, subLevel)
    Imgui.Text(string.format('%s', name))

    local jobs = ''
    if sub ~= 0 then
        jobs = string.format('%s%i/%s%i', Jobs.GetJobAbbr(job), jobLevel, Jobs.GetJobAbbr(sub), subLevel)
    else
        jobs = string.format('%s%i', Jobs.GetJobAbbr(job), jobLevel)
    end

    local width = Imgui.CalcTextSize(jobs) + Imgui.Lin.Styles.WindowPadding[1]

    Imgui.SameLine()
    Imgui.SetCursorPosX(Config.windowSize[1] - width)
    Imgui.Text(jobs)
end

---@param cur integer
---@param max integer
local function DrawHp(cur, max)
    local title = string.format('HP %4i', cur)
    local textColor = Imgui.Lin.Colors.White
    local barColor = Imgui.Lin.Colors.HpBar

    local frac = cur / max
    if frac > 0.75 then
        textColor = Imgui.Lin.Colors.White
    elseif frac > 0.50 then
        textColor = Imgui.Lin.Colors.Yellow
    elseif frac > 0.25 then
        textColor = Imgui.Lin.Colors.Orange
    elseif frac >= 0.00 then
        textColor = Imgui.Lin.Colors.Red
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.Lin.DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawMp(cur, max)
    local title = string.format('MP %4i', cur)
    local textColor = Imgui.Lin.Colors.White
    local barColor = Imgui.Lin.Colors.FfxiAmber

    local frac = cur / max
    if frac > 0.75 then
        textColor = Imgui.Lin.Colors.White
    elseif frac > 0.50 then
        textColor = Imgui.Lin.Colors.Yellow
    elseif frac > 0.25 then
        textColor = Imgui.Lin.Colors.Orange
    elseif frac >= 0.00 and max > 0 then
        textColor = Imgui.Lin.Colors.Red
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.Lin.DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawTp(cur, max)
    local title = string.format('TP %4i', cur)
    local textColor = Imgui.Lin.Colors.White
    local barColor = Imgui.Lin.Colors.TpBar

    if cur > 1000 then
        textColor = Imgui.Lin.Colors.TpBarActive
        barColor = Imgui.Lin.Colors.TpBarActive
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.Lin.DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawXp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = Imgui.Lin.Colors.XpBar
    local title = string.format('XP %4s', Text.FormatXp(cur, cur > 9999))
    local overlay = Text.FormatXp(max - cur, true)

    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.Lin.DrawBar(title, cur, max, overlay)
    Imgui.PopStyleColor()
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawLp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = Imgui.Lin.Colors.LpBar
    local title = string.format('LP %4s', type, Text.FormatXp(cur, cur > 9999))

    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.Lin.DrawBar(title, cur, max)
    Imgui.PopStyleColor()
end

---@param player Player
---@param party Party
---@param entity Entity
local function DrawMe(player, party, entity)
    local isExpLocked = player:GetIsExperiencePointsLocked()

    DrawHeader(entity.Name, player:GetMainJob(), player:GetMainJobLevel(), player:GetSubJob(), player:GetSubJobLevel())
    DrawHp(party:GetMemberHP(0), player:GetHPMax())
    DrawMp(party:GetMemberMP(0), player:GetMPMax())
    DrawTp(party:GetMemberTP(0), 3000)
    DrawXp(player:GetExpCurrent(), player:GetExpNeeded(), isExpLocked)
    DrawLp(player:GetLimitPoints(), 10000, not isExpLocked)
end

---@param s MeSettings?
local function UpdateSettings(s)
    if (s ~= nil) then
        Config = s
    end

    Settings.save()
end

local function OnPresent()
    ---@type Entity
    local entity = GetPlayerEntity()

    -- don't bother drawing if the player doesn't exist
    -- or if there's UI in the way
    if entity == nil or Ffxi.IsChatExpanded() then
        return
    end

    ---@type Player
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    -- don't bother drawing if the player is zoning or in character select
    if player:GetMainJob() == 0 or player:GetIsZoning() == 1 then
        return
    end

    local party = AshitaCore:GetMemoryManager():GetParty()
    Imgui.Lin.DrawWindow(Config.windowName, Config.windowSize, Config.windowPos, function()
        DrawMe(player, party, entity)
    end)
end

local function OnLoad()
end

local function OnUnload()
    UpdateSettings()
end

---@param e CommandEventArgs
local function OnCommand(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/me' then
        return
    end

    e.blocked = true
end

Settings.register('settings', 'settings_update', UpdateSettings)
ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('unload', 'on_unload', OnUnload)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
