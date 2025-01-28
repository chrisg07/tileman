-- Constants
local TILE_SIZE = 50 -- Size of each tile in pixels
local MOVE_SPEED = 200 -- Pixels per second

-- Variables for character position
local targetX, targetY -- The grid position the character is moving to
local currentX, currentY -- The character's current pixel position
local isMoving = false -- Whether the character is currently moving

-- Input flag to prevent continuous movement
local canMove = true

function love.load()
    -- Starting position
    targetX, targetY = 5, 5
    currentX, currentY = targetX * TILE_SIZE, targetY * TILE_SIZE

    -- Calculate the grid dimensions based on the screen size
    local screenWidth, screenHeight = love.graphics.getDimensions()
    GRID_WIDTH = math.floor(screenWidth / TILE_SIZE)
    GRID_HEIGHT = math.floor(screenHeight / TILE_SIZE)
end
function love.keypressed(key)
    if not isMoving then
        -- Move to the new tile if not already moving
        if key == "w" then
            targetY = targetY - 1
        elseif key == "s" then
            targetY = targetY + 1
        elseif key == "a" then
            targetX = targetX - 1
        elseif key == "d" then
            targetX = targetX + 1
        end

        -- Ensure target stays within grid bounds
        targetX = math.max(0, math.min(GRID_WIDTH - 1, targetX))
        targetY = math.max(0, math.min(GRID_HEIGHT - 1, targetY))

        -- Start the movement animation
        isMoving = true
    end
end

function love.keyreleased(key)
    -- Allow movement again when the key is released
    canMove = true
end

function love.draw()
    -- Draw the grid
    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            love.graphics.rectangle("line", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    
    -- Draw the character as a triangle
    local triangleVertices = getTriangleVertices(currentX, currentY, TILE_SIZE, 0.6)
    love.graphics.polygon("fill", triangleVertices)
end

-- Helper function to calculate the triangle vertices
function getTriangleVertices(x, y, size, scale)
    local scaledSize = size * scale
    local halfScaledSize = scaledSize / 2
    local padding = (size - scaledSize) / 2 -- Center the triangle in the tile
    return {
        x + padding + halfScaledSize, y + padding,           -- Top vertex
        x + padding, y + padding + scaledSize,              -- Bottom-left vertex
        x + padding + scaledSize, y + padding + scaledSize  -- Bottom-right vertex
    }
end

function love.update(dt)
    -- Smoothly interpolate toward the target position
    if isMoving then
        local dx = (targetX * TILE_SIZE) - currentX
        local dy = (targetY * TILE_SIZE) - currentY
        local distance = math.sqrt(dx^2 + dy^2)

        if distance < MOVE_SPEED * dt then
            -- Snap to the target when close enough
            currentX = targetX * TILE_SIZE
            currentY = targetY * TILE_SIZE
            isMoving = false
        else
            -- Continue moving toward the target
            local directionX = dx / distance
            local directionY = dy / distance
            currentX = currentX + directionX * MOVE_SPEED * dt
            currentY = currentY + directionY * MOVE_SPEED * dt
        end
    end
end