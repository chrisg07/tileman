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

local shader

function love.load()
    -- Load the Voronoi shader
    shader = love.graphics.newShader("voronoi.frag")

    -- Set shader resolution
    local screenWidth, screenHeight = love.graphics.getDimensions()
    shader:send("u_resolution", { screenWidth, screenHeight })

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
    -- Update shader time for animation
    shader:send("u_time", love.timer.getTime())

    character:update(dt, tileSize, bounceDuration, overshoot)
    menu:update(dt) -- Update menu animations
end

function love.draw()
    love.graphics.setBlendMode("alpha") -- Enable alpha blending
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()

    grid:draw()

    character:draw(tileSize)

    suit.draw()
end
