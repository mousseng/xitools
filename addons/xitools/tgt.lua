require('common')
local bit = require('bit')
local imgui = require('imgui')
local ui = require('ui')
local packets = require('utils.packets')

local Scale = 1.0

local Threnodies = {
    [454] = 'fire',
    [455] = 'ice',
    [456] = 'wind',
    [457] = 'earth',
    [458] = 'lightning',
    [459] = 'water',
    [460] = 'light',
    [461] = 'dark',
}

local Statuses = {
    dbTier1 = T{ 23, 33, 230, },
    dbTier2 = T{ 24, 231, },
    dbTier3 = T{ 25, 232, },
    dia = T{ 23, 24, 25, 33, },
    bio = T{ 230, 231, 232, },
    paralyze = T{ 58, 80, 341, 342, 343, },
    slow = T{ 56, 79, 344, 345, 346, },
    gravity = T{ 216, },
    blind = T{ 254, 276, 361, 347, 348, 349, },
    flash = T{ 112, },
    silence = T{ 59, 359, },
    sleep = T{ 253, 259, 273, 274, },
    bind = T{ 258, 362, },
    stun = T{ 252, },
    poison = T{ 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 350, 351, 352, },
    threnody = T{ 454, 455, 456, 457, 458, 459, 460, 461 },
    lullaby = T{ 376, 463, },
    requiem = T{ 368, 369, 370, 371, 372, 373, },
    elegy = T{ 421, 422 },
    drown = 240,
    shock = 239,
    rasp = 238,
    choke = 237,
    frost = 236,
    burn = 235,
}

-- The state we're operating on is the expiry time of the statuses
local DefaultDebuffs = {
    -- standard fare
    dia = 0,
    bio = 0,
    para = 0,
    slow = 0,
    grav = 0,
    blind = 0,
    flash = 0,
    -- utility
    silence = 0,
    sleep = 0,
    bind = 0,
    stun = 0,
    -- misc
    virus = 0,
    curse = 0,
    -- dots
    poison = 0,
    shock = 0,
    rasp = 0,
    choke = 0,
    frost = 0,
    burn = 0,
    drown = 0,
    -- bard stuff
    requiem = 0,
    elegy = 0,
    threnody = 0,
    threnodyEle = nil,
}

local TrackedEnemies = { }

