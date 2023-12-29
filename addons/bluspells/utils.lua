local utils = { }

local function Pairify(key, val)
    return string.format('%-16s: %s', key, val)
end

local function StringifyStats(statBlock)
    local stats = { }
    for stat, bonus in pairs(statBlock) do
        local template = '%s +%i'
        if bonus < 0 then
            template = '%s %i'
        end
        local str = string.format(template, string.upper(stat), bonus)
        table.insert(stats, str)
    end

    if #stats == 0 then
        return Pairify('Stats', '(none)')
    end

    return Pairify('Stats', table.concat(stats, ', '))
end

local function StringifyTrait(trait, points)
    if trait == nil then
        return Pairify('Trait', '(none)')
    end

    return Pairify('Trait', string.format('%s +%i', trait, points))
end

local function StringifyDamage(type, element)
    if element == nil then
        return Pairify('Damage Type', type)
    end

    return Pairify('Damage Type', string.format('%s %s', element, type))
end

local function StringifyEcosystem(type, family)
    return Pairify('Ecosystem', string.format('%s (%s)', type, family))
end

local function StringifyCasting(mpCost, cast, recast)
    return Pairify('Casting', string.format('%i MP, %.1fs cast, %.1fs recast', mpCost, cast / 1000, recast / 1000))
end

local function StringifyTargeting(type, range, area)
    if range > 0 and area == 0 then
        return Pairify('Targeting', string.format('Targets %s, %iy range', type, range))
    elseif range == 0 and area > 0 then
        return Pairify('Targeting', string.format('Targets %s, %iy area', type, area))
    elseif range == 0 and area == 0 then
        return Pairify('Targeting', string.format('Targets %s', type))
    end

    return Pairify('Targeting', string.format('Targets %s, %iy range, %iy area', type, range, area))
end

local function StringifyResonances(res)
    if #res == 0 then
        return nil
    end

    return Pairify('Resonances', table.concat(res, ', '))
end

local function StringifyAttributes(attr)
    if #attr == 0 then
        return nil
    end

    local attrs = { }
    for stat, scale in pairs(attr) do
        local str = string.format('%s %i%%', string.upper(stat), scale * 100)
        table.insert(attrs, str)
    end

    return Pairify('WSC Attributes', table.concat(attrs, ', '))
end

---Formats a bunch of strings for each spell so that it's not necessary to do
---this each frame within imgui.
---@param spells table
---@return table
function utils.FlattenSpells(spells)
    local spellDetails = { }
    for i, spell in ipairs(spells) do
        spellDetails[i] = {
            Cost = string.format('[%i]', spell.Cost),
            Name = spell.Name,
            Desc = spell.Desc,
            Notes = spell.Notes,
            Stats = StringifyStats(spell.Stats),
            Traits = StringifyTrait(spell.Trait, spell.TraitPoints),
            Damage = StringifyDamage(spell.DamageType, spell.Element),
            Ecosystem = StringifyEcosystem(spell.MonsterType, spell.MonsterFamily),
            Casting = StringifyCasting(spell.MpCost, spell.CastTime, spell.RecastTime),
            Targeting = StringifyTargeting(spell.Target, spell.Range, spell.Area),
            Resonance = StringifyResonances(spell.Resonances),
            Attributes = StringifyAttributes(spell.Attributes),
        }
    end

    return spellDetails
end

return utils
