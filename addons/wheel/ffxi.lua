local ffxi = {}

--- Determines if the chat window is fully-expanded.
---@return boolean
function ffxi.IsChatExpanded()
    -- courtesy of Syllendel
	local pattern = "83EC??B9????????E8????????0FBF4C24??84C0"
	local patternAddress = ashita.memory.find("FFXiMain.dll", 0, pattern, 0x04, 0)
	local chatExpandedPointer = ashita.memory.read_uint32(patternAddress)+0xF1
	local chatExpandedValue = ashita.memory.read_uint8(chatExpandedPointer)

	return chatExpandedValue ~= 0
end

local menuBase = ashita.memory.find('FFXiMain.dll', 0, '8B480C85C974??8B510885D274??3B05', 16, 0)

--- Gets the name of the top-most menu element.
---@return string
function ffxi.GetMenuName()
    local subPointer = ashita.memory.read_uint32(menuBase)
    local subValue = ashita.memory.read_uint32(subPointer)
    if (subValue == 0) then
        return ''
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4)
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16)
    return string.gsub(menuName, '\x00', '')
end

--- Determines if the map is open in game.
---@return boolean
function ffxi.IsMapOpen()
    local menuName = ffxi.GetMenuName()
    return menuName:match('menu%s+map.*') ~= nil
        or menuName:match('menu%s+scanlist.*') ~= nil
        or menuName:match('menu%s+cnqframe') ~= nil
end

return ffxi
