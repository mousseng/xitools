require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')
local box2 = require('primitives/box2')
local player = require('primitives/party-player')

local borderColor = d3d.D3DCOLOR_ARGB(255, 192, 192, 192)
local bgColor = d3d.D3DCOLOR_ARGB(204, 20, 20, 20)

local component = { }

local state = {
    [0] = {
        id             = 0,
        name           = 'someone',
        zone           = 'somewhere',
        job            = 'NIN99',
        sub            = 'WAR49',
        hp             = 0,
        mp             = 0,
        tp             = 0,
        hpp            = 1.0,
        mpp            = 1.0,
        tpp            = 1.0,
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
    log.dbg('initializing party component')

    component.panel = box2.new()
        :bg(bgColor)
        :border(borderColor)
        :size(424, 73)
        :pos(256, 256)

    component.player0 = player.new()
        :pos(256 + 10, 256 + 10)

    return self
end

function component:draw(dxui)
    log.dbg('rendering party component')
    component.panel:draw(dxui)
    component.player0:draw(dxui)
end

function component:twiddle()
end

return component
