local Stat = require "Tileman.stat"
local Stats = {}
Stats.__index = Stats

function Stats:new(state)
    local self = setmetatable({}, Stats)
    self.state = state
    -- Store stats in an array-like table to maintain order
    self.stats = {
        {name = "tiles", stat = Stat:new(state, "tiles", 1, 100)},
        {name = "health", stat = Stat:new(state, "health", 1, 100)},
        {name = "experience", stat = Stat:new(state, "experience", 1, 100)},
        {name = "currency", stat = Stat:new(state, "currency", 1, 100)}
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
    for i, statEntry in ipairs(self.stats) do
        local stat = statEntry.stat
        local posX = x
        local posY = y + (i-1) * (height + spacing)
        -- local percent = stat:getPercent()
        -- drawProgressBar(posX, posY, width, height, percent, stat.scale)
        love.graphics.print(stat.name .. ": " .. stat.amount, posX, posY + height + 5)
    end
end

return Stats
