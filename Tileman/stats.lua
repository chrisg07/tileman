local Stat = require "Tileman.stat"
local Stats = {}
Stats.__index = Stats

function Stats:new(state)
    local self = setmetatable({}, Stats)
    self.state = state
    self.stats = {
        {name = "experience", stat = Stat:new(state, "experience", 0, 100)},
        {name = "tiles", stat = Stat:new(state, "tiles", 0, 100)},
        {name = "health", stat = Stat:new(state, "health", 0, 100)},
        {name = "currency", stat = Stat:new(state, "currency", 0, 100)}
    }
    return self
end

function Stats:add(statName, amount)
    if self:get(statName) then
        self:get(statName):add(amount)
        print("Gained " .. amount .. " in " .. statName)
    else
        print("Stat '" .. statName .. "' does not exist!")
    end
end

function Stats:get(statName)
    for _, statEntry in ipairs(self.stats) do
        if statEntry.name == statName then
            return statEntry.stat
        end
    end
    return nil -- Return nil if the stat is not found
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
