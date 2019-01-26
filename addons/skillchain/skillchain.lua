-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'skillchain'
_addon.version = '0.4.0'

require 'utils'
require 'packet'
require 'common'

local Weaponskills = require 'weaponskills'
local BloodPacts   = require 'bloodpacts'
local MagicBursts  = require 'magicbursts'

local config = {
    font = {
        family    = 'Consolas',
        size      = 10,
        color     = 0xFFFFFFFF,
        position  = { 50, 125 },
        bgcolor   = 0x80000000,
        bgvisible = true
    }
}

-------------------------------------------------------------------------------
-- live data
-------------------------------------------------------------------------------

local Enemies = {}

-------------------------------------------------------------------------------
-- utility data
-------------------------------------------------------------------------------

-- A set-style table of weaponskills that do not interact with skillchains. It
-- is keyed by the animation ID.
local NonChainingSkills = {
    [8] = true,
    [36] = true,
    [37] = true,
    [79] = true,
    [80] = true,
    [87] = true,
    [89] = true,
    [143] = true,
    [149] = true,
    [150] = true,
    [230] = true,
    -- HACK: dragoon jump abilities. For some reason these are counted as
    -- weaponskills rather than abilities, in spite of appearing in darkstar's
    -- ability table.
    [204] = true,
    [209] = true,
    [214] = true,
}

-- A lookup table to find the appropriate name for a given skillchain effect.
-- The keys are an action's add_effect_message.
local Resonances = {
    [0x120] = 'Light',
    [0x121] = 'Darkness',
    [0x122] = 'Gravitation',
    [0x123] = 'Fragmentation',
    [0x124] = 'Distortion',
    [0x125] = 'Fusion',
    [0x126] = 'Compression',
    [0x127] = 'Liquefacation',
    [0x128] = 'Induration',
    [0x129] = 'Reverberation',
    [0x12A] = 'Transfixion',
    [0x12B] = 'Scission',
    [0x12C] = 'Detonation',
    [0x12D] = 'Impaction',
    [0x12E] = 'Radiance',
    [0x12F] = 'Umbra'
}

-- A lookup table to find the appropriate list of burstable magic elements for
-- a given skillchain effect.
local Elements = {
    Light         = 'Wind, Thunder, Fire, Light',
    Darkness      = 'Ice, Water, Earth, Dark',
    Gravitation   = 'Earth, Dark',
    Fragmentation = 'Thunder, Wind',
    Distortion    = 'Ice, Water',
    Fusion        = 'Fire, Light',
    Compression   = 'Dark',
    Liquefacation = 'Fire',
    Induration    = 'Ice',
    Reverberation = 'Water',
    Transfixion   = 'Light',
    Scission      = 'Earth',
    Detonation    = 'Wind',
    Impaction     = 'Thunder',
    Radiance      = 'Wind, Thunder, Fire, Light',
    Umbra         = 'Ice, Water, Earth, Dark'
}

local ChainType = {
    SC = 1,
    MB = 2,
}

-------------------------------------------------------------------------------
-- helper functions
-------------------------------------------------------------------------------

