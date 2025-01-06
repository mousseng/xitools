--[[
-- Courtesy of Thorny in the Ashita discord
--]]

local ffi = require('ffi')

ffi.cdef[[
    int32_t memcmp(const void* buff1, const void* buff2, size_t count)
]]

local lastChunkBuffer = {}
local currentChunkBuffer = {}

local function CheckForDuplicate(e)
    -- check if new chunk
    if ffi.C.memcmp(e.data_raw, e.chunk_data_raw, e.size) == 0 then
        lastChunkBuffer = currentChunkBuffer
        currentChunkBuffer = {}
    end

    -- add packet to current chunk's buffer
    local ptr = ffi.cast('uint8_t*', e.data_raw)
    local newPacket = ffi.new('uint8_t[?]', 512)
    ffi.copy(newPacket, ptr, e.size)
    table.insert(currentChunkBuffer, newPacket)

    -- check if last chunk contained this packet
    for _, packet in ipairs(lastChunkBuffer) do
        if ffi.C.memcmp(packet, ptr, e.size) == 0 then
            return true
        end
    end

    return false
end

return CheckForDuplicate
