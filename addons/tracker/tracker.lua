-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'tracker'
_addon.version = '1.0.0'
_addon.unique  = '__tracker_addon'

require 'common'
require 'utils'
require 'lin.text'
require 'lin.packets'

local config = { x = 200, y = 200 }

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

local tracked_spells = {
    [ 57] = 'Haste',
    [109] = 'Refresh',
}

local durations = {
    [ 57] = 180,
    [109] = 150,
}

local active_buffs = {
    [ 57] = {},
    [109] = {},
}

local last_render = os.time()

local function sorted(dict, prop)
    local order = {}

    for k, v in pairs(dict) do
        table.insert(order, { id=k, val=v[prop] })
    end

    table.sort(order, function(l,r) return l.val < r.val end)

    local i = 0
    local n = #order
    return function()
        i = i + 1
        if i <= n then return dict[order[i].id] end
    end
end

ashita.register_event('render', function()
    if os.time() - last_render < 1 then return end

    local font = AshitaCore:GetFontManager():Get(_addon.unique)
    local text = { }
    local time = os.time()

    for id, spell_name in pairs(tracked_spells) do
        for cast in sorted(active_buffs[id], 'time') do
            local remaining = durations[id] - (os.time() - cast.time)

            if remaining > -5 then
                local line = string.format(
                    '%-7s %12s %3is',
                    spell_name,
                    cast.name,
                    math.max(remaining, 0)
                )

                if remaining <= 10 then
                    line = lin.colorize_text(line, 243, 50, 50)
                elseif remaining <= 30 then
                    line = lin.colorize_text(line, 255, 165, 0)
                end

                table.insert(text, line)
            end
        end
    end

    font:SetText(table.concat(text, '\n'))
    last_render = os.time()
end)

ashita.register_event('incoming_packet', function(id, size, data)
    if id == 0x0028 then
        local action = lin.parse_action(data)

        if action.actor_id == GetPlayerEntity().ServerId
        and tracked_spells[action.param] ~= nil then
            for i = 1, action.target_count do
                local target = action.targets[i]
                local cast_info = {
                    name = GetEntityNameByServerId(target.id),
                    time = os.time(),
                }

                active_buffs[action.param][target.id] = cast_info
            end
        end
    end

    return false
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
