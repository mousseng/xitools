addon.name    = 'me'
addon.author  = 'lin'
addon.version = '2.0.0'
addon.desc    = 'A simple text-based HUD for player status'

local Defaults = require('defaults')
local Settings = require('settings')
local Fonts = require('fonts')

local Jobs = require('lin.jobs')
local Text = require('lin.text')

---@class MeModule
---@field config MeSettings
---@field font Font?

---@type MeModule
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

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    local lines = {}

    local party_data = AshitaCore:GetMemoryManager():GetParty()
    local player_data = AshitaCore:GetMemoryManager():GetPlayer()
    local player_entity = GetPlayerEntity()

    if player_entity == nil or Jobs.get_job(player_data:GetMainJob()) == nil then
        Module.font.text = ''
        return
    end

    local player = {
        name = player_entity.Name or '',

        main_job = Jobs.get_job(player_data:GetMainJob()),
        main_lv = player_data:GetMainJobLevel() or 0,

        sub_job = Jobs.get_job(player_data:GetSubJob()),
        sub_lv = player_data:GetSubJobLevel() or 0,

        cur_xp = player_data:GetExpCurrent() or 0,
        max_xp = player_data:GetExpNeeded() or 0,

        is_limit_mode = player_data:GetIsExperiencePointsLocked(),
        merits = player_data:GetMeritPoints(),

        cur_lp = player_data:GetLimitPoints(),
        max_lp = 10000,

        max_hp = player_data:GetHPMax() or 0,
        cur_hp = party_data:GetMemberHP(0) or 0,

        max_mp = player_data:GetMPMax() or 0,
        cur_mp = party_data:GetMemberMP(0) or 0,

        max_tp = 300,
        cur_tp = math.floor(party_data:GetMemberTP(0) / 10) or 0,
    }

    local line1
    if player.sub_job ~= '' and player.sub_job ~= nil then
        line1 = string.format('%-11.11s [%s%2i/%s%2i]',
            player.name,
            player.main_job, player.main_lv,
            player.sub_job, player.sub_lv)
    else
        line1 = string.format('%-17.17s [%s%2i]',
            player.name,
            player.main_job, player.main_lv)
    end

    local line2 = string.format('HP %4i/%4i %s',
        player.cur_hp,
        player.max_hp,
        Text.percent_bar(12, player.cur_hp / player.max_hp))

    local line3 = string.format('MP %4i/%4i %s',
        player.cur_mp,
        player.max_mp,
        Text.percent_bar(12, player.cur_mp / player.max_mp))

    local line4 = string.format('TP %4i/%4i %s',
        player.cur_tp,
        player.max_tp,
        Text.percent_bar(12, player.cur_tp / player.max_tp))

    local line5
    if player.is_limit_mode
    or player.cur_xp == 43999 then
        line5 = string.format('LP %4.4s/%-4.4s %s',
            Text.format_xp(player.cur_lp, false),
            Text.format_xp(player.max_lp, false),
            Text.percent_bar(12, player.cur_lp / player.max_lp))
    else
        line5 = string.format('XP %4.4s/%-4.4s %s',
            Text.format_xp(player.cur_xp, false),
            Text.format_xp(player.max_xp, false),
            Text.percent_bar(12, player.cur_xp / player.max_xp))
    end

    table.insert(lines, line1)
    table.insert(lines, Text.colorize(line2, Text.get_hp_color(player.cur_hp / player.max_hp)))
    table.insert(lines, Text.colorize(line3, Text.get_hp_color(player.cur_mp / player.max_mp)))
    table.insert(lines, Text.colorize(line4, Text.get_tp_color(player.cur_tp / player.max_tp)))
    table.insert(lines, line5)

    Module.font.text = table.concat(lines, '\n')
end)

ashita.events.register('load', 'load_cb', function()
    Module.font = Fonts.new(Module.config.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (Module.font ~= nil) then
        Module.config.font.position_x = Module.font.position_x
        Module.config.font.position_y = Module.font.position_y
        Module.font:destroy()
        Module.font = nil
    end

    Settings.save()
end)
