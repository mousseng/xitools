local function IsParadeGorgetActive()
    local player = gData.GetPlayer()
    local hpFromAccs = 0

    for i = 10, 17 do
        local slot = gEquip.GetCurrentEquip(i)
        if slot.Item ~= nil then
            local item = AshitaCore:GetResourceManager():GetItemById(slot.Id)
            local hpBonus = tonumber(item.Description[1]:match('HP([+-]%d+)')) or 0
            hpFromAccs = hpFromAccs + hpBonus
        end
    end

    local adjustedHpp = (player.MaxHP - hpFromAccs) / player.HP
    return adjustedHpp >= 0.85
end

return IsParadeGorgetActive