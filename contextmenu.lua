-- contextmenu.lua
local ContextMenu = {}
ContextMenu.__index = ContextMenu

local suit = require "suit"

-- Create a new context menu.
-- Optionally pass tileSize so the module can compute tile coordinates.
function ContextMenu:new(tileSize)
    local self = setmetatable({}, ContextMenu)
    self.visible = false
    self.x = 0
    self.y = 0
    self.actions = {} -- List of actions (each with a label and callback)
    self.tileSize = tileSize or 50
    return self
end

-- Opens the context menu by determining what actions are available at the clicked position.
-- It expects:
--   x, y: the mouse click coordinates (pixels)
--   grid: the grid module (for isDiscovered)
--   enemies: the list of enemies
--   character: the player character (to perform actions)
--   state: the game state (for checking mode, energy, etc.)
function ContextMenu:open(x, y, grid, enemies, character, state, camera)
    -- Adjust for camera position to get world coordinates
    local adjustedX = x + camera.x
    local adjustedY = y + camera.y

    -- Convert world coordinates to tile coordinates
    local tileX = math.floor(adjustedX / self.tileSize)
    local tileY = math.floor(adjustedY / self.tileSize)

    -- Get tile key
    local tileKey = tileX .. "," .. tileY
    local tile = grid.tiles[tileKey]

    -- Only allow context menu on discovered or seen tiles
    if not tile or not tile.discovered then
        print("Tile (" .. tileX .. ", " .. tileY .. ") is not discovered or seen!")
        return
    end

    self.x = x -- Keep menu at screen position (not world position)
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

    -- If an enemy is present, add an "Attack" action.
    if foundEnemy then
        table.insert(self.actions, {
            label = "Attack",
            callback = function()
                character:attack(foundEnemy)
            end
        })
    end

    -- Check if the tile is a tree.
    if tile and tile.type == "tree" then
        table.insert(self.actions, {
            label = "Chop Tree",
            callback = function()
                character:chopTree(tileX, tileY)
            end
        })
    end

    -- Always add a "Move Here" action.
    table.insert(self.actions, {
        label = "Move Here",
        callback = function()
            local Pathfinding = require("pathfinding")
            local path = Pathfinding.findPath(grid, character.targetX, character.targetY, tileX, tileY)
            if path then
                local cost = #path - 1 -- Exclude the starting tile.
                if state:get("energy") >= cost then
                    state.energy = state.energy - cost
                    print("Energy cost: " .. cost .. " | Remaining energy: " .. state.energy)
                    character:setPath(path)
                else
                    print("Not enough energy to move!")
                end
            else
                print("No valid path found!")
            end
        end
    })

    self.visible = true
end



-- This method can be called from love.mousepressed to let the context menu handle the right-click.
-- Pass in all necessary dependencies.
function ContextMenu:handleMousePress(x, y, button, grid, enemies, character, state, camera)
    if button == 2 then -- Right-click in game mode
        self:open(x, y, grid, enemies, character, state, camera)
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
