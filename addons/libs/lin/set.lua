--[[
* A shitty implementation of sets.
--]]

local set = {}

--[[ Creates an empty set. ]]
function set.new()
    local obj = { }
    setmetatable(obj, { __index = set })
    return obj
end

--[[ Creates a set populated with the values of an array. ]]
function set.from_array(array)
    local result = set.new()
    for _, v in pairs(array) do result:add(v) end
    return result
end

--[[ Creates an array populated with the values of the set. ]]
function set:to_array()
    local result = { }
    for v in self:values() do table.insert(result, v) end
    return result
end

--[[ Inserts a value into the set. ]]
function set:add(value)
    self[value] = true
end

--[[ Removes a value from the set. ]]
function set:remove(value)
    self[value] = nil
end

--[[ Returns the union of two sets. ]]
function set.union(lhs, rhs)
    local result = set.new()
    for v in lhs:values() do result[v] = true end
    for v in rhs:values() do result[v] = true end
    return result
end

--[[ Returns the intersection of two sets. ]]
function set.intersect(lhs, rhs)
    local result = set.new()
    for v in lhs:values() do result[v] = rhs[v] end
    return result
end

--[[ Returns a set of the values in rhs but not self. ]]
function set:difference(rhs)
    local result = set.new()
    for v in rhs:values() do if not self[v] then result[v] = true end end
    return result
end

--[[ Returns the complete difference of two sets. ]]
function set.diff(lhs, rhs)
    return set.union(lhs:difference(rhs), rhs:difference(lhs))
end

--[[ Checks if the set contains the value. ]]
function set:contains(value)
    return self[value] or false
end

--[[ Returns the number of elements in the set. ]]
function set:count()
    return set.__len(self)
end

--[[ Determines if two sets are equivalent. ]]
function set.equals(lhs, rhs)
    return set.__eq(lhs, rhs)
end

--[[ An unordered iterator over the set that provides the values. ]]
function set:values()
    local arr = { }

    for k, _ in pairs(self) do
        table.insert(arr, k)
    end

    local i = 0
    local n = #arr

    return function()
        i = i + 1
        if i <= n then return arr[i] end
    end
end

set.__len = function(self)
    local n = 0

    for k, v in pairs(self) do
        n = n + 1
    end

    return n
end

set.__eq = function(lhs, rhs)
    return lhs:count() == rhs:count() and set.diff(lhs, rhs):count() == 0
end

set.__lt = function(lhs, rhs)
    return false
end

return set
