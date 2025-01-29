-- menu.lua
local Menu = {}
Menu.__index = Menu

local buttonX, buttonY, buttonWidth, buttonHeight = 100, 100, 200, 50

function Menu:new(state)
    return setmetatable({
        state = state,
        visible = false,
        alpha = 0 -- Start fully transparent
    }, self)
end

function Menu:toggle()
    self.visible = not self.visible -- Toggle visibility
end

function Menu:update(dt)
    if self.visible and self.alpha < 1 then
        self.alpha = math.min(self.alpha + dt * 4, 1) -- Fade in
    elseif not self.visible and self.alpha > 0 then
        self.alpha = math.max(self.alpha - dt * 4, 0) -- Fade out
    end
end

function Menu:draw()
    if self.alpha <= 0 then
        return
    end

    love.graphics.setColor(0.1, 0.1, 0.1, 0.9 * self.alpha)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.print("Click me: " .. self.state:getCounter(), buttonX + 10, buttonY + 15)

    -- Draw a close button
    local closeButtonX, closeButtonY = buttonX + buttonWidth - 30, buttonY + 10
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", closeButtonX, closeButtonY, 20, 20)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("X", closeButtonX + 5, closeButtonY + 5)
end

function Menu:mousepressed(x, y, button)
    if not self.visible then
        return
    end

    -- Check if the close button is clicked
    local closeButtonX, closeButtonY = buttonX + buttonWidth - 30, buttonY + 10
    if button == 1 and x > closeButtonX and x < closeButtonX + 20 and y > closeButtonY and y < closeButtonY + 20 then
        self.visible = false
        return
    end

    -- Check if the main button is clicked
    if button == 1 and x > buttonX and x < buttonX + buttonWidth and y > buttonY and y < buttonY + buttonHeight then
        self.state:incrementCounter()
    end
end

return Menu
