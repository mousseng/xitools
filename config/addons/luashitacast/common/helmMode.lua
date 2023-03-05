local chat = require('chat')

local helmSet = {
    Body = "Field Tunica",
    Hands = "Field Gloves",
    Legs = "Field Hose",
    Feet = "Field Boots",
}

local function ToggleHelmMode(shouldEnable)
    local player = gData.GetPlayer()
    local header = string.format('LAC: %s', player.MainJob)
    gSettings.HelmMode = shouldEnable

    if shouldEnable then
        print(chat.header(header):append(chat.message('enabling helm mode')))
        gFunc.ForceEquipSet(helmSet)
        gFunc.Disable('Body')
        gFunc.Disable('Hands')
        gFunc.Disable('Legs')
        gFunc.Disable('Feet')
    else
        print(chat.header(header):append(chat.message('disabling helm mode')))
        gFunc.Enable('Body')
        gFunc.Enable('Hands')
        gFunc.Enable('Legs')
        gFunc.Enable('Feet')
    end
end

local function HandleHelmMode(args)
    if args[1] == 'helm' then
        local toggleToOn = #args == 1 and not gSettings.HelmMode
        local forceToOn = #args == 2 and args[2] == 'on'
        ToggleHelmMode(toggleToOn or forceToOn)
    end
end

return HandleHelmMode
