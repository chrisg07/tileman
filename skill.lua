-- skill.lua
local Skill = {}
Skill.__index = Skill

local flux = require "flux.flux"

function Skill:new(name, xp, level, xpNeeded)
    local self = setmetatable({}, Skill)
    self.name = name or "unknown"
    self.xp = xp or 0
    self.level = level or 1
    self.xpNeeded = xpNeeded or 100
    self.scale = 1 -- For tweening (default no scaling)
    return self
end

function Skill:addXP(amount)
    self.xp = self.xp + amount

    -- Trigger a pulse tween: scale up to 1.2 then back to 1.
    flux.to(self, 0.2, { scale = 1.2 }):ease("quadout"):oncomplete(function()
        flux.to(self, 0.2, { scale = 1 }):ease("quadin")
    end)

    while self.xp >= self.xpNeeded do
        self.xp = self.xp - self.xpNeeded
        self.level = self.level + 1
        self.xpNeeded = math.floor(self.xpNeeded * 1.25)
        print(self.name .. " leveled up to " .. self.level .. "!")
    end
end

function Skill:getProgress()
    return self.xp / self.xpNeeded
end

return Skill
