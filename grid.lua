local Grid = {}
Grid.__index = Grid

function Grid:new(tileSize)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gridWidth = math.floor(screenWidth / tileSize)
    local gridHeight = math.floor(screenHeight / tileSize)
    return setmetatable({ width = gridWidth, height = gridHeight, tileSize = tileSize }, self)
end

function Grid:draw()
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            love.graphics.print("0", x * self.tileSize, y * self.tileSize)
        end
    end
end

return Grid
