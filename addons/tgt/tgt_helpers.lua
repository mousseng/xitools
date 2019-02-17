-------------------------------------------------------------------------------
-- This contains some of the hairier business logic of the addon.
-------------------------------------------------------------------------------

DEFAULT_STATE = {
    -- standard fare
    dia = nil,
    bio = nil,
    para = nil,
    slow = nil,
    grav = nil,
    blind = nil,
    -- utility
    silence = nil,
    sleep = nil,
    bind = nil,
    stun = nil,
    -- misc
    virus = nil,
    curse = nil,
    -- dots
    poison = nil,
    shock = nil,
    rasp = nil,
    choke = nil,
    frost = nil,
    burn = nil,
    drown = nil,
}

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function handle_action(state, action)
    for _, target in pairs(action.targets) do
        for _, ability in pairs(target.actions) do
            if action.category == 4 then
                -- Set up our state
                local spell = action.param
                local message = ability.message
                state[target.id] = state[target.id] or deepCopy(DEFAULT_STATE)

                -- Bio and Dia
                if message == 2 or message == 264 then
                    if spell == 23 or spell == 24 or spell == 25 or spell == 33 then
                        state[target.id].dia = true
                        state[target.id].bio = false
                    elseif spell == 230 or spell == 231 or spell == 232 then
                        state[target.id].bio = true
                        state[target.id].dia = false
                    end

                    -- Set up timers
                    local timer_id = string.format('%i diabio', target.id)
                    local timer_len = nil

                    if spell == 23 or spell == 33 or spell == 230 then
                        timer_len = 60
                    elseif spell == 24 or spell == 231 then
                        timer_len = 120
                    else--if spell == 25 or spell == 232 then
                        timer_len = 150
                    end

                    ashita.timer.remove_timer(timer_id)
                    ashita.timer.create(timer_id, timer_len, 1, function()
                        state[target.id].dia = nil
                        state[target.id].bio = nil
                    end)
                -- Regular debuffs
                elseif message == 236 or message == 277 then
                    if spell == 58 or spell == 80 then -- para/para2
                        state[target.id].para = true

                        local timer_id = string.format('%i para', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].para = nil
                        end)
                    elseif spell == 56 or spell == 79 then -- slow/slow2
                        state[target.id].slow = true

                        local timer_id = string.format('%i slow', target.id)
                        local timer_len = 180

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, timer_len, 1, function()
                            state[target.id].slow = nil
                        end)
                    elseif spell == 216 then -- gravity
                        state[target.id].grav = true

                        local timer_id = string.format('%i grav', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].grav = nil
                        end)
                    elseif spell == 254 or spell == 276 then -- blind/blind2
                        state[target.id].blind = true

                        local timer_id = string.format('%i blind', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 180, 1, function()
                            state[target.id].blind = nil
                        end)
                    elseif spell == 59 or spell == 359 then -- silence/ga
                        state[target.id].silence = true

                        local timer_id = string.format('%i silence', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].silence = nil
                        end)
                    elseif spell == 253 or spell == 259 or spell == 273 or spell == 274 then -- sleep/2/ga/2
                        state[target.id].sleep = true

                        local timer_id = string.format('%i sleep', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 90, 1, function()
                            state[target.id].sleep = nil
                        end)
                    elseif spell == 258 or spell == 362 then -- bind
                        state[target.id].bind = true

                        local timer_id = string.format('%i bind', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 60, 1, function()
                            state[target.id].bind = nil
                        end)
                    elseif spell == 252 then -- stun
                        state[target.id].stun = true

                        local timer_id = string.format('%i stun', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 5, 1, function()
                            state[target.id].stun = nil
                        end)
                    elseif spell <= 229 and spell >= 220 then -- poison/2
                        state[target.id].poison = true

                        local timer_id = string.format('%i poison', target.id)

                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].poison = nil
                        end)
                    end
                -- Elemental debuffs
                elseif message == 237 or message == 278 then
                    if spell == 239 then -- shock
                        state[target.id].shock = true

                        local timer_id = string.format('%i shock', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].shock = nil
                        end)
                    elseif spell == 238 then -- rasp
                        state[target.id].rasp = true

                        local timer_id = string.format('%i rasp', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].rasp = nil
                        end)
                    elseif spell == 237 then -- choke
                        state[target.id].choke = true

                        local timer_id = string.format('%i choke', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].choke = nil
                        end)
                    elseif spell == 236 then -- frost
                        state[target.id].frost = true

                        local timer_id = string.format('%i frost', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].frost = nil
                        end)
                    elseif spell == 235 then -- burn
                        state[target.id].burn = true

                        local timer_id = string.format('%i burn', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].burn = nil
                        end)
                    elseif spell == 240 then -- drown
                        state[target.id].drown = true

                        local timer_id = string.format('%i drown', target.id)
                        ashita.timer.remove_timer(timer_id)
                        ashita.timer.create(timer_id, 120, 1, function()
                            state[target.id].drown = nil
                        end)
                    end
                end
            end
        end
    end
end

function handle_basic(state, basic)
    if basic.message == 206 then
        local status_name = AshitaCore:GetResourceManager():GetString('statusnames', basic.param)

        if state[basic.target] == nil then
            return
        end

        if basic.param == 2 or basic.param == 19 then
            state[basic.target].sleep = nil
        elseif basic.param == 3 or basic.param == 540 then
            state[basic.target].poison = nil
        elseif basic.param == 4 or basic.param == 566 then
            state[basic.target].para = nil
        elseif basic.param == 5 then
            state[basic.target].blind = nil
        elseif basic.param == 6 then
            state[basic.target].silence = nil
        elseif basic.param == 8 then
            state[basic.target].virus = nil
        elseif basic.param == 9 or basic.param == 20 then
            state[basic.target].curse = nil
        elseif basic.param == 10 then
            state[basic.target].stun = nil
        elseif basic.param == 11 then
            state[basic.target].bind = nil
        elseif basic.param == 12 or basic.param == 567 then
            state[basic.target].grav = nil
        elseif basic.param == 13 or basic.param == 565 then
            state[basic.target].slow = nil
        elseif basic.param == 128 then
            state[basic.target].burn = nil
        elseif basic.param == 129 then
            state[basic.target].frost = nil
        elseif basic.param == 130 then
            state[basic.target].choke = nil
        elseif basic.param == 131 then
            state[basic.target].rasp = nil
        elseif basic.param == 132 then
            state[basic.target].shock = nil
        elseif basic.param == 133 then
            state[basic.target].drown = nil
        elseif basic.param == 134 then
            state[basic.target].dia = nil
        elseif basic.param == 135 then
            state[basic.target].bio = nil
        end
    end
end
