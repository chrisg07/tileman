local tileSize = 50
local moveSpeed = 200
local bounceDuration = 0.2
local overshoot = 1.1

local Grid = require("grid")
local Character = require("character")
local Utils = require("utils")

function love.load()
    grid = Grid:new(tileSize)
    character = Character:new(5, 5, tileSize)
end

function love.keypressed(key)
    if key == "w" then
        character:move(0, -1, grid.width, grid.height)
    elseif key == "s" then
        character:move(0, 1, grid.width, grid.height)
    elseif key == "a" then
        character:move(-1, 0, grid.width, grid.height)
    elseif key == "d" then
        character:move(1, 0, grid.width, grid.height)
    end
end

function love.update(dt)
    character:update(dt, tileSize, bounceDuration, overshoot)
end

function love.draw()
    grid:draw()
    character:draw(tileSize)
end
