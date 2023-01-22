require 'common'
local chat = require('chat')

local profile = {
    Sets = {
        Base = {
            Main = "Pilgrim's Wand",
            Sub = "Parana Shield",
            -- Range = "",
            Ammo = "Morion Tathlum",
            -- Head = "",
            Body = "Savage Separates",
            Hands = "Savage Gauntlets",
            Legs = "Savage Loincloth",
            Feet = "Savage Gaiters",
            Neck = "Tiger Stole",
            Waist = "Friar's Rope",
            -- Ear1 = "",
            Ear2 = "Cunning Earring",
            Ring1 = "San d'Orian Ring",
            Ring2 = "Chariot Band",
            Back = "Cotton Cape",
        },
        Rest = {
            Main = "Pilgrim's Wand",
        },
        Int = {
            Main = "Yew Wand",
            -- Sub = "",
            -- Range = "",
            Ammo = "Morion Tathlum",
            -- Head = "",
            Body = "Ryl.Ftm. Tunic",
            -- Hands = "",
            -- Legs = "",
            -- Feet = "",
            Neck = "Black Neckerchief",
            Waist = "Wizard's Belt",
            -- Ear1 = "",
            Ear2 = "Cunning Earring",
            Ring1 = "Hermit's Ring",
            Ring2 = "Hermit's Ring",
            -- Back = "",
        },
        Mnd = {
            Main = "Yew Wand",
            -- Sub = "",
            -- Range = "",
            -- Ammo = "",
            -- Head = "",
            -- Body = "",
            Hands = "Savage Gauntlets",
            Legs = "Savage Loincloth",
            -- Feet = "",
            Neck = "Justice Badge",
            Waist = "Friar's Rope",
            -- Ear1 = "",
            -- Ear2 = "",
            Ring1 = "San d'Orian Ring",
            Ring2 = "Ascetic's Ring",
            -- Back = "",
        },
        Movement = { },
        Solo = {
            Main = "Fencing Degen",
            Sub = "Parana Shield",
            Range = nil,
        },
        Fish = {
            Range = "Bamboo Fish. Rod",
            Ammo = "Insect Ball",
            Body = "Fsh. Tunica",
            Hands = "Fsh. Gloves",
            Legs = "Fisherman's Hose",
            Feet = "Fisherman's Boots",
        },
    },
    Packer = {
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    gSettings.FishMode = false

    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl self on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl others on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl target on')

    ashita.tasks.once(3, function()
        print(chat.header('LAC: WHM'):append(chat.message('setting glamour')))
        AshitaCore:GetChatManager():QueueCommand(1, '/lockstyleset 19')
        AshitaCore:GetChatManager():QueueCommand(1, '/sl blink')
    end)
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
    if #args == 0 then return end

    if args[1] == 'solo' then
        if (#args == 1 and not gSettings.SoloMode) or (#args == 2 and args[2] == 'on') then
            gSettings.SoloMode = true
            print(chat.header('LAC: WHM'):append(chat.message('enabling solo mode')))
        elseif (#args == 1 and gSettings.SoloMode) or (#args == 2 and args[2] == 'off') then
            gSettings.SoloMode = false
            print(chat.header('LAC: WHM'):append(chat.message('disabling solo mode')))
        end
    end

    if args[1] == 'fish' then
        if (#args == 1 and not gSettings.FishMode) or (#args == 2 and args[2] == 'on') then
            gSettings.FishMode = true
            print(chat.header('LAC: WHM'):append(chat.message('enabling fish mode')))
        elseif (#args == 1 and gSettings.FishMode) or (#args == 2 and args[2] == 'off') then
            gSettings.FishMode = false
            print(chat.header('LAC: WHM'):append(chat.message('disabling fish mode')))
        end
    end
end

profile.HandleDefault = function()
    gFunc.EquipSet('Base')

    local player = gData.GetPlayer()
    if player.IsMoving then
        gFunc.EquipSet('Movement')
    elseif player.Status == 'Resting' then
        gFunc.EquipSet('Rest')
    end

    if gSettings.SoloMode then
        gFunc.EquipSet('Solo')
    end

    if gSettings.FishMode then
        gFunc.EquipSet('Fish')
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
end

return profile
