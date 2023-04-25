require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')
local conserveMp = gFunc.LoadFile('common/conserveMp.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Yew Wand +1" },
            Sub = { "Yew Wand +1" },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Gold Hairpin", "Seer's Crown +1", { Name = "displaced", Level = 10 }, "Dream Hat +1" },
            Body = { "Savage Separates", "Seer's Tunic", "Ryl.Ftm. Tunic", "Dream Robe" },
            Hands = { "Savage Gauntlets", "Seer's Mitts +1", "Dream Mittens +1" },
            Legs = { "Savage Loincloth", "Seer's Slacks", "Dream Pants +1" },
            Feet = { "Warlock's Boots", "Savage Gaiters", "Dream Boots +1" },
            Neck = { "Black Neckerchief" },
            Waist = { "Friar's Rope" },
            Ear1 = { "Moldavite Earring" },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Chariot Band" },
            Back = { "Black Cape" },
        },
        Rest_Priority = {
            Main = { "Pilgrim's Wand" },
        },
        Int_Priority = {
            Main = { "Yew Wand +1" },
            Sub = { "Yew Wand +1" },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Seer's Crown +1", { Name = "displaced", Level = 10 } },
            Body = { { Name = "displaced", Level = 29 }, "Ryl.Ftm. Tunic" },
            Hands = { "Seer's Mitts +1" },
            Legs = { "Seer's Slacks" },
            -- Feet = { },
            Neck = { "Black Neckerchief" },
            Waist = { "Shaman's Rope" },
            -- Ear1 = { },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "Eremite's Ring" },
            Ring2 = { "Eremite's Ring" },
            Back = { "Black Cape" },
        },
        Mnd_Priority = {
            Main = { "Yew Wand +1" },
            Sub = { "Yew Wand +1" },
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
            Ring1 = { "Saintly Ring" },
            Ring2 = { "Saintly Ring" },
            Back = { "White Cape" },
        },
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    gSettings.FishMode = false
    gSettings.HelmMode = false

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /fishe /lac fwd fish')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /helm /lac fwd helm')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
end

profile.OnUnload = function()
    handleSoloMode('solo off')
    handleFishMode('fish off')
    handleHelmMode('helm off')

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /fishe')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /helm')
end

profile.HandleCommand = function(args)
    if #args == 0 then return end
    handleSoloMode(args)
    handleFishMode(args)
    handleHelmMode(args)
end

profile.HandleDefault = function()
    local player = gData.GetPlayer()
    levelSync(profile.Sets)

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

    conserveMp(profile.Sets.Base)
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile
