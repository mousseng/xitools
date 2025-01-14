require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local gdi = require('gdifonts/include')
local log = require('log')
local box3 = require('primitives/box3')
local boxText = require('primitives/box-text')
local colors = require('primitives/colors')

local control = { }

function control.new()
    local c =  { }

    c.bar = box3.new()
        :pos(0, 0)
        :size(128, 16)
        :bg(colors.bgColor)
        :border(colors.borderDark)

    c.label = boxText.new()
        :pos(128, 0)
        :font('Consolas', 16, gdi.Alignment.Right)
        :text('0')
        :outline(2, colors.borderDark)

    function c:percent(pct)
        self.bar:percent(pct)
        return self
    end

    function c:text(str)
        self.label:text(str)
        return self
    end

    function c:color(d3dColor)
        self.bar:fg(d3dColor)
        return self
    end

    function c:pos(x, y)
        self.bar:pos(x, y)
        self.label:pos(x + 126, y + 2)
        return self
    end

    function c:draw(dxui)
        self.bar:draw(dxui)
        self.label:draw(dxui)
        return self
    end

    return c
end

return control
