local Grid = {}
Grid.__index = Grid

local flux = require("flux.flux") -- Ensure flux is required

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
            return tile.type, tile.weight
        end
    end
end

function Grid:new(tileSize, state)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local gridWidth = math.floor(screenWidth / tileSize)
    local gridHeight = math.floor(screenHeight / tileSize)

    local self = setmetatable({
        width = gridWidth,
        height = gridHeight,
        tileSize = tileSize,
        state = state,
        tiles = {},
        growthQueue = {}
    }, Grid)

    return self
end

function Grid:discoverTile(x, y)
    local key = x .. "," .. y
    local constant = 50 -- XP reward scaling factor

    if not self.tiles[key] then
        local tileType, tileWeight = getRandomTileType()
        
        -- New tile starts below the screen and will animate upwards
        self.tiles[key] = {
            type = tileType,
            discovered = true, -- Mark as discovered
            seen = true, -- Also mark as seen
            weight = tileWeight,
            yOffset = love.graphics.getHeight() -- Start off-screen
        }

        -- Animate tile upwards
        flux.to(self.tiles[key], 0.5, { yOffset = 0 }):ease("quadout")

        -- XP gain for exploration
        local gain = math.floor(constant / tileWeight)
        self.state.skills:addXP("exploration", gain)
        print("Discovered new tile (" .. x .. ", " .. y .. "): " .. tileType .. " gained " .. gain .. " exp")
    elseif not self.tiles[key].discovered then
        self.tiles[key].discovered = true
        local tileWeight = self.tiles[key].weight or 50
        local gain = math.floor(constant / tileWeight)
        self.state.skills:addXP("exploration", gain)
        print("Discovered tile (" .. x .. ", " .. y .. "): " .. self.tiles[key].type .. " gained " .. gain .. " exp")
    end

    -- Generate surrounding tiles but **mark them as seen, not discovered**
    local offsets = { {1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1} }
    for _, offset in ipairs(offsets) do
        local nx, ny = x + offset[1], y + offset[2]
        local nkey = nx .. "," .. ny
        if not self.tiles[nkey] then
            local tType, tWeight = getRandomTileType()
            self.tiles[nkey] = {
                type = tType,
                discovered = false, -- Mark as unseen
                seen = true, -- Mark as seen (so it appears as fog)
                weight = tWeight,
                yOffset = love.graphics.getHeight() -- Start off-screen
            }

            -- Animate seen tile upwards
            flux.to(self.tiles[nkey], 0.5, { yOffset = 0 }):ease("quadout")
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
    for key, tile in pairs(self.tiles) do
        local x, y = key:match("([^,]+),([^,]+)")
        x, y = tonumber(x), tonumber(y)
        local posX, posY = x * ts, y * ts + (tile.yOffset or 0) -- Apply animation offset

        if tile.discovered then
            -- Draw fully discovered tiles normally
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tile.type or "?", posX, posY)
        elseif tile.seen then
            -- Draw seen but undiscovered tiles with fog effect
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5) -- Semi-transparent gray
            love.graphics.rectangle("fill", posX, posY, ts, ts)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tile.type or "?", posX + ts * 0.25, posY + ts * 0.25)
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
