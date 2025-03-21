local Pathfinding = {}

-- Heuristic: Manhattan distance.
local function heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

-- Returns neighbors that are within grid bounds (including undiscovered ones).
local function getNeighbors(node, grid)
    local neighbors = {}
    local dirs = { {1,0}, {-1,0}, {0,1}, {0,-1} }
    for _, d in ipairs(dirs) do
        local nx, ny = node.x + d[1], node.y + d[2]
        local key = nx .. "," .. ny
        if grid.tiles[key] then  -- only consider neighbors that exist in grid.tiles
            table.insert(neighbors, { x = nx, y = ny })
        end
    end
    return neighbors
end


-- Reconstructs the path from the cameFrom table.
local function reconstructPath(cameFrom, current)
    local path = { current }
    local function hash(n) return n.x .. "," .. n.y end
    while cameFrom[hash(current)] do
        current = cameFrom[hash(current)]
        table.insert(path, 1, current)
    end
    return path
end

-- findPath returns a list of nodes (each with x and y) from start to goal.
-- This version penalizes stepping into undiscovered tiles.
function Pathfinding.findPath(grid, startX, startY, goalX, goalY)
    local start = { x = startX, y = startY }
    local goal  = { x = goalX, y = goalY }

    local openSet     = {}       -- List of nodes to evaluate.
    local openSetHash = {}       -- For quick lookup.
    local cameFrom    = {}       -- For reconstructing the path.
    local penalty = 5            -- Extra cost for stepping on an undiscovered tile.

    local function hash(node)
        return node.x .. "," .. node.y
    end

    start.g = 0
    start.h = heuristic(start.x, start.y, goal.x, goal.y)
    start.f = start.g + start.h
    table.insert(openSet, start)
    openSetHash[hash(start)] = start

    local closedSet = {}

    while #openSet > 0 do
        -- Get the node with the lowest f score.
        table.sort(openSet, function(a, b) return a.f < b.f end)
        local current = table.remove(openSet, 1)
        openSetHash[hash(current)] = nil

        if current.x == goal.x and current.y == goal.y then
            return reconstructPath(cameFrom, current)
        end

        closedSet[hash(current)] = true

        local neighbors = getNeighbors(current, grid)
        for _, neighbor in ipairs(neighbors) do
            local neighborKey = neighbor.x .. "," .. neighbor.y
            if not closedSet[neighborKey] then
                -- Base movement cost is 1.
                local cost = 1
                -- If the neighbor tile exists and is not visited, add a penalty.
                if grid.tiles[neighborKey] and not grid.tiles[neighborKey].visited then
                    cost = cost + penalty
                end

                local tentative_g = current.g + cost

                local neighborNode = openSetHash[neighborKey] or neighbor

                if (not openSetHash[neighborKey]) or (tentative_g < neighborNode.g) then
                    neighborNode.g = tentative_g
                    neighborNode.h = heuristic(neighborNode.x, neighborNode.y, goal.x, goal.y)
                    neighborNode.f = neighborNode.g + neighborNode.h
                    cameFrom[neighborKey] = current

                    if not openSetHash[neighborKey] then
                        table.insert(openSet, neighborNode)
                        openSetHash[neighborKey] = neighborNode
                    end
                end
            end
        end
    end

    return nil -- No valid path found.
end

return Pathfinding
