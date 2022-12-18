addon.name    = 'tgt'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for target status'

local common = require('common')
local fonts = require('fonts')
local settings = require('settings')
local text = require('lin.text')
local packets = require('lin.packets')

require('tgt_helpers')

-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

local default_settings = {
    -- this setting prepends a blank line to the HUD. this is intended to be
    -- used in conjunction with `me` to make it appear as a single unit while
    -- preserving some clarity with whitespace.
    dependent = true,
    -- this controls whether the HUD includes a "status bar" of sorts. it's not
    -- perfect (it relies on packet parsing, so it misses stuff if you're out of
    -- range) and is quite dense, but it's good for jobs like RDM to manage
    -- debuff uptime.
    status = true,
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

local tgt = {
    settings = settings.load(default_settings),
    font = nil,
}

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        tgt.settings = s
    end

    if (tgt.font ~= nil) then
        tgt.font:apply(tgt.settings.font)
    end

    settings.save()
end)

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

-- Just a little syntactical sugar. Takes a conditional and two functions, one
-- for when the conditional is truthy and one for falsey.
local function when(cond, t, f)
    if cond then return t()
    else return f() end
end

local function grey()   return 255, 255, 255, 127 end
local function white()  return 250, 235, 215 end
local function black()  return 153,  50, 204 end
local function yellow() return 205, 205, 205 end
local function brown()  return 255, 246, 143 end
local function green()  return 154, 205,  50 end
local function blue()   return  72, 118, 255 end
local function red()    return 205,  55,   0 end
local function cyan()   return 150, 205, 205 end

local debuffs = { }

ashita.events.register('d3d_present', 'd3d_present_cb', function()
    local now = os.time()
    local lines = {}
    local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0))

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
            text.percent_bar(12, target.HealthPercent / 100))

        -- build basic target display
        if tgt.settings.dependent then
            table.insert(text, '')
        end

        table.insert(text, line1)
        table.insert(text, text.colorize(line2, text.get_hp_color(target.HealthPercent / 100)))

        -- build advanced status display for target
        -- DB PGSB Si Sl Bi PoSRCFBD
        if tgt.settings.status then
            local tgt_debuffs = debuffs[target.ServerId] or deepCopy(DEFAULT_STATE)
            local line3 = string.format(
                '%s%s %s%s%s%s %s %s %s %s%s%s%s%s%s%s',
                -- '%s%s %s%s%s%s %s %s %s %s %s %s',
                text.colorize('D',  when(now < tgt_debuffs.dia, white, grey)),
                text.colorize('B',  when(now < tgt_debuffs.bio, black, grey)),
                text.colorize('P',  when(now < tgt_debuffs.para, white, grey)),
                text.colorize('S',  when(now < tgt_debuffs.slow, white, grey)),
                text.colorize('G',  when(now < tgt_debuffs.grav, black, grey)),
                text.colorize('B',  when(now < tgt_debuffs.blind, black, grey)),
                text.colorize('Si', when(now < tgt_debuffs.silence, white, grey)),
                text.colorize('Sl', when(now < tgt_debuffs.sleep, black, grey)),
                text.colorize('Bi', when(now < tgt_debuffs.bind, black, grey)),
                text.colorize('Po', when(now < tgt_debuffs.poison, black, grey)),
                text.colorize('S',  when(now < tgt_debuffs.shock, yellow, grey)),
                text.colorize('R',  when(now < tgt_debuffs.rasp, brown, grey)),
                text.colorize('C',  when(now < tgt_debuffs.choke, green, grey)),
                text.colorize('F',  when(now < tgt_debuffs.frost, cyan, grey)),
                text.colorize('B',  when(now < tgt_debuffs.burn, red, grey)),
                text.colorize('D',  when(now < tgt_debuffs.drown, blue, grey))
            )

            table.insert(text, line3)
        end
    end

    current_font.text = table.concat(text, '\n')
end)

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()

    if #args < 2 or args[1] ~= '/tgt' then
        return false
    end

    if args[2] == 'line' then
        tgt.settings.dependent = not tgt.settings.dependent
    elseif args[2] == 'status' then
        tgt.settings.status = not tgt.settings.status
    elseif args[2] == 'dump' then
        print(tostring(debuffs))

        for id, mob in pairs(debuffs) do
            print(string.format(
                '[%s] id %i: '
                .. 'dia %s, bio %s, para %s, slow %s, grav %s, bld %s, '
                .. 'sil %s, slp %s, bind %s, pois %s, '
                .. 'sh %s, ra %s, ch %s, fr %s, bu %s, dr %s',
                tostring(mob), id,
                tostring(mob.dia),
                tostring(mob.bio),
                tostring(mob.para),
                tostring(mob.slow),
                tostring(mob.grav),
                tostring(mob.blind),
                tostring(mob.silence),
                tostring(mob.sleep),
                tostring(mob.bind),
                tostring(mob.poison),
                tostring(mob.shock),
                tostring(mob.rasp),
                tostring(mob.choke),
                tostring(mob.frost),
                tostring(mob.burn),
                tostring(mob.drown)
            ))
        end
    end

    return false
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    -- don't track anything if we're not displaying it
    if not tgt.settings.status then return end

    -- clear state on zone changes
    if e.id == 0x0A then
        debuffs = { }
    elseif e.id == 0x0028 then
        handle_action(debuffs, packets.parse_action(e.data))
    elseif e.id == 0x0029 then
        handle_basic(debuffs, packets.parse_basic(e.data))
    end

    return false
end)

ashita.events.register('load', 'load_cb', function()
    tgt.font = fonts.new(tgt.settings.font)
end)

ashita.events.register('unload', 'unload_cb', function()
    if (tgt.font ~= nil) then
        -- TODO: do we need to manually persist location changes?
        --       if so, maybe just :apply() to the settings object
        tgt.font:destroy()
        tgt.font = nil
    end

    settings.save()
end)
