require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils/packets')

local Scale = 1.0
local LastProgress = nil
local LastActionName = ''
local ActionTypes = {
    [packets.inbound.action.actionTypes.SpellStart] = true,
    [packets.inbound.action.actionTypes.ItemStart] = true,
}

---@type xitool
local cast = {
    Name = 'cast',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.cast',
        size = T{ -1, -1 },
        barSize = T{ 256, 12 },
        pos = T{ 100, 100 },
        color = T{ 0.83, 0.33, 0.28, 1.0 },
        flags = bit.bor(ImGuiWindowFlags_NoDecoration),
    },
    HandlePacket = function(e, options, gOptions)
        if e.id == packets.inbound.action.id then
            local player = GetPlayerEntity()
            local action = packets.inbound.action.parse(e.data_raw)

            if player
            and action.actor_id == player.ServerId
            and ActionTypes[action.category]
            and action.param == 0x6163 then
                local res = AshitaCore:GetResourceManager()

                if action.category == packets.inbound.action.actionTypes.SpellStart then
                    local spellId = action.targets[1].actions[1].param
                    LastActionName = res:GetSpellById(spellId).Name[1]
                else
                    local itemId = action.targets[1].actions[1].param
                    LastActionName = res:GetItemById(itemId).Name[1]
                end
            end
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('cast') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.ColorEdit4('Bar Color', options.color)
            imgui.InputInt2('Size', options.barSize)

            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        local castBar = AshitaCore:GetMemoryManager():GetCastBar()
        local progress = castBar:GetPercent()

        if progress == LastProgress then return end

        Scale = gOptions.uiScale[1]

        ui.DrawInvisWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)

            imgui.PushStyleColor(ImGuiCol_FrameBg, { 0.08, 0.08, 0.08, 0.8 })
            imgui.PushStyleColor(ImGuiCol_Border, { 0.69, 0.68, 0.78, 1.0 })
            imgui.PushStyleColor(ImGuiCol_PlotHistogram, options.color)
            imgui.Text(LastActionName)
            imgui.ProgressBar(progress, ui.Scale(options.barSize, Scale))
            imgui.PopStyleColor(3)

            LastProgress = progress
        end)
    end,
}

return cast
