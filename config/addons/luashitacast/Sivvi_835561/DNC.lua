local profile = {
    Sets = {
        Base = {
            Range = "War Hoop",
            -- Ammo = "",
            Head = "Espial Cap",
            Body = "Espial Gambison",
            Hands = "Espial Bracers",
            Legs = "Espial Hose",
            Feet = "Espial Socks",
            Neck = "Peacock Amulet",
            Waist = "Vanguard Belt",
            Ear1 = "Bloodbead Earring",
            Ear2 = "Reraise Earring",
            Ring1 = "Warp Ring",
            -- Ring2 = "Empress Band",
            Back = "Smilodon Mantle",
        },
        Tp = {
            Ear1 = "Allegro Earring",
            Ear2 = "Megasco Earring",
            Ring1 = "Enlivened Ring",
            Ring2 = "Vehemence Ring",
        },
    }
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
    gFunc.EquipSet(profile.Sets.Base)
    if player.Status == 'Engaged' then
        gFunc.EquipSet(profile.Sets.Tp)
    end
end

profile.HandleAbility = function()
    local ability = gData.GetAction()
    if ability.Name:contains('Samba')
    or ability.Name:contains('Waltz') then
        gFunc.EquipSet{
            Head = "Dancer's Tiara",
            Neck = "Dancer's Torque",
            Legs = "Dancer's Tights",
            Waist = "Corsette",
        }
    end
end

profile.HandleItem = function()
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
    local ws = gData.GetAction()

    if ws.Name == 'Viper Bite' then
        -- DEX 100%
        gFunc.EquipSet{
            Neck = "Dancer's Torque",
        }
    elseif ws.Name == 'Dancing Edge' then
        -- DEX 40% / CHR 40%
        gFunc.EquipSet{
            Neck = "Dancer's Torque",
            Waist = "Corsette",
        }
    elseif ws.Name == 'Shark Bite' then
        -- DEX 40% / AGI 40%
        gFunc.EquipSet{
            Neck = "Dancer's Torque",
        }
    elseif ws.Name == 'Evisceration' then
        -- DEX 50%
        gFunc.EquipSet{
            Neck = "Dancer's Torque",
        }
    end
end

return profile
