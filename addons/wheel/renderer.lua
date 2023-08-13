local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local imgui = require('imgui')

local io = imgui.GetIO()
local gfxDevice = d3d8.get_device()

local white = imgui.GetColorU32({ 1, 1, 1, 1.0 })
local shadow = imgui.GetColorU32({ 0, 0, 0, 0.6 })
local transparent = imgui.GetColorU32({ 1, 1, 1, 0.3 })

local turn = math.pi / 3
local circumference = math.pi * 2

local flags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoBackground)

local function InBox(point, tl, br)
    return point.x >= tl[1]
        and point.y >= tl[2]
        and point.x <= br[1]
        and point.y <= br[2]
end

local function CreateTexture(filePath)
    -- Courtesy of Thorny's mobDb
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    if ffi.C.D3DXCreateTextureFromFileA(gfxDevice, filePath, texPtr) == ffi.C.S_OK then
        return d3d8.gc_safe_release(ffi.cast('IDirect3DTexture8*', texPtr[0]))
    end

    return nil
end

local function Spoke()
    return {
        icon = nil,
        recast = {
            Ichi = nil,
            Ni   = nil,
            San  = nil,
        },
        tools = 0,
        pos = { 0, 0 },
        tl = { -24, -24 },
        br = { 24, 24 },
    }
end

local drawing = {
    size = { 190, 190 },
    radius = 70,
    center = { 0, 0 },
    thickness = 2,
    segments = 0,
    rotation = math.pi,
    spokes = {
        [0] = Spoke(),
        [1] = Spoke(),
        [2] = Spoke(),
        [3] = Spoke(),
        [4] = Spoke(),
        [5] = Spoke(),
    },
}

local animation = {
    speed = 400,
    lastFrame = ashita.time.clock().ms,
    current = nil,
    progress = nil,
    distance = nil,
}

local renderer = {
    drawing = drawing,
    animation = animation,
}

function renderer.lock()
    flags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoMove)
end

function renderer.unlock()
    flags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoBackground)
end

function renderer.init(state)
    local path = "%s\\img\\%s.png"
    for i = 0, 5 do
        drawing.spokes[i].icon = CreateTexture(path:format(addon.path, state.spokes[i].Name))
    end
end

function renderer.calc(state)
    local delta = ashita.time.clock().ms - animation.lastFrame

    -- if we are currently animating, calculate out the partial position
    if animation.current ~= nil and animation.current <= animation.speed then
        animation.current = animation.current + delta

        -- in order to ensure we don't over-rotate, chop off any excess animation
        -- time over the set speed
        local excess = math.max(0, animation.current - animation.speed)
        animation.progress = (delta - excess) / animation.speed

        -- multiply out the partial rotation
        drawing.rotation = drawing.rotation + animation.progress * animation.distance * turn
    -- if we've finished animating, reset the animation state
    elseif animation.progress ~= nil and animation.progress > animation.speed then
        animation.current = nil
        animation.progress = nil
        animation.distance = nil

        -- just so we don't increment forever, chop off any excess circumferences
        if drawing.rotation > circumference then
            drawing.rotation = drawing.rotation - circumference
        end
    end

    -- move on to figuring out offsets and recasts for each spoke
    for i = 0, 5 do
        -- divide by -3 to get clockwise rotation
        local posX = drawing.radius * math.sin(i * math.pi / -3 + drawing.rotation)
        local posY = drawing.radius * math.cos(i * math.pi / -3 + drawing.rotation)

        drawing.spokes[i].pos = { posX, posY }
        drawing.spokes[i].tools = state.get_tools(i)
        drawing.spokes[i].recast.Ichi = state.get_timer(i, 'Ichi')
        drawing.spokes[i].recast.Ni = state.get_timer(i, 'Ni')
        drawing.spokes[i].recast.San = state.get_timer(i, 'San')
    end
end

function renderer.draw(state)
    imgui.SetNextWindowSize(drawing.size)
    if imgui.Begin('wheel', { true }, flags) then
        local draw = imgui.GetWindowDrawList()
        local lClick = io.MouseReleased[1]
        local rClick = io.MouseReleased[2]
        local clickable = not (io.KeyCtrl or io.KeyShift or io.KeyAlt or io.KeySuper)

        -- find the screen-based coordinates that will be the center of our circle
        local x, y = imgui.GetWindowPos()
        drawing.center = { x + (drawing.size[1] / 2), y + (drawing.size[2] / 2) }
        draw:AddCircle(drawing.center, drawing.radius, transparent, 0, 2.0)

        for i, spoke in pairs(drawing.spokes) do
            local icon = tonumber(ffi.cast('uint32_t', spoke.icon))
            local tl = { drawing.center[1] + spoke.pos[1] + spoke.tl[1], drawing.center[2] + spoke.pos[2] + spoke.tl[2] }
            local br = { drawing.center[1] + spoke.pos[1] + spoke.br[1], drawing.center[2] + spoke.pos[2] + spoke.br[2] }

            if spoke.recast[state.level] ~= nil then
                draw:AddImage(icon, tl, br, { 0, 0 }, { 1, 1 }, transparent)
                draw:AddText({ tl[1] + 9, tl[2] + 9 }, shadow, spoke.recast[state.level])
                draw:AddText({ tl[1] + 8, tl[2] + 8 }, white, spoke.recast[state.level])
            elseif spoke.tools == 0 then
                draw:AddImage(icon, tl, br, { 0, 0 }, { 1, 1 }, transparent)
            else
                draw:AddImage(icon, tl, br)
            end

            local toolCount = tostring(spoke.tools)
            local w, h = imgui.CalcTextSize(toolCount)
            draw:AddText({ br[1] - 6 - w, br[2] - 4 - h }, shadow, toolCount)
            draw:AddText({ br[1] - 7 - w, br[2] - 5 - h }, white, toolCount)

            if lClick and clickable then
                local startPos = io.MouseClickedPos[1]
                local finalPos = io.MousePos

                if InBox(startPos, tl, br) and InBox(finalPos, tl, br) then
                    state.cast(i, 'Ni')
                end
            elseif rClick and clickable then
                local startPos = io.MouseClickedPos[2]
                local finalPos = io.MousePos

                if InBox(startPos, tl, br) and InBox(finalPos, tl, br) then
                    state.cast(i, 'Ichi')
                end
            end
        end

        imgui.End()
    end

    animation.lastFrame = ashita.time.clock().ms
end

return renderer
