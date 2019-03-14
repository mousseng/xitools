require 'common'
require 'utils'

local Weaponskills = require 'weaponskills'
local BloodPacts   = require 'bloodpacts'
local MagicBursts  = require 'magicbursts'

-- Determines if a particular entity (given as a server ID) belongs to the
-- player's alliance.
local function is_server_id_in_party(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.ServerId == id then
                return true
            end
        end
    end

    return false
end

-- Determines if a particular pet (given as a server ID) belongs to the
-- player's alliance.
local function is_pet_server_id_in_party(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.PetTargetIndex ~= nil then
                local party_pet = GetEntity(party_mem.PetTargetIndex)

                if party_pet ~= nil and party_pet.ServerId == id then
                    return true
                end
            end
        end
    end

    return false
end

-- Does what it says on the tin: creates or resets the timer for a particular
-- skillchain. When the timer expires, the skillchain is removed from memory.
local function create_or_reset_timer(id, mobs)
    ashita.timer.remove_timer(id)
    ashita.timer.create(id, 16, 1, function() mobs[id] = nil end)
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- weaponskills.
function handle_weaponskill(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not is_server_id_in_party(packet.actor_id) then
        return
    end

    local resources = AshitaCore:GetResourceManager()

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = GetEntityByServerId(target.id).Name,
            time = nil,
            chain = { },
        }

        for j = 1, target.action_count do
            local action = target.actions[j]
            local chain_element = nil

            -- Skip weaponskills that we'll never bother with or actions that
            -- have no reaction (like Steal)
            if not NonChainingSkills[action.animation]
            and action.reaction ~= 0 then
                -- Prep chain step display data
                chain_element = {
                    id = action.animation,
                    type = nil,
                    name = resources:GetAbilityById(packet.param).Name[0],
                    base_damage = action.param,
                    bonus_damage = action.add_effect_param,
                    resonance = nil,
                }

                -- Specialize our chain step
                if action.reaction == 0x08 and not action.has_add_effect then
                    chain_element.type = ChainType.Starter
                    chain_element.resonance = table.concat(Weaponskills[packet.param].attr, ', ')

                    mob.time = os.time()
                    mob.chain = { }
                elseif action.reaction == 0x08 and action.has_add_effect then
                    chain_element.type = ChainType.Skillchain
                    chain_element.resonance = Resonances[action.add_effect_message]

                    mob.time = os.time()
                elseif action.reaction == 0x01 or action.reaction == 0x09 then
                    chain_element.type = ChainType.Miss
                else
                    chain_element.type = ChainType.Unknown
                end

                -- Drop the information after the window is definitely
                -- closed and there's been no activity
                create_or_reset_timer(target.id, mobs)
                table.insert(mob.chain, chain_element)
            end
        end

        -- Replace the existing mob information or add the new one
        mobs[target.id] = mob
    end
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on pet
-- abilities.
function handle_petability(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not is_pet_server_id_in_party(packet.actor_id)
    or BloodPacts[packet.param] == nil then
        return
    end

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = GetEntityByServerId(packet.actor_id).Name,
            time = nil,
            chain = { },
        }

        for j = 1, target.action_count do
            local action = target.actions[j]
            local chain_element = {
                id = action.animation,
                type = nil,
                name = BloodPacts[packet.param].name,
                base_damage = action.param,
                bonus_damage = action.add_effect_param,
                resonance = nil,
            }

            -- Specialize our chain step
            if action.reaction == 0x08 and not action.has_add_effect then
                chain_element.type = ChainType.Starter
                chain_element.resonance = table.concat(BloodPacts[packet.param].attr, ', ')

                mob.time = os.time()
                mob.chain = { }
            elseif action.reaction == 0x08 and action.has_add_effect then
                chain_element.type = ChainType.Skillchain
                chain_element.resonance = Resonances[action.add_effect_message]

                mob.time = os.time()
            elseif action.reaction == 0x01 or action.reaction == 0x09 then
                chain_element.type = ChainType.Miss
            else
                chain_element.type = ChainType.Unknown
            end

            -- Don't expect to need this, but it's nice to be clear
            if chain_element.type == nil then
                chain_element.type = ChainType.Unknown
            end

            -- Drop the information after the window is definitely
            -- closed and there's been no activity
            create_or_reset_timer(target.id, mobs)
            table.insert(mob.chain, chain_element)
        end

        -- Replace the existing mob information or add the new one
        mobs[target.id] = mob
    end
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- magic abilities; only handles magic bursts currently, not BLU chains.
function handle_magicability(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not is_server_id_in_party(packet.actor_id)
    or MagicBursts[packet.param] == nil then
        return
    end

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = GetEntityByServerId(target.id).Name,
            time = nil,
            chain = { },
        }

        for j = 1, target.action_count do
            local action = target.actions[j]
            local chain_element = nil

            if action.message == MagicBursts[packet.param].burst_msg then
                chain_element = {
                    id = packet.param,
                    type = ChainType.MagicBurst,
                    name = AshitaCore:GetResourceManager():GetSpellById(packet.param).Name[0],
                    base_damage = action.param,
                    bonus_damage = nil,
                    resonance = nil,
                }

                -- Drop the information after the window is definitely
                -- closed and there's been no activity
                create_or_reset_timer(target.id, mobs)
                table.insert(mob.chain, chain_element)
            end
        end

        -- Replace the existing mob information or add the new one
        mobs[target.id] = mob
    end
end
