-- menu.lua
local Menu = {}
Menu.__index = Menu

local suit = require "suit"

function Menu:new(state, properties)
    return setmetatable({
        state = state,
        properties = properties or {},
        visible = true,
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
        if suit.Button("Close Menu", suit.layout:col(200, 25)).hit then
            self:toggle()
        end

        for i, property in ipairs(self.properties) do
            if property == "tiles" then
                local x, y, w, h = suit.layout:row(200, 25)
                local btn = suit.Button(property .. ": " .. self.state[property], x, y, w, h)
                if btn.hit then
                    self.state[property] = (self.state[property] or 0) + 1
                end
        
                -- Define a maximum value for progress (adjust as needed).
                local maxTiles = 100
                local progress = math.min(self.state[property] / maxTiles, 1)
        
                -- Draw the progress background over the button.
                love.graphics.setColor(0.1, 0.8, 0.1, 0.5)
                love.graphics.rectangle("fill", x, y, w * progress, h)
                love.graphics.setColor(1, 1, 1)
            else
                if suit.Button(property .. ": " .. self.state[property], suit.layout:row(200, 25)).hit then
                    self.state[property] = (self.state[property] or 0) + 1
                end
            end
        end
        
    else
        if suit.Button("Open Menu", suit.layout:row(200, 25)).hit then
            self:toggle()
        end
    end
end


function Menu:draw()
end

return Menu
