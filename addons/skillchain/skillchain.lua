--[[ config ]]

_addon.author  = 'lin'
_addon.name    = 'skillchain'
_addon.version = '0.3.0'

require 'common'
require 'timer'

local Packet       = require 'packet'
local Weaponskills = require 'weaponskills'

local DefaultConfig = {
    font = {
        family    = 'Consolas',
        size      = 10,
        color     = 0xFFFF0000,
        position  = { 50, 125 },
        bgcolor   = 0x80000000,
        bgvisible = true
    }
}

local SkillchainConfig = DefaultConfig

--[[ live data ]]

local Party   = {}
local Enemies = {}

--[[ utility data ]]

-- keyed by the weaponskill's animation_id
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
    [230] = true
}

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

--[[ helper functions ]]

-- given a PARTY_DEFINE packet, extract the members' server_ids, drop the empty
-- values, and update the live party data
local function update_party(packet)
    local member1 = struct.unpack('i', packet, 0x08 + 1)
    local member2 = struct.unpack('i', packet, 0x08 + 1 + 12)
    local member3 = struct.unpack('i', packet, 0x08 + 1 + 24)
    local member4 = struct.unpack('i', packet, 0x08 + 1 + 36)
    local member5 = struct.unpack('i', packet, 0x08 + 1 + 48)
    local member6 = struct.unpack('i', packet, 0x08 + 1 + 60)

    Party = {
        [member1] = true,
        [member2] = true,
        [member3] = true,
        [member4] = true,
        [member5] = true,
        [member6] = true
    }

    -- just to keep things tidy
    Party[0] = nil
end

-- find an entity by its server_id by traversing the entire entity array
local function get_entity(server_id)
    -- entity array is 2304 items long
    for x = 0, 2303 do
        -- get the entity
        local e = GetEntity(x)

        -- ensure the entity is valid
        if e ~= nil and e.WarpPointer ~= 0 then
            if e.ServerId == server_id then
                return e
            end
        end
    end

    return nil
end

-- little helper to avoid crowding conditionals
local function is_chain_finished(skillchain)
    local len = #skillchain

    -- double lv3 chain?
    if (skillchain[len] == 'Light' or skillchain[len] == 'Darkness')
    and skillchain[len] == skillchain[len - 1] then
        return true
    end
end

--[[ event handlers ]]

function load()
    SkillchainConfig = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', SkillchainConfig)

    -- initialize rendering data
    local font = AshitaCore:GetFontManager():Create('__skillchain_addon')
    font:SetColor(SkillchainConfig.font.color)
    font:SetFontFamily(SkillchainConfig.font.family)
    font:SetFontHeight(SkillchainConfig.font.size)
    font:SetBold(false)
    font:SetPositionX(SkillchainConfig.font.position[1])
    font:SetPositionY(SkillchainConfig.font.position[2])
    font:SetText('Skillchain ~ by lin')
    font:SetVisibility(true)
    font:GetBackground():SetColor(SkillchainConfig.font.bgcolor)
    font:GetBackground():SetVisibility(SkillchainConfig.font.bgvisible)

    -- initialize party data
    local party = AshitaCore:GetDataManager():GetParty()

    local member1 = party:GetMemberServerId(0)
    local member2 = party:GetMemberServerId(1)
    local member3 = party:GetMemberServerId(2)
    local member4 = party:GetMemberServerId(3)
    local member5 = party:GetMemberServerId(4)
    local member6 = party:GetMemberServerId(5)

    Party = {
        [member1] = true,
        [member2] = true,
        [member3] = true,
        [member4] = true,
        [member5] = true,
        [member6] = true
    }

    -- just to keep things tidy
    Party[0] = nil
end

function unload()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    SkillchainConfig.font.position = { font:GetPositionX(), font:GetPositionY() }

    -- save config
    ashita.settings.save(_addon.path .. 'settings/settings.json', SkillchainConfig)

    -- unload font object
    AshitaCore:GetFontManager():Delete('__skillchain_addon')
end

function render()
    local font = AshitaCore:GetFontManager():Get('__skillchain_addon')
    local resx = AshitaCore:GetResourceManager()
    local e = T{}

    for k, v in pairs(Enemies) do
        local line = v.name

        for x = 1, #v.chain do
            line = line
                .. '\n  > '
                .. Weaponskills[v.chain[x].id].name
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
        end

        local time_remaining = 7 - math.abs(v.time - os.time())

        if time_remaining >= 0 then
            line = line .. '\n  > ' .. time_remaining .. 's'
        else
            line = line .. '\n  x'
        end

        table.insert(e, line)
    end

    font:SetText(e:concat('\n\n'))
end

function handle_packet(id, size, packet)
    if id == 0x00C8 then
        update_party(packet)
    elseif id == 0x0028 and ashita.bits.unpack_be(packet, 82, 4) == 3 then
        -- only look at WEAPONSKILL_FINISH packets
        local action = Packet.Server.parse(packet)

        -- gotta traverse our way to the meat of the action data; there can be
        -- multiple targets per weaponskill, so don't choke and die if there are
        for i = 1, action.target_count do
            local target = action.targets[i]

            -- pretty sure there should only ever be one action per target for
            -- weaponskills, but if not this could be the source of a bug
            for j = 1, target.action_count do
                local weaponskill = target.actions[j]

                -- only continue tracking if the source is in our party, the
                -- ability didn't miss, and it can skillchain
                if Party[action.actor_id]
                and weaponskill.reaction == 0x08
                and not NonChainingSkills[weaponskill.animation] then
                    -- reset target info if starting a new chain,
                    -- or if the last one was broken,
                    -- or if the last one finished
                    if Enemies[target.id] == nil
                    or not weaponskill.has_add_effect
                    or is_chain_finished(Enemies[target.id].chain) then
                        Enemies[target.id] = {
                            name = get_entity(target.id).Name,
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
                        base_damage = weaponskill.param,
                        bonus_damage = weaponskill.add_effect_param,
                        resonance = Resonances[weaponskill.add_effect_message]
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

    return false
end

ashita.register_event('load', load)
ashita.register_event('unload', unload)
ashita.register_event('render', render)
ashita.register_event('incoming_packet', handle_packet)
