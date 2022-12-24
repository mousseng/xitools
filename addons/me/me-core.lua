local Defaults = require('me-settings')
local Settings = require('settings')

local Imgui = require('imgui')
local Bit = require('bit')

local Jobs = require('lin.jobs')
local Text = require('lin.text')

---@type MeModule
local Module = {
    config = Settings.load(Defaults),
    windowName = 'Me_',
    windowFlags = Bit.bor(ImGuiWindowFlags_NoDecoration),
    windowPadding = { 10, 10 },
    windowBg = { 0.08, 0.08, 0.08, 0.8 },
    windowBgBorder = { 0.69, 0.68, 0.78, 1.0 },
    windowBgBorderShadow = { 1.0, 0.0, 0.0, 1.0},
    windowTextColor = { 1.0, 1.0, 1.0, 1.0 },
    isWindowOpen = false,
}

-- ashita.events.register('d3d_present', 'd3d_present_cb', function()
--     local lines = {}

--     local party_data = AshitaCore:GetMemoryManager():GetParty()
--     local player_data = AshitaCore:GetMemoryManager():GetPlayer()
--     local player_entity = GetPlayerEntity()

--     if player_entity == nil or Jobs.GetJobAbbr(player_data:GetMainJob()) == nil then
--         Module.font.text = ''
--         return
--     end

--     local player = {
--         name = player_entity.Name or '',

--         main_job = Jobs.GetJobAbbr(player_data:GetMainJob()),
--         main_lv = player_data:GetMainJobLevel() or 0,

--         sub_job = Jobs.GetJobAbbr(player_data:GetSubJob()),
--         sub_lv = player_data:GetSubJobLevel() or 0,

--         cur_xp = player_data:GetExpCurrent() or 0,
--         max_xp = player_data:GetExpNeeded() or 0,

--         is_limit_mode = player_data:GetIsExperiencePointsLocked(),
--         merits = player_data:GetMeritPoints(),

--         cur_lp = player_data:GetLimitPoints(),
--         max_lp = 10000,

--         max_hp = player_data:GetHPMax() or 0,
--         cur_hp = party_data:GetMemberHP(0) or 0,

--         max_mp = player_data:GetMPMax() or 0,
--         cur_mp = party_data:GetMemberMP(0) or 0,

--         max_tp = 300,
--         cur_tp = math.floor(party_data:GetMemberTP(0) / 10) or 0,
--     }

--     local line1
--     if player.sub_job ~= '' and player.sub_job ~= nil then
--         line1 = string.format('%-11.11s [%s%2i/%s%2i]',
--             player.name,
--             player.main_job, player.main_lv,
--             player.sub_job, player.sub_lv)
--     else
--         line1 = string.format('%-17.17s [%s%2i]',
--             player.name,
--             player.main_job, player.main_lv)
--     end

--     local line2 = string.format('HP %4i/%4i %s',
--         player.cur_hp,
--         player.max_hp,
--         Text.PercentBar(12, player.cur_hp / player.max_hp))

--     local line3 = string.format('MP %4i/%4i %s',
--         player.cur_mp,
--         player.max_mp,
--         Text.PercentBar(12, player.cur_mp / player.max_mp))

--     local line4 = string.format('TP %4i/%4i %s',
--         player.cur_tp,
--         player.max_tp,
--         Text.PercentBar(12, player.cur_tp / player.max_tp))

--     local line5
--     if player.is_limit_mode
--     or player.cur_xp == 43999 then
--         line5 = string.format('LP %4.4s/%-4.4s %s',
--             Text.FormatXp(player.cur_lp, false),
--             Text.FormatXp(player.max_lp, false),
--             Text.PercentBar(12, player.cur_lp / player.max_lp))
--     else
--         line5 = string.format('XP %4.4s/%-4.4s %s',
--             Text.FormatXp(player.cur_xp, false),
--             Text.FormatXp(player.max_xp, false),
--             Text.PercentBar(12, player.cur_xp / player.max_xp))
--     end

--     table.insert(lines, line1)
--     table.insert(lines, Text.Colorize(line2, Text.GetHpColor(player.cur_hp / player.max_hp)))
--     table.insert(lines, Text.Colorize(line3, Text.GetHpColor(player.cur_mp / player.max_mp)))
--     table.insert(lines, Text.Colorize(line4, Text.GetTpColor(player.cur_tp / player.max_tp)))
--     table.insert(lines, line5)

--     Module.font.text = table.concat(lines, '\n')
-- end)

local function DrawHeader()
end

local function DrawBar(title, cur, max)
    local fraction = cur / max
    local overlay = string.format('%i/%i', cur, max)

    Imgui.AlignTextToFramePadding()
    Imgui.Text(title)
    Imgui.SameLine()
    Imgui.ProgressBar(fraction, { 200, 15 }, overlay)
end

---@param player Player
---@param entity Entity
local function DrawMe(player, entity)
    Imgui.ShowDemoWindow()

    local party = AshitaCore:GetMemoryManager():GetParty()

    Imgui.SetNextWindowSize({ -1, -1 }, ImGuiCond_Always)
    Imgui.SetNextWindowPos({ Module.config.position_x, Module.config.position_y }, ImGuiCond_FirstUseEver)
    Imgui.PushStyleColor(ImGuiCol_WindowBg, Module.windowBg)
    Imgui.PushStyleColor(ImGuiCol_Border, Module.windowBgBorder)
    Imgui.PushStyleColor(ImGuiCol_BorderShadow, Module.windowBgBorderShadow)
    Imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, Module.windowPadding)
    if Imgui.Begin(Module.windowName, Module.isWindowOpen, Module.windowFlags) then
        Imgui.PopStyleColor(3)
        Imgui.PushStyleColor(ImGuiCol_Text, Module.windowTextColor)
        Imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 })

        Imgui.Text(string.format('%s', entity.Name))
        if player:GetSubJob() ~= nil then
            Imgui.Text(string.format(
                '%s%i/%s%i',
                Jobs.GetJobAbbr(player:GetMainJob()), player:GetMainJobLevel(),
                Jobs.GetJobAbbr(player:GetSubJob()), player:GetSubJobLevel()
            ))
        else
            Imgui.Text(string.format(
                '%s%i/%s%i',
                Jobs.GetJobAbbr(player:GetMainJob()), player:GetMainJobLevel()))
        end

        DrawBar('HP', party:GetMemberHP(0), player:GetHPMax())
        DrawBar('MP', party:GetMemberMP(0), player:GetMPMax())
        DrawBar('TP', party:GetMemberTP(0), 3000)
        DrawBar('XP', player:GetExpCurrent(), player:GetExpNeeded())

        Imgui.PopStyleVar(1)
        Imgui.End()
    else
        Imgui.PopStyleColor(3)
    end
    Imgui.PopStyleVar(1)
end

---@param s MeSettings?
function Module.UpdateSettings(s)
    if (s ~= nil) then
        Module.config = s
    end

    Settings.save()
end

function Module.OnPresent()
    ---@type Entity
    local entity = GetPlayerEntity()

    -- don't bother drawing if the player doesn't exist
    if entity == nil then
        return
    end

    ---@type Player
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    -- don't bother drawing if the player is zoning
    if player.IsZoning then
        return
    end

    DrawMe(player, entity)
end

function Module.OnLoad()
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
