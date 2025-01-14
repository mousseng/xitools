require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local gdi = require('gdifonts/include')
local log = require('log')
local bar = require('controls/value-bar')
local boxText = require('primitives/box-text')
local colors = require('primitives/colors')

local control = { }

function control.new()
    local c = { }

    c.name = boxText.new()
        :pos(0, 0)
        :font('Consolas', 16)
        :text('Someone')
        :outline(2, colors.borderDark)

    c.jobs = boxText.new()
        :pos(404, 0)
        :font('Consolas', 16, gdi.Alignment.Right)
        :text('JOB99/SUB49')
        :outline(2, colors.borderDark)

    c.hp = bar.new()
        :pos(0, 16)
        :color(colors.hpColor)

    c.mp = bar.new()
        :pos(128 + 10, 16)
        :color(colors.mpColor)

    c.tp = bar.new()
        :pos(256 + 20, 16)
        :color(colors.tpColor)

    -- TODO: buffs

    function c:pos(x, y)
        self.name:pos(      x, y)
        self.jobs:pos(404 + x, y)
        self.hp:pos(       0 + x, 16 + y)
        self.mp:pos(128 + 10 + x, 16 + y)
        self.tp:pos(256 + 20 + x, 16 + y)
        return self
    end

    function c:update(player)
        self.name:text(player.name)
        self.jobs:text(player.jobs)
        self.hp:text(tostring(player.hp))
        self.mp:text(tostring(player.mp))
        self.tp:text(tostring(player.tp))
        self.hp:percent(player.hpp)
        self.mp:percent(player.mpp)
        self.tp:percent(player.tpp)

        if player.tp >= 1000 then
            self.tp:color(colors.tpActiveColor)
        else
            self.tp:color(colors.tpColor)
        end

        return self
    end

    function c:draw(dxui)
        self.hp:draw(dxui)
        self.mp:draw(dxui)
        self.tp:draw(dxui)
        self.name:draw(dxui)
        self.jobs:draw(dxui)
        return self
    end

    return c
end

return control
