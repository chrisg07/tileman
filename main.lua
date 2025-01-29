-- main.lua
local tileSize = 50
local moveSpeed = 200
local bounceDuration = 0.2
local overshoot = 1.1

local Grid = require("grid")
local Character = require("character")
local Utils = require("utils")
local Menu = require("menu")
local State = require("state")

function love.load()
    -- Load the custom font
    local fontPath = "fonts/TLOCRT-Squared.otf" -- Path to the font file
    local fontSize = 24                         -- Desired font size
    customFont = love.graphics.newFont(fontPath, fontSize)

    -- Set the custom font as the default font
    love.graphics.setFont(customFont)

    local state = State:new()                        -- Initialize the state
    grid = Grid:new(tileSize)
    character = Character:new(5, 5, tileSize, state) -- Pass state to Character
    menu = Menu:new(state)                           -- Pass state to Menu
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
    elseif key == "m" then -- Toggle menu visibility
        menu:toggle()
    end
end

function love.update(dt)
    character:update(dt, tileSize, bounceDuration, overshoot)
    menu:update(dt) -- Update menu animations
end

function love.draw()
    grid:draw()
    character:draw(tileSize)
    menu:draw() -- Draw the menu only if it's visible
end

function love.mousepressed(x, y, button)
    menu:mousepressed(x, y, button) -- Delegate mouse click handling to the menu
end
