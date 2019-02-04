lin = lin or { }

local function dump(id, str)
    local date = os.date('*t')
    local log_name = string.format('packets %04i.%02i.%02i.log', date.year, date.month, date.day)
    local log_dir = string.format('%s/%s/', AshitaCore:GetAshitaInstallPath(), 'packetlogs')

    if not ashita.file.dir_exists(log_dir) then
        ashita.file.create_dir(log_dir)
    end

    local log_file = io.open(string.format('%s/%s', log_dir, log_name), 'a')
    if log_file ~= nil then
        local header = string.format(
            '%s id %x\n',
            os.date('[%H:%M:%S]', os.time()),
            id)

        local footer = '\n\n'

        log_file:write(header .. str .. footer)
        log_file:close()
    end
end

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

local function dump_action(action)
    local output =
        'actor_id: '     .. string.format('%i',   action.actor_id) .. ' (' .. GetEntityNameByServerId(action.actor_id) .. ')\n' ..
        'target_count: ' .. string.format('%i',   action.target_count) .. '\n' ..
        'category: '     .. string.format('0x%x', action.category)     .. '\n' ..
        'param: '        .. string.format('0x%x', action.param)        .. '\n' ..
        'recast: '       .. string.format('%i',   action.recast)       .. '\n' ..
        'unknown: '      .. string.format('%i',   action.unknown)      .. '\n' ..
        'targets: '      .. string.format('%i',   action.targets)      .. '\n'

    for i = 1, action.target_count do
        output = output ..
            '    id: '           .. tostring(action.targets[i].id) .. ' (' .. GetEntityNameByServerId(action.targets[i].id) .. ')\n' ..
            '    action_count: ' .. tostring(action.targets[i].action_count) .. '\n' ..
            '    actions:\n'

        for j = 1, action.targets[i].action_count do
            output = output ..
                '        reaction: '               .. tostring(action.targets[i].actions[j].reaction) .. '\n' ..
                '        animation: '              .. tostring(action.targets[i].actions[j].animation) .. '\n' ..
                '        effect: '                 .. tostring(action.targets[i].actions[j].effect) .. '\n' ..
                '        stagger: '                .. tostring(action.targets[i].actions[j].stagger) .. '\n' ..
                '        param: '                  .. tostring(action.targets[i].actions[j].param) .. '\n' ..
                '        message: '                .. tostring(action.targets[i].actions[j].message) .. '\n' ..
                '        unknown: '                .. tostring(action.targets[i].actions[j].unknown) .. '\n' ..
                '        has_add_effect: '         .. tostring(action.targets[i].actions[j].has_add_effect) .. '\n' ..
                '        add_effect_animation: '   .. tostring(action.targets[i].actions[j].add_effect_animation) .. '\n' ..
                '        add_effect_effect: '      .. tostring(action.targets[i].actions[j].add_effect_effect) .. '\n' ..
                '        add_effect_param: '       .. tostring(action.targets[i].actions[j].add_effect_param) .. '\n' ..
                '        add_effect_message: '     .. tostring(action.targets[i].actions[j].add_effect_message) .. '\n' ..
                '        has_spike_effect: '       .. tostring(action.targets[i].actions[j].has_spike_effect) .. '\n' ..
                '        spike_effect_animation: ' .. tostring(action.targets[i].actions[j].spike_effect_animation) .. '\n' ..
                '        spike_effect_effect: '    .. tostring(action.targets[i].actions[j].spike_effect_effect) .. '\n' ..
                '        spike_effect_param: '     .. tostring(action.targets[i].actions[j].spike_effect_param) .. '\n' ..
                '        spike_effect_message: '   .. tostring(action.targets[i].actions[j].spike_effect_message) .. '\n'

            if j < action.targets[i].action_count then
                blob = blob .. '\n'
            end
        end

        if i < action.target_count then
            blob = blob .. '\n'
        end
    end

    dump(0x0028, output)
end
lin.dump_action = dump_action

-------------------------------------------------------------------------------
-- Server ID 0x0029: the basic message packet.
-------------------------------------------------------------------------------
local function parse_basic(packet)
    local basic = {
        sender     = struct.unpack('i', packet, 0x04 + 1),
        target     = struct.unpack('i', packet, 0x08 + 1),
        sender_tgt = struct.unpack('h', packet, 0x14 + 1),
        target_tgt = struct.unpack('h', packet, 0x16 + 1),
        param      = struct.unpack('i', packet, 0x0C + 1),
        value      = struct.unpack('i', packet, 0x10 + 1),
        message    = struct.unpack('h', packet, 0x18 + 1)
    }

    return basic
end
lin.parse_basic = parse_basic

local function dump_basic(basic)
    local output =
        'sender: '     .. string.format('%i',   basic.sender)     .. '\n' ..
        'target: '     .. string.format('%i',   basic.target)     .. '\n' ..
        'sender_tgt: ' .. string.format('%i',   basic.sender_tgt) .. '\n' ..
        'target_tgt: ' .. string.format('%i',   basic.target_tgt) .. '\n' ..
        'param: '      .. string.format('0x%x', basic.param)      .. '\n' ..
        'value: '      .. string.format('0x%x', basic.value)      .. '\n' ..
        'message: '    .. string.format('0x%x', basic.message)    .. '\n' ..

    dump(0x0029, output)
end
lin.dump_basic = dump_basic
