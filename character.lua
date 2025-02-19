-- character.lua
local Utils = require("utils")
local flux = require("flux.flux") -- Adjust the require path as needed

local Character = {}
Character.__index = Character

function Character:new(x, y, state, grid)
    grid:discoverTile(x, y)
    grid:expandFog(x, y)

    return setmetatable({
        targetX = x,
        targetY = y,
        startX = x * state.tileSize,
        startY = y * state.tileSize,
        currentX = x * state.tileSize,
        currentY = y * state.tileSize,
        state = state,
        grid = grid,
        hasMoved = false,
        path = nil,      -- Holds the current path (if any)
        pathIndex = nil, -- Index of the next node in the path
        moveTween = nil, -- Reference to the current tween (if any)
        eyeShake = 0,    -- New property: amount of shake in pixels
    }, self)
end

-- When a multi-tile path is set (for example via the context menu), we assume that
-- the first node in the path is the current position, so we start from the second node.
function Character:setPath(path)
    self.path = path
    if #path > 1 then
        self.pathIndex = 2
        self:moveToNextTile()
    end
end

function Character:moveToNextTile()
    if self.path and self.pathIndex and self.pathIndex <= #self.path then
        local nextTile = self.path[self.pathIndex]
        local dx = nextTile.x - self.targetX
        local dy = nextTile.y - self.targetY
        self.pathIndex = self.pathIndex + 1
        self:move(dx, dy, function()
            self:moveToNextTile() -- Continue chaining
        end)
    else
        self.path = nil
        self.pathIndex = nil
        print("Path complete")
    end
end

-- Updated move method using tweening for movement and triggering an eye shake.
-- An optional onComplete callback allows chaining.
function Character:move(dx, dy, onComplete)
    if self.moveTween then return end

    local newX = self.targetX + dx
    local newY = self.targetY + dy
    local currentTile = self.grid:getTile(newX, newY)

    if self.state.stats:get("tiles").amount <= 0 and not currentTile.visited then return end

    if currentTile.discovered and not currentTile.visited then
        self.state.stats:get("tiles"):add(-1)

        local constant = 50
        local gain = math.floor(constant / currentTile.weight)
        print("Visited a tile for the first time at (" .. newX .. ", " .. newY .. ")")
        self.state.skills:addXP("exploration", gain)
        currentTile.visited = true
        self.grid:expandFog(newX, newY)
    elseif currentTile.discovered and currentTile.visited then
        -- self.state:decrement("energy")
    else
        return
    end

    self.targetX = newX
    self.targetY = newY
    self.startX = self.currentX
    self.startY = self.currentY

    local targetPixelX = newX * self.state.tileSize
    local targetPixelY = newY * self.state.tileSize

    self.eyeShake = 5
    flux.to(self, self.state.moveSpeed, { eyeShake = 0 })

    self.moveTween = flux.to(self, self.state.moveSpeed, { currentX = targetPixelX, currentY = targetPixelY })
        :ease("quadout")
        :oncomplete(function()
            self.moveTween = nil
            self.currentX = targetPixelX
            self.currentY = targetPixelY
            print("Player moved to (" .. newX .. ", " .. newY .. ")")
            if onComplete then onComplete() end
        end)
end

-- The update method now only ensures that if no tween is active, the position is snapped.
function Character:update(dt)
    if not self.moveTween then
        self.currentX = self.targetX * self.state.tileSize
        self.currentY = self.targetY * self.state.tileSize
    end
end

function Character:draw(mouseX, mouseY)
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, self.state.tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)

    -- Eye positioning relative to triangle
    local eyeOffsetX = self.state.tileSize * 0.1
    local eyeOffsetY = self.state.tileSize * 0.1
    local eyeRadius = self.state.tileSize * 0.11

    local centerX = self.currentX + self.state.tileSize / 2
    local centerY = self.currentY + self.state.tileSize / 2

    -- Compute eye movement direction towards mouse
    local dx, dy = mouseX - centerX, mouseY - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local maxEyeOffset = eyeRadius / 2 -- Adjusted maximum offset

    if distance > 0 then
        dx, dy = (dx / distance) * maxEyeOffset, (dy / distance) * maxEyeOffset
    end

    local shakeX, shakeY = 0, 0
    if self.eyeShake and self.eyeShake > 0 then
        shakeX = math.random(-self.eyeShake, self.eyeShake)
        shakeY = math.random(-self.eyeShake, self.eyeShake)
    end

    -- Draw eyes
    love.graphics.setColor(1, 1, 1) -- White for eyeball
    love.graphics.circle("fill", centerX - eyeOffsetX, centerY - eyeOffsetY, eyeRadius)
    love.graphics.circle("fill", centerX + eyeOffsetX, centerY - eyeOffsetY, eyeRadius)

    -- Draw pupils
    love.graphics.setColor(0, 0, 0) -- Black for pupil
    love.graphics.circle("fill", centerX - eyeOffsetX + dx + shakeX, centerY - eyeOffsetY + dy + shakeY, eyeRadius / 2)
    love.graphics.circle("fill", centerX + eyeOffsetX + dx + shakeX, centerY - eyeOffsetY + dy + shakeY, eyeRadius / 2)
    -- eye outline
    love.graphics.circle("line", centerX - eyeOffsetX, centerY - eyeOffsetY, eyeRadius)
    love.graphics.circle("line", centerX + eyeOffsetX, centerY - eyeOffsetY, eyeRadius)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Character:chopTree(tileX, tileY)
    local key = tileX .. "," .. tileY
    if self.grid.tiles[key] and self.grid.tiles[key].type == "tree" then
        self.state.skills:addXP("woodcutting", 5)
        self.grid:chopTree(tileX, tileY)
        return true
    end
    return false
end

function Character:attack(enemy)
    print("Attacking enemy at (" .. enemy.x .. ", " .. enemy.y .. ")")
    -- Attack logic would go here.
end

function Character:handleMousePress(x, y, button)
    if button == 1 then
        local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, self.state.tileSize, 0.6)
        local screenVertices = Utils.offsetVertices(triangleVertices, self.state.camera)

        if Utils.pointInTriangle(x, y, screenVertices) then
            self.state.stats:get("experience"):add(1)
            print("Gained experience by selecting the character")
        end
    end
end

return Character
