-- main.lua
local tileSize = 50
local bounceDuration = 0.2
local overshoot = 1.1

-- Imports
local suit = require "suit"
local Menu = require("menu")
local State = require("state")
local Background = require("background")
local ContextMenu = require "contextmenu"
local World = require("world")

local state
local menu
local background
local contextMenu
local world

function love.load()
    background = Background:new()

    -- Set SUIT theme (optional)
    suit.theme.color.normal = { bg = { 0.1, 0.1, 0.1 }, fg = { 1, 1, 1 } }

    state = State:new()
    world = World:new(tileSize, state)
    menu = Menu:new(state, { "tiles", "energy", "health" })
    contextMenu = ContextMenu:new(tileSize) -- Pass tileSize if needed for coordinate calculations.
end

function love.keypressed(key)
    if key == "w" then
        world.character:move(0, -1)
    elseif key == "s" then
        world.character:move(0, 1)
    elseif key == "a" then
        world.character:move(-1, 0)
    elseif key == "d" then
        world.character:move(1, 0)
    elseif key == "m" then
        menu:toggle()
    end

    if menu.keypressed then
        menu:keypressed(key)
    end
end

function love.update(dt)
    background:update(dt)
    world:update(dt, bounceDuration, overshoot)
    menu:update(dt)
    contextMenu:update(dt, world.character, world.grid, state)
end

local function drawProgressBar(x, y, width, height, progress)
    -- Draw the background (bar outline)
    love.graphics.setColor(0.3, 0.3, 0.3) -- dark gray background
    love.graphics.rectangle("fill", x, y, width, height)

    -- Draw the progress (filled portion)
    love.graphics.setColor(0.1, 0.8, 0.1) -- green fill
    love.graphics.rectangle("fill", x, y, width * progress, height)

    -- Draw the border
    love.graphics.setColor(1, 1, 1) -- white border
    love.graphics.rectangle("line", x, y, width, height)

    -- Reset the color (if needed)
    love.graphics.setColor(1, 1, 1)

    -- Optionally, you can also draw text showing the percentage or raw numbers:
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("EXP: %d / %d", state.experience, 100), x, y + height + 5)
end

function love.draw()
    background:draw()
    world:draw()
    menu:draw()
    contextMenu:draw()
    suit.draw()

    -- Draw the experience progress bar.
    -- For example, draw it at (50, 50) with a width of 200 and height of 20:
    local progress = state.experience / 100
    drawProgressBar(400, 25, 200, 20, progress)
end

function love.mousepressed(x, y, button)
    contextMenu:handleMousePress(x, y, button, world.grid, world.enemies, world.character, state)
end
