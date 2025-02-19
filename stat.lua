local Stat = {}
Stat.__index = Stat

local flux = require "flux.flux"

function Stat:new(state, name, amount, max)
    local self = setmetatable({}, Stat)
    self.state = state
    self.name = name or "unknown"
    self.amount = amount or 1
    self.max = max or 100
    self.scale = 1 -- Normal scale
    self.multiplier = 1
    return self
end

function Stat:add(delta)
    delta = delta * self.multiplier
    local percentageChange = math.abs(delta) / self.max
    -- Adjust the multiplier factor to control the pulse intensity.
    local pulseMultiplier = 0.5 -- Change this to tweak the effect (0.5 means 50% additional scale at 100% gain)
    local targetScale = 1 + math.min(percentageChange, 1) * pulseMultiplier
    -- Tween the scale property to the target scale and back to 1.
    flux.to(self, 0.2, { scale = targetScale }):ease("quadout")
        :oncomplete(function()
            flux.to(self, 0.2, { scale = 1 }):ease("quadin")
        end)

    self.amount = self.amount + delta
    print(self.name .. " is now " .. self.amount)
end

function Stat:getPercent()
    return self.amount / self.max
end

return Stat
