-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'jobbo'
_addon.version = '0.1.0'

require 'utils'
require 'packet'
require 'common'
require 'ffxi.recast'

require 'rdm'

-- Configuration for this addon is a little different than usual since each
-- spell being tracked has its own font surface.
local default_config = {
    ['default'] = {
        font = {
            family    = 'Consolas',
            size      = 10,
            color     = 0xFFFFFFFF,
            position  = { 50, 125 },
            bgcolor   = 0xA0000000,
            bgvisible = true
        }
    },
}

local config = default_config

-------------------------------------------------------------------------------
-- live data
-------------------------------------------------------------------------------

-- GlobalJobConfig is where the job modules dump their configuration. It doesn't
-- matter if they're loaded before or after this line, it'll all work the same.
local JobConfig = GlobalJobConfig or { }
local ActiveJob = 0

local Statuses = { }

-- some rendering garbage; each spell gets its own rendering surface, so we do
-- a little micro-management that's not related to the actual logic of the addon
local Linger = 5
local FontSurfaces = { }
local FontSurfacePrefix = '__jobbo_addon_'

-------------------------------------------------------------------------------
-- helper functions
-------------------------------------------------------------------------------

-- Get a font by the given name; if it doesn't already exist, then create it.
-- This is where we use our FontSurfaces table (set-style in this case).
local function GetFontObject(name, config)
    -- We track our font surfaces by the given tag name; however, for Direct3D
    -- we add a prefix to avoid potential conflicts.
    local font_name = FontSurfacePrefix .. name

    if not FontSurfaces[name] then
        CreateFontObject(font_name, config)
        FontSurfaces[name] = true
    end

    return AshitaCore:GetFontManager():Get(font_name)
end

local function GetSecondsFromRecastTimer(timer)
    local t = timer / 60
    local h = math.floor(t / (60 * 60))
    local m = math.floor(t / 60 - h * 60)
    local s = math.floor(t - (m + h * 60) * 60)

    return s
end

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

-- Show the duration of statuses you've put on targets
local function render()
    local timestamp = os.time()

    ActiveJob = AshitaCore:GetDataManager():GetPlayer():GetMainJob()

    if JobConfig[ActiveJob] ~= nil then
        for spell_id, spell in pairs(JobConfig[ActiveJob]) do
            if config[spell.tag] == nil then
                config[spell.tag] = config.default
            end

            local font = GetFontObject(spell.tag, config[spell.tag])
            local text = T{ }

            -- Create a shitty header to delineate the spells being tracked.
            table.insert(text, string.format('%-13.13s', spell.name))

            -- Pop in a progress bar indicating when the spell is ready to cast.
            local tim = ashita.ffxi.recast.get_spell_recast_by_index(spell_id)
            local sec = GetSecondsFromRecastTimer(tim)
            local bar = GetPercentBar(13, (spell.recast - sec) / spell.recast)

            if sec == 0 then
                bar = string.format('|cFF00FFFF|%s|r', bar)
            end

            table.insert(text, bar)

            -- Splat each target's remaining status duration.
            if Statuses[spell_id] ~= nil then
                for k, cast in pairs(Statuses[spell_id]) do
                    local remaining = math.max(spell.duration - (timestamp - cast.time), 0)
                    local line = string.format('%-8.8s %3is', cast.target, remaining)
                    table.insert(text, line)
                end
            end

            font:SetText(text:concat('\n'))
        end
    end
end

-- Capture magic-finish packets to track basic statuses and recasts
local function handle_packet(id, size, data)
    if id == 0x0028 then
        local spell = ashita.packet.parse_server(data)
        local player = GetPlayerEntity().ServerId

        -- If we detect a spell that's tracked for the current job,
        -- then we need to update our list of statuses.
        if spell.category == 4 and spell.actor_id == player
        and JobConfig[ActiveJob][spell.param] ~= nil then
            for i = 1, spell.target_count do
                local target = spell.targets[i]

                for j = 1, target.action_count do
                    -- Make use of Lua's lexical scoping and capture the current
                    -- state for use (primarily) by the timer, so we can clear
                    -- out the tracked statuses once they're no longer running.
                    local job = ActiveJob
                    local spl = spell.param
                    local tgt = target.id

                    -- Collate info needed for rendering
                    local cast_info = {
                        time = os.time(),
                        target = GetEntityNameByServerId(tgt),
                        recast = spell.recast,
                    }

                    if Statuses[spl] == nil then
                        Statuses[spl] = { }
                    end

                    Statuses[spl][tgt] = cast_info

                    -- Set up or refresh a single-use timer to drop the status
                    -- when it's run its course
                    local timer_id = string.format('%i.%i.%i', job, spl, tgt)

                    ashita.timer.remove_timer(timer_id)
                    ashita.timer.create(timer_id, JobConfig[job][spl].duration + Linger, 1, function() Statuses[spl][tgt] = nil end)
                end
            end
        end
    end

    return false
end

local function load()
    -- Don't bother creating our font surface here - we'll handle that on an
    -- ad-hoc, as-needed basis.
    config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', config)
end

local function unload()
    -- Destroy all of the font surfaces that we've accumulated. FontSurfaces is
    -- a set, so we don't care about its value - only the key.
    for tag, _ in pairs(FontSurfaces) do
        -- Update the config before dumping it; mind the prefix...
        local font_name = FontSurfacePrefix .. tag
        local font = AshitaCore:GetFontManager():Get(font_name)
        config[tag].font.position = { font:GetPositionX(), font:GetPositionY() }

        AshitaCore:GetFontManager():Delete(font_name)
    end

    ashita.settings.save(_addon.path .. 'settings/settings.json', config)
end

ashita.register_event('load', load)
ashita.register_event('unload', unload)
ashita.register_event('render', render)
ashita.register_event('incoming_packet', handle_packet)
