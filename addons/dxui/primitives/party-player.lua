require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local gdi = require('gdifonts/include')
local log = require('log')
local box3 = require('primitives/box3')
local boxText = require('primitives/boxText')
local colors = require('primitives/colors')

local component = { }

function component.new()
    local c = { }

    -- TODO: name, job/lvl, dist
    c.name = boxText.new()
        :pos(0, 0)
        :font('Consolas', 16)
        :text('Someone')

    c.jobs = boxText.new()
        :pos(404, 0)
        :font('Consolas', 16, gdi.Alignment.Right)
        :text('JOB99/SUB49')

    c.hp = box3.new()
        :pos(0, 16)
        :size(128, 16)
        :bg(colors.bgColor)
        :fg(colors.hpColor)
        :border(colors.borderColor)

    c.mp = box3.new()
        :pos(128 + 10, 16)
        :size(128, 16)
        :bg(colors.bgColor)
        :fg(colors.mpColor)
        :border(colors.borderColor)

    c.tp = box3.new()
        :pos(256 + 20, 16)
        :size(128, 16)
        :bg(colors.bgColor)
        :fg(colors.tpColor)
        :border(colors.borderColor)

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
        self.hp:percent(player.hpp)
        self.mp:percent(player.mpp)
        self.tp:percent(player.tpp)

        if player.tp >= 1000 then
            self.tp:fg(colors.tpActiveColor)
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

return component
