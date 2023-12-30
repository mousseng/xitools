require('common')
local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local d3d8_device = d3d8.get_device()
local imgui = require('imgui')
local ui = require('ui')

local ffxi = require('utils/ffxi')
local zones = require('utils/zones')

local Scale = 1.0

local Textures = { }
local Alliances = { }

-- notes on PartyMemberFlagMask
-- bit 0: ? maybe party 2?
-- bit 1: ?
-- bit 2: party leader
-- bit 3: alli leader
-- bit 4: ?
-- bit 5: ?
-- bit 6: ?
-- bit 7: level sync target

---@class PartyMember
---@field entity           table
---@field name             string
---@field showCastbar      boolean
---@field serverId         integer
---@field isInZone         boolean
---@field isActive         boolean
---@field isPartyLeader    boolean
---@field isAllianceLeader boolean
---@field isSyncTarget     boolean
---@field isTarget         boolean
---@field isSubTarget      boolean
---@field isPartyTarget    boolean
---@field job              string
---@field sub              string?
---@field jobLevel         integer
---@field subLevel         integer
---@field zoneId           integer
---@field hpp              integer
---@field mpp              integer
---@field hp               integer
---@field mp               integer
---@field tp               integer
---@field windowName       string
---@field windowSize       integer[]
---@field windowPos        integer[]
---@field statusIds        integer[]

---@param statusId number
---@param icon userdata
local function CreateTexture(statusId, icon)
    if icon == nil then
        print('xitools error: no icon for status ' .. tostring(statusId))
        return nil
    end

    -- Courtesy of Thorny's partybuffs
    local dx_texture_ptr = ffi.new('IDirect3DTexture8*[1]')
    if ffi.C.D3DXCreateTextureFromFileInMemoryEx(d3d8_device, icon.Bitmap, icon.ImageSize, 0xFFFFFFFF, 0xFFFFFFFF, 1, 0, ffi.C.D3DFMT_A8R8G8B8, ffi.C.D3DPOOL_MANAGED, ffi.C.D3DX_DEFAULT, ffi.C.D3DX_DEFAULT, 0xFF000000, nil, nil, dx_texture_ptr) == ffi.C.S_OK then
        return d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', dx_texture_ptr[0]))
    else
        return nil
    end
end

local function GetBuffs(party, serverId)
    -- courtesy of Thorny and Heals
    for i = 0, 4 do
        local sId = party:GetStatusIconsServerId(i)
        if sId == serverId then
            local icons_lo = party:GetStatusIcons(i)
            local icons_hi = party:GetStatusIconsBitMask(i)
            local effects = { }

            for b = 0, 31 do
                --[[ FIXME: lua doesn't handle 64bit return values properly..
                --   FIXME: the next lines are a workaround by Thorny that cover most but not all cases..
                --   FIXME: .. to try and retrieve the high bits of the buff id.
                --   TODO:  revesit this once atom0s adjusted the API.
                --]]
                local high_bits
                if b < 16 then
                    high_bits = bit.lshift(bit.band(bit.rshift(icons_hi, 2* b), 3), 8)
                else
                    local buffer = math.floor(icons_hi / 0xffffffff)
                    high_bits = bit.lshift(bit.band(bit.rshift(buffer, 2 * (b - 16)), 3), 8)
                end

                local buff_id = icons_lo[b+1] + high_bits
                if (buff_id ~= 255) then
                    table.insert(effects, buff_id)
                end
             end

             return effects
        end
    end

    return { }
end

local function FilterBuffs(buffList)
    local buffs = {}

    for _, buff in ipairs(buffList) do
        if buff ~= nil and buff > 0 then
            table.insert(buffs, buff)
        end
    end

    return buffs
end

local function IsSubTargetActive(target)
    local flags = target:GetSubTargetFlags()
    if flags == 0xFFFFFFFF then
        return target:GetIsActive(1) == 1
    else
        return target:GetIsActive(0) == 1
    end
end

