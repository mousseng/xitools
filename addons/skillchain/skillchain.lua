addon.name    = 'skillchain'
addon.author  = 'lin'
addon.version = '4.0'
addon.desc    = 'A little skillchain tracker so you know when things happen'

require('common')
local settings = require('settings')
local ffxi = require('lin/ffxi')
local imgui = require('lin/imgui')
local packets = require('lin/packets')

local Elements = require('data/elements')
local ChainType = require('data/chaintype')
local Resonances = require('data/resonances')
local MagicBursts = require('data/magicbursts')
local Weaponskills = require('data/weaponskills')
local MobSkills = require('data/mobskills')
local WeaponskillMsgs = T{ 185, 188, 264, }

---@class SkillchainSettings
---@field dataSet 'retail'|'horizon'
---@field windowName string
---@field windowSize Vec2
---@field windowPos Vec2

---@class Skillchain
---@field name string
---@field time number
---@field chain SkillchainStep[]

---@class SkillchainStep
---@field id number
---@field time number
---@field type ChainType
---@field name string
---@field base_damage number
---@field bonus_damage number?
---@field resonance Resonance?

---@type SkillchainSettings
local defaultConfig = {
    dataSet = 'retail',
    windowName = 'Skillchain',
    windowSize = { -1, -1 },
    windowPos = { 100, 100 },
}

---@type SkillchainSettings
local config = settings.load(defaultConfig)

---@type Skillchain[]
local chains = { }

---@type integer
local lastPulse = os.time()

local function when(cond, t, f)
    if cond then
        return t
    else
        return f
    end
end

-- Fetch an entity by its server ID. Helpful when looking up information from
-- packets, which tend to not include the entity index (since that's a client
-- thing only). Returns nil if no matching entity is found.
---@param id number
---@return table?
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
---@param id number
---@return boolean
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
---@param id number
---@return boolean
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

