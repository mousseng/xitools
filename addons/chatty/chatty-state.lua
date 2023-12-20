require('common')
local chat = require('chat')
local inspect = require('inspect')
local symbols = require('chat-symbols')
local colors = require('chat-colors')
local modes = require('chat-modes')

local state = {
    IsDebugOn = false,
    AllMessages = { },
    TabMessages = { },
    TabFilters = { },
    Tabs = { },
}

---Generate a random UUID. These are simply used to disambiguate tabs with
---identical names (not that people should do that, but it costs essentially
---nothing to avoid).
---@return string
local function GenerateUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)

    return uuid
end

---Logs a formatted message if debugging is enabled.
---@param msg string
---@param ... unknown
function state:Debug(msg, ...)
    if not self.IsDebugOn then
        return
    end

    local formatted = string.format(msg, ...)
    local headerized = chat.header('chatty-debug'):append(':: '):append(chat.message(formatted))
    print(headerized)
end

---Prints a formatted error message.
---@param msg string
---@param ... unknown
function state:Error(msg, ...)
    local formatted = string.format(msg, ...)
    local headerized = chat.header('chatty'):append(chat.error(formatted))
    print(headerized)
end

---Serializes some persistable configuration values and writes it to a .lua file.
---This is heavily based on the ashita settings lib.
function state:SaveSettings()
    self:Debug('state:SaveSettings()')

    local settingsDir = string.format(
        '%s\\config\\addons\\%s',
        AshitaCore:GetInstallPath(),
        addon.name)

    local settingsPath = string.format(
        '%s\\settings.lua',
        settingsDir,
        addon.name)

    local settings = inspect {
        IsDebugOn = self.IsDebugOn,
        TabFilters = self.TabFilters,
        Tabs = self.Tabs,
    }

    local serialized = string.format('return %s', settings)
    ashita.fs.create_dir(settingsDir)

    local file = io.open(settingsPath, 'w+')
    if file == nil then
        self:Error('Failed to save settings to %s', tostring(settingsPath))
        return
    end

    file:write(serialized)
    file:close()
end

---Tries to read a .lua file that returns a settings object and pull relevant
---properties off of it. This is heavily based on the ashita settings lib.
function state:LoadSettings()
    self:Debug('state:LoadSettings()')

    local settingsPath = string.format(
        '%s\\config\\addons\\%s\\settings.lua',
        AshitaCore:GetInstallPath(),
        addon.name)

    local settings = nil
    local success = pcall(function ()
        local getSettings = loadfile(settingsPath)
        if getSettings then
            settings = getSettings()
        end
    end)

    if success and type(settings) == 'table' then
        self.IsDebugOn  = settings.IsDebugOn  or self.IsDebugOn
        self.Tabs       = settings.Tabs       or self.Tabs
        self.TabFilters = settings.TabFilters or self.TabFilters

        for i, _ in ipairs(self.Tabs) do
            self.TabMessages[i] = self.TabMessages[i] or { }
        end
    else
        self:Error('Failed to load settings; using defaults')

        -- create default tabs
        self:AddTab('Party')
        self:AddTab('Linkshell 1')
        self:AddTab('Linkshell 2')
        self:AddTab('Tells')
        self:AddTab('Combat')

        -- set default tab filters
        for _, mode in ipairs(modes) do
            if mode.Tag == 'party' then
                self:AddFilter(mode.Id, 1)
            elseif mode.Tag == 'ls1' then
                self:AddFilter(mode.Id, 2)
            elseif mode.Tag == 'ls1' then
                self:AddFilter(mode.Id, 3)
            elseif mode.Tag == 'tell' then
                self:AddFilter(mode.Id, 4)
            elseif mode.Tag == 'combat' then
                self:AddFilter(mode.Id, 5)
            end
        end

        self:SaveSettings()
    end
end

---Adds a new tab with the given name. A UUID is automatically appended behind
---imgui's comment marker, and a backing array is created.
---@param name string
function state:AddTab(name)
    self:Debug('state:AddTab(name = "%s")', name)

    local fullName = string.format('%s##%s', name, GenerateUuid())
    table.insert(self.Tabs, fullName)
    table.insert(self.TabMessages, { })
    table.insert(self.TabFilters, { })
end

---Removes the tab at the given index along with its backing array.
---@param index number
function state:RemoveTab(index)
    self:Debug('state:RemoveTab(index = %i)', index)

    table.remove(self.Tabs, index)
    table.remove(self.TabMessages, index)
    table.remove(self.TabFilters, index)
end

---Changes a tab's visible name. The UUID may change as well, but it is not used
---by anything but imgui.
---@param index   number
---@param newName string
function state:RenameTab(index, newName)
    self:Debug('state:RenameTab(index = %i, newName = "%s")', index, newName)

    local newFullName = string.format('%s##%s', newName, GenerateUuid())
    self.Tabs[index] = newFullName
end

---Removes all messages from a tab.
---@param index number
function state:ClearTab(index)
    self.TabMessages[index] = { }
end

