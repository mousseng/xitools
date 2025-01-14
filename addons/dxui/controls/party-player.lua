require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local gdi = require('gdifonts/include')
local log = require('log')
local bar = require('controls/value-bar')
local iconList = require('controls/icon-list')
local boxText = require('primitives/box-text')
local colors = require('primitives/colors')

local control = { }

local ROW_H = 16
local ICON_SZ = 24
local ICON_PAD = 4

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

    c.buffs = iconList.new()
        :pos(0, 36)
        :scale(ICON_SZ)
        :limit(14)

    function c:pos(x, y)
        self.name:pos(         x, y)
        self.jobs:pos(   404 + x, y)
        self.hp:pos(       0 + x, y + ROW_H)
        self.mp:pos(128 + 10 + x, y + ROW_H)
        self.tp:pos(256 + 20 + x, y + ROW_H)
        self.buffs:pos(        x, y + ROW_H * 2 + ICON_PAD)
        return self
    end

    function c:update(player)
        self.name:text(player.name)
        self.jobs:text(player.jobs)
        self.buffs:icons(player.buffs)
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
        self.buffs:draw(dxui)
        return self
    end

    return c
end

return control
