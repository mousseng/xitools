--[[ business logic ]]--
local current_skillchain = {}

-- State machine to process resonance transitions. Usage:
--     StateMachine[cur_resonance][ws_attr] == new_resonance
local StateMachine = {
    -- level 1 chains
    Liquefaction = {
        Scission = 'Scission',
        Impaction = 'Fusion'
    },
    Impaction = {
        Liquefaction = 'Liquefaction',
        Detonation = 'Detonation'
    },
    Detonation = {
        Scission = 'Scission',
        Compression = 'Gravitation'
    },
    Scission = {
        Liquefaction = 'Liquefaction',
        Detonation = 'Detonation',
        Reverberation = 'Reverberation'
    },
    Reverberation = {
        Impaction = 'Impaction',
        Induration = 'Induration'
    },
    Induration = {
        Impaction = 'Impaction',
        Compression = 'Compression',
        Reverberation = 'Fragmentation'
    },
    Compression = {
        Detonation = 'Detonation',
        Transfixion = 'Transfixion'
    },
    Transfixion = {
        Reverberation = 'Reverberation',
        Compression = 'Compression',
        Scission = 'Distortion'
    },
    -- level 2 chains
    Fusion = {
        Gravitation = 'Gravitation',
        Fragmentation = 'Light'
    },
    Fragmentation = {
        Distortion = 'Distortion',
        Fusion = 'Light'
    },
    Gravitation = {
        Fragmentation = 'Fragmentation',
        Distortion = 'Darkness'
    },
    Distortion = {
        Fusion = 'Fusion',
        Gravitation = 'Darkness'
    },
    -- level 3 chains
    Light = {
        Light = 'Light II'
    },
    Darkness = {
        Darkness = 'Darkness II'
    }
}

local ActionType = {
    [0] = 'None',
    [1] = 'Attack',
    [2] = 'Ranged Finish',
    [3] = 'Weaponskill Finish',
    [4] = 'Magic Finish',
    [5] = 'Item Finish',
    [6] = 'Job Ability Finish',
    [7] = 'Weaponskill Start',
    [8] = 'Magic Start',
    [9] = 'Item Start',
    [10] = 'Job Ability Start',
    [11] = 'Mob Ability Finish',
    [12] = 'Ranged Start',
    [13] = 'Pet Mob Ability Finish',
    [14] = 'Dance',
    [15] = 'Quarry',
    [16] = 'Sprint',
    [29] = 'Item Interrupt',
    [31] = 'Magic Interrupt',
    [32] = 'Ranged Interrupt',
    [33] = 'Mob Ability Start',
    [35] = 'Mob Ability Interrupt',
    [37] = 'Raise Menu Selection'
}

local SkillchainAttribute = {
    Liquefaction = 0,
    Impaction = 0,
    Detonation = 0,
    Scission = 0,
    Reverberation = 0,
    Induration = 0,
    Compression = 0,
    Transfixion = 0,
    Fusion = 0,
    Fragmentation = 0,
    Gravitation = 0,
    Distortion = 0,
    Light = 0,
    Darkness = 0
}

-- Given a current resonance and a priority-order list of possible resonances,
-- determine what the subsequent resonance in the skillchain will be. Returns
-- nil if the skillchain will be broken.
function next_resonance(current, nexts)
    -- are we starting a skillchain?
    if (current == nil) then
        return next
    else
        -- find the highest-priority skillchain
        for idx, res in pairs(nexts) do
            if StateMachine[current][res] ~= nil then
                return StateMachine[current][res]
            end
        end

        -- can't make a chain with this weaponskill
        return nil
    end
end

--[[ event handlers ]]--
function load()
end

function unload()
end