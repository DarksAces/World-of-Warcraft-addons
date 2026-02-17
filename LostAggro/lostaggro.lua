local frame = CreateFrame("Frame")
local lostAggroHistory = {}

-- Función para mostrar mensaje tipo toast sin fondo negro
local function ShowToast(message)
    if not LostAggroToast then
        local toast = CreateFrame("Frame", "LostAggroToast", UIParent)
        toast:SetSize(350, 50)
        toast:SetPoint("TOP", UIParent, "TOP", 0, -100)
        -- No fondo negro, solo texto

        toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        toast.text:SetPoint("CENTER", toast, "CENTER", 0, 0)
        toast.text:SetTextColor(1, 0.82, 0, 1) -- color dorado

        toast:Hide()
        toast.fadeOut = nil

        toast:SetScript("OnUpdate", function(self, elapsed)
            if self.fadeOut then
                self.fadeOut = self.fadeOut - elapsed
                if self.fadeOut <= 0 then
                    self:Hide()
                    self.fadeOut = nil
                end
            end
        end)

        LostAggroToast = toast
    end

    LostAggroToast.text:SetText(message)
    LostAggroToast:Show()
    LostAggroToast.fadeOut = 5 -- duración 5 segundos
end

local currentTargetMob = nil
local hadAggro = false

-- Función para encontrar quién tiene el agro ahora
local function FindNewAggroHolder()
    if not UnitExists("target") then 
        return "Desconocido"
    end
    
    local function CheckUnitThreat(unit)
        if UnitExists(unit) then
            local isTanking = UnitDetailedThreatSituation(unit, "target")
            if isTanking then
                return UnitName(unit)
            end
        end
        return nil
    end

    -- Verificar jugador
    local playerName = CheckUnitThreat("player")
    if playerName then return playerName end
    
    -- Verificar mascota del jugador
    if UnitExists("pet") then
        local petName = CheckUnitThreat("pet")
        if petName then return petName end
    end

    -- Si está en raid
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = CheckUnitThreat("raid"..i)
            if name then return name end
            
            if UnitExists("raidpet"..i) then
                name = CheckUnitThreat("raidpet"..i)
                if name then return name end
            end
        end
    else
        -- Si está en party
        for i = 1, GetNumGroupMembers() - 1 do
            local name = CheckUnitThreat("party"..i)
            if name then return name end
            
            if UnitExists("partypet"..i) then
                name = CheckUnitThreat("partypet"..i)
                if name then return name end
            end
        end
    end

    return "Desconocido"
end

-- Frases para el mensaje (puedes añadir más)
local phrases = {
    "%s ya no está aggro. Ahora el agro es para %s.",
    "¡Pérdida de agro! %s ahora apunta a %s.",
    "%s te ha quitado el agro. ¡Cuidado!",
}

-- Función para obtener frase aleatoria
local function LostAggro_GetRandomPhrase(mobName, newTargetName)
    local phrase = phrases[math.random(#phrases)]
    return string.format(phrase, mobName, newTargetName)
end

-- Registrar eventos
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        currentTargetMob = nil
        hadAggro = false
        lostAggroHistory = {}
    elseif event == "PLAYER_TARGET_CHANGED" then
        local target = "target"
        if UnitExists(target) and UnitCanAttack("player", target) then
            currentTargetMob = UnitGUID(target)
            local isTanking = UnitDetailedThreatSituation("player", target)
            hadAggro = isTanking or false
        else
            currentTargetMob = nil
            hadAggro = false
        end
    elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
        local unit = select(1, ...)
        if unit == "player" and currentTargetMob and UnitExists("target") then
            local targetGUID = UnitGUID("target")
            if targetGUID == currentTargetMob then
                local isTanking = UnitDetailedThreatSituation("player", "target")
                local currentlyHasAggro = isTanking or false

                if hadAggro and not currentlyHasAggro then
                    -- Perdí el agro
                    local newTankName = FindNewAggroHolder()
                    local mobName = UnitName("target") or "Desconocido"
                    local msg = LostAggro_GetRandomPhrase(mobName, newTankName)
                    print("|cff00ffff[LostAggro!]|r "..msg)
                    ShowToast(msg)

                    lostAggroHistory[#lostAggroHistory + 1] = {mob = mobName, newTarget = newTankName}
                end

                hadAggro = currentlyHasAggro
            end
        end
    end
end)

-- Comando para mostrar historial de pérdidas de agro
SLASH_LOSTAGGRO1 = "/lostaggro"
SlashCmdList["LOSTAGGRO"] = function()
    if #lostAggroHistory == 0 then
        print("|cff00ffff[LostAggro!]|r No has perdido agro aún.")
    else
        print("|cff00ffff[LostAggro!]|r Historial de pérdidas de agro:")
        for i, entry in ipairs(lostAggroHistory) do
            print(string.format("%d) %s → %s", i, entry.mob, entry.newTarget))
        end
    end
end

--[[ TEST TEMPORAL PARA DEBUGGING (Opcional)
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
f:SetScript("OnEvent", function()
    local threat = UnitDetailedThreatSituation("player", "target")
    if threat == nil or type(threat) ~= "number" then return end
    if threat < 3 then
        local msg = "¡Has perdido el agro! (test)"
        print("|cff00ffff[LostAggro!]|r " .. msg)

        local toast = CreateFrame("Frame", "LostAggroToastTest", UIParent)
        toast:SetSize(300, 40)
        toast:SetPoint("CENTER")
        local text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        text:SetPoint("CENTER")
        text:SetText(msg)
        toast:Show()
        C_Timer.After(5, function() toast:Hide() end)
    end
end)
--]]

