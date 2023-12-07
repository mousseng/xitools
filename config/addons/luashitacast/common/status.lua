local status = {
    lastStatus = 'Engaged',
    currentStatus = 'Engaged',
}

---@return boolean
function status.IsNight()
    local time = gData.GetTimestamp()
    return time.hour >= 18 or time.hour < 6
end

---@return boolean
function status.IsNightPlus()
    local time = gData.GetTimestamp()
    return time.hour >= 17 or time.hour < 7
end

---@return boolean
function status.IsHalfMp()
    local player = gData.GetPlayer()
    return player.MPP <= 50
end

---@return boolean
function status.IsItemInContainer(bagId, inv, itemId)
    local bagMax = inv:GetContainerCountMax(bagId)
    for i = 0, bagMax do
        local invSlot = inv:GetContainerItem(bagId, i)
        if invSlot ~= nil and invSlot.Count > 0 and invSlot.Id > 0 and invSlot.Id == itemId then
            return true
        end
    end

    return false
end

---@return boolean
function status.HasEquipment(item)
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local itemId = AshitaCore:GetMemoryManager():GetResourceManager():GetItemByName(item, 0).Id

    return status.IsItemInContainer( 0, inv, itemId)
        or status.IsItemInContainer( 8, inv, itemId)
        or status.IsItemInContainer(10, inv, itemId)
end

---@param env table
---@return boolean
function status.IsInSandoria(env)
    return env.Area == "Northern San d'Oria"
        or env.Area == "Southern San d'Oria"
        or env.Area == "Port San d'Oria"
        or env.Area == "Chateau d'Oraguille"
end

---@param env table
---@return boolean
function status.IsInBastok(env)
    return env.Area == "Bastok Markets"
        or env.Area == "Bastok Mines"
        or env.Area == "Metalworks"
        or env.Area == "Port Bastok"
end

---@param env table
---@return boolean
function status.IsInWindurst(env)
    return env.Area == "Windurst Woods"
        or env.Area == "Windurst Waters"
        or env.Area == "Windurst Walls"
        or env.Area == "Port Windurst"
        or env.Area == "Heavens Tower"
end

---@param player table
---@return boolean
function status.IsAttacking(player)
    return player.Status == 'Engaged'
end

---@param player table
---@return boolean
function status.IsNewlyIdle(player)
    status.lastStatus = status.currentStatus
    status.currentStatus = player.Status

    return status.lastStatus ~= status.currentStatus
        and (status.currentStatus == 'Idle' or status.currentStatus == 'Resting')
end

---@param player   table
---@param settings table
---@return boolean
function status.IsResting(player, settings)
    local isResting = player.Status == 'Resting'

    if isResting and not settings.IsRested and player.MPP >= 99 then
        settings.IsRested = true
    elseif not isResting and settings.IsRested then
        settings.IsRested = false
    end

    return isResting and not settings.IsRested
end

---@param statusName string
---@return boolean
function status.HasStatus(statusName)
    local resx = AshitaCore:GetResourceManager()
    local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs()

    local matchText = string.lower(statusName)
    for _, buff in pairs(buffs) do
        local buffString = resx:GetString("buffs.names", buff)
        if buffString and string.lower(buffString):match(matchText) then
            return true
        end
    end

    return false
end

local spells = {
    CureI = 1,
    CuragaV = 11,
    Holy = 21,
    HolyII = 22,
    Banish = 28,
    BanishV = 32,
    Banishga = 38,
    BanishgaV = 42,
    Blink = 53,
    Stoneskin = 54,
    Slow = 56,
    Paralyze = 58,
    Silence = 59,
    Barfire = 60,
    Barwatera = 71,
    SlowII = 79,
    ParalyzeII = 80,
    Repose = 98,
    Enfire = 100,
    Enwater = 105,
    Phalanx = 106,
    PhalanxII = 107,
    Regen = 108,
    RegenII = 110,
    RegenIII = 111,
    Flash = 112,
    Invisible = 136,
    Sneak = 137,
    Fire = 144,
    FloodII = 215,
    Gravity = 216,
    GravityII = 217,
    Poison = 220,
    PoisongaV = 229,
    Burn = 235,
    Drown = 240,
    Drain = 245,
    Aspir = 246,
    DrainII = 247,
    AspirII = 248,
    BlazeSpikes = 249,
    IceSpikes = 250,
    ShockSpikes = 251,
    Blind = 254,
    Break = 255,
    Bind = 258,
    BlindII = 276,
    Addle = 286,
    Enlight = 310,
    MonomiIchi = 317,
    KatonIchi = 320,
    SuitonSan = 337,
    UtsusemiIchi = 337,
    UtsusemiNi = 338,
    UtsusemiSan = 339,
    JubakuIchi = 341,
    DokumoriSan = 352,
    TonkoIchi = 353,
    TonkoNi = 354,
    RegenIV = 477,
    RegenV = 504,
    Distract = 841,
    FrazzleII = 844,
    DrainIII = 880,
    AspirIII = 881,
    DistractIII = 882,
    FrazzleIII = 883,
    AddleII = 884,
}

