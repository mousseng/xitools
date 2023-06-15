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

local function DrawIcon(draw, recast, idx, box)
    local recast1 = GetTimer(recast, wheel[idx][spellLevel])

    local icon = tonumber(ffi.cast('uint32_t', wheel[idx].Icon))
    if recast1 ~= nil then
        draw:AddImage(icon, box.tl, box.br, { 0, 0 }, { 1, 1 }, transparent)
        draw:AddText(Offset(box.tl, 9), shadow, recast1)
        draw:AddText(Offset(box.tl, 8), white, recast1)
    else
        draw:AddImage(icon, box.tl, box.br)
    end
end

local function KeyMod()
    return io.KeyCtrl
        or io.KeyShift
        or io.KeyAlt
        or io.KeySuper
end

local function InBox(point, box)
    return point.x >= box.tl[1]
        and point.y >= box.tl[2]
        and point.x <= box.br[1]
        and point.y <= box.br[2]
end

local function AdvanceWheelTo(position)
    wheelPosition = position % 6
    currentAnim = 0
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

        local idx1 = (wheelPosition + 0) % 6
        local idx2 = (wheelPosition + 1) % 6
        local idx3 = (wheelPosition + 2) % 6
        local idx4 = (wheelPosition + 3) % 6
        local idx5 = (wheelPosition + 4) % 6
        local idx6 = (wheelPosition + 5) % 6

        local rotation = 0
        if currentAnim ~= nil and currentAnim <= animationTime then
            currentAnim = currentAnim + delta
            local animProgress = currentAnim / animationTime
            rotation = animProgress * math.pi / 3
        elseif currentAnim ~= nil and currentAnim > animationTime then
            currentAnim = nil
        end

        local center = { x + (width / 2), y + (height / 2) }
        local pos1 = { center[1] + radius * math.sin(3 * math.pi / -3 + rotation), center[2] + radius * math.cos(3 * math.pi / -3 + rotation) }
        local pos2 = { center[1] + radius * math.sin(4 * math.pi / -3 + rotation), center[2] + radius * math.cos(4 * math.pi / -3 + rotation) }
        local pos3 = { center[1] + radius * math.sin(5 * math.pi / -3 + rotation), center[2] + radius * math.cos(5 * math.pi / -3 + rotation) }
        local pos4 = { center[1] + radius * math.sin(0 * math.pi / -3 + rotation), center[2] + radius * math.cos(0 * math.pi / -3 + rotation) }
        local pos5 = { center[1] + radius * math.sin(1 * math.pi / -3 + rotation), center[2] + radius * math.cos(1 * math.pi / -3 + rotation) }
        local pos6 = { center[1] + radius * math.sin(2 * math.pi / -3 + rotation), center[2] + radius * math.cos(2 * math.pi / -3 + rotation) }

        local box1 = { tl = Offset(pos1, -24), br = Offset(pos1, 24) }
        local box2 = { tl = Offset(pos2, -24), br = Offset(pos2, 24) }
        local box3 = { tl = Offset(pos3, -24), br = Offset(pos3, 24) }
        local box4 = { tl = Offset(pos4, -24), br = Offset(pos4, 24) }
        local box5 = { tl = Offset(pos5, -24), br = Offset(pos5, 24) }
        local box6 = { tl = Offset(pos6, -24), br = Offset(pos6, 24) }

        draw:AddCircle(center, radius, circle, 0, 2.0)
        DrawIcon(draw, recast, idx1, box1)
        DrawIcon(draw, recast, idx2, box2)
        DrawIcon(draw, recast, idx3, box3)
        DrawIcon(draw, recast, idx4, box4)
        DrawIcon(draw, recast, idx5, box5)
        DrawIcon(draw, recast, idx6, box6)

        if io.MouseReleased[1] and not KeyMod() then
            local startPos = io.MouseClickedPos[1]
            local finalPos = io.MousePos

            if InBox(startPos, box1) and InBox(finalPos, box1) then
                CastSpell(wheel[idx1].Ni)
            elseif InBox(startPos, box2) and InBox(finalPos, box2) then
                CastSpell(wheel[idx2].Ni)
            elseif InBox(startPos, box3) and InBox(finalPos, box3) then
                CastSpell(wheel[idx3].Ni)
            elseif InBox(startPos, box4) and InBox(finalPos, box4) then
                CastSpell(wheel[idx4].Ni)
            elseif InBox(startPos, box5) and InBox(finalPos, box5) then
                CastSpell(wheel[idx5].Ni)
            elseif InBox(startPos, box6) and InBox(finalPos, box6) then
                CastSpell(wheel[idx6].Ni)
            end
        elseif io.MouseReleased[2] and not KeyMod() then
            local startPos = io.MouseClickedPos[2]
            local finalPos = io.MousePos

            if InBox(startPos, box1) and InBox(finalPos, box1) then
                CastSpell(wheel[idx1].Ichi)
            elseif InBox(startPos, box2) and InBox(finalPos, box2) then
                CastSpell(wheel[idx2].Ichi)
            elseif InBox(startPos, box3) and InBox(finalPos, box3) then
                CastSpell(wheel[idx3].Ichi)
            elseif InBox(startPos, box4) and InBox(finalPos, box4) then
                CastSpell(wheel[idx4].Ichi)
            elseif InBox(startPos, box5) and InBox(finalPos, box5) then
                CastSpell(wheel[idx5].Ichi)
            elseif InBox(startPos, box6) and InBox(finalPos, box6) then
                CastSpell(wheel[idx6].Ichi)
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
