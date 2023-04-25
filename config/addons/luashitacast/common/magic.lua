local spells = {
    Holy = 21,
    HolyII = 22,
    Banish = 28,
    BanishV = 32,
    Banishga = 38,
    BanishgaV = 42,
    Fire = 144,
    FloodII = 215,
    Drain = 245,
    AspirII = 248,
    KatonIchi = 320,
    SuitonSan = 337,
    Invisible = 136,
    UtsusemiIchi = 337,
    UtsusemiSan = 339,
    Sneak = 137,
    MonomiIchi = 317,
    TonkoIchi = 352,
    TonkoNi = 353,
}

local staves = {
    Dark = "Dark Staff",
}

local function between(val, min, max)
    return val >= min and val <= max
end

local function IsNuke(spell)
    return between(spell.Id, spells.Fire, spells.FloodII)
        or between(spell.Id, spells.Drain, spells.AspirII)
        or between(spell.Id, spells.KatonIchi, spells.SuitonSan)
        or between(spell.Id, spells.Holy, spells.HolyII)
        or between(spell.Id, spells.Banish, spells.BanishV)
        or between(spell.Id, spells.Banishga, spells.BanishgaV)
end

local function IsSneak(spell)
    return spell.Id == spells.Sneak
        or spell.Id == spells.MonomiIchi
end

local function IsInvis(spell)
    return spell.Id == spells.Invisible
        or spell.Id == spells.TonkoIchi
        or spell.Id == spells.TonkoNi
end

local function HandleSpell(spell)
    local player = gData.GetPlayer()

    if spell.Type == 'White Magic' then
        gFunc.EquipSet('Mnd')
    elseif spell.Type == 'Black Magic' then
        gFunc.EquipSet('Int')
    end

    if spell.Type == 'Ninjutsu' then
        if between(spell.Id, spells.UtsusemiIchi, spells.UtsusemiSan) then
            gFunc.EquipSet('Eva')
            gFunc.EquipSet('Interrupt')
        else
            gFunc.EquipSet('Int')
        end
    end

    if spell.Skill == 'Healing Magic' then
        gFunc.EquipSet('Healing')
    elseif spell.Skill == 'Elemental Magic' then
        gFunc.EquipSet('Elemental')
    elseif spell.Skill == 'Enhancing Magic' then
        gFunc.EquipSet('Enhancing')
    elseif spell.Skill == 'Enfeebling Magic' then
        gFunc.EquipSet('Enfeebling')
    elseif spell.Skill == 'Divine Magic' then
        gFunc.EquipSet('Divine')
    elseif spell.Skill == 'Dark Magic' then
        gFunc.EquipSet('Dark')
    end

    if IsNuke(spell) then
        gFunc.EquipSet('Mab')
    end

    if player.MainJobSync > 50 and staves[spell.Element] then
        gFunc.Equip('Main', staves[spell.Element])
        gFunc.Equip('Sub', 'displaced')
    end

    if IsSneak(spell) then
        gFunc.Equip('Back', "Skulker's Cape")
        gFunc.Equip('Feet', "Dream Boots +1")
    elseif IsInvis(spell) then
        gFunc.Equip('Back', "Skulker's Cape")
        gFunc.Equip('Hands', "Dream Mittens +1")
    end
end

return HandleSpell
