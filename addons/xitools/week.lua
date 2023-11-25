require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils/packets')

local Scale = 1.0

local IsListening = { false }

local Colors = {
    KeyMissing    = { 0.80, 0.22, 0.00, 1.0 },
    KeyObtained   = { 0.60, 0.80, 0.20, 1.0 },
    TimerReady    = { 0.23, 0.67, 0.91, 1.0 },
    TimerNotReady = { 1.00, 1.00, 1.00, 1.0 },
    TimerUnknown  = { 1.00, 0.96, 0.56, 1.0 },
}

local Icons = {
    Times = '\xef\x81\x97',
    Check = '\xef\x81\x98',
}

local KeyItems = {
    ChocoboLicense      = { Id = 138, Name = "Chocobo License" },
    CenserOfAbandonment = { Id = 670, Name = "Censer of Abandonment" },
    CenserOfAntipathy   = { Id = 671, Name = "Censer of Antipathy" },
    CenserOfAnimus      = { Id = 672, Name = "Censer of Animus" },
    CenserOfAcrimony    = { Id = 673, Name = "Censer of Acrimony" },
    MonarchBeard        = { Id = 674, Name = "Monarch Beard" },
    AstralCovenant      = { Id = 675, Name = "Astral Covenant" },
    ShaftLever          = { Id = 676, Name = "Shaft #2716 Operating Lever" },
    ZephyrFan           = { Id = 677, Name = "Zephyr Fan" },
    MiasmaFilter        = { Id = 678, Name = "Miasma Filter" },
    CosmoCleanse        = { Id = 734, Name = "Cosmo Cleanse" },
}

local Weeklies = T{
    {
        Level = '75',
        Name = 'Limbus',
        KeyItem = KeyItems.CosmoCleanse,
        Cooldown = 72 * 3600,
    },
    {
        Level = '75',
        Name = 'Boneyard Gully',
        KeyItem = KeyItems.MiasmaFilter,
        Cooldown = 120 * 3600,
    },
    {
        Level = '75',
        Name = 'Bearclaw Pinnacle',
        KeyItem = KeyItems.ZephyrFan,
        Cooldown = 120 * 3600,
    },
    {
        Level = '75, 60',
        Name = 'Mine Shaft #2716',
        KeyItem = KeyItems.ShaftLever,
        Cooldown = 120 * 3600,
    },
    {
        Level = '50',
        Name = 'Spire of Vahzl',
        KeyItem = KeyItems.CenserOfAcrimony,
        Cooldown = 120 * 3600,
    },
    {
        Level = '50, 40',
        Name = 'Monarch Linn',
        KeyItem = KeyItems.MonarchBeard,
        Cooldown = 120 * 3600,
    },
    {
        Level = '40',
        Name = 'The Shrouded Maw',
        KeyItem = KeyItems.AstralCovenant,
        Cooldown = 120 * 3600,
    },
    {
        Level = '30',
        Name = 'Spire of Mea',
        KeyItem = KeyItems.CenserOfAnimus,
        Cooldown = 120 * 3600,
    },
    {
        Level = '30',
        Name = 'Spire of Holla',
        KeyItem = KeyItems.CenserOfAbandonment,
        Cooldown = 120 * 3600,
    },
    {
        Level = '30',
        Name = 'Spire of Dem',
        KeyItem = KeyItems.CenserOfAntipathy,
        Cooldown = 120 * 3600,
    },
}

local function SortByLength(l, r)
    if #l == #r then
        return l > r
    else
        return #l > #r
    end
end

