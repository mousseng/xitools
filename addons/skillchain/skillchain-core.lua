local BloodPacts = require('data.bloodpacts')
local ChainType = require('data.chaintype')
local Elements = require('data.elements')
local MagicBursts = require('data.magicbursts')
local NonChainingSkills = require('data.nonchainingskills')
local Resonances = require('data.resonances')
local Weaponskills = require('data.weaponskills')

local core = { }

-- Fetch an entity by its server ID. Helpful when looking up information from
-- packets, which tend to not include the entity index (since that's a client
-- thing only). Returns nil if no matching entity is found.
local function getEntityByServerId(id)
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

-- Determines if a particular entity (given as a server ID) belongs to the
-- player's alliance.
local function isServerIdInParty(id)
    local party = AshitaCore:GetMemoryManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberIsActive(i) == 1
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
local function isPetServerIdInParty(id)
    local party = AshitaCore:GetMemoryManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberIsActive(i) == 1
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

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- weaponskills.
function core.HandleWeaponskill(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not isServerIdInParty(packet.actor_id) then
        return
    end

    local resources = AshitaCore:GetResourceManager()

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = getEntityByServerId(target.id).Name,
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
function core.HandlePetAbility(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not isPetServerIdInParty(packet.actor_id)
    or BloodPacts[packet.param] == nil then
        return
    end

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = getEntityByServerId(packet.actor_id).Name,
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

            table.insert(mob.chain, chain_element)
        end

        -- Replace the existing mob information or add the new one
        mobs[target.id] = mob
    end
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- magic abilities; only handles magic bursts currently, not BLU chains.
function core.HandleMagicAbility(packet, mobs)
    -- Don't care about skillchains we can't participate in
    if not isServerIdInParty(packet.actor_id)
    or MagicBursts[packet.param] == nil then
        return
    end

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- Set up our display data
        local mob = mobs[target.id] or {
            name = getEntityByServerId(target.id).Name,
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

                table.insert(mob.chain, chain_element)
            end
        end

        -- Replace the existing mob information or add the new one
        mobs[target.id] = mob
    end
end

-- Draws a single skillchain.
local function drawMob(mob)
    local lines = { }

    -- Create the heading for our skillchain.
    table.insert(lines, mob.name)

    -- Fill out the body of our skillchain.
    for _, chain in pairs(mob.chain) do
        -- Is this the first step of a chain? If so, don't show burstable
        -- elements (since you can't burst).
        if chain.type == ChainType.Starter then
            local t1 = string.format('  > %s [%i dmg]', chain.name, chain.base_damage)
            local t2 = string.format('    %s', chain.resonance)

            table.insert(lines, t1)
            table.insert(lines, t2)
        -- Otherwise, also display the bonus damage and burstable elements.
        elseif chain.type == ChainType.Skillchain then
            local t1 = string.format('  > %s [%i + %i dmg]', chain.name, chain.base_damage, chain.bonus_damage or 0)
            local t2 = string.format('    %s (%s)', chain.resonance, Elements[chain.resonance])

            table.insert(lines, t1)
            table.insert(lines, t2)
        -- Display any magic bursts that occurred and their damage.
        elseif chain.type == ChainType.MagicBurst then
            local t = string.format('    Magic Burst! %s [%i dmg]', chain.name, chain.base_damage)

            table.insert(lines, t)
        elseif chain.type == ChainType.Miss then
            local t = string.format('  ! %s missed.', chain.name)

            table.insert(lines, t)
        else
            -- chain.type == ChainType.Unknown
        end
    end

    -- Create the footer for our skillchain, noting the remaining window and
    -- including a spacer between the mobs.
    if mob.time ~= nil then
        local time_remaining = 8 - math.abs(mob.time - os.time())
        if time_remaining >= 0 then
            table.insert(lines, string.format('  > %is', time_remaining))
        else
            table.insert(lines, '  x')
        end
    end

    table.insert(lines, '')
    return table.concat(lines, '\n')
end

-- Draws the whole list of active skillchains the user is aware of.
function core.Draw(mobs)
    local lines = { }

    for _, mob in pairs(mobs) do
        if #mob.chain > 0 then
            table.insert(lines, drawMob(mob))
        end
    end

    -- Just clear out the last newline.
    lines[#lines] = nil
    return table.concat(lines, '\n')
end

-- Checks each skillchain we know about for expiry and deletes when appropriate.
local function RunGarbageCollector(chains)
    for i, mob in pairs(chains) do
        if mob.time ~= nil then
            local timeSince = os.time() - mob.time
            if timeSince > 15 then
                chains[i] = nil
            end
        end
    end
end

-- Loops infinitely in the background, cleaning up "expired" skillchains.
function core.BeginGarbageCollection(chains)
    return ashita.tasks.once(0, function()
        while (true) do
            RunGarbageCollector(chains)
            coroutine.sleep(1)
        end
    end)
end

return core
