--[[ private ]]
local jump_table = {
    client = {},
    server = {
        [0x0028] = function(packet)
            -- collect top-level action information
            local action = {
                -- Windower code leads me to believe param and recast might be
                -- at different indices - 102 and 134, respectively. not sure
                actor_id     = ashita.bits.unpack_be(packet, 40, 32),
                target_count = ashita.bits.unpack_be(packet, 72, 8),
                category     = ashita.bits.unpack_be(packet, 82, 4),
                param        = ashita.bits.unpack_be(packet, 86, 10),
                recast       = ashita.bits.unpack_be(packet, 118, 10),
                unknown      = 0,
                targets      = {}
            }

            local bit_offset = 150

            -- collect target information
            for i = 1, action.target_count do
                action.targets[i] = {
                    id           = ashita.bits.unpack_be(packet, bit_offset, 32),
                    action_count = ashita.bits.unpack_be(packet, bit_offset + 32, 4),
                    actions      = {}
                }

                -- collect per-target action information
                for j = 1, action.targets[i].action_count do
                    action.targets[i].actions[j] = {
                        reaction  = ashita.bits.unpack_be(packet, bit_offset + 36, 5),
                        animation = ashita.bits.unpack_be(packet, bit_offset + 41, 11),
                        effect    = ashita.bits.unpack_be(packet, bit_offset + 53, 2),
                        stagger   = ashita.bits.unpack_be(packet, bit_offset + 55, 7),
                        param     = ashita.bits.unpack_be(packet, bit_offset + 63, 17),
                        message   = ashita.bits.unpack_be(packet, bit_offset + 80, 10),
                        unknown   = ashita.bits.unpack_be(packet, bit_offset + 90, 31)
                    }

                    -- collect additional effect information for the action
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

                    -- collect spike effect information for the action
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
    }
}

--[[ public ]]
local Packet = { Client = {}, Server = {} }

function Packet.Server.parse(packet)
    local packet_id = struct.unpack('b', packet, 1)

    if jump_table.server[packet_id] ~= nil then
        return jump_table.server[packet_id](packet)
    else
        return nil
    end
end

return Packet
