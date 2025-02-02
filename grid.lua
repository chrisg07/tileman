local Grid = {}
Grid.__index = Grid

local tileTypes = {
    { type = "grass", weight = 50 },
    { type = "sand",  weight = 30 },
    { type = "water", weight = 15 },
    { type = "tree",  weight = 5 }
}

function Grid:new(tileSize)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gridWidth = math.floor(screenWidth / tileSize)
    local gridHeight = math.floor(screenHeight / tileSize)

    local self = setmetatable({
        width = gridWidth,
        height = gridHeight,
        tileSize = tileSize,
        tiles = {},
        growthQueue = {}
    }, Grid)

    return self
end

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

function Grid:discoverTile(x, y)
    local key = x .. "," .. y
    if not self.tiles[key] then
        local tileType = getRandomTileType()
        self.tiles[key] = { type = tileType, discovered = true }
    end
end

function Grid:setTile(x, y, type)
    local key = x .. "," .. y
    self.tiles[key] = { type = type, discovered = true }
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

-- Call this function to chop a tree at tile (x, y).
-- growDelay is in seconds (default is 10 seconds).
function Grid:chopTree(x, y)
    local key = x .. "," .. y
    if self.tiles[key] and self.tiles[key].type == "tree" then
        self.tiles[key].type = "stump"
        local delay = 10
        local regrowTime = love.timer.getTime() + delay
        self.tiles[key].regrowTime = regrowTime
        table.insert(self.growthQueue, { key = key, regrowTime = regrowTime })
    end
end

function Grid:update(dt)
    local currentTime = love.timer.getTime()
    local i = 1
    while i <= #self.growthQueue do
        local entry = self.growthQueue[i]
        if currentTime >= entry.regrowTime then
            local tile = self.tiles[entry.key]
            if tile and tile.type == "stump" then
                tile.type = "tree"
                tile.regrowTime = nil
                print("Stump at " .. entry.key .. " has regrown into a tree!")
            end
            table.remove(self.growthQueue, i)
        else
            i = i + 1
        end
    end
end

return Grid
