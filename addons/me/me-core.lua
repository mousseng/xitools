local Defaults = require('me-settings')
local Settings = require('settings')

local Imgui = require('imgui')
local Bit = require('bit')

local Jobs = require('lin.jobs')
local Text = require('lin.text')

---@alias Vec2 integer[]
---@alias Color number[]

---@class MeModule
---@field config               MeSettings
---@field windowName           string
---@field windowSize           Vec2
---@field windowFlags          any
---@field windowBg             Color
---@field windowBgBorder       Color
---@field windowBgBorderShadow Color
---@field isWindowOpen         boolean[]
---@field isLoaded             boolean

---@class MeSettings
---@field position_x integer
---@field position_y integer

local Colors = {
    White          = { 1.00, 1.00, 1.00, 1.0 },
    Yellow         = { 1.00, 1.00, 0.00, 1.0 },
    Orange         = { 1.00, 0.64, 0.00, 1.0 },
    Red            = { 0.95, 0.20, 0.20, 1.0 },

    HpBar          = { 0.83, 0.33, 0.28, 1.0 },
    MpBar          = { 0.82, 0.60, 0.27, 1.0 },
    TpBar          = { 1.00, 1.00, 1.00, 1.0 },
    TpBarActive    = { 0.23, 0.67, 0.91, 1.0 },
    XpBar          = { 0.01, 0.67, 0.07, 1.0 },
    LpBar          = { 0.61, 0.32, 0.71, 1.0 },

    FfxiGreyBg     = { 0.08, 0.08, 0.08, 0.8 },
    FfxiGreyBorder = { 0.69, 0.68, 0.78, 1.0 },
    FfxiAmber      = { 0.81, 0.81, 0.50, 1.0 },
}

---@type MeModule
local Module = {
    config = Settings.load(Defaults),
    windowName = 'Me',
    windowSize = { 277, -1 },
    windowFlags = Bit.bor(ImGuiWindowFlags_NoDecoration),
    windowPadding = { 10, 10 },
    windowBg = Colors.FfxiGreyBg,
    windowBgBorder = Colors.FfxiGreyBorder,
    windowBgBorderShadow = { 1.0, 0.0, 0.0, 1.0 },
    isWindowOpen = { true, },
    isLoaded = false,
}

local function InitMe()
    ---@type Entity
    local player = GetPlayerEntity()
    if player == nil or player.Name == nil or player.Name == '' then
        return
    end

    Module.windowName = 'Me_' .. player.Name
    Module.isLoaded = true
end

---@param name     string
---@param job      integer
---@param jobLevel integer
---@param sub      integer?
---@param subLevel integer?
local function DrawHeader(name, job, jobLevel, sub, subLevel)
    Imgui.Text(string.format('%s', name))

    local jobs = ''
    if sub ~= nil then
        jobs = string.format('%s%i/%s%i', Jobs.GetJobAbbr(job), jobLevel, Jobs.GetJobAbbr(sub), subLevel)
    else
        jobs = string.format('%s%i', Jobs.GetJobAbbr(job), jobLevel)
    end

    local width = Imgui.CalcTextSize(jobs) + Module.windowPadding[1]

    Imgui.SameLine()
    Imgui.SetCursorPosX(Module.windowSize[1] - width)
    Imgui.Text(jobs)
end

---@param title   string
---@param cur     integer
---@param max     integer
---@param overlay string?
local function DrawBar(title, cur, max, overlay)
    local fraction = cur / max

    Imgui.AlignTextToFramePadding()
    Imgui.Text(title)
    Imgui.SameLine()
    Imgui.ProgressBar(fraction, { 200, 15 }, overlay)
end

