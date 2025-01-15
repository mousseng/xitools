require('common')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')

local dxDevice = d3d.get_device()
local resx = AshitaCore:GetResourceManager()
local texCache = { }
local bitmapTex = { }

local function setAlpha(bitmap)
    -- the in-game bitmap data excludes the 14-byte BMP file header,
    -- and instead begins at the 40-byte DIB header. add 1 to account
    -- for lua's 1-based indexes
    local bmpStart = 40 + 1
    local bytes = bitmap:totable()

    -- each icon is 32x32 pixels and we're going to iterate over the
    -- bytes one pixel at a time (ie, 4 bytes). start at 0 since we're
    -- doing offset maths
    for i = 0, (32 * 32) - 1 do
        local pixelStart = i * 4
        local alpha = bytes[bmpStart + pixelStart + 3]

        -- any non-opaque pixel should be banished to the colorkey realm
        if alpha < 0xFF then
            bytes[bmpStart + pixelStart + 0] = 0
            bytes[bmpStart + pixelStart + 1] = 0
            bytes[bmpStart + pixelStart + 2] = 0
        end
    end

    -- turn our bytes back into chars, and our chars into a string
    return bytes:map(string.char):join()
end

function bitmapTex:createTexture(statusId, icon)
    if icon == nil then
        log.err('missing icon information for status %d', statusId)
        return 'missing'
    end

    -- courtesy of Thorny's partybuffs
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    local result = ffi.C.D3DXCreateTextureFromFileInMemoryEx(
        dxDevice,              -- pDevice:     LPDIRECT3DDEVICE8
        setAlpha(icon.Bitmap), -- pSrcData:    LPCVOID
        icon.ImageSize,        -- SrcDataSize: UINT
        0,                     -- Width:       UINT
        0,                     -- Height:      UINT
        1,                     -- MipLevels:   UINT
        0,                     -- Usage:       DWORD
        ffi.C.D3DFMT_A8R8G8B8, -- Format:      D3DFORMAT
        ffi.C.D3DPOOL_MANAGED, -- Pool:        D3DPOOL
        ffi.C.D3DX_DEFAULT,    -- Filter:      DWORD
        ffi.C.D3DX_DEFAULT,    -- MipFilter:   DWORD
        0xFF000000,            -- ColorKey:    D3DCOLOR
        nil,                   -- pSrcInfo:    D3DXIMAGE_INFO*
        nil,                   -- pPalette:    PALETTEENTRY*
        texPtr)                -- ppTexture:   LPDIRECT3DTEXTURE8*

    if result ~= ffi.C.S_OK then
        log.err('failed to make texture for status %d', statusId)
        return 'missing'
    end

    return d3d.gc_safe_release(ffi.cast('IDirect3DTexture8*', texPtr[0]))
end

function bitmapTex:getTexture(statusId)
    if not texCache[statusId] then
        local icon = resx:GetStatusIconByIndex(statusId)
        texCache[statusId] = self:createTexture(statusId, icon)
    end

    return texCache[statusId]
end

return bitmapTex
