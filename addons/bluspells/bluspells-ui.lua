local bit = require('bit')
local imgui = require('imgui')
local state = require('bluspells-state')

local BASE_W, BASE_H = imgui.CalcTextSize('W')
local LIST_W = BASE_W * 32
local DEET_W = BASE_W * 64
local TOP_H  = BASE_H * 20

local ui = {
    WindowFlags = bit.bor(ImGuiWindowFlags_None),
    IsVisible = { true },
    ShowAllSpells = { true },
}

function ui:DrawMenu()
end

function ui:DrawSpellList()
    imgui.BeginGroup()
    if imgui.Checkbox('Show All Spells', self.ShowAllSpells) then
        state:FilterSpells(self.ShowAllSpells[1])
    end

    if imgui.BeginChild('bluspells-list', { LIST_W, TOP_H }, true) then
        for _, spell in ipairs(state.SpellList) do
            local spellId = spell.Id
            local spellName = spell.Display

            if imgui.Selectable(spellName, state.SelectedSpell == spellId) then
                state:SelectSpell(spellId)
            end
        end
    end

    imgui.EndChild()
    imgui.EndGroup()
end

function ui:DrawSpellDetails()
    imgui.SameLine()
    imgui.BeginGroup()

    -- cache this ahead to prevent flickering
    local isSelectedActive = state.SelectedActive

    if not isSelectedActive and imgui.Button('Set Spell') and state.SelectedSpell then
        state:SetSpell(state.SelectedSpell)
        state:SelectSpell(state.SelectedSpell)
        state:FilterSpells(self.ShowAllSpells[1])
    end

    if isSelectedActive and imgui.Button('Unset Spell') and state.SelectedSpell then
        state:UnsetSpell(state.SelectedSpell)
        state:SelectSpell(state.SelectedSpell)
        state:FilterSpells(self.ShowAllSpells[1])
    end

    if imgui.BeginChild('bluspells-details', { DEET_W, TOP_H }, true) and state.SelectedDetails then
        imgui.PushTextWrapPos(imgui.GetWindowContentRegionWidth())

        imgui.Text(state.SelectedDetails.Cost)
        imgui.SameLine()
        imgui.Text(state.SelectedDetails.Name)
        imgui.Text(state.SelectedDetails.Desc)
        if state.SelectedDetails.Notes then
            imgui.Text(state.SelectedDetails.Notes)
        end

        imgui.Separator()

        imgui.Text(state.SelectedDetails.Stats)
        imgui.Text(state.SelectedDetails.Traits)
        imgui.Text(state.SelectedDetails.Damage)
        imgui.Text(state.SelectedDetails.Ecosystem)
        imgui.Text(state.SelectedDetails.Casting)
        imgui.Text(state.SelectedDetails.Targeting)
        if state.SelectedDetails.Resonance then
            imgui.Text(state.SelectedDetails.Resonance)
        end
        if state.SelectedDetails.Attributes then
            imgui.Text(state.SelectedDetails.Attributes)
        end

        imgui.PopTextWrapPos()
    end

    imgui.EndChild()
    imgui.EndGroup()
end

function ui:DrawStatSummary()
    imgui.BeginGroup()

    imgui.Text('Stat Summary')
    if imgui.BeginChild('bluspells-summary-stats', { LIST_W, 0 }, false) then
        for _, stat in ipairs(state.SummaryStats) do
            imgui.Text(stat)
        end
    end

    imgui.EndChild()
    imgui.EndGroup()
end

function ui:DrawTraitSummary()
    imgui.SameLine()
    imgui.BeginGroup()

    imgui.Text('Trait Summary')
    if imgui.BeginChild('bluspells-summary-traits', { DEET_W, 0 }, false) then
        for _, trait in ipairs(state.SummaryTraits) do
            imgui.Text(trait)
        end
    end

    imgui.EndChild()
    imgui.EndGroup()
end

-- Displays the set-builder window.
function ui:Render()
    if not self.IsVisible[1] then
        return
    end

    if imgui.Begin('bluspells', self.IsVisible, self.WindowFlags) then
        self:DrawMenu()
        self:DrawSpellList()
        self:DrawSpellDetails()
        self:DrawStatSummary()
        self:DrawTraitSummary()
    end

    imgui.End()
end

return ui
