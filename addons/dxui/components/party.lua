require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')
local box2 = require('primitives/box2')
local colors = require('primitives/colors')
local player = require('primitives/party-player')

local component = { }

local state = {
    [0] = {
        id             = 0,
        zone           = 'Port San d\'Oria',
        name           = 'Sivvi',
        jobs           = 'NIN99/WAR49',
        hp             = 2282,
        mp             = 185,
        tp             = 0,
        hpp            = 1.0,
        mpp            = 1.0,
        tpp            = 0.0,
        distance       = 0.0,
        isLeadParty    = false,
        isLeadAlliance = false,
        isSync         = false,
        isTargetMain   = false,
        isTargetSub    = false,
        isTargetParty  = false,
        buffs          = { },
    }
}

function component:init()
    component.panel = box2.new()
        :bg(colors.bgPanel)
        :border(colors.borderLight)
        :size(424, 73)
        :pos(256, 256)

    component.player0 = player.new()
        :pos(256 + 10, 256 + 10)

    return self
end

function component:draw(dxui)
    component.panel:draw(dxui)
    component.player0:draw(dxui)
end

function component:update()
    component.player0:update(state[0])
end

return component
