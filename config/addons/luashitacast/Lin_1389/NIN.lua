require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local handleGlamour = gFunc.LoadFile('common/glamour.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')
local handleMagic = gFunc.LoadFile('common/magic.lua')
local handleSwordWs = gFunc.LoadFile('common/weaponskills/sword.lua')
local handleDaggerWs = gFunc.LoadFile('common/weaponskills/dagger.lua')
local handleKatanaWs = gFunc.LoadFile('common/weaponskills/katana.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Centurion's Sword", "Shinobi-Gatana", "Wakizashi" },
            Sub = { "Centurion's Sword", "Shinobi-Gatana", "Wakizashi" },
            -- Range = { "Platoon Disc" },
            Ammo = { "Pebble" },
            Head = { "Mrc. Hachimaki", "Ryl.Ftm. Bandana", "Dream Hat +1" },
            Body = { "Beetle Harness", "Brass Harness +1", "Dream Robe" },
            Hands = { "Savage Gauntlets", "Mrc. Tekko", "Ryl.Ftm. Gloves", "Dream Mittens +1" },
            Legs = { "Savage Loincloth", "Mrc. Sitabaki", "Brass Subligar", "Dream Pants +1" },
            Feet = { "Savage Gaiters", "Beetle Leggings", "Brass Leggings", "Dream Boots +1" },
            Neck = { "Tiger Stole", "Wing Pendant" },
            Waist = { "Warrior's Belt", "Leather Belt" },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Chariot Band" },
            Back = { "Rabbit Mantle" },
        },
        Rest_Priority = {
        },
        Tp_Priority = {
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            Hands = { "Mrc. Tekko", },
            Legs = { "Mrc. Sitabaki", },
            -- Feet = { },
            -- Neck = { },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Balance Ring", },
            Ring2 = { "Balance Ring", },
            -- Back = { },
        },
        Str_Priority = {
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            Body = { "Savage Separates" },
            -- Hands = { },
            -- Legs = { },
            Feet = { "Savage Gaiters" },
            Neck = { "Spike Necklace", },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "San d'Orian Ring" },
            -- Ring2 = { },
            -- Back = { },
        },
        Dex_Priority = {
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            -- Hands = { },
            -- Legs = { },
            -- Feet = { },
            Neck = { "Spike Necklace", },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
            -- Back = { },
        },
        Int_Priority = {
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { { Name = "displaced", Level = 10 } },
            Body = { "Ryl.Ftm. Tunic" },
            -- Hands = { },
            -- Legs = { },
            -- Feet = { },
            Neck = { "Black Neckerchief" },
            -- Waist = { },
            -- Ear1 = { },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "Eremite's Ring" },
            Ring2 = { "Eremite's Ring" },
            -- Back = { },
        },
        Mnd_Priority = {
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            Hands = { "Savage Gauntlets" },
            Legs = { "Savage Loincloth" },
            -- Feet = { },
            Neck = { "Justice Badge" },
            Waist = { "Friar's Rope" },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Saintly Ring" },
            Ring2 = { "Saintly Ring" },
            -- Back = { },
        },
        Glamour = {
            Head = "remove",
            Body = "Beetle Harness",
            Hands = "remove",
            Legs = "Fisherman's Hose",
            Feet = "Dream Boots +1",
        },
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    gSettings.FishMode = false
    gSettings.HelmMode = false

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /glam /lac fwd glam')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /fishe /lac fwd fish')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /helm /lac fwd helm')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 4')
end

profile.OnUnload = function()
    handleSoloMode('solo off')
    handleFishMode('fish off')
    handleHelmMode('helm off')

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /glam')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /fishe')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /helm')
end

profile.HandleCommand = function(args)
    if #args == 0 then return end
    handleGlamour(args)
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
end

profile.HandleMidcast = function()
    local spell = gData.GetAction()
    handleMagic(spell)
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    local weaponskill = gData.GetAction()
    handleSwordWs(weaponskill.Name)
    handleDaggerWs(weaponskill.Name)
    handleKatanaWs(weaponskill.Name)
end

return profile