---@param cur integer
---@param max integer
local function DrawHp(cur, max)
    local title = string.format('HP %4i', cur)
    local textColor = Colors.White
    local barColor = Colors.HpBar

    local frac = cur / max
    if frac > 0.75 then
        textColor = Colors.White
    elseif frac > 0.50 then
        textColor = Colors.Yellow
    elseif frac > 0.25 then
        textColor = Colors.Orange
    elseif frac >= 0.00 then
        textColor = Colors.Red
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawMp(cur, max)
    local title = string.format('MP %4i', cur)
    local textColor = Colors.White
    local barColor = Colors.FfxiAmber

    local frac = cur / max
    if frac > 0.75 then
        textColor = Colors.White
    elseif frac > 0.50 then
        textColor = Colors.Yellow
    elseif frac > 0.25 then
        textColor = Colors.Orange
    elseif frac >= 0.00 and max > 0 then
        textColor = Colors.Red
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawTp(cur, max)
    local title = string.format('TP %4i', cur)
    local textColor = Colors.White
    local barColor = Colors.TpBar

    if cur > 1000 then
        textColor = Colors.TpBarActive
        barColor = Colors.TpBarActive
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    DrawBar(title, cur, max, '')
    Imgui.PopStyleColor(2)
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawXp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = Colors.XpBar
    local title = string.format('XP %4i', Text.FormatXp(cur, true))
    local overlay = Text.FormatXp(max - cur, true)

    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    DrawBar(title, cur, max, overlay)
    Imgui.PopStyleColor()
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawLp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = Colors.LpBar
    local title = string.format('LP %4i', type, Text.FormatXp(cur, true))

    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    DrawBar(title, cur, max)
    Imgui.PopStyleColor()
end

---@param player Player
---@param party Party
---@param entity Entity
local function DrawMe(player, party, entity)
    Imgui.SetNextWindowSize(Module.windowSize, ImGuiCond_Always)
    Imgui.SetNextWindowPos({ Module.config.position_x, Module.config.position_y }, ImGuiCond_FirstUseEver)
    Imgui.PushStyleColor(ImGuiCol_WindowBg, Module.windowBg)
    Imgui.PushStyleColor(ImGuiCol_Border, Module.windowBgBorder)
    Imgui.PushStyleColor(ImGuiCol_BorderShadow, Module.windowBgBorderShadow)
    Imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, Module.windowPadding)

    if Imgui.Begin(Module.windowName, Module.isWindowOpen, Module.windowFlags) then
        Imgui.PopStyleColor(3)
        Imgui.PushStyleColor(ImGuiCol_Text, Colors.White)
        Imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 })

        local isExpLocked = player:GetIsExperiencePointsLocked()

        DrawHeader(entity.Name, player:GetMainJob(), player:GetMainJobLevel(), player:GetSubJob(), player:GetSubJobLevel())
        DrawHp(party:GetMemberHP(0), player:GetHPMax())
        DrawMp(party:GetMemberMP(0), player:GetMPMax())
        DrawTp(party:GetMemberTP(0), 3000)
        DrawXp(player:GetExpCurrent(), player:GetExpNeeded(), isExpLocked)
        DrawLp(player:GetLimitPoints(), 10000, not isExpLocked)

        Imgui.PopStyleVar()
        Imgui.End()
    else
        Imgui.PopStyleColor(3)
    end

    Imgui.PopStyleVar()
end

---@param s MeSettings?
function Module.UpdateSettings(s)
    if (s ~= nil) then
        Module.config = s
    end

    Settings.save()
end

function Module.OnPresent()
    if not Module.isLoaded then
        InitMe()
        return
    end

    ---@type Entity
    local entity = GetPlayerEntity()

    -- don't bother drawing if the player doesn't exist
    if entity == nil then
        return
    end

    ---@type Player
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    -- don't bother drawing if the player is zoning or in character select
    if player:GetMainJob() == 0 or player:GetIsZoning() == 1 then
        return
    end

    local party = AshitaCore:GetMemoryManager():GetParty()
    DrawMe(player, party, entity)
end

function Module.OnLoad()
    InitMe()
end

function Module.OnUnload()
    Module.UpdateSettings()
end

---@param e CommandEventArgs
function Module.OnCommand(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/me' then
        return
    end

    e.blocked = true
end

Settings.register('settings', 'settings_update', Module.UpdateSettings)
return Module
