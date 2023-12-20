local bit = require('bit')
local imgui = require('imgui')
local state = require('chatty-state')

local BASE_W, BASE_H = imgui.CalcTextSize('W')

local ui = {
    Font = imgui.AddFontFromFileTTF(string.format('%s\\CascadiaCode.ttf', addon.path), 18),
    WindowFlags = bit.bor(ImGuiWindowFlags_NoTitleBar),
    IsVisible = { true },
}

---Draws a chat message within the window.
---@param msg table
local function DrawMessage(msg)
    imgui.NewLine()
    -- TODO: while the segmenting strategy makes it simple to colorize text in
    --       imgui, it has left the wrapping messed up
    for _, segment in ipairs(msg.Message) do
        imgui.SameLine(0, 0)
        imgui.TextColored(segment.Color, segment.String)

        if imgui.IsItemHovered() then
            local tlX, tlY = imgui.GetItemRectMin()
            local brX, brY = imgui.GetItemRectMax()
            local color = imgui.GetColorU32({ 0.23, 0.67, 0.91, 1.0 })
            local drawList = imgui.GetWindowDrawList()
            drawList:AddRect({ tlX, tlY }, { brX, brY }, color, 0.0)

            imgui.BeginTooltip()
            imgui.Text(segment.Tooltip)
            imgui.EndTooltip()
        end
    end
end

---Draws a given tab and its contents.
---@param name     string
---@param messages table[]
local function DrawTab(name, messages)
    if imgui.BeginTabItem(name) then
        local panelName = string.format('chatty_tabs##%s', name)
        imgui.BeginChild(panelName, { 0, 0 }, false, ImGuiWindowFlags_NoBackground)
        imgui.PushTextWrapPos(imgui.GetWindowContentRegionWidth())

        for _, msg in ipairs(messages) do
            DrawMessage(msg)
        end

        -- autoscroll to bottom if you're close; this will keep new messages in
        -- view without manual intervention
        if (imgui.GetScrollMaxY() - imgui.GetScrollY()) <= BASE_H then
            imgui.SetScrollHereY(1.0)
        end

        imgui.PopTextWrapPos()
        imgui.EndChild()
        imgui.EndTabItem()
    end
end

---Draws the tab bar and each tab.
local function DrawTabsAndChat()
    if imgui.BeginTabBar('chatty_tabs') then
        -- "all" is a special tab that isn't configurable
        DrawTab('All', state.AllMessages)

        for tabIndex, tabName in ipairs(state.Tabs) do
            local messages = state:GetMessages(tabIndex)
            DrawTab(tabName, messages)
        end

        imgui.EndTabBar()
    end
end

---Displays the chat window.
function ui:Render()
    -- TODO: using an alternative font breaks FontAwesome?
    imgui.PushFont(self.Font)
    if imgui.Begin('chatty', self.IsVisible, self.WindowFlags) then
        DrawTabsAndChat()
    end

    imgui.End()
    imgui.PopFont()
end

return ui
