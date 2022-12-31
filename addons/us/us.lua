addon.name    = 'us'
addon.author  = 'lin'
addon.version = '1.0.0'
addon.desc    = 'A simple text-based HUD for party status'

require('common')

local ffi = require('ffi')
local d3d8 = require('d3d8')
local d3d8_device = d3d8.get_device()

local Bit = require('bit')
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

local Textures = { }

local function IsChatExpanded()
    -- courtesy of Syllendel
	local pattern = "83EC??B9????????E8????????0FBF4C24??84C0"
	local patternAddress = ashita.memory.find("FFXiMain.dll", 0, pattern, 0x04, 0);
	local chatExpandedPointer = ashita.memory.read_uint32(patternAddress)+0xF1
	local chatExpandedValue = ashita.memory.read_uint8(chatExpandedPointer)

	return chatExpandedValue ~= 0
end

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
                    high_bits = Bit.lshift(Bit.band(Bit.rshift(icons_hi, 2* b), 3), 8)
                else
                    local buffer = math.floor(icons_hi / 0xffffffff)
                    high_bits = Bit.lshift(Bit.band(Bit.rshift(buffer, 2 * (b - 16)), 3), 8)
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
    local stpt = GetStPartyIndex()
    local buffs = player:GetBuffs()

    return {
        name = party:GetMemberName(0),
        serverId = serverId,
        isInZone = true,
        isActive = true,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stpt ~= nil and stpt == 0,
        isActionTarget = target:GetActionTargetActive() == 1 and serverId == target:GetActionTargetServerId(),
        job = Jobs.GetJobAbbr(party:GetMemberMainJob(0)),
        sub = Jobs.GetJobAbbr(party:GetMemberSubJob(0)),
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
    local stpt = GetStPartyIndex()
    local buffs = GetStatusEffects(party, serverId)

    return {
        name = party:GetMemberName(i),
        serverId = serverId,
        isInZone = party:GetMemberZone(i) == party:GetMemberZone(0),
        isActive = party:GetMemberIsActive(i) == 1,
        isTarget = (target:GetIsSubTargetActive() == 0 and serverId == target:GetServerId(0)) or (target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(1)),
        isSubTarget = target:GetIsSubTargetActive() == 1 and serverId == target:GetServerId(0),
        isPartyTarget = stpt ~= nil and stpt == i,
        isActionTarget = target:GetActionTargetActive() == 1 and serverId == target:GetActionTargetServerId(),
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
        windowName = window.name,
        windowSize = window.size,
        windowPos = window.pos,
        statusIds = buffs
    }
end

local AllianceWindows = {
    { name = 'Us_1', size = { 277, -1 }, pos = { 392, 628 }, isVisible = function(party) return party:GetAlliancePartyMemberCount1() > 0 end },
    { name = 'Us_2', size = { 277, -1 }, pos = { 107, 628 }, isVisible = function(party) return party:GetAlliancePartyMemberCount2() > 0 end },
    { name = 'Us_3', size = { 277, -1 }, pos = { 000, 628 }, isVisible = function(party) return party:GetAlliancePartyMemberCount3() > 0 end },
}

local Alliances = {
    ['Us_1'] = {
        GetPlayer:bindn(AllianceWindows[1]),
        GetMember:bindn(1, AllianceWindows[1]),
        GetMember:bindn(2, AllianceWindows[1]),
        GetMember:bindn(3, AllianceWindows[1]),
        GetMember:bindn(4, AllianceWindows[1]),
        GetMember:bindn(5, AllianceWindows[1]),
    },
    ['Us_2'] = {
        GetMember:bindn(6, AllianceWindows[2]),
        GetMember:bindn(7, AllianceWindows[2]),
        GetMember:bindn(8, AllianceWindows[2]),
        GetMember:bindn(9, AllianceWindows[2]),
        GetMember:bindn(10, AllianceWindows[2]),
        GetMember:bindn(11, AllianceWindows[2]),
    },
    ['Us_3'] = {
        GetMember:bindn(12, AllianceWindows[3]),
        GetMember:bindn(13, AllianceWindows[3]),
        GetMember:bindn(14, AllianceWindows[3]),
        GetMember:bindn(15, AllianceWindows[3]),
        GetMember:bindn(16, AllianceWindows[3]),
        GetMember:bindn(17, AllianceWindows[3]),
    },
}

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
    Imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 2, 2 })
    for i = 1, 32 do
        local buffId = player.statusIds[i]
        if buffId ~= nil and buffId >= 0 then
            if Textures[buffId] == nil then
                Textures[buffId] = CreateTexture(addon.path .. "icons\\" .. buffId .. ".png")
            end

            if i ~= 1 and i ~= 32 then
                Imgui.SameLine()
            end

            local img = tonumber(ffi.cast("uint32_t", Textures[buffId]))
            Imgui.Image(img, { 16, 16 })
        end
    end

    Imgui.PopStyleVar()
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
    local party = AshitaCore:GetMemoryManager():GetParty()
    if not alliance.isVisible(party) then return end

    Styles.DrawWindow(alliance.name, alliance.size, alliance.pos[1], alliance.pos[2], function()
        for _, getMember in pairs(Alliances[alliance.name]) do
            local person = getMember()

            if person.isActive and person.name ~= '' then
                DrawPartyMember(person)
            end
        end
    end)
end

local function DrawUs()
    if IsChatExpanded() then
        return
    end

    for _, alliance in pairs(AllianceWindows) do
        DrawAlliance(alliance)
    end
end

ashita.events.register('d3d_present', 'd3d_present_handler', DrawUs)

---@param e CommandEventArgs
ashita.events.register('command', 'command_handler', function(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/us' then
        return
    end

    e.blocked = true
end)
