-------------------------------------------------------------------------------
-- config
-------------------------------------------------------------------------------

_addon.author  = 'lin'
_addon.name    = 'rcheck'
_addon.version = '1.0.0'
_addon.unique  = '__rcheck_addon'

require 'common'
require 'lin.packets'

local PartyMessage = 4
local OutChatPacket = 0xB5
local InChatPacket  = 0x17

local all_ready = 'All party members accounted for.'
local whitelist = { '/', '\\', 'r', 'kronk' }

local listening = false
local party = { }
local ready = { }

local function get_party()
    local party = AshitaCore:GetDataManager():GetParty()
    local array = { }

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1 then
            table.insert(array, party:GetMemberName(i))
        end
    end

    return array
end

local function is_whitelisted(text)
    return table.hasvalue(
        whitelist,
        string.lower(string.trim(text)))
end

local function subtract(lhs, rhs)
    local result = { }

    for idx, val in ipairs(lhs) do
        if not table.hasvalue(rhs, val) then
            table.insert(result, val)
        end
    end

    return result
end

local function matches(lhs, rhs)
    if #lhs ~= #rhs then
        return false
    end

    for idx, val in ipairs(lhs) do
        if not table.hasvalue(rhs, val) then
            return false
        end
    end

    return true
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
    ready = { party[1] }

    write('Running ready check, tallying results in 20 seconds.')
    send_message('Ready check, please / within 20 seconds!')

    ashita.timer.create(_addon.unique, 1, 19, function()
        if listening and matches(party, ready) then
            write(all_ready)
            send_message(all_ready)
            listening = false
        end
    end)

    ashita.timer.once(20, function()
        if listening and matches(party, ready) then
            write(all_ready)
            send_message(all_ready)
        elseif listening then
            local missing = subtract(party, ready)
            local some_ready = string.format(
                '%i of %i ready. We\'re missing %s.',
                #ready,
                #party,
                table.concat(missing, ', ')
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
        and is_whitelisted(msg.text) then
            table.insert(ready, msg.sender)
        end
    end

    return false
end)
