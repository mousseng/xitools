addon.name    = 'us'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for party status'

local Jobs = require('lin.jobs')
local Zones = require('lin.zones')
local Styles = require('lin.imgui')
local Imgui = require('imgui')

---@class PartyMember
---@field name string
---@field isInZone boolean
---@field isTarget boolean
---@field isActive boolean
---@field job string
---@field sub string
---@field jobLevel integer
---@field subLevel integer
---@field hpp integer
---@field mpp integer
---@field hp integer
---@field mp integer
---@field tp integer
---@field zoneId integer
---@field windowName string
---@field windowSize Vec2
---@field windowPos Vec2

local Members = {
    { windowName = 'Us_0', windowSize = { 277, -1 }, windowPos = { 400, 580 }, },
    { windowName = 'Us_1', windowSize = { 277, -1 }, windowPos = { 400, 630 }, },
    { windowName = 'Us_2', windowSize = { 277, -1 }, windowPos = { 400, 680 }, },
    { windowName = 'Us_3', windowSize = { 277, -1 }, windowPos = { 400, 730 }, },
    { windowName = 'Us_4', windowSize = { 277, -1 }, windowPos = { 400, 780 }, },
    { windowName = 'Us_5', windowSize = { 277, -1 }, windowPos = { 400, 830 }, },
}

---@param player PartyMember
local function DrawName(player)
    if player.isTarget then
        Imgui.PushStyleColor(ImGuiCol_Text, Styles.Colors.TpBarActive)
        Imgui.Text(string.format('> %s', player.name))
    else
        Imgui.Text(string.format('%s', player.name))
    end

    if player.job ~= nil then
        local jobs = ''
        if player.sub ~= 0 then
            jobs = string.format('%s%i/%s%i', player.job, player.jobLevel, player.sub, player.subLevel)
        else
            jobs = string.format('%s%i', player.job, player.jobLevel)
        end

        local width = Imgui.CalcTextSize(jobs) + Styles.Styles.WindowPadding[1]

        Imgui.SameLine()
        Imgui.SetCursorPosX(player.windowSize[1] - width)
        Imgui.Text(jobs)
    end

    if player.isTarget then
        Imgui.PopStyleColor()
    end
end

---@param player PartyMember
local function DrawZone(player)
    Imgui.TextDisabled(Zones[player.zoneId])
end

---@param player PartyMember
local function DrawHp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.HpBar
    local overlay = string.format('%i', player.hp)

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Styles.DrawBar2(player.hpp, 100, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawMp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.MpBar
    local overlay = string.format('%i', player.mp)

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.SameLine()
    Styles.DrawBar2(player.mpp, 100, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawTp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.TpBar
    local overlay = string.format('%i', player.tp)

    if player.tp >= 1000 then
        barColor = Styles.Colors.TpBarActive
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.SameLine()
    Styles.DrawBar2(player.tp, 3000, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawPartyMember(player)
    DrawName(player)

    if player.isInZone then
        DrawHp(player)
        DrawMp(player)
        DrawTp(player)
    else
        DrawZone(player)
    end
end

local function DrawUs()
    Styles.DrawWindow('Us', { 277, -1 }, Members[2].windowPos[1], Members[2].windowPos[2], function()
        local target = AshitaCore:GetMemoryManager():GetTarget()
        local party = AshitaCore:GetMemoryManager():GetParty()

        for i = 0, 5 do
            ---@type PartyMember
            local member = {
                name = party:GetMemberName(i),
                isInZone = party:GetMemberZone(i) == party:GetMemberZone(0),
                isTarget = party:GetMemberServerId(i) == target:GetServerId(0),
                isActive = party:GetMemberIsActive(i) == 1,
                job = Jobs.GetJobAbbr(party:GetMemberMainJob(i)),
                sub = Jobs.GetJobAbbr(party:GetMemberSubJob(i)),
                jobLevel = party:GetMemberMainJobLevel(i),
                subLevel = party:GetMemberSubJobLevel(i),
                zoneId = party:GetMemberZone(i),
                hpp = party:GetMemberHPPercent(i),
                mpp = party:GetMemberMPPercent(i),
                hp = party:GetMemberHP(i),
                mp = party:GetMemberMP(i),
                tp = party:GetMemberTP(i),
                windowName = Members[i + 1].windowName,
                windowSize = Members[i + 1].windowSize,
                windowPos = Members[i + 1].windowPos,
            }

            if member.isActive and member.name ~= '' then
                DrawPartyMember(member)
            end
        end
    end)
end

ashita.events.register('d3d_present', 'd3d_present_handler', DrawUs)
