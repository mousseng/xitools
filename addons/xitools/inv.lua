require('common')
local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local ffxi = require('utils/ffxi')
local debounce = require('utils/debounce')
local packets = require('utils/packets')
local imgui = require('imgui')
local ui = require('ui')

local textures = { }
local gfxDevice = d3d8.get_device()
local fontWidth = imgui.CalcTextSize('A')
local inventories = T{
    gil = 0,
    bag = T{
        all  = T{},
        temp = T{},
        inv  = T{},
    },
    satchel = T{
        all = T{},
        satchel = T{},
        case = T{},
        sack = T{},
    },
    wardrobe = T{
        all = T{},
        wardrobe1 = T{},
        wardrobe2 = T{},
        wardrobe3 = T{},
        wardrobe4 = T{},
        wardrobe5 = T{},
        wardrobe6 = T{},
        wardrobe7 = T{},
        wardrobe8 = T{},
    },
    house = T{
        all = T{},
        mogSafe1 = T{},
        mogSafe2 = T{},
        storage = T{},
        mogLocker = T{},
    },
}

local itemTypes = {
    misc       = 1,
    weapon     = 4,
    armor      = 5,
    consumable = 7,
}

local slots = {
    [    1] = 'Main',
    [    2] = 'Sub',
    [    3] = 'Weapon',
    [    4] = 'Range',
    [    8] = 'Ammo',
    [   16] = 'Head',
    [   32] = 'Body',
    [   64] = 'Hands',
    [  128] = 'Legs',
    [  256] = 'Feet',
    [  512] = 'Neck',
    [ 1024] = 'Waist',
    [ 2048] = 'L.Ear',
    [ 4096] = 'R.Ear',
    [ 6144] = 'Earring',
    [ 8192] = 'L.Ring',
    [16384] = 'R.Ring',
    [24576] = 'Ring',
    [32768] = 'Back',
}

local skills = {
    [ 1] = 'Fists',
    [ 2] = 'Dagger',
    [ 3] = 'Sword',
    [ 4] = 'Great Sword',
    [ 5] = 'Axe',
    [ 6] = 'Great Axe',
    [ 7] = 'Scythe',
    [ 8] = 'Polearm',
    [ 9] = 'Katana',
    [10] = 'Great Katana',
    [11] = 'Club',
    [12] = 'Staff',
    [25] = 'Bow',
    [26] = 'Crossbow',
    [27] = 'Throwable',
    -- [28] = 'Guarding',
    -- [29] = 'Evasion',
    [30] = 'Shield',
    -- [31] = 'Parrying',
    -- [32] = 'Divine',
    -- [33] = 'Healing',
    -- [34] = 'Enhancing',
    -- [35] = 'Enfeebling',
    -- [36] = 'Elemental',
    -- [37] = 'Dark',
    -- [38] = 'Summoning',
    -- [39] = 'Ninjutsu',
    [40] = 'Instrument',
    [41] = 'Instrument',
    [42] = 'Instrument',
    -- [43] = 'Blue',
    -- [44] = 'Geomancy',
}

local jobs = {
    [ 1] = 'WAR',
    [ 2] = 'MNK',
    [ 3] = 'WHM',
    [ 4] = 'BLM',
    [ 5] = 'RDM',
    [ 6] = 'THF',
    [ 7] = 'PLD',
    [ 8] = 'DRK',
    [ 9] = 'BST',
    [10] = 'BRD',
    [11] = 'RNG',
    [12] = 'SAM',
    [13] = 'NIN',
    [14] = 'DRG',
    [15] = 'SMN',
    [16] = 'BLU',
    [17] = 'COR',
    [18] = 'PUP',
    [19] = 'DNC',
    [20] = 'SCH',
    [21] = 'GEO',
    [22] = 'RUN',
}

local bags = {
    inventory      = 0,
    mogSafe        = 1,
    storage        = 2,
    tempItems      = 3,
    mogLocker      = 4,
    mogSatchel     = 5,
    mogSack        = 6,
    mogCase        = 7,
    wardrobe       = 8,
    mogSafe2       = 9,
    wardrobe2      = 10,
    wardrobe3      = 11,
    wardrobe4      = 12,
    wardrobe5      = 13,
    wardrobe6      = 14,
    wardrobe7      = 15,
    wardrobe8      = 16,
    recycleBin     = 17,
    maxContainerId = 18,
}

