require('common')
local status = gFunc.LoadFile('common/status.lua')
local EquipSlots = gData.Constants.EquipSlots

local sets = {
    Idle = {
        Main = "Dark Staff",
        Sub = "displaced",
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Duelist's Chapeau", -- Refresh, MP+14, DEF+24
        Neck = "Uggalepih Pendant", -- MP+20
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Duelist's Tabard",  -- MP+24, DEF+45
        Hands = "Warlock's Gloves", -- MP+12, DEF+16
        Ring1 = "San d'Orian Ring", -- DEF+1
        Ring2 = "Chariot Band",     -- EXP Ring

        Back = "Psilos Mantle",     -- DEF+6
        Waist = "Ryl.Kgt. Belt",    -- DEF+5, AGI+2
        Legs = "Crimson Cuisses",   -- Move, MP+25, DEF+43
        Feet = "Duelist's Boots",   -- MP+15, DEF+15, Eva+5
    },
    Rest = {
        Main = "Dark Staff",        -- hMP+10
        Body = "Errant Hpl.",       -- hMP+5
        Waist = "Duelist's Belt",   -- hMP+4
    },
    Solo = {
        Main = "Martial Anelace",
        Sub = "Joyeuse",
    },
    AutoBal = {
        Head = "Ogre Mask",         -- Att+10
        Neck = "Spike Necklace",    -- STR+3, DEX+3
        Ear1 = "Beetle Earring +1", -- Att+3
        Ear2 = "Beetle Earring +1", -- Att+3

        Body = "Assault Jerkin",    -- Att+16
        Hands = "Warlock's Gloves", -- DEX+4
        Ring1 = "Balance Ring",     -- DEX+2
        Ring2 = "Balance Ring",     -- DEX+2

        Back = "Psilos Mantle",     -- Att+12, Acc+1
        Waist = "Tilt Belt",        -- Acc+5
        Legs = "Duelist's Tights",  -- DEX+5
        Feet = "Ogre Ledelsens",    -- Att+10
    },
    AutoDmg = {
        Head = "Ogre Mask",         -- Att+10
        Neck = "Spike Necklace",    -- STR+3, DEX+3
        Ear1 = "Beetle Earring +1", -- Att+3
        Ear2 = "Beetle Earring +1", -- Att+3

        Body = "Assault Jerkin",    -- Att+16
        Hands = "Ogre Gloves",      -- STR+6
        Ring1 = "Courage Ring",     -- STR+2
        Ring2 = "Courage Ring",     -- STR+2

        Back = "Psilos Mantle",     -- Att+12, Acc+1
        Waist = "Swordbelt",        -- Att+10
        Legs = "Cmb.Cst. Slacks",   -- Att+5
        Feet = "Ogre Ledelsens",    -- Att+10
    },
    AutoAcc = {
        Head = "Ogre Mask",         -- Att+10
        Neck = "Spike Necklace",    -- STR+3, DEX+3
        Ear1 = "Beetle Earring +1", -- Att+3
        Ear2 = "Beetle Earring +1", -- Att+3

        Body = "Assault Jerkin",    -- Att+16
        Hands = "Warlock's Gloves", -- DEX+4
        Ring1 = "Balance Ring",     -- DEX+2
        Ring2 = "Balance Ring",     -- DEX+2

        Back = "Psilos Mantle",     -- Att+12, Acc+1
        Waist = "Tilt Belt",        -- Acc+5
        Legs = "Duelist's Tights",  -- DEX+5
        Feet = "Wise Pigaches",     -- Acc+2
    },
    Weaponskill = {
        Head = "Ogre Mask",         -- Att+10
        Neck = "Tiger Stole",       -- Att+5
        Ear1 = "Beetle Earring +1", -- Att+3
        Ear2 = "Beetle Earring +1", -- Att+3

        Body = "Assault Jerkin",    -- Att+16
        Hands = "Ogre Gloves",      -- STR+6
        Ring1 = "Courage Ring",     -- STR+2
        Ring2 = "Courage Ring",     -- STR+2

        Back = "Psilos Mantle",     -- Att+12, Acc+1
        Waist = "Tilt Belt",        -- Acc+5
        Legs = "Duelist's Tights",  -- DEX+5
        Feet = "Ogre Ledelsens",    -- Att+10
    },
    MaxMp = {
        Main = "Fencing Degen",     -- MP+10
        Sub = "displaced",
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Gold Hairpin",      -- MP+30
        Neck = "Uggalepih Pendant", -- MP+20
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Duelist's Tabard",  -- MP+24
        Hands = "Savage Gauntlets", -- MP+16
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "Psilos Mantle",
        Waist = "Friar's Rope",     -- MP+5
        Legs = "Savage Loincloth",  -- MP+32
        Feet = "Duelist's Boots",   -- MP+15
    },
    Pdt = {},
    Mdt = {},
    Stealth = {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Feet = "Dream Boots +1",
    },
    FastCast = {
        Head = "Warlock's Chapeau", -- FC+10
        Body = "Duelist's Tabard",  -- FC+10
    },
    EnfeebInt = {
        Main = "Yew Wand +1",       -- INT+4
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Duelist's Chapeau", -- Enfeeb+15
        Neck = "Uggalepih Pendant",
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = "Abyssal Earring",   -- INT+2

        Body = "Warlock's Tabard",  -- Enfeeb+15
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Duelist's Belt",   -- INT+4
        Legs = "Errant Slops",      -- INT+7, Enm-3
        Feet = "Wise Pigaches",     -- INT+4, Enm-1
    },
    EnfeebMnd = {
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau", -- Enfeeb+15
        Neck = "Uggalepih Pendant",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",  -- Enfeeb+15
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Duelist's Belt",   -- MND+4
        Legs = "Errant Slops",      -- MND+7, Enm-3
        Feet = "Duelist's Boots",   -- MND+4
    },
    Shadows = {
        Main = "Ryl.Grd. Fleuret",  -- Parry+5
        Sub = "displaced",
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau", -- Refresh
        Neck = "Uggalepih Pendant",
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Warlock's Tabard",  -- SID+10
        Hands = "Warlock's Gloves", -- Parry+10
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "Psilos Mantle",
        Waist = "Ryl.Kgt. Belt",    -- AGI+2
        Legs = "Cmb.Cst. Slacks",   -- Eva+5
        Feet = "Duelist's Boots",   -- Eva+5
    },
    NinjutsuAcc = {},
    NinjutsuPot = {},
    Stoneskin = {
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau",
        Neck = "Justice Badge",     -- MND+3
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Errant Hpl.",       -- MND+10
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Duelist's Belt",   -- MND+4
        Legs = "Errant Slops",      -- MND+7
        Feet = "Duelist's Boots",   -- MND+4
    },
    Enhancing = {
        Neck = "Enhancing Torque",  -- Enhancing+7
        Legs = "Warlock's Tights",  -- Enhancing+15
    },
    Heal = {
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau",
        Neck = "Justice Badge",     -- MND+3
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Errant Hpl.",       -- MND+10, Enm-3
        Hands = "Savage Gauntlets", -- MND+2, VIT+4
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Duelist's Belt",   -- MND+4
        Legs = "Errant Slops",      -- MND+7, Enm-3
        Feet = "Duelist's Boots",   -- MND+4
    },
    Nuke = {
        Main = "Ice Staff",         -- Ele+10, INT+4
        Sub = "displaced",
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Warlock's Chapeau", -- Ele+10, INT+3
        Neck = "Uggalepih Pendant", -- MAB+8
        Ear1 = "Moldavite Earring", -- MAB+5
        Ear2 = "Abyssal Earring",   -- INT+2

        Body = "Errant Hpl.",       -- INT+10, Enm-3
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Duelist's Belt",   -- INT+4
        Legs = "Duelist's Tights",  -- Ele+10
        Feet = "Duelist's Boots",   -- MAB+4
    },
    Drain = {
        Main = "Dark Staff",        -- Dark affinity
        Sub = "displaced",
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "Warlock's Chapeau", -- INT+3
        Neck = "Uggalepih Pendant",
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = "Abyssal Earring",   -- Dark+5, INT+2

        Body = "Errant Hpl.",       -- INT+10, Enm-3
        Hands = "Sly Gauntlets",    -- INT+3
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Duelist's Belt",   -- INT+4
        Legs = "Errant Slops",      -- INT+7, Enm-3
        Feet = "Wise Pigaches",     -- INT+4, Enm-1
    },
}