local function handleChainStep(packet, mobs, actionName, attrInfo)
    if packet.target_count < 1 then
        return
    end

    local target = packet.targets[1]

    -- Set up our display data
    ---@type Skillchain
    local mob = mobs[target.id] or {
        name = getEntityByServerId(target.id).Name,
        time = nil,
        chain = { },
    }

    for j = 1, target.action_count do
        local action = target.actions[j]

        -- skip non-chaining stuff like jumps, bashes, and steals
        -- if T{ 110, 129, 244, 317, 327, }:contains(action.message) then
        if not WeaponskillMsgs:contains(action.message) then
            return
        end

        -- Prep chain step display data
        ---@type SkillchainStep
        local chain_step = {
            id = action.sub_kind,
            time = os.time(),
            type = ChainType.Unknown,
            name = actionName,
            base_damage = action.param,
            bonus_damage = action.proc_param,
            resonance = nil,
        }

        -- Specialize our chain step
        if action.miss == 1 then
            chain_step.type = ChainType.Miss
        elseif not action.has_proc then
            chain_step.type = ChainType.Starter
            chain_step.resonance = attrInfo

            mob.time = os.time()
            mob.chain = { }
        elseif action.has_proc then
            chain_step.type = ChainType.Skillchain
            chain_step.resonance = Resonances[action.proc_message]

            mob.time = os.time()
        else
            chain_step.type = ChainType.Unknown
        end

        table.insert(mob.chain, chain_step)
    end

    -- Replace the existing mob information or add the new one
    mobs[target.id] = mob
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- weaponskills.
---@param packet ActionPacket
---@param mobs Skillchain[]
local function HandleWeaponskill(packet, mobs)
    local weaponskillInfo = Weaponskills[config.dataSet][packet.param]

    -- Don't care about skillchains we can't participate in
    if not isServerIdInParty(packet.actor_id) or weaponskillInfo == nil or weaponskillInfo.attr == nil then
        return
    end

    local resources = AshitaCore:GetResourceManager()
    local actionName = resources:GetAbilityById(packet.param).Name[1]

    handleChainStep(packet, mobs, actionName, table.concat(weaponskillInfo.attr, ', '))
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on pet
-- abilities.
---@param packet ActionPacket
---@param mobs Skillchain[]
local function HandlePetAbility(packet, mobs)
    local petAbilInfo = MobSkills[config.dataSet][packet.param]

    -- Don't care about skillchains we can't participate in
    if not isPetServerIdInParty(packet.actor_id) or petAbilInfo == nil or petAbilInfo.attr == nil then
        return
    end

    local resources = AshitaCore:GetResourceManager()
    local actionName = resources:GetString('monsters.abilities', packet.param - 256):trimend('\0')

    handleChainStep(packet, mobs, actionName, table.concat(petAbilInfo.attr, ', '))
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- mob skills.
---@param packet ActionPacket
---@param mobs Skillchain[]
local function HandleMobSkill(packet, mobs)
    local mobSkillInfo = MobSkills[config.dataSet][packet.param]

    -- Don't care about skillchains we can't participate in
    if not isServerIdInParty(packet.actor_id) or mobSkillInfo == nil or mobSkillInfo.attr == nil then
        return
    end

    local resources = AshitaCore:GetResourceManager()
    local actionName = resources:GetString('monsters.abilities', packet.param - 256):trimend('\0')

    handleChainStep(packet, mobs, actionName, table.concat(mobSkillInfo.attr, ', '))
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- magic abilities; only handles magic bursts currently, not BLU chains.
---@param packet ActionPacket
---@param mobs Skillchain[]
local function HandleMagicAbility(packet, mobs)
    local burstInfo = MagicBursts[config.dataSet][packet.param]

    -- Don't care about skillchains we can't participate in
    if not isServerIdInParty(packet.actor_id) or burstInfo == nil then
        return
    end

    -- Iterate down to the meat of our data
    for i = 1, packet.target_count do
        local target = packet.targets[i]

        -- MB targets must have a skillchain already
        local mob = mobs[target.id]
        if not mob then
            return
        end

        for j = 1, target.action_count do
            local action = target.actions[j]

            ---@type SkillchainStep
            local chain_step = nil

            if action.message == burstInfo.burst_msg then
                chain_step = {
                    id = packet.param,
                    time = os.time(),
                    type = ChainType.MagicBurst,
                    name = AshitaCore:GetResourceManager():GetSpellById(packet.param).Name[1],
                    base_damage = when(burstInfo.no_dmg, nil, action.param),
                    bonus_damage = nil,
                    resonance = nil,
                }

                table.insert(mob.chain, chain_step)
            end
        end
    end
end

