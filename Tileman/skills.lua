local Skill = require "Tileman.skill"
local Skills = {}
Skills.__index = Skills

function Skills:new()
    local self = setmetatable({}, Skills)
    self.skills = {
        {name = "knowledge", skill = Skill:new("knowledge", 0, 0, 10)},
        {name = "exploration", skill = Skill:new("exploration", 0, 0, 100)},
        {name = "woodcutting", skill = Skill:new("woodcutting", 0, 0, 100)},
        {name = "mining", skill = Skill:new("mining", 0, 0, 100)},
    }
    return self
end

function Skills:addXP(skillName, amount)
    if self:get(skillName) then
        self:get(skillName):addXP(amount)
        print("Gained " .. amount .. " experience in " .. skillName)
    else
        print("Skill '" .. skillName .. "' does not exist!")
    end
end

function Skills:get(skillName)
    for _, skillEntry in ipairs(self.skills) do
        if skillEntry.name == skillName then
            return skillEntry.skill
        end
    end
    return nil -- Return nil if the skill is not found
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



-- Draw all the progress bars for the skills.
-- Parameters:
--   x, y: starting position
--   width, height: size of each progress bar
--   spacing: vertical space between bars
function Skills:drawProgressBars(x, y, width, height, spacing)
    for i, skillEntry in ipairs(self.skills) do
        local skill = skillEntry.skill
        local posX = x
        local posY = y + (i-1) * (height + spacing)
        local progress = skill:getProgress()
        drawProgressBar(posX, posY, width, height, progress, skill.scale)
        
        -- Center the skill name and level within the progress bar
        local skillInfo = string.format("%s Lvl %d", skill.name, skill.level)
        local skillInfoWidth = love.graphics.getFont():getWidth(skillInfo)
        local skillInfoX = posX + (width - skillInfoWidth) / 2
        love.graphics.print(skillInfo, skillInfoX, posY + (height - love.graphics.getFont():getHeight()) + 35 / 2)
        
        -- Center the XP text within the progress bar
        local skillXP = string.format("%d/%d", skill.xp, skill.xpNeeded)
        local skillXPWidth = love.graphics.getFont():getWidth(skillXP)
        local skillXPX = posX + (width - skillXPWidth) / 2
        love.graphics.print(skillXP, skillXPX, posY + (height - love.graphics.getFont():getHeight()) / 2)
    end
end

return Skills