local moveableBags = {
    { id =  0, hasAccess = false, isGearOnly = false, name = 'inventory' },
    { id =  5, hasAccess = false, isGearOnly = false, name = 'satchel' },
    { id =  6, hasAccess = false, isGearOnly = false, name = 'sack' },
    { id =  7, hasAccess = false, isGearOnly = false, name = 'case' },
    { id =  8, hasAccess = false, isGearOnly = true,  name = 'wardrobe 1' },
    { id = 10, hasAccess = false, isGearOnly = true,  name = 'wardrobe 2' },
    { id = 11, hasAccess = false, isGearOnly = true,  name = 'wardrobe 3' },
    { id = 12, hasAccess = false, isGearOnly = true,  name = 'wardrobe 4' },
    { id = 13, hasAccess = false, isGearOnly = true,  name = 'wardrobe 5' },
    { id = 14, hasAccess = false, isGearOnly = true,  name = 'wardrobe 6' },
    { id = 15, hasAccess = false, isGearOnly = true,  name = 'wardrobe 7' },
    { id = 16, hasAccess = false, isGearOnly = true,  name = 'wardrobe 8' },
}

local function FormatGil(number)
    local str = tostring(number)
    local len = #str
    local numSeps = math.ceil((len / 3) - 1)
    local strTbl = str:explode()
    for i = 1, numSeps do
        table.insert(strTbl, len - (3 * i) + 1, ',')
    end
    return strTbl:join('')
end

local function CreateTexture(bitmap, size)
    local c = ffi.C
    local texturePtr = ffi.new('IDirect3DTexture8*[1]')

    local width = 0xFFFFFFFF
    local height = 0xFFFFFFFF
    local mipLevels = 1
    local usage = 0
    local colorKey = 0xFF000000

    local textureSuccess = c.D3DXCreateTextureFromFileInMemoryEx(
        gfxDevice,
        bitmap,
        size,
        width,
        height,
        mipLevels,
        usage,
        c.D3DFMT_A8R8G8B8,
        c.D3DPOOL_MANAGED,
        c.D3DX_DEFAULT,
        c.D3DX_DEFAULT,
        colorKey,
        nil,
        nil,
        texturePtr)

    if textureSuccess == c.S_OK then
        return d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', texturePtr[0]))
    else
        return nil
    end
end

local function EscapeString(str)
    -- shamelessly stolen from Shinzaku's GearFinder
    if str then
        return str:
            replace('\x81\x60', '~'):
            replace('\xEF\x1F', 'Fire Res'):
            replace('\xEF\x20', 'Ice Res'):
            replace('\xEF\x21', 'Wind Res'):
            replace('\xEF\x22', 'Earth Res'):
            replace('\xEF\x23', 'Ltng Res'):
            replace('\xEF\x24', 'Water Res'):
            replace('\xEF\x25', 'Light Res'):
            replace('\xEF\x26', 'Dark Res'):
            replace('\x25',     '%%')
    end

    return ''
end

local function GetJobs(bitfield)
    if bitfield == 8388606 then
        return T{ 'All jobs' }
    end

    local jobList = T{}
    for i = 1, 23 do
        if bit.band(1, bit.rshift(bitfield, i)) == 1 then
            table.insert(jobList, jobs[i])
        end
    end
    return jobList
end

local function GetSlots(bitfield, skill)
    if bitfield <= 3 then
        return skills[skill]
    else
        return slots[bitfield]
    end
end

local function SortInventory(lhs, rhs)
    if lhs.sortId == rhs.sortId then
        if lhs.id == rhs.id then
            return lhs.stackCur > rhs.stackCur
        end

        return lhs.id < rhs.id
    end

    return lhs.sortId < rhs.sortId
end

