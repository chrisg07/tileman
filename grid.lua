local Grid = {}
Grid.__index = Grid

-- Define tile types and weightings
local tileTypes = {
    { type = "grass", weight = 50 }, -- 50% chance
    { type = "sand",  weight = 30 }, -- 30% chance
    { type = "water", weight = 15 }, -- 15% chance
    { type = "rock",  weight = 5 }   -- 5% chance
}

-- Weighted random selection function
local function getRandomTileType()
    local totalWeight = 0
    for _, tile in ipairs(tileTypes) do
        totalWeight = totalWeight + tile.weight
    end

    local randomValue = math.random(totalWeight)
    local cumulativeWeight = 0

    for _, tile in ipairs(tileTypes) do
        cumulativeWeight = cumulativeWeight + tile.weight
        if randomValue <= cumulativeWeight then
            return tile.type
        end
    end
end

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

function Grid:discoverTile(x, y)
    local key = x .. "," .. y
    if not self.tiles[key] then
        -- Select a random tile type based on weightings
        local tileType = getRandomTileType()
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
