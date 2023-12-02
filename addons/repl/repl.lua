addon.name    = 'repl'
addon.author  = 'lin'
addon.version = '0.1'
addon.desc    = 'A lua REPL for debugging'

local _       = require('common')
local imgui   = require('imgui')
local inspect = require('inspect')
local visible = { true }
local input   = { "print('hello world')" }
local output  = { "" }

local function formatResults(obj)
    if type(obj) == 'userdata' then
        return inspect(getmetatable(obj))
    else
        return inspect(obj)
    end
end

ashita.events.register('d3d_present', 'd3d_present_handler', function()
    if not visible[1] then
        AshitaCore:GetChatManager():QueueCommand(-1, '/addon unload repl')
        return
    end

    imgui.SetNextWindowSizeConstraints({ 512, 512 }, { FLT_MAX, FLT_MAX })
    if imgui.Begin('repl', visible) then
        local fontSize = 14
        local padding = imgui.GetStyle().FramePadding.y * 2
        local spacing = imgui.GetStyle().ItemSpacing.y * 2

        local x, y = imgui.GetContentRegionAvail()
        local size = { x, (y - (padding + spacing + fontSize)) / 2 }

        if imgui.Button('Execute') then
            local code, loadErr = loadstring(input[1])
            if loadErr then
                output[1] = loadErr
            elseif code then
                local exeErr, result = pcall(code)
                output[1] = formatResults(result)
            end
        end

        imgui.PushID('repl.input')
        imgui.InputTextMultiline('', input, 4096, size)
        imgui.PopID()

        imgui.PushID('repl.output')
        imgui.InputTextMultiline('', output, 4096 * 32, size, ImGuiInputTextFlags_ReadOnly)
        imgui.PopID()
    end
    imgui.End()
end)
