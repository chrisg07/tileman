local Utils = {}
Utils.__index = Utils

function Utils.getTriangleVertices(x, y, size, scale)
    local scaledSize = size * scale
    local halfScaledSize = scaledSize / 2
    local padding = (size - scaledSize) / 2
    return {
        x + padding + halfScaledSize, y + padding,
        x + padding, y + padding + scaledSize,
        x + padding + scaledSize, y + padding + scaledSize,
    }
end

function Utils.pointInTriangle(px, py, vertices)
    local x1, y1 = vertices[1], vertices[2]
    local x2, y2 = vertices[3], vertices[4]
    local x3, y3 = vertices[5], vertices[6]
    
    -- Compute denominator of barycentric coordinates.
    local denominator = ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3))
    if denominator == 0 then
        return false  -- Degenerate triangle.
    end
    
    local a = ((y2 - y3) * (px - x3) + (x3 - x2) * (py - y3)) / denominator
    local b = ((y3 - y1) * (px - x3) + (x1 - x3) * (py - y3)) / denominator
    local c = 1 - a - b
    
    local inTriangle = (a >= 0) and (b >= 0) and (c >= 0)

    print("Point (" .. px .. "," .. py .. ") is in triangle", inTriangle)
    return inTriangle
end

function Utils.offsetVertices(vertices, camera)
    local offsetVerts = {}
    for i, coord in ipairs(vertices) do
        if i % 2 == 1 then
            table.insert(offsetVerts, coord - camera.x)
        else
            table.insert(offsetVerts, coord - camera.y)
        end
    end
    return offsetVerts
end

return Utils