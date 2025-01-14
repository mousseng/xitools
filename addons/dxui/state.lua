local bit = require('bit')

local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift

local player = AshitaCore:GetMemoryManager():GetPlayer()
local party = AshitaCore:GetMemoryManager():GetParty()
local resx = AshitaCore:GetResourceManager()

local state = {
    party = { },
}

local function getMemberZone(index)
    local zoneId = party:GetMemberZone(index)
    local zoneName = resx:GetString('zones.names', zoneId)
    return zoneName or string.format('Unknown %d', zoneId)
end

local function getMemberJobs(index)
    local main = party:GetMemberMainJob(index)
    local sub = party:GetMemberSubJob(index)
    local mainLv = party:GetMemberMainJobLevel(index)
    local subLv = party:GetMemberSubJobLevel(index)

    if main == 0 then
        return ''
    end

    if sub == 0 then
        local mainAbbr = resx:GetString('jobs.names_abbr', main)
        return string.format('%s%02d', mainAbbr, mainLv)
    end

    local mainAbbr = resx:GetString('jobs.names_abbr', main)
    local subAbbr = resx:GetString('jobs.names_abbr', sub)
    return string.format('%s%02d/%s%02d', mainAbbr, mainLv, subAbbr, subLv)
end

local function getBuffs(index)
    -- impl courtesy of Thorny and Heals
    if index == 0 then
        local effects = { }
        local icons = player:GetStatusIcons()
        for b = 0, 31 do
            local buffId = icons[b]
            if buffId ~= 255 then
                table.insert(effects, buffId)
            end
        end

        return effects
    end

    -- statuses are not stored at the normal party indices, so we need to find
    -- the right set via the server ID
    local serverId = party:GetMemberServerId(index)
    local buffIndex = nil
    for i = 0, 4 do
        local sId = party:GetStatusIconsServerId(i)
        if serverId == party:GetStatusIconsServerId(i) then
            buffIndex = i
        end
    end

    if not buffIndex then
        return { }
    end

    -- once we've found where the buffs are, pull them apart to get the IDs
    local iconsLo = party:GetStatusIcons(buffIndex)
    local iconsHi = party:GetStatusIconsBitMask(buffIndex)
    local effects = { }

    for b = 0, 31 do
        --[[
        --   FIXME: lua doesn't handle 64bit return values properly..
        --   FIXME: the next lines are a workaround by Thorny that cover most but not all cases..
        --   FIXME: .. to try and retrieve the high bits of the buff id.
        --   TODO:  revesit this once atom0s adjusted the API.
        --]]
        local highBits
        if b < 16 then
            highBits = lshift(band(rshift(iconsHi, 2 * b), 3), 8)
        else
            local buffer = math.floor(iconsHi / 0xffffffff)
            highBits = lshift(band(rshift(buffer, 2 * (b - 16)), 3), 8)
        end

        local buffId = iconsLo[b + 1] + highBits
        if buffId ~= 255 then
            table.insert(effects, buffId)
        end
    end

    return effects
end

function state:listen(e)
end

function state:update()
    for i = 0, 17 do
        if party:GetMemberIsActive(i) == 1 then
            self.party[i] = {
                id             = party:GetMemberServerId(i),
                zone           = getMemberZone(i),
                name           = party:GetMemberName(i),
                jobs           = getMemberJobs(i),
                hp             = party:GetMemberHP(i),
                mp             = party:GetMemberMP(i),
                tp             = party:GetMemberTP(i),
                hpp            = party:GetMemberHPPercent(i) / 100,
                mpp            = party:GetMemberMPPercent(i) / 100,
                tpp            = party:GetMemberTP(i) / 3000,
                distance       = nil,
                isLeadParty    = nil,
                isLeadAlliance = nil,
                isSync         = nil,
                isTargetMain   = nil,
                isTargetSub    = nil,
                isTargetParty  = nil,
                buffs          = getBuffs(i),
            }
        end
    end
end

return state
