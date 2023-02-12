require 'common'
local levelSync = gFunc.LoadFile('common/levelSync.lua')
local setGlamour = gFunc.LoadFile('common/glamour.lua')
local handleSoloMode = gFunc.LoadFile('common/soloMode.lua')
local handleFishMode = gFunc.LoadFile('common/fishMode.lua')
local conserveMp = gFunc.LoadFile('common/conserveMp.lua')

local profile = {
    Sets = {
        Base_Priority = {
            Main = { "Fencing Degen", "Yew Wand" },
            Sub = { "Parana Shield" },
            -- Range = { },
            Ammo = { "Morion Tathlum" },
            Head = { "Gold Hairpin", "Brass Hairpin", "Dream Hat +1" },
            Body = { "Savage Separates", "Ryl.Ftm. Tunic", "Dream Robe" },
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
            -- Head = { },
            -- Body = { },
            Hands = { "Ryl.Ftm. Gloves" },
            -- Legs = { },
            -- Feet = { },
            -- Neck = { },
            -- Waist = { },
            Ear1 = { "Beetle Earring +1" },
            Ear2 = { "Beetle Earring +1" },
            -- Ring1 = { },
            -- Ring2 = { },
            -- Back = { },
        },
        Str_Priority = {
            -- Main = { },
            -- Sub = { },
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
            -- Main = { },
            -- Sub = { },
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
            -- Ring1 = { },
            -- Ring2 = { },
            -- Back = { },
        },
        Int_Priority = {
            Main = { "Fencing Degen", "Yew Wand" },
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
            Main = { "Fencing Degen", "Yew Wand" },
            -- Sub = { },
            -- Range = { },
            -- Ammo = { },
            -- Head = { },
            -- Body = { },
            Hands = { "Savage Gauntlets" },
            Legs = { "Warlock's Tights", "Savage Loincloth" },
            Feet = { "Warlock's Boots" },
            Neck = { "Justice Badge" },
            Waist = { "Friar's Rope" },
            -- Ear1 = { },
            -- Ear2 = { },
            Ring1 = { "San d'Orian Ring" },
            Ring2 = { "Ascetic's Ring" },
            Back = { "White Cape" },
        },
        Movement = {
        },
        Solo = {
            Main = "T.K. Army Sword",
            Sub = "Parana Shield",
        },
        SoloNin = {
            Main = "T.K. Army Sword",
            Sub = "Buzzard Tuck",
        },
        Fish = {
            Main = nil,
            Sub = nil,
            Range = "Halcyon Rod",
            Ammo = "Insect Ball",
            Head = nil,
            Body = "Fsh. Tunica",
            Hands = "Fsh. Gloves",
            Legs = "Fisherman's Hose",
            Feet = "Fisherman's Boots",
            Neck = nil,
            Waist = nil,
            Ear1 = nil,
            Ear2 = nil,
            Ring1 = nil,
            Ring2 = nil,
            Back = nil,
        },
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
    gSettings.SoloMode = false
    gSettings.FishMode = false

    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias add /fishe /lac fwd fish')
    AshitaCore:GetChatManager():QueueCommand(1, '/macro book 2')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl self on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl others on')
    AshitaCore:GetChatManager():QueueCommand(1, '/sl target on')

    setGlamour(19)
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /solo /lac fwd solo')
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias del /fishe /lac fwd fish')
end

profile.HandleCommand = function(args)
    if #args == 0 then return end
    handleSoloMode(args)
    handleFishMode(args)
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
    elseif spell.Skill == 'Enhancing Magic' then
        gFunc.Equip('Legs', "Warlock's Tights")
    elseif spell.Skill == 'Enfeebling Magic' then
        gFunc.Equip('Main', "Fencing Degen")
    end

    conserveMp(profile.Sets.Base)
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
    local weaponskill = gData.GetAction()
    local strSkills = T{ 'Flat Blade', 'Circle Blade', 'Vorpal Blade' }
    local dexSkills = T{ 'Fast Blade' }
    local mndSkills = T{ 'Requiescat' }
    local strMndSkills = T{ 'Shining Blade', 'Seraph Blade', 'Swift Blade', 'Savage Blade', 'Sanguine Blade', 'Knights of Round', 'Death Blossom' }
    local strIntSkills = T{ 'Burning Blade', 'Red Lotus Blade' }
    local hpSkills = T{ 'Spirits Within' }

    if strSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
    elseif dexSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Dex')
    elseif mndSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Mnd')
    elseif strMndSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Mnd')
    elseif strIntSkills:contains(weaponskill.Name) then
        gFunc.EquipSet('Str')
        gFunc.EquipSet('Int')
    elseif hpSkills:contains(weaponskill.Name) then
    end

    if gSettings.SoloMode then
        gFunc.EquipSet('Solo')
    end

    if gSettings.FishMode then
        gFunc.EquipSet('Fish')
    end
end

return profile
