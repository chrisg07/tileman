-- menu.lua
local Menu = {}
Menu.__index = Menu

local suit = require "suit"

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
    suit.layout:reset(0, 0)

    -- Draw buttons for each property
    for i, property in ipairs(self.properties) do
        if suit.Button(property .. ": " .. self.state[property], suit.layout:row(200, 25)).hit then
            self.state[property] = (self.state[property] or 0) + 1
        end
    end
end

return Menu
