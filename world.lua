-- world.lua
local Grid = require("grid")
local Character = require("character")
local Enemy = require("enemy")

local World = {}
World.__index = World

function World:new(tileSize, state)
    local self = setmetatable({}, World)
    self.tileSize = tileSize
    self.state = state
    self.grid = Grid:new(tileSize)
    self.character = Character:new(5, 5, tileSize, state, self.grid)
    self.enemies = {}
    table.insert(self.enemies, Enemy:new(10, 10, tileSize, 0.5))

    return self
end

function World:update(dt, bounceDuration, overshoot)
    self.character:update(dt, self.tileSize, bounceDuration, overshoot)

    if self.character.hasMoved then
        for _, enemy in ipairs(self.enemies) do
            enemy:triggerMove(self.grid)
        end
        self.character.hasMoved = false
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.grid, self.character)
    end
end

function World:draw()
    self.grid:draw()
    self.character:draw(self.tileSize)
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

return World
