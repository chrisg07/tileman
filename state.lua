local Camera = require("camera")
local Skills = require "skills"
local State = {}
State.__index = State

function State:new()
    return setmetatable({
        mode = "menu",
        tiles = 0,
        energy = 0,
        health = 1,
        experience = 0,
        skills = Skills:new(),
        tileSize = 50,
        camera = Camera:new(0, 0)
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
        print(property .. " decremented to " .. self[property])
    end
end

return State
