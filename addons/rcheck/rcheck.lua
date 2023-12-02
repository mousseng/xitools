addon.name    = 'rcheck'
addon.author  = 'lin'
addon.version = '2.1'
addon.desc    = 'Make ready-checking easy :)'

require('common')
local Set = require('lin/set')
local Packets = require('lin/packets')

local MessagePacket = 0x0017
local PartyMessage = 4
local Prompt = 'Ready check, please / within %i seconds! <call21>'
local AllReady = 'All party members accounted for.'
local SomeReady = '%i of %i ready. We\'re missing %s.'
local Whitelist = Set.from_array({ '/', '\\', 'r', 'kronk' })

local IsListening = false
local Party = Set.new()
local Ready = Set.new()

local function GetParty()
    local result = Set.new()
    local partyMgr = AshitaCore:GetMemoryManager():GetParty()

    for i = 0, 17 do
        if partyMgr:GetMemberIsActive(i) == 1 then
            result:add(partyMgr:GetMemberName(i))
        end
    end

    return result
end

local function GetPlayer()
    local result = Set.new()
    local player = GetPlayerEntity()

    if player ~= nil and player.Name ~= nil then
        result:add(player.Name)
    end

    return result
end

local function SendMessage(mode, text)
    AshitaCore:GetChatManager():QueueCommand(1, string.format('%s %s', mode, text))
end

ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()
    local duration = 30

    if #args < 1 or (args[1] ~= '/rc' and args[1] ~= '/rcheck') then
        return false
    end

    if #args == 2 then
        local newDur = tonumber(args[2])
        if newDur == nil then
            SendMessage('/echo', '[rcheck] ERROR: please provide a number for duration.')
            return true
        end

        duration = newDur
    end

    IsListening = true
    Party = GetParty()
    Ready = GetPlayer()

    SendMessage('/p', string.format(Prompt, duration))

    ashita.tasks.repeating(1, duration - 1, 1, function()
        if IsListening and Set.equals(Ready, Party) then
            SendMessage('/p', AllReady)
            IsListening = false
        end
    end)

    ashita.tasks.once(duration, function()
        if IsListening and Set.equals(Ready, Party) then
            SendMessage('/p', AllReady)
        elseif IsListening then
            local missing = Ready:difference(Party)
            local someReady = string.format(
                SomeReady,
                Ready:count(),
                Party:count(),
                table.concat(missing:to_array(), ', ')
            )

            SendMessage('/p', someReady)
        end

        IsListening = false
    end)

    return true
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    if e.id == MessagePacket and IsListening then
        local msg = Packets.inbound.chatMessage.parse(e.data)

        if msg.type == PartyMessage
        and Whitelist:contains(string.trim(msg.text))
        and not Ready:contains(string.trim(msg.sender)) then
            Ready:add(msg.sender)
        end
    end

    return false
end)
