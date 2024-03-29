local Light         = 'Light'
local Darkness      = 'Darkness'
local Distortion    = 'Distortion'
local Gravitation   = 'Gravitation'
local Fusion        = 'Fusion'
local Fragmentation = 'Fragmentation'
local Scission      = 'Scission'
local Compression   = 'Compression'
local Induration    = 'Induration'
local Reverberation = 'Reverberation'
local Impaction     = 'Impaction'
local Detonation    = 'Detonation'
local Liquefaction  = 'Liquefaction'
local Transfixion   = 'Transfixion'

local retail = {
    [144] = { name = "Fire",              attr = { Liquefaction } },
    [145] = { name = "Fire II",           attr = { Liquefaction } },
    [146] = { name = "Fire III",          attr = { Liquefaction } },
    [147] = { name = "Fire IV",           attr = { Liquefaction } },
    [148] = { name = "Fire V",            attr = { Liquefaction } },
    [149] = { name = "Blizzard",          attr = { Induration } },
    [150] = { name = "Blizzard II",       attr = { Induration } },
    [151] = { name = "Blizzard III",      attr = { Induration } },
    [152] = { name = "Blizzard IV",       attr = { Induration } },
    [153] = { name = "Blizzard V",        attr = { Induration } },
    [154] = { name = "Aero",              attr = { Detonation } },
    [155] = { name = "Aero II",           attr = { Detonation } },
    [156] = { name = "Aero III",          attr = { Detonation } },
    [157] = { name = "Aero IV",           attr = { Detonation } },
    [158] = { name = "Aero V",            attr = { Detonation } },
    [159] = { name = "Stone",             attr = { Scission } },
    [160] = { name = "Stone II",          attr = { Scission } },
    [161] = { name = "Stone III",         attr = { Scission } },
    [162] = { name = "Stone IV",          attr = { Scission } },
    [163] = { name = "Stone V",           attr = { Scission } },
    [164] = { name = "Thunder",           attr = { Impaction } },
    [165] = { name = "Thunder II",        attr = { Impaction } },
    [166] = { name = "Thunder III",       attr = { Impaction } },
    [167] = { name = "Thunder IV",        attr = { Impaction } },
    [168] = { name = "Thunder V",         attr = { Impaction } },
    [169] = { name = "Water",             attr = { Reverberation } },
    [170] = { name = "Water II",          attr = { Reverberation } },
    [171] = { name = "Water III",         attr = { Reverberation } },
    [172] = { name = "Water IV",          attr = { Reverberation } },
    [173] = { name = "Water V",           attr = { Reverberation } },
    [278] = { name = "Geohelix",          attr = { Scission },      delay=5 },
    [279] = { name = "Hydrohelix",        attr = { Reverberation }, delay=5 },
    [280] = { name = "Anemohelix",        attr = { Detonation },    delay=5 },
    [281] = { name = "Pyrohelix",         attr = { Liquefaction },  delay=5 },
    [282] = { name = "Cryohelix",         attr = { Induration },    delay=5 },
    [283] = { name = "Ionohelix",         attr = { Impaction },     delay=5 },
    [284] = { name = "Noctohelix",        attr = { Compression },   delay=5 },
    [285] = { name = "Luminohelix",       attr = { Transfixion },   delay=5 },
    [503] = { name = "Impact",            attr = { Compression } },
    [519] = { name = "Screwdriver",       attr = { Transfixion, Scission } },
    [527] = { name = "Smite of Rage",     attr = { Detonation } },
    [529] = { name = "Bludgeon",          attr = { Liquefaction } },
    [539] = { name = "Terror Touch",      attr = { Compression, Reverberation } },
    [540] = { name = "Spinal Cleave",     attr = { Scission, Detonation } },
    [543] = { name = "Mandibular Bite",   attr = { Induration } },
    [545] = { name = "Sickle Slash",      attr = { Compression } },
    [551] = { name = "Power Attack",      attr = { Reverberation } },
    [554] = { name = "Death Scissors",    attr = { Compression, Reverberation } },
    [560] = { name = "Frenetic Rip",      attr = { Induration } },
    [564] = { name = "Body Slam",         attr = { Impaction } },
    [567] = { name = "Helldive",          attr = { Transfixion } },
    [569] = { name = "Jet Stream",        attr = { Impaction } },
    [577] = { name = "Foot Kick",         attr = { Detonation } },
    [585] = { name = "Ram Charge",        attr = { Fragmentation } },
    [587] = { name = "Claw Cyclone",      attr = { Scission } },
    [589] = { name = "Dimensional Death", attr = { Transfixion, Impaction } },
    [594] = { name = "Uppercut",          attr = { Liquefaction, Impaction } },
    [596] = { name = "Pinecone Bomb",     attr = { Liquefaction } },
    [597] = { name = "Sprout Smack",      attr = { Reverberation } },
    [599] = { name = "Queasyshroom",      attr = { Compression } },
    [603] = { name = "Wild Oats",         attr = { Transfixion } },
    [611] = { name = "Disseverment",      attr = { Distortion } },
    [617] = { name = "Vertical Cleave",   attr = { Gravitation } },
    [620] = { name = "Battle Dance",      attr = { Impaction } },
    [622] = { name = "Grand Slam",        attr = { Induration } },
    [623] = { name = "Head Butt",         attr = { Impaction } },
    [628] = { name = "Frypan",            attr = { Impaction } },
    [631] = { name = "Hydro Shot",        attr = { Reverberation } },
    [638] = { name = "Feather Storm",     attr = { Transfixion } },
    [640] = { name = "Tail Slap",         attr = { Reverberation } },
    [641] = { name = "Hysteric Barrage",  attr = { Detonation } },
    [643] = { name = "Cannonball",        attr = { Fusion } },
    [650] = { name = "Seedspray",         attr = { Induration, Detonation } },
    [652] = { name = "Spiral Spin",       attr = { Transfixion } },
    [653] = { name = "Asuran Claws",      attr = { Liquefaction, Impaction } },
    [654] = { name = "Sub-zero Smash",    attr = { Fragmentation } },
    [665] = { name = "Final Sting",       attr = { Fusion } },
    [666] = { name = "Goblin Rush",       attr = { Fusion, Impaction } },
    [667] = { name = "Vanity Dive",       attr = { Transfixion, Scission } },
    [669] = { name = "Whirl of Rage",     attr = { Scission, Detonation } },
    [670] = { name = "Benthic Typhoon",   attr = { Gravitation, Transfixion } },
    [673] = { name = "Quad. Continuum",   attr = { Distortion, Scission } },
    [677] = { name = "Empty Thrash",      attr = { Compression, Scission } },
    [682] = { name = "Delta Thrust",      attr = { Liquefaction, Detonation } },
    [688] = { name = "Heavy Strike",      attr = { Fragmentation, Transfixion } },
    [692] = { name = "Sudden Lunge",      attr = { Detonation } },
    [693] = { name = "Quadrastrike",      attr = { Liquefaction, Scission, Impaction } },
    [697] = { name = "Amorphic Spikes",   attr = { Gravitation } },
    [699] = { name = "Barbed Crescent",   attr = { Distortion, Scission } },
    [704] = { name = "Paralyzing Triad",  attr = { Gravitation } },
    [706] = { name = "Glutinous Dart",    attr = { Fragmentation } },
    [709] = { name = "Thrashing Assault", attr = { Fusion } },
    [714] = { name = "Sinker Drill",      attr = { Gravitation, Reverberation } },
    [723] = { name = "Saurian Slide",     attr = { Fragmentation, Distortion } },
    [740] = { name = "Tourbillion",       attr = { Light, Fragmentation } },
    [742] = { name = "Bilgestorm",        attr = { Darkness, Gravitation } },
    [743] = { name = "Bloodrake",         attr = { Darkness, Distortion } },
    [885] = { name = "Geohelix II",       attr = { Scission },      delay=5 },
    [886] = { name = "Hydrohelix II",     attr = { Reverberation }, delay=5 },
    [887] = { name = "Anemohelix II",     attr = { Detonation },    delay=5 },
    [888] = { name = "Pyrohelix II",      attr = { Liquefaction },  delay=5 },
    [889] = { name = "Cryohelix II",      attr = { Induration },    delay=5 },
    [890] = { name = "Ionohelix II",      attr = { Impaction },     delay=5 },
    [891] = { name = "Noctohelix II",     attr = { Compression },   delay=5 },
    [892] = { name = "Luminohelix II",    attr = { Transfixion },   delay=5 },
}

return {
    retail = retail,
    horizon = retail,
}