local function GetPlayer(options, target, party, stal)
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    local serverId = party:GetMemberServerId(0)
    local buffs = FilterBuffs(player:GetBuffs())

    return {
        entity = GetEntity(party:GetMemberTargetIndex(0)),
        name = party:GetMemberName(0),
        showCastbar = options.showCastbar[1],
        serverId = serverId,
        isInZone = true,
        isActive = true,
        isPartyLeader = bit.band(party:GetMemberFlagMask(0), 4) == 4,
        isAllianceLeader = bit.band(party:GetMemberFlagMask(0), 8) == 8,
        isSyncTarget = bit.band(party:GetMemberFlagMask(0), 256) == 256,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stal ~= nil and stal == 0,
        job = ffxi.GetJobAbbr(party:GetMemberMainJob(0)),
        sub = ffxi.GetJobAbbr(party:GetMemberSubJob(0)),
        jobLevel = party:GetMemberMainJobLevel(0),
        subLevel = party:GetMemberSubJobLevel(0),
        zoneId = party:GetMemberZone(0),
        hpp = party:GetMemberHPPercent(0),
        mpp = party:GetMemberMPPercent(0),
        hp = party:GetMemberHP(0),
        mp = party:GetMemberMP(0),
        tp = party:GetMemberTP(0),
        windowName = options.alliance1.name,
        windowSize = options.alliance1.size,
        windowPos = options.alliance1.pos,
        statusIds = buffs
    }
end

---@return PartyMember
local function GetMember(i, window, target, party, stal)
    local serverId = party:GetMemberServerId(i)
    local buffs = FilterBuffs(GetBuffs(party, serverId))

    return {
        entity = GetEntity(party:GetMemberTargetIndex(i)),
        name = party:GetMemberName(i),
        showCastbar = false,
        serverId = serverId,
        isInZone = party:GetMemberZone(i) == party:GetMemberZone(0),
        isActive = party:GetMemberIsActive(i) == 1,
        isPartyLeader = bit.band(party:GetMemberFlagMask(i), 4) == 4,
        isAllianceLeader = bit.band(party:GetMemberFlagMask(i), 8) == 8,
        isSyncTarget = bit.band(party:GetMemberFlagMask(i), 256) == 256,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stal ~= nil and stal == i,
        job = ffxi.GetJobAbbr(party:GetMemberMainJob(i)),
        sub = ffxi.GetJobAbbr(party:GetMemberSubJob(i)),
        jobLevel = party:GetMemberMainJobLevel(i),
        subLevel = party:GetMemberSubJobLevel(i),
        zoneId = party:GetMemberZone(i),
        hpp = party:GetMemberHPPercent(i),
        mpp = party:GetMemberMPPercent(i),
        hp = party:GetMemberHP(i),
        mp = party:GetMemberMP(i),
        tp = party:GetMemberTP(i),
        windowName = window.name,
        windowSize = window.size,
        windowPos = window.pos,
        statusIds = buffs
    }
end

---@param pos Vec2
---@param color Vec4
local function DrawDot(pos, color)
    local realColor = imgui.GetColorU32(color)
    imgui.GetWindowDrawList():AddCircleFilled(pos, 3 * Scale, realColor, 0)
end

