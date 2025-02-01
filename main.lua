-- main.lua
local tileSize = 50
local moveSpeed = 200
local bounceDuration = 0.2
local overshoot = 1.1

-- context menu
local contextMenuVisible = false
local contextMenuX, contextMenuY = 0, 0
local contextMenuType = nil                   -- "attack" or "move"
local targetedEnemy = nil                     -- if attacking
local targetedTileX, targetedTileY = nil, nil -- if moving

-- imports
local suit = require "suit"
local Grid = require("grid")
local Character = require("character")
local Menu = require("menu")
local State = require("state")
local Background = require("background")
local Enemy = require("enemy")
local ContextMenu = require "contextmenu"

local grid
local character
local menu
local contextMenu
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
    contextMenu = ContextMenu:new()

    table.insert(enemies, Enemy:new(10, 10, tileSize, 0.5))
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
        menu:toggle() -- If you want to show an in-game menu overlay
    end

    -- You can also let your menu handle its own key events if implemented:
    if menu.keypressed then
        menu:keypressed(key)
    end
end

function love.update(dt)
    background:update(dt)

    character:update(dt, tileSize, bounceDuration, overshoot)

    -- When the character moves, trigger enemy moves once.
    if character.hasMoved then
        for _, enemy in ipairs(enemies) do
            enemy:triggerMove(grid)
        end
        character.hasMoved = false
    end

    -- Update enemies continuously for their interpolation and collision check.
    for _, enemy in ipairs(enemies) do
        enemy:update(dt, grid, character)
    end

    -- Check if the character's health has dropped to zero.
    if state.health <= 0 then
        -- Optionally, reset your game objects here for a new game session.
    end
    menu:update(dt)

    contextMenu:update(dt, character, grid, state)
end

function love.draw()
    background:draw()

    grid:draw()
    character:draw(tileSize)
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
    menu:draw()

    contextMenu:draw()
    suit.draw()
end

function love.mousepressed(x, y, button)
    contextMenu:handleMousePress(x, y, button, grid, enemies, character, state)
end
