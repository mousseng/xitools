-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'rcheck'
_addon.version = '1.0.0'
_addon.unique  = '__rcheck_addon'

require 'common'
require 'core.set'
require 'lin.packets'

local PartyMessage = 4
local OutChatPacket = 0xB5
local InChatPacket  = 0x17

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

local function write(text)
    -- Gnarly, but the colors help.
    print(string.format('\31\200[\31\05rcheck\31\200] \31\130%s', text))
end

local function send_message(text)
    local data = struct.pack('xxxxBBsx', 4, 0, text):totable()

    data[1] = OutChatPacket
    data[2] = #text + 2

    AddOutgoingPacket(OutChatPacket, data)
end

ashita.register_event('command', function(cmd)
    local args = cmd:args()

    if #args < 1 or args[1] == '/rc' or args[1] ~= '/rcheck' then
        return false
    end

    listening = true
    party = get_party()
    ready = get_player()

    write('Running ready check, tallying results in 30 seconds. <call21>')
    send_message('Ready check, please / within 30 seconds! <call21>')

    ashita.timer.create(_addon.unique, 1, 29, function()
        if listening and set.equals(ready, party) then
            write(all_ready)
            send_message(all_ready)
            listening = false
        end
    end)

    ashita.timer.once(30, function()
        if listening and set.equals(ready, party) then
            write(all_ready)
            send_message(all_ready)
        elseif listening then
            local missing = ready:difference(party)
            local some_ready = string.format(
                '%i of %i ready. We\'re missing %s.',
                ready:count(),
                party:count(),
                table.concat(missing:to_array(), ', ')
            )

            write(some_ready)
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
