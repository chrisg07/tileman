-- menu.lua
local Menu = {}
Menu.__index = Menu

local suit = require "suit"

function Menu:new(state, properties)
    return setmetatable({
        state = state,
        properties = properties or {},
        visible = false,
        alpha = 0
    }, self)
end

function Menu:toggle()
    self.visible = not self.visible
end

function Menu:update(dt)
    if self.visible and self.alpha < 1 then
        self.alpha = math.min(self.alpha + dt * 4, 1) -- Fade in
    elseif not self.visible and self.alpha > 0 then
        self.alpha = math.max(self.alpha - dt * 4, 0) -- Fade out
    end

    suit.layout:reset(0, 0)

    if self.visible then
        if suit.Button("Start Game", suit.layout:row(200, 25)).hit then
            self.state.mode = "game"
            self:toggle()
        end

        if suit.Button("Close Menu", suit.layout:row(200, 25)).hit then
            self:toggle()
        end

        for i, property in ipairs(self.properties) do
            if suit.Button(property .. ": " .. self.state[property], suit.layout:row(200, 25)).hit then
                self.state[property] = (self.state[property] or 0) + 1
            end
        end
    else
        if suit.Button("Open Menu", suit.layout:row(200, 25)).hit then
            self:toggle()
        end
    end
end

function Menu:draw()
    if self.visible then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9 * self.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
end

return Menu
