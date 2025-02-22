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
    local startX, startY = self.x, self.y
    local buttonWidth, buttonHeight = 100, 25
    local textMargin = 10         -- margin from left for text
    local buttonMargin = 50       -- margin from right edge for button
    local spacing = 5
    local yOffset = 0

    for key, upgrade in pairs(self.upgrades) do
        local upgradeText = string.format("%s (%d)", upgrade.name, upgrade.cost)
        love.graphics.print(upgradeText, startX + textMargin, startY + yOffset + (buttonHeight - love.graphics.getFont():getHeight()) / 2)

        local currentCurrency = self.state.stats:get("currency").amount
        local isDisabled = currentCurrency < upgrade.cost
        local buttonX = startX + self.width + buttonWidth + buttonMargin

        if isDisabled then
            -- Draw a disabled button (a grey rectangle with centered text)
            love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
            love.graphics.rectangle("fill", buttonX, startY + yOffset, buttonWidth, buttonHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Purchase", buttonX, startY + yOffset + (buttonHeight - love.graphics.getFont():getHeight())/2, buttonWidth, "center")
        else
            local btn = suit.Button("Purchase", {id = key}, buttonX, startY + yOffset, buttonWidth, buttonHeight)
            if btn.hit then
                upgrade:purchase(self.state)
            end
        end

        yOffset = yOffset + buttonHeight + spacing
    end
end


return UpgradesList
