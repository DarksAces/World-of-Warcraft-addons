local _, ns = ...
ns.Effects = {}

local activeRipples = {}
local activeSparkles = {}
local trailPoints = {}
local trailLines = {}
local shadowLines = {}

local wasLeftDown = false
local wasRightDown = false

local lastUpdate = 0
local rainbowHue = 0
local idleTime = 0
local lastCursorX, lastCursorY = 0, 0
local auraRotation = 0

function ns.Effects.ClearTrail()
    for _, line in ipairs(trailLines) do ns.Drawing.ReleaseLine(line) end
    for _, line in ipairs(shadowLines) do ns.Drawing.ReleaseLine(line) end
    wipe(trailLines)
    wipe(shadowLines)
    wipe(trailPoints)
end

local function UpdateRipples(elapsed)
    for i = #activeRipples, 1, -1 do
        local ripple = activeRipples[i]
        ripple.age = ripple.age + elapsed
        
        if ripple.age >= ripple.maxAge then
            ns.Drawing.ReleaseRipple(ripple.texture)
            table.remove(activeRipples, i)
        else
            local progress = ripple.age / ripple.maxAge
            local size = ripple.startSize + (ripple.endSize - ripple.startSize) * math.pow(progress, 0.5)
            local alpha = 1 - progress
            
            ripple.texture:SetSize(size, size)
            ripple.texture:SetAlpha(alpha)
            ripple.texture:SetRotation(progress * math.pi)
        end
    end
end

local function UpdateSparkles(elapsed)
    for i = #activeSparkles, 1, -1 do
        local sparkle = activeSparkles[i]
        sparkle.age = sparkle.age + elapsed
        
        if sparkle.age >= sparkle.maxAge then
            ns.Drawing.ReleaseSparkle(sparkle.texture)
            table.remove(activeSparkles, i)
        else
            local progress = sparkle.age / sparkle.maxAge
            -- Move sparkle slightly down (gravity)
            sparkle.y = sparkle.y - (20 * elapsed)
            sparkle.texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", sparkle.x, sparkle.y)
            
            -- Flicker alpha
            local alpha = (1 - progress) * (0.5 + 0.5 * math.sin(sparkle.age * 20))
            sparkle.texture:SetAlpha(alpha)
            
            local size = sparkle.size * (1 - progress * 0.5)
            sparkle.texture:SetSize(size, size)
        end
    end
end

local function SpawnRipple(x, y)
    local r = ns.Drawing.GetRipple()
    local scale = UIParent:GetEffectiveScale()
    r:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)
    local r_col, g_col, b_col = ns.Utils.GetCurrentColor(1, rainbowHue)
    r:SetVertexColor(r_col, g_col, b_col, 1)
    r:Show()
    
    table.insert(activeRipples, {
        texture = r,
        age = 0,
        maxAge = 0.5,
        startSize = 10,
        endSize = 50
    })
    
    -- Sound Effect
    if CursorTrailDB.soundEffects then
        -- SOUNDKIT.UI_TOYBOX_MAGIC (id 43493) or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON (id 856)
        PlaySound(43493, "SFX", false)
    end
end

local function SpawnSparkle(x, y)
    if not CursorTrailDB.sparkles then return end
    if math.random() > 0.3 then return end -- 30% chance to spawn per segment
    
    local s = ns.Drawing.GetSparkle()
    local scale = UIParent:GetEffectiveScale()
    
    -- Add some random offset
    local ox = (math.random() - 0.5) * 15
    local oy = (math.random() - 0.5) * 15
    
    local sx, sy = x/scale + ox, y/scale + oy
    s:SetPoint("CENTER", UIParent, "BOTTOMLEFT", sx, sy)
    
    local r_col, g_col, b_col = ns.Utils.GetCurrentColor(1, rainbowHue)
    s:SetVertexColor(r_col, g_col, b_col, 1)
    s:Show()
    
    table.insert(activeSparkles, {
        texture = s,
        x = sx,
        y = sy,
        age = 0,
        maxAge = 0.8 + math.random() * 0.5,
        size = 4 + math.random() * 6
    })
end

local function CreateLineBetweenPoints(poolList, p1, p2, alpha, widthMult, isShadow)
    local line = ns.Drawing.GetLine()
    
    local distance = ns.Utils.CalculateDistance(p1.x, p1.y, p2.x, p2.y)
    local angle = ns.Utils.CalculateAngle(p1.x, p1.y, p2.x, p2.y)
    
    local centerX = (p1.x + p2.x) / 2
    local centerY = (p1.y + p2.y) / 2
    
    local texturePath = ns.Config.textureOptions[CursorTrailDB.texture] or ns.Config.textureOptions["solid"]
    if isShadow then
        texturePath = ns.Config.textureOptions["soft"] -- Shadows use soft texture
    end
    
    if texturePath == "Solid" then
       line:SetColorTexture(1, 1, 1, 1)
    else
       line:SetTexture(texturePath)
    end
    
    local width = CursorTrailDB.lineWidth * (widthMult or 1)
    if isShadow then
        width = width * 1.5 -- Shadows are wider
    end
    
    if CursorTrailDB.pulse and not isShadow then
        width = width * (0.8 + 0.4 * math.sin(GetTime() * 5))
    end
    
    line:SetSize(distance, width)
    line:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
    line:SetRotation(angle)
    
    local r, g, b, baseAlpha = ns.Utils.GetCurrentColor(1, rainbowHue)
    if isShadow then
        line:SetVertexColor(r * 0.5, g * 0.5, b * 0.5, alpha * baseAlpha * 0.3)
    else
        line:SetVertexColor(r, g, b, alpha * baseAlpha)
    end
    
    line:Show()
    table.insert(poolList, line)
