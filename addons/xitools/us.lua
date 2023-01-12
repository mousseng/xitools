require('common')
local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local d3d8_device = d3d8.get_device()
local imgui = require('imgui')
local ui = require('ui')

local ffxi = require('utils.ffxi')
local zones = require('utils.zones')

local Textures = { }
local Alliances = { }

---@param filePath string
local function CreateTexture(filePath)
    -- Courtesy of Thorny's mobDb
    local dx_texture_ptr = ffi.new('IDirect3DTexture8*[1]')
    if (ffi.C.D3DXCreateTextureFromFileA(d3d8_device, filePath, dx_texture_ptr) == ffi.C.S_OK) then
        return d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', dx_texture_ptr[0]))
    else
        return nil
    end
end

local function GetStatusEffects(party, serverId)
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

local function GetPlayer(window)
    local target = AshitaCore:GetMemoryManager():GetTarget()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local party = AshitaCore:GetMemoryManager():GetParty()

    local serverId = party:GetMemberServerId(0)
    local stpt = ffxi.GetStPartyIndex()
    local buffs = player:GetBuffs()

    return {
        name = party:GetMemberName(0),
        serverId = serverId,
        isInZone = true,
        isActive = true,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stpt ~= nil and stpt == 0,
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
        windowName = window.name,
        windowSize = window.size,
        windowPos = window.pos,
        statusIds = buffs
    }
end

local function GetMember(i, window)
    local target = AshitaCore:GetMemoryManager():GetTarget()
    local party = AshitaCore:GetMemoryManager():GetParty()

    local serverId = party:GetMemberServerId(i)
    local stpt = ffxi.GetStPartyIndex()
    local buffs = GetStatusEffects(party, serverId)

    return {
        name = party:GetMemberName(i),
        serverId = serverId,
        isInZone = party:GetMemberZone(i) == party:GetMemberZone(0),
        isActive = party:GetMemberIsActive(i) == 1,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stpt ~= nil and stpt == i,
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

---@param player PartyMember
local function DrawName(player)
    if player.isSubTarget or player.isPartyTarget then
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.XpBar)
        imgui.Text(string.format('> %s', player.name))
        imgui.PopStyleColor()
    elseif player.isTarget then
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.TpBarActive)
        imgui.Text(string.format('>> %s', player.name))
        imgui.PopStyleColor()
    else
        imgui.Text(string.format('%s', player.name))
    end

    if player.job ~= nil then
        local jobStr = ''
        if player.sub ~= nil then
            jobStr = string.format('%s%i/%s%i', player.job, player.jobLevel, player.sub, player.subLevel)
        else
            jobStr = string.format('%s%i', player.job, player.jobLevel)
        end

        local width = imgui.CalcTextSize(jobStr) + ui.Styles.WindowPadding[1]

        imgui.SameLine()
        imgui.SetCursorPosX(player.windowSize[1] - width)
        imgui.Text(jobStr)
    end
end

---@param player PartyMember
local function DrawZone(player)
    imgui.TextDisabled(zones[player.zoneId])
end

---@param player PartyMember
local function DrawHp(player)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.HpBar
    local overlay = string.format('%i', player.hp)

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar2(player.hpp, 100, { 80, 15 }, overlay)
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
    ui.DrawBar2(player.mpp, 100, { 80, 15 }, overlay)
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
    ui.DrawBar2(player.tp, 3000, { 80, 15 }, overlay)
    imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawBuffs(player)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 2, 2 })
    for i = 1, 32 do
        local buffId = player.statusIds[i]
        if buffId ~= nil and buffId >= 0 then
            if Textures[buffId] == nil then
                Textures[buffId] = CreateTexture(addon.path .. "icons\\" .. buffId .. ".png")
            end

            if i ~= 1 and i ~= 32 then
                imgui.SameLine()
            end

            local img = tonumber(ffi.cast("uint32_t", Textures[buffId]))
            imgui.Image(img, { 16, 16 })
        end
    end

    imgui.PopStyleVar()
end

---@param player PartyMember
local function DrawPartyMember(player)
    DrawName(player)

    if player.isInZone then
        DrawHp(player)
        DrawMp(player)
        DrawTp(player)
        DrawBuffs(player)
    else
        DrawZone(player)
    end
end

local function DrawAlliance(alliance)
    ui.DrawWindow(alliance, function()
        for _, getMember in pairs(Alliances[alliance.name]) do
            local person = getMember()

            if person.isActive and person.name ~= '' then
                DrawPartyMember(person)
            end
        end
    end)
end

---@type xitool
local us = {
    Load = function(options)
        Alliances['xitools.us.1'] = {
            GetPlayer:bindn(options.alliance1),
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
    end,
    HandlePacket = function(e, options) end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('us') then
            imgui.Checkbox('Enabled', options.isVisible)
            imgui.Checkbox('Hide when solo', options.hideWhenSolo)
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
    DrawMain = function(options)
        local party = AshitaCore:GetMemoryManager():GetParty()
        local alliCount1 = party:GetAlliancePartyMemberCount1()
        local alliCount2 = party:GetAlliancePartyMemberCount2()
        local alliCount3 = party:GetAlliancePartyMemberCount3()

        if (options.hideWhenSolo[1] and alliCount1 > 1)
        or (not options.hideWhenSolo[1] and alliCount1 > 0) then
            DrawAlliance(options.alliance1)
        end
        if alliCount2 > 0 then
            DrawAlliance(options.alliance2)
        end
        if alliCount3 > 0 then
            DrawAlliance(options.alliance3)
        end
    end,
}

return us
