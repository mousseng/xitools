require('common')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils.packets')
local vanatime = require('utils.vanatime')

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
    [0x2C] = 'you might suck',
    [0x2D] = 'you probably suck',
    [0x2E] = 'you definitely suck',
    [0x35] = 'KEEN_ANGLERS_SENSE',
    [0x36] = 'caught a giga fish',
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

local function DrawCurrent()
    imgui.Separator()

    if currentLine.hook then
        imgui.Text(currentLine.hook)
    end

    if currentLine.feel then
        if currentLine.feel == 'good feeling' then
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusGreen)
        elseif currentLine.feel == 'bad feeling' then
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusYellow)
        else
            imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusRed)
        end

        imgui.Text(currentLine.feel)
        imgui.PopStyleColor()
        imgui.Separator()
    end

    local date = vanatime.get_current_date()
    local time = vanatime.get_current_time()
    local moon = AshitaCore:GetResourceManager():GetString('moonphases', date.moon_phase)
    local day = AshitaCore:GetResourceManager():GetString('days', date.weekday)

    imgui.Text(('%s (%2i%%%%)'):format(moon, date.moon_percent))
    imgui.Text(('%-13s %02i:%02i'):format(day, time.h, time.m))
    imgui.Text(('Next restock: %02i:00'):format(poolResets[math.floor(time.h)]))
end

local function DrawHistory(history)
    if imgui.CollapsingHeader('Catch History') then
        if imgui.BeginTable('xitool.fishe.history', 2, ImGuiTableFlags_ScrollY, { textBaseWidth * 32, 400 }) then
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
    Load = function(options) end,
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
        elseif e.id == 0x036 then
            local msg = packets.inbound.npcMessage.parse(e.data)
            if msg.sender ~= player.ServerId then return end

            local zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
            local offset = fishMessageOffsets[zone]
            local realMessage = (msg.message % 0x8000) - offset

            local hookMsgs = T{ 0x08, 0x32, 0x33, 0x34, }
            local feelMsgs = T{ 0x29, 0x2A, 0x2B, }

            if hookMsgs:contains(realMessage) then
                currentLine.hook = fishMessages[realMessage]
            elseif feelMsgs:contains(realMessage) then
                currentLine.feel = fishMessages[realMessage]
            end
        end
    end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('fishe') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.InputFloat('Fishe Level', options.skill, 0.1, 0.1, '%.1f')

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options)
        ui.DrawNormalWindow(options, function()
            imgui.Text(('%-13s %5.1f'):format('Fishe', options.skill[1]))
            DrawCurrent()
            DrawHistory(options.history)
        end)
    end,
}

return fishe