-- Draws a single skillchain.
---@param mob Skillchain
local function DrawMob(mob)
    -- Create the heading for our skillchain.
    imgui.Text(mob.name)
    -- Fill out the body of our skillchain.
    for _, chain in pairs(mob.chain) do
        -- Is this the first step of a chain? If so, don't show burstable
        -- elements (since you can't burst).
        if chain.type == ChainType.Starter then
            imgui.BulletText(string.format('%s [%i dmg]\n%s', chain.name, chain.base_damage, chain.resonance))
        -- Otherwise, also display the bonus damage and burstable elements.
        elseif chain.type == ChainType.Skillchain then
            imgui.BulletText(string.format('%s [%i + %i dmg]\n%s (%s)', chain.name, chain.base_damage, chain.bonus_damage or 0, chain.resonance, Elements[chain.resonance]))
        -- Display any magic bursts that occurred and their damage.
        elseif chain.type == ChainType.MagicBurst then
            if chain.base_damage ~= nil then
                imgui.BulletText(string.format('Magic Burst! %s [%i dmg]', chain.name, chain.base_damage))
            else
                imgui.BulletText(string.format('Magic Burst! %s', chain.name))
            end
        elseif chain.type == ChainType.Miss then
            imgui.BulletText(string.format('%s missed.', chain.name))
        else
            -- chain.type == ChainType.Unknown
        end
    end

    -- Create the footer for our skillchain, noting the remaining window and
    -- including a spacer between the mobs.
    if mob.time ~= nil then
        local time_remaining = 10 - math.abs(mob.time - os.time())
        if time_remaining >= 0 then
            -- you must wait 3 seconds before weaponskilling, but the remaining
            -- 7 seconds are free game for burst and skilling
            if time_remaining <= 7 then
                imgui.BulletText(string.format('%is - go!', time_remaining))
            else
                imgui.BulletText(string.format('%is - wait...', time_remaining))
            end
        else
            imgui.BulletText('closed.')
        end
    end
end

-- Draws the whole list of active skillchains the user is aware of.
---@param mobs Skillchain[]
local function DrawSkillchain(mobs)
    local i = 1
    for _, mob in pairs(mobs) do
        if #mob.chain > 0 then
            if i > 1 then
                imgui.Text('')
            end
            DrawMob(mob)
            i = i + 1
        end
    end
end

-- Checks each skillchain we know about for expiry and deletes when appropriate.
---@param chains Skillchain[]
local function RunGarbageCollector(chains)
    for i, mob in pairs(chains) do
        if mob.time == nil and #mob.chain > 0 and mob.chain[#mob.chain].type == ChainType.Miss then
            -- this means our starter missed
            local timeSince = os.time() - mob.chain[#mob.chain].time
            if timeSince > 12 then
                chains[i] = nil
            end
        elseif mob.time ~= nil then
            local timeSince = os.time() - mob.time
            if timeSince > 16 then
                chains[i] = nil
            end
        end
    end
end

---@param s SkillchainSettings?
local function UpdateSettings(s)
    if s ~= nil then
        config = s
    end

    settings.save()
end

local function OnLoad()
end

local function OnUnload()
    UpdateSettings()
end

---@param e CommandEventArgs
local function OnCommand(e)
    local args = e.command:args()

    if #args < 2 or args[1] ~= '/schain' then
        return
    end

    if args[2] == 'retail' then
        config.dataSet = 'retail'
    elseif args[2] == 'horizon' then
        config.dataSet = 'horizon'
    elseif args[2] == 'test' then
        ---@type Skillchain
        local testMob = {
            chain = { },
            name = 'Test Mob',
            time = os.time(),
        }

        ---@type SkillchainStep
        local testStep = {
            id = 42,
            name = 'Test Weaponskill',
            resonance = Resonances[299],
            base_damage = 69,
            time = os.time(),
            type = ChainType.Starter,
        }

        table.insert(testMob.chain, testStep)
        table.insert(chains, testMob)
    end

    e.blocked = true
end

---@param e PacketInEventArgs
local function OnPacket(e)
    if e.id == 0x28 then
        ---@type ActionPacket
        local action = packets.inbound.action.parse(e.data_modified_raw)

        if action.category == 3 then
            -- For some reason, some trusts (like Valaineral) send their mobskills
            -- as weaponskill packets instead. It's possible there's something in
            -- the sub_kind, scale, or message that could be used to distinguish
            if action.param > 256 then
                HandleMobSkill(action, chains)
            else
                HandleWeaponskill(action, chains)
            end
        elseif action.category == 4 then
            HandleMagicAbility(action, chains)
        elseif action.category == 11 then
            HandleMobSkill(action, chains)
        elseif action.category == 13 then
            HandlePetAbility(action, chains)
        end
    end
end

local function OnPresent()
    local activeCount = 0
    for _, mob in pairs(chains) do
        if #mob.chain > 0 then
            activeCount = activeCount + 1
        end
    end

    if activeCount > 0 and not ffxi.IsChatExpanded() then
        imgui.Lin.DrawWindow(config.windowName, config.windowSize, config.windowPos, function()
            DrawSkillchain(chains)
        end)
    end

    local now = os.time()
    if now - lastPulse > 1 then
        lastPulse = now
        RunGarbageCollector(chains)
    end
end

settings.register('settings', 'settings_update', UpdateSettings)
ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('unload', 'on_unload', OnUnload)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
ashita.events.register('packet_in', 'on_packet_in', OnPacket)
