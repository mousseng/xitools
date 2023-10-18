addon.name      = 'loggers'
addon.author    = 'lin'
addon.version   = '1.1'
addon.desc      = 'Logs raw packet data to a file'

require('common')

local IndexTable = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function ToBinary(integer)
    local remaining = tonumber(integer)
    local binBits = ''

    for i = 7, 0, -1 do
        local currentPower = 2 ^ i

        if remaining >= currentPower then
            binBits = binBits .. '1'
            remaining = remaining - currentPower
        else
            binBits = binBits .. '0'
        end
    end

    return binBits
end

function FromBinary(binBits)
    return tonumber(binBits, 2)
end

function ToBase64(toEncode)
    local bitPattern = ''
    local encoded = ''
    local trailing = ''

    for i = 1, string.len(toEncode) do
        bitPattern = bitPattern .. ToBinary(string.byte(string.sub(toEncode, i, i)))
    end

    -- Check the number of bytes. If it's not evenly divisible by three,
    -- zero-pad the ending & append on the correct number of ``=``s.
    if string.len(bitPattern) % 3 == 2 then
        trailing = '=='
        bitPattern = bitPattern .. '0000000000000000'
    elseif string.len(bitPattern) % 3 == 1 then
        trailing = '='
        bitPattern = bitPattern .. '00000000'
    end

    for i = 1, string.len(bitPattern), 6 do
        local byte = string.sub(bitPattern, i, i + 5)
        local offset = tonumber(FromBinary(byte))
        encoded = encoded .. string.sub(IndexTable, offset + 1, offset + 1)
    end

    return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
end

local function LogPacket(prefix, packet)
    local date = os.date('%Y-%m-%d')
    local time = os.date('T%TZ')
    local encoded = ToBase64(packet)
    local line = string.format('[%s%s] [%s] %s\n', date, time, prefix, encoded)

    local logDir = string.format('%s/%s/', AshitaCore:GetInstallPath(), 'packetlogs')
    if not ashita.fs.exists(logDir) then
        ashita.fs.create_dir(logDir)
    end

    local logName = string.format('%s.loggers', date)
    local logFile = io.open(string.format('%s/%s', logDir, logName), 'a')
    if logFile ~= nil then
        logFile:write(line)
        logFile:close()
    end
end

local function OnPacketIn(e)
    local packet = e.data:sub(0, e.size)
    LogPacket('s->c', packet)
end

local function OnPacketOut(e)
    local packet = e.data:sub(0, e.size)
    LogPacket('c->s', packet)
end

ashita.events.register('packet_in', 'on_packet_in', OnPacketIn)
ashita.events.register('packet_out', 'on_packet_out', OnPacketOut)
