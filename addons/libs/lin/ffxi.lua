local ffxi = {}

-- Fetch an entity by its server ID. Helpful when looking up information from
-- packets, which tend to not include the entity index (since that's a client
-- thing only). Returns nil if no matching entity is found.
---@param id number
---@return Entity?
function ffxi.GetEntityByServerId(id)
    -- The entity array is 2304 items long
    for x = 0, 2303 do
        ---@type Entity
        local e = GetEntity(x)

        -- Ensure the entity is valid
        if e ~= nil and e.WarpPointer ~= 0 then
            if e.ServerId == id then
                return e
            end
        end
    end

    return nil
end

-- Shorthand method to grab an entity's name (by server id, obviously) or a
-- placeholder string if the entity can't be found.
---@param id number
---@param default_name string?
---@return string
function ffxi.GetEntityNameByServerId(id, default_name)
    local e = ffxi.GetEntityByServerId(id)

    if e ~= nil and e.Name ~= nil then
        return e.Name
    else
        return default_name or '[unknown]'
    end
end


-- Determines if a particular entity (given as a server ID) belongs to the
-- player's alliance.
---@param id number
---@return boolean
function ffxi.IsServerIdInParty(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.ServerId == id then
                return true
            end
        end
    end

    return false
end


-- Determines if a particular pet (given as a server ID) belongs to the
-- player's alliance.
---@param id number
---@return boolean
function ffxi.IsPetServerIdInParty(id)
    local party = AshitaCore:GetDataManager():GetParty()

    for i = 0, 17 do
        if party:GetMemberActive(i) == 1
        and party:GetMemberServerId(i) ~= 0 then
            local party_mem = GetEntity(party:GetMemberTargetIndex(i))

            if party_mem ~= nil and party_mem.PetTargetIndex ~= nil then
                local party_pet = GetEntity(party_mem.PetTargetIndex)

                if party_pet ~= nil and party_pet.ServerId == id then
                    return true
                end
            end
        end
    end

    return false
end

--- Determines if the chat window is fully-expanded.
---@return boolean
function ffxi.IsChatExpanded()
    -- courtesy of Syllendel
	local pattern = "83EC??B9????????E8????????0FBF4C24??84C0"
	local patternAddress = ashita.memory.find("FFXiMain.dll", 0, pattern, 0x04, 0)
	local chatExpandedPointer = ashita.memory.read_uint32(patternAddress) + 0xF1
	local chatExpandedValue = ashita.memory.read_uint8(chatExpandedPointer)

	return chatExpandedValue > 2
end

--- Fetches the party index of your <stpt> target, if it exists.
---@return integer?
function ffxi.GetStPartyIndex()
    -- Courtesy of Thorny from the Ashita discord
    local ptr = AshitaCore:GetPointerManager():Get('party')
    ptr = ashita.memory.read_uint32(ptr)
    ptr = ashita.memory.read_uint32(ptr)
    local isActive = (ashita.memory.read_uint32(ptr + 0x54) ~= 0)
    if isActive then
        return ashita.memory.read_uint8(ptr + 0x50)
    else
        return nil
    end
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
    local trimmedName = string.gsub(menuName, '\x00', '')
    return trimmedName
end

--- Determines if the map is open in game.
---@return boolean
function ffxi.IsMapOpen()
    local menuName = ffxi.GetMenuName()
    return menuName:match('menu%s+map.*') ~= nil
        or menuName:match('menu%s+scanlist.*') ~= nil
        or menuName:match('menu%s+cnqframe') ~= nil
end

-- event system signature courtesy of Velyn
local eventSystem = ashita.memory.find('FFXiMain.dll', 0, "A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3", 0, 0)

function ffxi.IsEventHappening()
    if eventSystem == 0 then
        return false
    end

    local ptr = ashita.memory.read_uint32(eventSystem + 1)
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr) == 1
end

-- interface hidden signature courtesy of Velyn
local interfaceHidden = ashita.memory.find('FFXiMain.dll', 0, "8B4424046A016A0050B9????????E8????????F6D81BC040C3", 0, 0)

function ffxi.IsInterfaceHidden()
    if interfaceHidden == 0 then
        return false
    end

    local ptr = ashita.memory.read_uint32(interfaceHidden + 10)
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr + 0xB4) == 1
end

return ffxi
