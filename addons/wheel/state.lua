require('common')
local packets = require('lin/packets')
local recast = AshitaCore:GetMemoryManager():GetRecast()

local trackedItems = T{
    [1161] = true,
    [1164] = true,
    [1167] = true,
    [1170] = true,
    [1173] = true,
    [1176] = true,
    [2971] = true,
}

local ninjaTools = {
    [0] = { 1170, 2971 },
    [1] = { 1167, 2971 },
    [2] = { 1164, 2971 },
    [3] = { 1161, 2971 },
    [4] = { 1176, 2971 },
    [5] = { 1173, 2971 },
}

local inventory = {
    slots = {},
    items = {},
}

local function UpdateInventory(data)
    local slotCur = inventory.slots[data.slot]
    local slotNew = data

    if slotCur and trackedItems[slotCur.id] then
        inventory.items[slotCur.id] = (inventory.items[slotCur.id] or 0) - slotCur.qty
    end

    if slotNew and trackedItems[slotNew.id] then
        inventory.items[slotNew.id] = (inventory.items[slotNew.id] or 0) + slotNew.qty
        inventory.slots[data.slot] = slotNew
    end
end

ashita.events.register('load', 'state_load', function()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    for i = 1, 80 do
        local item = inv:GetContainerItem(0, i)
    local data = { slot = i, id = item.Id, qty = item.Count }
    UpdateInventory(data)
    end
end)

ashita.events.register('packet_in', 'state_packetin', function(e)
    if e.id == 0x00A then
        inventory = {
            slots = {},
            items = {},
        }
    elseif e.id == 0x01E then
        local data = packets.inbound.inventoryModify.parse(e.data)
        if data.container ~= 0 then return end
        local curItem = inventory.slots[data.slot] or { id = 0 }
        UpdateInventory { slot = data.slot, id = curItem.id, qty = data.quantity }
    elseif e.id == 0x01F then
        local data = packets.inbound.inventoryAssign.parse(e.data)
        if data.container ~= 0 then return end
        UpdateInventory { slot = data.slot, id = data.item, qty = data.quantity }
    elseif e.id == 0x020 then
        local data = packets.inbound.inventoryItem.parse(e.data)
        if data.container ~= 0 then return end
        UpdateInventory { slot = data.slot, id = data.item, qty = data.quantity }
    end
end)

local wheel = {
    debug = false,
    level = 'Ni',
    alt = 'Ichi',
    position = 0,
    spokes = {
        [0] = { Name = 'Doton',  Ichi = 329, Ni = 330, San = 331 },
        [1] = { Name = 'Huton',  Ichi = 326, Ni = 327, San = 328 },
        [2] = { Name = 'Hyoton', Ichi = 323, Ni = 324, San = 325 },
        [3] = { Name = 'Katon',  Ichi = 320, Ni = 321, San = 322 },
        [4] = { Name = 'Suiton', Ichi = 335, Ni = 336, San = 337 },
        [5] = { Name = 'Raiton', Ichi = 332, Ni = 333, San = 334 },
    },
    lookup = {
        [320] = 3,
        [321] = 3,
        [322] = 3,
        [335] = 4,
        [336] = 4,
        [337] = 4,
        [332] = 5,
        [333] = 5,
        [334] = 5,
        [329] = 0,
        [330] = 0,
        [331] = 0,
        [326] = 1,
        [327] = 1,
        [328] = 1,
        [323] = 2,
        [324] = 2,
        [325] = 2,
    },
}

function wheel.get_timer(i, level)
    local id = wheel.spokes[i][level]
    local remaining = recast:GetSpellTimer(id)

    if remaining > 0 then
        return string.format('%.1f', remaining / 60)
    end

    return nil
end

function wheel.get_tools(i)
    local tools = 0
    for _, item in pairs(ninjaTools[i]) do
        tools = tools + (inventory.items[item] or 0)
    end
    return tools
end

function wheel.current()
    return wheel.spokes[wheel.position]
end

function wheel.cast(i, level)
    local command = '/ma "%s" <t>'
    local id = wheel.spokes[i][level]
    local spell = AshitaCore:GetResourceManager():GetSpellById(id).Name[1]
    AshitaCore:GetChatManager():QueueCommand(1, command:format(spell))
end

return wheel
