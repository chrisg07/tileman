-- skill.lua
local Skill = {}
Skill.__index = Skill

-- Constructor for a new skill.
-- name: the skill's name (e.g., "mining")
-- xp: starting XP (default 0)
-- level: starting level (default 1)
-- xpNeeded: XP needed to reach the next level (default 100)
function Skill:new(name, xp, level, xpNeeded)
    local self = setmetatable({}, Skill)
    self.name = name or "unknown"
    self.xp = xp or 0
    self.level = level or 1
    self.xpNeeded = xpNeeded or 100
    return self
end

-- Add XP to the skill and check for level up.
function Skill:addXP(amount)
    self.xp = self.xp + amount
    while self.xp >= self.xpNeeded do
        self.xp = self.xp - self.xpNeeded
        self.level = self.level + 1
        -- Increase XP required for next level. (This formula can be adjusted.)
        self.xpNeeded = math.floor(self.xpNeeded * 1.25)
        print(self.name .. " leveled up to " .. self.level .. "!")
    end
end

-- Return the progress fraction (0..1) toward the next level.
function Skill:getProgress()
    return self.xp / self.xpNeeded
end

return Skill
