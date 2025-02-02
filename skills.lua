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
local function drawProgressBar(x, y, width, height, progress, scale)
    scale = scale or 1
    -- Adjust x, y to center the scaled rectangle.
    local scaledWidth = width * scale
    local scaledHeight = height * scale
    local offsetX = (scaledWidth - width) / 2
    local offsetY = (scaledHeight - height) / 2

    love.graphics.setColor(0.3, 0.3, 0.3) -- background
    love.graphics.rectangle("fill", x - offsetX, y - offsetY, scaledWidth, scaledHeight)

    love.graphics.setColor(0.1, 0.8, 0.1) -- fill
    love.graphics.rectangle("fill", x - offsetX, y - offsetY, scaledWidth * progress, scaledHeight)

    love.graphics.setColor(1, 1, 1) -- border
    love.graphics.rectangle("line", x - offsetX, y - offsetY, scaledWidth, scaledHeight)

    love.graphics.setColor(1, 1, 1) -- reset color
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
        drawProgressBar(posX, posY, width, height, progress, skill.scale)
        love.graphics.print(skill.name .. " Lvl " .. skill.level, posX, posY + height + 5)
        i = i + 1
    end
end

return Skills
