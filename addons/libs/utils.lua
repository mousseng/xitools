-------------------------------------------------------------------------------
-- These are just some loose functions that I find helpful for clarifying
-- intent, but don't want to clutter up the actual logic of an addon with.
-------------------------------------------------------------------------------

function PercentBar(width, percent, f, h, n)
    if f == nil then f = '=' end
    if h == nil then h = '-' end
    if n == nil then n = ' ' end

    local bar_width = width - 2

    local full_step = 1 / bar_width
    local half_step = 1 / (bar_width * 2)

    local full_bars = math.floor(percent / full_step)
    local half_bars = math.floor((percent % full_step) / half_step)

    local fb = f:rep(full_bars)
    local hb = h:rep(half_bars)
    local nb = n:rep(bar_width - (full_bars + half_bars))

    return string.format('[%s%s%s]', fb, hb, nb)
end

-- Fetch an entity by its server ID. Helpful when looking up information from
-- packets, which tend to not include the entity index (since that's a client
-- thing only). Returns nil if no matching entity is found.
function GetEntityByServerId(id)
    -- The entity array is 2304 items long
    for x = 0, 2303 do
        local e = GetEntity(x)

        -- Ensure the entity is valid
        if e ~= nil and e.WarpPointer ~= 0 then
            if e.ServerId == id then
                return e
            end
        end
    end

    return nil
end

-- Shorthand method to grab an entity's name (by server id, obviously) or a
-- placeholder string if the entity can't be found.
function GetEntityNameByServerId(id)
    local e = GetEntityByServerId(id)

    if e ~= nil and e.Name ~= nil then
        return e.Name
    else
        return '[unknown]'
    end
end

-- Determines if a particular entity (given as a server ID) belongs to the
-- player's party.
function IsServerIdInParty(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.ServerId == id then
                return true
            end
        else
            return false
        end
    end

    return false
end

local jobs = {
    'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG',
    'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',
}

function GetJob(id)
    return jobs[id] or ''
end
