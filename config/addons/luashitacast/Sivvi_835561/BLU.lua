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
    Default = {
        Main = "",
        Sub  = "",
        Ammo = "",
    },
}

local sets = {
    Idle = Equip.NewSet {
        Ammo  = "Sapience Orb",

        Head  = "Assim. Keffiyeh",
        Body  = "Assim. Jubbah",
        Hands = "Assim. Bazu.",
        Legs  = "Assim. Shalwar",
        Feet  = "Assim. Charuqs",

        Neck  = "Sanctity Necklace",
        Ear1  = "Brutal Earring",
        Ear2  = "Hashishin Earring",
        Ring1 = "Dim. Ring (Holla)",
        Ring2 = "Warp Ring",
        Back  = "Aptitude Mantle +1",
        Waist = "Sailfi Belt +1",
    },
    Melee = {
        Dps = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = "Assim. Keffiyeh",
            Body  = "Assim. Jubbah",
            Hands = "Assim. Bazu.",
            Legs  = "Assim. Shalwar",
            Feet  = "Assim. Charuqs",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Hashishin Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Jhakri Ring",
            Back  = "Aptitude Mantle +1",
            Waist = "Sailfi Belt +1",
        },
    },
    Magic = {
        FastCast = Equip.NewSet {
            Ammo  = "Sapience Orb",
            Ring1 = "Weather. Ring",
        },
    },
    Weaponskills = {
        Base = Equip.NewSet {
            Ammo  = "Sapience Orb",

            Head  = "Assim. Keffiyeh",
            Body  = "Assim. Jubbah",
            Hands = "Assim. Bazu.",
            Legs  = "Assim. Shalwar",
            Feet  = "Assim. Charuqs",

            Neck  = "Sanctity Necklace",
            Ear1  = "Brutal Earring",
            Ear2  = "Hashishin Earring",
            Ring1 = "Epona's Ring",
            Ring2 = "Jhakri Ring",
            Back  = "Aptitude Mantle +1",
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
        if T{ 'Dps', }:contains(meleeSet) then
            settings.MeleeSet = meleeSet
            print(chat.header(addon.name):append(chat.message('Melee set: ')):append(chat.success(meleeSet:upper())))
        end
    elseif args[1] == 'gear' then
        Equip.Main(settings.Default.Main, true)
        Equip.Sub(settings.Default.Sub, true)
        Equip.Ammo(settings.Default.Ammo, true)
    end
end

local function onLoad()
    chatMgr:QueueCommand(-1, '/addon reload blumon')
    chatMgr:QueueCommand(-1, '/addon reload blusets')
    chatMgr:QueueCommand(-1, '/addon reload blucheck')
end

local function onUnload()
    chatMgr:QueueCommand(-1, '/addon unload blumon')
    chatMgr:QueueCommand(-1, '/addon unload blusets')
    chatMgr:QueueCommand(-1, '/addon unload blucheck')
end

return {
    Sets              = sets,
    OnLoad            = onLoad,
    OnUnload          = onUnload,
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
