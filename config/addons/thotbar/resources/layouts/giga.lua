local gridHeight = 3
local gridWidth = 10

local btnHeight = 48
local btnWidth = 48

local padHeight = 6
local padWidth = 6

local totalHeight = (gridHeight * btnHeight) + ((gridHeight - 1) * padHeight)
local totalWidth = (gridWidth * btnWidth) + ((gridWidth - 1) * padWidth)

local theme = {
    FontObjects = {
        --[[
            OffsetX: Distance from the top left of individual square object.
            OffsetY: Distance from the top right of individual square object.
            BoxWidth: Width of the box for text to be drawn into.
            BoxHeight: Height of the box for text to be drawn into.
            OutlineWidth: Width of the text outline.
            FontHeight: Height of the font.
            FontFamily: Font Family.
            FontFlags: bitflags for font modifiers
               0x01 - Bold
               0x02 - Italic
               0x04 - Underline
               0x08 - Strikeout
            FontAlignment: Font alignment within the box
               0x00 - Left Aligned
               0x01 - Center Aligned
               0x02 - Right Aligned
            FontColor - Hex ARGB value, highest significance byte is alpha.
            OutlineColor - Hex ARGB value, highest significance byte is alpha.
        ]]--
        Cost = {
            OffsetX = 0,
            OffsetY = 0,
            BoxWidth = btnWidth + padWidth,
            BoxHeight = btnHeight + padHeight,
            OutlineWidth = 1,
            FontHeight = 9,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 2,
            FontColor = 0xFFC00080,
            OutlineColor = 0xFF000000,
        },
        Macro = {
            OffsetX = 0,
            OffsetY = 0,
            BoxWidth = btnWidth + padWidth,
            BoxHeight = btnHeight + padHeight,
            OutlineWidth = 1,
            FontHeight = 12,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 0,
            FontColor = 0xFFFFFFFF,
            OutlineColor = 0xFF000000,
        },
        Name = {
            OffsetX = 0,
            OffsetY = 0,
            BoxWidth = btnWidth + padWidth,
            BoxHeight = btnHeight + padHeight,
            OutlineWidth = 1,
            FontHeight = 10,
            FontFamily = 'Arial',
            FontFlags = 0,
            FontAlignment = 1,
            FontColor = 0xFFFFFFFF,
            OutlineColor = 0xFF000000,
        },
        Recast = {
            OffsetX = 0,
            OffsetY = (btnHeight + padHeight) / 4,
            BoxWidth = btnWidth + padWidth,
            BoxHeight = btnHeight + padHeight,
            OutlineWidth = 2,
            FontHeight = btnHeight / 2 - 1,
            FontFamily = 'Consolas',
            FontFlags = 0,
            FontAlignment = 1,
            FontColor = 0xFFFFFFFF,
            OutlineColor = 0xFF000000,
        },
    },

    ImageObjects = {
        --[[
            OffsetX: Distance from the top left of individual square object.
            OffsetY: Distance from the top right of individual square object.
            Width: Width of image to be drawn.
            Height: Height of image to be drawn.
        ]]--
        Frame = {
            OffsetX = 0,
            OffsetY = 0,
            Width = btnWidth + padWidth,
            Height = btnHeight + padHeight
        },
        Icon = {
            OffsetX = padWidth / 2,
            OffsetY = padHeight / 2,
            Width = btnWidth,
            Height = btnHeight
        },
        Overlay = {
            OffsetX = padWidth / 2,
            OffsetY = padHeight / 2,
            Width = btnWidth,
            Height = btnHeight
        },
    },

    --Primitive object to be drawn prior to drawing squares.  Uses standard ashita primitive options.
    Background = {
        texture          = nil,
        texture_offset_x = 0.0,
        texture_offset_y = 0.0,
        border_visible   = false,
        border_color     = 0x00000000,
        border_flags     = FontBorderFlags.None,
        border_sizes     = '0,0,0,0',
        visible          = false,
        position_x       = 0,
        position_y       = 0,
        can_focus        = false,
        locked           = false,
        lockedz          = false,
        scale_x          = 1.0,
        scale_y          = 1.0,
        width            = totalWidth,
        height           = totalHeight,
        color            = 0x00000000,
    },

    --Level of transparency to be used for icons that are faded(due to recast down, or ability cost not met).
    IconFadeAlpha = 0.3,

    --[[
        Path to images..
        First checks absolute path.
        Next checks: ashita/config/addons/addonname/resources/
        Finally checks: ashita/addons/addonname/resources/
    ]]--
    FramePath = '',
    CrossPath = 'misc/cross.png',
    TriggerPath = 'misc/trigger.png',

    --This is checked the same way, and can contain any amount of frames.  Frames cycle back to first after last is completed.
    SkillchainAnimationPaths = T{
        'misc/crawl1.png',
        'misc/crawl2.png',
        'misc/crawl3.png',
        'misc/crawl4.png',
        'misc/crawl5.png',
        'misc/crawl6.png',
        'misc/crawl7.png'
    },

    --Time, in seconds, to wait between advancing frames of skillchain animation.
    SkillchainAnimationTime = 0.08,

    --Height of the full graphics object used to render all squares.  All squares *MUST* fully fit within this panel.
    PanelHeight = totalHeight + 10,

    --Width of the full graphics object used to render all squares.  All squares *MUST* fully fit within this panel.
    PanelWidth = totalWidth + 10,

    --Default position for object.  Set later in this theme using scaling lib.
    DefaultX = 0,
    DefaultY = 0,

    --Height of an individual square object.
    SquareHeight = btnHeight + padHeight,

    --Width of an individual square object.
    SquareWidth = btnWidth + padWidth,

    --Amount of square Objects
    SquareCount = 0,

    --Table of square objects, where each entry must be a table with attributes PositionX, PositionY, DefaultMacro.
    --Table is initialized this way so that the array afterwards can fill in position.  Can be initialized using constants.
    Squares = T{
        { DefaultMacro = '1' },
        { DefaultMacro = '2' },
        { DefaultMacro = '3' },
        { DefaultMacro = '4' },
        { DefaultMacro = '5' },
        { DefaultMacro = '6' },
        { DefaultMacro = '7' },
        { DefaultMacro = '8' },
        { DefaultMacro = '9' },
        { DefaultMacro = '0' },

        { DefaultMacro = '!1' },
        { DefaultMacro = '!2' },
        { DefaultMacro = '!3' },
        { DefaultMacro = '!4' },
        { DefaultMacro = '!5' },
        { DefaultMacro = '!6' },
        { DefaultMacro = '!7' },
        { DefaultMacro = '!8' },
        { DefaultMacro = '!9' },
        { DefaultMacro = '!0' },

        { DefaultMacro = '^1' },
        { DefaultMacro = '^2' },
        { DefaultMacro = '^3' },
        { DefaultMacro = '^4' },
        { DefaultMacro = '^5' },
        { DefaultMacro = '^6' },
        { DefaultMacro = '^7' },
        { DefaultMacro = '^8' },
        { DefaultMacro = '^9' },
        { DefaultMacro = '^0' },
    },
}

for i = 0, gridHeight - 1 do
    local offsetY = i * theme.SquareHeight
    for j = 0, gridWidth - 1 do
        theme.SquareCount = theme.SquareCount + 1
        theme.Squares[theme.SquareCount].OffsetX = j * theme.SquareWidth
        theme.Squares[theme.SquareCount].OffsetY = offsetY
    end
end

return theme
