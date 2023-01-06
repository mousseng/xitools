require 'common'
local chat = require('chat')

local profile = {
    Sets = {
        Base = {
            Main = "Centurion's sword",
            Sub = "Parana shield",
            -- Range = "",
            -- Ammo = "",
            -- Head = "",
            Body = "Royal Footman's tunic",
            Hands = "Royal Footman's gloves",
            Legs = "Royal Footman's trousers",
            Feet = "Royal Footman's clogs",
            Neck = "Tiger stole",
            Waist = "Friar's rope",
            -- Ear1 = "",
            -- Ear2 = "",
            Ring1 = "San d'Orian ring",
            Ring2 = "Chariot band",
            Back = "Cotton cape",
        },
        Resting = {
            Main = "Pilgrim's wand",
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
    if item.Name == 'Ginger cookies' then
        gFunc.Equip('Legs', 'Dream pants +1')
    end
end

profile.HandlePrecast = function()
    -- TODO: get fast-cast gear
end

profile.HandleMidcast = function()
    local spell = gData.GetAction()

    -- TODO: get wand for early-game casting
    -- TODO: get staves for late-game casting
    gFunc.Equip('Neck', "Justice Badge")
    gFunc.Equip('Ring2', "Ascetic's Ring")

    if spell.Name == 'Sneak' then
        gFunc.Equip('Feet', "Dream boots +1")
    elseif spell.Name == 'Invisible' then
        gFunc.Equip('Hands', "Dream mittens +1")
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
