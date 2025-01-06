local state = { }

function state.getParty()
end

local function pollMemory()
end

local function handlePacket(e)
end

ashita.events.register('d3d_beginscene', 'd3d_beginscene', pollMemory)
ashita.events.register('packet_in', 'packet_in', handlePacket)

return state
