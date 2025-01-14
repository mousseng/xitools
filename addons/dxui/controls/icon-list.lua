local ffi = require('ffi')
local colors = require('primitives/colors')

local control = { }

local ICON_SZ = 32
local ICON_PAD = 4

function control.new()
    local c = { }

    c.iList = { }
    c.iLimit = 999
    c.iRect = ffi.new('RECT', { 0, 0, 32, 32 })
    c.iScale = ffi.new('D3DXVECTOR2', { 1.0, 1.0 })
    c.iPosition = ffi.new('D3DXVECTOR2', { 0, 0 })
    c.position = ffi.new('D3DXVECTOR2', { 0, 0 })

    function c:pos(x, y)
        self.position.x = x
        self.position.y = y
        return self
    end

    function c:size(w, h)
        self.iRect.left   = 0
        self.iRect.top    = 0
        self.iRect.right  = w
        self.iRect.bottom = h
        return self
    end

    function c:scale(sz)
        -- TODO: how can we know the actual size of the icons?
        ICON_SZ = sz
        self.iScale.x = sz / 32
        self.iScale.y = sz / 32
        return self
    end

    function c:limit(n)
        c.iLimit = n
        return self
    end

    function c:icons(iconList)
        self.iList = iconList
        return self
    end

    function c:draw(dxui)
        local surface = dxui.surface
        for i, icon in ipairs(self.iList) do
            if i > self.iLimit then
                break
            end

            self.iPosition.x = self.position.x + ((i - 1) * (ICON_SZ + ICON_PAD))
            self.iPosition.y = self.position.y
            dxui.surface:Draw(icon, self.iRect, self.iScale, nil, 0.0, self.iPosition, colors.white)
        end

        return self
    end

    return c
end

return control
