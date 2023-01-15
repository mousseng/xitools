require('common')
local ffxi = require('utils.ffxi')
local imgui = require('imgui')
local ui = require('ui')

---@param name     string
---@param job      integer
---@param jobLevel integer
---@param sub      integer?
---@param subLevel integer?
local function DrawHeader(name, job, jobLevel, sub, subLevel, options)
    imgui.Text(string.format('%s', name))

    local jobStr = ''
    if sub ~= 0 then
        jobStr = string.format('%s%i/%s%i', ffxi.GetJobAbbr(job), jobLevel, ffxi.GetJobAbbr(sub), subLevel)
    else
        jobStr = string.format('%s%i', ffxi.GetJobAbbr(job), jobLevel)
    end

    local width = imgui.CalcTextSize(jobStr) + ui.Styles.WindowPadding[1]

    imgui.SameLine()
    imgui.SetCursorPosX(options.size[1] - width)
    imgui.Text(jobStr)
end

---@param cur integer
---@param max integer
local function DrawHp(cur, max)
    local title = string.format('HP %4i', cur)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.HpBar

    local frac = cur / max
    if frac > 0.75 then
        textColor = ui.Colors.White
    elseif frac > 0.50 then
        textColor = ui.Colors.Yellow
    elseif frac > 0.25 then
        textColor = ui.Colors.Orange
    elseif frac >= 0.00 then
        textColor = ui.Colors.Red
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, cur, max, '')
    imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawMp(cur, max)
    local title = string.format('MP %4i', cur)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.FfxiAmber

    local frac = cur / max
    if frac > 0.75 then
        textColor = ui.Colors.White
    elseif frac > 0.50 then
        textColor = ui.Colors.Yellow
    elseif frac > 0.25 then
        textColor = ui.Colors.Orange
    elseif frac >= 0.00 and max > 0 then
        textColor = ui.Colors.Red
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, cur, max, '')
    imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawTp(cur, max)
    local title = string.format('TP %4i', cur)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.TpBar

    if cur > 1000 then
        textColor = ui.Colors.TpBarActive
        barColor = ui.Colors.TpBarActive
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, cur, max, '')
    imgui.PopStyleColor(2)
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawXp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = ui.Colors.XpBar
    local title = string.format('XP %4s', ffxi.FormatXp(cur, cur > 9999))
    local overlay = ffxi.FormatXp(max - cur, true)

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, cur, max, overlay)
    imgui.PopStyleColor()
end

---@param cur      integer
---@param max      integer
---@param isLocked boolean
local function DrawLp(cur, max, isLocked)
    if isLocked then
        return
    end

    local barColor = ui.Colors.LpBar
    local title = string.format('LP %4s', type, ffxi.FormatXp(cur, cur > 9999))

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, cur, max)
    imgui.PopStyleColor()
end

---@param player Player
---@param party Party
---@param entity Entity
local function DrawMe(player, party, entity, options)
    local isExpLocked = player:GetIsExperiencePointsLocked()

    DrawHeader(entity.Name, player:GetMainJob(), player:GetMainJobLevel(), player:GetSubJob(), player:GetSubJobLevel(), options)
    DrawHp(party:GetMemberHP(0), player:GetHPMax())
    DrawMp(party:GetMemberMP(0), player:GetMPMax())
    DrawTp(party:GetMemberTP(0), 3000)
    DrawXp(player:GetExpCurrent(), player:GetExpNeeded(), isExpLocked)
    DrawLp(player:GetLimitPoints(), 10000, not isExpLocked)
end

---@type xitool
local me = {
    Name = 'me',
    Load = function(options) end,
    HandlePacketOut = function(e, options) end,
    HandlePacket = function(e, options) end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('me') then
            imgui.Checkbox('Enabled', options.isVisible)
            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options)
        ---@type Entity
        local entity = GetPlayerEntity()

        -- don't bother drawing if the player doesn't exist
        -- or if there's UI in the way
        if entity == nil or ffxi.IsChatExpanded() then
            return
        end

        ---@type Player
        local player = AshitaCore:GetMemoryManager():GetPlayer()

        -- don't bother drawing if the player is zoning or in character select
        if player:GetMainJob() == 0 or player:GetIsZoning() == 1 then
            return
        end

        local party = AshitaCore:GetMemoryManager():GetParty()
        ui.DrawWindow(options, function()
            DrawMe(player, party, entity, options)
        end)
    end,
}

return me
