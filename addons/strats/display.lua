require('common')
local d3d = require('d3d8')
local ffi = require('ffi')

local function loadTexture(filename)
    local filepath = string.format('%s\\%s', addon.path, filename)
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    if ffi.C.D3DXCreateTextureFromFileA(d3d.get_device(), filepath, texPtr) ~= ffi.C.S_OK then
        return nil
    end

    return d3d.gc_safe_release(ffi.cast('IDirect3DTexture8*', texPtr[0]))
end

local scale = ffi.new('D3DXVECTOR2', { 1.0, 1.0 })
local position = ffi.new('D3DXVECTOR2', { 0, 0 })
local color = d3d.D3DCOLOR_ARGB(255, 255, 255, 255)

local pipsTexture    = loadTexture('pips.png')
local pipsRectFrame  = ffi.new('RECT', {   0,   0,  64,  64 })
local pipsRectFill   = ffi.new('RECT', {  64,   0, 128,  64 })
local pipsRectAccent = ffi.new('RECT', {  64,  64, 128, 128 })

local gaugeTexture   = loadTexture('gauge.png')
local gaugeRectFrame = ffi.new('RECT', {   0,   0, 490, 150 })
local gaugeRectFill  = ffi.new('RECT', {   0, 160, 360, 250 })
local gaugeRectBack  = ffi.new('RECT', {   0, 250, 360, 340 })

local display = { }

function display.drawPipFrame(sprite, x, y)
    position.x = x
    position.y = y
    sprite:Draw(pipsTexture, pipsRectFrame, scale, nil, 0.0, position, color)
end

function display.drawPipFill(sprite, x, y, colorOverride)
    position.x = x
    position.y = y
    sprite:Draw(pipsTexture, pipsRectFill, scale, nil, 0.0, position, colorOverride or color)
end

function display.drawPipAccent(sprite, x, y, colorOverride)
    position.x = x
    position.y = y
    sprite:Draw(pipsTexture, pipsRectAccent, scale, nil, 0.0, position, colorOverride or color)
end

function display.drawGaugeFrame(sprite, x, y)
    position.x = x
    position.y = y
    sprite:Draw(gaugeTexture, gaugeRectFrame, scale, nil, 0.0, position, color)
end

function display.drawGaugeBack(sprite, x, y)
    position.x = x + 95
    position.y = y + 18
    sprite:Draw(gaugeTexture, gaugeRectBack, scale, nil, 0.0, position, color)
end

function display.drawGaugeFill(sprite, x, y)
    position.x = x + 95
    position.y = y + 18
    sprite:Draw(gaugeTexture, gaugeRectFill, scale, nil, 0.0, position, color)
end

return display
