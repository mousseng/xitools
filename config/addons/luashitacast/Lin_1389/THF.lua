require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local handleGlamour = gFunc.LoadFile('common/glamour.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local handleHelmMode = gFunc.LoadFile('common/helmMode.lua')
local handleSwordWs = gFunc.LoadFile('common/weaponskills/sword.lua')
local handleDaggerWs = gFunc.LoadFile('common/weaponskills/dagger.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Mercenary's Knife" },
            Sub = { "Beestinger" },
            -- Range = { },
            Ammo = { "Pebble" },
            Head = { "Ryl.Ftm. Bandana", "Dream Hat +1" },
            Body = { "Beetle Harness", "Brass Harness +1", "Dream Robe" },
            Hands = { "Ryl.Ftm. Gloves", "Dream Mittens +1" },
            Legs = { "Brass Subligar", "Dream Pants +1" },
            Feet = { "Beetle Leggings", "Brass Leggings", "Dream Boots +1" },
            Neck = { "Tiger Stole", "Wing Pendant" },
            Waist = { "Warrior's Belt" },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            Ring1 = { "Balance Ring", "San d'Orian Ring" },
            Ring2 = { "Balance Ring", "Chariot Band" },
            -- Back = { },
        },
        Rest_Priority = {
        },
        Tp_Priority = {
        },
        Str_Priority = {
        },
        Dex_Priority = {
        },
        Int_Priority = {
        },
        Mnd_Priority = {
        },
        Movement = {
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
    gSettings.FishMode = false
    gSettings.HelmMode = false

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /glam /lac fwd glam')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /fishe /lac fwd fish')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /helm /lac fwd helm')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 5')
end

profile.OnUnload = function()
    handleFishMode('fish off')
    handleHelmMode('helm off')

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /glam')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /fishe')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /helm')
end

profile.HandleCommand = function(args)
    if #args == 0 then return end
    handleGlamour(args)
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
