-------------------------------------------------------------------------------
-- This contains some of the hairier business logic of the addon.
-------------------------------------------------------------------------------

-- The state we're operating on is the expiry time of the statuses
DEFAULT_STATE = {
    -- standard fare
    dia = 0,
    bio = 0,
    para = 0,
    slow = 0,
    grav = 0,
    blind = 0,
    -- utility
    silence = 0,
    sleep = 0,
    bind = 0,
    stun = 0,
    -- misc
    virus = 0,
    curse = 0,
    -- dots
    poison = 0,
    shock = 0,
    rasp = 0,
    choke = 0,
    frost = 0,
    burn = 0,
    drown = 0,
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
    local now = os.time()

    for _, target in pairs(action.targets) do
        for _, ability in pairs(target.actions) do
            if action.category == 4 then
                -- Set up our state
                local spell = action.param
                local message = ability.message
                state[target.id] = state[target.id] or deepCopy(DEFAULT_STATE)

                -- Bio and Dia
                if message == 2 or message == 264 then
                    local expiry = 0

                    if spell == 23 or spell == 33 or spell == 230 then
                        expiry = now + 60
                    elseif spell == 24 or spell == 231 then
                        expiry = now + 120
                    elseif spell == 25 or spell == 232 then
                        expiry = now + 150
                    else
                        -- something went wrong
                        expiry = nil
                    end

                    if spell == 23 or spell == 24 or spell == 25 or spell == 33 then
                        state[target.id].dia = expiry
                        state[target.id].bio = 0
                    elseif spell == 230 or spell == 231 or spell == 232 then
                        state[target.id].dia = 0
                        state[target.id].bio = expiry
                    end
                -- Regular debuffs
                elseif message == 236 or message == 277 then
                    if spell == 58 or spell == 80 then -- para/para2
                        state[target.id].para = now + 120
                    elseif spell == 56 or spell == 79 then -- slow/slow2
                        state[target.id].slow = now + 180
                    elseif spell == 216 then -- gravity
                        state[target.id].grav = now + 120
                    elseif spell == 254 or spell == 276 then -- blind/blind2
                        state[target.id].blind = now + 180
                    elseif spell == 59 or spell == 359 then -- silence/ga
                        state[target.id].silence = now + 120
                    elseif spell == 253 or spell == 259 or spell == 273 or spell == 274 then -- sleep/2/ga/2
                        state[target.id].sleep = now + 90
                    elseif spell == 258 or spell == 362 then -- bind
                        state[target.id].bind = now + 60
                    elseif spell == 252 then -- stun
                        state[target.id].stun = now + 5
                    elseif spell <= 229 and spell >= 220 then -- poison/2
                        state[target.id].poison = now + 120
                    end
                -- Elemental debuffs
                elseif message == 237 or message == 278 then
                    if spell == 239 then -- shock
                        state[target.id].shock = now + 120
                    elseif spell == 238 then -- rasp
                        state[target.id].rasp = now + 120
                    elseif spell == 237 then -- choke
                        state[target.id].choke = now + 120
                    elseif spell == 236 then -- frost
                        state[target.id].frost = now + 120
                    elseif spell == 235 then -- burn
                        state[target.id].burn = now + 120
                    elseif spell == 240 then -- drown
                        state[target.id].drown = now + 120
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
            state[basic.target].sleep = 0
        elseif basic.param == 3 or basic.param == 540 then
            state[basic.target].poison = 0
        elseif basic.param == 4 or basic.param == 566 then
            state[basic.target].para = 0
        elseif basic.param == 5 then
            state[basic.target].blind = 0
        elseif basic.param == 6 then
            state[basic.target].silence = 0
        elseif basic.param == 8 then
            state[basic.target].virus = 0
        elseif basic.param == 9 or basic.param == 20 then
            state[basic.target].curse = 0
        elseif basic.param == 10 then
            state[basic.target].stun = 0
        elseif basic.param == 11 then
            state[basic.target].bind = 0
        elseif basic.param == 12 or basic.param == 567 then
            state[basic.target].grav = 0
        elseif basic.param == 13 or basic.param == 565 then
            state[basic.target].slow = 0
        elseif basic.param == 128 then
            state[basic.target].burn = 0
        elseif basic.param == 129 then
            state[basic.target].frost = 0
        elseif basic.param == 130 then
            state[basic.target].choke = 0
        elseif basic.param == 131 then
            state[basic.target].rasp = 0
        elseif basic.param == 132 then
            state[basic.target].shock = 0
        elseif basic.param == 133 then
            state[basic.target].drown = 0
        elseif basic.param == 134 then
            state[basic.target].dia = 0
        elseif basic.param == 135 then
            state[basic.target].bio = 0
        end
    end
end
