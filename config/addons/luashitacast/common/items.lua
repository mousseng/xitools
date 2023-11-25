---@module 'common.equip'
local Equip = gFunc.LoadFile('common/equip.lua')

local items = {
    OrangeJuice = 4422,
    PrismPowder = 4164,
    SilentOil = 4165,
}

return function()
    local item = gData.GetAction()
    if item.Id == items.OrangeJuice then
        Equip.Legs("Dream Pants +1")
    elseif item.Id == items.PrismPowder or item.Id == items.SilentOil then
        Equip.Stealth()
    end
end
