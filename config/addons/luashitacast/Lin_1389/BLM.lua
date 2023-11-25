require 'common'

local profile = {
    Sets = {
        Base = {
            Main = "Yew Wand +1",
            Sub = "Yew Wand +1",
            -- Range =,
            Ammo = "Morion Tathlum",
            Head = "Gold Hairpin",
            Body = "Seer's Tunic",
            Hands = "Seer's Mitts +1",
            Legs = "Seer's Slacks",
            Feet = "Savage Gaiters",
            Neck = "Black Neckerchief",
            Waist = "Friar's Rope",
            Ear1 = "Morion Earring",
            Ear2 = "Cunning Earring",
            Ring1 = "San d'Orian Ring",
            Ring2 = "Chariot Band",
            Back = "Black Cape",
        },
        Rest = {
            Main = "Pilgrim's Wand",
        },
        Int = {
            Main = "Yew Wand +1",
            Sub = "Yew Wand +1",
            -- Range =,
            Ammo = "Morion Tathlum",
            Head = "Seer's Crown +1",
            Body = "Seer's Tunic",
            Hands = "Seer's Mitts +1",
            Legs = "Seer's Slacks",
            -- Feet =,
            Neck = "Black Neckerchief",
            Waist = "Shaman's Rope",
            Ear1 = "Morion Earring",
            Ear2 = "Cunning Earring",
            Ring1 = "Eremite's Ring",
            Ring2 = "Eremite's Ring",
            Back = "Black Cape",
        },
        Mnd = {
            Main = "Yew Wand +1",
            Sub = "Yew Wand +1",
            -- Range =,
            -- Ammo =,
            -- Head =,
            -- Body =,
            Hands = "Savage Gauntlets",
            Legs = "Savage Loincloth",
            Feet = "Warlock's Boots",
            Neck = "Justice Badge",
            Waist = "Friar's Rope",
            -- Ear1 =,
            -- Ear2 =,
            Ring1 = "Saintly Ring",
            Ring2 = "Saintly Ring",
            Back = "White Cape",
        },
    },
}

profile.OnLoad = function()
    gSettings.AllowAddSet = true
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
end

profile.HandleDefault = function()
    local player = gData.GetPlayer()

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
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile
