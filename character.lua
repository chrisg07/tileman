-- character.lua
local Utils = require("utils")

local Character = {}
Character.__index = Character

function Character:new(x, y, tileSize, state, grid)
    grid:discoverTile(x, y)

    return setmetatable({
        targetX = x,
        targetY = y,
        startX = x * tileSize,
        startY = y * tileSize,
        currentX = x * tileSize,
        currentY = y * tileSize,
        bounceProgress = 1,
        state = state,
        grid = grid,
        hasMoved = false,
        path = nil,      -- Holds the current path (if any)
        pathIndex = nil, -- Index of the next node in the path
    }, self)
end

function Character:setPath(path)
    self.path = path
    -- Assuming the first node in the path is the current position,
    -- start from the second node.
    self.pathIndex = 2
end

function Character:move(dx, dy)
    if self.state:get("energy") <= 0 then
        return
    end

    if self.bounceProgress >= 1 and self.grid then
        local newX = math.max(0, math.min(self.grid.width - 1, self.targetX + dx))
        local newY = math.max(0, math.min(self.grid.height - 1, self.targetY + dy))

        if not self.grid:isDiscovered(newX, newY) and self.state:get("energy") > 0 and self.state:get("tiles") > 0 then
            self.grid:discoverTile(newX, newY)
            self.state:decrement("tiles")
            self.state:decrement("energy")
        elseif self.grid:isDiscovered(newX, newY) and self.state:get("energy") > 0 then
            self.state:decrement("energy")
        else
            return
        end

        -- Maintain animation logic
        self.targetX = newX
        self.targetY = newY
        self.startX = self.currentX
        self.startY = self.currentY
        self.bounceProgress = 0

        self.hasMoved = true
        print("Player moved!")
    end
end

function Character:update(dt, tileSize, bounceDuration, overshoot)
    -- If a path is set and the character is not mid-move, trigger the next step.
    if self.path and self.pathIndex then
        if self.bounceProgress >= 1 and self.pathIndex <= #self.path then
            local nextTile = self.path[self.pathIndex]
            local dx = nextTile.x - self.targetX
            local dy = nextTile.y - self.targetY
            self:move(dx, dy)
            self.pathIndex = self.pathIndex + 1
        end
        if self.pathIndex and self.pathIndex > #self.path then
            -- Path complete.
            self.path = nil
            self.pathIndex = nil
        end
    end

    -- Existing animation logic.
    if self.bounceProgress < 1 then
        self.bounceProgress = math.min(self.bounceProgress + dt / bounceDuration, 1)
        local t = self.bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        local dx = (self.targetX * tileSize - self.startX)
        local dy = (self.targetY * tileSize - self.startY)
        local distance = math.sqrt(dx ^ 2 + dy ^ 2)
        local overshootFactor = overshoot * (1 - t)
        local overshootX = 0
        local overshootY = 0
        if distance > 0 then
            overshootX = dx / distance * overshootFactor * tileSize
            overshootY = dy / distance * overshootFactor * tileSize
        end
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

function Character:chopTree(tileX, tileY)
    self.grid:setTile(tileX, tileY, "stump")
    print("Tree chopped!")
end

function Character:attack(enemy)
    -- Example attack logic:
    print("Attacking enemy at (" .. enemy.x .. ", " .. enemy.y .. ")")
    -- Here you might reduce the enemy's health or remove the enemy from the enemies table.
    -- You could also trigger an animation or change game state to a combat phase.
end

return Character
