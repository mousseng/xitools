require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')

local box2 = { }

function box2.new()
    local b = { }

    -- we'll colorize each piece by subtracting from white, so
    -- only a single 1-pixel texture is needed
    b.texture = require('primitives/pixel-tex')

    b.bgColor = d3d.D3DCOLOR_ARGB(255, 0, 0, 0)
    b.borderColor = d3d.D3DCOLOR_ARGB(255, 0, 0, 0)

    -- default to a 128x16 box with inner borders
    b.bgRect = ffi.new('RECT', { 0, 0, 128, 16 })

    b.tbRect = ffi.new('RECT', { 0, 0, 128,  1 })
    b.lrRect = ffi.new('RECT', { 0, 0,   1, 16 })

    -- default to origin position and special pos for bot/right border
    b.position = ffi.new('D3DXVECTOR2', { 0, 0 })

    b.bPosition = ffi.new('D3DXVECTOR2', {   0, 15 })
    b.rPosition = ffi.new('D3DXVECTOR2', { 127,  0 })

    function b:pos(x, y)
        self.position.x = x
        self.position.y = y

        -- update our border positions based on current w/h
        self.bPosition.x = x
        self.bPosition.y = y + self.bgRect.bottom - 1

        self.rPosition.x = x + self.bgRect.right - 1
        self.rPosition.y = y
        return self
    end

    function b:size(w, h)
        self.bgRect.left = 0
        self.bgRect.top = 0
        self.bgRect.right = w
        self.bgRect.bottom = h

        self.tbRect.left = 0
        self.tbRect.top = 0
        self.tbRect.right = w
        self.tbRect.bottom = 1

        self.lrRect.left = 0
        self.lrRect.top = 0
        self.lrRect.right = 1
        self.lrRect.bottom = h

        -- update our border positions based on current w/h
        self.bPosition.y = self.position.y + h - 1
        self.rPosition.x = self.position.x + w - 1

        return self
    end

    function b:bg(d3dColor)
        self.bgColor = d3dColor
        return self
    end

    function b:border(d3dColor)
        self.borderColor = d3dColor
        return self
    end

    function b:draw(dxui)
        local sprite = dxui.surface

        sprite:Draw(self.texture, self.bgRect, dxui.scale, nil, 0.0, self.position, self.bgColor)
        sprite:Draw(self.texture, self.tbRect, dxui.scale, nil, 0.0, self.position, self.borderColor)
        sprite:Draw(self.texture, self.tbRect, dxui.scale, nil, 0.0, self.bPosition, self.borderColor)
        sprite:Draw(self.texture, self.lrRect, dxui.scale, nil, 0.0, self.position, self.borderColor)
        sprite:Draw(self.texture, self.lrRect, dxui.scale, nil, 0.0, self.rPosition, self.borderColor)
        return self
    end

    return b
end

return box2
