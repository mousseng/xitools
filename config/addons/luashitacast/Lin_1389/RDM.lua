require('common')
local noop = function() end

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local sets = {
    Idle = Equip.NewSet {
        Main = Equip.Staves.Earth,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Duelist's Chapeau",
        Neck = "Uggalepih Pendant",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Duelist's Tabard",
        Hands = "Warlock's Gloves",
        Ring1 = "Zoredonite Ring",
        Ring2 = "Sattva Ring",

        Back = "Hexerei Cape",
        Waist = "Ryl.Kgt. Belt",
        Legs = "Crimson Cuisses",
        Feet = "Duelist's Boots",
    },
    Rest = Equip.NewSet {
        Main = Equip.Staves.Dark,
        Ear1 = "Relaxing Earring",
        Body = "Errant Hpl.",
        Waist = "Duelist's Belt",
    },
    Solo = Equip.NewSet {
        Main = "Martial Anelace",
        Sub = "Joyeuse",
    },
    Auto = Equip.NewSet {
        Head = "Ogre Mask",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Assault Jerkin",
        Hands = "Warlock's Gloves",
        Ring1 = "Woodsman Ring",
        Ring2 = "Balance Ring",

        Back = "Psilos Mantle",
        Waist = "Swift Belt",
        Legs = "Duelist's Tights",
        Feet = "Ogre Ledelsens",
    },
    Weaponskill = Equip.NewSet {
        Head = "Ogre Mask",
        Neck = "Tiger Stole",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Assault Jerkin",
        Hands = "Ogre Gloves",
        Ring1 = "Woodsman Ring",
        Ring2 = "Courage Ring",

        Back = "Psilos Mantle",
        Waist = "Life Belt",
        Legs = "Duelist's Tights",
        Feet = "Ogre Ledelsens",
    },
    MaxMp = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Gold Hairpin",
        Neck = "Uggalepih Pendant",
        Ear1 = "Morion Earring",
        Ear2 = "Drone Earring",

        Body = "Duelist's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Zoredonite Ring",
        Ring2 = "Chariot Band",

        Back = "Rainbow Cape",
        Waist = "Friar's Rope",
        Legs = "Savage Loincloth",
        Feet = "Duelist's Boots",
    },
    Pdt = Equip.NewSet {
        Main = Equip.Staves.Earth,

        -- Head = "Darksteel Cap +1",
        -- Neck = "",
        -- Ear1 = "",
        -- Ear2 = "",

        -- Body = "Dst. Harness +1",
        -- Hands = "Dst. Mittens +1",
        Ring1 = "Jelly Ring",
        Ring2 = "Sattva Ring",

        Back = "Hexerei Cape",
        -- Waist = "",
        -- Legs = "Dst. Subligar +1",
        -- Feet = "Dst. Leggings +1",
    },
    Mdt = Equip.NewSet {
        -- Head = "Coral Visor +1",
        -- Neck = "Jeweled Collar",
        Ear1 = "Merman's Earring",
        -- Ear2 = "Merman's Earring",

        -- Body = "Cor. Scale Mail +1",
        -- Hands = "Coral Fng.Gnt. +1",
        -- Ring1 = "Merman's Ring",
        Ring2 = "Sattva Ring",

        Back = "Hexerei Cape",
        -- Waist = "Duelist's Belt",
        Legs = "Crimson Cuisses",
        -- Feet = "Crimson Greaves",
    },
    Bdt = Equip.NewSet {
        -- Head = "",
        -- Neck = "",
        -- Ear1 = "",
        -- Ear2 = "",

        -- Body = "",
        -- Hands = "",
        -- Ring1 = "",
        Ring2 = "Sattva Ring",

        Back = "Hexerei Cape",
        -- Waist = ""
        -- Legs = "",
        -- Feet = "",
    },
    FastCast = Equip.NewSet {
        Head = "Warlock's Chapeau",
        Body = "Duelist's Tabard",
    },
    Shadows = Equip.NewSet {
        Main = Equip.Staves.Wind,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Duelist's Chapeau",
        Neck = "Uggalepih Pendant",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Warlock's Gloves",
        Ring1 = "Reflex Ring",
        Ring2 = "Peridot Ring",

        Back = "Hexerei Cape",
        Waist = "Swift Belt",
        Legs = "Cmb.Cst. Slacks",
        Feet = "Duelist's Boots",
    },
    Stoneskin = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Duelist's Chapeau",
        Neck = "Justice Badge",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Errant Hpl.",
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "Rainbow Cape",
        Waist = "Duelist's Belt",
        Legs = "Errant Slops",
        Feet = "Duelist's Boots",
    },
    Enhancing = Equip.NewSet {
        Neck = "Enhancing Torque",
        Legs = "Warlock's Tights",
    },
    Cure = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau",
        Neck = "Harmonia's Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Savage Separates",
        Hands = "Savage Gauntlets",
        Ring1 = "Sattva Ring",
        Ring2 = "Bomb Queen Ring",

        Back = "White Cape",
        Waist = "Duelist's Belt",
        Legs = "Crimson Cuisses",
        Feet = "Duelist's Boots",
    },
    Heal = Equip.NewSet {
        Main = "Yew Wand +1",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Duelist's Chapeau",
        Neck = "Justice Badge",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Errant Hpl.",
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "Rainbow Cape",
        Waist = "Duelist's Belt",
        Legs = "Errant Slops",
        Feet = "Duelist's Boots",
    },
    EnfeebInt = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Duelist's Chapeau",
        Neck = "Enfeebling Torque",
        Ear1 = "Morion Earring",
        Ear2 = "Abyssal Earring",

        Body = "Warlock's Tabard",
        Hands = "Sly Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Rainbow Cape",
        Waist = "Duelist's Belt",
        Legs = "Errant Slops",
        Feet = "Wise Pigaches",
    },
    EnfeebMnd = Equip.NewSet {
        Main = "Fencing Degen",
        Sub = "Yew Wand +1",
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Duelist's Chapeau",
        Neck = "Enfeebling Torque",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Warlock's Tabard",
        Hands = "Savage Gauntlets",
        Ring1 = "Saintly Ring",
        Ring2 = "Saintly Ring",

        Back = "Rainbow Cape",
        Waist = "Duelist's Belt",
        Legs = "Errant Slops",
        Feet = "Duelist's Boots",
    },
    NinjutsuAcc = Equip.NewSet {
    },
    NinjutsuPot = Equip.NewSet {
    },
    Nuke = Equip.NewSet {
        Main = Equip.Staves.Ice,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Morion Tathlum",

        Head = "Warlock's Chapeau",
        Neck = "Uggalepih Pendant",
        Ear1 = "Moldavite Earring",
        Ear2 = "Abyssal Earring",

        Body = "Errant Hpl.",
        Hands = "Sly Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Rainbow Cape",
        Waist = "Duelist's Belt",
        Legs = "Duelist's Tights",
        Feet = "Duelist's Boots",
    },
    Drain = Equip.NewSet {
        Main = Equip.Staves.Dark,
        Sub = Equip.Special.Displaced,
        Range = Equip.Special.Displaced,
        Ammo = "Hedgehog Bomb",

        Head = "Warlock's Chapeau",
        Neck = "Uggalepih Pendant",
        Ear1 = "Morion Earring",
        Ear2 = "Abyssal Earring",

        Body = "Duelist's Tabard",
        Hands = "Sly Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "Rainbow Cape",
        Waist = "Swift Belt",
        Legs = "Errant Slops",
        Feet = "Wise Pigaches",
    },
}

