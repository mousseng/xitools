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
    Default = {
        Main = "Ternion Dagger +1",
        Sub  = "Nibiru Knife",
        -- Ammo = "Date Shuriken",
    },
    Capes = {
        -- Auto  = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+20', [2] = '"Dbl.Atk."+10', } },
        -- StrWs = { Name = "Andartia's Mantle", Augment = { [1] = 'STR+30', [2] = 'Weapon skill damage +10%', } },
        -- DexWs = { Name = "Andartia's Mantle", Augment = { [1] = 'DEX+29', [2] = 'Weapon skill damage +10%', } },
        -- AgiWs = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+30', [2] = 'Weapon skill damage +10%', } },
        -- Cast  = { Name = "Andartia's Mantle", Augment = { [1] = 'AGI+30', [2] = 'Fast Cast +10%', } },
        -- Nuke  = { Name = "Andartia's Mantle", Augment = { [1] = 'INT+30', [2] = '"Mag. Atk. Bns."+9' } },
    },
    -- Interface = {
    --     Flags = ImGuiWindowFlags_NoDecoration,
    --     IsOpen = { true },
    -- },
}

local sets = {
    Idle = Equip.NewSet {
        Neck  = "Sanctity Necklace",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
    },
    TreasureHunter = Equip.NewSet {
        Legs  = "Herculean Trousers",
    },
    Melee = {
        Dps = Equip.NewSet {
            -- Ammo  = "Seething Bomblet",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Regal Ring",
            Back  = "Buquwik Cape",
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Hands = "Taeon Gloves",
            Ring1 = "Weather. Ring",
        },
        Shadows = Equip.NewSet {
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            -- Ammo  = "Seething Bomblet",

            Head  = "Mummu Bonnet +2",
            Body  = "Mummu Jacket +2",
            Hands = "Mummu Wrists +2",
            Legs  = "Mummu Kecks +2",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Regal Ring",
            Back  = "Buquwik Cape",
            Waist = "Sailfi Belt +1",
        },
        ['Aeolian Edge'] = Equip.NewSet {
            -- Ammo  = "Seething Bomblet",

            Head  = "Taeon Chapeau",
            Body  = "Herculean Vest",
            Hands = "Herculean Gloves",
            Legs  = "Herculean Trousers",
            Feet  = "Mummu Gamash. +2",

            Neck  = "Sanctity Necklace",
            Ear1  = "Hecate's Earring",
            Ear2  = "Odr Earring",
            Ring1 = "Weather. Ring",
            Ring2 = "Mephitas's Ring +1",
            Back  = "Buquwik Cape",
            Waist = "Thunder Belt",
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
    else
        Equip.Feet(sets.Idle.Feet)
    end
end

local function handleWeaponskill()
    local ws = gData.GetAction()
    local wsSet = sets.Weaponskills[ws.Name]
    local fallback = sets.Weaponskills.Base

    Equip.Set(wsSet or fallback)
end

local function handleAbility()
    local ability = gData.GetAction()

    if ability.Name:match('Samba') then
        Equip.Head("Dancer's Tiara")
    elseif ability.Name:match('Waltz') then
        Equip.Body("Dancer's Casaque")
    -- elseif ability.Name:match('Step') then
    --     Equip.Hands("Dancer's Bangles")
    elseif ability.Name:match('Jig') then
        Equip.Feet("Dancer's Toe Shoes")
    end
end

local function handlePrecast()
    Equip.Set(sets.Magic.FastCast)
end

local function handleMidcast()
end

local function handleCommand(args)
    if #args == 0 then
        return
    end

    if args[1] == 'idle' then
        Equip.Set(sets.Idle, true)
    elseif args[1] == 'melee' and #args == 2 then
        local meleeSet = args[2]:proper()
        if T{ 'Dps' }:contains(meleeSet) then
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
    elseif args[1] == 'gear' then
        Equip.Main(settings.Default.Main, true)
        Equip.Sub(settings.Default.Sub, true)
        Equip.Ammo(settings.Default.Ammo, true)
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
