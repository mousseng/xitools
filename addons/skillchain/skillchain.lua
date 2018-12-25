_addon.author  = 'lin'
_addon.name    = 'skillchain'
_addon.version = '0.1.0'

local Packet = require 'packet'

require 'common'
require 'timer'

local Party   = {}
local Enemies = {}

-- local DefaultConfig = {
--     font = {
--         family    = 'Arial',
--         size      = 10,
--         color     = 0xFFFF0000,
--         position  = { 50, 125 },
--         bgcolor   = 0x80000000,
--         bgvisible = true
--     }
-- }

-- local SkillchainConfig = DefaultConfig

function update_party(packet)
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

function load()
    -- initialize rendering data
    -- SkillchainConfig = ashita.settings.load_merged

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

function render()
    -- TODO
end

function handle_command(cmd)
    local args = cmd:args()

    if args[1] ~= '/sc' then
        return false
    end

    if #args > 1 and args[2] == 'dump' then
        for k, v in pairs(Party) do
          print('partymem ' .. k)
        end

        for k, v in pairs(Enemies) do
          print('target ' .. k .. ': ' .. #v)
        end
    end

    return true
end

function handle_packet(id, size, packet)
    if id == 0x00C8 then
        update_party(packet)
    elseif id == 0x0028 and ashita.bits.unpack_be(packet, 82, 4) == 3 then
        -- only look at WEAPONSKILL_FINISH packets
        local action = Packet.Server.parse(packet)

        -- gotta traverse our way to the meat of the action data
        for i = 1, action.target_count do
            local target = action.targets[i]

            for j = 1, target.action_count do
                local weaponskill = target.actions[j]

                if Party[action.actor_id] == true then
                    -- are we starting a new chain?
                    if Enemies[target.id] == nil then
                        Enemies[target.id] = {}
                        table.insert(Enemies[target.id], weaponskill.id)
                    -- reset timer if not
                    else
                        ashita.timer.remove_timer(target.id)
                    end

                    -- once the chain window closes after ~6s,
                    -- drop the chain information
                    ashita.timer.create(target.id, 6, 1, function(tgt) Enemies[tgt] = nil end, target.id)
                end
            end
        end
    end

    return false
end

ashita.register_event('load', load)
ashita.register_event('render', render)
ashita.register_event('command', handle_command)
ashita.register_event('incoming_packet', handle_packet)
