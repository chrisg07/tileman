-- contextmenu.lua
local ContextMenu = {}
ContextMenu.__index = ContextMenu

local suit = require "suit"

function ContextMenu:new()
    local self = setmetatable({}, ContextMenu)
    self.visible = false
    self.x = 0
    self.y = 0
    self.type = nil          -- "attack" or "move"
    self.targetedEnemy = nil -- if attacking
    self.targetedTileX = nil -- if moving
    self.targetedTileY = nil -- if moving
    return self
end

-- Call this to display an attack menu at (x, y) targeting an enemy.
function ContextMenu:showAttack(x, y, enemy)
    self.visible = true
    self.x = x
    self.y = y
    self.type = "attack"
    self.targetedEnemy = enemy
end

-- Call this to display a move menu at (x, y) targeting a tile.
function ContextMenu:showMove(x, y, tileX, tileY)
    self.visible = true
    self.x = x
    self.y = y
    self.type = "move"
    self.targetedTileX = tileX
    self.targetedTileY = tileY
end

function ContextMenu:hide()
    self.visible = false
    self.type = nil
    self.targetedEnemy = nil
    self.targetedTileX = nil
    self.targetedTileY = nil
end

-- Update the context menu UI using SUIT.
-- Note: Pass in any dependencies (like character, grid, state) so the module can perform actions.
function ContextMenu:update(dt, character, grid, state)
    if self.visible then
        suit.layout:reset(self.x, self.y)
        if self.type == "attack" then
            if suit.Button("Attack", suit.layout:row(100, 30)).hit then
                character:attack(self.targetedEnemy)
                self:hide()
            end
        elseif self.type == "move" then
            if suit.Button("Move Here", suit.layout:row(100, 30)).hit then
                local Pathfinding = require("pathfinding")
                local path = Pathfinding.findPath(grid, character.targetX, character.targetY, self.targetedTileX,
                    self.targetedTileY)
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
                self:hide()
            end
        end
    end
end

function ContextMenu:draw()
    if self.visible then
        -- Optionally draw a background behind the menu (e.g., a semi-transparent rectangle)
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", self.x, self.y, 100, 30) -- Example size; adjust as needed.
        love.graphics.setColor(1, 1, 1)
    end
end

return ContextMenu
