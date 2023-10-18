-- TODO: is there a better imgui-native way to build this, like a theme?
--       critically, it must avoid clobbering styles for other addons

local bit = require('bit')
local imgui = require('imgui')

---@class ColorScheme
---@field text         table
---@field windowBg     table
---@field windowBorder table
---@field barBg        table
---@field barBorder    table
---@field hpBar        table
---@field mpBar        table
---@field tpBar        table
---@field tpReady      table
---@field xpBar        table
---@field lpBar        table
---@field cpBar        table
---@field epBar        table
---@field percent75    table
---@field percent50    table
---@field percent25    table
---@field success      table
---@field pending      table
---@field failure      table
---@field transparent  table

---@class Theme
---@field colors           ColorScheme
---@field windowPadNone    table
---@field windowPadSome    table
---@field itemSpacingNone  table
---@field itemSpacingSome  table
---@field framePaddingNone table
---@field framePaddingSome table
---@field barSize          table

---@class BarConfig
---@field title   string
---@field overlay string?
---@field size    table
---@field cur     number
---@field max     number

---@class WindowConfig
---@field title       string
---@field flags       number
---@field size        table
---@field pos         table
---@field isVisible   table
---@field isClickThru table

---@type ColorScheme
local defaultColorScheme = {
    text         = { 1.00, 1.00, 1.00, 1.0 },
    windowBg     = { 0.08, 0.08, 0.08, 0.8 },
    windowBorder = { 0.69, 0.68, 0.78, 1.0 },
    barBg        = { 0.16, 0.17, 0.20, 1.0 },
    barBorder    = { 0.07, 0.07, 0.07, 1.0 },
    hpBar        = { 0.83, 0.33, 0.28, 1.0 },
    mpBar        = { 0.82, 0.60, 0.27, 1.0 },
    tpBar        = { 1.00, 1.00, 1.00, 1.0 },
    tpReady      = { 0.23, 0.67, 0.91, 1.0 },
    xpBar        = { 0.01, 0.67, 0.07, 1.0 },
    lpBar        = { 0.61, 0.32, 0.71, 1.0 },
    cpBar        = { 1.00, 1.00, 1.00, 1.0 }, -- TODO
    epBar        = { 1.00, 1.00, 1.00, 1.0 }, -- TODO
    percent75    = { 1.00, 1.00, 0.00, 1.0 },
    percent50    = { 1.00, 0.64, 0.00, 1.0 },
    percent25    = { 0.95, 0.20, 0.20, 1.0 },
    success      = { 0.60, 0.80, 0.20, 1.0 },
    pending      = { 1.00, 0.88, 0.50, 1.0 },
    failure      = { 0.80, 0.22, 0.00, 1.0 },
    transparent  = { 0.00, 0.00, 0.00, 0.0 },
}

---@type Theme
local defaultTheme = {
    colors            = defaultColorScheme,
    itemSpacingNone   = {   1,   1 },
    itemSpacingSome   = {   8,   4 },
    windowPadNone     = {   1,   1 },
    windowPadSome     = {  10,  10 },
    framePaddingNone  = {   0,   0 },
    framePaddingSome  = {   4,   2 },
    barSize           = { 199,  15 },
}

local ui = {}

---@return ColorScheme
function ui.ColorScheme(table)
    if table == nil then
        table = { }
    end

    return {
        text         = table.text or defaultColorScheme.text,
        windowBg     = table.windowBg or defaultColorScheme.windowBg,
        windowBorder = table.windowBorder or defaultColorScheme.windowBorder,
        barBg        = table.barBg or defaultColorScheme.barBg,
        barBorder    = table.barBorder or defaultColorScheme.barBorder,
        hpBar        = table.hpBar or defaultColorScheme.hpBar,
        mpBar        = table.mpBar or defaultColorScheme.mpBar,
        tpBar        = table.tpBar or defaultColorScheme.tpBar,
        tpReady      = table.tpReady or defaultColorScheme.tpReady,
        xpBar        = table.xpBar or defaultColorScheme.xpBar,
        lpBar        = table.lpBar or defaultColorScheme.lpBar,
        cpBar        = table.cpBar or defaultColorScheme.cpBar,
        epBar        = table.epBar or defaultColorScheme.epBar,
        percent75    = table.percent75 or defaultColorScheme.percent75,
        percent50    = table.percent50 or defaultColorScheme.percent50,
        percent25    = table.percent25 or defaultColorScheme.percent25,
        success      = table.success or defaultColorScheme.success,
        pending      = table.pending or defaultColorScheme.pending,
        failure      = table.failure or defaultColorScheme.failure,
        transparent  = table.transparent or defaultColorScheme.transparent,
    }
end

---@return Theme
function ui.Theme(table)
    if table == nil then
        table = { }
    end

    return {
        colors           = ui.ColorScheme(table.Colors),
        windowPadNone    = table.windowPadNone or defaultTheme.windowPadNone,
        windowPadSome    = table.windowPadSome or defaultTheme.windowPadSome,
        itemSpacingNone  = table.itemSpacingNone or defaultTheme.itemSpacingNone,
        itemSpacingSome  = table.itemSpacingSome or defaultTheme.itemSpacingSome,
        framePaddingNone = table.framePaddingNone or defaultTheme.framePaddingNone,
        framePaddingSome = table.framePaddingSome or defaultTheme.framePaddingSome,
        barSize          = table.barSize or defaultTheme.barSize,
    }
end

