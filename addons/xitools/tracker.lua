require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local ffxi = require('utils.ffxi')
local packets = require('utils.packets')

local Scale = 1.0

local Spell = 4
local Ability = 6
local Arrow = '\xef\x81\xa1'

local function GetSpellName(id)
    local spell = AshitaCore:GetResourceManager():GetSpellById(id)

    if spell then
        return spell.Name[1]
    end

    return ''
end

local function GetAbilityName(id)
    local ability = AshitaCore:GetResourceManager():GetAbilityById(id + 512)

    if ability then
        return ability.Name[1]
    end

    return ''
end

local function IsInParty(serverId)
    local pt = AshitaCore:GetMemoryManager():GetParty()
    for i=0, 17 do
        if pt:GetMemberIsActive(i) == 1
        and pt:GetMemberServerId(i) == serverId then
            return true
        end
    end

    return false
end

local function Where(table, predicate)
    local ret = { }

    for k, v in pairs(table) do
        if predicate(v) then
            table.insert(ret, v)
        end
    end

    return T(ret)
end

local function HasActiveItems(tracker)
    return #tracker.ActiveItems > 0
end

local function TryToTrackSpell(spell, trackers)
    local isTracked = function(v) return v.IsEnabled[1] and v.Id[1] == spell.param end
    local _, tracker = trackers:find_if(isTracked)

    if tracker ~= nil then
        for i = 1, spell.target_count do
            local target = spell.targets[i]

            local _, existingTimer = tracker.ActiveItems:find_if(function(v) return v.id == target.id end)
            if existingTimer == nil then
                local castInfo = {
                    id = target.id,
                    name = ffxi.GetEntityNameByServerId(target.id),
                    time = os.time(),
                }

                tracker.ActiveItems:append(castInfo)
            else
                existingTimer.time = os.time()
            end
        end
    end
end

local function TryToTrackAbility(ability, trackers)
    local isTracked = function(v) return v.IsEnabled[1] and v.Id[1] == ability.param end
    local _, tracker = trackers:find_if(isTracked)

    if tracker ~= nil then
        local _, existingTimer = tracker.ActiveItems:find_if(function(v) return v.id == ability.actor_id end)
        if existingTimer == nil then
            local castInfo = {
                id = ability.actor_id,
                name = ffxi.GetEntityNameByServerId(ability.actor_id),
                time = os.time(),
            }

            tracker.ActiveItems:append(castInfo)
        else
            existingTimer.time = os.time()
        end
    end
end

local function DrawTrackers(trackers)
    local now = os.time()
    for _, trackedItem in ipairs(trackers) do
        imgui.Text(trackedItem.Name[1])
        imgui.Indent(10 * Scale)

        for idx, activeItem in ipairs(trackedItem.ActiveItems) do
            local elapsed = now - activeItem.time

            if elapsed > trackedItem.Duration[1] + 5 then
                table.remove(trackedItem.ActiveItems, idx)
            elseif elapsed > trackedItem.Duration[1] then
                imgui.TextDisabled(('%s %s'):format(Arrow, activeItem.name))
            else
                local remaining = trackedItem.Duration[1] - elapsed
                imgui.Text(('%s %s - %ss'):format(Arrow, activeItem.name, remaining))
            end
        end

        imgui.Unindent(10)
    end
end