---Adds a list of messages to a set of tabs after first checking the filter to
---test for appropriateness.
---@param messages table[]
---@param indexes  number[]
function state:AddMessagesToTabs(messages, indexes)
    self:Debug('state:AddMessageToTabs(messages = (%i) %s, indexes = { %s })', #messages, tostring(messages), table.concat(indexes, ', '))

    for _, messageTable in ipairs(messages) do
        for _, tabIndex in ipairs(indexes) do
            if self:CheckFilter(messageTable.Mode, tabIndex) then
                table.insert(self.TabMessages[tabIndex], messageTable)
            end
        end
    end
end

---Reinterprets an array of bytes as a string.
---@param bytes number[]
---@return string
local function Stringify(bytes)
    ---@diagnostic disable-next-line: undefined-field
    return table.join(table.map(bytes, string.char), '')
end

---Parses out a message event into a structured object for easy rendering.
---@param event TextInEventArgs
function state:ParseMessage(event)
        ---@diagnostic disable-next-line: undefined-field
        local cleanedBytes = event.message_modified:strip_translate(true):totable()

        -- begin parsing out colors into distinct segments with color information
        -- that imgui can use
        -- TODO: it seems like color id -> color value depends on the message mode?
        local segments = {
            { ColorId = '1.1', Color = colors[1][1], Bytes = { } },
        }

        local segment = 1
        local skipNext = false
        for i = 1, #cleanedBytes do
            local byte = cleanedBytes[i]

            if skipNext then
                -- last byte was color marker, this byte has already been used
                skipNext = false
            elseif byte == 30 then
                -- marker for color table 1, start a new segment
                local nextByte = cleanedBytes[i + 1]
                local color = colors[1][nextByte]
                skipNext = true
                segment = segment + 1

                segments[segment] = {
                    Tooltip = string.format('table %d, color %d', byte, nextByte),
                    Color = color or colors[1][1],
                    Bytes = { }
                }
            elseif byte == 31 then
                -- marker for color table 2, start a new segment
                local nextByte = cleanedBytes[i + 1]
                local color = colors[2][nextByte]
                skipNext = true
                segment = segment + 1

                segments[segment] = {
                    Tooltip = string.format('table %d, color %d', byte, nextByte),
                    Color = color or colors[2][1],
                    Bytes = { }
                }
            elseif byte == 127 then
                -- marker for color table 3? start a new segment
                local nextByte = cleanedBytes[i + 1]
                local color = colors[3][nextByte]
                skipNext = true
                segment = segment + 1

                segments[segment] = {
                    Tooltip = string.format('table %d, color %d', byte, nextByte),
                    Color = color or colors[3][1],
                    Bytes = { }
                }
            elseif byte == 129 then
                -- marker for a symbol
                local nextByte = cleanedBytes[i + 1]
                local symbol = symbols[byte][nextByte]
                skipNext = true

                for _, symbolByte in ipairs(symbol) do
                    table.insert(segments[segment].Bytes, symbolByte)
                end
            else
                -- regular ascii, accumulate into current segment
                table.insert(segments[segment].Bytes, byte)
            end
        end

        -- mark empty segments
        local emptySegments = { }
        for i, seg in ipairs(segments) do
            if #seg.Bytes == 0 then
                table.insert(emptySegments, 1, i)
            end
        end

        -- drop marked segments
        for _, i in ipairs(emptySegments) do
            table.remove(segments, i)
        end

        -- re-stringify our collected bytes
        for _, seg in ipairs(segments) do
            seg.String = Stringify(seg.Bytes)
            seg.Bytes = nil
            seg.Table = nil
        end

        -- add finalized message object to backing stores
        return { Mode = event.mode, Message = segments }
end

---Adds an incoming message to the backing buffer and each appropriate tab array.
---@param event TextInEventArgs
function state:AddMessage(event)
    self:Debug('state:AddMessage(event = %s)', tostring(event))

    local message = self:ParseMessage(event)
    table.insert(self.AllMessages, message)

    ---@diagnostic disable-next-line: undefined-field
    self:AddMessagesToTabs({ message }, table.keys(self.Tabs))
end

---Checks to see if a message belongs to a specific tab.
---@param mode     number
---@param tabIndex number
---@return boolean
function state:CheckFilter(mode, tabIndex)
    self:Debug('state:CheckFilter(mode = %i, tabIndex = %i)', mode, tabIndex)

    for _, filter in ipairs(self.TabFilters[tabIndex]) do
        if mode == filter then
            return true
        end
    end

    return false
end

---Adds a mode to the list of filters for a given tab.
---@param mode     number
---@param tabIndex number
function state:AddFilter(mode, tabIndex)
    self:Debug('state:AddFilter(mode = %i, tabIndex = %i)', mode, tabIndex)

    table.insert(self.TabFilters[tabIndex], mode)
    self:ClearTab(tabIndex)
    self:AddMessagesToTabs(self.AllMessages, { tabIndex })
end

---Removes a mode from a tab's list of filters.
---@param mode     number
---@param tabIndex number
function state:RemoveFilter(mode, tabIndex)
    self:Debug('state:RemoveFilter(mode = %i, tabIndex = %i)', mode, tabIndex)

    local tabFilters = self.TabFilters[tabIndex]
    for i, m in ipairs(tabFilters) do
        if m == mode then
            table.remove(tabFilters, i)
        end
    end

    -- TODO: is it better to just iterate through and remove the dead modes?
    self:ClearTab(tabIndex)
    self:AddMessagesToTabs(self.AllMessages, { tabIndex })
end

---Gets a reference to an array containing the pre-computed list of messages
---that belong in a given tab.
---@param index number
---@return string[]
function state:GetMessages(index)
    return self.TabMessages[index]
end

return state
