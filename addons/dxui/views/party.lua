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

function view:init()
    self.panel = box2.new()
        :bg(colors.bgPanel)
        :border(colors.borderLight)
        :size(424, 73)
        :pos(256, 256)

    self.player0 = player.new()
        :pos(256 + 10, 256 + 10)

    return self
end

function view:draw(dxui)
    self.panel:draw(dxui)
    self.player0:draw(dxui)
end

function view:update()
    self.player0:update(state.party[0])
end

return view
