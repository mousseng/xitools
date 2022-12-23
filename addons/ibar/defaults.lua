require('common')
local Scaling = require('scaling')

---@class IbarLayout
---@field player string
---@field target string
---@field npc    string

---@class IbarSettings
---@field font Font?
---@field layout IbarLayout

---@type TgtSettings
local default_settings = T{
    layout = {
        player = '$zone $name  [$level]  [$position] - $ecompass',
        target = '$target  [$job / $level / $aggro]  Weak[$weak]  [$position]',
        npc = '$target [$position] [ID: $id / Index: $m_index]'
    },
    font = {
        visible = true,
        font_family = 'Consolas',
        font_height = Scaling.scale_f(10),
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
