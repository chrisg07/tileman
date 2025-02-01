-- main.lua
local tileSize = 50
local moveSpeed = 200
local bounceDuration = 0.2
local overshoot = 1.1

local suit = require "suit"
local Grid = require("grid")
local Character = require("character")
local Menu = require("menu")
local State = require("state")
local Background = require("background")
local Enemy = require("enemy")

local grid
local character
local menu
local background
local enemies = {}

function love.load()
    background = Background:new()

    -- Load the custom font
    -- local fontPath = "fonts/TLOCRT-Squared.otf" -- Path to the font file
    -- local fontSize = 84                         -- Desired font size
    -- customFont = love.graphics.newFont(fontPath, fontSize)

    -- -- Set the custom font as the default font
    -- love.graphics.setFont(customFont)

    -- Set SUIT theme (optional)
    suit.theme.color.normal = { bg = { 0.1, 0.1, 0.1 }, fg = { 1, 1, 1 } }

    state = State:new()
    grid = Grid:new(tileSize)
    character = Character:new(5, 5, tileSize, state, grid)
    menu = Menu:new(state, { "tiles", "energy", "health" })

    table.insert(enemies, Enemy:new(10, 10, tileSize, 0.5))
    table.insert(enemies, Enemy:new(15, 15, tileSize, 0.5))
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
    elseif key == "m" then
        menu:toggle()
    end
end

function love.update(dt)
    background:update(dt)

    character:update(dt, tileSize, bounceDuration, overshoot)

    for _, enemy in ipairs(enemies) do
        enemy:update(dt, grid)

        if enemy:checkCollision(character) then
            print("Player collided with an enemy!")
            -- Handle collision (e.g., reduce player health)
        end
    end

    menu:update(dt)
end

function love.draw()
    background:draw()

    grid:draw()

    character:draw(tileSize)

    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    suit.draw()
end
