local Grid = {}
Grid.__index = Grid

local tileTypes = {
    { type = "grass", weight = 50 },
    { type = "sand",  weight = 30 },
    { type = "water", weight = 15 },
    { type = "tree",  weight = 5 }
}

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

    local self = setmetatable({
        width = gridWidth,
        height = gridHeight,
        tileSize = tileSize,
        tiles = {},
        growthQueue = {}
    }, Grid)

    return self
end

-- When a tile is discovered, generate it (if needed) and mark it discovered.
-- Also, for each adjacent tile that is not in the grid yet, create a preview tile.
function Grid:discoverTile(x, y)
    local key = x .. "," .. y
    if not self.tiles[key] then
        local tileType = getRandomTileType()
        self.tiles[key] = { type = tileType, discovered = true }
    else
        self.tiles[key].discovered = true
        -- (Optional) In case the tile existed only as a preview, ensure its type is set.
        if not self.tiles[key].type then
            self.tiles[key].type = getRandomTileType()
        end
    end

    -- Pre-generate neighbors (if not already present) as undiscovered tiles.
    local offsets = {
        { 1, 0 }, { -1, 0 },
        { 0, 1 }, { 0, -1 },
        { 1,  1 }, { 1, -1 },
        { -1, 1 }, { -1, -1 }
    }
    for _, offset in ipairs(offsets) do
        local nx = x + offset[1]
        local ny = y + offset[2]
        -- Check bounds
        if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
            local nkey = nx .. "," .. ny
            if not self.tiles[nkey] then
                -- Create a preview tile that is not yet discovered.
                self.tiles[nkey] = { type = getRandomTileType(), discovered = false }
            end
        end
    end
end

function Grid:setTile(x, y, type)
    local key = x .. "," .. y
    self.tiles[key] = { type = type, discovered = true }
end

function Grid:isDiscovered(x, y)
    local key = x .. "," .. y
    return self.tiles[key] and self.tiles[key].discovered
end

-- Draw every tile in the grid.
-- Discovered tiles are drawn normally.
-- Undiscovered tiles (but pre-generated) are drawn foggy with their type shown in a faded way.
function Grid:draw()
    local ts = self.tileSize
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = x .. "," .. y
            local posX, posY = x * ts, y * ts
            local tile = self.tiles[key]
            if tile then
                if tile.discovered then
                    -- Fully discovered: draw normally.
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(tile.type or "?", posX, posY)
                else
                    -- Not discovered: draw a foggy preview.
                    love.graphics.setColor(0.5, 0.5, 0.5, 0.5) -- semi-transparent gray
                    love.graphics.rectangle("fill", posX, posY, ts, ts)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(tile.type or "?", posX + ts * 0.25, posY + ts * 0.25)
                end
            else
                -- If a tile hasn't been generated yet, you could fill it with black.
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", posX, posY, ts, ts)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end
end

-- Existing chopping and growth functions remain unchanged.
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
