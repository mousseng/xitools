require('common')
local utils = require('utils')
local traits = require('data/traits')
local spells = require('data/spells')
local spellDetails = utils.FlattenSpells(spells)
local currentSet = { }

local state = {
    SpellList = { },
    SelectedSpell = nil,
    SelectedDetails = nil,
    SelectedActive = nil,
    SummaryStats = { },
    SummaryTraits = { },
}

local function SumStats(statSum)
    local finalStats = { }

    for stat, bonus in pairs(statSum) do
        local template = '%s +%i'
        if bonus < 0 then
            template = '%s %i'
        end

        if bonus ~= 0 then
            table.insert(finalStats, string.format(template, string.upper(stat), bonus))
        end
    end

    return finalStats
end

local function SumTraits(traitSum)
    local finalTraits = { }

    for trait, points in pairs(traitSum) do
        -- TODO: handle job bonuses
        local level = math.min(math.floor(points / 8), #traits[trait])
        if level > 0 then
            table.insert(finalTraits, traits[trait][level])
        end
    end

    return finalTraits
end

---Builds summary tables for the stats and traits of the working set.
function state:Summarize()
    local statSum = { }
    local traitSum = { }

    for _, spellId in ipairs(currentSet) do
        local _, spell = table.find_if(spells, function(val) return val.Id == spellId end)

        for stat, bonus in pairs(spell.Stats) do
            statSum[stat] = (statSum[stat] or 0) + bonus
        end

        if spell.Trait then
            traitSum[spell.Trait] = (traitSum[spell.Trait] or 0) + spell.TraitPoints
        end
    end

    self.SummaryStats = SumStats(statSum)
    self.SummaryTraits = SumTraits(traitSum)
end

---Filters the spell list based on whether it should contain only those included
---in the current set, or all of them.
---@param includeAll boolean
function state:FilterSpells(includeAll)
    local predicate = function(val)
        return includeAll or table.contains(currentSet, val.Id)
    end

    local map = function(val)
        local setIdx = table.find(currentSet, val.Id)
        local setIndicator = tostring(setIdx or '')
        local display = string.format('%2s [%i] %s', setIndicator, val.Cost, val.Name)

        return { Id = val.Id, Display = display }
    end

    self.SpellList = table.imap(table.filteri(spells, predicate), map)
end

---Selects a spell to be the general action context.
---@param spellId number
function state:SelectSpell(spellId)
    self.SelectedSpell = spellId
    self.SelectedActive = table.contains(currentSet, spellId)

    local spellIndex = table.find_if(spells, function(val)
        return val.Id == spellId
    end)

    self.SelectedDetails = spellDetails[spellIndex]
end

---Adds a spell to the working set.
---@param spellId number
function state:SetSpell(spellId)
    local i = table.find(currentSet, spellId)

    if not i then
        table.insert(currentSet, spellId)
    end

    self:Summarize()
end

---Removes a spell from the working set.
---@param spellId number
function state:UnsetSpell(spellId)
    local i = table.find(currentSet, spellId)

    if i then
        table.remove(currentSet, i)
    end

    self:Summarize()
end

return state