local TableFlags = bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_Borders, ImGuiTableFlags_NoBordersInBody)
local TableDef = {
    {
        Name = 'Activity',
        Flags = ImGuiTableColumnFlags_None,
        Width = imgui.CalcTextSize(
            Weeklies
                :map(function(w) return w.Name end)
                :append('Activity')
                :sort(SortByLength)
                :first()
            ),
        Draw = function(activity, player, timers, now)
            imgui.Text(activity.Name)
        end,
    },
    {
        Name = 'Level(s)',
        Flags = ImGuiTableColumnFlags_None,
        Width = imgui.CalcTextSize(
            Weeklies
                :map(function(w) return w.Level end)
                :append('Level(s)')
                :sort(SortByLength)
                :first()
            ),
        Draw = function(activity, player, timers, now)
            imgui.Text(activity.Level)
        end,
    },
    {
        Name = 'Key Item',
        Flags = ImGuiTableColumnFlags_None,
        Width = imgui.CalcTextSize(
            Weeklies
                :map(function(w) return w.KeyItem.Name end)
                :append('Key Item')
                :sort(SortByLength)
                :first()
            ),
        Draw = function(activity, player, timers, now)
            imgui.Text(activity.KeyItem.Name)
        end,
    },
    {
        Name = 'Have KI',
        Flags = ImGuiTableColumnFlags_None,
        Width = imgui.CalcTextSize('Have KI'),
        Draw = function(activity, player, timers, now)
            -- TODO: save this state somewhere instead of querying every frame
            local color = Colors.KeyMissing
            local icon = Icons.Times

            if player:HasKeyItem(activity.KeyItem.Id) then
                color = Colors.KeyObtained
                icon = Icons.Check
            end

            imgui.PushStyleColor(ImGuiCol_Text, color)
            imgui.Text(icon)
            imgui.PopStyleColor()
        end,
    },
    {
        Name = 'Next KI',
        Flags = ImGuiTableColumnFlags_None,
        Width = imgui.CalcTextSize('Day, Mon 99 at hh:mm:ss'),
        Draw = function(activity, player, timers, now)
            local targetTime = timers[activity.Name]
            local readyTime = ''

            if targetTime == nil then
                imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerUnknown)
                readyTime = '???'
            elseif now >= targetTime.time then
                imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerReady)
                readyTime = 'now'
            else
                imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerNotReady)
                readyTime = targetTime.desc
            end

            imgui.Text(readyTime)
            imgui.PopStyleColor()
        end,
    },
}

local function DrawWeek(timers)
    local now = os.time()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    if IsListening[1] then
        imgui.PushStyleColor(ImGuiCol_Text, Colors.KeyObtained)
        imgui.Checkbox('Listening for key item updates', IsListening)
        imgui.PopStyleColor()
    else
        imgui.PushStyleColor(ImGuiCol_Text, Colors.KeyMissing)
        imgui.Checkbox('Ignoring key item updates', IsListening)
        imgui.PopStyleColor()
    end

    imgui.Separator()

    imgui.PushStyleVar(ImGuiStyleVar_CellPadding, { 10, 3 })
    if imgui.BeginTable('xitools.week.summary', #TableDef, TableFlags) then
        imgui.TableSetupScrollFreeze(0, 1)
        for _, col in ipairs(TableDef) do
            imgui.TableSetupColumn(col.Name, col.Flags, col.Width)
        end
        imgui.TableHeadersRow()

        for _, activity in ipairs(Weeklies) do
            imgui.TableNextRow()

            for _, col in ipairs(TableDef) do
                imgui.TableNextColumn()
                col.Draw(activity, player, timers, now)
            end
        end

        imgui.EndTable()
    end
    imgui.PopStyleVar()
end

---@type xitool
local week = {
    Name = 'week',
    Aliases = T{ 'w', 'e', 'enm', },
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.week',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoResize),
        timers = T{ },
    },
    HandleCommand = function(args, options)
        if #args == 0 then
            options.isVisible[1] = not options.isVisible[1]
        end
    end,
    HandlePacket = function(e, options)
        -- we get a key item update on every zone change, and the client
        -- will have already dumped its knowledge of held key items. to
        -- ensure we're not getting false positives from this scenario,
        -- we stop listening for key item updates until we receive the "stop
        -- downloading" packet, by which time we're sure to have all of our
        -- basic syncing out of the way.

        if e.id == 0x0A or e.id == 0x0B then
            IsListening[1] = false
        elseif e.id == 0x41 then
            IsListening[1] = true
        elseif IsListening[1] and e.id == packets.inbound.keyItems.id then
            local now = os.time()
            local player = AshitaCore:GetMemoryManager():GetPlayer()
            local keyItems = packets.inbound.keyItems.parse(e.data_raw)

            for _, weekly in pairs(Weeklies) do
                if not player:HasKeyItem(weekly.KeyItem.Id)
                and keyItems.heldList[weekly.KeyItem.Id] then
                    local timestamp = now + weekly.Cooldown
                    options.timers[weekly.Name] = {
                        time = timestamp,
                        desc = os.date('%a, %b %d at %X', timestamp)
                    }
                end
            end
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('week') then
            imgui.Checkbox('Enabled', options.isEnabled)
            imgui.Checkbox('Visible', options.isVisible)
            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        Scale = gOptions.uiScale[1]

        ui.DrawNormalWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            DrawWeek(options.timers)
        end)
    end,
}

return week
