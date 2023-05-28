require('common')
local status = gFunc.LoadFile('common/status.lua')
local EquipSlots = gData.Constants.EquipSlots

local sets = {
    Idle = {
        -- preferred stats: MP, DEF, EVA
        Main = "Fencing Degen",     -- MP+10
        Sub = nil,
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Brass Hairpin",     -- MP+10
        Neck = "Black Neckerchief", -- DEF+2
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Savage Separates",  -- DEF+18, HP+32
        Hands = "Savage Gauntlets", -- MP+16, DEF+6
        Ring1 = "San d'Orian Ring", -- DEF+1
        Ring2 = nil,

        Back = "High Brth. Mantle", -- DEF+5
        Waist = "Friar's Rope",     -- MP+5, DEF+2
        Legs = "Savage Loincloth",  -- MP+32, DEF+12
        Feet = "Savage Gaiters",    -- DEF+5, HP+16
    },
    Cast = {
        -- preferred stats: Haste, MP, EVA
        Main = "Fencing Degen",     -- MP+10
        Sub = nil,
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Brass Hairpin",     -- MP+10
        Neck = "Black Neckerchief", -- DEF+2
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = "Savage Separates",  -- DEF+18, HP+32
        Hands = "Savage Gauntlets", -- MP+16, DEF+6
        Ring1 = "San d'Orian Ring", -- DEF+1
        Ring2 = nil,

        Back = "High Brth. Mantle", -- DEF+5
        Waist = "Friar's Rope",     -- MP+5, DEF+2
        Legs = "Savage Loincloth",  -- MP+32, DEF+12
        Feet = "Savage Gaiters",    -- DEF+5, HP+16
    },
    Rest = {
        -- preferred stats: hMP
        Main = "Pilgrim's Wand",    -- hMP+2
    },
    Auto = {
        Main = "Buzzard Tuck",     -- Dmg+23, Del+224, DEX+1, Ensp+2
        Sub = "Fencing Degen",     -- Dmg+22, Del+224
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Brass Hairpin",
        Neck = "Spike Necklace",    -- STR+3, DEX+3
        Ear1 = "Beetle Earring +1", -- Atk+3
        Ear2 = "Beetle Earring +1", -- Atk+3

        Body = "Savage Separates",  -- STR+1
        Hands = "Ryl.Ftm. Gloves",  -- Atk+3
        Ring1 = "Balance Ring",     -- DEX+2
        Ring2 = "Balance Ring",     -- DEX+2

        Back = "High Brth. Mantle",
        Waist = "Tilt Belt",        -- Acc+5
        Legs = "Cmb.Cst. Slacks",   -- Atk+5
        Feet = "Savage Gaiters",    -- STR+3
    },
    MaxMp = {
        -- preferred stats: MP
        Main = "Fencing Degen",     -- MP+10
        Sub = nil,
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- MP+3

        Head = "Brass Hairpin",     -- MP+10
        Neck = nil,
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets", -- MP+16
        Ring1 = nil,
        Ring2 = nil,

        Back = nil,
        Waist = "Friar's Rope",     -- MP+5
        Legs = "Savage Loincloth",  -- MP+32
        Feet = nil,
    },
    Stealth = {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Feet = "Dream Boots +1",
    },
    EnfeebInt = {
        -- preferred stats: Enfeeb, INT, Enm-
        Main = "Fencing Degen",     -- Enfeeb+3, INT+3
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "displaced",
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = nil,

        Body = "Ryl.Ftm. Tunic",    -- INT+1
        Hands = nil,
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Wizard's Belt",    -- INT+2
        Legs = nil,
        Feet = nil,
    },
    EnfeebMnd = {
        -- preferred stats: Enfeeb, MND, Enm-
        Main = "Fencing Degen",     -- Enfeeb+3, MND+3
        Sub = "Yew Wand +1",        -- MND+4
        Range = nil,
        Ammo = nil,

        Head = nil,
        Neck = "Justice Badge",     -- MND+3
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Friar's Rope",     -- MND+1
        Legs = "Savage Loincloth",  -- MND+1
        Feet = nil,
    },
    Shadows = {
        -- preferred stats: SID, Parry, Eva
        Main = nil,
        Sub = nil,
        Range = nil,
        Ammo = nil,

        Head = nil,
        Neck = nil,
        Ear1 = "Drone Earring",     -- AGI+3
        Ear2 = "Drone Earring",     -- AGI+3

        Body = nil,
        Hands = nil,
        Ring1 = nil,
        Ring2 = nil,

        Back = nil,
        Waist = nil,
        Legs = "Cmb.Cst. Slacks",   -- Eva+5
        Feet = nil,
    },
    NinjutsuAcc = {
        -- preferred stats: Ninjutsu, mAcc, INT
    },
    NinjutsuPot = {
        -- preferred stats: Ninjutsu, INT, mAcc
    },
    Stoneskin = {
        -- preferred stats: MND, Enhancing
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = "displaced",
        Ammo = "Hedgehog Bomb",

        Head = nil,
        Neck = "Justice Badge",     -- MND+3
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets", -- MND+2
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Friar's Rope",     -- MND+1
        Legs = "Savage Loincloth",  -- MND+1
        Feet = nil,
    },
    Heal = {
        -- preferred stats: Cure%, MND, Enm-, VIT, Healing
        Main = "Yew Wand +1",       -- MND+4
        Sub = "Yew Wand +1",        -- MND+4
        Range = nil,
        Ammo = nil,

        Head = nil,
        Neck = "Justice Badge",     -- MND+3
        Ear1 = nil,
        Ear2 = nil,

        Body = nil,
        Hands = "Savage Gauntlets", -- MND+2, VIT+4
        Ring1 = "Saintly Ring",     -- MND+2
        Ring2 = "Saintly Ring",     -- MND+2

        Back = "White Cape",        -- MND+2
        Waist = "Friar's Rope",     -- MND+1
        Legs = "Savage Loincloth",  -- MND+1
        Feet = nil,
    },
    Nuke = {
        -- preferred stats: MAB, INT, Ele, Enm-
        Main = "Yew Wand +1",       -- INT+4
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "displaced",
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = nil,

        Body = "Ryl.Ftm. Tunic",    -- INT+1
        Hands = nil,
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Wizard's Belt",    -- INT+2
        Legs = nil,
        Feet = nil,
    },
    Drain = {
        -- preferred stats: Dark, MP, mAcc, INT, Enm-
        Main = "Yew Wand +1",       -- INT+4
        Sub = "Yew Wand +1",        -- INT+4
        Range = "displaced",
        Ammo = "Morion Tathlum",    -- INT+1

        Head = "displaced",
        Neck = "Black Neckerchief", -- INT+1
        Ear1 = "Cunning Earring",   -- INT+1
        Ear2 = nil,

        Body = "Ryl.Ftm. Tunic",    -- INT+1
        Hands = nil,
        Ring1 = "Eremite's Ring",   -- INT+2
        Ring2 = "Eremite's Ring",   -- INT+2

        Back = "Black Cape",        -- INT+2
        Waist = "Wizard's Belt",    -- INT+2
        Legs = nil,
        Feet = nil,
    },
}

