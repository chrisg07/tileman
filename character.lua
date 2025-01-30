-- character.lua
local Utils = require("utils")

local Character = {}
Character.__index = Character

function Character:new(x, y, tileSize, state, grid)
    return setmetatable({
        targetX = x,
        targetY = y,
        startX = x * tileSize,
        startY = y * tileSize,
        currentX = x * tileSize,
        currentY = y * tileSize,
        bounceProgress = 1,
        state = state,
        grid = grid -- Store reference to grid
    }, self)
end

function Character:move(dx, dy)
    if self.state:getCounter() <= 0 then
        return -- Prevent movement if counter is not positive
    end

    if self.bounceProgress >= 1 and self.grid then -- Ensure grid is not nil
        local newX = math.max(0, math.min(self.grid.width - 1, self.targetX + dx))
        local newY = math.max(0, math.min(self.grid.height - 1, self.targetY + dy))

        -- Discover the new tile
        self.grid:discoverTile(newX, newY, "grass")

        -- Maintain animation logic
        self.targetX = newX
        self.targetY = newY
        self.startX = self.currentX
        self.startY = self.currentY
        self.bounceProgress = 0

        -- Decrement movement counter
        self.state:decrementCounter()
    end
end

function Character:update(dt, tileSize, bounceDuration, overshoot)
    if self.bounceProgress < 1 then
        self.bounceProgress = math.min(self.bounceProgress + dt / bounceDuration, 1)
        local t = self.bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        local dx = (self.targetX * tileSize - self.startX)
        local dy = (self.targetY * tileSize - self.startY)
        local distance = math.sqrt(dx ^ 2 + dy ^ 2)
        local overshootFactor = overshoot * (1 - t)
        local overshootX = dx / distance * overshootFactor * tileSize
        local overshootY = dy / distance * overshootFactor * tileSize
        self.currentX = self.startX + dx * easedT + overshootX
        self.currentY = self.startY + dy * easedT + overshootY
    else
        self.currentX = self.targetX * tileSize
        self.currentY = self.targetY * tileSize
    end
end

function Character:draw(tileSize)
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)
end

return Character
