addon.name    = 'dxui'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'a performant UI supplement'

require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')
local utils = require('utils')
local uiHost = require('ui-host')
local state = require('state')

local dxui = {
    scale = ffi.new('D3DXVECTOR2', { 1.0, 1.0 }),
    surface = nil,
}

local function listen(e)
    state:listen(e)
end

local function update()
    state:update()
    uiHost:update()
end

local function render()
    if utils.ShouldHideUi()
    or dxui.surface == nil then
        return
    end

    dxui.surface:Begin()
    uiHost:draw(dxui)
    dxui.surface:End()

    log.debug = false
end

local function command(e)
    local args = e.command:args()
    if args[1] ~= '/dx' then
        return
    end

    if args[2] == 'debug' then
        log.debug = true
    end

    if args[2] == 'pos' and #args == 5 then
        uiHost:pos(args[3], args[4], args[5])
    end

    e.blocked = true
end

ashita.events.register('load', 'load', function()
    -- first try to establish our drawing surface
    local sprite = ffi.new('ID3DXSprite*[1]')
    local result = ffi.C.D3DXCreateSprite(d3d.get_device(), sprite)

    if result ~= ffi.C.S_OK then
        log.err('failed to create sprite')
        AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload dxui')
        return
    end

    dxui.surface = d3d.gc_safe_release(ffi.cast('ID3DXSprite*', sprite[0]))

    -- then construct all of our consituent pieces
    uiHost:init()

    -- finally: let it rip
    ashita.events.register('packet_in',    'dxui_listen', listen)
    ashita.events.register('d3d_endscene', 'dxui_update', update)
    ashita.events.register('d3d_present',  'dxui_draw',   render)
    ashita.events.register('command',      'dxui_cmd',    command)
end)
