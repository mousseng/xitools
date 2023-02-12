require 'common'
local chat = require('chat')

local currentLevel = 0

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Yew Wand" },
            Sub = { "Parana Shield" },
            Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Gold Hairpin", "Brass Hairpin", "Dream Hat +1" },
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
        Int_Priority = {
            Main = { "Yew Wand" },
            -- Sub = { },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { { Name = "displaced", Level = 10 } },
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
        Mnd_Priority = {
            Main = { "Yew Wand" },
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
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true

    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl self on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl others on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl target on')

    ashita.tasks.once(3, function()
        print(chat.header('LAC: BLM'):append(chat.message('setting glamour')))
        AshitaCore:GetChatManager():QueueCommand(1, '/lockstyleset 19')
        AshitaCore:GetChatManager():QueueCommand(1, '/sl blink')
    end)
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
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
