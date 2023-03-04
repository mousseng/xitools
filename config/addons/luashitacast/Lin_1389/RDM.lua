require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local handleGlamour = gFunc.LoadFile('common/glamour.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')
local conserveMp = gFunc.LoadFile('common/conserveMp.lua')
local handleSwordWs = gFunc.LoadFile('common/weaponskills/sword.lua')
local handleDaggerWs = gFunc.LoadFile('common/weaponskills/dagger.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Fencing Degen", "Yew Wand +1" },
            Sub = { "Parana Shield" },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Gold Hairpin", "Brass Hairpin", "Dream Hat +1" },
            Body = { "Warlock's Tabard", "Savage Separates", "Ryl.Ftm. Tunic", "Dream Robe" },
            Hands = { "Savage Gauntlets", "Dream Mittens +1" },
            Legs = { "Savage Loincloth", "Dream Pants +1" },
            Feet = { "Warlock's Boots", "Savage Gaiters", "Dream Boots +1" },
            Neck = { "Tiger Stole" },
            Waist = { "Friar's Rope" },
            -- Ear1 = { },
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
            Head = { "Super Ribbon" },
            Body = { "Brigandine" },
            Hands = { "Warlock's Gloves", "Ryl.Ftm. Gloves" },
            Legs = { "Cmb.Cst. Slacks" },
            -- Feet = { },
            -- Neck = { },
            Waist = { "Tilt Belt" },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
            -- Back = { },
        },
        Str_Priority = {
            -- Main = { },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            Head = { "Super Ribbon" },
            Body = { "Savage Separates" },
            -- Hands = { },
            -- Legs = { },
            Feet = { "Savage Gaiters" },
            Neck = { "Spike Necklace" },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "San d'Orian Ring" },
            -- Ring2 = { },
            -- Back = { },
        },
        Dex_Priority = {
            -- Main = { },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            Head = { "Super Ribbon" },
            Body = { "Brigandine" },
            Hands = { "Warlock's Gloves" },
            -- Legs = { },
            -- Feet = { },
            Neck = { "Spike Necklace" },
            -- Waist = { },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Balance Ring" },
            Ring2 = { "Balance Ring" },
            -- Back = { },
        },
        Int_Priority = {
            Main = { "Fencing Degen", "Yew Wand +1" },
            -- Sub = { },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Warlock's Chapeau", "Super Ribbon", { Name = "displaced", Level = 10 } },
            Body = { "Ryl.Ftm. Tunic" },
            Hands = { "Sly Gauntlets" },
            -- Legs = { },
            Feet = { "Warlock's Boots" },
            Neck = { "Black Neckerchief" },
            Waist = { "Wizard's Belt" },
            -- Ear1 = { },
            Ear2 = { "Cunning Earring" },
            Ring1 = { "Eremite's Ring" },
            Ring2 = { "Eremite's Ring" },
            Back = { "Black Cape" },
        },
        Mnd_Priority = {
            Main = { "Fencing Degen", "Yew Wand +1" },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            Head = { "Super Ribbon" },
            -- Body = { },
            Hands = { "Savage Gauntlets" },
            Legs = { "Warlock's Tights", "Savage Loincloth" },
            Feet = { "Warlock's Boots" },
            Neck = { "Justice Badge" },
            Waist = { "Friar's Rope" },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "Saintly Ring" },
            Ring2 = { "Saintly Ring" },
            Back = { "White Cape" },
        },
        Glamour = {
            Head = "remove",
            Body = "Savage Separates",
            Hands = "Savage Gauntlets",
            Legs = "Warlock's Tights",
            Feet = "Warlock's Boots",
        },
        Movement = {
        },
        Solo = {
            Main = "Hornetneedle",
            Sub = "Parana Shield",
            Hands = "Warlock's Gloves",
        },
        SoloNin = {
            Main = "Dst. Baselard",
            Sub = "Hornetneedle",
            Hands = "Warlock's Gloves",
        },
        Fish = {
            Range = "Halcyon Rod",
            Ammo = "Insect Ball",
            Body = "Fsh. Tunica",
            Hands = "Fsh. Gloves",
            Legs = "Fisherman's Hose",
            Feet = "Fisherman's Boots",
        },
        Helm = {
            Body = "Field Tunica",
            Hands = "Field Gloves",
            Legs = "Field Hose",
            Feet = "Field Boots",
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
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
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

        if player.HPP <= 75 and player.TP <= 1000 then
            gFunc.Equip('Ring1', "Fencer's Ring")
        end
    elseif player.IsMoving then
        gFunc.EquipSet('Movement')
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

    if spell.Skill == 'Healing Magic' then
        gFunc.Equip('Legs', "Warlock's Tights")
    elseif spell.Skill == 'Elemental Magic' then
        gFunc.Equip('Head', "Warlock's Chapeau")
    elseif spell.Skill == 'Enhancing Magic' then
        gFunc.Equip('Legs', "Warlock's Tights")
    elseif spell.Skill == 'Enfeebling Magic' then
        gFunc.Equip('Main', "Fencing Degen")
        gFunc.Equip('Body', "Warlock's Tabard")
    end

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
    handleSwordWs(weaponskill.Name)
    handleDaggerWs(weaponskill.Name)
end

return profile
