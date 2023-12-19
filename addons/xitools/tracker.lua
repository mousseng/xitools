require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local ffxi = require('utils/ffxi')
local packets = require('utils/packets')

local Scale = 1.0

local Spell = 4
local Ability = 6
local Arrow = '\xef\x81\xa1'
local Plus = '\xef\x81\xa7'
local Trash = '\xef\x87\xb8'
local Link = '\xef\x83\x81'

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
    local checkId = function(obj)
        return obj.Id[1] == spell.param
    end

    local isAliased = function(v)
        return v ~= nil and v:any(checkId)
    end

    local isTracked = function(v)
        return v.IsEnabled[1] and (checkId(v) or isAliased(v.Aliases))
    end

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
    local checkId = function(obj)
        return obj.Id[1] == ability.param
    end

    local isAliased = function(v)
        return v ~= nil and v:any(checkId)
    end

    local isTracked = function(v)
        return v.IsEnabled[1] and (checkId(v) or isAliased(v.Aliases))
    end

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

        imgui.Unindent(10 * Scale)
    end
end

local function ConfigTrackers(title, trackers, getName)
    if imgui.CollapsingHeader(title) then
        local textBaseWidth = imgui.CalcTextSize('A')

        for idx, trackedItem in ipairs(trackers) do
            imgui.PushID(('%s%i.IsEnabled'):format(title, idx))
            imgui.Checkbox('', trackedItem.IsEnabled)
            imgui.PopID()

            imgui.SameLine()
            imgui.SetNextItemWidth(80 * Scale)
            imgui.PushID(('%s%i.Id'):format(title, idx))
            if imgui.InputInt('', trackedItem.Id) then
                trackedItem.Name[1] = getName(trackedItem.Id[1])
            end
            imgui.PopID()

            imgui.SameLine()
            imgui.SetNextItemWidth(130 * Scale)
            imgui.PushID(('%s%i.Name'):format(title, idx))
            imgui.InputText('', trackedItem.Name, 256)
            imgui.PopID()

            imgui.SameLine()
            imgui.SetNextItemWidth(80 * Scale)
            imgui.PushID(('%s%i.Duration'):format(title, idx))
            imgui.InputInt('', trackedItem.Duration)
            imgui.PopID()

            imgui.SameLine()
            imgui.PushID(('%s%i.AliasButton'):format(title, idx))
            if imgui.Button('\xef\x83\x81 Alias') then
                if trackedItem.Aliases == nil then
                    trackedItem.Aliases = T{ }
                end
                table.insert(trackedItem.Aliases, { Id = { 0 }, Name = { '' } })
            end
            imgui.PopID()

            imgui.SameLine()
            imgui.PushID(('%s%i.RemoveButton'):format(title, idx))
            if imgui.Button('\xef\x87\xb8 Delete') then
                table.remove(trackers, idx)
            end
            imgui.PopID()

            if trackedItem.Aliases ~= nil and #trackedItem.Aliases > 0 then
                imgui.Indent(textBaseWidth * 4)
                if imgui.CollapsingHeader(('%s Aliases##%i'):format(trackedItem.Name[1], trackedItem.Id[1])) then
                    local tag = ('%s Aliases##%i Region'):format(trackedItem.Name[1], trackedItem.Id[1])
                    local size = { imgui.GetContentRegionAvail(), 300 }

                    if imgui.BeginChild(tag, size) then
                        for jdx, alias in ipairs(trackedItem.Aliases) do
                            imgui.SetNextItemWidth(80 * Scale)
                            imgui.PushID(('%s%i.Alias%i.Id'):format(title, idx, jdx))
                            if imgui.InputInt('', alias.Id) then
                                alias.Name[1] = getName(alias.Id[1])
                            end
                            imgui.PopID()

                            imgui.SameLine()
                            imgui.SetNextItemWidth(130 + 164 * Scale)
                            imgui.PushID(('%s%i.Alias%i.Name'):format(title, idx, jdx))
                            imgui.InputText('', alias.Name, 256)
                            imgui.PopID()

                            imgui.SameLine()
                            imgui.PushID(('%s%i.Alias%i.DeleteButton'):format(title, idx, jdx))
                            if imgui.Button('\xef\x87\xb8') then
                                table.remove(trackedItem.Aliases, jdx)
                            end
                            imgui.PopID()
                        end

                        imgui.EndChild()
                    end
                end

                imgui.Unindent(textBaseWidth * 4)
            end
        end

        if imgui.Button('\xef\x81\xa7 Track another') then
            trackers:append(T{
                IsEnabled = { false },
                Id = { 0 },
                Name = { '' },
                Duration = { 0 },
                ActiveItems = T{},
            })
        end
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
        spells = T{ },
        abilities = T{ },
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
            ConfigTrackers('Spells', options.spells, GetSpellName)

            imgui.Separator()
            ConfigTrackers('Abilities', options.abilities, GetAbilityName)

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