local function UpdateInventory(inv, res, bagId)
    local inventory = T{ }
    local itemCount = inv:GetContainerCountMax(bagId)

    for i = 0, itemCount do
        local invItem = inv:GetContainerItem(bagId, i)
        local itemRes = res:GetItemById(invItem.Id)

        if itemRes ~= nil and invItem.Id ~= 65535 then
            if textures[invItem.Id] == nil then
                textures[invItem.Id] = CreateTexture(itemRes.Bitmap, itemRes.ImageSize)
            end

            local coolItem = {
                id = invItem.Id,
                bagId = bagId,
                sortId = itemRes.ResourceId,
                slotId = invItem.Index,
                uniqueId = ('%i.%i.%s'):format(bagId, invItem.Index, itemRes.Name[1]),
                type = itemRes.Type,
                flags = itemRes.Flags,
                targets = itemRes.Targets,
                isUsable = bit.band(1, bit.rshift(itemRes.Flags, 10)) == 1,
                isMoveable = true,
                isTradeable = true,
                isLocked = bit.band(1, invItem.Flags) == 1 or bagId > 0,
                isEquippable = itemRes.Type == 4 or itemRes.Type == 5,
                name = ('%s [%i]'):format(itemRes.LogNameSingular[1], invItem.Id),
                shortName = itemRes.Name[1],
                longNameS = itemRes.LogNameSingular[1],
                longNameP = itemRes.LogNamePlural[1],
                desc = EscapeString(itemRes.Description[1]),
                stack = nil,
                stackCur = invItem.Count,
                stackMax = itemRes.StackSize,
                level = nil,
                jobs = nil,
                iconPtr = tonumber(ffi.cast('uint32_t', textures[invItem.Id]))
            }

            if coolItem.stackMax > 1 then
                coolItem.stack = ('%i / %i'):format(coolItem.stackCur, coolItem.stackMax)
            end

            if coolItem.type == itemTypes.armor
            or coolItem.type == itemTypes.weapon then
                local itemSlots = GetSlots(itemRes.Slots, itemRes.Skill)
                local itemJobs = GetJobs(itemRes.Jobs)
                coolItem.level = ('Lv %i %s'):format(itemRes.Level, itemSlots)
                coolItem.jobs = itemJobs:join(', ')
                coolItem.slots = itemRes.Slots
            end

            inventory:append(coolItem)
        end
    end

    return inventory
end

local function UpdateInventories()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local res = AshitaCore:GetResourceManager()
    local gil = inv:GetContainerItem(0, 0)
    local invSize = inv:GetContainerCountMax(0)
    if gil == nil or invSize == 0 then return end

    for _, bag in ipairs(moveableBags) do
        if bag.id > 10 then
            bag.hasAccess = ffxi.HasBagAccess(bag.id)
        else
            bag.hasAccess = inv:GetContainerCountMax(bag.id) > 0
        end
    end

    inventories.gil = FormatGil(gil.Count)
    inventories.bag.inv = UpdateInventory(inv, res, bags.inventory):sort(SortInventory)
    inventories.bag.temp = UpdateInventory(inv, res, bags.tempItems):sort(SortInventory)
    inventories.satchel.satchel = UpdateInventory(inv, res, bags.mogSatchel):sort(SortInventory)
    inventories.satchel.case = UpdateInventory(inv, res, bags.mogCase):sort(SortInventory)
    inventories.satchel.sack = UpdateInventory(inv, res, bags.mogSack):sort(SortInventory)
    inventories.wardrobe.wardrobe1 = UpdateInventory(inv, res, bags.wardrobe):sort(SortInventory)
    inventories.wardrobe.wardrobe2 = UpdateInventory(inv, res, bags.wardrobe2):sort(SortInventory)
    inventories.wardrobe.wardrobe3 = UpdateInventory(inv, res, bags.wardrobe3):sort(SortInventory)
    inventories.wardrobe.wardrobe4 = UpdateInventory(inv, res, bags.wardrobe4):sort(SortInventory)
    inventories.wardrobe.wardrobe5 = UpdateInventory(inv, res, bags.wardrobe5):sort(SortInventory)
    inventories.wardrobe.wardrobe6 = UpdateInventory(inv, res, bags.wardrobe6):sort(SortInventory)
    inventories.wardrobe.wardrobe7 = UpdateInventory(inv, res, bags.wardrobe7):sort(SortInventory)
    inventories.wardrobe.wardrobe8 = UpdateInventory(inv, res, bags.wardrobe8):sort(SortInventory)
    inventories.house.mogSafe1 = UpdateInventory(inv, res, bags.mogSafe):sort(SortInventory)
    inventories.house.mogSafe2 = UpdateInventory(inv, res, bags.mogSafe2):sort(SortInventory)
    inventories.house.storage = UpdateInventory(inv, res, bags.storage):sort(SortInventory)
    inventories.house.locker = UpdateInventory(inv, res, bags.mogLocker):sort(SortInventory)

    inventories.bag.all = T{}
        :extend(inventories.bag.inv)
        :extend(inventories.bag.temp)
        :sort(SortInventory)

    inventories.satchel.all = T{}
        :extend(inventories.satchel.satchel)
        :extend(inventories.satchel.case)
        :extend(inventories.satchel.sack)
        :sort(SortInventory)

    inventories.wardrobe.all = T{}
        :extend(inventories.wardrobe.wardrobe1)
        :extend(inventories.wardrobe.wardrobe2)
        :extend(inventories.wardrobe.wardrobe3)
        :extend(inventories.wardrobe.wardrobe4)
        :extend(inventories.wardrobe.wardrobe5)
        :extend(inventories.wardrobe.wardrobe6)
        :extend(inventories.wardrobe.wardrobe7)
        :extend(inventories.wardrobe.wardrobe8)
        :sort(SortInventory)

    inventories.house.all = T{}
        :extend(inventories.house.mogSafe1)
        :extend(inventories.house.mogSafe2)
        :extend(inventories.house.storage)
        :extend(inventories.house.locker)
        :sort(SortInventory)
