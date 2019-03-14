-- A set-style table of weaponskills that do not interact with skillchains. It
-- is keyed by the animation ID.
NonChainingSkills = {
    [8] = true,
    [36] = true,
    [37] = true,
    [79] = true,
    [80] = true,
    [87] = true,
    [89] = true,
    [143] = true,
    [149] = true,
    [150] = true,
    [230] = true,
    -- HACK: dragoon jump abilities. For some reason these are counted as
    -- weaponskills rather than abilities, in spite of appearing in darkstar's
    -- ability table.
    [204] = true,
    [209] = true,
    [214] = true,
}

-- A lookup table to find the appropriate name for a given skillchain effect.
-- The keys are an action's add_effect_message.
Resonances = {
    [0x120] = 'Light',
    [0x121] = 'Darkness',
    [0x122] = 'Gravitation',
    [0x123] = 'Fragmentation',
    [0x124] = 'Distortion',
    [0x125] = 'Fusion',
    [0x126] = 'Compression',
    [0x127] = 'Liquefaction',
    [0x128] = 'Induration',
    [0x129] = 'Reverberation',
    [0x12A] = 'Transfixion',
    [0x12B] = 'Scission',
    [0x12C] = 'Detonation',
    [0x12D] = 'Impaction',
    [0x12E] = 'Radiance',
    [0x12F] = 'Umbra'
}

-- A lookup table to find the appropriate list of burstable magic elements for
-- a given skillchain effect.
Elements = {
    Light         = 'Wind, Thunder, Fire, Light',
    Darkness      = 'Ice, Water, Earth, Dark',
    Gravitation   = 'Earth, Dark',
    Fragmentation = 'Thunder, Wind',
    Distortion    = 'Ice, Water',
    Fusion        = 'Fire, Light',
    Compression   = 'Dark',
    Liquefaction  = 'Fire',
    Induration    = 'Ice',
    Reverberation = 'Water',
    Transfixion   = 'Light',
    Scission      = 'Earth',
    Detonation    = 'Wind',
    Impaction     = 'Thunder',
    Radiance      = 'Wind, Thunder, Fire, Light',
    Umbra         = 'Ice, Water, Earth, Dark'
}

-- Enum to identify what type of display a particular chain element will need.
ChainType = {
    Unknown = 0,
    Starter = 1,
    Skillchain = 2,
    MagicBurst = 3,
    Miss = 4,
}
