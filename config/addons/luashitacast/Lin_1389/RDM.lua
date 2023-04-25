require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local conserveMp = gFunc.LoadFile('common/conserveMp.lua')
local doMagic = gFunc.LoadFile('common/magic.lua')
local doSwordWs = gFunc.LoadFile('common/weaponskills/sword.lua')
local doDaggerWs = gFunc.LoadFile('common/weaponskills/dagger.lua')
local handleCudgel = gFunc.LoadFile('common/cudgel.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Dark Staff", "Fencing Degen", "Yew Wand +1" },
            Sub = { { Level = 51, Name = "displaced" }, "Parana Shield" },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Gold Hairpin", "Brass Hairpin", "Dream Hat +1" },
            Body = { "Duelist's Tabard", "Warlock's Tabard", "Savage Separates", "Ryl.Ftm. Tunic", "Dream Robe" },
            Hands = { "Savage Gauntlets", "Dream Mittens +1" },
            Legs = { "Savage Loincloth", "Dream Pants +1" },
            Feet = { "Duelist's Boots", "Warlock's Boots", "Savage Gaiters", "Dream Boots +1" },
            Neck = { "Tiger Stole" },
            Waist = { "Friar's Rope" },
            Ear1 = { "Moldavite Earring" },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Chariot Band" },
            Back = { "Black Cape", "Cotton Cape" },
        },
        -- situational base sets
        Rest_Priority = {
            Main = { "Dark Staff", "Pilgrim's Wand" },
        },
        Tp_Priority = {
            Head = { "Ogre Mask", "Super Ribbon" },
            Body = { "Tiger Jerkin", "Brigandine" },
            Hands = { "Warlock's Gloves", "Ryl.Ftm. Gloves" },
            Legs = { "Cmb.Cst. Slacks" },
            Waist = { "Tilt Belt" },
            Neck = { "Tiger Stole" },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
        },
        Movement_Priority = {
        },
        Solo = {
            Main = "Martial Anelace",
            Sub = "Parana Shield",
            Hands = "Warlock's Gloves",
        },
        SoloNin = {
            Main = "Martial Anelace",
            Sub = "Ryl.Grd. Fleuret",
            Hands = "Warlock's Gloves",
        },
        -- stat bonus sets
        Str_Priority = {
            Head = { "Super Ribbon" },
            Body = { "Savage Separates" },
            Feet = { "Savage Gaiters" },
            Neck = { "Spike Necklace" },
            Waist = { "Ryl.Kgt. Belt" },
            Ring1 = { "San d'Orian Ring" },
        },
        Dex_Priority = {
            Head = { "Super Ribbon" },
            Body = { "Brigandine" },
            Legs = { "Duelist's Tights"},
            Hands = { "Warlock's Gloves" },
            Neck = { "Spike Necklace" },
            Waist = { "Ryl.Kgt. Belt" },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
        },
        Vit_Priority = {
        },
        Agi_Priority = {
        },
        Int_Priority = {
            Main = { "Fencing Degen", "Yew Wand +1" },
            Ammo = { "Morion Tathlum" },
            Head = { "Warlock's Chapeau", "Super Ribbon", { Name = "displaced", Level = 10 } },
            Body = { { Name = "displaced", Level = 52 }, "Ryl.Ftm. Tunic" },
            Hands = { "Sly Gauntlets" },
            Legs = { "Magic Cuisses" },
            Feet = { "Warlock's Boots" },
            Neck = { "Black Neckerchief" },
            Waist = { "Ryl.Kgt. Belt", "Wizard's Belt" },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "Eremite's Ring" },
            Ring2 = { "Eremite's Ring" },
            Back = { "Black Cape" },
        },
        Mnd_Priority = {
            Main = { "Fencing Degen", "Yew Wand +1" },
            Head = { "Super Ribbon" },
            Hands = { "Savage Gauntlets" },
            Legs = { "Warlock's Tights", "Magic Cuisses", "Savage Loincloth" },
            Feet = { "Duelist's Boots", "Warlock's Boots" },
            Neck = { "Justice Badge" },
            Waist = { "Ryl.Kgt. Belt", "Friar's Rope" },
            Ring1 = { "Saintly Ring" },
            Ring2 = { "Saintly Ring" },
            Back = { "White Cape" },
        },
        Chr_Priority = {
        },
        -- substat bonus sets
        Acc_Priority = {
            Waist = { "Tilt Belt" },
        },
        Att_Priority = {
            Head = { "Ogre Mask" },
            Body = { "Tiger Jerkin" },
            Hands = { "Ryl.Ftm. Gloves" },
            Legs = { "Cmb.Cst. Slacks" },
            Neck = { "Tiger Stole" },
            Waist = { "Swordbelt" },
        },
        Eva_Priority = {
        },
        Hp_Priority = {
        },
        Mp_Priority = {
        },
        Mab_Priority = {
            Ear1 = { "Moldavite Earring", },
            Feet = { "Duelist's Boots", },
        },
        Interrupt_Priority = {
        },
        -- skill bonus sets
        Healing_Priority = {
            Body = { "Duelist's Tabard" },
            Legs = { "Warlock's Tights" },
            Neck = { "Healing Torque" },
        },
        Elemental_Priority = {
            Head = { "Warlock's Chapeau" },
            Legs = { "Duelist's Tights"},
            Neck = { "Elemental Torque" },
            Ear1 = { "Moldavite Earring" },
        },
        Enhancing_Priority = {
            Legs = { "Warlock's Tights" },
            Neck = { "Enhancing Torque" },
        },
        Enfeebling_Priority = {
            Main = { "Fencing Degen" },
            Body = { "Warlock's Tabard" },
            Neck = { "Enfeebling Torque" },
        },
        Divine_Priority = {
            Neck = { "Divine Torque" },
        },
        Dark_Priority = {
            Main = { "Dark Staff" },
            Neck = { "Dark Torque" },
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
    handleCudgel(args)
end

profile.HandleDefault = function()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()
    levelSync(profile.Sets)

    gFunc.EquipSet('Base')

    if env.Area:endswith("San d'Oria") then
        gFunc.Equip('Body', "Kingdom Aketon")
    end

    if player.Status == 'Resting' then
        gFunc.EquipSet('Rest')
    elseif player.Status == 'Engaged' then
        gFunc.EquipSet('Tp')

        if player.HPP <= 75 and player.TP <= 1000 then
            gFunc.Equip('Ring1', "Fencer's Ring")
        end
    end

    if gSettings.SoloMode then
        gFunc.EquipSet('Solo')
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
    gFunc.Equip('Head', "Warlock's Chapeau")
    gFunc.Equip('Body', "Duelist's Tabard")
    conserveMp(profile.Sets.Base)
end

profile.HandleMidcast = function()
    local spell = gData.GetAction()
    doMagic(spell)

    if gSettings.SoloMode then
        gFunc.Equip('Body', "Warlock's Tabard")
    end

    conserveMp(profile.Sets.Base)
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    local weaponskill = gData.GetAction()
    doSwordWs(weaponskill.Name)
    doDaggerWs(weaponskill.Name)
end

return profile