end

local function TryToUse(item)
    if imgui.Selectable('Use') then
        local target = '<me>'

        -- target determination courtesy of Thorny's thotbar
        local targetsOthers = bit.band(item.targets, 0xFC) ~= 0
        if targetsOthers then
            target = '<t>'
        end

        AshitaCore:GetChatManager():QueueCommand(1, ('/item "%s" %s'):format(item.shortName, target))
    end
end

local function TryToTrade(item)
    if imgui.Selectable('Trade') then
        AshitaCore:GetChatManager():QueueCommand(1, ('/item "%s" <t>'):format(item.shortName))
    end
end

local function TryToEquip(item)
    for i = 0, 16 do
        local slot = bit.band(item.slots, bit.lshift(1, i))
        if slot > 0 then
            local target = slots[slot]
            local action = ('Equip to %s'):format(target)
            if imgui.Selectable(action) then
                AshitaCore:GetChatManager():QueueCommand(1, ('/equip %s "%s"'):format(target, item.shortName))
            end
        end
    end
end

local function TryToMove(item)
    if imgui.BeginMenu('Move') then
        for _, bag in ipairs(moveableBags) do
            local title = ('to %s'):format(bag.name)

            local shouldShow = bag.hasAccess
                and bag.id ~= item.bagId
                and (not bag.isGearOnly or bag.isGearOnly and item.isEquippable)

            if shouldShow and imgui.MenuItem(title) then
                AshitaCore:GetPacketManager():AddOutgoingPacket(
                    packets.outbound.inventoryMove:make(item.stackCur, item.bagId, bag.id, item.slotId))
            end
        end

        imgui.EndMenu()
    end
end

local function TryToDrop(item)
    if imgui.BeginMenu('Drop') then
        local itemName = item.longNameS
        if item.stackCur > 1 then
            itemName = item.longNameP
        end

        -- TODO: add quantity picker

        local title = ('Drop %i %s'):format(item.stackCur, itemName)
        if imgui.MenuItem(title) then
            AshitaCore:GetPacketManager():AddOutgoingPacket(
                packets.outbound.inventoryDrop:make(item.stackCur, 0, item.slotId))
        end

        imgui.EndMenu()
    end
end

local function AddStackSize(posX, posY, count)
    local mainColor = imgui.GetColorU32({ 1, 1, 1, 1 })
    local shadowColor = imgui.GetColorU32({ 0, 0, 0, 1 })
    imgui.GetWindowDrawList():AddText({ posX + 1, posY + 1 }, shadowColor, tostring(count or 0))
    imgui.GetWindowDrawList():AddText({ posX, posY }, mainColor, tostring(count or 0))
