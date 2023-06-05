local Const = gFunc.LoadFile('common/const.lua')
local EquipSlots = gFunc.LoadFile('common/equipSlots.lua')

local staves = {
    Light = nil,
    Dark = "Dark Staff",
    Fire = nil,
    Ice = "Ice Staff",
    Water = nil,
    Thunder = nil,
    Earth = "Earth Staff",
    Wind = nil,
}

function staves.Equip(spell)
    if staves[spell.Element] then
        gFunc.Equip(EquipSlots.Main, staves[spell.Element])
        gFunc.Equip(EquipSlots.Sub, Const.Displaced)
    end
end

return staves
