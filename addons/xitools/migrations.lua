local chat = require('chat')

local function UnknownVersion(options, targetVer)
    print(chat.header('xitools'):append(chat.warning('Failed to determine prior version of xitools')))
    print(chat.header('xitools'):append(chat.warning('Assuming settings are version ' .. targetVer)))

    options.version = targetVer
end

local migrations = {
    ['unknown'] = UnknownVersion,
    ['0.19'] = function(options)
        options.tools.inv.name = 'xitools.inv'
        options.tools.inv.flags = ImGuiWindowFlags_NoResize

        options.version = '0.20'
    end,
    ['0.20'] = function(options)
        local weekTimers = options.tools.week.timers
        for k, timer in pairs(weekTimers) do
            weekTimers[k] = {
                time = timer,
                desc = os.date('%a, %b %d at %X', timer),
            }
        end

        options.version = '0.21'
    end,
    ['0.21'] = function(options)
        options.version = '0.22'
    end,
    ['0.22'] = function(options)
        options.version = '0.23'
    end,
    ['0.23'] = function(options)
        options.version = '0.24'
    end,
}

return {
    run = function(options, targetVer)
        if options.version == nil then
            UnknownVersion(options, targetVer)
            return false
        elseif options.version == targetVer then
            return false
        end

        while options.version ~= targetVer do
            migrations[options.version](options)
            print(chat.header('xitools'):append(chat.success('upgraded to ' .. options.version)))
        end

        return true
    end,
}