---@type xitool
local tracker = {
    Name = 'tracker',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.tracker',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        spells = T{
            T{ IsEnabled = { false }, Id = {  57 }, Name = { "Haste" },            Duration = { 180 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 109 }, Name = { "Refresh" },          Duration = { 150 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 108 }, Name = { "Regen" },            Duration = {  75 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 110 }, Name = { "Regen II" },         Duration = {  60 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 111 }, Name = { "Regen III" },        Duration = {  60 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 386 }, Name = { "Mage's Ballad" },    Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 387 }, Name = { "Mage's Ballad II" }, Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 394 }, Name = { "Valor Minuet" },     Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 395 }, Name = { "Valor Minuet II" },  Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 396 }, Name = { "Valor Minuet III" }, Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 397 }, Name = { "Valor Minuet IV" },  Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 399 }, Name = { "Sword Madrigal" },   Duration = { 120 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = { 400 }, Name = { "Blade Madrigal" },   Duration = { 120 }, ActiveItems = T{}, },
        },
        abilities = T{
            T{ IsEnabled = { false }, Id = {  35 }, Name = { "Provoke" },        Duration = {  30 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = {  44 }, Name = { "Sneak Attack" },   Duration = {  60 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = {  76 }, Name = { "Trick Attack" },   Duration = {  60 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = {  74 }, Name = { "Elemental Seal" }, Duration = { 600 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = {  75 }, Name = { "Divine Seal" },    Duration = { 600 }, ActiveItems = T{}, },
            T{ IsEnabled = { false }, Id = {  83 }, Name = { "Convert" },        Duration = { 780 }, ActiveItems = T{}, },
        },
    },
    HandlePacket = function(e, options)
        -- TODO: cancel bard song timers when a song is overwritten
        if e.id == 0x28 then
            local action = packets.inbound.action.parse(e.data_raw)

            if IsInParty(action.actor_id) then
                if action.category == Spell then
                    TryToTrackSpell(action, options.spells)
                elseif action.category == Ability then
                    TryToTrackAbility(action, options.abilities)
                end
            end
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('tracker') then
            imgui.Checkbox('Enabled', options.isEnabled)

            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end

            imgui.Separator()
            if imgui.CollapsingHeader('Tracked Spells') then
                for idx, spell in ipairs(options.spells) do
                    imgui.PushID(('spell%i.IsEnabled'):format(idx))
                    imgui.Checkbox('', spell.IsEnabled)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(80)
                    imgui.PushID(('spell%i.Id'):format(idx))
                    if imgui.InputInt('', spell.Id) then
                        spell.Name[1] = GetSpellName(spell.Id[1])
                    end
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(130)
                    imgui.PushID(('spell%i.Name'):format(idx))
                    imgui.InputText('', spell.Name, 256)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(80)
                    imgui.PushID(('spell%i.Duration'):format(idx))
                    imgui.InputInt('', spell.Duration)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.PushID(('spell%i.RemoveButton'):format(idx))
                    if imgui.Button('\xef\x87\xb8 Delete') then
                        table.remove(options.spells, idx)
                    end
                    imgui.PopID()
                end

                if imgui.Button('\xef\x81\xa7 Track another spell') then
                    options.spells:append(T{
                        IsEnabled = { false },
                        Id = { 0 },
                        Name = { '' },
                        Duration = { 0 },
                        ActiveItems = T{},
                    })
                end
            end

            imgui.Separator()
            if imgui.CollapsingHeader('Tracked Abilities') then
                for idx, ability in ipairs(options.abilities) do
                    imgui.PushID(('ability%i.IsEnabled'):format(idx))
                    imgui.Checkbox('', ability.IsEnabled)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(80)
                    imgui.PushID(('ability%i.Id'):format(idx))
                    if imgui.InputInt('', ability.Id) then
                        ability.Name[1] = GetAbilityName(ability.Id[1])
                    end
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(130)
                    imgui.PushID(('ability%i.Name'):format(idx))
                    imgui.InputText('', ability.Name, 256)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.SetNextItemWidth(80)
                    imgui.PushID(('ability%i.Duration'):format(idx))
                    imgui.InputInt('', ability.Duration)
                    imgui.PopID()

                    imgui.SameLine()
                    imgui.PushID(('ability%i.RemoveButton'):format(idx))
                    if imgui.Button('\xef\x87\xb8 Delete') then
                        table.remove(options.abilities, idx)
                    end
                    imgui.PopID()
                end

                if imgui.Button('\xef\x81\xa7 Track another ability') then
                    options.abilities:append(T{
                        IsEnabled = { false },
                        Id = { 0 },
                        Name = { '' },
                        Duration = { 0 },
                        ActiveItems = T{},
                    })
                end
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        local activeSpells = Where(options.spells, HasActiveItems)
        local activeAbilities = Where(options.abilities, HasActiveItems)
        if #activeSpells == 0 and #activeAbilities == 0 then return end

        Scale = gOptions.uiScale[1]

        ui.DrawUiWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)

            if #activeSpells > 0 then
                DrawTrackers(activeSpells)
            end

            if #activeAbilities > 0 then
                DrawTrackers(activeAbilities)
            end
        end)
    end,
}

return tracker
