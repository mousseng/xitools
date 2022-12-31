addon.name    = 'us'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for party status'

require('common')

local ffi = require('ffi')
local d3d8 = require('d3d8')
local d3d8_device = d3d8.get_device()

local Bit = require('bit')
local Ffxi = require('lin.ffxi')
local Jobs = require('lin.jobs')
local Zones = require('lin.zones')
local Styles = require('lin.imgui')
local Imgui = require('imgui')

---@class PartyMember
---@field name string
---@field serverId integer
---@field statusIds integer[]
---@field isInZone boolean
---@field isActive boolean
---@field isTarget boolean
---@field isSubTarget boolean
---@field isPartyTarget boolean
---@field isActionTarget boolean
---@field job string
---@field sub string
---@field jobLevel integer
---@field subLevel integer
---@field hpp integer
---@field mpp integer
---@field hp integer
---@field mp integer
---@field tp integer
---@field zoneId integer
---@field windowName string
---@field windowSize Vec2
---@field windowPos Vec2

local Members = {
    { windowName = 'Us_0', windowSize = { 277, -1 }, windowPos = { 400, 580 }, },
    { windowName = 'Us_1', windowSize = { 277, -1 }, windowPos = { 400, 630 }, },
    { windowName = 'Us_2', windowSize = { 277, -1 }, windowPos = { 400, 680 }, },
    { windowName = 'Us_3', windowSize = { 277, -1 }, windowPos = { 400, 730 }, },
    { windowName = 'Us_4', windowSize = { 277, -1 }, windowPos = { 400, 780 }, },
    { windowName = 'Us_5', windowSize = { 277, -1 }, windowPos = { 400, 830 }, },
}

local Textures = { }

local function GetStPartyIndex()
    -- Courtesy of Thorny from the Ashita discord
    local ptr = AshitaCore:GetPointerManager():Get('party')
    ptr = ashita.memory.read_uint32(ptr)
    ptr = ashita.memory.read_uint32(ptr)
    local isActive = (ashita.memory.read_uint32(ptr + 0x54) ~= 0)
    if isActive then
        return ashita.memory.read_uint8(ptr + 0x50)
    else
        return nil
    end
end

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

---@param player PartyMember
local function DrawName(player)
    if player.isSubTarget or player.isPartyTarget or player.isActionTarget then
        Imgui.PushStyleColor(ImGuiCol_Text, Styles.Colors.XpBar)
        Imgui.Text(string.format('> %s', player.name))
    elseif player.isTarget then
        Imgui.PushStyleColor(ImGuiCol_Text, Styles.Colors.TpBarActive)
        Imgui.Text(string.format('>> %s', player.name))
    else
        Imgui.Text(string.format('%s', player.name))
    end

    if player.job ~= nil then
        local jobs = ''
        if player.sub ~= nil then
            jobs = string.format('%s%i/%s%i', player.job, player.jobLevel, player.sub, player.subLevel)
        else
            jobs = string.format('%s%i', player.job, player.jobLevel)
        end

        local width = Imgui.CalcTextSize(jobs) + Styles.Styles.WindowPadding[1]

        Imgui.SameLine()
        Imgui.SetCursorPosX(player.windowSize[1] - width)
        Imgui.Text(jobs)
    end

    if player.isTarget or player.isSubTarget or player.isPartyTarget or player.isActionTarget then
        Imgui.PopStyleColor()
    end
end

---@param player PartyMember
local function DrawZone(player)
    Imgui.TextDisabled(Zones[player.zoneId])
end

