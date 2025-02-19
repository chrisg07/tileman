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
    self.scale = 1 -- Normal scale
    return self
end

function Skill:addXP(amount)
    -- Calculate the percentage of the XP gain relative to the current threshold.
    local percentageGain = amount / self.xpNeeded
    -- For instance, if percentageGain is 0.5, that's a 50% gain relative to xpNeeded.
    -- Adjust the multiplier factor to control the pulse intensity.
    local pulseMultiplier = 0.5 -- Change this to tweak the effect (0.5 means 50% additional scale at 100% gain)
    local targetScale = 1 + math.min(percentageGain, 1) * pulseMultiplier
    -- Tween the scale property to the target scale and back to 1.
    flux.to(self, 0.2, { scale = targetScale }):ease("quadout")
        :oncomplete(function()
            flux.to(self, 0.2, { scale = 1 }):ease("quadin")
        end)

    -- Add the XP.
    self.xp = self.xp + amount
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
