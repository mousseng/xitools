local utils = { }

-- event system and interface hidden signatures courtesy of Velyn, chat base courtesy of Syllendel
local interfaceHidden = ashita.memory.find('FFXiMain.dll', 0, '8B4424046A016A0050B9????????E8????????F6D81BC040C3', 0, 0)
local eventSystem = ashita.memory.find('FFXiMain.dll', 0, 'A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3', 0, 0)
local menuBase = ashita.memory.find('FFXiMain.dll', 0, '8B480C85C974??8B510885D274??3B05', 16, 0)
local chatBase = ashita.memory.find('FFXiMain.dll', 0, '83EC??B9????????E8????????0FBF4C24??84C0', 4, 0)

function utils.IsInterfaceHidden()
    if interfaceHidden == 0 then
        return false
    end

    local ptr = ashita.memory.read_uint32(interfaceHidden + 10)
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr + 0xB4) == 1
end

function utils.IsEventHappening()
    if eventSystem == 0 then
        return false
    end

    local ptr = ashita.memory.read_uint32(eventSystem + 1)
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr) == 1
end

--- Determines if the chat window is fully-expanded.
---@return boolean
function utils.IsChatExpanded()
    if chatBase == 0 then
        return false
    end

    local ptr = ashita.memory.read_uint32(chatBase) + 0xF1
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr) ~= 0
end

--- Gets the name of the top-most menu element.
---@return string
function utils.GetMenuName()
    local subPointer = ashita.memory.read_uint32(menuBase)
    local subValue = ashita.memory.read_uint32(subPointer)
    if subValue == 0 then
        return ''
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4)
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16)
    local trimmedName = string.gsub(menuName, '\x00', '')
    return trimmedName
end

--- Determines if the map is open in game.
---@return boolean
function utils.IsMapOpen()
    local menuName = utils.GetMenuName()
    return menuName:match('menu%s+map.*') ~= nil
        or menuName:match('menu%s+scanlist.*') ~= nil
        or menuName:match('menu%s+cnqframe') ~= nil
end

function utils.ShouldHideUi()
    return utils.IsInterfaceHidden()
        or utils.IsEventHappening()
        or utils.IsChatExpanded()
        or utils.IsMapOpen()
        or GetPlayerEntity() == nil
end

return utils
