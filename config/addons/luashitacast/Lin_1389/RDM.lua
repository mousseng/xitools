require 'common'
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

local currentLevel = 0

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Fencing Degen", "Yew Wand" },
            Sub = { "Parana Shield" },
            Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Dream Hat +1" },
            Body = { "Savage Separates", "Ryl.Ftm. Tunic", "Dream Robe" },
            Hands = { "Savage Gauntlets", "Dream Mittens +1" },
            Legs = { "Savage Loincloth", "Dream Pants +1" },
            Feet = { "Warlock's Boots", "Savage Gaiters", "Dream Boots +1" },
            Neck = { "Tiger Stole" },
            Waist = { "Friar's Rope" },
            Ear1 = { },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Chariot Band" },
            Back = { "Black Cape", "Cotton Cape" },
        },
        Rest_Priority = {
            Main = { "Pilgrim's Wand" },
        },
        Tp_Priority = {
            -- Main = { },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            Hands = { "Ryl.Ftm. Gloves" },
            -- Legs = { },
            -- Feet = { },
            -- Neck = { },
            -- Waist = { },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            -- Ring1 = { },
            -- Ring2 = { },
            -- Back = { },
        },
        Str = {
            -- Main = { },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            Body = { "Savage Separates" },
            -- Hands = { },
            -- Legs = { },
            Feet = { "Savage Gaiters" },
            -- Neck = { },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "San d'Orian Ring" },
            -- Ring2 = { },
            -- Back = { },
        },
        Dex = {
            -- Main = { },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            -- Hands = { },
            -- Legs = { },
            -- Feet = { },
            -- Neck = { },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            -- Ring1 = { },
            -- Ring2 = { },
            -- Back = { },
        },
        Int = {
            Main = { "Fencing Degen", "Yew Wand" },
            -- Sub = { },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            -- Head = { },
            Body = { "Ryl.Ftm. Tunic" },
            -- Hands = { },
            -- Legs = { },
            Feet = { "Warlock's Boots" },
            Neck = { "Black Neckerchief" },
            Waist = { "Wizard's Belt" },
            -- Ear1 = { },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "Hermit's Ring" },
            Ring2 = { "Hermit's Ring" },
            Back = { "Black Cape" },
        },
        Mnd = {
            Main = { "Fencing Degen", "Yew Wand" },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            Hands = { "Savage Gauntlets" },
            Legs = { "Savage Loincloth" },
            Feet = { "Warlock's Boots" },
            Neck = { "Justice Badge" },
            Waist = { "Friar's Rope" },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Ascetic's Ring" },
            Back = { "White Cape" },
        },
        Movement = { },
        Solo = {
            Main = "Buzzard Tuck",
            Sub = "Parana Shield",
        },
        SoloNin = {
            Main = "Buzzard Tuck",
            Sub = "Fencing Degen",
        },
        Fish = {
            Main = nil,
            Sub = nil,
            Range = "Halcyon Rod",
            Ammo = "Insect Ball",
            Head = nil,
            Body = "Fsh. Tunica",
            Hands = "Fsh. Gloves",
            Legs = "Fisherman's Hose",
            Feet = "Fisherman's Boots",
            Neck = nil,
            Waist = nil,
            Ear1 = nil,
            Ear2 = nil,
            Ring1 = nil,
            Ring2 = nil,
            Back = nil,
        },
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    gSettings.FishMode = false

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /fishe /lac fwd fish')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl self on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl others on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl target on')

    ashita.tasks.once(3, function()
        print(chat.header('LAC: RDM'):append(chat.message('setting glamour')))
        AshitaCore:GetChatManager():QueueCommand(1, '/lockstyleset 19')
        AshitaCore:GetChatManager():QueueCommand(1, '/sl blink')
    end)
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /fishe /lac fwd fish')
end

profile.HandleCommand = function(args)
    if #args == 0 then return end

    if args[1] == 'solo' then
        local toggleToOn = #args == 1 and not gSettings.SoloMode
        local forceToOn = #args == 2 and args[2] == 'on'
        ToggleSoloMode(toggleToOn or forceToOn)
    end

    if args[1] == 'fish' then
        local toggleToOn = #args == 1 and not gSettings.FishMode
        local forceToOn = #args == 2 and args[2] == 'on'
        ToggleFishMode(toggleToOn or forceToOn)
    end
end

profile.HandleDefault = function()
    local player = gData.GetPlayer()

    if currentLevel ~= player.MainJobSync then
        currentLevel = player.MainJobSync
        gFunc.EvaluateLevels(profile.Sets, currentLevel)
    end

    gFunc.EquipSet('Base')
    if player.Status == 'Resting' then
        gFunc.EquipSet('Rest')
    elseif player.Status == 'Engaged' then
        gFunc.EquipSet('Tp')
    elseif player.IsMoving then
        gFunc.EquipSet('Movement')
    end
end

profile.HandleAbility = function()
end

profile.HandleItem = function()
    local item = gData.GetAction()
    if item.Name == 'Orange Juice' then
        gFunc.Equip('Legs', "Dream Pants +1")
    end
end

profile.HandlePrecast = function()
end

profile.HandleMidcast = function()
    local spell = gData.GetAction()

    if spell.Name == 'Sneak' then
        gFunc.Equip('Feet', "Dream Boots +1")
    elseif spell.Name == 'Invisible' then
        gFunc.Equip('Hands', "Dream Mittens +1")
    elseif spell.Type == 'White Magic' then
        gFunc.EquipSet('Mnd')
    elseif spell.Type == 'Black Magic' then
        gFunc.EquipSet('Int')
    end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    local weaponskill = gData.GetAction()
    local strSkills = T{ 'Flat Blade', 'Circle Blade', 'Vorpal Blade' }
    local dexSkills = T{ 'Fast Blade' }
    local mndSkills = T{ 'Requiescat' }
    local strMndSkills = T{ 'Shining Blade', 'Seraph Blade', 'Swift Blade', 'Savage Blade', 'Sanguine Blade', 'Knights of Round', 'Death Blossom' }
    local strIntSkills = T{ 'Burning Blade', 'Red Lotus Blade' }
    local hpSkills = T{ 'Spirits Within' }

    if strSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
    elseif dexSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Dex')
    elseif mndSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Mnd')
    elseif strMndSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Mnd')
    elseif strIntSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Int')
    elseif hpSkills:contains(weaponskill.Name) then
    end

    if gSettings.SoloMode then
        gFunc.EquipSet('Solo')
    end

    if gSettings.FishMode then
        gFunc.EquipSet('Fish')
    end
end

return profile
