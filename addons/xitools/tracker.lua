require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local ffxi = require('utils.ffxi')
local packets = require('utils.packets')

local Spell = 4
local Ability = 6
local Arrow = '\xef\x81\xa1'

local function GetSpellName(id)
    return AshitaCore:GetResourceManager():GetSpellById(id).Name[1]
end

local function GetAbilityName(id)
    return AshitaCore:GetResourceManager():GetAbilityById(id + 512).Name[1]
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
        trackers = T{
            -- for type: 4 is spell, 6 is job ability
            T{ IsEnabled = T{ false }, Id =  57, Name = '', Type = 4, Duration = 180, ActiveItems = T{}, }, -- haste
            T{ IsEnabled = T{ false }, Id = 109, Name = '', Type = 4, Duration = 150, ActiveItems = T{}, }, -- refresh
            T{ IsEnabled = T{ false }, Id = 108, Name = '', Type = 4, Duration =  75, ActiveItems = T{}, }, -- regen i
            T{ IsEnabled = T{ false }, Id = 110, Name = '', Type = 4, Duration =  60, ActiveItems = T{}, }, -- regen ii
            T{ IsEnabled = T{ false }, Id = 111, Name = '', Type = 4, Duration =  60, ActiveItems = T{}, }, -- regen iii
            T{ IsEnabled = T{ false }, Id = 386, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- ballad i
            T{ IsEnabled = T{ false }, Id = 387, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- ballad ii
            T{ IsEnabled = T{ false }, Id = 394, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet i
            T{ IsEnabled = T{ false }, Id = 395, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet ii
            T{ IsEnabled = T{ false }, Id = 396, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet iii
            T{ IsEnabled = T{ false }, Id = 397, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- minuet iv
            T{ IsEnabled = T{ false }, Id = 399, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- sword madrigal
            T{ IsEnabled = T{ false }, Id = 400, Name = '', Type = 4, Duration = 120, ActiveItems = T{}, }, -- blade madrigal
            T{ IsEnabled = T{ false }, Id =  35, Name = '', Type = 6, Duration =  30, ActiveItems = T{}, }, -- provoke
            T{ IsEnabled = T{ false }, Id =  44, Name = '', Type = 6, Duration =  60, ActiveItems = T{}, }, -- sneak
            T{ IsEnabled = T{ false }, Id =  76, Name = '', Type = 6, Duration =  60, ActiveItems = T{}, }, -- trick
            T{ IsEnabled = T{ false }, Id =  74, Name = '', Type = 6, Duration = 600, ActiveItems = T{}, }, -- e.seal
            T{ IsEnabled = T{ false }, Id =  75, Name = '', Type = 6, Duration = 600, ActiveItems = T{}, }, -- d.seal
            T{ IsEnabled = T{ false }, Id =  83, Name = '', Type = 6, Duration = 780, ActiveItems = T{}, }, -- convert
        },
    },
    Load = function(options)
        for _, tracker in pairs(options.trackers) do
            if tracker.Type == Spell then
                tracker.Name = GetSpellName(tracker.Id)
            elseif tracker.Type == Ability then
                tracker.Name = GetAbilityName(tracker.Id)
            end
        end
    end,
    HandlePacket = function(e, options)
        -- TODO: cancel bard song timers when a song is overwritten
        if e.id == 0x28 then
            local action = packets.inbound.action.parse(e.data_raw)
            local isTracked = function(v) return v.IsEnabled[1] and v.Id == action.param end

            if IsInParty(action.actor_id) then
                local _, tracker = options.trackers:find_if(isTracked)
                if tracker ~= nil then
                    for i = 1, action.target_count do
                        local target = action.targets[i]

                        local _, existingTimer = tracker.ActiveItems:find_if(function(v) return v.id == target.id end)
                        if existingTimer == nil then
                            local serverId = target.id
                            if action.category == Ability then
                                serverId = action.actor_id
                            end

                            local castInfo = {
                                id = target.id,
                                name = ffxi.GetEntityNameByServerId(serverId),
                                time = os.time(),
                            }

                            tracker.ActiveItems:append(castInfo)
                        else
                            existingTimer.time = os.time()
                        end
                    end
                end
            end
        end
    end,
    DrawConfig = function(options)
        if imgui.BeginTabItem('tracker') then
            imgui.Checkbox('Enabled', options.isEnabled)

            for _, tracker in ipairs(options.trackers) do
                imgui.Checkbox(('Track %s'):format(tracker.Name), tracker.IsEnabled)
            end

            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end

            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options)
        local activeTrackers = Where(options.trackers, HasActiveItems)
        if #activeTrackers == 0 then return end

        local now = os.time()

        ui.DrawUiWindow(options, function()
            for _, trackedItem in ipairs(activeTrackers) do
                imgui.Text(trackedItem.Name)
                imgui.Indent(10)

                for idx, activeItem in ipairs(trackedItem.ActiveItems) do
                    local elapsed = now - activeItem.time

                    if elapsed > trackedItem.Duration + 5 then
                        table.remove(trackedItem.ActiveItems, idx)
                    elseif elapsed > trackedItem.Duration then
                        imgui.TextDisabled(('%s %s'):format(Arrow, activeItem.name))
                    else
                        local remaining = trackedItem.Duration - elapsed
                        imgui.Text(('%s %s - %ss'):format(Arrow, activeItem.name, remaining))
                    end
                end

                imgui.Unindent(10)
            end
        end)
    end,
}

return tracker
