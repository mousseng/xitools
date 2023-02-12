local chat = require('chat')

local function SetGlamour(equipSet)
    local player = gData.GetPlayer()
    ashita.tasks.once(3, function()
        local header = ('LAC: %s'):format(player.MainJob)
        local lockStyle = ('/lockstyleset %i'):format(equipSet)

        print(chat.header(header):append(chat.message('setting glamour')))
        AshitaCore:GetChatManager():QueueCommand(1, lockStyle)
        AshitaCore:GetChatManager():QueueCommand(1, '/sl blink')
    end)
end

return SetGlamour
