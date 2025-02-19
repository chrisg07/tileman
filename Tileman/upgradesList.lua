-- upgradeslist.lua
local suit = require "suit"
local flux = require "flux.flux"
local Upgrades = require("Tileman.upgrades") -- Your upgrades module containing a table 'list'
local UpgradesList = {}
UpgradesList.__index = UpgradesList

-- Create a new upgrades list.
-- x,y: top-left position of the list on the screen.
-- width, height: the visible region of the upgrades list.
function UpgradesList:new(state, x, y, width, height)
    local self = setmetatable({}, UpgradesList)
    self.state = state
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.scroll = 0
    self.upgrades = Upgrades.list
    return self
end

-- Call this from love.wheelmoved to adjust the scroll.
function UpgradesList:wheelmoved(dx, dy)
    -- Adjust the scroll offset. (You might want to clamp it later.)
    self.scroll = self.scroll - dy * 20  -- Adjust speed as needed.
end

function UpgradesList:update(dt)
    -- You might add additional update logic here if needed.
end

function UpgradesList:draw()
    -- Set a scissor region so that only the upgrades list region is visible.
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    love.graphics.push()
    -- Translate by the scroll offset.
    love.graphics.translate(self.x, self.y - self.scroll)
    
    local buttonWidth, buttonHeight = self.width, 25
    local spacing = 5
    local yOffset = 0

    for key, upgrade in pairs(self.upgrades) do
        local btn = suit.Button(upgrade.name .. " (" .. upgrade.cost .. ")", 0, yOffset, buttonWidth, buttonHeight)
        if btn.hit then
            upgrade:purchase(self.state)
            -- if upgrade:purchase(self.state) then
            --     flux.to(upgrade, 0.3, { scale = 1.2 })
            --         :ease("quadout")
            --         :oncomplete(function() flux.to(upgrade, 0.3, { scale = 1 }) end)
            -- end
        end
        yOffset = yOffset + buttonHeight + spacing
    end

    love.graphics.pop()
    love.graphics.setScissor()  -- Clear the scissor region.
end

return UpgradesList