end

local highlightColor = imgui.GetColorU32({ 0.23, 0.67, 0.91, 1.0 })
local function AddHighlight(posX, posY, size, drawList)
    local pad = 2
    local upperLeft = { posX - pad, posY - pad }
    local bottomRight = { posX + size + pad, posY + size + pad }
    drawList:AddRect(upperLeft, bottomRight, highlightColor, 0.0)
end

local function AddTooltip(item)
    imgui.BeginTooltip()

    imgui.PushTextWrapPos(fontWidth * 64)
    imgui.Text(item.name)
    imgui.Text(item.desc)
    imgui.PopTextWrapPos()

    if item.stack then
        imgui.Text(item.stack)
    end

    imgui.PushTextWrapPos(fontWidth * 40)
    if item.level then
        imgui.Text(item.level)
    end
    if item.jobs then
        imgui.Text(item.jobs)
    end
    imgui.PopTextWrapPos()

    imgui.EndTooltip()
end

local function AddFullCtxMenu(item)
    local menuOpened = false
    local menuOpenable = item.isUsable or item.isMoveable or item.isEquippable or not item.isLocked

    if menuOpenable and imgui.BeginPopupContextItem(item.uniqueId) then
        menuOpened = true

        if item.isUsable then
            TryToUse(item)
        end

        if item.isTradeable then
            TryToTrade(item)
        end

        if item.isEquippable then
            TryToEquip(item)
        end

        if item.isMoveable then
            TryToMove(item)
        end

        if not item.isLocked then
            TryToDrop(item)
        end

        if imgui.Selectable('Cancel') then
            imgui.CloseCurrentPopup()
        end

        imgui.EndPopup()
    end

    return menuOpened
end

local function AddWardrobeCtxMenu(item)
    local menuOpened = false
    local menuOpenable = item.isUsable or item.isMoveable or item.isEquippable or not item.isLocked

    if menuOpenable and imgui.BeginPopupContextItem(item.uniqueId) then
        menuOpened = true

        if item.isUsable then
            TryToUse(item)
        end

        if item.isEquippable then
            TryToEquip(item)
        end

        if item.isMoveable then
            TryToMove(item)
        end

        if not item.isLocked then
            TryToDrop(item)
        end

        if imgui.Selectable('Cancel') then
            imgui.CloseCurrentPopup()
        end

        imgui.EndPopup()
    end

    return menuOpened
end

local function AddSatchelCtxMenu(item)
    local menuOpened = false
    local menuOpenable = item.isMoveable or not item.isLocked

    if menuOpenable and imgui.BeginPopupContextItem(item.uniqueId) then
        menuOpened = true

        if item.isMoveable then
            TryToMove(item)
        end

        if not item.isLocked then
            TryToDrop(item)
        end

        if imgui.Selectable('Cancel') then
            imgui.CloseCurrentPopup()
        end

        imgui.EndPopup()
    end

    return menuOpened
end

local function AddHouseCtxMenu(item)
    return false
end

local contextMenus = {
    bag      = AddFullCtxMenu,
    satchel  = AddSatchelCtxMenu,
    wardrobe = AddWardrobeCtxMenu,
    house    = AddHouseCtxMenu,
}

local function DrawItem(item, addCtxMenu)
    local iconSize = 32
    local curX, curY = imgui.GetCursorScreenPos()
    local drawList = imgui.GetWindowDrawList()

    imgui.Image(item.iconPtr, { iconSize, iconSize })

    if item.stackMax > 1 then
        AddStackSize(curX, curY, item.stackCur)
    end

    if imgui.IsItemHovered() then
        AddHighlight(curX, curY, iconSize, drawList)
        AddTooltip(item)
    end

    if addCtxMenu(item) then
        AddHighlight(curX, curY, iconSize, drawList)
    end
end

local function DrawBag(bagId, subId)
    local rowLength = 5

    for i, item in ipairs(inventories[bagId][subId]) do
        if i % rowLength ~= 1 then
            imgui.SameLine()
        end

        DrawItem(item, contextMenus[bagId])
    end
end

local function DrawSubInventory(title, bagId, subId)
    if #inventories[bagId][subId] == 0 then
        return
    end

    imgui.Text(title)
    imgui.Separator()
    DrawBag(bagId, subId)
    imgui.NewLine()
