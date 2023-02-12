local chat = require('chat')

local function ToggleSoloMode(shouldEnable)
    local player = gData.GetPlayer()
    local header = string.format('LAC: %s', player.MainJob)
    gSettings.SoloMode = shouldEnable

    if shouldEnable then
        print(chat.header(header):append(chat.message('enabling solo mode')))
        if player.SubJob == 'NIN' then
            gFunc.ForceEquipSet('SoloNin')
        else
            gFunc.ForceEquipSet('Solo')
        end
        gFunc.Disable('Main')
        gFunc.Disable('Sub')
        gFunc.Disable('Range')
    else
        print(chat.header(header):append(chat.message('disabling solo mode')))
        gFunc.Enable('Main')
        gFunc.Enable('Sub')
        gFunc.Enable('Range')
    end
end

local function HandleSoloMode(args)
    if args[1] == 'solo' then
        local toggleToOn = #args == 1 and not gSettings.SoloMode
        local forceToOn = #args == 2 and args[2] == 'on'
        ToggleSoloMode(toggleToOn or forceToOn)
    end
end

return HandleSoloMode
