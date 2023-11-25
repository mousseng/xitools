require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils/packets')

local TextBaseWidth = imgui.CalcTextSize('A')
local Scale = 1.0
local WeirdTimestamps = {}

local gold = { 1.0, 215/255, 0.0, 1.0 }

local function GetTreasure(options)
    local res = AshitaCore:GetResourceManager()
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local player = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0)
    local now = os.time()

    local treasurePool = T{ }
    for i = 0,9 do
        local treasureItem = inv:GetTreasurePoolItem(i)
        if treasureItem ~= nil and treasureItem.ItemId > 0 then
            local itemInfo = res:GetItemById(treasureItem.ItemId)

            if not WeirdTimestamps[treasureItem.DropTime] then
                WeirdTimestamps[treasureItem.DropTime] = now + 300
            end

            treasurePool:append{
                id = itemInfo.Id,
                slot = i,
                name = itemInfo.Name[1],
                time = string.format('%4i', WeirdTimestamps[treasureItem.DropTime] - now),
                winner = {
                    exists = treasureItem.WinningLot > 0,
                    name = treasureItem.WinningEntityName,
                    lot = string.format('%4i', treasureItem.WinningLot),
                },
                current = {
                    name = player,
                    lot = string.format('%4i', treasureItem.Lot),
                    hasRolled = treasureItem.Lot > 0 and treasureItem.Lot < 1000,
                    hasPassed = treasureItem.Lot > 1000,
                },
            }
        elseif options.showAllSlots[1] then
            treasurePool:append{
                id = 0,
                slot = i,
                name = '',
                time = '',
                winner = { exists = false },
                current = { name = player, hasRolled = false, hasPassed = true },
            }
        end
    end

    return treasurePool
end

local function Roll(treasure)
    if treasure.current.hasRolled
    or treasure.current.hasPassed then
        return
    end

    AshitaCore:GetPacketManager():AddOutgoingPacket(packets.outbound.treasureLot:make(treasure.slot))
end

local function Pass(treasure)
    if treasure.current.hasPassed then
        return
    end

    AshitaCore:GetPacketManager():AddOutgoingPacket(packets.outbound.treasurePass:make(treasure.slot))
end

-- local function GetDummyTreasure()
--     local now = os.time()
--     return {
--         {
--             id = 1,
--             slot = 1,
--             name = 'Cool Item 1',
--             time = string.format('%4i', (now + 300) - (now + 267)),
--             winner = { exists = true, name = 'Winner Dude', lot = '673' },
--             current = { name = 'Lin', hasRolled = true, hasPassed = false, lot = '555', },
--         },
--         {
--             id = 2,
--             slot = 2,
--             name = 'Cool Item 2',
--             time = string.format('%4i', (now + 300) - (now + 113)),
--             winner = { exists = true, name = 'Lin', lot = '999' },
--             current = { name = 'Lin', hasRolled = true, hasPassed = false, lot = '999', },
--         },
--         {
--             id = 3,
--             slot = 3,
--             name = 'Cool Item 3',
--             time = string.format('%4i', (now + 300) - (now + 10)),
--             winner = { exists = true, name = 'Winner Dude', lot = '888' },
--             current = { name = 'Lin', hasRolled = false, hasPassed = true, lot = '65535', },
--         },
--         {
--             id = 4,
--             slot = 4,
--             name = 'Cool Item 4',
--             time = string.format('%4i', (now + 300) - (now + 78)),
--             winner = { exists = false, name = 'Winner Dude', lot = '888' },
--             current = { name = 'Lin', hasRolled = false, hasPassed = false, lot = '65535', },
--         },
--     }
-- end

local function DrawTreasure(treasurePool)
    if imgui.Button('Roll All') then
        for _, treasure in pairs(treasurePool) do
            Roll(treasure)
        end
    end

    imgui.SameLine()
    if imgui.Button('Pass All') then
        for _, treasure in pairs(treasurePool) do
            Pass(treasure)
        end
    end

    if imgui.BeginTable('xitools.treas.pool', 6, ImGuiTableFlags_SizingFixedFit) then
        imgui.TableSetupScrollFreeze(0, 1)
        imgui.TableSetupColumn('Treasure', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 17)
        imgui.TableSetupColumn('Time', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 6)
        imgui.TableSetupColumn('##Winning Lot', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 4)
        imgui.TableSetupColumn('Winner', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 16)
        imgui.TableSetupColumn('Lot', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 6)
        imgui.TableSetupColumn('##Pass', ImGuiTableColumnFlags_NoHide, TextBaseWidth * 6)
        imgui.TableHeadersRow()

        for i, treasure in ipairs(treasurePool) do
            imgui.TableNextRow()

            local Write = imgui.Text
            if treasure.current.hasPassed then
                Write = imgui.TextDisabled
            elseif treasure.winner.name == treasure.current.name then
                Write = imgui.TextColored:bindn(gold)
            end

            imgui.TableNextColumn()
            imgui.AlignTextToFramePadding()
            Write(treasure.name)

            imgui.TableNextColumn()
            Write(treasure.time)

            imgui.TableNextColumn()
            if treasure.winner.exists then
                Write(treasure.winner.lot)
            end

            imgui.TableNextColumn()
            if treasure.winner.exists then
                Write(treasure.winner.name)
            end

            imgui.TableNextColumn()
            if not treasure.current.hasRolled
            and not treasure.current.hasPassed then
                if imgui.Button(('Roll##%i'):format(i)) then
                    Roll(treasure)
                end
            elseif treasure.current.hasRolled then
                Write(treasure.current.lot)
            elseif treasure.current.hasPassed then
                Write('---')
            end

            imgui.TableNextColumn()
            if imgui.Button(('Pass##%i'):format(i))
            and not treasure.current.hasPassed then
                Pass(treasure)
            end
        end

        imgui.EndTable()
    end
end

---@type xitool
local treas = {
    Name = 'treas',
    Aliases = T{ 't' },
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        showAllSlots = T{ false },
        name = 'xitools.treas',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoResize),
    },
    HandleCommand = function (args, options, gOptions)
        if #args == 0 then
            options.isVisible[1] = not options.isVisible[1]
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('treas') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.Checkbox('Visible', options.isVisible)
            imgui.Checkbox('Show empty slots', options.showAllSlots)

            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]
        local treasurePool = GetTreasure(options)
        -- local treasurePool = GetDummyTreasure()
        if #treasurePool > 0 then
            ui.DrawNormalWindow(options, gOptions, function()
                imgui.SetWindowFontScale(Scale)
                DrawTreasure(treasurePool)
            end)
        else
            WeirdTimestamps = {}
        end
    end,
}

return treas
