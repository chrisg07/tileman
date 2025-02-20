local Camera = require("Tileman.camera")
local Skills = require "Tileman.skills"
local Stats = require "Tileman.stats"

local State = {}
State.__index = State

function State:new()
    return setmetatable({
        mode = "menu",
        stats = Stats:new(self),
        skills = Skills:new(),
        meditation = {
            active = false,
            timer =  0,
            interval = 10,
            chance = 0.2,
            minXPGain = 1,
            maxXPGain = 3
        },
        tileSize = 50,
        moveSpeed = 1,
        camera = Camera:new(0, 0),
        showStats = false,
        showSkills = false,
        showUpgrades = false,
        xpMultiplier = 1
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
