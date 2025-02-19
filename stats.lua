local Stat = require "stat"
local Stats = {}
Stats.__index = Stats

function Stats:new(state)
    local self = setmetatable({}, Stats)
    self.state = state
    self.stats = {
        tiles = Stat:new(state, "tiles", 1, 100),
        health = Stat:new(state, "health", 1, 100),
        energy = Stat:new(state, "energy", 1, 100),
        experience = Stat:new(state, "experience", 1, 100)
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