local settings = {
    Tank     = false,
    Solo     = false,
    Pdt      = false,
    Mdt      = false,
    IsRested = false,
}

local function equipCureCheat(spell)
    local hpNeeded = 0
    if spell.Name == 'Cure IV' then
        hpNeeded = 400
    elseif spell.Name == 'Cure III' then
        hpNeeded = 200
    elseif spell.Name == 'Cure II' then
        hpNeeded = 100
    end

    local player = gData.GetPlayer()
    local hpMissing = player.MaxHP - player.HP

    hpNeeded = hpNeeded - hpMissing
    if hpNeeded <= 0 then
        return
    end

    -- TODO: equip HP- pieces to exceed hpNeeded
end

local function handleCommand(args)
    if #args < 1 then return end

    local cmd = args[1]
    if cmd == 'solo' then
        settings.Solo = not settings.Solo
        if settings.Solo then
            Equip.Set(sets.Solo, true)
            Equip.Disable(Equip.Slots.Main)
            Equip.Disable(Equip.Slots.Sub)
            Equip.Disable(Equip.Slots.Range)
        else
            Equip.Enable(Equip.Slots.Main)
            Equip.Enable(Equip.Slots.Sub)
            Equip.Enable(Equip.Slots.Range)
        end
    elseif cmd == 'tank' then
        settings.Tank = not settings.Tank
    elseif cmd == 'pdt' then
        settings.Pdt = not settings.Pdt
        if settings.Pdt then settings.Mdt = false end
    elseif cmd == 'mdt' then
        settings.Mdt = not settings.Mdt
        if settings.Mdt then settings.Pdt = false end
    end
