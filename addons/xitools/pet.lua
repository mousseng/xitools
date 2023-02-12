require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')

local Scale = 1.0

---@param name     string
---@param distance string
local function DrawHeader(name, distance, options)
    imgui.Text(string.format('%s', name))

    local newX =
        imgui.GetCursorPosX() +
        imgui.GetColumnWidth() -
        imgui.CalcTextSize(distance) -
        imgui.GetStyle().FramePadding.x

    imgui.SameLine()
    imgui.SetCursorPosX(newX)
    imgui.Text(distance)
end

---@param cur integer
---@param max integer
local function DrawHpp(cur, max)
    -- local title = string.format('HP %4i', cur)
    -- local textColor = ui.Colors.White
    -- local barColor = ui.Colors.HpBar

    -- if cur > 75 then
    --     textColor = ui.Colors.White
    -- elseif cur > 50 then
    --     textColor = ui.Colors.Yellow
    -- elseif cur > 25 then
    --     textColor = ui.Colors.Orange
    -- elseif cur >= 00 then
    --     textColor = ui.Colors.Red
    -- end

    -- imgui.PushStyleColor(ImGuiCol_Text, textColor)
    -- imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    -- ui.DrawBar(title, cur, max, ui.Scale(ui.Styles.BarSize, Scale), '')
    -- imgui.PopStyleColor(2)

    local textColor = ui.Colors.White
    local barColor = ui.Colors.HpBar
    local overlay = string.format('%i%%', cur)

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar3(cur, max, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawMpp(cur, max)
    -- local title = string.format('MP %4i', cur)
    -- local textColor = ui.Colors.White
    -- local barColor = ui.Colors.FfxiAmber

    -- if cur > 75 then
    --     textColor = ui.Colors.White
    -- elseif cur > 50 then
    --     textColor = ui.Colors.Yellow
    -- elseif cur > 25 then
    --     textColor = ui.Colors.Orange
    -- elseif cur >= 00 and max > 0 then
    --     textColor = ui.Colors.Red
    -- end

    -- imgui.PushStyleColor(ImGuiCol_Text, textColor)
    -- imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    -- ui.DrawBar(title, cur, max, ui.Scale(ui.Styles.BarSize, Scale), '')
    -- imgui.PopStyleColor(2)

    local textColor = ui.Colors.White
    local barColor = ui.Colors.MpBar
    local overlay = string.format('%i%%', cur)

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    imgui.SameLine()
    ui.DrawBar2(cur, max, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param cur integer
---@param max integer
local function DrawTp(cur, max)
    -- local title = string.format('TP %4i', cur)
    -- local textColor = ui.Colors.White
    -- local barColor = ui.Colors.TpBar

    -- if cur > 1000 then
    --     textColor = ui.Colors.TpBarActive
    --     barColor = ui.Colors.TpBarActive
    -- end

    -- imgui.PushStyleColor(ImGuiCol_Text, textColor)
    -- imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    -- ui.DrawBar(title, cur, max, ui.Scale(ui.Styles.BarSize, Scale), '')
    -- imgui.PopStyleColor(2)

    local textColor = ui.Colors.White
    local barColor = ui.Colors.TpBar
    local overlay = string.format('%i', cur)

    if cur >= 1000 then
        barColor = ui.Colors.TpBarActive
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    imgui.SameLine()
    ui.DrawBar2(cur, max, ui.Scale({ 80, 15 }, Scale), overlay)
    imgui.PopStyleColor(2)
end

---@param pet Entity
---@param options table
local function DrawPet(pet, options)
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    DrawHeader(pet.Name, ('%.1fm'):format(math.sqrt(pet.Distance)), options)
    DrawHpp(pet.HPPercent, 100)
    DrawMpp(player:GetPetMPPercent(), 100)
    DrawTp(player:GetPetTP(), 3000)
end

---@type xitool
local pet = {
    Name = 'pet',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.pet',
        size = T{ 276, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoDecoration),
    },
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('pet') then
            imgui.Checkbox('Enabled', options.isEnabled)
            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]

        ---@type Entity
        local player = GetPlayerEntity()
        if player == nil then return end

        ---@type Entity
        local pet = GetEntity(player.PetTargetIndex)
        if pet == nil or pet.Name == nil then return end

        ui.DrawUiWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            DrawPet(pet, options)
        end)
    end,
}

return pet
