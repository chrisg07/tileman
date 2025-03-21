local Grid = {}
Grid.__index = Grid

local flux = require("flux.flux") -- Ensure flux is required

local tileTypes = {
    { type = "grass", weight = 50, color = { 0.1, 0.8, 0.1 } },  -- Green
    { type = "sand",  weight = 30, color = { 0.9, 0.8, 0.3 } },  -- Yellow
    { type = "water", weight = 15, color = { 0.2, 0.4, 0.9 } },  -- Blue
    { type = "tree",  weight = 5,  color = { 0.2, 0.6, 0.2 } }   -- Dark green
}

function Grid:new(state, fogDistance)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gridWidth = math.floor(screenWidth / state.tileSize)
    local gridHeight = math.floor(screenHeight / state.tileSize)

    local self = setmetatable({
        width = gridWidth,
        height = gridHeight,
        state = state,
        tiles = {},
        growthQueue = {},
        fogDistance = fogDistance or 2 -- Default fog distance if not provided
    }, Grid)

    return self
end

local function getProceduralTileType(x, y)
    local noiseValue = love.math.noise(x * 0.1, y * 0.1) -- Scale noise frequency

    -- Compute total weight sum
    local totalWeight = 0
    for _, tile in ipairs(tileTypes) do
        totalWeight = totalWeight + tile.weight
    end

    -- Scale noiseValue into weight range
    local scaledNoise = noiseValue * totalWeight

    -- Determine tile type based on weighted probability
    local cumulativeWeight = 0
    for _, tile in ipairs(tileTypes) do
        cumulativeWeight = cumulativeWeight + tile.weight
        if scaledNoise <= cumulativeWeight then
            return tile.type, tile.color, tile.weight
        end
    end

    -- Fallback (should never be reached)
    return "grass", { 0.1, 0.8, 0.1 }, 50 -- Default to grass with weight 50
end


function Grid:createTile(x, y, discovered, visited)
    local tileType, tileColor, tileWeight = getProceduralTileType(x, y) -- Use Perlin noise
    local key = x .. "," .. y

    self.tiles[key] = {
        type = tileType,
        discovered = discovered or false,
        visited = visited or false,
        color = tileColor, -- Store procedural color
        weight = tileWeight, -- ✅ Now storing weight
        yOffset = love.graphics.getHeight() -- Start off-screen
    }

    self:animateTile(key)
    return self.tiles[key]
end

function Grid:discoverTile(x, y)
    local key = x .. "," .. y

    if not self.tiles[key] then
        self:createTile(x, y, true, true)
        print("Discovered new tile at (" .. x .. ", " .. y .. ")")
    end
end

function Grid:getTile(x, y)
    local key = x .. "," .. y
    return self.tiles[key]
end

function Grid:setVisited(x, y, bool)
    local key = x .. "," .. y
    self.tiles[key] = bool
end

function Grid:setTile(x, y, type)
    local key = x .. "," .. y
    self.tiles[key] = { type = type, discovered = true }
end

function Grid:isDiscovered(x, y)
    local key = x .. "," .. y
    return self.tiles[key] and self.tiles[key].discovered
end

function Grid:isVisited(x, y)
    local key = x .. "," .. y
    local visited = self.tiles[key] and self.tiles[key].visited

    if visited then 
        print("Tile at (" .. x .. ", " .. y .. ") has been visited")
    else
        print("Tile at (" .. x .. ", " .. y .. ") has not been visited")
    end
    return visited
end

function Grid:expandFog(x, y)
    for dx = -self.fogDistance, self.fogDistance do
        for dy = -self.fogDistance, self.fogDistance do
            local nx, ny = x + dx, y + dy
            local nkey = nx .. "," .. ny

            if math.abs(dx) + math.abs(dy) <= self.fogDistance then
                if not self.tiles[nkey] then
                    self:createTile(nx, ny, true, false) -- Procedurally generate fog tiles
                end
            end
        end
    end
end

function Grid:animateTile(tileKey)
    flux.to(self.tiles[tileKey], 2, { yOffset = 0 }):ease("elasticinout")
end

-- Draw every tile in the grid.
-- Discovered tiles are drawn normally.
-- Undiscovered tiles (but pre-generated) are drawn foggy with their type shown in a faded way.
function Grid:draw()
    local ts = self.state.tileSize
    for key, tile in pairs(self.tiles) do
        local x, y = key:match("([^,]+),([^,]+)")
        x, y = tonumber(x), tonumber(y)
        local posX, posY = x * ts, y * ts + (tile.yOffset or 0) -- Apply animation offset

        self:drawTile(posX, posY, tile) -- Pass full tile data
    end
end

function Grid:drawTile(x, y, tile)
    local r, g, b = unpack(tile.color or { 1, 1, 1 }) -- Default to white if no color
    local alpha = tile.visited and 1 or 0.5 -- Fog effect

    love.graphics.setColor(r, g, b, alpha)
    love.graphics.rectangle("fill", x, y, self.state.tileSize, self.state.tileSize)

    -- Draw text in white for contrast
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tile.type or "?", x + self.state.tileSize * 0.25, y + self.state.tileSize * 0.25)
end

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
