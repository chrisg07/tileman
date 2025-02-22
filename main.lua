local bounceDuration = 0.2
local overshoot = 1.1

local suit = require "suit"
local flux = require "flux.flux"
local Menu = require("Tileman.menu")
local State = require("Tileman.state")
local Background = require("Tileman.background")
local ContextMenu = require "Tileman.contextmenu"
local World = require("Tileman.world")
local UpgradesList = require "Tileman.upgradeslist"

local state
local menu
local background
local contextMenu
local world
local camera
mouseX, mouseY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
local upgradesList

function love.load()
    background = Background:new()

    -- Set SUIT theme
    suit.theme.color.normal = { bg = { 0.1, 0.1, 0.1 }, fg = { 1, 1, 1 } }

    state = State:new()
    world = World:new(state, 1)
    menu = Menu:new(state)
    contextMenu = ContextMenu:new(world)
    upgradesList = UpgradesList:new(state, 200, 200, 200, 300)
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
    upgradesList:update(dt)

    flux.update(dt)

    -- Update camera so that the character is centered.
    local screenWidth, screenHeight = love.graphics.getDimensions()
    -- Calculate camera position so that character.currentX/currentY are centered.
    local camX = world.character.currentX - screenWidth / 2 + state.tileSize / 2
    local camY = world.character.currentY - screenHeight / 2 + state.tileSize / 2
    state.camera:setPosition(camX, camY)

    state.meditation.timer = (state.meditation.timer or 0) + dt
    if state.meditation.active and state.meditation.timer >= state.meditation.interval then
        state.meditation.timer = state.meditation.timer - state.meditation.interval
        if math.random() < state.meditation.chance * 100 then
            local xp = math.random(state.meditation.minXPGain, state.meditation.maxXPGain)
            state.skills:addXP("knowledge", xp)
            print("Meditation bonus! Awarded " .. xp .. " XP.")
        else
            print("Meditation attempt yielded no XP this time.")
        end
    end
end

function love.draw()
    background:draw()

    -- Apply camera transform so that world is drawn relative to the camera.
    state.camera:apply()
    world:draw()
    state.camera:reset() -- reset the transformation

    contextMenu:draw()
    suit.draw()
    menu:draw()


    -- Draw all skill progress bars starting at (400, 50),
    -- with each bar 200px wide, 20px tall, and 20px vertical spacing.
    if state.showStats then
        local statPadding = 5
        state.stats:drawProgressBars(600 - statPadding, statPadding, 200, 20, statPadding)
    end

    if state.showSkills then 
        local skillBarPadding = 25
        state.skills:drawProgressBars(700 - skillBarPadding, skillBarPadding, 100, 20, skillBarPadding)
    end

    if state.showUpgrades then
        upgradesList:draw()
    end
end

function love.mousepressed(x, y, button)
    contextMenu:handleMousePress(x, y, button, world.grid, world.enemies, world.character, state, camera)
    world.character:handleMousePress(x, y, button)
end

function love.wheelmoved(dx, dy)
    upgradesList:wheelmoved(dx, dy)
end

function love.mousemoved(x, y, dx, dy)
    mouseX, mouseY = x, y
end
