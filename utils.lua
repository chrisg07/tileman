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

return Utils