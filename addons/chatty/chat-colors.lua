local bit = require('bit')

local Vecify = function(rgb)
    local a = 1
    local r = bit.band(bit.rshift(rgb, 16), 0xff) / 0xff
    local g = bit.band(bit.rshift(rgb,  8), 0xff) / 0xff
    local b = bit.band(bit.rshift(rgb,  0), 0xff) / 0xff

    return { r, g, b, a }
end

local chatColors = {
    [1] = {
        [  1] = Vecify(0xffffff),
        [  2] = Vecify(0x84ff4a),
        [  3] = Vecify(0x9291fd),
        [  4] = Vecify(0x8885da),
        [  5] = Vecify(0xff46ff),
        [  6] = Vecify(0x39d8e7),
        [  7] = Vecify(0xe6e2db),
        [  8] = Vecify(0xdc8687),
        [ 81] = Vecify(0x9d4cff),
        [106] = Vecify(0xffffd1),
    },
    [2] = {
        [  1] = Vecify(0xffffff),
        [  2] = Vecify(0xee9cb4),
        [  3] = Vecify(0xDB6F8C),
        [  4] = Vecify(0xfb8aff),
        [  5] = Vecify(0x4cffff),
        [  6] = Vecify(0x7edabf),
        [  7] = Vecify(0x9682d4),
        [  8] = Vecify(0xd4abe4),
    },
    [3] = {
        [  1] = Vecify(0xffffff),
    },
}

return chatColors
