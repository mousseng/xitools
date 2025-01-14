require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local gdi = require('gdifonts/include')
local log = require('log')
local colors = require('primitives/colors')

local fontSettings = {
    box_height = 0,
    box_width = 0,
    font_alignment = 0,
    font_color = 0xFFFFFFFF,
    font_family = 'Arial',
    font_height = 16,
    outline_color = 0xFF000000,
    outline_width = 0,
    text = '',
    visible = true,
}

local boxText = { }

function boxText.new()
    local b = { }

    b.isVisible = true
    b.gdiFont = gdi:create_object(fontSettings, true)
    b.position = ffi.new('D3DXVECTOR2', { 0, 0 })

    function b:font(family, height, alignment)
        self.gdiFont:set_font_family(family)
        self.gdiFont:set_font_height(height)

        if alignment then
            self.gdiFont:set_font_alignment(alignment)
        end

        return self
    end

    function b:outline(width, d3dColor)
        self.gdiFont:set_outline_width(width)
        self.gdiFont:set_outline_color(d3dColor)
        return self
    end

    function b:pos(x, y)
        -- the positioning is a little funny. not sure where the extra height
        -- is coming from, but subtracting 4 vertical pixels seems to let me
        -- position things exactly as I want them
        self.position.x = x
        self.position.y = y - 4
        self.gdiFont:set_position_x(x)
        self.gdiFont:set_position_y(y - 4)
        self:realign()
        return self
    end

    function b:size(w, h)
        self.gdiFont:set_box_width(w)
        self.gdiFont:set_box_height(h)
        return self
    end

    function b:text(str)
        -- avoid drawing things when we have no string value
        if str == nil or str == '' then
            self.isVisible = false
            return self
        end

        self.isVisible = true
        self.gdiFont:set_text(str)
        self:realign()
        return self
    end

    function b:realign()
        -- in order to avoid doing math on every frame, we adjust the position
        -- on text changes to support right-alignment. this requires us to keep
        -- track of an "original" or "target" set of coordinates, which we use
        -- gdifonts' position settings for
        if self.gdiFont.settings.font_alignment == gdi.Alignment.Right then
            local _, rect = self.gdiFont:get_texture()
            self.position.x = self.gdiFont.settings.position_x - rect.right
        end
    end

    function b:draw(dxui)
        if not self.isVisible then
            return self
        end

        local tex, rect = self.gdiFont:get_texture()
        dxui.surface:Draw(tex, rect, dxui.scale, nil, 0.0, self.position, colors.white)
        return self
    end

    return b
end

return boxText
