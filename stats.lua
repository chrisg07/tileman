local Stat = require "stat"
local Stats = {}
Stats.__index = Stats

function Stats:new()
    local self = setmetatable({}, Stats)
    self.stats = {
        tiles = Stat:new("tiles", 1, 100),
        health = Stat:new("health", 1, 100),
        energy = Stat:new("energy", 1, 100),
        experience = Stat:new("experience", 1, 100)
    }

    return self
end

-- Add XP to a given stat.
function Stats:add(statName, amount)
    if self.stats[statName] then
        self.stats[statName]:add(amount)
        print("Gained " .. amount .. " in " .. statName)
    else
        print("Stat '" .. statName .. "' does not exist!")
    end
end

function Stats:get(statName)
    return self.stats[statName]
end

local function drawProgressBar(x, y, width, height, progress, scale)
    scale = scale or 1
    local scaledWidth = width * scale
    local scaledHeight = height * scale
    local offsetX = (scaledWidth - width) / 2
    local offsetY = (scaledHeight - height) / 2

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x - offsetX, y - offsetY, scaledWidth, scaledHeight)

    love.graphics.setColor(0.1, 0.8, 0.1)
    love.graphics.rectangle("fill", x - offsetX, y - offsetY, scaledWidth * progress, scaledHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x - offsetX, y - offsetY, scaledWidth, scaledHeight)

    love.graphics.setColor(1, 1, 1)
end



-- Draw all the progress bars for the stats.
-- Parameters:
--   x, y: starting position
--   width, height: size of each progress bar
--   spacing: vertical space between bars
function Stats:drawProgressBars(x, y, width, height, spacing)
    local i = 0
    for name, stat in pairs(self.stats) do
        local posX = x
        local posY = y + i * (height + spacing)
        -- local percent = stat:getPercent()
        -- drawProgressBar(posX, posY, width, height, percent, stat.scale)
        love.graphics.print(stat.name .. ": " .. stat.amount, posX, posY + height + 5)
        i = i + 1
    end
end

return Stats
