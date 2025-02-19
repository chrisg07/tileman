local Upgrade = {}
Upgrade.__index = Upgrade

-- new() takes:
--   name: the upgrade's name
--   cost: the cost to purchase the upgrade
--   description: a string describing the upgrade
--   applyFunction: a function that will be executed when the upgrade is purchased;
--                  it can modify the game state as needed.
function Upgrade:new(name, cost, description, applyFunction)
    local self = setmetatable({}, Upgrade)
    self.name = name
    self.cost = cost
    self.description = description
    self.apply = applyFunction or function(state) end
    self.purchased = false
    return self
end

-- purchase() checks if the upgrade can be purchased, subtracts the cost,
-- applies the upgrade's side effects, and marks it as purchased.
function Upgrade:purchase(state)
    if self.purchased then
        print("Upgrade already purchased: " .. self.name)
        return false
    end

    if state.stats:get("currency").amount and state.stats:get("currency").amount >= self.cost then
        state.stats:get("currency").amount = state.stats:get("currency").amount - self.cost
        self.apply(state)  -- Execute the side effects.
        self.purchased = true
        print("Purchased upgrade: " .. self.name)
        return true
    else
        print("Not enough currency for " .. self.name)
        return false
    end
end

return Upgrade
