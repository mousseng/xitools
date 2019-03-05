lin = lin or { }

-------------------------------------------------------------------------------
-- Server ID 0x0028: the action packet. This is pretty complex packet, and its
-- fields are used for a lot of differing purposes, depending on the context.
-- It is a variable-length packet, containing nested arrays of targets and
-- actions.
-------------------------------------------------------------------------------
local function parse_action(packet)
    -- Collect top-level metadata. The category field will provide the context
    -- for the rest of the packet - that should be enough information to figure
    -- out what each target and action field are used for.
    local action = {
        -- Windower code leads me to believe param and recast might be at
        -- different indices - 102 and 134, respectively. Confusing.
        actor_id     = ashita.bits.unpack_be(packet,  40, 32),
        target_count = ashita.bits.unpack_be(packet,  72,  8),
        category     = ashita.bits.unpack_be(packet,  82,  4),
        param        = ashita.bits.unpack_be(packet,  86, 10),
        recast       = ashita.bits.unpack_be(packet, 118, 10),
        unknown      = 0,
        targets      = {}
    }

    local bit_offset = 150

    -- Collect target information. The ID is the server ID, not the entity idx.
    for i = 1, action.target_count do
        action.targets[i] = {
            id           = ashita.bits.unpack_be(packet, bit_offset,      32),
            action_count = ashita.bits.unpack_be(packet, bit_offset + 32,  4),
            actions      = {}
        }

        -- Collect per-target action information. This is where more identifiers
        -- for what's being used lie - often the animation can be used for that
        -- purpose. Otherwise the message may be what you want.
        for j = 1, action.targets[i].action_count do
            action.targets[i].actions[j] = {
                reaction  = ashita.bits.unpack_be(packet, bit_offset + 36,  5),
                animation = ashita.bits.unpack_be(packet, bit_offset + 41, 11),
                effect    = ashita.bits.unpack_be(packet, bit_offset + 53,  2),
                stagger   = ashita.bits.unpack_be(packet, bit_offset + 55,  7),
                param     = ashita.bits.unpack_be(packet, bit_offset + 63, 17),
                message   = ashita.bits.unpack_be(packet, bit_offset + 80, 10),
                unknown   = ashita.bits.unpack_be(packet, bit_offset + 90, 31)
            }

            -- Collect additional effect information for the action. This is
            -- where you'll find information about skillchains, enspell damage,
            -- et cetera.
            if ashita.bits.unpack_be(packet, bit_offset + 121, 1) == 1 then
                action.targets[i].actions[j].has_add_effect       = true
                action.targets[i].actions[j].add_effect_animation = ashita.bits.unpack_be(packet, bit_offset + 122, 10)
                action.targets[i].actions[j].add_effect_effect    = nil -- unknown value
                action.targets[i].actions[j].add_effect_param     = ashita.bits.unpack_be(packet, bit_offset + 132, 17)
                action.targets[i].actions[j].add_effect_message   = ashita.bits.unpack_be(packet, bit_offset + 149, 10)

                bit_offset = bit_offset + 37
            else
                action.targets[i].actions[j].has_add_effect       = false
                action.targets[i].actions[j].add_effect_animation = nil
                action.targets[i].actions[j].add_effect_effect    = nil
                action.targets[i].actions[j].add_effect_param     = nil
                action.targets[i].actions[j].add_effect_message   = nil
            end

            -- Collect spike effect information for the action.
            if ashita.bits.unpack_be(packet, bit_offset + 122, 1) == 1 then
                action.targets[i].actions[j].has_spike_effect       = true
                action.targets[i].actions[j].spike_effect_animation = ashita.bits.unpack_be(packet, bit_offset + 123, 10)
                action.targets[i].actions[j].spike_effect_effect    = nil -- unknown value
                action.targets[i].actions[j].spike_effect_param     = ashita.bits.unpack_be(packet, bit_offset + 133, 14)
                action.targets[i].actions[j].spike_effect_message   = ashita.bits.unpack_be(packet, bit_offset + 147, 10)

                bit_offset = bit_offset + 34
            else
                action.targets[i].actions[j].has_spike_effect       = false
                action.targets[i].actions[j].spike_effect_animation = nil
                action.targets[i].actions[j].spike_effect_effect    = nil
                action.targets[i].actions[j].spike_effect_param     = nil
                action.targets[i].actions[j].spike_effect_message   = nil
            end

            bit_offset = bit_offset + 87
        end

        bit_offset = bit_offset + 36
    end

    return action
end
lin.parse_action = parse_action

-------------------------------------------------------------------------------
-- Server ID 0x0029: the basic message packet.
-------------------------------------------------------------------------------
local function parse_basic(packet)
    local basic = {
        sender     = struct.unpack('i4', packet, 0x04 + 1),
        target     = struct.unpack('i4', packet, 0x08 + 1),
        sender_tgt = struct.unpack('i1', packet, 0x14 + 1),
        target_tgt = struct.unpack('i1', packet, 0x16 + 1),
        param      = struct.unpack('i4', packet, 0x0C + 1),
        value      = struct.unpack('i4', packet, 0x10 + 1),
        message    = struct.unpack('i1', packet, 0x18 + 1)
    }

    return basic
end
lin.parse_basic = parse_basic

-------------------------------------------------------------------------------
-- Server ID 0x0061: the character stats packet.
-------------------------------------------------------------------------------
local function parse_charstats(packet)
    local charstats = {
        max_hp      = struct.unpack('i4', packet, 0x04 + 1),
        max_mp      = struct.unpack('i4', packet, 0x08 + 1),

        main_job    = struct.unpack('i1', packet, 0x0C + 1),
        main_level  = struct.unpack('i1', packet, 0x0D + 1),
        sub_job     = struct.unpack('i1', packet, 0x0E + 1),
        sub_level   = struct.unpack('i1', packet, 0x0F + 1),
        current_exp = struct.unpack('i2', packet, 0x10 + 1),
        needed_exp  = struct.unpack('i2', packet, 0x12 + 1),

        str = nil,
        dex = nil,
        vit = nil,
        agi = nil,
        int = nil,
        mnd = nil,
        chr = nil,

        atk = nil,
        def = nil,

        fireres = nil,
        iceres = nil,
        windres = nil,
        earthres = nil,
        thunderres = nil,
        waterres = nil,
        lightres = nil,
        darkres = nil,

        title = nil,
        rank = nil,
        rankpoints = nil,
        homepoint = nil,
        nation = nil
    }

    return charstats
end
lin.parse_charstats = parse_charstats
