addon.name    = 'wheel'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'gavlan wheel, gavlan deal'

require('common')
local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local imgui = require('imgui')

local io = imgui.GetIO()
local gfxDevice = d3d8.get_device()
local animationTime = 400
local currentAnim = nil
local currentDist = nil
local lastFrame = ashita.time.clock().ms
local spellLevel = 'Ni'
local wheelPosition = 0
local wheel = {
    [0] = { Name = 'Doton',  Ichi = 329, Ni = 330, San = 331 },
    [1] = { Name = 'Huton',  Ichi = 326, Ni = 327, San = 328 },
    [2] = { Name = 'Hyoton', Ichi = 323, Ni = 324, San = 325 },
    [3] = { Name = 'Katon',  Ichi = 320, Ni = 321, San = 322 },
    [4] = { Name = 'Suiton', Ichi = 335, Ni = 336, San = 337 },
    [5] = { Name = 'Raiton', Ichi = 332, Ni = 333, San = 334 },
}
local wheelLookup = {
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
}

local white = imgui.GetColorU32({ 1, 1, 1, 1.0 })
local shadow = imgui.GetColorU32({ 0, 0, 0, 0.4 })
local circle = imgui.GetColorU32({ 1, 1, 1, 0.1 })
local transparent = imgui.GetColorU32({ 1, 1, 1, 0.3 })
local turn = math.pi / 3
local rotation = math.pi
local radius = 70
local height = radius * 3
local width = radius * 3
local size = { height, width }
local flags = bit.bor(ImGuiWindowFlags_NoDecoration)

local function CreateTexture(filePath)
    -- Courtesy of Thorny's mobDb
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    if ffi.C.D3DXCreateTextureFromFileA(gfxDevice, filePath, texPtr) == ffi.C.S_OK then
        return d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', texPtr[0]))
    end

    return nil
end

local function Offset(vec2, offset)
    return { vec2[1] + offset, vec2[2] + offset }
end

local function GetTimer(recast, spellId)
    local remaining = recast:GetSpellTimer(spellId)
    if remaining >= 60 then
        return string.format('%i', math.floor(remaining / 60))
    end

    return nil
end

local function DrawIcon(draw, recast, idx, tl, br)
    local recast1 = GetTimer(recast, wheel[idx][spellLevel])

    local icon = tonumber(ffi.cast('uint32_t', wheel[idx].Icon))
    if recast1 ~= nil then
        draw:AddImage(icon, tl, br, { 0, 0 }, { 1, 1 }, transparent)
        draw:AddText(Offset(tl, 9), shadow, recast1)
        draw:AddText(Offset(tl, 8), white, recast1)
    else
        draw:AddImage(icon, tl, br)
    end
end

local function KeyMod()
    return io.KeyCtrl
        or io.KeyShift
        or io.KeyAlt
        or io.KeySuper
end

local function InBox(point, tl, br)
    return point.x >= tl[1]
        and point.y >= tl[2]
        and point.x <= br[1]
        and point.y <= br[2]
end

local function AdvanceWheelTo(position)
    currentAnim = 0
    currentDist = (position - wheelPosition + 6) % 6
    wheelPosition = position % 6
end

local function CastSpell(id)
    local command = '/ma "%s" <t>'
    local spell = AshitaCore:GetResourceManager():GetSpellById(id).Name[1]
    AshitaCore:GetChatManager():QueueCommand(1, command:format(spell))
end

local function OnLoad()
    local path = "%s\\img\\%s.png"
    for _, spell in pairs(wheel) do
        spell.Icon = CreateTexture(path:format(addon.path, spell.Name))
    end
end

local function OnCommand(e)
    local args = e.command:args()
    if #args == 0 or args[1] ~= '/wheel' then
        return
    end

    if #args == 1 then
        -- TODO: print help
        return
    end

    if args[2]:lower() == 'ichi' or args[2] == '1' then
        CastSpell(wheel[wheelPosition.Ichi])
    elseif args[2]:lower() == 'ni' or args[2] == '2' then
        CastSpell(wheel[wheelPosition.Ni])
    elseif args[2]:lower() == 'san' or args[2] == '3' then
        CastSpell(wheel[wheelPosition.San])
    end
end

---@param e PacketInEventArgs
local function OnPacketIn(e)
    if e.id == 0x028 then
        local actor = ashita.bits.unpack_be(e.data_raw, 40, 32)
        local type = ashita.bits.unpack_be(e.data_raw, 82, 4)
        local spell = ashita.bits.unpack_be(e.data_raw, 86, 16)

        if actor == GetPlayerEntity().ServerId and type == 4 and spell >= 320 and spell <= 337 then
            AdvanceWheelTo(wheelLookup[spell] + 1)
        end
    end
end

local function OnPresent()
    local delta = ashita.time.clock().ms - lastFrame
    imgui.SetNextWindowSize(size)
    if imgui.Begin('wheel', { true }, flags) then
        local recast = AshitaCore:GetMemoryManager():GetRecast()
        local draw = imgui.GetWindowDrawList()
        local x, y = imgui.GetWindowPos()
        local lClick = io.MouseReleased[1]
        local rClick = io.MouseReleased[2]
        local clickable = not KeyMod()

        if currentAnim ~= nil and currentAnim <= animationTime then
            currentAnim = currentAnim + delta
            local excess = math.max(0, currentAnim - animationTime)
            local animProgress = (delta - excess) / animationTime
            rotation = rotation + animProgress * turn * currentDist
        elseif currentAnim ~= nil and currentAnim > animationTime then
            currentAnim = nil
            currentDist = nil
        end

        local center = { x + (width / 2), y + (height / 2) }
        draw:AddCircle(center, radius, circle, 0, 2.0)

        for i = 0, 5 do
            -- divide by -3 to get clockwise rotation
            local posX = center[1] + radius * math.sin(i * math.pi / -3 + rotation)
            local posY = center[2] + radius * math.cos(i * math.pi / -3 + rotation)

            local topLeft = { posX - 24, posY - 24 }
            local bottomRight = { posX + 24, posY + 24 }
            DrawIcon(draw, recast, i, topLeft, bottomRight)

            if lClick and clickable then
                local startPos = io.MouseClickedPos[1]
                local finalPos = io.MousePos

                if InBox(startPos, topLeft, bottomRight) and InBox(finalPos, topLeft, bottomRight) then
                    CastSpell(wheel[i].Ni)
                end
            elseif rClick and clickable then
                local startPos = io.MouseClickedPos[2]
                local finalPos = io.MousePos

                if InBox(startPos, topLeft, bottomRight) and InBox(finalPos, topLeft, bottomRight) then
                    CastSpell(wheel[i].Ichi)
                end
            end
        end

        imgui.End()
    end

    lastFrame = ashita.time.clock().ms
end

ashita.events.register('load', 'on_load', OnLoad)
ashita.events.register('command', 'on_command', OnCommand)
ashita.events.register('packet_in', 'on_packet_in', OnPacketIn)
ashita.events.register('d3d_present', 'on_d3d_present', OnPresent)
