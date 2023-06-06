require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils.packets')
local inspect = require('utils.inspect')

local Scale = 1.0

local Colors = {
    KeyMissing    = { 0.80, 0.22, 0.00, 1.0 },
    KeyObtained   = { 0.60, 0.80, 0.20, 1.0 },
    TimerReady    = { 0.23, 0.67, 0.91, 1.0 },
    TimerNotReady = { 1.00, 1.00, 1.00, 1.0 },
    TimerUnknown  = { 1.00, 0.96, 0.56, 1.0 },
}

local KeyItems = {
    CenserOfAbandonment = { Id = 670, Name = "Censer of Abandonment" },
    CenserOfAntipathy   = { Id = 671, Name = "Censer of Antipathy" },
    CenserOfAnimus      = { Id = 672, Name = "Censer of Animus" },
    CenserOfAcrimony    = { Id = 673, Name = "Censer of Acrimony" },
    MonarchBeard        = { Id = 674, Name = "Monarch Beard" },
    AstralCovenant      = { Id = 675, Name = "Astral Covenant" },
    ShaftLever          = { Id = 676, Name = "Shaft #2716 Operating Lever" },
    ZephyrFan           = { Id = 677, Name = "Zephyr Fan" },
    MiasmaFilter        = { Id = 678, Name = "Miasma Filter" },
}

local Weeklies = {
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
        Level = '60 or 75',
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
        Level = '40 or 50',
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

local function GetReadyTime(targetTime, now)
    if targetTime == nil then
        imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerUnknown)
        return '???'
    elseif now >= targetTime then
        imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerReady)
        return 'now!'
    end

    imgui.PushStyleColor(ImGuiCol_Text, Colors.TimerNotReady)
    return os.date('on %a, %b %d at %X', targetTime)
end

local function DrawWeek(timers)
    local now = os.time()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    for _, enm in ipairs(Weeklies) do
        imgui.Text(string.format('%s [Lv%s]', enm.Name, enm.Level))

        if player:HasKeyItem(enm.KeyItem.Id) then
            imgui.PushStyleColor(ImGuiCol_Text, Colors.KeyObtained)
            imgui.Text(string.format('%s obtained', enm.KeyItem.Name))
            imgui.PopStyleColor()
        else
            imgui.PushStyleColor(ImGuiCol_Text, Colors.KeyMissing)
            imgui.Text(string.format('%s missing', enm.KeyItem.Name))
            imgui.PopStyleColor()
        end

        local readyTime = GetReadyTime(timers[enm.Name], now)
        imgui.Text(string.format('Obtainable %s', readyTime))
        imgui.PopStyleColor()
        imgui.Separator()
    end
end

---@type xitool
local week = {
    Name = 'week',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        name = 'xitools.week',
        size = T{ -1, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoResize),
        timers = T{ },
    },
    HandlePacket = function(e, options)
        if e.id == packets.inbound.keyItems.id then
            local now = os.time()
            local player = AshitaCore:GetMemoryManager():GetPlayer()
            local keyItems = packets.inbound.keyItems.parse(e.data_raw)

            for _, weekly in pairs(Weeklies) do
                if not player:HasKeyItem(weekly.KeyItem.Id)
                and keyItems.heldList[weekly.KeyItem.Id] then
                    options.timers[weekly.Name] = now + weekly.Cooldown
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
