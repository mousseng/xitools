require 'common'

local profile = {
    Sets = {
        Dodge = {
            Main = "Parrying Knife",
            Sub = "Parrying Knife",
            -- Range = "",
            -- Ammo = "",

            Head = "Erd. Headband",
            Neck = "Wing Pendant",
            Ear1 = "Drone Earring",
            Ear2 = "Drone Earring",

            Body = "Savage Separates",
            Hands = "Savage Gauntlets",
            -- Ring1 = "Reflex Ring",
            -- Ring2 = "Reflex Ring",

            Back = "High Brth. Mantle",
            -- Waist = "",
            Legs = "Savage Loincloth",
            Feet = "Savage Gaiters",
        },
        Throwing = {
            -- Main = "Archer's Knife",
            -- Sub = "Archer's Knife",
            -- Range = "",
            -- Ammo = "",

            -- Head = "Fed. Hachimaki",
            -- Neck = "Peacock Amulet",
            -- Ear1 = "",
            -- Ear2 = "",

            Body = "Savage Separates",
            Hands = "Windurstian Tekko",
            -- Ring1 = "Horn Ring",
            -- Ring2 = "Horn Ring",

            Back = "High Brth. Mantle",
            -- Waist = "",
            Legs = "Republic Subligar",
            Feet = "Savage Gaiters",
        },
        Debuffing = {
            -- Main = "Crimson Blade",
            -- Sub = "Crimson Blade",
            Range = "displaced",
            Ammo = "Morion Tathlum",

            Head = "Erd. Headband",
            -- Neck = "Ryl.Sqr. Collar",
            -- Ear1 = "Cunning Earring",
            Ear2 = "Cunning Earring",

            -- Body = "Federation Gi",
            -- Hands = "Beetle Mittens +1",
            Ring1 = "Eremite's Ring",
            Ring2 = "Eremite's Ring",

            Back = "High Brth. Mantle",
            Waist = "Wizard's Belt",
            -- Legs = "Kingdom Trousers",
            -- Feet = "Garrison Boots",
        },
        Nuking = {
            -- Main = "Crimson Blade",
            -- Sub = "Crimson Blade",
            Range = "displaced",
            Ammo = "Morion Tathlum",

            Head = "Erd. Headband",
            -- Neck = "Ryl.Sqr. Collar",
            Ear1 = "Moldavite Earring",
            Ear2 = "Cunning Earring",

            -- Body = "Federation Gi",
            -- Hands = "Beetle Mittens +1",
            Ring1 = "Eremite's Ring",
            Ring2 = "Eremite's Ring",

            Back = "High Brth. Mantle",
            Waist = "Wizard's Belt",
            -- Legs = "Kingdom Trousers",
            -- Feet = "Garrison Boots",
        },
    },
}

profile.HandleDefault = function()
    gFunc.EquipSet('Dodge')
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

    if spell.Name:startswith('Utsusemi') then
        gFunc.EquipSet('Dodge')
    elseif spell.Name:startswith('Tonko')
    or spell.Name:startswith('Monomi') then
        gFunc.Equip('Hands', "Dream Mittens +1")
    elseif spell.Name:startswith('Kurayami')
    or spell.Name:startswith('Hojo')
    or spell.Name:startswith('Jubaku') then
        gFunc.EquipSet('Debuffing')
    elseif spell.Type == 'Ninjutsu' then
        gFunc.EquipSet('Nuking')
    end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
    gFunc.EquipSet('Throwing')
end

profile.OnLoad = function() end
profile.OnUnload = function() end
profile.HandleCommand = function(args) end
profile.HandleAbility = function() end
profile.HandleWeaponskill = function() end

return profile
