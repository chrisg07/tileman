local Grid = {}
Grid.__index = Grid

function Grid:new(tileSize)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gridWidth = math.floor(screenWidth / tileSize)
    local gridHeight = math.floor(screenHeight / tileSize)

    return setmetatable({
        width = gridWidth,   -- Ensure width is set
        height = gridHeight, -- Ensure height is set
        tileSize = tileSize,
        tiles = {}           -- Store discovered tiles
    }, self)
end

function Grid:discoverTile(x, y, tileType)
    local key = x .. "," .. y
    if not self.tiles[key] then
        self.tiles[key] = { type = tileType, discovered = true }
    end
end

function Grid:isDiscovered(x, y)
    return self.tiles[x .. "," .. y] ~= nil
end

function Grid:draw()
    for key, tile in pairs(self.tiles) do
        local x, y = key:match("([^,]+),([^,]+)")
        x, y = tonumber(x), tonumber(y)
        love.graphics.print(tile.type or "?", x * self.tileSize, y * self.tileSize)
    end
end

return Grid
