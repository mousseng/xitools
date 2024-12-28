addon.name    = 'dxui'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'a performant UI supplement'

require('common')
local bit = require('bit')
local d3d = require('d3d8')
local ffi = require('ffi')
local log = require('log')

local componentDir = string.format('%s\\components', addon.path)

local dxui = {
    scale = ffi.new('D3DXVECTOR2', { 1.0, 1.0 }),
    surface = nil,
}

local components = { }

local function init()
    local sprite = ffi.new('ID3DXSprite*[1]')
    if (ffi.C.D3DXCreateSprite(d3d.get_device(), sprite) == ffi.C.S_OK) then
        dxui.surface = d3d.gc_safe_release(ffi.cast('ID3DXSprite*', sprite[0]))
    else
        log.err('failed to create sprite')
    end

    for entry in io.popen(string.format([[dir "%s" /b /a-d]], componentDir)):lines() do
        local component = dofile(string.format('%s\\%s', componentDir, entry))
        if component then
            local comp = component:init()
            table.insert(components, comp)
        end
    end
end

local function render()
    dxui.surface:Begin()
    for _, component in ipairs(components) do
        component:draw(dxui)
    end
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

    if args[2] == 'twiddle' then
        components[1]:twiddle()
    end
end

ashita.events.register('load', 'load', init)
ashita.events.register('d3d_present', 'd3d_present', render)
ashita.events.register('command', 'command', command)