---@return BarConfig
function ui.Bar(table)
    if table == nil then
        table = { }
    end

    return {
        title = table.title or '',
        overlay = table.overlay or nil,
        size = table.size or { 0, 0 },
        cur = table.cur or 0,
        max = table.max or 100,
    }
end

---@return WindowConfig
function ui.Window(table)
    if table == nil then
        table = { }
    end

    return {
        title       = table.title or '',
        flags       = table.flags or ImGuiWindowFlags_None,
        size        = table.size or { 0, 0 },
        pos         = table.pos or { 0, 0 },
        isVisible   = { table.isVisible or false },
        isClickThru = { table.isClickThru or false },
    }
end

---@param config BarConfig
---@param theme  Theme
function ui.DrawBar(config, theme)
    local fraction = config.cur / config.max

    imgui.PushStyleColor(ImGuiCol_FrameBg, theme.colors.barBg)
    imgui.PushStyleColor(ImGuiCol_Border, theme.colors.barBorder)

    imgui.AlignTextToFramePadding()
    imgui.ProgressBar(fraction, config.size, config.overlay)

    imgui.PopStyleColor(2)
end

---@param config BarConfig
---@param theme  Theme
function ui.DrawTitledBar(config, theme)
    local fraction = config.cur / config.max

    imgui.PushStyleColor(ImGuiCol_FrameBg, theme.colors.barBg)
    imgui.PushStyleColor(ImGuiCol_Border, theme.colors.barBorder)

    imgui.AlignTextToFramePadding()
    imgui.Text(config.title)
    imgui.SameLine()
    imgui.ProgressBar(fraction, config.size, config.overlay)

    imgui.PopStyleColor(2)
end

---@param config BarConfig
---@param theme  Theme
function ui.DrawColoredBar(config, theme)
    local fraction = config.cur / config.max
    local borderColor = theme.colors.barBorder

    if config.max > 0 and fraction <= 0.25 then
        borderColor = theme.colors.percent25
    elseif config.max > 0 and fraction <= 0.50 then
        borderColor = theme.colors.percent50
    elseif config.max > 0 and fraction <= 0.75 then
        borderColor = theme.colors.percent75
    end

    imgui.PushStyleColor(ImGuiCol_FrameBg, theme.colors.barBg)
    imgui.PushStyleColor(ImGuiCol_Border, borderColor)

    imgui.AlignTextToFramePadding()
    imgui.ProgressBar(fraction, config.size, config.overlay)

    imgui.PopStyleColor(2)
end

---@param config    WindowConfig
---@param theme     Theme
---@param drawStuff function
function ui.DrawNormalWindow(config, theme, drawStuff)
    imgui.SetNextWindowSize(config.size)
    imgui.SetNextWindowPos(config.pos, ImGuiCond_FirstUseEver)

    if config.isVisible[1] and imgui.Begin(config.title, config.isVisible, config.flags) then
        drawStuff()

        local x, y = imgui.GetWindowPos()
        config.pos[1] = x
        config.pos[2] = y
        imgui.End()
    end
end

---@param config    WindowConfig
---@param theme     Theme
---@param drawStuff function
function ui.DrawUiWindow(config, theme, drawStuff)
    imgui.SetNextWindowSize(config.size)
    imgui.SetNextWindowPos(config.pos, ImGuiCond_FirstUseEver)

    imgui.PushStyleColor(ImGuiCol_WindowBg, theme.colors.windowBg)
    imgui.PushStyleColor(ImGuiCol_Border, theme.colors.windowBorder)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, theme.itemSpacingSome)
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, theme.windowPadSome)

    local flags = config.flags
    if config.isClickThru[1] then
        flags = bit.bor(flags, ImGuiWindowFlags_NoInputs)
    end

    if config.isVisible[1] and imgui.Begin(config.title, config.isVisible, flags) then
        imgui.PopStyleColor(2)
        imgui.PushStyleColor(ImGuiCol_Text, theme.colors.text)
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, theme.framePaddingNone)

        drawStuff()

        local x, y = imgui.GetWindowPos()
        config.pos[1] = x
        config.pos[2] = y

        imgui.PopStyleVar()
        imgui.PopStyleColor()
        imgui.End()
    else
        imgui.PopStyleColor(2)
    end

    imgui.PopStyleVar(2)
end

---@param config    WindowConfig
---@param theme     Theme
---@param drawStuff function
function ui.DrawInvisWindow(config, theme, drawStuff)
    imgui.SetNextWindowSize(config.size)
    imgui.SetNextWindowPos(config.pos, ImGuiCond_FirstUseEver)

    imgui.PushStyleColor(ImGuiCol_WindowBg, theme.colors.transparent)
    imgui.PushStyleColor(ImGuiCol_Border, theme.colors.transparent)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, theme.itemSpacingNone)
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, theme.windowPadNone)

    local flags = config.flags
    if config.isClickThru[1] then
        flags = bit.bor(flags, ImGuiWindowFlags_NoInputs)
    end

    if config.isVisible[1] and imgui.Begin(config.title, config.isVisible, flags) then
        imgui.PopStyleColor(2)
        imgui.PushStyleColor(ImGuiCol_Text, theme.colors.text)
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, theme.framePaddingNone)

        drawStuff()

        local x, y = imgui.GetWindowPos()
        config.pos[1] = x
        config.pos[2] = y

        imgui.PopStyleVar(1)
        imgui.PopStyleColor(1)
        imgui.End()
    else
        imgui.PopStyleColor(2)
    end

    imgui.PopStyleVar(2)
end

imgui.lin = imgui.lin or ui
return imgui
