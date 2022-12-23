require('common')
local scaling = require('scaling')

---@class MeSettings
---@field font Font?

---@type MeSettings
local default_settings = T{
    font = {
        visible = true,
        font_family = 'Consolas',
        font_height = scaling.scale_f(10),
        color = 0xFFFFFFFF,
        position_x = 200,
        position_y = 200,
        background = {
            visible = true,
            color = 0xA0000000,
        }
    }
}

return default_settings
