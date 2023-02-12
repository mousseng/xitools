local chat = require('chat')

local function ToggleFishMode(shouldEnable)
    local player = gData.GetPlayer()
    local header = string.format('LAC: %s', player.MainJob)
    gSettings.FishMode = shouldEnable

    if shouldEnable then
        print(chat.header(header):append(chat.message('enabling fish mode')))
        gFunc.ForceEquipSet('Fish')
        gFunc.Disable('Range')
        gFunc.Disable('Ammo')
        gFunc.Disable('Body')
        gFunc.Disable('Hands')
        gFunc.Disable('Legs')
        gFunc.Disable('Feet')
    else
        print(chat.header(header):append(chat.message('disabling fish mode')))
        gFunc.Enable('Range')
        gFunc.Enable('Ammo')
        gFunc.Enable('Body')
        gFunc.Enable('Hands')
        gFunc.Enable('Legs')
        gFunc.Enable('Feet')
    end
end

local function HandleFishMode(args)
    if args[1] == 'fish' then
        local toggleToOn = #args == 1 and not gSettings.FishMode
        local forceToOn = #args == 2 and args[2] == 'on'
        ToggleFishMode(toggleToOn or forceToOn)
    end
end

return HandleFishMode