---@param spell table
---@return boolean
function status.IsStealth(spell)
    return spell.Id == spells.Sneak
        or spell.Id == spells.Invisible
        or spell.Id == spells.TonkoIchi
        or spell.Id == spells.TonkoNi
        or spell.Id == spells.MonomiIchi
end

---@param spell table
---@return boolean
function status.IsDrain(spell)
    return spell.Id == spells.Drain
        or spell.Id == spells.Aspir
        or spell.Id == spells.DrainII
        or spell.Id == spells.AspirII
        or spell.Id == spells.DrainIII
        or spell.Id == spells.AspirIII
end

-- Is this spell an INT-based elemental nuke or dot?
---@param spell table
---@return boolean
function status.IsNuke(spell)
    return (spell.Id >= spells.Fire and spell.Id <= spells.FloodII)
        or (spell.Id >= spells.Burn and spell.Id <= spells.Drown)
end

---@param spell table
---@return boolean
function status.IsHeal(spell)
    return spell.Id >= spells.CureI
        and spell.Id <= spells.CuragaV
end

---@param spell table
---@return boolean
function status.IsHoly(spell)
    return spell.Id >= spells.Holy and spell.Id <= spells.HolyII
end

---@param spell table
---@return boolean
function status.IsBanish(spell)
    return (spell.Id >= spells.Banish and spell.Id <= spells.BanishV)
        or (spell.Id >= spells.Banishga and spell.Id <= spells.BanishgaV)
end

-- Is this spell non-nuke divine magic?
---@param spell table
---@return boolean
function status.IsDivine(spell)
    return spell.Id == spells.Flash
        or spell.Id == spells.Enlight
        or spell.Id == spells.Repose
end

---@param spell table
---@return boolean
function status.IsEnfeebMnd(spell)
    return spell.Id == spells.Paralyze
        or spell.Id == spells.ParalyzeII
        or spell.Id == spells.Slow
        or spell.Id == spells.SlowII
        or spell.Id == spells.Silence
        or spell.Id == spells.Addle
        or spell.Id == spells.AddleII
        or (spell.Id >= spells.Distract and spell.Id <= spells.FrazzleII)
        or spell.Id == spells.DistractIII
        or spell.Id == spells.FrazzleIII
end

---@param spell table
---@return boolean
function status.IsEnfeebInt(spell)
    return spell.Id == spells.Gravity
        or spell.Id == spells.GravityII
        or spell.Id == spells.Blind
        or spell.Id == spells.BlindII
        or spell.Id == spells.Bind
        or spell.Id == spells.Break
        or (spell.Id >= spells.Poison and spell.Id <= spells.PoisongaV)
end

---@param spell table
---@return boolean
function status.IsShadows(spell)
    return spell.Id == spells.Blink
        or spell.Id == spells.UtsusemiIchi
        or spell.Id == spells.UtsusemiNi
        or spell.Id == spells.UtsusemiSan
end

---@param spell table
---@return boolean
function status.IsPotencyNinjutsu(spell)
    return spell.Id >= spells.KatonIchi and spell.Id <= spells.SuitonSan
end

---@param spell table
---@return boolean
function status.IsAccuracyNinjutsu(spell)
    return spell.Id >= spells.JubakuIchi and spell.Id <= spells.DokumoriSan
end

---@param spell table
---@return boolean
function status.IsStoneskin(spell)
    return spell.Id == spells.Stoneskin
end

-- Is this spell affected by enhancing magic skill?
---@param spell table
---@return boolean
function status.IsEnhancement(spell)
    return (spell.Id >= spells.Barfire and spell.Id <= spells.Barwatera)
        or (spell.Id >= spells.Enfire and spell.Id <= spells.Enwater)
        or (spell.Id >= spells.BlazeSpikes and spell.Id <= spells.ShockSpikes)
        or spell.Id == spells.Phalanx
        or spell.Id == spells.PhalanxII
end

---@param spell table
---@return boolean
function status.IsRegen(spell)
    return spell.Id == spells.Regen
        or spell.Id == spells.RegenII
        or spell.Id == spells.RegenIII
        or spell.Id == spells.RegenIV
        or spell.Id == spells.RegenV
end

return status
