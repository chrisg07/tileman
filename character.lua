-- character.lua
local Utils = require("utils")
local flux = require("flux.flux") -- Adjust the require path as needed

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
    }, self)
end

-- When a multi-tile path is set (for example via the context menu), we assume that
-- the first node is the current position, so we start at index 2.
function Character:setPath(path)
    self.path = path
    if #path > 1 then
        -- Start at the second node (since the first node is the current position).
        self.pathIndex = 2
        if not self.moveTween then
            local nextTile = self.path[self.pathIndex]
            local dx = nextTile.x - self.targetX
            local dy = nextTile.y - self.targetY
            self.pathIndex = self.pathIndex + 1
            self:move(dx, dy)
        end
    end
end

function Character:move(dx, dy)
    if self.state:get("energy") <= 0 then return end
    if self.moveTween then return end

    local newX = self.targetX + dx
    local newY = self.targetY + dy

    -- Ensure that the tile is generated before moving
    if not self.grid:isDiscovered(newX, newY) then
        self.grid:discoverTile(newX, newY)
    end

    -- Energy and tile discovery logic
    if not self.grid:isDiscovered(newX, newY) and self.state:get("tiles") > 0 then
        self.grid:discoverTile(newX, newY)
        self.state:decrement("tiles")
        self.state:decrement("energy")
    elseif self.grid:isDiscovered(newX, newY) and self.state:get("energy") > 0 then
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

    self.moveTween = flux.to(self, 0.3, { currentX = targetPixelX, currentY = targetPixelY })
        :ease("quadout")
        :oncomplete(function()
            self.moveTween = nil
            self.currentX = targetPixelX
            self.currentY = targetPixelY
            print("Player moved to (" .. newX .. ", " .. newY .. ")")
        end)
end


-- Update method now only ensures that if no tween is active, the character's position
-- is exactly at its target. Flux handles the tween interpolation.
function Character:update(dt, tileSize)
    if not self.moveTween then
        self.currentX = self.targetX * tileSize
        self.currentY = self.targetY * tileSize
    end
end

function Character:draw(tileSize)
    local triangleVertices = Utils.getTriangleVertices(self.currentX, self.currentY, tileSize, 0.6)
    love.graphics.polygon("fill", triangleVertices)
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
