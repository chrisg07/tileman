-- skills.lua
local Skill = require "skill"
local Skills = {}
Skills.__index = Skills

function Skills:new()
    local self = setmetatable({}, Skills)
    -- Initialize your skills here. You can add as many as you need.
    self.skills = {
        mining = Skill:new("mining", 0, 1, 100),
        woodcutting = Skill:new("woodcutting", 0, 1, 100),
        exploration = Skill:new("exploration", 0, 1, 100),
        combat = Skill:new("combat", 0, 1, 100)
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

-- Get a reference to a skill (for example, to display its level or progress).
function Skills:get(skillName)
    return self.skills[skillName]
end

return Skills
