local bit = require('bit')
local imgui = require('imgui')
local state = require('chatty-state')
local modes = require('chat-modes')

local BASE_W, BASE_H = imgui.CalcTextSize('W')
local CONF_W = BASE_W * 75
local CONF_H = BASE_H * 25
local TABS_W = BASE_W * 25

local config = {
    WindowFlags = bit.bor(ImGuiWindowFlags_NoResize),
    IsVisible = { false },
    SelectedTab = nil,
    Inputs = {
        Rename = { '' },
        Modes = { },
    }
}

---Resets input data to their default values. For simplicity, we share a single
---object to hold user input for all of the filter configs.
function config:ResetInputs()
    self.Inputs.Rename[1] = ''
    self.Inputs.Modes = { }

    for i, mode in ipairs(modes) do
        self.Inputs.Modes[i] = { state:CheckFilter(mode.Id, self.SelectedTab) }
    end
end

---Draws the panel containing a mutable list of tabs to display in the chat
---window.
function config:DrawTabList()
    imgui.BeginGroup()
    imgui.Text('Tabs')

    local panelSize = { TABS_W, -imgui.GetFrameHeightWithSpacing() }
    local hasBorder = true
    local panelFlags = bit.bor(ImGuiWindowFlags_None)

    if imgui.BeginChild('chatty_config_tabs', panelSize, hasBorder, panelFlags) then
        for tabIndex, tabName in ipairs(state.Tabs) do
            if imgui.Selectable(tabName, self.SelectedTab == tabIndex) then
                self.SelectedTab = tabIndex
                self:ResetInputs()
            end
        end
    end
    imgui.EndChild()

    if imgui.Button('+##chatty_config_tabs_add', { BASE_W * 3, 0 }) then
        state:AddTab('New Tab')
        state:SaveSettings()
    end

    -- only bother showing the "delete tab" button if there's a tab to delete
    if self.SelectedTab ~= nil then
        imgui.SameLine()
        if imgui.Button('-##chatty_config_tabs_del', { BASE_W * 3, 0 }) then
            state:RemoveTab(self.SelectedTab)
            state:SaveSettings()
        end
    end

    imgui.EndGroup()
end

---Draws the panel containing filter information for the selected tab.
function config:DrawFilterConfig()
    imgui.BeginGroup()
    imgui.Text('Filters')

    local panelSize = { 0, -imgui.GetFrameHeightWithSpacing() }
    local hasBorder = false
    local panelFlags = bit.bor(ImGuiWindowFlags_NoBackground)

    if imgui.BeginChild('chatty_config_filters', panelSize, hasBorder, panelFlags) then
        imgui.InputText('##chatty_config_filters_rename', self.Inputs.Rename, 32)
        imgui.SameLine()
        if imgui.Button('Rename') then
            state:RenameTab(self.SelectedTab, self.Inputs.Rename[1])
            state:SaveSettings()
            self:ResetInputs()
        end

        for i, mode in ipairs(modes) do
            if imgui.Checkbox(mode.Name, self.Inputs.Modes[i]) then
                if self.Inputs.Modes[i][1] then
                    state:AddFilter(mode.Id, self.SelectedTab)
                else
                    state:RemoveFilter(mode.Id, self.SelectedTab)
                end
                state:SaveSettings()
            end
        end
    end

    imgui.EndChild()
    imgui.EndGroup()
end

---Displays the configuration window (if it is open).
function config:Render()
    if not self.IsVisible[1] then
        return
    end

    imgui.SetNextWindowSize({ CONF_W, CONF_H }, ImGuiCond_Once)
    if imgui.Begin('Chatty Config##chatty_config', self.IsVisible, self.WindowFlags) then
        self:DrawTabList()

        if self.SelectedTab ~= nil then
            imgui.SameLine()
            self:DrawFilterConfig()
        end
    end

    imgui.End()
end

return config
