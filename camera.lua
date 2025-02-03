-- camera.lua
local Camera = {}
Camera.__index = Camera

function Camera:new(x, y)
    local self = setmetatable({}, Camera)
    self.x = x or 0
    self.y = y or 0
    return self
end

-- Sets the camera's position.
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Applies the camera transformation.
function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

-- Resets the transformation.
function Camera:reset()
    love.graphics.pop()
end

return Camera