end

local function DrawInventory()
    imgui.PushStyleVar(ImGuiStyleVar_FramePadding, ui.Styles.FramePaddingSome)
    imgui.Text(('%s G'):format(inventories.gil))

    if imgui.BeginTabBar('##xitools.inventories.all', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton) then
        if imgui.BeginTabItem('bag##all1') then
            DrawSubInventory('temp items', 'bag', 'temp')
            DrawSubInventory('inventory', 'bag', 'inv')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('satchel##all2') then
            DrawSubInventory('mog satchel', 'satchel', 'satchel')
            DrawSubInventory('mog case', 'satchel', 'case')
            DrawSubInventory('mog sack', 'satchel', 'sack')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('ward##all3') then
            DrawSubInventory('wardrobe 1', 'wardrobe', 'wardrobe1')
            DrawSubInventory('wardrobe 2', 'wardrobe', 'wardrobe2')
            DrawSubInventory('wardrobe 3', 'wardrobe', 'wardrobe3')
            DrawSubInventory('wardrobe 4', 'wardrobe', 'wardrobe4')
            DrawSubInventory('wardrobe 5', 'wardrobe', 'wardrobe5')
            DrawSubInventory('wardrobe 6', 'wardrobe', 'wardrobe6')
            DrawSubInventory('wardrobe 7', 'wardrobe', 'wardrobe7')
            DrawSubInventory('wardrobe 8', 'wardrobe', 'wardrobe8')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('house##all4') then
            DrawSubInventory('mog safe 1', 'house', 'mogSafe1')
            DrawSubInventory('mog safe 2', 'house', 'mogSafe2')
            DrawSubInventory('storage', 'house', 'storage')
            DrawSubInventory('mog locker', 'house', 'locker')
            imgui.EndTabItem()
        end

        imgui.EndTabBar()
    end
    imgui.PopStyleVar()
end

local function DrawInventoryUnified()
    imgui.PushStyleVar(ImGuiStyleVar_FramePadding, ui.Styles.FramePaddingSome)
    imgui.Text(('%s G'):format(inventories.gil))

    if imgui.BeginTabBar('##xitools.inventories.unified', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton) then
        if imgui.BeginTabItem('bag##unified1') then
            DrawBag('bag', 'all')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('satchel##unified2') then
            DrawBag('satchel', 'all')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('ward##unified3') then
            DrawBag('wardrobe', 'all')
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem('house##unified4') then
            DrawBag('house', 'all')
            imgui.EndTabItem()
        end

        imgui.EndTabBar()
    end
    imgui.PopStyleVar()
end

---@type xitool
local inv = {
    Name = 'inv',
    Aliases = T{ 'i' },
    DefaultSettings = T{
        name = 'xitools.inv',
        isEnabled = T{ false },
        isVisible = T{ true },
        isUnified = T{ true },
        size = T{ 0, 0 },
        maxHeight = T{ 432 },
        pos = T{ 256, 256 },
        flags = bit.bor(ImGuiWindowFlags_NoResize),
    },
    Load = function()
        if GetPlayerEntity() ~= nil then
            UpdateInventories()
        end
    end,
    HandleCommand = function(args, options)
        if #args == 0 then
            options.isVisible[1] = not options.isVisible[1]
        end
    end,
    HandlePacket = function(e, options)
        if e.id == 0x01D then
            local packet = packets.inbound.inventoryFinish.parse(e.data)
            if packet.flag == 1 then
                debounce(UpdateInventories)
            end
        elseif e.id == 0x01E then
            debounce(UpdateInventories)
        end
    end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('inv') then
            if imgui.Checkbox('Enabled', options.isEnabled) and options.isEnabled[1] then
                UpdateInventories()
            end

            imgui.Checkbox('Visible', options.isVisible)
            imgui.Checkbox('Draw Unified Bags', options.isUnified)
            imgui.InputInt('Max Height', options.maxHeight)

            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]
        ui.DrawNormalWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            if options.isUnified[1] then
                DrawInventoryUnified()
            else
                DrawInventory()
            end
        end)
    end,
}

return inv
