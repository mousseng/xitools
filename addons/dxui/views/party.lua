require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')
local state = require('state')
local box2 = require('primitives/box2')
local colors = require('primitives/colors')
local player = require('controls/party-player')

local view = { }

local HEIGHT = 62
local PADDING = 8
local TOTAL_H = HEIGHT + PADDING

function view:init()
    self.memberCount = 1

    self.panel = box2.new()
        :bg(colors.bgPanel)
        :border(colors.borderLight)
        :size(424, 20 + HEIGHT)
        :pos(256, 256)

    -- each player will be 62px tall with 8px padding inbetween
    self.party1 = {
        [ 0] = player.new():pos(256 + 10, 256 + 10),
        [ 1] = player.new():pos(256 + 10, 256 + 10 + TOTAL_H * 1),
        [ 2] = player.new():pos(256 + 10, 256 + 10 + TOTAL_H * 2),
        [ 3] = player.new():pos(256 + 10, 256 + 10 + TOTAL_H * 3),
        [ 4] = player.new():pos(256 + 10, 256 + 10 + TOTAL_H * 4),
        [ 5] = player.new():pos(256 + 10, 256 + 10 + TOTAL_H * 5),
    }

    self:pos(384, 400)

    return self
end

function view:pos(x, y)
    self.panel:pos(x, y)
    for i = 0, 5 do
        self.party1[i]:pos(x + 10, y + 10 + (TOTAL_H * i))
    end
    return self
end

function view:draw(dxui)
    self.panel:draw(dxui)
    for i = 0, self.memberCount - 1 do
        self.party1[i]:draw(dxui)
    end
end

function view:update()
    local memberCount = 0
    for i = 0, 5 do
        if not state.party[i] then
            break
        end

        memberCount = memberCount + 1
        self.party1[i]:update(state.party[i])
    end

    if memberCount ~= self.memberCount then
        -- we need n-1 padding instead of n
        self.panel:size(424, 20 + (TOTAL_H * memberCount) - PADDING)
        self.memberCount = memberCount
    end
end

return view