---@param player PartyMember
local function DrawHp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.HpBar
    local overlay = string.format('%i', player.hp)

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Styles.DrawBar2(player.hpp, 100, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawMp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.MpBar
    local overlay = string.format('%i', player.mp)

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.SameLine()
    Styles.DrawBar2(player.mpp, 100, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawTp(player)
    local textColor = Styles.Colors.White
    local barColor = Styles.Colors.TpBar
    local overlay = string.format('%i', player.tp)

    if player.tp >= 1000 then
        barColor = Styles.Colors.TpBarActive
    end

    Imgui.PushStyleColor(ImGuiCol_Text, textColor)
    Imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    Imgui.SameLine()
    Styles.DrawBar2(player.tp, 3000, { 80, 15 }, overlay)
    Imgui.PopStyleColor(2)
end

---@param player PartyMember
local function DrawBuffs(player)
    Imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 8, 2 })
    for _, buffId in pairs(player.statusIds) do
        if buffId > 0 then
            if Textures[buffId] == nil then
                Textures[buffId] = CreateTexture(addon.path .. "icons\\" .. buffId .. ".png", 16, 16)
            end

            local img = tonumber(ffi.cast("uint32_t", Textures[buffId]))
            Imgui.Image(img, { 16, 16 })
            Imgui.SameLine()
        end
    end

    Imgui.PopStyleVar()
    Imgui.NewLine()
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

local function DrawAlliance(allianceNum)
    Styles.DrawWindow('Us', { 277, -1 }, Members[2].windowPos[1], Members[2].windowPos[2], function()
        local player = AshitaCore:GetMemoryManager():GetPlayer()
        local target = AshitaCore:GetMemoryManager():GetTarget()
        local party = AshitaCore:GetMemoryManager():GetParty()

        for i = allianceNum + 0, allianceNum + 5 do
            local stpt = GetStPartyIndex()
            local buffs = party:GetStatusIcons(i)
            if i == 0 then
                buffs = player:GetBuffs()
            end

            ---@type PartyMember
            local member = {
                name = party:GetMemberName(i),
                serverId = party:GetMemberServerId(i),
                isInZone = party:GetMemberZone(i) == party:GetMemberZone(0),
                isActive = party:GetMemberIsActive(i) == 1,
                isTarget = (target:GetIsSubTargetActive() == 0 and party:GetMemberServerId(i) == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and party:GetMemberServerId(i) == target:GetServerId(1)),
                isSubTarget = target:GetIsSubTargetActive() == 1 and party:GetMemberServerId(i) == target:GetServerId(0),
                isPartyTarget = stpt ~= nil and stpt == i,
                isActionTarget = target:GetActionTargetActive() == 1 and party:GetMemberServerId(i) == target:GetActionTargetServerId(),
                job = Jobs.GetJobAbbr(party:GetMemberMainJob(i)),
                sub = Jobs.GetJobAbbr(party:GetMemberSubJob(i)),
                jobLevel = party:GetMemberMainJobLevel(i),
                subLevel = party:GetMemberSubJobLevel(i),
                zoneId = party:GetMemberZone(i),
                hpp = party:GetMemberHPPercent(i),
                mpp = party:GetMemberMPPercent(i),
                hp = party:GetMemberHP(i),
                mp = party:GetMemberMP(i),
                tp = party:GetMemberTP(i),
                windowName = Members[i + 1].windowName,
                windowSize = Members[i + 1].windowSize,
                windowPos = Members[i + 1].windowPos,
                statusIds = buffs
            }

            if member.isActive and member.name ~= '' then
                DrawPartyMember(member)
            end
        end
    end)
end

local function DrawUs()
    DrawAlliance(0)
end

ashita.events.register('d3d_present', 'd3d_present_handler', DrawUs)

---@param e CommandEventArgs
ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/us' then
        return
    end

    e.blocked = true

    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local pIcons = player:GetStatusIcons()
    local p = ''
    for x = 1, 32 do
        p = p .. tostring(pIcons[x]) .. ', '
    end
    print(p)

    local buffs = player:GetBuffs()
    local b = ''
    for _, v in pairs(buffs) do
        b = b .. tostring(v) .. ', '
    end
    print(b)

    local party = AshitaCore:GetMemoryManager():GetParty()
    for i = 0, 5 do
        local mask = party:GetStatusIconsBitMask(i)
        local icons = party:GetStatusIcons(i)
        local s = ''
        for x = 1, 32 do
            local buff = Bit.bor(icons[x], Bit.lshift(mask, 8))
            s = s .. tostring(buff) .. ', '
        end
        print(s)
    end
end)
