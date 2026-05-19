local _, ns = ...
ns.Drawing = {}

ns.Drawing.linePool = {}
ns.Drawing.ripplePool = {}
ns.Drawing.sparklePool = {}
ns.Drawing.auraTexture = nil

local ParentFrame = CreateFrame("Frame", "CursorTrailCanvas", UIParent)
ParentFrame:SetFrameStrata("TOOLTIP")

function ns.Drawing.GetLine()
    local line = next(ns.Drawing.linePool)
    if line then
        ns.Drawing.linePool[line] = nil
        return line
    end
    local tex = ParentFrame:CreateTexture(nil, "OVERLAY")
    tex:SetBlendMode("ADD")
    tex:Hide()
    return tex
end

function ns.Drawing.ReleaseLine(line)
    line:Hide()
    line:ClearAllPoints()
    ns.Drawing.linePool[line] = true
end

function ns.Drawing.GetRipple()
    local tex = next(ns.Drawing.ripplePool)
    if tex then
        ns.Drawing.ripplePool[tex] = nil
        return tex
    end
    local tex2 = ParentFrame:CreateTexture(nil, "OVERLAY")
    tex2:SetTexture("Interface\\Cooldown\\star4")
    tex2:SetBlendMode("ADD")
    tex2:Hide()
    return tex2
end

function ns.Drawing.ReleaseRipple(tex)
    tex:Hide()
    tex:ClearAllPoints()
    ns.Drawing.ripplePool[tex] = true
end

function ns.Drawing.GetSparkle()
    local tex = next(ns.Drawing.sparklePool)
    if tex then
        ns.Drawing.sparklePool[tex] = nil
        return tex
    end
    local tex2 = ParentFrame:CreateTexture(nil, "OVERLAY")
    tex2:SetTexture("Interface\\COMMON\\Indicator-White")
    tex2:SetBlendMode("ADD")
    tex2:Hide()
    return tex2
end

function ns.Drawing.ReleaseSparkle(tex)
    tex:Hide()
    tex:ClearAllPoints()
    ns.Drawing.sparklePool[tex] = true
end

function ns.Drawing.GetAura()
    if not ns.Drawing.auraTexture then
        local tex = ParentFrame:CreateTexture(nil, "OVERLAY")
        tex:SetTexture("Interface\\Cooldown\\Ping_Circle")
        tex:SetBlendMode("ADD")
        tex:Hide()
        ns.Drawing.auraTexture = tex
    end
    return ns.Drawing.auraTexture
end
