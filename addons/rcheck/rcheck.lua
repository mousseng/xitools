addon.name    = 'rcheck'
addon.author  = 'lin'
addon.version = '2.0.0'
addon.desc    = 'Make ready-checking easy :)'

local Set = require('lin.set')
local Packets = require('lin.packets')

local MessagePacket = 0x0017
local PartyMessage = 4
local Prompt = 'Ready check, please / within 30 seconds! <call21>'
local AllReady = 'All party members accounted for.'
local Whitelist = Set.from_array({ '/', '\\', 'r', 'kronk' })

local IsListening = false
local Party = Set.new()
local Ready = Set.new()

local function GetParty()
    local result = Set.new()
    local partyMgr = AshitaCore:GetMemoryManager():GetParty()

    for i = 0, 17 do
        if partyMgr:GetMemberActive(i) == 1 then
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

local function SendMessage(text)
    AshitaCore:GetChatManager():QueueCommand(1, string.format('/p %s', text))
end

ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()

    if #args < 1 or (args[1] ~= '/rc' and args[1] ~= '/rcheck') then
        return false
    end

    IsListening = true
    Party = GetParty()
    Ready = GetPlayer()

    SendMessage(Prompt)

    -- TODO: idk if this blows up, might have to hoist
    -- some of these vars up as parameters to the coroutines
    ashita.tasks.repeating(1, 29, 1, function()
        if IsListening and Set.equals(Ready, Party) then
            SendMessage(AllReady)
            IsListening = false
        end
    end)

    ashita.tasks.once(30, function()
        if IsListening and Set.equals(Ready, Party) then
            SendMessage(AllReady)
        elseif IsListening then
            local missing = Ready:difference(Party)
            local someReady = string.format(
                '%i of %i ready. We\'re missing %s.',
                Ready:count(),
                Party:count(),
                table.concat(missing:to_array(), ', ')
            )

            SendMessage(someReady)
        end

        IsListening = false
    end)

    return true
end)

ashita.events.register('packet_in', 'packet_in_handler', function(e)
    if e.id == MessagePacket and IsListening then
        local msg = Packets.ParseChatMessage(e.data)

        if msg.type == PartyMessage
        and Whitelist:contains(string.trim(msg.text))
        and not Ready:contains(string.trim(msg.sender)) then
            Ready:add(msg.sender)
        end
    end

    return false
end)
