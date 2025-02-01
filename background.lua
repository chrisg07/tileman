-- background.lua
local Background = {}
Background.__index = Background

function Background:new()
    local self = setmetatable({}, Background)

    -- Load the Voronoi shader
    self.shader = love.graphics.newShader("voronoi.frag")

    -- Set shader resolution
    local screenWidth, screenHeight = love.graphics.getDimensions()
    self.shader:send("u_resolution", { screenWidth, screenHeight })

    return self
end

function Background:update(dt)
    -- Update shader time for animation
    self.shader:send("u_time", love.timer.getTime())
end

function Background:draw()
    -- Enable alpha blending
    love.graphics.setBlendMode("alpha")

    -- Draw the shader
    love.graphics.setShader(self.shader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()

    -- Reset blend mode (optional)
    love.graphics.setBlendMode("alpha")
end

return Background
