require('common')
local noop = function() end
local chat = require('chat')
local chatMgr = AshitaCore:GetChatManager()

---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')
---@module 'common.status'
local Status = gFunc.LoadFile('common/status.lua')

local settings = {
    Subjob = 'NON',
    MeleeSet = 'Dps',
    TreasureHunter = false,
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = "Seething Bomblet +1",

        Head  = "Mummu Bonnet +2",
        Body  = "Mummu Jacket +2",
        Hands = "Mummu Wrists +2",
        Legs  = "Mummu Kecks +2",
        Feet  = "Mummu Gamash. +2",

        Neck  = "Sanctity Necklace",
        Ear1  = "Brutal Earring",
        Ear2  = "Skulker's Earring",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
        Back  = "Toutatis's Cape",
        Waist = "Sailfi Belt +1",
    },
    TreasureHunter = Equip.NewSet {
        Legs  = "Herculean Trousers",
    },
    Melee = {
        Dt = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Skulker's Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Mummu Ring",
            Back  = "Toutatis's Cape",
            Waist = "Sailfi Belt +1",
        },
        Dps = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Skulker's Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Mummu Ring",
            Back  = "Toutatis's Cape",
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Ring1 = "Weather. Ring",
            Ring2 = "Lebeche Ring",
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Skulker's Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = "Toutatis's Cape",
            Waist = "Sailfi Belt +1",
        },
        ['Aeolian Edge'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Herculean Vest",
            Hands = "Herculean Gloves",
            Legs  = "Herculean Trousers",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Friomisi Earring",
            Ring1 = "Shiva Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = "Toutatis's Cape",
            Waist = "Skrymir Cord",
        },
        ['Evisceration'] = Equip.NewSet {
            Ammo  = "Yetshila",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Odr Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = "Toutatis's Cape",
            Waist = "Soil Belt",
        },
        ['Exenterator'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Ear1  = "Odr Earring",
            Ear2  = "Lugra Earring +1",
            Ring1 = "Regal Ring",
            Ring2 = "Mummu Ring",
            Back  = "Toutatis's Cape",
            Waist = "Thunder Belt",
        },
        ['Savage Blade'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Skulker's Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Epona's Ring",
            Back  = "Toutatis's Cape",
            Waist = "Sailfi Belt +1",
        },
        ['Circle Blade'] = Equip.NewSet {
            Ammo  = "Seething Bomblet +1",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Ear1  = "Lugra Earring +1",
            Ear2  = "Skulker's Earring",
            Ring1 = "Regal Ring",
            Ring2 = "Epona's Ring",
            Back  = "Toutatis's Cape",
            Waist = "Sailfi Belt +1",
        },
    },
}

local function changeThotbarPalette(subjob)
    if subjob == nil or subjob == 'NON' or subjob == settings.Subjob then
        return
    end

    local thotbarCmd = '/tb palette change %s'
    chatMgr:QueueCommand(1, thotbarCmd:format(subjob))
    settings.Subjob = subjob
end

local function handleDefault()
    local player = gData.GetPlayer()

    changeThotbarPalette(player.SubJob)

    if Status.IsNewlyIdle(player) then
        Equip.Set(sets.Idle)
    elseif Status.IsAttacking(player) then
        Equip.Set(sets.Melee[settings.MeleeSet])

        if settings.TreasureHunter then
            Equip.Set(sets.TreasureHunter)
        end
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()
    local wsSet = sets.Weaponskills[ws.Name]
    local fallback = sets.Weaponskills.Base

    Equip.Set(wsSet or fallback)
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
    local spell = gData.GetAction()
    Status.currentStatus = 'Casting'
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'idle' then
        Equip.Set(sets.Idle, true)
    elseif args[1] == 'melee' and #args == 2 then
        local meleeSet = args[2]:proper()
        if T{ 'Dt', 'Dps', }:contains(meleeSet) then
            settings.MeleeSet = meleeSet
            print(chat.header(addon.name):append(chat.message('Melee set: ')):append(chat.success(meleeSet:upper())))
        end
    elseif args[1] == 'th' then
        settings.TreasureHunter = not settings.TreasureHunter

        if settings.TreasureHunter then
            print(chat.header(addon.name):append(chat.message('Treasure Hunter ')):append(chat.success('ON')))
        else
            print(chat.header(addon.name):append(chat.message('Treasure Hunter ')):append(chat.error('OFF')))
        end
    end
end

return {
    Sets              = sets,
    OnLoad            = noop,
    OnUnload          = noop,
    HandleCommand     = handleCommand,
    HandleDefault     = handleDefault,
    HandleAbility     = handleAbility,
    HandleItem        = gFunc.LoadFile('common/items.lua'),
    HandlePrecast     = handlePrecast,
    HandleMidcast     = handleMidcast,
    HandlePreshot     = noop,
    HandleMidshot     = noop,
    HandleWeaponskill = handleWeaponskill,
}
