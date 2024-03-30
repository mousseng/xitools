require('common')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils/packets')
local vanatime = require('utils/vanatime')

local Scale = 1.0

local textBaseWidth = imgui.CalcTextSize('A')
local currentLine = {
    hook = nil,
    feel = nil,
}

local fishMessageOffsets = {
    [1] = 7229,
    [2] = 7281,
    [3] = 7230,
    [4] = 7275,
    [11] = 7579,
    [24] = 7562,
    [25] = 7082,
    [26] = 10268,
    [27] = 7243,
    [44] = 7060,
    [46] = 7060,
    [47] = 7060,
    [48] = 7057,
    [50] = 894,
    [51] = 7057,
    [52] = 7057,
    [53] = 7057,
    [54] = 7057,
    [57] = 7060,
    [58] = 7057,
    [59] = 7057,
    [61] = 7057,
    [65] = 7057,
    [68] = 7057,
    [79] = 7057,
    [81] = 7241,
    [82] = 7373,
    [83] = 7060,
    [84] = 7080,
    [85] = 7060,
    [87] = 7060,
    [88] = 7366,
    [89] = 7060,
    [90] = 7157,
    [91] = 7080,
    [94] = 7060,
    [95] = 7087,
    [99] = 7060,
    [100] = 7241,
    [101] = 7241,
    [102] = 7223,
    [103] = 7241,
    [104] = 7715,
    [105] = 7241,
    [106] = 7241,
    [107] = 7241,
    [109] = 7241,
    [110] = 7241,
    [111] = 7241,
    [113] = 7561,
    [114] = 7561,
    [115] = 7060,
    [116] = 7219,
    [117] = 7241,
    [118] = 7260,
    [119] = 7241,
    [120] = 7249,
    [121] = 7561,
    [122] = 7219,
    [123] = 7561,
    [124] = 7561,
    [125] = 7219,
    [126] = 7219,
    [130] = 7060,
    [140] = 7590,
    [142] = 7219,
    [143] = 7219,
    [145] = 7219,
    [149] = 7219,
    [151] = 7264,
    [153] = 7060,
    [154] = 7060,
    [157] = 7223,
    [158] = 7095,
    [159] = 7219,
    [160] = 7247,
    [166] = 7219,
    [167] = 7219,
    [169] = 7265,
    [172] = 7219,
    [173] = 7060,
    [174] = 7219,
    [176] = 7219,
    [178] = 7060,
    [184] = 7249,
    [191] = 7219,
    [193] = 7219,
    [196] = 7219,
    [204] = 7239,
    [208] = 7219,
    [212] = 7219,
    [213] = 7219,
    [220] = 7241,
    [221] = 7241,
    [227] = 7241,
    [228] = 7241,
    [231] = 7433,
    [232] = 7241,
    [234] = 10816,
    [235] = 7222,
    [236] = 7098,
    [237] = 8018,
    [238] = 7062,
    [239] = 7072,
    [240] = 11588,
    [241] = 7112,
    [242] = 7377,
    [245] = 6937,
    [246] = 6913,
    [247] = 6669,
    [248] = 6565,
    [249] = 6724,
    [250] = 6669,
    [252] = 6669,
    [280] = 7219,
}

local fishMessages = {
    [0x01] = 'no rod',
    [0x02] = 'no bait',
    [0x03] = 'no fishing this moment',
    [0x5E] = 'no fishing this time',
    [0x06] = 'line broke',
    [0x07] = 'rod broke',
    [0x11] = 'rod broke - fish too big',
    [0x12] = 'rod broke - fish way too big',
    [0x09] = 'lost the catch',
    [0x13] = 'lost the catch - fish too small',
    [0x14] = 'lost the catch - you suck',
    [0x3C] = 'lost the catch - fish too big',
    [0x24] = 'gave up - lost bait',
    [0x25] = 'gave up',
    [0x27] = 'caught one',
    [0x0E] = 'caught several',
    [0x0A] = 'caught with a full bag',
    [0x05] = 'caught a monster',
    [0x40] = 'caught a chest',
    [0x04] = 'no catch',
    [0x17] = 'GOLDFISH_PAPER_RIPPED',
    [0x18] = 'GOLDFISH_APPROACHES',
    [0x19] = 'PLUMP_BLACK_APPROACHES',
    [0x1A] = 'FAT_JUICY_APPROACHES',
    [0x1B] = 'NO_GOLDFISH_FOUND',
    [0x1C] = 'CATCH_GOLDFISH_FULL',
    [0x1D] = 'GOLDFISH_SLIPPED_OFF',
    [0x3F] = 'HURRY_GOLDFISH_WARNING',
    [0x28] = 'WARNING',
    [0x08] = 'hooked small fish',
    [0x32] = 'hooked big fish',
    [0x33] = 'hooked an item',
    [0x34] = 'hooked a monster',
    [0x29] = 'good feeling',
    [0x2A] = 'bad feeling',
    [0x2B] = 'terrible feeling',
    [0x2C] = 'skill issue',
    [0x2D] = 'big skill issue',
    [0x2E] = 'yuge skill issue',
    [0x35] = 'good feeling', -- TODO: keen sense has its own packet
    [0x36] = 'caught a giga fish',
}