-- Heuristic to determine whether to even bother trying to handle a mob action.
-- Since we only have (partial, buggy) SMN support at the moment, only check
-- for the presence of a SMN in the party.
local function party_has_pet_job()
    local party = AshitaCore:GetDataManager():GetParty()

    return party:GetMemberMainJob(0) == 15 or party:GetMemberSubJob(0) == 15
        or party:GetMemberMainJob(1) == 15 or party:GetMemberSubJob(1) == 15
        or party:GetMemberMainJob(2) == 15 or party:GetMemberSubJob(2) == 15
        or party:GetMemberMainJob(3) == 15 or party:GetMemberSubJob(3) == 15
        or party:GetMemberMainJob(4) == 15 or party:GetMemberSubJob(4) == 15
        or party:GetMemberMainJob(5) == 15 or party:GetMemberSubJob(5) == 15
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on
-- weaponskills.
local function handle_weaponskill(action)
    if IsServerIdInParty(action.actor_id) then

        -- Gotta traverse our way to the meat of the action data; there can be
        -- multiple targets per weaponskill, so don't choke and die if there
        -- are. Additionally, while the top-level param field contains the skill
        -- ID, this doesn't hold for all category 3 packets (such as DRG jumps).
        for i = 1, action.target_count do
            local target = action.targets[i]

            -- pretty sure there should only ever be one action per target for
            -- weaponskills, but if not this could be the source of a bug
            for j = 1, target.action_count do
                local weaponskill = target.actions[j]

                -- only track if the ability didn't miss and can chain
                if weaponskill.reaction == 0x08
                and not NonChainingSkills[weaponskill.animation] then
                    -- reset target info if starting a new chain,
                    -- or if the last one was broken/finished
                    if Enemies[target.id] == nil
                    or not weaponskill.has_add_effect then
                        Enemies[target.id] = {
                            name = GetEntityByServerId(target.id).Name,
                            time = nil,
                            chain = {}
                        }
                    end

                    -- drop the information after the window is definitely
                    -- closed and there's been no activity
                    ashita.timer.remove_timer(target.id)
                    ashita.timer.create(
                        target.id,
                        10,
                        1,
                        function(tgt) Enemies[target.id] = nil end,
                        target.id
                    )

                    local chain_element = {
                        id = weaponskill.animation,
                        type = ChainType.SC,
                        name = Weaponskills[weaponskill.animation].name,
                        base_damage = weaponskill.param,
                        bonus_damage = weaponskill.add_effect_param,
                        resonance = Resonances[weaponskill.add_effect_message],
                    }

                    -- list out all the attrs for first weaponskill. unsure if
                    -- you can actually chain off of non-primary attributes, so
                    -- just do it anyway
                    if #Enemies[target.id].chain == 0 then
                        chain_element.resonance =
                            table.concat(Weaponskills[weaponskill.animation].attr, ', ')
                    end

                    Enemies[target.id].time = os.time()
                    table.insert(Enemies[target.id].chain, chain_element)
                end
            end
        end
    end
end

-- Collects and collates data about a particular action in order for the render
-- function to display information about active skillchains. Specialized on pet
-- abilities.
local function handle_petability(action)
    local party = AshitaCore:GetDataManager():GetParty()

    -- first we need to find out which pets are in our party
    local pets = {}

    for x = 1, 5 do
        if party:GetMemberActive(x) == 1 and party:GetMemberServerId(x) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(x))

            if party_mem ~= nil then
                local party_pet = GetEntity(party_mem.PetTargetIndex)

                if party_pet ~= nil then
                    pets[party_pet.ServerId] = true
                end
            end
        end
    end

    -- only bother deciphering it if it's a party member's pet
    if pets[action.actor_id] then
        local pet = GetEntityByServerId(action.actor_id)

        -- check if it's a chainable skill by a supported pet
        if BloodPacts[pet.Name] ~= nil
        and BloodPacts[pet.Name][action.param] ~= nil then

            for i = 1, action.target_count do
                local target = action.targets[i]

                for j = 1, target.action_count do
                    local ability =  target.actions[j]

                    -- check if it was a hit
                    if ability.reaction == 0x08 then
                        -- reset target info if starting a new chain,
                        -- or if the last one was broken/finished
                        if Enemies[target.id] == nil
                        or not ability.has_add_effect then
                            Enemies[target.id] = {
                                name = GetEntityByServerId(target.id).Name,
                                time = nil,
                                chain = {}
                            }
                        end

                        -- drop the information after the window is definitely
                        -- closed and there's been no activity
                        ashita.timer.remove_timer(target.id)
                        ashita.timer.create(
                            target.id,
                            10,
                            1,
                            function(tgt) Enemies[target.id] = nil end,
                            target.id
                        )

                        local chain_element = {
                            id = ability.animation,
                            type = ChainType.SC,
                            name = BloodPacts[pet.Name][action.param].name,
                            base_damage = ability.param,
                            bonus_damage = ability.add_effect_param,
                            resonance = Resonances[ability.add_effect_message],
                        }

                        -- list out all the attrs for first weaponskill. unsure if
                        -- you can actually chain off of non-primary attributes, so
                        -- just do it anyway
                        if #Enemies[target.id].chain == 0 then
                            chain_element.resonance =
                                table.concat(BloodPacts[pet.Name][action.param].attr, ', ')
                        end

                        Enemies[target.id].time = os.time()
                        table.insert(Enemies[target.id].chain, chain_element)
                    end
                end
            end
        end
    end
