addon.name    = 'strats'
addon.author  = 'lin'
addon.version = '1.0'
addon.desc    = 'A UI piece for SCH stratagems'

require('common')
local d3d = require('d3d8')
local ffi = require('ffi')
local display = require('display')

local x, y = 1070, 1000
local surface = nil
local schJp = 0
local player = AshitaCore:GetMemoryManager():GetPlayer()
local recast = AshitaCore:GetMemoryManager():GetRecast()

local function getMaxPips(schLevel)
    if schLevel >= 90 then
        return 5
    elseif schLevel >= 70 then
        return 4
    elseif schLevel >= 50 then
        return 3
    elseif schLevel >= 30 then
        return 2
    elseif schLevel >= 10 then
        return 1
    else
        return 0
    end
end

local function getMaxRecast(schLevel)
    if schLevel == 99 and schJp >= 550 then
        return 165
    else
        return 240
    end
end

local function command(e)
    local args = e.command:args()
    if args[1] ~= '/strats' then
        return
    end

    if args[2] == 'pos' then
        x = tonumber(args[3] or x)
        y = tonumber(args[4] or args[3] or y)
    end

    e.blocked = true
end

local function listen(e)
    if e.id ~= 0x63 then
        return
    end

    local packetType = struct.unpack('B', e.data_modified, 0x04 + 1)
    if packetType ~= 5 then
        return
    end

    schJp = struct.unpack('H', e.data_modified, 0x88 + 1)
end

local function present()
    local schLevel = 0
    if player:GetMainJob() == 20 then
        schLevel = player:GetMainJobLevel()
    elseif player:GetSubJob() == 20 then
        schLevel = player:GetSubJobLevel()
    else
        return
    end

    local curPips = 0
    local maxPips = getMaxPips(schLevel)
    local maxRecast = getMaxRecast(schLevel)
    local progress = 0.0

    for i = 0, 31 do
        local ability = recast:GetAbilityTimerId(i)
        if ability == 231 then
            local remaining = recast:GetAbilityTimer(i) / 60
            local completed = maxRecast - remaining
            local increment = maxRecast / maxPips
            curPips = math.floor(completed / increment)
            progress = math.fmod(remaining, increment)
        end
    end

    if not surface then
        return
    end

    surface:Begin()
    for i = 1, curPips do
        display.drawPipFrame(surface, x + 42 * (i - 1), y)
        display.drawPipFill(surface, x + 42 * (i - 1), y)
    end

    for i = curPips + 1, maxPips do
        display.drawPipFrame(surface, x + 42 * (i - 1), y)
    end

    -- TODO: draw progress bar to the next charge

    surface:End()
end

ashita.events.register('load', 'load', function()
    local sprite = ffi.new('ID3DXSprite*[1]')
    local result = ffi.C.D3DXCreateSprite(d3d.get_device(), sprite)

    if result ~= ffi.C.S_OK then
        AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload strats')
        return
    end

    surface = d3d.gc_safe_release(ffi.cast('ID3DXSprite*', sprite[0]))

    ashita.events.register('command',     'strats_command', command)
    ashita.events.register('d3d_present', 'strats_present', present)
    ashita.events.register('packet_in',   'strats_listen',  listen)
end)
