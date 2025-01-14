require('common')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')

local dxDevice = d3d.get_device()
local resx = AshitaCore:GetResourceManager()
local texCache = { }
local bitmapTex = { }

-- TODO: some of our textures aren't doing transparency properly; white bg
function bitmapTex:createTexture(statusId, icon)
    if icon == nil then
        log.err('missing icon information for status %d', statusId)
        return 'missing'
    end

    -- courtesy of Thorny's partybuffs
    local texPtr = ffi.new('IDirect3DTexture8*[1]')
    local result = ffi.C.D3DXCreateTextureFromFileInMemoryEx(
        dxDevice,              -- pDevice:     LPDIRECT3DDEVICE8
        icon.Bitmap,           -- pSrcData:    LPCVOID
        icon.ImageSize,        -- SrcDataSize: UINT
        0xFFFFFFFF,            -- Width:       UINT
        0xFFFFFFFF,            -- Height:      UINT
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