local settings = {
    IsRested = false,
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    gFunc.EquipSet(sets.Idle)

    if status.IsAttacking(player) then
        gFunc.EquipSet(sets.Auto)
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
    elseif status.IsShadows(spell) then
        gFunc.EquipSet(sets.Shadows)
    elseif status.IsNuke(spell) then
        gFunc.EquipSet(sets.Nuke)
    elseif status.IsEnfeebMnd(spell) then
        gFunc.EquipSet(sets.EnfeebMnd)
    elseif status.IsEnfeebInt(spell) then
        gFunc.EquipSet(sets.EnfeebInt)
    elseif status.IsPotencyNinjutsu(spell) then
        gFunc.EquipSet(sets.NinjutsuPot)
    elseif status.IsAccuracyNinjutsu(spell) then
        gFunc.EquipSet(sets.NinjutsuAcc)
    else
        gFunc.EquipSet(sets.Cast)
    end
end

return {
    Sets = sets,
    OnLoad = nil,
    OnUnload = nil,
    HandleCommand = nil,
    HandleDefault = handleDefault,
    HandleAbility = handleAbility,
    HandleItem = handleItem,
    HandlePrecast = nil,
    HandleMidcast = handleMidcast,
    HandlePreshot = nil,
    HandleMidshot = nil,
    HandleWeaponskill = nil,
}
