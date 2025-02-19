-- world.lua
local Grid = require("Tileman.grid")
local Character = require("Tileman.character")
local Enemy = require("Tileman.enemy")

local World = {}
World.__index = World

function World:new(state, fogDistance)
    local self = setmetatable({}, World)
    self.state = state
    self.grid = Grid:new(state, fogDistance)
    self.character = Character:new(0, 0, state, self.grid)
    self.enemies = {}
    table.insert(self.enemies, Enemy:new(10, 10, state.tileSize, 0.5))

    return self
end

function World:update(dt, bounceDuration, overshoot)
    self.character:update(dt, self.state.tileSize, bounceDuration, overshoot)

    if self.character.hasMoved then
        for _, enemy in ipairs(self.enemies) do
            enemy:triggerMove(self.grid)
        end
        self.character.hasMoved = false
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.grid, self.character)
    end

    self.grid:update(dt)
end

function World:draw()
    self.grid:draw()
    self.character:draw(self.state.tileSize, mouseX, mouseY) -- Pass mouse position
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end


return World
