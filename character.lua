-- character.lua
local Utils = require("utils")
local flux = require("flux.flux") -- Adjust the require path as needed

local Character = {}
Character.__index = Character

Character.MOVE_SPEED = 1 -- Default move speed in seconds

function Character:new(x, y, tileSize, state, grid)
    grid:discoverTile(x, y)
    return setmetatable({
        targetX = x,
        targetY = y,
        startX = x * tileSize,
        startY = y * tileSize,
        currentX = x * tileSize,
        currentY = y * tileSize,
        state = state,
        grid = grid,
        hasMoved = false,
        path = nil,      -- Holds the current path (if any)
        pathIndex = nil, -- Index of the next node in the path
        moveTween = nil, -- Reference to the current tween (if any)
        eyeShake = 0,    -- New property: amount of shake in pixels
    }, self)
end

function Character:setMoveSpeed(speed)
    self.MOVE_SPEED = speed
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
    if self.state:get("energy") <= 0 then return end
    if self.moveTween then return end

    local newX = self.targetX + dx
    local newY = self.targetY + dy

    if not self.grid:isDiscovered(newX, newY) then
        self.grid:discoverTile(newX, newY)
    end

    if self.grid:isDiscovered(newX, newY) and not self.grid:isVisited(newX, newY) then
        self.state:decrement("tiles")
        self.state:decrement("energy")
    elseif self.grid:isDiscovered(newX, newY) and self.grid:isVisited(newX, newY) then
        self.state:decrement("energy")
    else
        return
    end

    self.targetX = newX
    self.targetY = newY
    self.startX = self.currentX
    self.startY = self.currentY

    local ts = self.grid.tileSize
    local targetPixelX = newX * ts
    local targetPixelY = newY * ts

    self.eyeShake = 5
    flux.to(self, self.MOVE_SPEED, { eyeShake = 0 })

    self.moveTween = flux.to(self, self.MOVE_SPEED, { currentX = targetPixelX, currentY = targetPixelY })
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
function Character:update(dt, tileSize)
    if not self.moveTween then
        self.currentX = self.targetX * tileSize
        self.currentY = self.targetY * tileSize
    end
end

function Character:draw(tileSize, mouseX, mouseY)
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)

    -- Eye positioning relative to triangle
    local eyeOffsetX = tileSize * 0.1
    local eyeOffsetY = tileSize * 0.1
    local eyeRadius = tileSize * 0.11

    local centerX = self.currentX + tileSize / 2
    local centerY = self.currentY + tileSize / 2

    -- Compute eye movement direction towards mouse
    local dx, dy = mouseX - centerX, mouseY - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local maxEyeOffset = eyeRadius / 2  -- Adjusted maximum offset

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

return Character
