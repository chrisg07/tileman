-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy

local Utils = require("utils") -- Require Utils for triangle vertices

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
        bounceProgress = 1
    }, self)
end

function Enemy:update(dt, grid)
    -- Simple AI: Move towards the player or randomly
    if self.bounceProgress >= 1 then
        local dx, dy = 0, 0

        -- Random movement (for now)
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

        -- Check if the new position is valid
        local newX = math.max(0, math.min(grid.width - 1, self.targetX + dx))
        local newY = math.max(0, math.min(grid.height - 1, self.targetY + dy))

        if grid:isDiscovered(newX, newY) then
            self.targetX = newX
            self.targetY = newY
            self.bounceProgress = 0
        end
    end

    -- Update position with bounce animation
    if self.bounceProgress < 1 then
        self.bounceProgress = math.min(self.bounceProgress + dt * self.speed, 1)
        local t = self.bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        self.currentX = self.x * self.tileSize + (self.targetX - self.x) * self.tileSize * easedT
        self.currentY = self.y * self.tileSize + (self.targetY - self.y) * self.tileSize * easedT
    else
        self.x = self.targetX
        self.y = self.targetY
        self.currentX = self.x * self.tileSize
        self.currentY = self.y * self.tileSize
    end
end

function Enemy:draw()
    -- Draw the enemy as a red triangle
    love.graphics.setColor(1, 0, 0) -- Red color for enemies
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, self.tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Enemy:checkCollision(character)
    return self.x == character.targetX and self.y == character.targetY
end

return Enemy
