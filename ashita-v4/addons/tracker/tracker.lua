addon.name    = 'tracker'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'Like status but shittier'

local common = require('common')
local settings = require('settings')
local ffxi = require('lin.ffxi')
local text = require('lin.text')
local packets = require('lin.packets')

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

local tracker = {
    settings = settings.load(default_settings),
    font = nil,
}

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        tracker.settings = s
    end

    if (tracker.font ~= nil) then
        tracker.font:apply(tracker.settings.font)
    end

    settings.save()
end)

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

ashita.events.register('d3d_present', 'd3d_present_cb', function()
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

ashita.events.register('incoming_packet', 'incoming_packet_cb', function(e)
    if id == 0x28 then
        local action = packets.parse_action(e.data)

        if GetPlayerEntity() ~= nil
        and action.actor_id == GetPlayerEntity().ServerId
        and tracked_spells[action.param] ~= nil then
            for i = 1, action.target_count do
                local target = action.targets[i]
                local cast_info = {
                    name = ffxi.get_entity_name_by_server_id(target.id),
                    time = os.time(),
                }

                active_buffs[action.param][target.id] = cast_info
            end
        end
    end

    return false
end)

ashita.events.register('load', 'load_cb', function()
    tracker.font = fonts.new(tracker.settings.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (tracker.font ~= nil) then
        -- TODO: do we need to manually persist location changes?
        --       if so, maybe just :apply() to the settings object
        tracker.font:destroy()
        tracker.font = nil
    end

    settings.save()
end)
