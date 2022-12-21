addon.name    = 'xp'
addon.author  = 'lin'
addon.version = '2.0.0'
addon.desc    = 'Like WatchEXP, but a v4 addon'

require('common')

-- For whatever reason, FFXI uses ASCII 7 as its newline character in the chain
-- messages instead of 10 and/or 13 like one might expect.
local exp_earned = '%w+ gains (%d+) experience points.'
local lmt_earned = '%w+ gains (%d+) limit points.'
local exp_chain  = 'EXP chain #(%d+)!.%w+ gains (%d+) experience points.'
local lmt_chain  = 'Limit chain #(%d+)!.%w+ gains (%d+) limit points.'

local chain_timers = {
    [10] = {  50,  40,  30,  20,  10,   6,   2, },
    [20] = { 100,  80,  60,  40,  20,   8,   4, },
    [30] = { 150, 120,  90,  60,  30,  10,   5, },
    [40] = { 200, 160, 120,  80,  40,  40,  30, },
    [50] = { 250, 200, 150, 100,  50,  50,  50, },
    [60] = { 300, 240, 180, 120,  90,  60,  60, },
    [75] = { 360, 300, 240, 165, 105,  60,  60, },
}

local events = { }
local chain_end = nil

-- Walks through the list of events and sums up the experience gain from events
-- that come after the given time
local function sum_xp(from)
    local sum = 0

    for _, evt in pairs(events) do
        if evt.time >= from then
            sum = sum + evt.gain
        end
    end

    return sum
end

-- Converts a level into the values suitable for indexing into the chain timer
-- table, since level range determines how long a chain lasts
local function clamp_level(lvl)
    if     lvl <= 10 then return 10
    elseif lvl <= 20 then return 20
    elseif lvl <= 30 then return 30
    elseif lvl <= 40 then return 40
    elseif lvl <= 50 then return 50
    elseif lvl <= 60 then return 60
    else                  return 75
    end
end

local function record_exp(exp)
    table.insert(events, {
        time = os.time(),
        gain = exp,
    })
end

local function update_chain(tier)
    -- just nuke chain info if it gets reset
    if tier == 0 then
        chain_end = nil
        return
    end

    local mlvl = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel()
    local lvl = clamp_level(mlvl)

    chain_end = os.time() + chain_timers[lvl][tier]
end

ashita.events.register('text_in', 'text_in_cb', function(e)
    local chain, exp

    chain, exp = string.match(e.message_modified, exp_chain)
    if exp ~= nil then
        update_chain(tonumber(chain))
        record_exp(tonumber(exp))
        return false
    end

    chain, exp = string.match(e.message_modified, lmt_chain)
    if exp ~= nil then
        update_chain(tonumber(chain))
        record_exp(tonumber(exp))
        return false
    end

    exp = string.match(e.message_modified, exp_earned)
    if exp ~= nil then
        update_chain(0)
        record_exp(tonumber(exp))
        return false
    end

    exp = string.match(e.message_modified, lmt_earned)
    if exp ~= nil then
        update_chain(0)
        record_exp(tonumber(exp))
        return false
    end

    return false
end)

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()
    if #args < 1 or args[1] ~= '/xp' then
        return false
    end

    if #args > 1 and args[2] == 'reset' then
        events = { }
        chain_end = nil
        return true
    end

    -- Bail early if nothing to report
    if #events == 0 then
        print('No experience earned yet.')
        return true
    end

    -- Set up our calculations
    local now = os.time()
    local start, duration, total_xp

    if #args == 1 then
        start = events[1].time
    elseif #args == 2 then
        start = now - (args[2] * 60.0)
    end

    duration = (now - start) / 3600.0
    total_xp = sum_xp(start)

    -- First, total out the earned experience for the provided time range
    if total_xp == 0 then
        print(string.format(
            'No experience earned in the past %.1i hours.',
            duration
        ))
    else
        print(string.format(
            'For the past %.1i hours, earned %.1i exp/hr (for %i total).',
            duration,
            total_xp / duration,
            total_xp
        ))
    end

    -- Then provide chain info, if we have anything to share
    if chain_end ~= nil and (chain_end - now) > 0 then
        print(chain_end - now .. 's remaining on the EXP chain.')
    end

    return true
end)