---@param player PartyMember
---@param showDist boolean
local function DrawName(player, showDist)
    -- the "party status dots" are intended to be a prefix to the player's name,
    -- so we want any target indicators to come beforehand.
    if player.isSubTarget or player.isPartyTarget then
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.XpBar)
        imgui.Text('>')
        imgui.SameLine()
    elseif player.isTarget then
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.TpBarActive)
        imgui.Text('>>')
        imgui.SameLine()
    else
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.White)
    end

    -- unfortunately, we can't draw circles inline (without using images, that
    -- is). instead, we have to manually place them on the screen, and manually
    -- offset the succeeding text.
    local originX, originY = imgui.GetCursorScreenPos()
    local offsetX = 0

    if player.isAllianceLeader then
        DrawDot({originX + offsetX + 3 * Scale, originY + 6 * Scale}, ui.Colors.TpBarActive)
        offsetX = offsetX + 6 * Scale
    end

    if player.isPartyLeader then
        DrawDot({originX + offsetX + 3 * Scale, originY + 6 * Scale}, ui.Colors.FfxiAmber)
        offsetX = offsetX + 6 * Scale
    end

    if player.isSyncTarget then
        DrawDot({originX + offsetX + 3 * Scale, originY + 6 * Scale}, ui.Colors.Red)
        offsetX = offsetX + 6 * Scale
    end

    local windowX = imgui.GetCursorPosX()
    imgui.SetCursorPosX(windowX + offsetX * Scale)

    imgui.Text(player.name)
    imgui.PopStyleColor()

    -- we can use the top right corner for more cool stuff, but imgui doesn't do
    -- right-alignment (as far as i'm aware). again, we must do it ourselves:
    -- calculate the width of our displayed item, and offset it from the width
    -- of the window. this probably won't work with a dynamically-sized window.
    local castbar = AshitaCore:GetMemoryManager():GetCastBar()
    if player.showCastbar and castbar:GetCount() ~= 0 then
        imgui.SameLine()
        imgui.SetCursorPosX((player.windowSize[1] * Scale) - (80 + 10) * Scale)
        ui.DrawBar2(castbar:GetPercent() * 100, 100, ui.Scale({ 80, 8 }, Scale), '')
    elseif showDist and player.entity then
        local dist = string.format('%.1fm', math.sqrt(player.entity.Distance))
        local width = imgui.CalcTextSize(dist) + ui.Styles.WindowPadding[1] * Scale

        imgui.SameLine()
        imgui.SetCursorPosX((player.windowSize[1] * Scale) - width)
        imgui.Text(dist)
    elseif player.job ~= nil then
        local jobStr = ''
        if player.sub ~= nil then
            jobStr = string.format('%s%i/%s%i', player.job, player.jobLevel, player.sub, player.subLevel)
        else
            jobStr = string.format('%s%i', player.job, player.jobLevel)
        end

        local width = imgui.CalcTextSize(jobStr) + ui.Styles.WindowPadding[1] * Scale

        imgui.SameLine()
        imgui.SetCursorPosX((player.windowSize[1] * Scale) - width)
        imgui.Text(jobStr)
    end
end

---@param player PartyMember
local function DrawZone(player)
    local zone = zones[player.zoneId] or string.format('??? ZONEID %s', tostring(player.zoneId))
    imgui.TextDisabled(zone)
end

---@param player PartyMember
local function DrawHp(player)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.HpBar
    local overlay = string.format('%i', player.hp)

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar3(player.hpp, 100, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawMp(player)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.MpBar
    local overlay = string.format('%i', player.mp)

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    imgui.SameLine()
    ui.DrawBar2(player.mpp, 100, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawTp(player)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.TpBar
    local overlay = string.format('%i', player.tp)

    if player.tp >= 1000 then
        barColor = ui.Colors.TpBarActive
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    imgui.SameLine()
    ui.DrawBar2(player.tp, 3000, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawBuffs(player)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ui.Scale({ 2, 2 }, Scale))
    imgui.NewLine()

    for _, buffId in ipairs(player.statusIds) do
        if Textures[buffId] == nil then
            local icon = AshitaCore:GetResourceManager():GetStatusIconByIndex(buffId)
            Textures[buffId] = CreateTexture(buffId, icon)
        end

        local buffIcon = Textures[buffId]
        if buffIcon then
            imgui.SameLine()
            local img = tonumber(ffi.cast("uint32_t", buffIcon))
            imgui.Image(img, ui.Scale({ 16, 16 }, Scale))
        end
    end

    imgui.PopStyleVar()
end

---@param player PartyMember
---@param showDist boolean
local function DrawPartyMember(player, showDist)
    DrawName(player, showDist)

    if player.isInZone then
        DrawHp(player)
        DrawMp(player)
        DrawTp(player)
        DrawBuffs(player)
    else
        DrawZone(player)
    end
end

---@param player PartyMember
local function DrawCompactPartyMember(player)
    -- TODO: indicate targeted by stpt/stal
    if player.isInZone then
        imgui.Text(player.name:slice(0, 3))
        imgui.SameLine()
        DrawHp(player)
    else
        imgui.TextDisabled(player.name:slice(0, 3))
    end
end

local function DrawAlliance(alliance, gOptions)
    ui.DrawUiWindow(alliance, gOptions, function()
        imgui.SetWindowFontScale(Scale)

        local target = AshitaCore:GetMemoryManager():GetTarget()
        local party = AshitaCore:GetMemoryManager():GetParty()
        local stal = ffxi.GetStPartyIndex()
        local showDist = stal ~= nil or IsSubTargetActive(target)

        for _, getMember in pairs(Alliances[alliance.name]) do
            local person = getMember(target, party, stal)

            if person.isActive and person.name ~= '' then
                if alliance.isCompact[1] then
                    DrawCompactPartyMember(person)
                else
                    DrawPartyMember(person, showDist)
                end
            end
        end
    end)
end

local function UpdateAlliances(options)
    Alliances['xitools.us.1'] = {
        GetPlayer:bindn(options),
        GetMember:bindn(1, options.alliance1),
        GetMember:bindn(2, options.alliance1),
        GetMember:bindn(3, options.alliance1),
        GetMember:bindn(4, options.alliance1),
        GetMember:bindn(5, options.alliance1),
    }
    Alliances['xitools.us.2'] = {
        GetMember:bindn(6, options.alliance2),
        GetMember:bindn(7, options.alliance2),
        GetMember:bindn(8, options.alliance2),
        GetMember:bindn(9, options.alliance2),
        GetMember:bindn(10, options.alliance2),
        GetMember:bindn(11, options.alliance2),
    }
    Alliances['xitools.us.3'] = {
        GetMember:bindn(12, options.alliance3),
        GetMember:bindn(13, options.alliance3),
        GetMember:bindn(14, options.alliance3),
        GetMember:bindn(15, options.alliance3),
        GetMember:bindn(16, options.alliance3),
        GetMember:bindn(17, options.alliance3),
    }
end

---@type xitool
local us = {
    Name = 'us',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        hideWhenSolo = T{ false },
        showCastbar = T{ true },
        alliance1 = T{
            isCompact = T{ false },
            isVisible = T{ true },
            name = 'xitools.us.1',
            fullSize = T{ 276, -1 },
            compactSize = T{ -1, -1 },
            size = T{ 276, -1 },
            pos = T{ 392, 628 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        alliance2 = T{
            isCompact = T{ false },
            isVisible = T{ true },
            name = 'xitools.us.2',
            fullSize = T{ 276, -1 },
            compactSize = T{ -1, -1 },
            size = T{ 276, -1 },
            pos = T{ 107, 628 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        alliance3 = T{
            isCompact = T{ false },
            isVisible = T{ true },
            name = 'xitools.us.3',
            fullSize = T{ 276, -1 },
            compactSize = T{ -1, -1 },
            size = T{ 276, -1 },
            pos = T{ 000, 628 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
    },
    UpdateSettings = UpdateAlliances,
    Load = UpdateAlliances,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('us') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.Checkbox('Hide when solo', options.hideWhenSolo)
            imgui.Checkbox('Display cast bar', options.showCastbar)

            if imgui.Checkbox('Compact alliance 1', options.alliance1.isCompact) then
                if options.alliance1.isCompact[1] then
                    options.alliance1.size = options.alliance1.compactSize
                else
                    options.alliance1.size = options.alliance1.fullSize
                end
            end
            if imgui.Checkbox('Compact alliance 2', options.alliance2.isCompact) then
                if options.alliance2.isCompact[1] then
                    options.alliance2.size = options.alliance2.compactSize
                else
                    options.alliance2.size = options.alliance2.fullSize
                end
            end
            if imgui.Checkbox('Compact alliance 3', options.alliance3.isCompact) then
                if options.alliance3.isCompact[1] then
                    options.alliance3.size = options.alliance3.compactSize
                else
                    options.alliance3.size = options.alliance3.fullSize
                end
            end

            if imgui.InputInt2('Alliance 1', options.alliance1.pos) then
                imgui.SetWindowPos(options.alliance1.name, options.alliance1.pos)
            end
            if imgui.InputInt2('Alliance 2', options.alliance2.pos) then
                imgui.SetWindowPos(options.alliance2.name, options.alliance2.pos)
            end
            if imgui.InputInt2('Alliance 3', options.alliance3.pos) then
                imgui.SetWindowPos(options.alliance3.name, options.alliance3.pos)
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        local party = AshitaCore:GetMemoryManager():GetParty()
        local alliCount1 = party:GetAlliancePartyMemberCount1()
        local alliCount2 = party:GetAlliancePartyMemberCount2()
        local alliCount3 = party:GetAlliancePartyMemberCount3()

        Scale = gOptions.uiScale[1]

        if (options.hideWhenSolo[1] and alliCount1 > 1)
        or (not options.hideWhenSolo[1] and alliCount1 > 0) then
            DrawAlliance(options.alliance1, gOptions)
        end
        if alliCount2 > 0 then
            DrawAlliance(options.alliance2, gOptions)
        end
        if alliCount3 > 0 then
            DrawAlliance(options.alliance3, gOptions)
        end
    end,
}

return us
