local function ParseMpBonus(item)
    if item == nil then
        return 0
    end

    return tonumber(item.Description[1]:match('MP([+-]%d+)')) or 0
end

local function GetCurSlot(idx)
    local slot = gEquip.GetCurrentEquip(idx)
    if slot ~= nil and slot.Item ~= nil then
        return AshitaCore:GetResourceManager():GetItemById(slot.Item.Id)
    end

    return nil
end

local function GetNextSlot(slot)
    if slot == nil then
        return nil
    end

    if type(slot) == 'string' then
        return AshitaCore:GetResourceManager():GetItemByName(slot, 0)
    elseif type(slot) == 'table' then
        return AshitaCore:GetResourceManager():GetItemByName(slot.Name or '', 0)
    end
end

local function CompareMpBonus(nextSet)
    local cumulativeResult = 0
    local setComparison = T{}
    for idx = 1, 16 do
        local slotName = gData.Constants.EquipSlots:find(idx)
        local curItem = GetCurSlot(idx)
        local nextItem = GetNextSlot(nextSet[idx])

        if nextItem == nil and not (nextSet[idx] ~= nil and nextSet[idx].Name == 'displaced') then
            nextItem = curItem
        end

        local curBonus = ParseMpBonus(curItem)
        local nextBonus = ParseMpBonus(nextItem)

        local result = nextBonus - curBonus

        setComparison[slotName] = result
        cumulativeResult = cumulativeResult + result
    end
    return cumulativeResult, setComparison
end

local function ConserveMp(baseSet)
    local player = gData.GetPlayer()

    -- this will prevent you from losing lots of MP on the first spellcast,
    -- but obviously might result in lower strength spells
    local replaceCount = 0
    local curDeficit = player.MP - player.MaxMP
    local nextBonus, setCmp = CompareMpBonus(gEquip.PeekBuffer())

    -- include a terminal condition so we don't lock up accidentally
    while curDeficit > nextBonus and replaceCount < 16 do
        local biggestContributor = nil
        local biggestMpDiff = 0
        for i = 1, 16 do
            local mpDiff = setCmp[gData.Constants.EquipSlots:find(i)]
            if mpDiff < biggestMpDiff then
                biggestMpDiff = mpDiff
                biggestContributor = i
            end
        end

        if biggestContributor == nil then
            replaceCount = 16
        else
            local slotToReplace = gData.Constants.EquipSlots:find(biggestContributor)
            local itemToReplace = baseSet[slotToReplace]

            gFunc.Equip(slotToReplace, itemToReplace)
            nextBonus, setCmp = CompareMpBonus(gEquip.PeekBuffer())
            replaceCount = replaceCount + 1
        end
    end
end

return ConserveMp
