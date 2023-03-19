local delay = ashita.time.qpf()
local bounces = T{}

local function debounce(fn)
    bounces[fn] = ashita.time.qpc()
    ashita.tasks.once(1, function()
        local time = ashita.time.qpc()
        if bounces[fn] and time.q >= (bounces[fn].q + delay.q) then
            fn()
            bounces[fn] = nil
        end
    end)
end

return debounce
