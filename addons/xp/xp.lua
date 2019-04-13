-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'xp'
_addon.version = '1.0.0'
_addon.unique  = '__xp_addon'

require 'common'

local levels = require 'levels'
local prev_session = { }
local cur_session  = { }

-------------------------------------------------------------------------------
-- misc functions
-------------------------------------------------------------------------------

-- Checks to see if an input string matches a specified expression string, or is
-- a subset of the specified expression string.
local function matches(str, expr)
    for i = 1, #str do
        if str:sub(i,i) ~= expr:sub(i,i) then
            return false
        end
    end

    return true
end

-- Gets the current total experience of the player.
local function get_xp()
    local player_data = AshitaCore:GetDataManager():GetPlayer()
    return player_data:GetExpCurrent() + levels[player_data:GetExpNeeded()]
end

-- Gets the last element of an array-style table.
local function tail(tbl)
    return tbl[#tbl]
end

-------------------------------------------------------------------------------
-- display functions
-------------------------------------------------------------------------------

-- Given an array of experience segments, returns the sum of the experience
-- earned and the sum of the time elapsed.
local function sum_segments(segments)
    local sum_ss = 0
    local sum_xp = 0

    for idx, seg in pairs(segments) do
        local head = seg.head
        local tail = seg.tail

        if tail == nil then
            tail = { time = os.time(), xp = get_xp() }
        end

        sum_ss = sum_ss + (tail.time - head.time)
        sum_xp = sum_xp + (tail.xp - head.xp)
    end

    return sum_ss, sum_xp
end

-- Converts seconds to hours.
local function hours(seconds)
    return seconds / 3600.0
end

-- Takes a number of seconds and returns a friendly string.
local function format_time(seconds)
    if seconds < 60 then
        return string.format('%i seconds', seconds)
    elseif seconds < 3600 then
        return string.format('%i minutes', seconds / 60)
    else
        return string.format('%i hours', seconds / 3600)
    end
end

-------------------------------------------------------------------------------
-- command functions
-------------------------------------------------------------------------------

-- Prints the current status of the experience recorded. If there is no current
-- and no saved session, prints basically nothing; if there's no current but
-- there is a saved session, prints the previous session. Finally, if there's an
-- active session, prints that.
local function display(cur, prev)
    local total_time, total_xp, message

    if #cur == 0 and #prev == 0 then
        return 'No experience history.'
    elseif #cur == 0 and #prev > 0 then
        total_time, total_xp = sum_segments(prev)
        message = 'Earned %.1f experience per hour (%i over %s)'
    else
        total_time, total_xp = sum_segments(cur)
        message = 'Earning %.1f experience per hour (%i over %s)'
    end

    return string.format(
        message,
        total_xp / hours(total_time),
        total_xp,
        format_time(total_time))
end

-- Starts a new session, as long as there's no other active session.
local function start_xp()
    if #cur_session > 0 then
        return
    end

    cur_session = { }
    table.insert(cur_session, {
        head = { time = os.time(), xp = get_xp() },
        tail = nil,
    })
end

-- A shorthand for stopping and starting. Pushes the current session into the
-- history slot and creates a new active session.
local function reset_xp()
    if #cur_session == 0 then
        return
    end

    prev_session = cur_session
    cur_session = { }
    table.insert(cur_session, {
        head = { time = os.time(), xp = get_xp() },
        tail = nil,
    })
end

-- Pushes current session into history slot, as long as there's a current one to
-- work with.
local function stop_xp()
    if #cur_session == 0 then
        return
    end

    tail(cur_session).tail = { time = os.time(), xp = get_xp() }

    prev_session = cur_session
    cur_session = { }
end

-- Closes the current session's segment, as long as there is a current session.
local function pause_xp()
    if #cur_session == 0 then
        return
    end

    tail(cur_session).tail = { time = os.time(), xp = get_xp() }
end

-- Adds a new segment to the current session, as long as there is one.
local function resume_xp()
    if #cur_session == 0 then
        return
    end

    table.insert(cur_session, {
        head = { time = os.time(), xp = get_xp() },
        tail = nil,
    })
end

ashita.register_event('command', function(cmd)
    local args = cmd:args()

    if #args < 1 or args[1] ~= '/xp' then
        return false
    end

    if args[2] == nil then
        print(display(cur_session, prev_session))
    elseif matches(args[2], 'start') then
        print('Starting experience session.')
        start_xp()
    elseif matches(args[2], 'reset') then
        print('Starting new session.')
        reset_xp()
    elseif matches(args[2], 'stop') then
        stop_xp()
        print(display(cur_session, prev_session))
    elseif matches(args[2], 'pause') then
        print('Pausing experience session.')
        pause_xp()
    elseif matches(args[2], 'resume') then
        print('Resuming experience session.')
        pause_xp()
    end

    return true
end)
