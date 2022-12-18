addon.name    = 'rcheck'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'Make ready-checking easy :)'

local PartyMessage = 4
local OutChatPacket = 0xB5
local IncChatPacket = 0x17

local prompt = 'Ready check, please / within 30 seconds! <call21>'
local all_ready = 'All party members accounted for.'
local whitelist = set.from_array({ '/', '\\', 'r', 'kronk' })

local listening = false
local party = set.new()
local ready = set.new()

local function get_party()
    local result = set.new()
    local party = AshitaCore:GetMemoryManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1 then
            result:add(party:GetMemberName(i))
        end
    end

    return result
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

    AshitaCore:GetPacketManager():AddOutgoingPacket(OutChatPacket, out)

    -- name string must be padded out with null bytes to a length of 15
    local name = string.rpad(player.Name, string.char(0), 15)
    local inc = struct.pack('xxxxBBhssx', 4, 0, zone, name, text):totable()
    inc[1] = IncChatPacket
    inc[2] = #text + 20 -- 2 uchars, 1 ushort, 16-byte sender

    AshitaCore:GetPacketManager():AddIncomingPacket(IncChatPacket, inc)
end

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()

    if #args < 1 or (args[1] ~= '/rc' and args[1] ~= '/rcheck') then
        return false
    end

    listening = true
    party = get_party()
    ready = get_player()

    send_message(prompt)

    -- TODO: idk if this blows up, might have to hoist
    -- some of these vars up as parameters to the coroutines
    ashita.tasks.repeating(1, 29, 1, function()
        if listening and set.equals(ready, party) then
            send_message(all_ready)
            listening = false
        end
    end)

    ashita.tasks.once(30, function()
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

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x17 and listening then
        local msg = lin.parse_chatmessage(e.data)

        if msg.type == PartyMessage
        and whitelist:contains(string.trim(msg.text))
        and not ready:contains(string.trim(msg.sender)) then
            ready:add(msg.sender)
        end
    end

    return false
end)
