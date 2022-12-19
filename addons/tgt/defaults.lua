local scaling = require('scaling')

---@class TgtSettings
---@field font Font?
---@field dependent boolean
---@field status boolean

---@type TgtSettings
local default_settings = {
    dependent = false,
    status = true,
    font = {
        visible = true,
        font_family = 'Consolas',
        font_height = scaling.scale_f(10),
        color = 0xFFFFFFFF,
        position_x = 100,
        position_y = 100,
        background = {
            visible = true,
            color = 0xA0000000,
        }
    }
}

return default_settings
