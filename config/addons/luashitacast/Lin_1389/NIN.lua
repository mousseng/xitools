require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local handleGlamour = gFunc.LoadFile('common/glamour.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Shinobi-Gatana", "Wakizashi" },
            Sub = { "Shinobi-Gatana", "Wakizashi" },
            Range = { "Platoon Disc" },
            Ammo = { "Shuriken" },
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
            -- Hands = { },
            -- Legs = { },
            -- Feet = { },
            -- Neck = { },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
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
            -- Neck = { },
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
            -- Neck = { },
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
            Body = "Brass Harness +1",
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
    if spell.Name:startswith('Hyoton')
    or spell.Name:startswith('Suiton') then
        gFunc.EquipSet('Int')
    end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    local weaponskill = gData.GetAction()
    local strDexSkills = T{ 'Blade: Rin', 'Blade: Retsu', 'Blade: Jin', 'Blade: Ten', 'Blade: Ku' }
    local strIntSkills = T{ 'Blade: Teki', 'Blade: To', 'Blade: Chi', 'Blade: Ei', }
    local dexIntSkills = T{ 'Blade: Yu' }

    if strDexSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Dex')
    elseif strIntSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Int')
        gFunc.EquipSet('Str')
    elseif dexIntSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Int')
        gFunc.EquipSet('Dex')
    elseif weaponskill.Name == 'Blade: Shun' then
        gFunc.EquipSet('Dex')
    end
end

return profile