local settings = {
    Solo    = false,
    Pdt     = false,
    Mdt     = false,
    Convert = false,
    Rested  = false,
    TpSet   = sets.AutoAcc,
    Staves = {
        Dark = "Dark Staff",
        Ice = "Ice Staff",
    },
}

local function equipStaff(spell)
    if settings.Staves[spell.Element] then
        gFunc.Equip(EquipSlots.Main, settings.Staves[spell.Element])
        gFunc.Equip(EquipSlots.Sub, 'displaced')
    end
end

local function handleCommand(args)
    if #args < 1 then return end

    local cmd = args[1]
    if cmd == 'solo' then
        settings.Solo = not settings.Solo
        if settings.Solo then
            gFunc.ForceEquipSet(sets.Solo)
            gFunc.Disable(EquipSlots.Main)
            gFunc.Disable(EquipSlots.Sub)
            gFunc.Disable(EquipSlots.Range)
        else
            gFunc.Enable(EquipSlots.Main)
            gFunc.Enable(EquipSlots.Sub)
            gFunc.Enable(EquipSlots.Range)
        end
    elseif cmd == 'pdt' then
        settings.Pdt = not settings.Pdt
        if settings.Pdt then settings.Mdt = false end
    elseif cmd == 'mdt' then
        settings.Mdt = not settings.Mdt
        if settings.Mdt then settings.Pdt = false end
    elseif cmd == 'bal' then
        settings.TpSet = sets.AutoBal
    elseif cmd == 'acc' then
        settings.TpSet = sets.AutoAcc
    elseif cmd == 'dmg' then
        settings.TpSet = sets.AutoDmg
    end
