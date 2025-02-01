-- state.lua
local State = {}
State.__index = State

function State:new()
    return setmetatable({
        tiles = 0,
        energy = 0,
        health = 1
    }, self)
end

function State:get(property)
    return self[property] or 0
end

function State:increment(property)
    if self[property] then
        self[property] = self[property] + 1
    end
end

function State:decrement(property)
    if self[property] and self[property] > 0 then
        self[property] = self[property] - 1
        print(property .. " decremented to " .. self[property]) -- Debugging output
    end
end

return State
