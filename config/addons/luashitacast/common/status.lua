local function IsInSandoria(env)
    return env.Area == "Northern San d'Oria"
        or env.Area == "Southern San d'Oria"
        or env.Area == "Port San d'Oria"
        or env.Area == "Chateau d'Oraguille"
end

local function IsInBastok(env)
    return env.Area == "Bastok Markets"
        or env.Area == "Bastok Mines"
        or env.Area == "Metalworks"
        or env.Area == "Port Bastok"
end

local function IsInWindurst(env)
    return env.Area == "Windurst Woods"
        or env.Area == "Windurst Waters"
        or env.Area == "Windurst Walls"
        or env.Area == "Port Windurst"
        or env.Area == "Heavens Tower"
end

local function IsAttacking(player)
    return player.Status == 'Engaged'
end

local function IsResting(player, settings)
    local isResting = player.Status == 'Resting'

    if isResting and not settings.Rested and player.MPP >= 99 then
        settings.Rested = true
    elseif not isResting and settings.Rested then
        settings.Rested = false
    end

    return isResting and not settings.Rested
end

local function HasStatus(status)
    local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs()

    local matchText = string.lower(status)
    for _, buff in pairs(buffs) do
        local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff)
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
    Enfire = 100,
    Enwater = 105,
    Phalanx = 106,
    PhalanxII = 107,
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
    Bind = 258,
    BlindII = 276,
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
}

local function IsStealth(spell)
    return spell.Id == spells.Sneak
        or spell.Id == spells.Invisible
        or spell.Id == spells.TonkoIchi
        or spell.Id == spells.TonkoNi
        or spell.Id == spells.MonomiIchi
end

local function IsDrain(spell)
    return spell.Id == spells.Drain
        or spell.Id == spells.Aspir
        or spell.Id == spells.DrainII
        or spell.Id == spells.AspirII
end

local function IsNuke(spell)
    return (spell.Id >= spells.Fire and spell.Id <= spells.FloodII)
        or (spell.Id >= spells.Burn and spell.Id <= spells.Drown)
end

local function IsHeal(spell)
    return spell.Id >= spells.CureI
        and spell.Id <= spells.CuragaV
end

local function IsEnfeebMnd(spell)
    return spell.Id == spells.Paralyze
        or spell.Id == spells.ParalyzeII
        or spell.Id == spells.Slow
        or spell.Id == spells.SlowII
        or spell.Id == spells.Silence
end

local function IsEnfeebInt(spell)
    return spell.Id == spells.Gravity
        or spell.Id == spells.GravityII
        or spell.Id == spells.Blind
        or spell.Id == spells.BlindII
        or spell.Id == spells.Bind
        or (spell.Id >= spells.Poison and spell.Id <= spells.PoisongaV)
end

local function IsShadows(spell)
    return spell.Id == spells.Blink
        or spell.Id == spells.UtsusemiIchi
        or spell.Id == spells.UtsusemiNi
        or spell.Id == spells.UtsusemiSan
end

local function IsPotencyNinjutsu(spell)
    return spell.Id >= spells.KatonIchi and spell.Id <= spells.SuitonSan
end

local function IsAccuracyNinjutsu(spell)
    return spell.Id >= spells.JubakuIchi and spell.Id <= spells.DokumoriSan
end

local function IsStoneskin(spell)
    return spell.Id == spells.Stoneskin
end

local function IsEnhancement(spell)
    return (spell.Id >= spells.Barfire and spell.Id <= spells.Barwatera)
        or (spell.Id >= spells.Enfire and spell.Id <= spells.Enwater)
        or (spell.Id >= spells.BlazeSpikes and spell.Id <= spells.ShockSpikes)
        or spell.Id == spells.Phalanx
        or spell.Id == spells.PhalanxII
end

return {
    -- player stuff
    HasStatus = HasStatus,
    IsAttacking = IsAttacking,
    IsResting = IsResting,
    IsInBastok = IsInBastok,
    IsInSandoria = IsInSandoria,
    IsInWindurst = IsInWindurst,
    -- action stuff
    IsStealth = IsStealth,
    IsDrain = IsDrain,
    IsNuke = IsNuke,
    IsHeal = IsHeal,
    IsEnfeebMnd = IsEnfeebMnd,
    IsEnfeebInt = IsEnfeebInt,
    IsShadows = IsShadows,
    IsPotencyNinjutsu = IsPotencyNinjutsu,
    IsAccuracyNinjutsu = IsAccuracyNinjutsu,
    IsStoneskin = IsStoneskin,
    IsEnhancement = IsEnhancement,
}
