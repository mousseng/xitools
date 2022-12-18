local scaling = require('scaling')

---@class SkillchainSettings
---@field font Font
local default_settings = {
    ---@class Font
    ---@field visible boolean
    ---@field font_family string
    ---@field font_height number
    ---@field color number
    ---@field position_x number
    ---@field position_y number
    ---@field background table
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
