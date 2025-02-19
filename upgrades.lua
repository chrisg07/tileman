local Upgrade = require("upgrade")  

local Upgrades = {}

Upgrades.list = {
    doubleXP = Upgrade:new(
        "Double XP Multiplier",
        1,
        "Gain twice as much experience",
        function(state)
            state.stats:get("experience").multiplier = state.stats:get("experience").multiplier * 2
        end
    ),
    fasterMove = Upgrade:new(
        "Faster Movement",
        75,
        "Reduce move delay by 50%",
        function(state)
            state.moveSpeed = state.moveSpeed * 0.5
        end
    ),
    -- Add additional upgrades as needed.
}

function Upgrades:getAll()
    return self.list
end

function Upgrades:get(name)
    return self.list[name]
end

return Upgrades
