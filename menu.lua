-- menu.lua
local Menu = {}
Menu.__index = Menu

local buttonX, buttonY, buttonWidth, buttonHeight = 100, 100, 200, 50

function Menu:new(state)
    return setmetatable({ state = state }, self)
end

function Menu:mousepressed(x, y, button)
    if button == 1 and x > buttonX and x < buttonX + buttonWidth and y > buttonY and y < buttonY + buttonHeight then
        self.state:incrementCounter() -- Increment the counter on button click
    end
end

function Menu:draw()
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Click me: " .. self.state:getCounter(), buttonX + 10, buttonY + 15)
end

return Menu
