local Text = require('lin.text')

local core = { }

-- The state we're operating on is the expiry time of the statuses
local DefaultDebuffs = {
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

---@param object table
---@return table
local function deepCopy(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for index, value in pairs(obj) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(object)
end

---@param debuffs TrackedEnemies
---@param includeStatus boolean
---@param includePreamble boolean
---@return string
function core.Draw(debuffs, includeStatus, includePreamble)
    local now = os.time()
    local lines = { }
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
            target.HPPercent,
            Text.PercentBar(12, target.HPPercent / 100))

        -- build basic target display
        if includePreamble then
            table.insert(lines, '')
        end

        table.insert(lines, line1)
        table.insert(lines, Text.Colorize(line2, Text.GetHpColor(target.HPPercent / 100)))

        -- build advanced status display for target
        -- DB PGSB Si Sl Bi PoSRCFBD
        if includeStatus then
            local tgt_debuffs = debuffs[target.ServerId] or deepCopy(DefaultDebuffs)
            local line3 = string.format(
                '%s%s %s%s%s%s %s %s %s %s%s%s%s%s%s%s',
                -- '%s%s %s%s%s%s %s %s %s %s %s %s',
                Text.Colorize('D',  when(now < tgt_debuffs.dia, white, grey)),
                Text.Colorize('B',  when(now < tgt_debuffs.bio, black, grey)),
                Text.Colorize('P',  when(now < tgt_debuffs.para, white, grey)),
                Text.Colorize('S',  when(now < tgt_debuffs.slow, white, grey)),
                Text.Colorize('G',  when(now < tgt_debuffs.grav, black, grey)),
                Text.Colorize('B',  when(now < tgt_debuffs.blind, black, grey)),
                Text.Colorize('Si', when(now < tgt_debuffs.silence, white, grey)),
                Text.Colorize('Sl', when(now < tgt_debuffs.sleep, black, grey)),
                Text.Colorize('Bi', when(now < tgt_debuffs.bind, black, grey)),
                Text.Colorize('Po', when(now < tgt_debuffs.poison, black, grey)),
                Text.Colorize('S',  when(now < tgt_debuffs.shock, yellow, grey)),
                Text.Colorize('R',  when(now < tgt_debuffs.rasp, brown, grey)),
                Text.Colorize('C',  when(now < tgt_debuffs.choke, green, grey)),
                Text.Colorize('F',  when(now < tgt_debuffs.frost, cyan, grey)),
                Text.Colorize('B',  when(now < tgt_debuffs.burn, red, grey)),
                Text.Colorize('D',  when(now < tgt_debuffs.drown, blue, grey))
            )

            table.insert(lines, line3)
        end
    end

    return table.concat(lines, '\n')
end

---@param debuffs TrackedEnemies
---@param action any
function core.HandleAction(debuffs, action)
    local now = os.time()

    for _, target in pairs(action.targets) do
        for _, ability in pairs(target.actions) do
            if action.category == 4 then
                -- Set up our state
                local spell = action.param
                local message = ability.message
                debuffs[target.id] = debuffs[target.id] or deepCopy(DefaultDebuffs)

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
                        debuffs[target.id].dia = expiry
                        debuffs[target.id].bio = 0
                    elseif spell == 230 or spell == 231 or spell == 232 then
                        debuffs[target.id].dia = 0
                        debuffs[target.id].bio = expiry
                    end
                -- Regular debuffs
                elseif message == 236 or message == 277 then
                    if spell == 58 or spell == 80 then -- para/para2
                        debuffs[target.id].para = now + 120
                    elseif spell == 56 or spell == 79 then -- slow/slow2
                        debuffs[target.id].slow = now + 180
                    elseif spell == 216 then -- gravity
                        debuffs[target.id].grav = now + 120
                    elseif spell == 254 or spell == 276 then -- blind/blind2
                        debuffs[target.id].blind = now + 180
                    elseif spell == 59 or spell == 359 then -- silence/ga
                        debuffs[target.id].silence = now + 120
                    elseif spell == 253 or spell == 259 or spell == 273 or spell == 274 then -- sleep/2/ga/2
                        debuffs[target.id].sleep = now + 90
                    elseif spell == 258 or spell == 362 then -- bind
                        debuffs[target.id].bind = now + 60
                    elseif spell == 252 then -- stun
                        debuffs[target.id].stun = now + 5
                    elseif spell <= 229 and spell >= 220 then -- poison/2
                        debuffs[target.id].poison = now + 120
                    end
                -- Elemental debuffs
                elseif message == 237 or message == 278 then
                    if spell == 239 then -- shock
                        debuffs[target.id].shock = now + 120
                    elseif spell == 238 then -- rasp
                        debuffs[target.id].rasp = now + 120
                    elseif spell == 237 then -- choke
                        debuffs[target.id].choke = now + 120
                    elseif spell == 236 then -- frost
                        debuffs[target.id].frost = now + 120
                    elseif spell == 235 then -- burn
                        debuffs[target.id].burn = now + 120
                    elseif spell == 240 then -- drown
                        debuffs[target.id].drown = now + 120
                    end
                end
            end
        end
    end
end

---@param debuffs TrackedEnemies
---@param basic any
function core.HandleBasic(debuffs, basic)
    -- if we're tracking a mob that dies, reset its status
    if basic.message == 6 and debuffs[basic.target] then
        debuffs[basic.target] = nil
    elseif basic.message == 206 then
        if debuffs[basic.target] == nil then
            return
        end

        if basic.param == 2 or basic.param == 19 then
            debuffs[basic.target].sleep = 0
        elseif basic.param == 3 or basic.param == 540 then
            debuffs[basic.target].poison = 0
        elseif basic.param == 4 or basic.param == 566 then
            debuffs[basic.target].para = 0
        elseif basic.param == 5 then
            debuffs[basic.target].blind = 0
        elseif basic.param == 6 then
            debuffs[basic.target].silence = 0
        elseif basic.param == 8 then
            debuffs[basic.target].virus = 0
        elseif basic.param == 9 or basic.param == 20 then
            debuffs[basic.target].curse = 0
        elseif basic.param == 10 then
            debuffs[basic.target].stun = 0
        elseif basic.param == 11 then
            debuffs[basic.target].bind = 0
        elseif basic.param == 12 or basic.param == 567 then
            debuffs[basic.target].grav = 0
        elseif basic.param == 13 or basic.param == 565 then
            debuffs[basic.target].slow = 0
        elseif basic.param == 128 then
            debuffs[basic.target].burn = 0
        elseif basic.param == 129 then
            debuffs[basic.target].frost = 0
        elseif basic.param == 130 then
            debuffs[basic.target].choke = 0
        elseif basic.param == 131 then
            debuffs[basic.target].rasp = 0
        elseif basic.param == 132 then
            debuffs[basic.target].shock = 0
        elseif basic.param == 133 then
            debuffs[basic.target].drown = 0
        elseif basic.param == 134 then
            debuffs[basic.target].dia = 0
        elseif basic.param == 135 then
            debuffs[basic.target].bio = 0
        end
    end
end

return core
