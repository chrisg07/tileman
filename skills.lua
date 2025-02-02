-- skills.lua
local Skill = require "skill"
local Skills = {}
Skills.__index = Skills

function Skills:new()
    local self = setmetatable({}, Skills)
    -- Initialize your skills here. For ordering purposes, you can store skills in a table.
    self.skills = {
        mining = Skill:new("mining", 0, 1, 100),
        exploration = Skill:new("exploration", 0, 1, 100),
        woodcutting = Skill:new("woodcutting", 0, 1, 100)
        -- Add more skills as needed.
    }
    return self
end

-- Add XP to a given skill.
function Skills:addXP(skillName, amount)
    if self.skills[skillName] then
        self.skills[skillName]:addXP(amount)
    else
        print("Skill '" .. skillName .. "' does not exist!")
    end
end

-- Get a reference to a skill.
function Skills:get(skillName)
    return self.skills[skillName]
end

-- Local helper function to draw a single progress bar.
local function drawProgressBar(x, y, width, height, progress)
    -- Draw the background.
    love.graphics.setColor(0.3, 0.3, 0.3) -- dark gray
    love.graphics.rectangle("fill", x, y, width, height)

    -- Draw the progress (filled portion).
    love.graphics.setColor(0.1, 0.8, 0.1) -- green
    love.graphics.rectangle("fill", x, y, width * progress, height)

    -- Draw the border.
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.rectangle("line", x, y, width, height)

    -- Reset color.
    love.graphics.setColor(1, 1, 1)
end

-- Draw all the progress bars for the skills.
-- Parameters:
--   x, y: starting position
--   width, height: size of each progress bar
--   spacing: vertical space between bars
function Skills:drawProgressBars(x, y, width, height, spacing)
    local i = 0
    for name, skill in pairs(self.skills) do
        local posX = x
        local posY = y + i * (height + spacing)
        local progress = skill:getProgress()
        drawProgressBar(posX, posY, width, height, progress)
        love.graphics.print(skill.name .. " Lvl " .. skill.level, posX, posY + height + 5)
        i = i + 1
    end
end

return Skills
