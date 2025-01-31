-- main.lua
local tileSize = 50
local moveSpeed = 200
local bounceDuration = 0.2
local overshoot = 1.1

local suit = require "suit"
local Grid = require("grid")
local Character = require("character")
local Utils = require("utils")
local Menu = require("menu")
local State = require("state")

function love.load()
    -- Load the custom font
    -- local fontPath = "fonts/TLOCRT-Squared.otf" -- Path to the font file
    -- local fontSize = 84                         -- Desired font size
    -- customFont = love.graphics.newFont(fontPath, fontSize)

    -- -- Set the custom font as the default font
    -- love.graphics.setFont(customFont)

    -- Set SUIT theme (optional)
    suit.theme.color.normal = { bg = { 0.1, 0.1, 0.1 }, fg = { 1, 1, 1 } }

    state = State:new()                                    -- Initialize the state
    grid = Grid:new(tileSize)
    character = Character:new(5, 5, tileSize, state, grid) -- Pass state to Character
    menu = Menu:new(state, { "tiles", "energy", "health" })
end

function love.keypressed(key)
    if key == "w" then
        character:move(0, -1)
    elseif key == "s" then
        character:move(0, 1)
    elseif key == "a" then
        character:move(-1, 0)
    elseif key == "d" then
        character:move(1, 0)
    elseif key == "m" then -- Toggle menu visibility
        menu:toggle()
    end
end

function love.update(dt)
    character:update(dt, tileSize, bounceDuration, overshoot)
    menu:update(dt) -- Update menu animations

    -- Reset the layout position
    suit.layout:reset(100, 100)

    -- Create a button
    if suit.Button("Button 1", suit.layout:row(200, 50)).hit then
        print("Button 1 clicked!")
    end

    -- Create another button
    if suit.Button("Button 2", suit.layout:row(200, 50)).hit then
        print("Button 2 clicked!")
    end
end

function love.draw()
    grid:draw()
    character:draw(tileSize)
    menu:draw() -- Draw the menu only if it's visible
    -- Draw SUIT elements
    suit.draw()
end

function love.mousepressed(x, y, button)
    menu:mousepressed(x, y, button) -- Delegate mouse click handling to the menu
end
