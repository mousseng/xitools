addon.name    = 'omen'
addon.author  = 'lin'
addon.version = '1.3'
addon.desc    = 'Track objectives in omen'

require('common')
local chat = require('chat')
local imgui = require('lin/ui')
local buildMessages = require('messages')
local messages = buildMessages(7327)

---@class OmenMessageTemplate
---@field text    string
---@field summary string?
---@field func    fun(msg: OmenMessage, state: OmenObjectives)

---@class OmenMessage
---@field id      number
---@field summary string?
---@field params  number[]

---@class OmenObjectives
---@field mainTimer  number
---@field floorTimer number
---@field floorEnd   number
---@field floor      OmenObjectiveFloor
---@field transient  OmenObjectiveTransient[]

---@class OmenObjectiveFloor
---@field summary string
---@field status  'success'|'pending'|'failure'

---@class OmenObjectiveTransient
---@field summary string
---@field status  'success'|'pending'|'failure'
---@field cur     number
---@field max     number

local OMEN_ZONE = 292
local STATUSES = {
    failure = '\xef\x81\x97',
    pending = '\xef\x85\x81',
    success = '\xef\x81\x98',
}

local party = AshitaCore:GetMemoryManager():GetParty()
local theme = imgui.lin.Theme()
local mainWindow = imgui.lin.Window {
    title = 'omen',
    isVisible = true,
    flags = ImGuiWindowFlags_NoDecoration,
    size = { -1, -1 },
    pos = { 400, 400 },
}

local function isInOmen(zoneId)
    return (zoneId or party:GetMemberZone(0)) == OMEN_ZONE
end

local function parseStringMessage(packet)
    local msgId = struct.unpack('I2', packet, 0x0a + 1) - 0x8000
    if messages[msgId] == nil then
        return nil
    end

    return {
        id = msgId,
        summary = messages[msgId].summary,
        params = {
            [1] = struct.unpack('i4', packet, 0x10 + 1),
            [2] = struct.unpack('i4', packet, 0x14 + 1),
            [3] = struct.unpack('i4', packet, 0x18 + 1),
            [4] = struct.unpack('i4', packet, 0x1c + 1),
        }
    }
end

local function parseRestMessage(packet)
    local msgId = struct.unpack('I2', packet, 0x1a + 1) - 0x8000
    if messages[msgId] == nil then
        return nil
    end

    return {
        id = msgId,
        summary = messages[msgId].summary,
        params = {
            [1] = struct.unpack('i4', packet, 0x08 + 1),
            [2] = struct.unpack('i4', packet, 0x0c + 1),
            [3] = struct.unpack('i4', packet, 0x10 + 1),
            [4] = struct.unpack('i4', packet, 0x14 + 1),
        }
    }
end

local function parseNpcMessage(packet)
    local msgId = struct.unpack('I2', packet, 0x0a + 1) - 0x8000
    if messages[msgId] == nil then
        return nil
    end

    return {
        id = msgId,
        summary = messages[msgId].summary,
        params = { },
    }
end

---Parses a string message if it is determined to be omen-related
---@param e PacketInEventArgs
---@return OmenMessage?
local function parseOmenMessage(e)
    -- ignore everything when you're not in reisenjima henge
    if not isInOmen() then
        return nil
    end

    if e.id == 0x027 then
        return parseStringMessage(e.data)
    elseif e.id == 0x02a then
        return parseRestMessage(e.data)
    elseif e.id == 0x036 then
        return parseNpcMessage(e.data)
    end
end

---Gets a fresh objective state to begin tracking
---@return OmenObjectives
local function getNewObjectives()
    return {
        mainTimer = 0,
        floorTimer = 0,
        floorEnd = 0,
        floor = {
            summary = 'no floor objective yet',
            status  = 'pending',
            isDone  = false,
            isFail  = false,
        },
        transient = { },
    }
end

local currentObjectives = getNewObjectives()

---Scan the DATs for a reference message so we can map message IDs to message
---text. This requires a change to the boot config.
local function findIds()
    local res = AshitaCore:GetResourceManager()
    local id = res:GetString('dialog.omen', 'The light contains...something other than peace and serenity!')

    if id == nil then
        print(chat.header(addon.name) .. chat.error('Failed to find Omen message IDs'))
        print(chat.header(addon.name) .. chat.message('Please ensure your Ashita config includes the omen datmap. Check the README for more information.'))
        return
    end

    -- the reference message we're looking for should be 4 after the time extension,
    -- which is the base we're actually using
    messages = buildMessages(id - 4)
end

---Checks the player zone on load to ensure we don't show it at a silly time
local function checkZone()
    mainWindow.isVisible[1] = isInOmen()
end

---Maintain objective state on zone change
---@param e PacketInEventArgs
local function handleZoning(e)
    if e.id == 0x0a then
        local zone = struct.unpack('i2', e.data, 0x30 + 1)
        mainWindow.isVisible[1] = isInOmen(zone)
        currentObjectives = getNewObjectives()
    end
end

---Read and parse Omen objectives from message packets
---@param e PacketInEventArgs
local function trackObjectives(e)
    local omen = parseOmenMessage(e)
    if omen == nil or messages[omen.id] == nil then
        return
    end

    messages[omen.id].func(omen, currentObjectives)
end

---Displays the current timer and objective status in a simple window
local function showObjectives()
    imgui.lin.DrawUiWindow(mainWindow, theme, function()
        imgui.Text('======================= OMEN =======================')
        imgui.Separator()

        do
            local obj = currentObjectives.floor
            local status = STATUSES[obj.status]
            local color = theme.colors[obj.status]

            imgui.TextColored(color, status)
            imgui.SameLine()
            imgui.Text(obj.summary)
        end

        if #currentObjectives.transient == 0 then
            return
        else
            imgui.NewLine()
        end

        local remaining = math.max(currentObjectives.floorEnd - os.time(), 0)
        local timer = '%5ds remaining'
        imgui.Text(timer:format(remaining))

        for _, obj in ipairs(currentObjectives.transient) do
            local status = STATUSES[obj.status]
            local color = theme.colors[obj.status]
            local progress = '%d / %d'

            imgui.TextColored(color, status)
            imgui.SameLine()
            imgui.Text(progress:format(obj.cur, obj.max))
            imgui.SameLine()
            imgui.Text(obj.summary)
        end
    end)
end

ashita.events.register('load', 'findIds', findIds)
ashita.events.register('load', 'checkZone', checkZone)
ashita.events.register('packet_in', 'handleZoning', handleZoning)
ashita.events.register('packet_in', 'trackObjectives', trackObjectives)
ashita.events.register('d3d_present', 'showObjectives', showObjectives)
