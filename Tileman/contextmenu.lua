local ContextMenu = {}
ContextMenu.__index = ContextMenu

local suit = require "suit"
local Pathfinding = require("Tileman.pathfinding")

-- Create a new context menu.
-- Optionally pass tileSize so the module can compute tile coordinates.
function ContextMenu:new(world)
    local self = setmetatable({}, ContextMenu)
    self.world = world
    self.visible = false
    self.x = 0
    self.y = 0
    self.actions = {} -- List of actions (each with a label and callback)
    self.tileSize = world.state.tileSize or 50
    return self
end

-- Opens the context menu by determining what actions are available at the clicked position.
-- It expects:
--   x, y: the mouse click coordinates (pixels)
--   grid: the grid module (for isDiscovered)
--   enemies: the list of enemies
--   character: the player character (to perform actions)
--   state: the game state (for checking mode, energy, etc.)
function ContextMenu:open(x, y, grid, enemies, character, state)
    -- Adjust for camera position to get world coordinates
    local adjustedX = x + state.camera.x
    local adjustedY = y + state.camera.y

    -- Convert world coordinates to tile coordinates
    -- TODO: move logic for determing selected tile to Grid
    local tileX = math.floor(adjustedX / self.tileSize)
    local tileY = math.floor(adjustedY / self.tileSize)

    -- Get tile key
    local tileKey = tileX .. "," .. tileY
    local tile = grid.tiles[tileKey]

    -- Only allow context menu on discovered tiles
    if not tile or not tile.discovered then
        print("Tile (" .. tileX .. ", " .. tileY .. ") has not been discovered yet!")
        return
    end

    self.x = x        -- Keep menu at screen position (not world position)
    self.y = y
    self.actions = {} -- Clear previous actions

    -- Check if an enemy occupies the clicked tile.
    local foundEnemy = nil
    for _, enemy in ipairs(enemies) do
        if enemy.x == tileX and enemy.y == tileY then
            foundEnemy = enemy
            break
        end
    end

    if foundEnemy then
        table.insert(self.actions, {
            label = "Attack",
            callback = function()
                character:attack(foundEnemy)
            end
        })
    end

    if tile and tile.type == "tree" then
        table.insert(self.actions, {
            label = "Chop Tree",
            callback = function()
                character:chopTree(tileX, tileY)
            end
        })
    end

    if tileX == self.world.character.targetX and tileY == self.world.character.targetY then
        if not self.world.state.meditation.active then
            table.insert(self.actions, {
                label = "Meditate",
                callback = function()
                    print("Meditate callback triggered")
                    self.world.state.meditation.active = true
                end
            })
        else
            table.insert(self.actions, {
                label = "Stop Meditating",
                callback = function()
                    print("Stop Meditating callback triggered; current state: " .. tostring(self.world.state.meditation.active))
                    self.world.state.meditation.active = false
                end
            })
        end
    else
        -- Only add the "Move Here" action if the clicked tile is not the character's tile.
        if tile and tile.discovered then
            table.insert(self.actions, {
                label = "Move Here",
                callback = function()
                    local path = Pathfinding.findPath(grid, self.world.character.targetX, self.world.character.targetY, tileX, tileY)
                    if path then
                        self.world.character:setPath(path)
                        self.world.state.meditation.active = false
                    else
                        print("No valid path found!")
                    end
                end
            })
        end
    end

    self.visible = true
end

-- This method can be called from love.mousepressed to let the context menu handle the right-click.
-- Pass in all necessary dependencies.
function ContextMenu:handleMousePress(x, y, button, grid, enemies, character, state)
    if button == 2 then -- Right-click
        self:open(x, y, grid, enemies, character, state)
    elseif button == 1 then
        -- Check if the click is within the context menu bounds.
        if self.visible and x >= self.x and x <= self.x + 100 and y >= self.y and y <= self.y + (#self.actions * 30) then
            -- Do nothing so that SUIT can process the click on the button.
        else
            self.visible = false
        end
    end
end

-- Hide the context menu.
function ContextMenu:hide()
    self.visible = false
    self.actions = {}
end

-- Update the context menu UI using SUIT.
function ContextMenu:update(dt)
    if self.visible then
        suit.layout:reset(self.x, self.y)
        for i, action in ipairs(self.actions) do
            if suit.Button(action.label, suit.layout:row(100, 30)).hit then
                action.callback()
                self:hide()
            end
        end
    end
end

-- Optionally, draw a background behind the context menu.
function ContextMenu:draw()
    if self.visible then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        local menuHeight = (#self.actions) * 30
        love.graphics.rectangle("fill", self.x, self.y, 100, menuHeight)
        love.graphics.setColor(1, 1, 1)
    end
end

return ContextMenu
