local _, ns = ...
ns.Utils = {}

function ns.Utils.CalculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function ns.Utils.CalculateAngle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function ns.Utils.GetRainbowColor(hue)
    -- Simple HSV to RGB conversion
    local h = hue % 1
    local r, g, b
    if h < 1/6 then r, g, b = 1, h*6, 0
    elseif h < 2/6 then r, g, b = (2/6-h)*6, 1, 0
    elseif h < 3/6 then r, g, b = 0, 1, (h-2/6)*6
    elseif h < 4/6 then r, g, b = 0, (4/6-h)*6, 1
    elseif h < 5/6 then r, g, b = (h-4/6)*6, 0, 1
    else r, g, b = 1, 0, (1-h)*6 end
    return r, g, b
end

function ns.Utils.GetCurrentColor(alpha, hue)
    if CursorTrailDB.classColor then
        local _, class = UnitClass("player")
        local color = C_ClassColor.GetClassColor(class)
        if color then
            return color.r, color.g, color.b, CursorTrailDB.color.a * (alpha or 1)
        end
    end
    
    if CursorTrailDB.rainbow then
        local r, g, b = ns.Utils.GetRainbowColor(hue or 0)
        return r, g, b, CursorTrailDB.color.a * (alpha or 1)
    end
    
    return CursorTrailDB.color.r, CursorTrailDB.color.g, CursorTrailDB.color.b, CursorTrailDB.color.a * (alpha or 1)
end
