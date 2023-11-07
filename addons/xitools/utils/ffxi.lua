local bit = require('bit')
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
	local chatExpandedPointer = ashita.memory.read_uint32(patternAddress)+0xF1
	local chatExpandedValue = ashita.memory.read_uint8(chatExpandedPointer)

	return chatExpandedValue ~= 0
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

local contentPtr = ashita.memory.find('FFXiMain.dll', 0, 'A1????????8B88B4000000C1E907F6C101E9', 0, 0)

---Returns whether or not the local player has access to the given container.
---Code provided by atom0s.
---@param index number The container index.
---@return boolean True if the player has access, false otherwise.
function ffxi.HasBagAccess(index)
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    if contentPtr == 0 or inv == nil then
        return false
    end

    local ptr = ashita.memory.read_uint32(contentPtr + 1)
    if ptr == 0 then
        return false
    end

    local flagsPtr = ashita.memory.read_uint32(ptr)
    if flagsPtr == 0 then
        return false
    end

    local val = ashita.memory.read_uint8(flagsPtr + 0xB4)

    return switch(index, {
        -- Inventory
        [0] = function ()
            return true
        end,
        -- Wardrobe 3
        [11] = function ()
            return bit.band(bit.rshift(val, 0x02), 0x01) ~= 0
        end,
        -- Wardrobe 4
        [12] = function ()
            return bit.band(bit.rshift(val, 0x03), 0x01) ~= 0
        end,
        -- Wardrobe 5
        [13] = function ()
            return bit.band(bit.rshift(val, 0x04), 0x01) ~= 0
        end,
        -- Wardrobe 6
        [14] = function ()
            return bit.band(bit.rshift(val, 0x05), 0x01) ~= 0
        end,
        -- Wardrobe 7
        [15] = function ()
            return bit.band(bit.rshift(val, 0x06), 0x01) ~= 0
        end,
        -- Wardrobe 8
        [16] = function ()
            return bit.band(bit.rshift(val, 0x07), 0x01) ~= 0
        end,
        [switch.default] = function ()
            -- Safe to Wardrobe 2..
            if (index >= 1 and index <= 10) then
                return inv:GetContainerCountMax(index) > 0
            end

            -- Consider rest invalid..
            return false
        end,
    })
end

local jobs = {
    [ 1] = 'WAR',
    [ 2] = 'MNK',
    [ 3] = 'WHM',
    [ 4] = 'BLM',
    [ 5] = 'RDM',
    [ 6] = 'THF',
    [ 7] = 'PLD',
    [ 8] = 'DRK',
    [ 9] = 'BST',
    [10] = 'BRD',
    [11] = 'RNG',
    [12] = 'SAM',
    [13] = 'NIN',
    [14] = 'DRG',
    [15] = 'SMN',
    [16] = 'BLU',
    [17] = 'COR',
    [18] = 'PUP',
    [19] = 'DNC',
    [20] = 'SCH',
    [21] = 'GEO',
    [22] = 'RUN',
}

---@param id integer
---@return 'WAR'|'MNK'|'WHM'|'BLM'|'RDM'|'THF'|'PLD'|'DRK'|'BST'|'BRD'|'RNG'|'SAM'|'NIN'|'DRG'|'SMN'|'BLU'|'COR'|'PUP'|'DNC'|'SCH'|'GEO'|'RUN'|nil
function ffxi.GetJobAbbr(id)
    return jobs[id]
end

---@param number integer
---@param include_unit boolean
---@return string
function ffxi.FormatXp(number, include_unit)
    if number < 10000 then
        return string.format('%4i', number)
    elseif include_unit then
        return string.format('%4.1fk', number / 1000)
    else
        return string.format('%4.1f', number / 1000)
    end
end

return ffxi
