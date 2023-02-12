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

-- The state we're operating on is the expiry time of the statuses
local DefaultDebuffs = {
    -- standard fare
    dia = 0,
    bio = 0,
    para = 0,
    slow = 0,
    grav = 0,
    blind = 0,
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

                -- Magic bursted debuffs
                -- Supposedly, the following debuffs can burst:
                --   dia i, ii, iii
                --   bio i, ii, iii
                --   paralyze i, ii
                --   stun
                --   elemental dots
                -- Dia, Bio, and the Elements burst with message 252, the normal
                -- magic burst message. Stun seems to be 268. Para shows in the
                -- database as  having burst message 84, and Para2 shows as not
                -- having a magic burst message. PServer nonsense?
                if message == 84 or message == 252 or message == 268 or message == 271 then
                    if spell == 58 or spell == 80 then -- para/para2
                        debuffs[target.id].para = now + 120
                    elseif spell == 56 or spell == 79 then -- slow/slow2
                        debuffs[target.id].slow = now + 180
                    elseif spell == 252 then -- stun
                        debuffs[target.id].stun = now + 5
                    end

                    if spell == 239 then -- shock
                        debuffs[target.id].shock = now + 120
                    elseif spell == 238 then -- rasp
                        debuffs[target.id].rasp = now + 120
                    elseif spell == 237 then -- choke
                        debuffs[target.id].choke = now + 120
                    elseif spell == 236 then -- frost
                        debuffs[target.id].frost = now + 120
                    elseif spell == 235 then -- burn
                        debuffs[target.id].burn = now + 120
                    elseif spell == 240 then -- drown
                        debuffs[target.id].drown = now + 120
                    end

                    local expiry = 0
                    if spell == 23 or spell == 33 or spell == 230 then
                        expiry = now + 60
                    elseif spell == 24 or spell == 231 then
                        expiry = now + 120
                    elseif spell == 25 or spell == 232 then
                        expiry = now + 150
                    end

                    if spell == 23 or spell == 24 or spell == 25 or spell == 33 then
                        debuffs[target.id].dia = expiry
                        debuffs[target.id].bio = 0
                    elseif spell == 230 or spell == 231 or spell == 232 then
                        debuffs[target.id].dia = 0
                        debuffs[target.id].bio = expiry
                    end
                end

                -- Bio and Dia
                if message == 2 or message == 264 then
                    local expiry = 0

                    if spell == 23 or spell == 33 or spell == 230 then
                        expiry = now + 60
                    elseif spell == 24 or spell == 231 then
                        expiry = now + 120
                    elseif spell == 25 or spell == 232 then
                        expiry = now + 150
                    end

                    if spell == 23 or spell == 24 or spell == 25 or spell == 33 then
                        debuffs[target.id].dia = expiry
                        debuffs[target.id].bio = 0
                    elseif spell == 230 or spell == 231 or spell == 232 then
                        debuffs[target.id].dia = 0
                        debuffs[target.id].bio = expiry
                    end
                -- Regular debuffs
                elseif message == 236 or message == 277 then
                    if spell == 58 or spell == 80 then -- para/para2
                        debuffs[target.id].para = now + 120
                    elseif spell == 56 or spell == 79 then -- slow/slow2
                        debuffs[target.id].slow = now + 180
                    elseif spell == 216 then -- gravity
                        debuffs[target.id].grav = now + 120
                    elseif spell == 254 or spell == 276 then -- blind/blind2
                        debuffs[target.id].blind = now + 180
                    elseif spell == 112 then -- flash
                        debuffs[target.id].blind = now + 12
                    elseif spell == 59 or spell == 359 then -- silence/ga
                        debuffs[target.id].silence = now + 120
                    elseif spell == 253 or spell == 259 or spell == 273 or spell == 274 then -- sleep/2/ga/2
                        debuffs[target.id].sleep = now + 90
                    elseif spell == 258 or spell == 362 then -- bind
                        debuffs[target.id].bind = now + 60
                    elseif spell == 252 then -- stun
                        debuffs[target.id].stun = now + 5
                    elseif spell <= 229 and spell >= 220 then -- poison/2
                        debuffs[target.id].poison = now + 120
                    end
                -- Elemental debuffs and bard songs
                elseif message == 237 or message == 278 then
                    if spell == 239 then -- shock
                        debuffs[target.id].shock = now + 120
                    elseif spell == 238 then -- rasp
                        debuffs[target.id].rasp = now + 120
                    elseif spell == 237 then -- choke
                        debuffs[target.id].choke = now + 120
                    elseif spell == 236 then -- frost
                        debuffs[target.id].frost = now + 120
                    elseif spell == 235 then -- burn
                        debuffs[target.id].burn = now + 120
                    elseif spell == 240 then -- drown
                        debuffs[target.id].drown = now + 120
                    elseif spell == 376 or spell == 463 then -- horde/foe lullaby
                        -- base is 30, but merits and song+
                        debuffs[target.id].sleep = now + 60
                    -- foe requiems; estimating extended durations
                    elseif spell == 368 then
                        debuffs[target.id].requiem = now + 100
                    elseif spell == 369 then
                        debuffs[target.id].requiem = now + 150
                    elseif spell == 370 then
                        debuffs[target.id].requiem = now + 200
                    elseif spell == 371 then
                        debuffs[target.id].requiem = now + 250
                    elseif spell == 372 then
                        debuffs[target.id].requiem = now + 300
                    elseif spell == 373 then
                        debuffs[target.id].requiem = now + 350
                    elseif spell == 421 then
                        debuffs[target.id].elegy = now + 150
                    elseif spell == 422 then
                        debuffs[target.id].elegy = now + 250
                    elseif spell >= 454 and spell <= 461 then -- threnodies
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
        elseif basic.param == 5 or basic.param == 156 then
            debuffs[basic.target].blind = 0
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
        showStatus = T{ false },
        name = 'xitools.tgt',
        size = T{ 276, -1 },
        pos = T{ 100, 100 },
        flags = bit.bor(ImGuiWindowFlags_NoDecoration),
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
            imgui.Checkbox('Show debuffs', options.showStatus)
            if imgui.InputInt2('Position', options.pos) then
                imgui.SetWindowPos(options.name, options.pos)
            end
            imgui.EndTabItem()
        end
    end,
    DrawMain = function(options, gOptions)
        -- don't bother drawing if we have no target
        local targetId = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0)
        if targetId == 0 then return end

        Scale = gOptions.uiScale[1]

        local entity = GetEntity(targetId)
        ui.DrawUiWindow(options, gOptions, function()
            imgui.SetWindowFontScale(Scale)
            DrawTgt(entity, options)
        end)
    end,
}

return tgt