end

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    gFunc.EquipSet(sets.Idle)

    if settings.Pdt then
        gFunc.EquipSet(sets.Pdt)
    elseif settings.Mdt then
        gFunc.EquipSet(sets.Mdt)
    elseif status.IsAttacking(player) then
        gFunc.EquipSet(settings.TpSet)

        if player.HPP <= 75 and player.TP < 1000 and status.HasStatus('en%a+') then
            gFunc.Equip(EquipSlots.Ring2, "Fencer's Ring")
        end
    end

    if status.IsInSandoria(env) then
        gFunc.Equip(EquipSlots.Body, "Kingdom Aketon")
    elseif status.IsInBastok(env) then
        gFunc.Equip(EquipSlots.Body, "Republic Aketon")
    elseif status.IsInWindurst(env) then
        gFunc.Equip(EquipSlots.Body, "Federation Aketon")
    end

    if status.IsResting(player, settings) then
        gFunc.EquipSet('Rest')
    end
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name == 'Convert' then
        gFunc.LockSet(sets.MaxMp, 10)
    end
end

local function handleItem()
    local item = gData.GetAction()
    if item.Name == 'Orange Juice' then
        gFunc.Equip(EquipSlots.Legs, "Dream Pants +1")
    end
end

local function handlePrecast()
    gFunc.EquipSet(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if status.IsStealth(spell) then
        gFunc.EquipSet(sets.Stealth)
    elseif status.IsHeal(spell) then
        gFunc.EquipSet(sets.Heal)
    elseif status.IsDrain(spell) then
        gFunc.EquipSet(sets.Drain)
    elseif status.IsStoneskin(spell) then
        gFunc.EquipSet(sets.Stoneskin)
    elseif status.IsEnhancement(spell) then
        gFunc.EquipSet(sets.Enhancing)
    elseif status.IsShadows(spell) then
        gFunc.EquipSet(sets.Shadows)
    elseif status.IsNuke(spell) then
        gFunc.EquipSet(sets.Nuke)
        equipStaff(spell)
    elseif status.IsEnfeebMnd(spell) then
        gFunc.EquipSet(sets.EnfeebMnd)
        equipStaff(spell)
    elseif status.IsEnfeebInt(spell) then
        gFunc.EquipSet(sets.EnfeebInt)
        equipStaff(spell)
    elseif status.IsPotencyNinjutsu(spell) then
        gFunc.EquipSet(sets.NinjutsuPot)
        equipStaff(spell)
    elseif status.IsAccuracyNinjutsu(spell) then
        gFunc.EquipSet(sets.NinjutsuAcc)
        equipStaff(spell)
    else
        handleDefault()
    end
end

local function handleWeaponskill()
    local weaponskill = gData.GetAction()
    gFunc.EquipSet(sets.Weaponskill)
end

return {
    Sets = sets,
    OnLoad = nil,
    OnUnload = nil,
    HandleCommand = handleCommand,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = handleItem,
    HandlePrecast = handlePrecast,
    HandleMidcast = handleMidcast,
    HandlePreshot = nil,
    HandleMidshot = nil,
    HandleWeaponskill = handleWeaponskill,
}
