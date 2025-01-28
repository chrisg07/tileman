local Utils = require("utils") -- Require Utils for helper functions

local Character = {}
Character.__index = Character

function Character:new(x, y, tileSize)
    print("Initializing Character with x:", x, "y:", y, "tileSize:", tileSize)
    return setmetatable({
        targetX = x,
        targetY = y,
        startX = x * tileSize,
        startY = y * tileSize,
        currentX = x * tileSize,
        currentY = y * tileSize,
        bounceProgress = 1
    }, self)
end

function Character:move(dx, dy, gridWidth, gridHeight)
    print("Move called with dx:", dx, "dy:", dy, "gridWidth:", gridWidth, "gridHeight:", gridHeight)
    if self.bounceProgress >= 1 then
        self.targetX = math.max(0, math.min(gridWidth - 1, self.targetX + dx))
        self.targetY = math.max(0, math.min(gridHeight - 1, self.targetY + dy))
        self.startX = self.currentX
        self.startY = self.currentY
        self.bounceProgress = 0
    end
end

function Character:update(dt, tileSize, bounceDuration, overshoot)
    print("targetX:", self.targetX, "targetY:", self.targetY, "bounceProgress:", self.bounceProgress)
    print("startX:", self.startX, "startY:", self.startY, "currentX:", self.currentX, "currentY:", self.currentY)
    if self.bounceProgress < 1 then
        self.bounceProgress = math.min(self.bounceProgress + dt / bounceDuration, 1)
        local t = self.bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        local dx = (self.targetX * tileSize - self.startX)
        local dy = (self.targetY * tileSize - self.startY)
        local distance = math.sqrt(dx^2 + dy^2)
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
