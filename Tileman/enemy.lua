-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy

local Utils = require("Tileman.utils") -- Require Utils for triangle vertices

function Enemy:new(x, y, tileSize, speed)
    return setmetatable({
        x = x,
        y = y,
        tileSize = tileSize,
        speed = speed or 1, -- Default speed
        targetX = x,
        targetY = y,
        currentX = x * tileSize,
        currentY = y * tileSize,
        bounceProgress = 1,
        movedThisTurn = false -- New flag for turn-based movement
    }, self)
end

-- This function triggers a new move if the enemy is idle and hasn't moved yet this turn.
function Enemy:triggerMove(grid)
    if self.bounceProgress >= 1 and not self.movedThisTurn then
        local dx, dy = 0, 0
        local direction = math.random(4)
        if direction == 1 then
            dx = -1
        elseif direction == 2 then
            dx = 1
        elseif direction == 3 then
            dy = -1
        elseif direction == 4 then
            dy = 1
        end

        local newX = math.max(0, math.min(grid.width - 1, self.targetX + dx))
        local newY = math.max(0, math.min(grid.height - 1, self.targetY + dy))

        if grid:isDiscovered(newX, newY) then
            self.targetX = newX
            self.targetY = newY
            self.bounceProgress = 0
            self.movedThisTurn = true -- Mark that this enemy has moved this turn
        end
    end
end

function Enemy:update(dt, grid, character)
    -- Update the bounce interpolation every frame.
    if self.bounceProgress < 1 then
        self.bounceProgress = math.min(self.bounceProgress + dt * self.speed, 1)
        local t = self.bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        self.currentX = self.x * self.tileSize + (self.targetX - self.x) * self.tileSize * easedT
        self.currentY = self.y * self.tileSize + (self.targetY - self.y) * self.tileSize * easedT
    else
        -- Once the bounce (movement) completes, update the enemy's logical position.
        self.x = self.targetX
        self.y = self.targetY
        self.currentX = self.x * self.tileSize
        self.currentY = self.y * self.tileSize

        -- Reset the flag so the enemy is ready to move on the next turn.
        if self.movedThisTurn then
            self.movedThisTurn = false
        end

        -- Check for collision with the character here.
        if self:checkCollision(character) then
            character.state:decrement("health")
            print("Character damaged by enemy! Health: " .. character.state.health)
        end
    end
end

function Enemy:draw()
    love.graphics.setColor(1, 0, 0) -- Red color for enemies
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, self.tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Enemy:checkCollision(character)
    return self.x == character.targetX and self.y == character.targetY
end

return Enemy