---@param object table
---@return table
local function DeepCopy(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for index, value in pairs(obj) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(object)
end

local function GetThrenodyColor(element)
    if element == 'light' then
        return ui.Colors.StatusWhite
    elseif element == 'dark' then
        return ui.Colors.StatusBlack
    elseif element == 'fire' then
        return ui.Colors.StatusRed
    elseif element == 'ice' then
        return ui.Colors.StatusCyan
    elseif element == 'wind' then
        return ui.Colors.StatusGreen
    elseif element == 'earth' then
        return ui.Colors.StatusBrown
    elseif element == 'lightning' then
        return ui.Colors.StatusYellow
    elseif element == 'water' then
        return ui.Colors.StatusBlue
    end
end

---@param debuffs table
---@param action any
local function HandleAction(debuffs, action)
    local now = os.time()

    for _, target in pairs(action.targets) do
        for _, ability in pairs(target.actions) do
            if action.category == 4 then
                -- Set up our state
                local spell = action.param
                local message = ability.message
                debuffs[target.id] = debuffs[target.id] or DeepCopy(DefaultDebuffs)

                -- Bio and Dia
                if message == 2 or message == 264 or message == 252 then
                    local expiry = 0

                    if Statuses.dbTier1:contains(spell) then
                        expiry = now + 60
                    elseif Statuses.dbTier2:contains(spell) then
                        expiry = now + 120
                    elseif Statuses.dbTier3:contains(spell) then
                        expiry = now + 150
                    end

                    if Statuses.dia:contains(spell) then
                        debuffs[target.id].dia = expiry
                        debuffs[target.id].bio = 0
                    elseif Statuses.bio:contains(spell) then
                        debuffs[target.id].dia = 0
                        debuffs[target.id].bio = expiry
                    end
                -- Regular debuffs
                elseif message == 236 or message == 277 or message == 268 or message == 271 then
                    if Statuses.paralyze:contains(spell) then
                        debuffs[target.id].para = now + 120
                    elseif Statuses.slow:contains(spell) then
                        debuffs[target.id].slow = now + 180
                    elseif Statuses.gravity:contains(spell) then
                        debuffs[target.id].grav = now + 120
                    elseif Statuses.blind:contains(spell) then
                        debuffs[target.id].blind = now + 180
                    elseif Statuses.flash:contains(spell) then
                        debuffs[target.id].flash = now + 12
                    elseif Statuses.silence:contains(spell) then
                        debuffs[target.id].silence = now + 120
                    elseif Statuses.sleep:contains(spell) then
                        debuffs[target.id].sleep = now + 90
                    elseif Statuses.bind:contains(spell) then
                        debuffs[target.id].bind = now + 60
                    elseif Statuses.stun:contains(spell) then
                        debuffs[target.id].stun = now + 5
                    elseif Statuses.poison:contains(spell) then
                        debuffs[target.id].poison = now + 120
                    end
                -- Elemental debuffs and bard songs
                elseif message == 237 or message == 278 then
                    if spell == Statuses.shock then -- shock
                        debuffs[target.id].shock = now + 120
                    elseif spell == Statuses.rasp then
                        debuffs[target.id].rasp = now + 120
                    elseif spell == Statuses.choke then
                        debuffs[target.id].choke = now + 120
                    elseif spell == Statuses.frost then
                        debuffs[target.id].frost = now + 120
                    elseif spell == Statuses.burn then
                        debuffs[target.id].burn = now + 120
                    elseif spell == Statuses.drown then
                        debuffs[target.id].drown = now + 120
                    elseif Statuses.lullaby:contains(spell) then
                        -- base is 30, but merits and song+
                        debuffs[target.id].sleep = now + 60
                    -- foe requiems; estimating extended durations
                    elseif spell == Statuses.requiem[1] then
                        debuffs[target.id].requiem = now + 100
                    elseif spell == Statuses.requiem[2] then
                        debuffs[target.id].requiem = now + 150
                    elseif spell == Statuses.requiem[3] then
                        debuffs[target.id].requiem = now + 200
                    elseif spell == Statuses.requiem[4] then
                        debuffs[target.id].requiem = now + 250
                    elseif spell == Statuses.requiem[5] then
                        debuffs[target.id].requiem = now + 300
                    elseif spell == Statuses.requiem[6] then
                        debuffs[target.id].requiem = now + 350
                    elseif spell == Statuses.elegy[1] then
                        debuffs[target.id].elegy = now + 150
                    elseif spell == Statuses.elegy[2] then
                        debuffs[target.id].elegy = now + 250
                    elseif Statuses.threnody:contains(spell) then
                        debuffs[target.id].threnody = now + 120
                        debuffs[target.id].threnodyEle = Threnodies[spell]
                    end
                end
            end
        end
    end
end

---@param debuffs table
---@param basic any
local function HandleBasic(debuffs, basic)
    -- if we're tracking a mob that dies, reset its status
    if basic.message == 6 and debuffs[basic.target] then
        debuffs[basic.target] = nil
    elseif basic.message == 206 then
        if debuffs[basic.target] == nil then
            return
        end

        if basic.param == 2 or basic.param == 19 then
            debuffs[basic.target].sleep = 0
        elseif basic.param == 3 or basic.param == 540 then
            debuffs[basic.target].poison = 0
        elseif basic.param == 4 or basic.param == 566 then
            debuffs[basic.target].para = 0
        elseif basic.param == 5 then
            debuffs[basic.target].blind = 0
        elseif basic.param == 156 then
            debuffs[basic.target].flash = 0
        elseif basic.param == 6 then
            debuffs[basic.target].silence = 0
        elseif basic.param == 8 then
            debuffs[basic.target].virus = 0
        elseif basic.param == 9 or basic.param == 20 then
            debuffs[basic.target].curse = 0
        elseif basic.param == 10 then
            debuffs[basic.target].stun = 0
        elseif basic.param == 11 then
            debuffs[basic.target].bind = 0
        elseif basic.param == 12 or basic.param == 567 then
            debuffs[basic.target].grav = 0
        elseif basic.param == 13 or basic.param == 565 then
            debuffs[basic.target].slow = 0
        elseif basic.param == 128 then
            debuffs[basic.target].burn = 0
        elseif basic.param == 129 then
            debuffs[basic.target].frost = 0
        elseif basic.param == 130 then
            debuffs[basic.target].choke = 0
        elseif basic.param == 131 then
            debuffs[basic.target].rasp = 0
        elseif basic.param == 132 then
            debuffs[basic.target].shock = 0
        elseif basic.param == 133 then
            debuffs[basic.target].drown = 0
        elseif basic.param == 134 then
            debuffs[basic.target].dia = 0
        elseif basic.param == 135 then
            debuffs[basic.target].bio = 0
        elseif basic.param == 192 then
            debuffs[basic.target].requiem = 0
        elseif basic.param == 194 then
            debuffs[basic.target].elegy = 0
        elseif basic.param == 217 then
            debuffs[basic.target].threnody = 0
            debuffs[basic.target].threnodyEle = nil
        end
    end
end

---@param name     string
---@param distance number
---@param options  table
local function DrawHeader(name, distance, options)
    imgui.Text(name)

    local dist = string.format('%.1fm', distance)
    local width = imgui.CalcTextSize(dist) + ui.Styles.WindowPadding[1] * Scale

    imgui.SameLine()
    imgui.SetCursorPosX(options.size[1] * Scale - width)
    imgui.Text(dist)
end

---@param hpPercent integer
local function DrawHp(hpPercent)
    local title = string.format('HP %3i%%%%', hpPercent)
    local textColor = ui.Colors.White
    local barColor = ui.Colors.HpBar

    if hpPercent > 0.75 then
        textColor = ui.Colors.White
    elseif hpPercent > 0.50 then
        textColor = ui.Colors.Yellow
    elseif hpPercent > 0.25 then
        textColor = ui.Colors.Orange
    elseif hpPercent >= 0.00 then
        textColor = ui.Colors.Red
    end

    imgui.PushStyleColor(ImGuiCol_Text, textColor)
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barColor)
    ui.DrawBar(title, hpPercent, 100, ui.Scale(ui.Styles.BarSize, Scale), '')
    imgui.PopStyleColor(2)
