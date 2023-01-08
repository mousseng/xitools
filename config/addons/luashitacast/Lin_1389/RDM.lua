require 'common'
local chat = require('chat')

local profile = {
    Sets = {
        Base = {
            Main = "Centurion's Sword",
            Sub = "Parana Shield",
            -- Range = "",
            Ammo = "Morion Tathlum",
            -- Head = "",
            Body = "Ryl.Ftm. Tunic",
            Hands = "Ryl.Ftm. Gloves",
            Legs = "Ryl.Ftm. Trousers",
            Feet = "Ryl.Ftm. Clogs",
            Neck = "Tiger Stole",
            Waist = "Friar's Rope",
            -- Ear1 = "",
            -- Ear2 = "",
            Ring1 = "San d'Orian Ring",
            Ring2 = "Chariot Band",
            Back = "Cotton Cape",
        },
        Resting = {
            Main = "Pilgrim's Wand",
        },
        Tp = { },
        Movement = { },
    },
    Packer = {
    },
}

profile.OnLoad = function()
    local player = gData.GetPlayer()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')

    if player.SubJob == 'WHM' then
        AshitaCore:GetChatManager():QueueCommand(1, '/macro set 1')
    elseif player.SubJob == 'BLM' then
        AshitaCore:GetChatManager():QueueCommand(1, '/macro set 2')
    elseif player.SubJob == 'THF' then
        AshitaCore:GetChatManager():QueueCommand(1, '/macro set 3')
    elseif player.SubJob == 'NIN' then
        AshitaCore:GetChatManager():QueueCommand(1, '/macro set 4')
    end
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
    if #args == 0 then return end
    if args[1] == 'solo' and not gSettings.SoloMode then
        gSettings.SoloMode = true
        print(chat.header('LAC: RDM'):append(chat.message('enabling solo mode')))
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac disable Main')
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac disable Sub')
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac disable Range')
    elseif args[1] == 'solo' and gSettings.SoloMode then
        gSettings.SoloMode = false
        print(chat.header('LAC: RDM'):append(chat.message('disabling solo mode')))
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac enable Main')
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac enable Sub')
        AshitaCore:GetChatManager():QueueCommand(-1, '/lac enable Range')
    end
end

profile.HandleDefault = function()
    gFunc.EquipSet('Base')

    local player = gData.GetPlayer()
    if player.IsMoving then
        gFunc.EquipSet('Movement')
    elseif player.Status == 'Resting' then
        gFunc.EquipSet('Resting')
    elseif player.Status == 'Engaged' then
        gFunc.EquipSet('Tp')
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
    -- TODO: get fast-cast gear
end

profile.HandleMidcast = function()
    local spell = gData.GetAction()

    -- TODO: get staves for late-game casting
    gFunc.Equip('Main', "Yew Wand")

    if spell.Name == 'Sneak' then
        gFunc.Equip('Feet', "Dream Boots +1")
    elseif spell.Name == 'Invisible' then
        gFunc.Equip('Hands', "Dream Mittens +1")
    elseif spell.Type == 'White Magic' then
        gFunc.Equip('Neck', "Justice Badge")
        gFunc.Equip('Ring1', "San d'Orian Ring")
        gFunc.Equip('Ring2', "Ascetic's Ring")
    elseif spell.Type == 'Black Magic' then
        gFunc.Equip('Ring1', "Hermit's Ring")
        gFunc.Equip('Ring2', "Hermit's Ring")
    end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    -- TODO: get str/dex/int/mnd gear
end

return profile