local fish = T{
    624, 2216, 3965, 4288, 4289, 4290, 4291, 4304, 4305, 4306, 4307, 4308, 4309,
    4310, 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319, 4354, 4360,
    4361, 4379, 4383, 4384, 4385, 4399, 4401, 4402, 4403, 4426, 4427, 4428,
    4429, 4443, 4451, 4454, 4461, 4462, 4463, 4464, 4469, 4470, 4471, 4472,
    4473, 4474, 4475, 4476, 4477, 4478, 4479, 4480, 4481, 4482, 4483, 4484,
    4485, 4500, 4514, 4515, 4528, 4579, 4580, 5120, 5121, 5122, 5123, 5124,
    5125, 5126, 5127, 5128, 5129, 5130, 5131, 5132, 5133, 5134, 5135, 5136,
    5137, 5138, 5139, 5140, 5141, 5446, 5447, 5448, 5449, 5450, 5451, 5452,
    5453, 5454, 5455, 5456, 5457, 5458, 5459, 5460, 5461, 5462, 5463, 5464,
    5465, 5466, 5467, 5468, 5469, 5470, 5471, 5472, 5473, 5474, 5475, 5476,
    5534, 5535, 5536, 5537, 5538, 5539, 5540, 5714, 5715, 5812, 5813, 5814,
    5815, 5816, 5817, 5818, 5948, 5949, 5950, 5951, 5952, 5953, 5954, 5955,
    5957, 5959, 5960, 5961, 5962, 5963, 5993, 5995, 5997, 6144, 6145, 6146,
    6333, 6334, 6335, 6336, 6337, 6338, 6371, 6372, 6373, 6374, 6375, 6376,
    6489,
}

local poolResets = {
    [ 0] = 4,
    [ 1] = 4,
    [ 2] = 4,
    [ 3] = 4,
    [ 4] = 6,
    [ 5] = 6,
    [ 6] = 7,
    [ 7] = 17,
    [ 8] = 17,
    [ 9] = 17,
    [10] = 17,
    [11] = 17,
    [12] = 17,
    [13] = 17,
    [14] = 17,
    [15] = 17,
    [16] = 17,
    [17] = 18,
    [18] = 20,
    [19] = 20,
    [20] = 0,
    [21] = 0,
    [22] = 0,
    [23] = 0,
}

local function GetInventoryTotals(inv)
    local cumInv = {}
    -- the inventory array is not guaranteed to be compact, but counting id=0 or
    -- id=65535 is fine
    for i = 1, inv:GetContainerCountMax(0) do
        local slot = inv:GetContainerItem(0, i)
        if cumInv[slot.Id] == nil then
            cumInv[slot.Id] = slot.Count
        else
            cumInv[slot.Id] = cumInv[slot.Id] + slot.Count
        end
    end

    return cumInv
end

local function GetMessageViaOffset(messageId)
    local zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    local offset = fishMessageOffsets[zone]
    if offset == nil then
        return nil
    end
    return (messageId % 0x8000) - offset
end

local function DrawCurrent()
    if currentLine.hook then
        imgui.Separator()
        if currentLine.hook:startswith('snagged') then
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.TpBarActive)
            imgui.Text(currentLine.hook)
            imgui.PopStyleColor()
        else
            imgui.Text(currentLine.hook)
        end
    end

    if currentLine.feel then
        if currentLine.feel == 'good feeling' then
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusGreen)
        elseif currentLine.feel == 'bad feeling' then
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.Yellow)
        else
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.Red)
        end

        imgui.Text(currentLine.feel)
        imgui.PopStyleColor()
    end

    local date = vanatime.get_current_date()
    local time = vanatime.get_current_time()
    local moon = AshitaCore:GetResourceManager():GetString('moonphases', date.moon_phase)
    local day = AshitaCore:GetResourceManager():GetString('days', date.weekday)

    imgui.Separator()
    imgui.Text(('%-15s %2i%%'):format(moon, date.moon_percent))
    imgui.Text(('%-13s %02i:%02i'):format(day, time.h, time.m))
    imgui.Text(('Restock at... %02i:00'):format(poolResets[math.floor(time.h)]))
end

