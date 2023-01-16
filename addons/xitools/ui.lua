local imgui = require('imgui')

local ui = {
    Styles = {
        ItemSpacing       = { 8, 4 },
        WindowPadding     = { 10, 10 },
        FramePaddingNone  = { 0, 0 },
        FramePaddingSome  = { 4, 2 },
        BarSize           = { 200, 15 },
    },
    Colors = {
        White          = { 1.00, 1.00, 1.00, 1.0 },
        Yellow         = { 1.00, 1.00, 0.00, 1.0 },
        Orange         = { 1.00, 0.64, 0.00, 1.0 },
        Red            = { 0.95, 0.20, 0.20, 1.0 },

        HpBar          = { 0.83, 0.33, 0.28, 1.0 },
        MpBar          = { 0.82, 0.60, 0.27, 1.0 },
        TpBar          = { 1.00, 1.00, 1.00, 1.0 },
        TpBarActive    = { 0.23, 0.67, 0.91, 1.0 },
        XpBar          = { 0.01, 0.67, 0.07, 1.0 },
        LpBar          = { 0.61, 0.32, 0.71, 1.0 },
        BarBorder      = { 0.07, 0.07, 0.07, 1.0 }, --#13131f
        BarBackground  = { 0.16, 0.17, 0.20, 1.0 }, --#292b33

        StatusGrey     = { 1.00, 1.00, 1.00, 0.5 },
        StatusWhite    = { 0.98, 0.92, 0.84, 1.0 },
        StatusBlack    = { 0.60, 0.20, 0.80, 1.0 },
        StatusYellow   = { 0.80, 0.80, 0.80, 1.0 },
        StatusBrown    = { 1.00, 0.96, 0.56, 1.0 },
        StatusGreen    = { 0.60, 0.80, 0.20, 1.0 },
        StatusBlue     = { 0.28, 0.46, 1.00, 1.0 },
        StatusRed      = { 0.80, 0.22, 0.00, 1.0 },
        StatusCyan     = { 0.59, 0.80, 0.80, 1.0 },

        FfxiGreyBg     = { 0.08, 0.08, 0.08, 0.8 },
        FfxiGreyBorder = { 0.69, 0.68, 0.78, 1.0 },
        FfxiAmber      = { 0.81, 0.81, 0.50, 1.0 },

        BorderShadow   = { 1.00, 0.00, 0.00, 1.0 },
    },
}

---@param title   string
---@param cur     integer
---@param max     integer
---@param overlay string?
function ui.DrawBar(title, cur, max, overlay)
    local fraction = cur / max

    imgui.PushStyleColor(ImGuiCol_FrameBg, ui.Colors.BarBackground)
    imgui.PushStyleColor(ImGuiCol_Border, ui.Colors.BarBorder)

    imgui.AlignTextToFramePadding()
    imgui.Text(title)
    imgui.SameLine()
    imgui.ProgressBar(fraction, ui.Styles.BarSize, overlay)

    imgui.PopStyleColor(2)
end

---@param cur     integer
---@param max     integer
---@param size    Vec2
---@param overlay string?
function ui.DrawBar2(cur, max, size, overlay)
    local fraction = cur / max

    imgui.PushStyleColor(ImGuiCol_FrameBg, ui.Colors.BarBackground)
    imgui.PushStyleColor(ImGuiCol_Border, ui.Colors.BarBorder)

    imgui.AlignTextToFramePadding()
    imgui.ProgressBar(fraction, size, overlay)

    imgui.PopStyleColor(2)
end

---@param cur     integer
---@param max     integer
---@param size    Vec2
---@param overlay string?
function ui.DrawBar3(cur, max, size, overlay)
    local fraction = cur / max
    local borderColor = ui.Colors.BarBorder

    if max > 0 and fraction <= 0.25 then
        borderColor = ui.Colors.Red
    elseif max > 0 and fraction <= 0.50 then
        borderColor = ui.Colors.Orange
    elseif max > 0 and fraction <= 0.75 then
        borderColor = ui.Colors.Yellow
    end

    imgui.PushStyleColor(ImGuiCol_FrameBg, ui.Colors.BarBackground)
    imgui.PushStyleColor(ImGuiCol_Border, borderColor)

    imgui.AlignTextToFramePadding()
    imgui.ProgressBar(fraction, size, overlay)

    imgui.PopStyleColor(2)
end

function ui.DrawNormalWindow(config, drawStuff)
    imgui.SetNextWindowSize(config.size)
    imgui.SetNextWindowPos(config.pos, ImGuiCond_FirstUseEver)

    if config.isVisible[1] and imgui.Begin(config.name, config.isVisible, config.flags) then
        drawStuff()

        local x, y = imgui.GetWindowPos()
        config.pos[1] = x
        config.pos[2] = y
        imgui.End()
    end
end

---@param config table
---@param drawStuff function
function ui.DrawUiWindow(config, drawStuff)
    imgui.SetNextWindowSize(config.size)
    imgui.SetNextWindowPos(config.pos, ImGuiCond_FirstUseEver)

    imgui.PushStyleColor(ImGuiCol_WindowBg, ui.Colors.FfxiGreyBg)
    imgui.PushStyleColor(ImGuiCol_Border, ui.Colors.FfxiGreyBorder)
    imgui.PushStyleColor(ImGuiCol_BorderShadow, ui.Colors.BorderShadow)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, ui.Styles.ItemSpacing)
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, ui.Styles.WindowPadding)

    if config.isVisible[1] and imgui.Begin(config.name, config.isVisible, config.flags) then
        imgui.PopStyleColor(3)
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.White)
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, ui.Styles.FramePaddingNone)

        drawStuff()

        local x, y = imgui.GetWindowPos()
        config.pos[1] = x
        config.pos[2] = y

        imgui.PopStyleVar()
        imgui.PopStyleColor()
        imgui.End()
    else
        imgui.PopStyleColor(3)
    end
    imgui.PopStyleVar(2)
end

return ui
