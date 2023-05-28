require('common')
local status = gFunc.LoadFile('common/status.lua')
local EquipSlots = gData.Constants.EquipSlots

local sets = {
    Idle = {
        Main = "Zushio",
        Sub = "Anju",
        Range = "displaced",
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Nanban Kariginu",
        Hands = "Windurstian Tekko",
        Ring1 = "San d'Orian Ring",
        Ring2 = "Chariot Band",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Auto = {
        Range = "displaced",
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Spike Necklace",
        Ear1 = "Beetle Earring +1",
        Ear2 = "Beetle Earring +1",

        Body = "Nanban Kariginu",
        Hands = "Windurstian Tekko",
        Ring1 = "Balance Ring",
        Ring2 = "Balance Ring",

        Back = "High Brth. Mantle",
        Waist = "Tilt Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Throw = {
        Ring1 = "Horn Ring",
        Ring2 = "Horn Ring",
    },
    Stealth = {
        Hands = "Dream Mittens +1",
        Back = "Skulker's Cape",
        Waist = "Swift Belt",
        Feet = "Dream Boots +1",
    },
    Shadows = {
        Range = "displaced",
        Ammo = "Pebble",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Drone Earring",
        Ear2 = "Drone Earring",

        Body = "Nanban Kariginu",
        Hands = "Savage Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "High Brth. Mantle",
        Waist = "Friar's Rope",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
    Ninjutsu = {
        Range = "displaced",
        Ammo = "Morion Tathlum",

        Head = "Erd. Headband",
        Neck = "Ryl.Sqr. Collar",
        Ear1 = "Cunning Earring",
        Ear2 = "Drone Earring",

        Body = "Nanban Kariginu",
        Hands = "Savage Gauntlets",
        Ring1 = "Eremite's Ring",
        Ring2 = "Eremite's Ring",

        Back = "High Brth. Mantle",
        Waist = "Wizard's Belt",
        Legs = "Republic Subligar",
        Feet = "Fed. Kyahan",
    },
}

local function handleDefault()
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()

    gFunc.EquipSet(sets.Idle)

    if status.IsAttacking(player) and status.HasStatus('Copy Image') then
        gFunc.EquipSet(sets.Auto)
    elseif status.IsAttacking(player) then
        gFunc.EquipSet(sets.Shadows)
    end

    if status.IsInSandoria(env) then
        gFunc.Equip(EquipSlots.Body, "Kingdom Aketon")
    elseif status.IsInBastok(env) then
        gFunc.Equip(EquipSlots.Body, "Republic Aketon")
    elseif status.IsInWindurst(env) then
        gFunc.Equip(EquipSlots.Body, "Federation Aketon")
    end
end

local function handleMidshot()
    gFunc.EquipSet(sets.Throw)
end

local function handleMidcast()
    local spell = gData.GetAction()

    if status.IsStealth(spell) then
        gFunc.EquipSet(sets.Stealth)
    elseif status.IsShadows(spell) or status.IsDrain(spell) then
        gFunc.EquipSet(sets.Shadows)
    elseif status.IsNuke(spell) or status.IsPotencyNinjutsu(spell) or status.IsAccuracyNinjutsu(spell) then
        gFunc.EquipSet(sets.Ninjutsu)
    end
end

local function handleWeaponskill()
    local weaponskill = gData.GetAction().Name

    if weaponskill == 'Blade: Teki'
    or weaponskill == 'Blade: To' then
        gFunc.EquipSet(sets.Ninjutsu)
    end
end

return {
    Sets = sets,
    OnLoad = nil,
    OnUnload = nil,
    HandleCommand = nil,
    HandleDefault = handleDefault,
    HandleAbility = nil,
    HandleItem = nil,
    HandlePrecast = nil,
    HandlePreshot = nil,
    HandleMidcast = handleMidcast,
    HandleMidshot = handleMidshot,
    HandleWeaponskill = handleWeaponskill,
}