end

local function DrawSeparator()
    imgui.PopStyleVar()
    imgui.Text('')
    imgui.SameLine()
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 0, 0 })
end

local function DrawStatusEntry(text, isActive, color)
    if isActive then
        imgui.PushStyleColor(ImGuiCol_Text, color)
    else
        imgui.PushStyleColor(ImGuiCol_Text, ui.Colors.StatusGrey)
    end

    imgui.Text(text)
    imgui.SameLine()
    imgui.PopStyleColor()
end

---@param debuffs table
local function DrawStatus(debuffs)
    local now = os.time()
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 0, 0 })
    DrawStatusEntry('D',  now < debuffs.dia, ui.Colors.StatusWhite)
    DrawStatusEntry('B',  now < debuffs.bio, ui.Colors.StatusBlack)
    DrawSeparator()
    DrawSeparator()
    DrawStatusEntry('P',  now < debuffs.para, ui.Colors.StatusWhite)
    DrawStatusEntry('S',  now < debuffs.slow, ui.Colors.StatusWhite)
    DrawStatusEntry('E',  now < debuffs.elegy, ui.Colors.StatusBrown)
    DrawStatusEntry('G',  now < debuffs.grav, ui.Colors.StatusBlack)
    DrawStatusEntry('B',  now < debuffs.blind, ui.Colors.StatusBlack)
    DrawStatusEntry('F',  now < debuffs.flash, ui.Colors.StatusWhite)
    DrawSeparator()
    DrawSeparator()
    DrawStatusEntry('Si', now < debuffs.silence, ui.Colors.StatusWhite)
    DrawSeparator()
    DrawStatusEntry('Sl', now < debuffs.sleep, ui.Colors.StatusBlack)
    DrawSeparator()
    DrawStatusEntry('Bi', now < debuffs.bind, ui.Colors.StatusBlack)
    DrawSeparator()
    DrawStatusEntry('Po', now < debuffs.poison, ui.Colors.StatusBlack)
    DrawSeparator()
    DrawStatusEntry('Rq', now < debuffs.requiem, ui.Colors.StatusWhite)
    DrawSeparator()
    DrawSeparator()
    DrawStatusEntry('S',  now < debuffs.shock, ui.Colors.StatusYellow)
    DrawStatusEntry('R',  now < debuffs.rasp, ui.Colors.StatusBrown)
    DrawStatusEntry('C',  now < debuffs.choke, ui.Colors.StatusGreen)
    DrawStatusEntry('F',  now < debuffs.frost, ui.Colors.StatusCyan)
    DrawStatusEntry('B',  now < debuffs.burn, ui.Colors.StatusRed)
    DrawStatusEntry('D',  now < debuffs.drown, ui.Colors.StatusBlue)

    if debuffs.threnodyEle ~= nil then
        imgui.NewLine()
        imgui.Text('Threnody: ')
        imgui.SameLine()
        imgui.PushStyleColor(ImGuiCol_Text, GetThrenodyColor(debuffs.threnodyEle))
        imgui.Text(debuffs.threnodyEle)
        imgui.PopStyleColor()
    end

    imgui.PopStyleVar()
end

