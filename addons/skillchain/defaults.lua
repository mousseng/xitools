require('common')
local scaling = require('scaling')

---@class SkillchainSettings
---@field showHeader boolean
---@field font Font?

---@type SkillchainSettings
local default_settings = T{
    showHeader = true,
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