end

function ns.Effects.OnUpdate(elapsed)
    UpdateRipples(elapsed)
    UpdateSparkles(elapsed)

    -- Mouse Click Detection
    if CursorTrailDB.clickEffects then
        local left = IsMouseButtonDown("LeftButton")
        local right = IsMouseButtonDown("RightButton")
        
        if left and not wasLeftDown then
            local x, y = GetCursorPosition()
            SpawnRipple(x, y)
        end
        if right and not wasRightDown then
            local x, y = GetCursorPosition()
            SpawnRipple(x, y)
        end
        
        wasLeftDown = left
        wasRightDown = right
    end

    if not CursorTrailDB.enabled or next(ns.Core.hideConditions) then 
        if #trailPoints > 0 then ns.Effects.ClearTrail() end
        local aura = ns.Drawing.GetAura()
        if aura then aura:Hide() end
        return 
    end
    
    if not ns.Core.hideConditions["combat_mode"] then
        ns.Core.CheckCombatState()
        if ns.Core.hideConditions["combat_mode"] then return end
    end
    
    lastUpdate = lastUpdate + elapsed
    rainbowHue = (rainbowHue + elapsed * 0.2) % 1
    
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    local scaledX, scaledY = x/scale, y/scale
    
    -- Idle Aura Logic
    if CursorTrailDB.idleAura then
        local distMoved = ns.Utils.CalculateDistance(scaledX, scaledY, lastCursorX, lastCursorY)
        if distMoved < 1 then
            idleTime = idleTime + elapsed
        else
            idleTime = 0
            ns.Drawing.GetAura():Hide()
        end
        
        lastCursorX, lastCursorY = scaledX, scaledY
        
        if idleTime > 1.5 then
            local aura = ns.Drawing.GetAura()
            auraRotation = auraRotation - elapsed * 2
            aura:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lastCursorX, lastCursorY)
            local r, g, b, a = ns.Utils.GetCurrentColor(1, rainbowHue)
            aura:SetVertexColor(r, g, b, math.min(1, (idleTime - 1.5)) * a * 0.6)
            aura:SetSize(40, 40)
            aura:SetRotation(auraRotation)
            aura:Show()
        end
    else
        ns.Drawing.GetAura():Hide()
    end
    
    if lastUpdate >= CursorTrailDB.updateRate then
        local shouldAdd = true
        if #trailPoints > 0 then
            local lastPoint = trailPoints[1]
            local distance = ns.Utils.CalculateDistance(lastPoint.x, lastPoint.y, scaledX, scaledY)
            if distance < CursorTrailDB.minDistance then
                shouldAdd = false
            end
        end
        
        if shouldAdd then
            for _, line in ipairs(trailLines) do ns.Drawing.ReleaseLine(line) end
            for _, line in ipairs(shadowLines) do ns.Drawing.ReleaseLine(line) end
            wipe(trailLines)
            wipe(shadowLines)
            
            table.insert(trailPoints, 1, {x = scaledX, y = scaledY, time = GetTime()})
            SpawnSparkle(x, y) -- Spawn sparkle at cursor position (unscaled for screen pos)
            
            local currentTime = GetTime()
            for i = #trailPoints, 1, -1 do
                if currentTime - trailPoints[i].time > CursorTrailDB.trailLength then
                    table.remove(trailPoints, i)
                end
            end
            
            while #trailPoints > CursorTrailDB.maxPoints do
                table.remove(trailPoints)
            end
            
            for i = 1, #trailPoints - 1 do
                local p1 = trailPoints[i]
                local p2 = trailPoints[i + 1]
                
                local age = (currentTime - p2.time) / CursorTrailDB.trailLength
                local alpha = 1 - age
                local widthMult = 1 - (age * 0.5)
                
                if alpha > 0.05 then
                    if CursorTrailDB.shadowTrail then
                        if trailPoints[i+2] then
                            CreateLineBetweenPoints(shadowLines, trailPoints[i+1], trailPoints[i+2], alpha * 0.5, widthMult, true)
                        end
                    end
                    CreateLineBetweenPoints(trailLines, p1, p2, alpha, widthMult, false)
                end
            end
        end
        
        lastUpdate = 0
    end
end

-- Link OnUpdate securely after creation
ns.Core.Frame:SetScript("OnUpdate", function(self, elapsed)
    ns.Effects.OnUpdate(elapsed)
end)