---@param entity Entity
---@param options table
local function DrawTgt(entity, options)
    DrawHeader(entity.Name, math.sqrt(entity.Distance), options)
    DrawHp(entity.HPPercent)
    if options.showStatus[1] then
        DrawStatus(TrackedEnemies[entity.ServerId] or DefaultDebuffs)
    end
end

---@type xitool
local tgt = {
    Name = 'tgt',
    DefaultSettings = T{
        isEnabled = T{ false },
        isVisible = T{ true },
        showMain = T{ true },
        showSub = T{ false },
        showTot = T{ false },
        mainWindow = T{
            isVisible = T{ true },
            showStatus = T{ false },
            name = 'xitools.tgt.main',
            size = T{ 276, -1 },
            pos = T{ 100, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        subWindow = T{
            isVisible = T{ true },
            showStatus = T{ false },
            name = 'xitools.tgt.sub',
            size = T{ 276, -1 },
            pos = T{ 100, 200 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
        totWindow = T{
            isVisible = T{ true },
            showStatus = T{ false },
            name = 'xitools.tgt.tot',
            size = T{ 276, -1 },
            pos = T{ 386, 100 },
            flags = bit.bor(ImGuiWindowFlags_NoDecoration),
        },
    },
    HandlePacket = function(e, options)
        -- don't track anything if we're not displaying it
        if not options.showStatus[1] then return end

        -- clear state on zone changes
        -- TODO: clear mob state on death
        if e.id == 0x00A then
            TrackedEnemies = { }
        elseif e.id == 0x028 then
            HandleAction(TrackedEnemies, packets.inbound.action.parse(e.data_raw))
        elseif e.id == 0x029 then
            HandleBasic(TrackedEnemies, packets.inbound.basic.parse(e.data))
        end
    end,
    DrawConfig = function(options, gOptions)
        if imgui.BeginTabItem('tgt') then
            imgui.Checkbox('Enabled', options.isEnabled)

            imgui.Checkbox('Show main target', options.showMain)
            imgui.SameLine()
            imgui.Checkbox('Show debuffs##mt', options.mainWindow.showStatus)

            imgui.Checkbox('Show sub-target', options.showSub)
            imgui.SameLine()
            imgui.Checkbox('Show debuffs##st', options.subWindow.showStatus)

            imgui.Checkbox('Show target of target', options.showTot)
            imgui.SameLine()
            imgui.Checkbox('Show debuffs##tot', options.totWindow.showStatus)

            if imgui.InputInt2('Target position', options.mainWindow.pos) then
                imgui.SetWindowPos(options.mainWindow.name, options.mainWindow.pos)
            end
            if imgui.InputInt2('Sub-target position', options.subWindow.pos) then
                imgui.SetWindowPos(options.subWindow.name, options.subWindow.pos)
            end
            if imgui.InputInt2('Target of target position', options.totWindow.pos) then
                imgui.SetWindowPos(options.totWindow.name, options.totWindow.pos)
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        local tgt = AshitaCore:GetMemoryManager():GetTarget()
        local targetId = tgt:GetTargetIndex(0)
        local targetActive = tgt:GetActive(0) == 1
        local subTargetId = tgt:GetTargetIndex(1)
        local subTargetActive = tgt:GetIsSubTargetActive() == 1
        local totId = 0


        -- the target struct appears to be a stack, so when we have two targets
        -- that means the subtarget is actually in [0] and main moves to [1]
        if subTargetActive then
            targetId, subTargetId = subTargetId, targetId
        end

        -- TODO: if no subtarget, check for stpt/stal

        Scale = gOptions.uiScale[1]

        if options.showMain[1] and targetActive and targetId ~= 0 then
            ui.DrawUiWindow(options.mainWindow, gOptions, function()
                imgui.SetWindowFontScale(Scale)

                local entity = GetEntity(targetId)
                DrawTgt(entity, options.mainWindow)
                totId = entity.TargetedIndex or 0
            end)
        end

        if options.showSub[1] and subTargetActive and subTargetId ~= 0 then
            ui.DrawUiWindow(options.subWindow, gOptions, function()
                imgui.SetWindowFontScale(Scale)

                local entity = GetEntity(subTargetId)
                DrawTgt(entity, options.subWindow)
            end)
        end

        if options.showTot[1] and totId ~= 0 then
            -- it's possible for your target to be targeting something that your
            -- client does not know about (even if it has an id for it). ensure
            -- that we actually have all the info before trying to draw anything
            local entity = GetEntity(totId)
            if entity then
                ui.DrawUiWindow(options.totWindow, gOptions, function()
                    imgui.SetWindowFontScale(Scale)

                    -- TODO: compact tot display
                    DrawTgt(entity, options.totWindow)
                end)
            end
        end
    end,
}

return tgt
