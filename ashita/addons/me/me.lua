-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'me'
_addon.version = '2.0.0'
_addon.unique  = '__me_addon'

require 'common'
require 'lin.text'
require 'lin.jobs'

local config = { x = 200, y = 200 }

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

local limit_mode = {
    exp = 32,
    merit = 224,
}

ashita.register_event('render', function()
    local font = AshitaCore:GetFontManager():Get(_addon.unique)

    local party_data = AshitaCore:GetDataManager():GetParty()
    local player_data = AshitaCore:GetDataManager():GetPlayer()
    local target_data = AshitaCore:GetDataManager():GetTarget()
    local player_entity = GetPlayerEntity()

    if player_entity == nil or lin.get_job(player_data:GetMainJob()) == nil then
        font:SetText('')
        return
    end

    local player = {
        name = player_entity.Name or '',

        main_job = lin.get_job(player_data:GetMainJob()),
        main_lv = player_data:GetMainJobLevel() or 0,

        sub_job = lin.get_job(player_data:GetSubJob()),
        sub_lv = player_data:GetSubJobLevel() or 0,

        cur_xp = player_data:GetExpCurrent() or 0,
        max_xp = player_data:GetExpNeeded() or 0,

        limit_mode = player_data:GetLimitMode(),
        merits = player_data:GetMeritPoints(),

        cur_lp = player_data:GetLimitPoints(),
        max_lp = 10000,

        max_hp = player_data:GetHealthMax() or 0,
        cur_hp = party_data:GetMemberCurrentHP(0) or 0,

        max_mp = player_data:GetManaMax() or 0,
        cur_mp = party_data:GetMemberCurrentMP(0) or 0,

        max_tp = 300,
        cur_tp = math.floor(party_data:GetMemberCurrentTP(0) / 10) or 0,
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
        lin.percent_bar(12, player.cur_hp / player.max_hp))

    local line3 = string.format('MP %4i/%4i %s',
        player.cur_mp,
        player.max_mp,
        lin.percent_bar(12, player.cur_mp / player.max_mp))

    local line4 = string.format('TP %4i/%4i %s',
        player.cur_tp,
        player.max_tp,
        lin.percent_bar(12, player.cur_tp / player.max_tp))

    local line5
    if player.limit_mode == limit_mode.merit
    or player.cur_xp == 43999 then
        line5 = string.format('LP %4.4s/%-4.4s %s',
            lin.format_xp(player.cur_lp, false),
            lin.format_xp(player.max_lp, false),
            lin.percent_bar(12, player.cur_lp / player.max_lp))
    else -- xp
        line5 = string.format('XP %4.4s/%-4.4s %s',
            lin.format_xp(player.cur_xp, false),
            lin.format_xp(player.max_xp, false),
            lin.percent_bar(12, player.cur_xp / player.max_xp))
    end

    local text = {}
    table.insert(text, line1)
    table.insert(text, lin.colorize_text(line2, lin.get_hp_color(player.cur_hp / player.max_hp)))
    table.insert(text, lin.colorize_text(line3, lin.get_hp_color(player.cur_mp / player.max_mp)))
    table.insert(text, lin.colorize_text(line4, lin.get_tp_color(player.cur_tp / player.max_tp)))
    table.insert(text, line5)

    font:SetText(table.concat(text, '\n'))
end)

ashita.register_event('load', function()
    local font = AshitaCore:GetFontManager():Create(_addon.unique)
    config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', config)

    font:SetColor(0xFFFFFFFF)
    font:SetFontFamily('Consolas')
    font:SetFontHeight(10)
    font:SetBold(false)
    font:SetPositionX(config.x)
    font:SetPositionY(config.y)
    font:SetVisibility(true)
    font:GetBackground():SetColor(0xA0000000)
    font:GetBackground():SetVisibility(true)
end)

ashita.register_event('unload', function()
    config.x = AshitaCore:GetFontManager():Get(_addon.unique):GetPositionX()
    config.y = AshitaCore:GetFontManager():Get(_addon.unique):GetPositionY()

    AshitaCore:GetFontManager():Delete(_addon.unique)

    ashita.settings.save(_addon.path .. 'settings/settings.json', config)
end)
