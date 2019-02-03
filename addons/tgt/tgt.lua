-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'tgt'
_addon.version = '1.0.0'
_addon.unique  = '__tgt_addon'

require 'common'
require 'lin.text'
require 'ffxi.targets'

local config = { x = 200, y = 200 }

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

ashita.register_event('render', function()
    local font = AshitaCore:GetFontManager():Get(_addon.unique)
    local text = { }

    local target = ashita.ffxi.targets.get_target('t')

    -- do we have anything targeted?
    if target ~= nil and target.Name ~= '' and target.TargetIndex ~= 0 then
        local dist = string.format(
            '[%.1fm]',
            math.sqrt(target.Distance))

        local line1 = string.format(
            '%-17.17s %7s',
            target.Name,
            dist)

        local line2 = string.format(
            'HP      %3i%% %s',
            target.HealthPercent,
            percent_bar(12, target.HealthPercent / 100))

        -- Line 3: debuff status icons.
        -- DB PSGB Sh Ra Ch Fr Bu Dr
        -- Other considerations: Poison, Bind, Sleep, Silence

        -- local target_debuffs = debuffs[target.ServerId]
        -- local line3 = string.format(
        --     '%s%s %s%s%s%s %s %s %s %s %s %s',
        --     colorize_text('D', target_debuffs.dia),
        --     colorize_text('B', target_debuffs.bio),
        --     colorize_text('P', target_debuffs.paralyze),
        --     colorize_text('S', target_debuffs.slow),
        --     colorize_text('G', target_debuffs.blind),
        --     colorize_text('B', target_debuffs.gravity),
        --     colorize_text('Sh', target_debuffs.shock),
        --     colorize_text('Ra', target_debuffs.rasp),
        --     colorize_text('Ch', target_debuffs.choke),
        --     colorize_text('Fr', target_debuffs.frost),
        --     colorize_text('Bu', target_debuffs.burn),
        --     colorize_text('Dr', target_debuffs.drown),
        -- )

        table.insert(text, '')
        table.insert(text, line1)
        table.insert(text, colorize_text(line2, get_hp_color(target.HealthPercent / 100)))
        -- table.insert(text, line3)
    end

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