local function DrawHaul()
    imgui.Separator()
    local invMgr = AshitaCore:GetMemoryManager():GetInventory()
    imgui.Text(('%i free slot(s)'):format(invMgr:GetContainerCountMax(0) - invMgr:GetContainerCount(0)))

    local inv = GetInventoryTotals(invMgr)
    for itemId, count in pairs(inv) do
        if fish:contains(itemId) then
            local fishName = AshitaCore:GetResourceManager():GetItemById(itemId).Name[1]
            imgui.Text(('%3ix %s'):format(count, fishName))
        end
    end
end

local function DrawHistory(history)
    if imgui.CollapsingHeader('Catch History') then
        if imgui.BeginTable('xitool.fishe.history', 2, ImGuiTableFlags_ScrollY, { textBaseWidth * 32, 400 * Scale }) then
            local res = AshitaCore:GetResourceManager()
            imgui.TableSetupScrollFreeze(0, 1)
            imgui.TableSetupColumn('Catch', ImGuiTableColumnFlags_NoHide, textBaseWidth * 20)
            imgui.TableSetupColumn('Skillup', ImGuiTableColumnFlags_NoHide, textBaseWidth * 12)
            imgui.TableHeadersRow()

            for i, catch in pairs(history) do
                imgui.TableNextRow()

                imgui.TableNextColumn()
                if catch.count > 1 then
                    imgui.Text(('%s x%i'):format(res:GetItemById(catch.fishId).Name[1] or catch.fishId, catch.count))
                else
                    imgui.Text(('%s'):format(res:GetItemById(catch.fishId).Name[1] or catch.fishId))
                end

                imgui.TableNextColumn()
                if catch.skillup ~= nil then
                    imgui.Text(('Fishe %+.1f'):format(catch.skillup))
                end
            end
            imgui.EndTable()
        end
    end
end

---@type xitool
local fishe = {
    Name = 'fishe',
    Aliases = T{ 'f', 'fish' },
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.fishe',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = ImGuiWindowFlags_None,
        skill = T{ 0.0 },
        history = T{},
    },
    HandleCommand = function(args, options)
        if #args == 0 then
            options.isVisible[1] = not options.isVisible[1]
        end

        if #args == 1 and (args[1] == 'cl' or args[1] == 'clear') then
            options.history = T{}
        end
    end,
    HandlePacketOut = function(e, options)
        if e.id == packets.outbound.fishingAction.id then
            currentLine = {
                hook = nil,
                feel = nil,
            }
        end
    end,
    HandlePacket = function(e, options)
        local player = GetPlayerEntity()
        if player == nil then return end

        -- reset state on zoning in case you get boated
        if e.id == 0x00A then
            currentLine.hook = nil
            currentLine.feel = nil
            return
        end

        if e.id == 0x027 then
            local msg = packets.inbound.fishCatch.parse(e.data)
            if msg.player == player.ServerId then
                options.history:insert(1, {
                    catchType = msg.message,
                    fishId = msg.fishId,
                    count = msg.count,
                    skillup = nil,
                })
            end
        elseif e.id == 0x029 then
            local basic = packets.inbound.basic.parse(e.data)
            if basic.message == 38 and basic.target == player.ServerId and basic.param == 48 then
                local latestCatch = options.history:first()
                latestCatch.skillup = basic.value / 10
                options.skill[1] = options.skill[1] + (basic.value / 10)
            end
        elseif e.id == 0x02A then
            -- keen senses
            local special = packets.inbound.special.parse(e.data)
            local realMessage = GetMessageViaOffset(special.message)
            if realMessage == nil then return end

            if realMessage == 0x35 then
                local fishName = AshitaCore:GetResourceManager():GetItemById(special.param1).Name[1]
                currentLine.hook = ('snagged %s'):format(fishName)
            end
        elseif e.id == 0x036 then
            local msg = packets.inbound.npcMessage.parse(e.data)
            if msg.sender ~= player.ServerId then return end

            local realMessage = GetMessageViaOffset(msg.message)
            if realMessage == nil then return end

            local hookMsgs = T{ 0x08, 0x32, 0x33, 0x34, }
            local feelMsgs = T{ 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, }

            if hookMsgs:contains(realMessage) then
                currentLine.hook = fishMessages[realMessage]
            elseif feelMsgs:contains(realMessage) then
                currentLine.feel = fishMessages[realMessage]
            end
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('fishe') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.Checkbox('Visible', options.isVisible)
            imgui.InputFloat('Fishe Level', options.skill, 0.1, 0.1, '%.1f')

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]
        ui.DrawNormalWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            imgui.Text(('%-13s %5.1f'):format('Fishe', options.skill[1]))
            DrawCurrent()
            DrawHaul()
            DrawHistory(options.history)
        end)
    end,
}

return fishe
