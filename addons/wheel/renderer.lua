local bit = require('bit')
local ffi = require('ffi')
local d3d8 = require('d3d8')
local imgui = require('imgui')

local io = imgui.GetIO()
local gfxDevice = d3d8.get_device()

local white = imgui.GetColorU32({ 1, 1, 1, 1.0 })
local shadow = imgui.GetColorU32({ 0, 0, 0, 0.6 })
local transparent = imgui.GetColorU32({ 1, 1, 1, 0.3 })

local oneTurn = math.pi / 3
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
    currentPos = 0,
    targetPos = 0,
    currentRot = 0,
    targetRot = 0,
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
    if animation.currentPos ~= animation.targetPos then
        animation.targetRot = animation.targetPos * oneTurn

        -- if we're spinning past the "end" of the circle, we want the numbers
        -- to keep going up so the animation continues smoothly in one direction
        -- TODO: maybe we allow backwards rotation for out-of-order casts?
        if animation.targetRot < animation.currentRot then
            animation.targetRot = animation.targetRot + circumference
        end

        local distance = (animation.targetPos - animation.currentPos) % 6
        local deltaTime = ashita.time.clock().ms - animation.lastFrame
        local deltaRot = (deltaTime / animation.speed) * (oneTurn * distance)
        local newRot = math.min(animation.currentRot + deltaRot, animation.targetRot)

        animation.currentRot = newRot

        -- once we've completed the rotation, mark the new current pos so we can
        -- skip these calculations until the next cast
        if animation.currentRot == animation.targetRot then
            animation.currentPos = animation.targetPos
        end
    else
        -- once we're settled in a new spot, just make sure to chop off extra
        -- rotation to keep ourselves close to the [0,2pi] range
        if animation.currentRot > circumference then
            animation.currentRot = animation.currentRot - circumference
        end
    end

    -- move on to figuring out offsets and recasts for each spoke
    for i = 0, 5 do
        -- add 3 to move the "next spell" to the top of the wheel instead of
        -- the bottom; divide by -3 to get clockwise rotation
        local posX = drawing.radius * math.sin((i + 3) * math.pi / -3 + animation.currentRot)
        local posY = drawing.radius * math.cos((i + 3) * math.pi / -3 + animation.currentRot)

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
                    state.cast(i, state.level)
                end
            elseif rClick and clickable then
                local startPos = io.MouseClickedPos[2]
                local finalPos = io.MousePos

                if InBox(startPos, tl, br) and InBox(finalPos, tl, br) then
                    state.cast(i, state.alt)
                end
            end
        end

    end
    imgui.End()

    if state.debug then
        if imgui.Begin('wheel_debug') then
            imgui.Text('animation:')
            imgui.Text(string.format('  speed      = %d', animation.speed))
            imgui.Text(string.format('  currentPos = %d', animation.currentPos))
            imgui.Text(string.format('  targetPos  = %d', animation.targetPos))
            imgui.Text(string.format('  currentRot = %d', animation.currentRot / circumference * 360))
            imgui.Text(string.format('  targetRot  = %d', animation.targetRot / circumference * 360))
        end
        imgui.End()
    end

    animation.lastFrame = ashita.time.clock().ms
end

return renderer
