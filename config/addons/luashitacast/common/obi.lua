local EquipSlots = gFunc.LoadFile('common/equipSlots.lua')

local obi = {
    Light = nil,
    Dark = nil,
    Fire = nil,
    Ice = nil,
    Water = nil,
    Thunder = nil,
    Earth = nil,
    Wind = nil,
}

function obi.Equip(spell)
    local env = gData.GetEnvironment()
    if obi[spell.Element]
    and (env.WeatherElement == spell.Element or env.DayElement == spell.Element) then
        gFunc.Equip(EquipSlots.Waist, obi[spell.Element])
    end
end

return obi
