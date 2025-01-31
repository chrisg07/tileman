-- menu.lua
local Menu = {}
Menu.__index = Menu

local suit = require "suit"

local buttonX, buttonY = 100, 100
local buttonWidth, buttonHeight = 200, 50
local buttonSpacing = 60 -- Spacing between buttons

function Menu:new(state, properties)
    return setmetatable({
        state = state,                 -- Reference to the state object
        properties = properties or {}, -- List of state properties to show
        visible = false,
        alpha = 0                      -- Start fully transparent
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

    -- Reset the layout position
    suit.layout:reset(100, 100)

    -- Draw buttons for each property
    for i, property in ipairs(self.properties) do
        if suit.Button(property .. ": " .. self.state[property], suit.layout:row(200, 50)).hit then
            self.state[property] = (self.state[property] or 0) + 1
        end
    end
end

function Menu:draw()
    -- if self.alpha <= 0 then
    --     return
    -- end

    -- -- Draw menu background
    -- love.graphics.setColor(0.1, 0.1, 0.1, 0.9 * self.alpha)
    -- love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, #self.properties * buttonSpacing, 10)

    -- -- Draw buttons for each property
    -- for i, property in ipairs(self.properties) do
    --     local y = buttonY + (i - 1) * buttonSpacing
    --     local value = self.state:get(property)                           -- Ensure it always reads the latest value
    --     print("Menu displaying " .. property .. ": " .. tostring(value)) -- Debugging

    --     -- Button background
    --     love.graphics.setColor(0.2, 0.2, 0.2, self.alpha)
    --     love.graphics.rectangle("fill", buttonX, y, buttonWidth, buttonHeight)

    --     -- Button text
    --     love.graphics.setColor(1, 1, 1, self.alpha)
    --     love.graphics.print(property .. ": " .. tostring(value), buttonX + 10, y + 15)
    -- end

    -- -- Draw close button
    -- local closeButtonX, closeButtonY = buttonX + buttonWidth - 30, buttonY - 30
    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.rectangle("fill", closeButtonX, closeButtonY, 20, 20)
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.print("X", closeButtonX + 5, closeButtonY + 5)
end

function Menu:mousepressed(x, y, button)
    if not self.visible then
        return
    end

    -- Check if close button is clicked
    local closeButtonX, closeButtonY = buttonX + buttonWidth - 30, buttonY - 30
    if button == 1 and x > closeButtonX and x < closeButtonX + 20 and y > closeButtonY and y < closeButtonY + 20 then
        self.visible = false
        return
    end

    -- Check if any state increment button is clicked
    for i, property in ipairs(self.properties) do
        local y = buttonY + (i - 1) * buttonSpacing
        if button == 1 and x > buttonX and x < buttonX + buttonWidth and y > y and y < y + buttonHeight then
            self.state[property] = (self.state[property] or 0) + 1
        end
    end
end

return Menu
