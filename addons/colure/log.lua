require('common')
local chat = require('chat')
local log = { debug = true }

function log.dbg(str, ...)
    if not log.debug then return end
    print(chat.header(addon.name):append(chat.color1(67, str)):format(...))
end

function log.inf(str, ...)
    print(chat.header(addon.name):append(chat.message(str)):format(...))
end

function log.err(str, ...)
    print(chat.header(addon.name):append(chat.error(str)):format(...))
end

return log
