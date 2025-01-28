-- Constants
local TILE_SIZE = 50 -- Size of each tile in pixels
local MOVE_SPEED = 200 -- Pixels per second
local BOUNCE_DURATION = 0.2 -- Total duration of the bounce animation in seconds
local OVERSHOOT = 1.1 -- Factor for how far the triangle overshoots

-- Variables for character position
local targetX, targetY -- The grid position the character is moving to
local startX, startY -- Starting position of the bounce animation
local currentX, currentY -- Current pixel position
local bounceProgress = 1 -- Animation progress (1 means no animation is happening)

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
    if bounceProgress >= 1 then
        -- Move to the new tile if no animation is currently running
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

        -- Start bounce animation
        startX, startY = currentX, currentY
        bounceProgress = 0
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
    if bounceProgress < 1 then
        -- Update animation progress
        bounceProgress = math.min(bounceProgress + dt / BOUNCE_DURATION, 1)

        -- Calculate easing with overshoot
        local t = bounceProgress
        local easedT = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- Ease out cubic

        -- Calculate overshoot direction
        local dx = (targetX * TILE_SIZE - startX)
        local dy = (targetY * TILE_SIZE - startY)
        local distance = math.sqrt(dx^2 + dy^2)

        local overshootFactor = OVERSHOOT * (1 - t)
        local overshootX = dx / distance * overshootFactor * TILE_SIZE
        local overshootY = dy / distance * overshootFactor * TILE_SIZE

        -- Interpolate position with easing and directional overshoot
        currentX = startX + dx * easedT + overshootX
        currentY = startY + dy * easedT + overshootY
    else
        -- Ensure the character lands exactly at the target position when animation ends
        if currentX ~= targetX * TILE_SIZE or currentY ~= targetY * TILE_SIZE then
            currentX = targetX * TILE_SIZE
            currentY = targetY * TILE_SIZE
        end
    end
end