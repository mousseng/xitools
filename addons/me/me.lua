-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'me'
_addon.version = '1.0.0'

require 'utils'
require 'common'
require 'ffxi.targets'

local default_config = {
    font = {
        family    = 'Consolas',
        size      = 10,
        color     = 0xFFFFFFFF,
        position  = { 50, 125 },
        bgcolor   = 0xA0000000,
        bgvisible = true
    }
}

local config = default_config

-------------------------------------------------------------------------------
-- helper functions
-------------------------------------------------------------------------------

local function format_xp(number, include_unit)
    if number < 10000 then
        return string.format('%4i', number)
    elseif include_unit then
        return string.format('%4.1fk', number)
    else
        return string.format('%4.1f', number)
    end
end

local function colorize_text(text, r, g, b, a)
    if a == nil then
        a = 255
    end

    if r < 0 then r = 0 elseif r > 255 then r = 255 end
    if g < 0 then g = 0 elseif g > 255 then g = 255 end
    if b < 0 then b = 0 elseif b > 255 then b = 255 end
    if a < 0 then a = 0 elseif a > 255 then a = 255 end

    return string.format('|c%02x%02x%02x%02x|%s|r', a, r, g, b, text)
end

local function get_hp_color(hp_percent)
        if hp_percent > 0.75 then return 255, 255, 255
    elseif hp_percent > 0.50 then return 255, 255,   0
    elseif hp_percent > 0.25 then return 255, 165,   0
    elseif hp_percent > 0.00 then return 243,  50,  50
    else                          return 255, 255, 255 end
end

local function get_tp_color(tp_percent)
    if tp_percent > 0.33 then return   0, 255, 255
    else return 255, 255, 255 end
end

local function get_percent_bar(percent)
        if percent >= 1.00 then return ' [==========]'
    elseif percent >= 0.95 then return ' [=========-]'
    elseif percent >= 0.90 then return ' [========= ]'
    elseif percent >= 0.85 then return ' [========- ]'
    elseif percent >= 0.80 then return ' [========  ]'
    elseif percent >= 0.75 then return ' [=======-  ]'
    elseif percent >= 0.70 then return ' [=======   ]'
    elseif percent >= 0.65 then return ' [======-   ]'
    elseif percent >= 0.60 then return ' [======    ]'
    elseif percent >= 0.55 then return ' [=====-    ]'
    elseif percent >= 0.50 then return ' [=====     ]'
    elseif percent >= 0.45 then return ' [====-     ]'
    elseif percent >= 0.40 then return ' [====      ]'
    elseif percent >= 0.35 then return ' [===-      ]'
    elseif percent >= 0.30 then return ' [===       ]'
    elseif percent >= 0.25 then return ' [==-       ]'
    elseif percent >= 0.20 then return ' [==        ]'
    elseif percent >= 0.15 then return ' [=-        ]'
    elseif percent >= 0.10 then return ' [=         ]'
    elseif percent >= 0.05 then return ' [-         ]'
    else                        return ' [          ]' end
end

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

function load()
    config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', config)

    local font = AshitaCore:GetFontManager():Create('__me_addon')
    font:SetColor(config.font.color)
    font:SetFontFamily(config.font.family)
    font:SetFontHeight(config.font.size)
    font:SetBold(false)
    font:SetPositionX(config.font.position[1])
    font:SetPositionY(config.font.position[2])
    font:SetText('me ~ by lin')
    font:SetVisibility(true)
    font:GetBackground():SetColor(config.font.bgcolor)
    font:GetBackground():SetVisibility(config.font.bgvisible)
end

function unload()
    local font = AshitaCore:GetFontManager():Get('__me_addon')
    config.font.position = { font:GetPositionX(), font:GetPositionY() }
    ashita.settings.save(_addon.path .. 'settings/settings.json', config)
    AshitaCore:GetFontManager():Delete('__me_addon')
end

function render()
    local font = AshitaCore:GetFontManager():Get('__me_addon')

    local party_data = AshitaCore:GetDataManager():GetParty()
    local player_data = AshitaCore:GetDataManager():GetPlayer()
    local target_data = AshitaCore:GetDataManager():GetTarget()
    local player_entity = GetPlayerEntity()

    if party_data == nil or player_data == nil or player_entity == nil then
        font:SetText('')
        return
    end

    local player = {
        name = player_entity.Name or '',

        main_job = GetJob(player_data:GetMainJob()) or 0,
        main_lv = player_data:GetMainJobLevel() or 0,

        sub_job = GetJob(player_data:GetSubJob()) or 0,
        sub_lv = player_data:GetSubJobLevel() or 0,

        cur_xp = player_data:GetExpCurrent() or 0,
        max_xp = player_data:GetExpNeeded() or 0,

        max_hp = player_data:GetHealthMax() or 0,
        cur_hp = party_data:GetMemberCurrentHP(0) or 0,

        max_mp = player_data:GetManaMax() or 0,
        cur_mp = party_data:GetMemberCurrentMP(0) or 0,

        max_tp = 300,
        cur_tp = math.floor(party_data:GetMemberCurrentTP(0) / 10) or 0,
    }

    local line1 = player.name
        .. ' (Lv' .. player.main_lv .. ' ' .. player.main_job

    if player.sub_job ~= 0 then
        line1 = line1 .. ', Lv' .. player.sub_lv .. ' ' .. player.sub_job
    end

    line1 = line1 .. ')'

    local line2 = '\nHP ' .. string.format('%4i', player.cur_hp)
        .. '/' .. string.format('%4i', player.max_hp)
        .. get_percent_bar(player.cur_hp / player.max_hp)

    local line3 = '\nMP ' .. string.format('%4i', player.cur_mp)
        .. '/' .. string.format('%4i', player.max_mp)
        .. get_percent_bar(player.cur_mp / player.max_mp)

    local line4 = '\nTP ' .. string.format('%4i', player.cur_tp)
        .. '/' .. string.format('%4i', player.max_tp)
        .. get_percent_bar(player.cur_tp / player.max_tp)

    local line5 = '\nXP ' .. format_xp(player.cur_xp, false)
        .. '/' .. format_xp(player.max_xp, true)
        .. get_percent_bar(player.cur_xp / player.max_xp)


    local text = line1
        .. colorize_text(line2, get_hp_color(player.cur_hp / player.max_hp))
        .. colorize_text(line3, get_hp_color(player.cur_mp / player.max_mp))
        .. colorize_text(line4, get_tp_color(player.cur_tp / player.max_tp))
        .. line5

    local target = ashita.ffxi.targets.get_target('t')
    if target ~= nil and target.Name ~= '' and target.TargetIndex ~= 0 then
        local dist = string.format('%.1f', math.sqrt(target.Distance))

        local target_line1 = string.format('%-17.17s %s', target.Name, ' [' .. dist .. 'm]')
        local target_line2 = '\nHP      '
            .. string.format('%3i', target.HealthPercent) .. '%'
            .. get_percent_bar(target.HealthPercent / 100)

        text = text .. '\n\n'
            .. target_line1
            .. colorize_text(target_line2, get_hp_color(target.HealthPercent / 100))
    end

    font:SetText(text)
end

ashita.register_event('load', load)
ashita.register_event('unload', unload)
ashita.register_event('render', render)
