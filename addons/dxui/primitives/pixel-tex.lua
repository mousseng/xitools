require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')

local assetsPath = string.format('%s\\assets', addon.path)

local function loadTexture(filename)
    local filepath = string.format('%s\\%s', assetsPath, filename)
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    if ffi.C.D3DXCreateTextureFromFileA(d3d.get_device(), filepath, texPtr) ~= ffi.C.S_OK then
        log.err('failed to create texture from file "%s"', filepath)
        return nil
    end

    return d3d.gc_safe_release(ffi.cast('IDirect3DTexture8*', texPtr[0]))
end

return loadTexture('white.png')
