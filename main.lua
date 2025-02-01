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
end

function love.keypressed(key)
    if state.mode == "game" then
        if key == "w" then
            character:move(0, -1)
        elseif key == "s" then
            character:move(0, 1)
        elseif key == "a" then
            character:move(-1, 0)
        elseif key == "d" then
            character:move(1, 0)
        elseif key == "m" then
            menu:toggle() -- If you want to show an in-game menu overlay
        end
    elseif state.mode == "menu" then
        -- When in menu mode, allow menu interaction.
        -- For example, pressing Enter might start the game.
        if key == "return" then
            state.mode = "game"
            -- Optionally reset other game properties here, such as:
            -- state.health = 1
            -- Reset character and enemy positions if needed.
        end

        -- You can also let your menu handle its own key events if implemented:
        if menu.keypressed then
            menu:keypressed(key)
        end
    end
end

function love.update(dt)
    background:update(dt)

    if state.mode == "game" then
        character:update(dt, tileSize, bounceDuration, overshoot)

        if character.hasMoved then
            for _, enemy in ipairs(enemies) do
                enemy:update(dt, grid, character)
            end
            character.hasMoved = false
        end

        -- Check if the character's health has dropped to zero.
        if state.health <= 0 then
            state.mode = "menu"
            -- Optionally, reset your game objects here for a new game session.
        end
    else -- state.mode == "menu"
        menu:update(dt)
    end
end

function love.draw()
    background:draw()

    if state.mode == "game" then
        grid:draw()
        character:draw(tileSize)
        for _, enemy in ipairs(enemies) do
            enemy:draw()
        end
    elseif state.mode == "menu" then
        menu:draw()
    end

    suit.draw()
end
