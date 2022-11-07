-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'rcheck'
_addon.version = '2.0.0'
_addon.unique  = '__rcheck_addon'

require 'common'
require 'core.set'
require 'lin.packets'

local PartyMessage = 4
local OutChatPacket = 0xB5
local IncChatPacket = 0x17

local all_ready = 'All party members accounted for.'
local whitelist = set.from_array({ '/', '\\', 'r', 'kronk' })

local listening = false
local party = set.new()
local ready = set.new()

local function get_party()
    local data = AshitaCore:GetDataManager():GetParty()
    local party = set.new()

    for i = 0, 17 do
        if data:GetMemberActive(i) == 1 then
            party:add(data:GetMemberName(i))
        end
    end

    return party
end

local function get_player()
    local result = set.new()
    local player = GetPlayerEntity()

    if player ~= nil and player.Name ~= nil then
        result:add(player.Name)
    end

    return result
end

local function send_message(text)
    local player = GetPlayerEntity()
    local zone = AshitaCore:GetDataManager():GetParty():GetMemberZone(0)

    if player == nil or player.Name == nil or zone == nil then
        -- shit's broke, bail before you do something stupid
        return
    end

    local out = struct.pack('xxxxBBsx', 4, 0, text):totable()
    out[1] = OutChatPacket
    out[2] = #text + 2

    AddOutgoingPacket(OutChatPacket, out)

    -- name string must be padded out with null bytes to a length of 15
    local name = string.rpad(player.Name, string.char(0), 15)
    local inc = struct.pack('xxxxBBhssx', 4, 0, zone, name, text):totable()
    inc[1] = IncChatPacket
    inc[2] = #text + 20 -- 2 uchars, 1 ushort, 16-byte sender

    AddIncomingPacket(IncChatPacket, inc)
end

ashita.register_event('command', function(cmd)
    local args = cmd:args()

    if #args < 1 or args[1] == '/rc' or args[1] ~= '/rcheck' then
        return false
    end

    listening = true
    party = get_party()
    ready = get_player()

    send_message('Ready check, please / within 30 seconds! <call21>')

    ashita.timer.create(_addon.unique, 1, 29, function()
        if listening and set.equals(ready, party) then
            send_message(all_ready)
            listening = false
        end
    end)

    ashita.timer.once(30, function()
        if listening and set.equals(ready, party) then
            send_message(all_ready)
        elseif listening then
            local missing = ready:difference(party)
            local some_ready = string.format(
                '%i of %i ready. We\'re missing %s.',
                ready:count(),
                party:count(),
                table.concat(missing:to_array(), ', ')
            )

            send_message(some_ready)
        end

        listening = false
    end)

    return true
end)

ashita.register_event('incoming_packet', function(id, size, data)
    if id == 0x17 and listening then
        local msg = lin.parse_chatmessage(data)

        if msg.type == PartyMessage
        and whitelist:contains(string.trim(msg.text))
        and not ready:contains(string.trim(msg.sender)) then
            ready:add(msg.sender)
        end
    end

    return false
end)