end

local function handle_magicability(action)
    -- TODO: handle BLU skillchains

    if IsServerIdInParty(action.actor_id) and MagicBursts[action.param] ~= nil then
        for i = 1, action.target_count do
            local target = action.targets[i]

            for j = 1, target.action_count do
                local spell = target.actions[j]

                if spell.message == MagicBursts[action.param].burst_msg then
                    local chain_element = {
                        id = action.param,
                        type = ChainType.MB,
                        name = AshitaCore:GetResourceManager():GetSpellById(action.param).Name[0],
                        base_damage = ability.param,
                        bonus_damage = nil,
                        resonance = nil,
                    }

                    table.insert(Enemies[target.id].chain, chain_element)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- event handlers
-------------------------------------------------------------------------------

function load()
    config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', config)

    -- initialize rendering data
    local font = AshitaCore:GetFontManager():Create('__skillchain_addon')
    font:SetColor(config.font.color)
    font:SetFontFamily(config.font.family)
    font:SetFontHeight(config.font.size)
    font:SetBold(false)
    font:SetPositionX(config.font.position[1])
    font:SetPositionY(config.font.position[2])
    font:SetText('Skillchain ~ by lin')
    font:SetVisibility(true)
    font:GetBackground():SetColor(config.font.bgcolor)
    font:GetBackground():SetVisibility(config.font.bgvisible)
end

function unload()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    config.font.position = { font:GetPositionX(), font:GetPositionY() }

    -- save config
    ashita.settings.save(_addon.path .. 'settings/settings.json', config)

    -- unload font object
    AshitaCore:GetFontManager():Delete('__skillchain_addon')
end

function render()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    local resx = AshitaCore:GetResourceManager()
    local e = T{}

    for idx, v in pairs(Enemies) do
        local line = v.name

        for x = 1, #v.chain do
            if v.chain[x].type == ChainType.SC then
                line = line
                    .. '\n  > '
                    .. v.chain[x].name
                    .. ' ['
                    .. v.chain[x].base_damage

                -- don't show bonus damage for first step in chain
                if v.chain[x].bonus_damage ~= nil then
                    line = line .. ' + ' .. v.chain[x].bonus_damage
                end

                line = line
                    .. ' dmg]'
                    .. '\n    '
                    .. v.chain[x].resonance

                -- don't show burstable elements for first step in chain
                if x > 1 then
                    line = line
                        .. ' ('
                        .. Elements[v.chain[x].resonance]
                        .. ')'
                end
            elseif v.chain[x].type == ChainType.MB then
                line = line
                    .. '\n    Magic Burst! '
                    .. v.chain[x].name
                    .. ' [' .. v.chain[x].base_damage .. ' dmg]'
            end
        end

        local time_remaining = 8 - math.abs(v.time - os.time())

        if time_remaining >= 0 then
            line = line .. '\n  > ' .. time_remaining .. 's'
        else
            line = line .. '\n  x'
        end

        table.insert(e, line)
    end

    font:SetText(e:concat('\n\n'))
end

function dispatch_packet(id, size, packet)
    if id == 0x0028 then
        local action = ashita.packet.parse_server(packet)

        if action.category == 3 then
            ashita.packet.log_server(id, action)
            handle_weaponskill(action)
        elseif action.category == 4 then
            ashita.packet.log_server(id, action)
            handle_magicability(action)
        elseif action.category == 13 and party_has_pet_job() then
            ashita.packet.log_server(id, action)
            handle_petability(action)
        end
    end

    return false
end

ashita.register_event('load', load)
ashita.register_event('unload', unload)
ashita.register_event('render', render)
ashita.register_event('incoming_packet', dispatch_packet)
