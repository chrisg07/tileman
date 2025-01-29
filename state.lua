-- state.lua
local State = {}
State.__index = State

function State:new()
    return setmetatable({
        counter = 10 -- Initial value for the counter
    }, self)
end

function State:getCounter()
    return self.counter
end

function State:incrementCounter()
    self.counter = self.counter + 1
end

function State:decrementCounter()
    if self.counter > 0 then
        self.counter = self.counter - 1
    end
end

return State
