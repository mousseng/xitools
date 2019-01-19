-------------------------------------------------------------------------------
-- Set up the namespace.
-------------------------------------------------------------------------------

require 'utils'

ashita        = ashita or { }
ashita.packet = ashita.packet or { }

-------------------------------------------------------------------------------
-- We'll be using jump tables to efficiently dispatch to the correct packet fn.
-------------------------------------------------------------------------------

local parsing_functions = {
    client = { },
    server = { },
}

local logging_functions = {
    client = { },
    server = { },
}

-------------------------------------------------------------------------------
-- Here we'll define each server packet's parser.
-------------------------------------------------------------------------------

-- Server ID 0x0028: the action packet. This is pretty complex packet, and its
-- fields are used for a lot of differing purposes, depending on the context.
-- It is a variable-length packet, containing nested arrays of targets and
-- actions.
local function parse_server_0028(packet)
    -- Collect top-level metadata. The category field will provide the context
    -- for the rest of the packet - that should be enough information to figure
    -- out what each target and action field are used for.
    local action = {
        -- Windower code leads me to believe param and recast might be at
        -- different indices - 102 and 134, respectively. Not sure.
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

        -- Collect per-target action information. This is where the identifiers
        -- for what's being used is - often the animation can be used for that
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
parsing_functions.server[0x0028] = parse_server_0028

-------------------------------------------------------------------------------
-- Here we'll define each client packet's parser.
-------------------------------------------------------------------------------

-- TODO

-------------------------------------------------------------------------------
-- Here we'll define each server packet's logger. Packet must be parsed first.
-------------------------------------------------------------------------------

local function log_server_0028(packet)
    local date = os.date('*t')
    local log_name = string.format('packets %04i.%02i.%02i.log', date.year, date.month, date.day)
    local log_dir = string.format('%s/%s/', AshitaCore:GetAshitaInstallPath(), 'packetlogs')

    if not ashita.file.dir_exists(log_dir) then
        ashita.file.create_dir(log_dir)
    end

    local log_file = io.open(string.format('%s/%s', log_dir, log_name), 'a')
    if log_file ~= nil then
        local timestamp = os.date('[%H:%M:%S]', os.time())
        local blob = timestamp .. ' ' .. 'ID 0x0028' .. '\n'
            .. 'actor_id: '     .. tostring(packet.actor_id) .. ' (' .. GetEntityNameByServerId(packet.actor_id) .. ')\n'
            .. 'target_count: ' .. tostring(packet.target_count) .. '\n'
            .. 'category: '     .. tostring(packet.category) .. '\n'
            .. 'param: '        .. tostring(packet.param) .. '\n'
            .. 'recast: '       .. tostring(packet.recast) .. '\n'
            .. 'unknown: '      .. tostring(packet.unknown) .. '\n'
            .. 'targets:\n'

        for i = 1, packet.target_count do
            blob = blob
                .. '    id: '           .. tostring(packet.targets[i].id) .. ' (' .. GetEntityNameByServerId(packet.targets[i].id) .. ')\n'
                .. '    action_count: ' .. tostring(packet.targets[i].action_count) .. '\n'
                .. '    actions:\n'

            for j = 1, packet.targets[i].action_count do
                blob = blob
                    .. '        reaction: '               .. tostring(packet.targets[i].actions[j].reaction) .. '\n'
                    .. '        animation: '              .. tostring(packet.targets[i].actions[j].animation) .. '\n'
                    .. '        effect: '                 .. tostring(packet.targets[i].actions[j].effect) .. '\n'
                    .. '        stagger: '                .. tostring(packet.targets[i].actions[j].stagger) .. '\n'
                    .. '        param: '                  .. tostring(packet.targets[i].actions[j].param) .. '\n'
                    .. '        message: '                .. tostring(packet.targets[i].actions[j].message) .. '\n'
                    .. '        unknown: '                .. tostring(packet.targets[i].actions[j].unknown) .. '\n'
                    .. '        has_add_effect: '         .. tostring(packet.targets[i].actions[j].has_add_effect) .. '\n'
                    .. '        add_effect_animation: '   .. tostring(packet.targets[i].actions[j].add_effect_animation) .. '\n'
                    .. '        add_effect_effect: '      .. tostring(packet.targets[i].actions[j].add_effect_effect) .. '\n'
                    .. '        add_effect_param: '       .. tostring(packet.targets[i].actions[j].add_effect_param) .. '\n'
                    .. '        add_effect_message: '     .. tostring(packet.targets[i].actions[j].add_effect_message) .. '\n'
                    .. '        has_spike_effect: '       .. tostring(packet.targets[i].actions[j].has_spike_effect) .. '\n'
                    .. '        spike_effect_animation: ' .. tostring(packet.targets[i].actions[j].spike_effect_animation) .. '\n'
                    .. '        spike_effect_effect: '    .. tostring(packet.targets[i].actions[j].spike_effect_effect) .. '\n'
                    .. '        spike_effect_param: '     .. tostring(packet.targets[i].actions[j].spike_effect_param) .. '\n'
                    .. '        spike_effect_message: '   .. tostring(packet.targets[i].actions[j].spike_effect_message) .. '\n'

                if j < packet.targets[i].action_count then
                    blob = blob .. '\n'
                end
            end

            if i < packet.target_count then
                blob = blob .. '\n'
            end
        end

        blob = blob .. '\n\n'

        log_file:write(blob)
        log_file:close()
    end
end
logging_functions.server[0x0028] = log_server_0028

-------------------------------------------------------------------------------
-- Here we'll define each client packet's logger.
-------------------------------------------------------------------------------

-- TODO

-------------------------------------------------------------------------------
-- And finally we export all this into the namespace we set up earlier.
-------------------------------------------------------------------------------

local function parse_client(data)
    local id = struct.unpack('b', data, 1)

    if parsing_functions.client[id] ~= nil then
        return parsing_functions.client[id](data)
    end

    return nil
end
ashita.packet.parse_client = parse_client

local function parse_server(data)
    local id = struct.unpack('b', data, 1)

    if parsing_functions.server[id] ~= nil then
        return parsing_functions.server[id](data)
    end

    return nil
end
ashita.packet.parse_server = parse_server

local function log_client(id, data)
    if logging_functions.client[id] ~= nil then
        logging_functions.client[id](data)
    end
end
ashita.packet.log_client = log_client

local function log_server(id, data)
    if logging_functions.server[id] ~= nil then
        logging_functions.server[id](data)
    end
end
ashita.packet.log_server = log_server
