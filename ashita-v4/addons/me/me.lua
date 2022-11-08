addon.name    = 'me'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for player status'

local fonts = require('fonts')
local scaling = require('scaling')
local settings = require('settings')
local jobs = require('lin.jobs')
local text = require('lin.text')

-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

local default_settings = {
    font = {
        visible = true,
        font_family = 'Consolas',
        font_height = scaling.scale_f(10),
        color = 0xFFFFFFFF,
        position_x = 200,
        position_y = 200,
        background = {
            visible = true,
            color = 0xA0000000,
        }
    }
}

local me = {
    settings = settings.load(default_settings),
    font = nil,
}

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        me.settings = s
    end

    if (me.font ~= nil) then
        me.font:apply(me.settings.font)
    end

    settings.save()
end)

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    local lines = {}

    local party_data = AshitaCore:GetMemoryManager():GetParty()
    local player_data = AshitaCore:GetMemoryManager():GetPlayer()
    local player_entity = GetPlayerEntity()

    if player_entity == nil or jobs.get_job(player_data:GetMainJob()) == nil then
        me.font.text = ''
        return
    end

    local player = {
        name = player_entity.Name or '',

        main_job = jobs.get_job(player_data:GetMainJob()),
        main_lv = player_data:GetMainJobLevel() or 0,

        sub_job = jobs.get_job(player_data:GetSubJob()),
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
        text.percent_bar(12, player.cur_hp / player.max_hp))

    local line3 = string.format('MP %4i/%4i %s',
        player.cur_mp,
        player.max_mp,
        text.percent_bar(12, player.cur_mp / player.max_mp))

    local line4 = string.format('TP %4i/%4i %s',
        player.cur_tp,
        player.max_tp,
        text.percent_bar(12, player.cur_tp / player.max_tp))

    local line5
    if player.is_limit_mode
    or player.cur_xp == 43999 then
        line5 = string.format('LP %4.4s/%-4.4s %s',
            text.format_xp(player.cur_lp, false),
            text.format_xp(player.max_lp, false),
            text.percent_bar(12, player.cur_lp / player.max_lp))
    else
        line5 = string.format('XP %4.4s/%-4.4s %s',
            text.format_xp(player.cur_xp, false),
            text.format_xp(player.max_xp, false),
            text.percent_bar(12, player.cur_xp / player.max_xp))
    end
    table.insert(lines, line1)
    table.insert(lines, text.colorize(line2, text.get_hp_color(player.cur_hp / player.max_hp)))
    table.insert(lines, text.colorize(line3, text.get_hp_color(player.cur_mp / player.max_mp)))
    table.insert(lines, text.colorize(line4, text.get_tp_color(player.cur_tp / player.max_tp)))
    table.insert(lines, line5)

    me.font.text = table.concat(lines, '\n')
end)

ashita.events.register('load', 'load_cb', function()
    me.font = fonts.new(me.settings.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (me.font ~= nil) then
        -- TODO: do we need to manually persist location changes?
        --       if so, maybe just :apply() to the settings object
        me.font:destroy()
        me.font = nil
    end

    settings.save()
end)
