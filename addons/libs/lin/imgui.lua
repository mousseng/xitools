local Bit = require('bit')
local Imgui = require('imgui')

local linImgui = {}

linImgui.Styles = {
    ItemSpacing   = { 8, 4 },
    WindowPadding = { 10, 10 },
    FramePadding  = { 0, 0 },
    BarSize       = { 200, 15 },
}

linImgui.Colors = {
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
}

---@param title   string
---@param cur     integer
---@param max     integer
---@param overlay string?
function linImgui.DrawBar(title, cur, max, overlay)
    local fraction = cur / max

    Imgui.PushStyleColor(ImGuiCol_FrameBg, linImgui.Colors.BarBackground)
    Imgui.PushStyleColor(ImGuiCol_Border, linImgui.Colors.BarBorder)

    Imgui.AlignTextToFramePadding()
    Imgui.Text(title)
    Imgui.SameLine()
    Imgui.ProgressBar(fraction, linImgui.Styles.BarSize, overlay)

    Imgui.PopStyleColor(2)
end

function linImgui.DrawWindow(name, size, x, y, drawStuff)
    Imgui.SetNextWindowSize(size, ImGuiCond_Always)
    Imgui.SetNextWindowPos({ x, y }, ImGuiCond_FirstUseEver)

    Imgui.PushStyleColor(ImGuiCol_WindowBg, linImgui.Colors.FfxiGreyBg)
    Imgui.PushStyleColor(ImGuiCol_Border, linImgui.Colors.FfxiGreyBorder)
    Imgui.PushStyleColor(ImGuiCol_BorderShadow, linImgui.Colors.BorderShadow)
    Imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, linImgui.Styles.ItemSpacing)
    Imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, linImgui.Styles.WindowPadding)

    if Imgui.Begin(name, { true }, Bit.bor(ImGuiWindowFlags_NoDecoration)) then
        Imgui.PopStyleColor(3)
        Imgui.PushStyleColor(ImGuiCol_Text, linImgui.Colors.White)
        Imgui.PushStyleVar(ImGuiStyleVar_FramePadding, linImgui.Styles.FramePadding)

        drawStuff()

        Imgui.PopStyleVar()
        Imgui.PopStyleColor()
        Imgui.End()
    else
        Imgui.PopStyleColor(3)
    end

    Imgui.PopStyleVar(2)
end

return linImgui