end

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    Equip.Set(sets.Idle)

    if settings.Pdt then
        Equip.Set(sets.Pdt)
    elseif settings.Mdt then
        Equip.Set(sets.Mdt)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Auto)

        if player.HPP <= 75 and player.TP < 1000 and Status.HasStatus('en%a+') then
            Equip.Ring2("Fencer's Ring")
        end
    end

    if Status.IsInSandoria(env) then
        Equip.Body("Kingdom Aketon")
    elseif Status.IsInBastok(env) then
        Equip.Body("Republic Aketon")
    elseif Status.IsInWindurst(env) then
        Equip.Body("Federation Aketon")
    end

    if Status.IsResting(player, settings) then
        Equip.Set(sets.Rest)
    end
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name == 'Convert' then
        Equip.LockSet(sets.MaxMp, 10)
    end
end

local function handlePrecast()
    local spell = gData.GetAction()
    local target = gData.GetTarget()

    if settings.Tank and target.Name == 'Lin' then
        equipCureCheat(spell)
    end

    Equip.Set(sets.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if Status.IsStealth(spell) then
        Equip.Stealth()
    elseif Status.IsHeal(spell) then
        if settings.Tank then
            Equip.Set(sets.Cure)
            Equip.Obi(spell)
        else
            Equip.Set(sets.Heal)
            Equip.Obi(spell)
        end
    elseif Status.IsDrain(spell) then
        Equip.Set(sets.Drain)
        Equip.Obi(spell)
    elseif Status.IsStoneskin(spell) then
        Equip.Set(sets.Stoneskin)
    elseif Status.IsEnhancement(spell) then
        Equip.Set(sets.Enhancing)
    elseif Status.IsShadows(spell) then
        Equip.Set(sets.Shadows)
    elseif Status.IsNuke(spell) then
        Equip.Set(sets.Nuke)
        Equip.Staff(spell)
        Equip.Obi(spell)
    elseif Status.IsEnfeebMnd(spell) then
        Equip.Set(sets.EnfeebMnd)
        Equip.Staff(spell)
        Equip.Obi(spell)
    elseif Status.IsEnfeebInt(spell) then
        Equip.Set(sets.EnfeebInt)
        Equip.Staff(spell)
        Equip.Obi(spell)
    elseif Status.IsPotencyNinjutsu(spell) then
        Equip.Set(sets.NinjutsuPot)
        Equip.Staff(spell)
        Equip.Obi(spell)
    elseif Status.IsAccuracyNinjutsu(spell) then
        Equip.Set(sets.NinjutsuAcc)
        Equip.Staff(spell)
        Equip.Obi(spell)
    else
        Equip.Set(sets.Idle)
        Equip.Main(Equip.Staves.Wind)
        Equip.Sub(Equip.Special.Displaced)
        if settings.Pdt then
            Equip.Set(sets.Pdt)
        elseif settings.Mdt then
            Equip.Set(sets.Mdt)
        end
    end
end

local function handleWeaponskill()
    Equip.Set(sets.Weaponskill)
end

return {
    Sets = sets,
    OnLoad = noop,
    OnUnload = noop,
    HandleCommand = handleCommand,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = gFunc.LoadFile('common/items.lua'),
    HandlePrecast = handlePrecast,
    HandleMidcast = handleMidcast,
    HandlePreshot = noop,
    HandleMidshot = noop,
    HandleWeaponskill = handleWeaponskill,
}
