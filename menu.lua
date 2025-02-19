-- menu.lua
local Menu = {}
Menu.__index = Menu

local suit = require "suit"

function Menu:new(state, properties)
    return setmetatable({
        state = state,
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

    local menuButtonWidth = 125
    if self.visible then
        if suit.Button("Close Menu", suit.layout:col(menuButtonWidth, 25)).hit then
            self:toggle()
        end

        if suit.Button("Show Skills", suit.layout:col(menuButtonWidth, 25)).hit then
            self.state.showSkills = not self.state.showSkills
            self.state.showStats = false
            self.state.showUpgrades = false
        end

        if suit.Button("Show Stats", suit.layout:col(menuButtonWidth, 25)).hit then
            self.state.showStats = not self.state.showStats
            self.state.showSkills = false
            self.state.showUpgrades = false
        end

        if suit.Button("Show Upgrades", suit.layout:col(menuButtonWidth, 25)).hit then
            self.state.showUpgrades = not self.state.showUpgrades
            self.state.showSkills = false
            self.state.showStats = false
        end
        
        -- suit.layout:reset(0, 25)

        -- for i, stat in pairs(self.state.stats.stats) do
        --     if suit.Button(stat.name .. ": " .. stat.amount, suit.layout:row(menuButtonWidth, 25)).hit then
        --         stat:add(1)
        --     end
        -- end
    else
        if suit.Button("Open Menu", suit.layout:row(menuButtonWidth, 25)).hit then
            self:toggle()
        end
    end
end


function Menu:draw()
end

return Menu
