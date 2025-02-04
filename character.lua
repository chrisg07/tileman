-- character.lua
local Utils = require("utils")
local flux = require("flux.flux") -- Adjust the require path as needed

local mouseX, mouseY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
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
    if self.state:get("energy") <= 0 then return end
    if self.moveTween then return end

    local newX = math.max(0, math.min(self.grid.width - 1, self.targetX + dx))
    local newY = math.max(0, math.min(self.grid.height - 1, self.targetY + dy))

    if not self.grid:isDiscovered(newX, newY) then
        self.grid:discoverTile(newX, newY)
    end

    if self.grid:isDiscovered(newX, newY) and self.state:get("energy") > 0 then
        self.state:decrement("energy")
    else
        return
    end

    -- Set new target and record starting position.
    self.targetX = newX
    self.targetY = newY
    self.startX = self.currentX
    self.startY = self.currentY

    local ts = self.grid.tileSize
    local targetPixelX = newX * ts
    local targetPixelY = newY * ts

    -- Trigger an eye shake: set a nonzero eyeShake value and tween it back to 0.
    self.eyeShake = 5  -- Adjust this value to change the shake amplitude.
    flux.to(self, 0.3, { eyeShake = 0 })

    -- Tween the character's position from the current to target pixel coordinates.
    self.moveTween = flux.to(self, 0.3, { currentX = targetPixelX, currentY = targetPixelY })
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

function Character:mousemoved(x, y) 
    mouseX, mouseY = x, y
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

    -- Draw eyes
    love.graphics.setColor(1, 1, 1) -- White for eyeball
    love.graphics.circle("fill", centerX - eyeOffsetX, centerY - eyeOffsetY, eyeRadius)
    love.graphics.circle("fill", centerX + eyeOffsetX, centerY - eyeOffsetY, eyeRadius)

    -- Draw pupils
    love.graphics.setColor(0, 0, 0) -- Black for pupil
    love.graphics.circle("fill", centerX - eyeOffsetX + dx, centerY - eyeOffsetY + dy, eyeRadius / 2)
    love.graphics.circle("fill", centerX + eyeOffsetX + dx, centerY - eyeOffsetY + dy, eyeRadius / 2)

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
