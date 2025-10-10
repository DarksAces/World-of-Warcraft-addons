local addonName = "BetterProfessionXP"
local f = CreateFrame("Frame")
local enabled = true
local debug = false
local lastSkillXP = {}

local function ShowProfXP(amount, skill)
    local msg = "+"..amount.." "..skill
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0, 0.6, 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0, 0.6, 1, 53, 3)
    end
end

local function CheckProfessionXP()
    if not enabled then return end
    
    -- Obtener información de profesiones (API moderna de WoW)
    local prof1, prof2 = GetProfessions()
    local professions = {}
    
    if prof1 then table.insert(professions, prof1) end
    if prof2 then table.insert(professions, prof2) end
    
    for _, profIndex in ipairs(professions) do
        local name, _, skillLevel, skillMaxLevel, _, _, skillLineID = GetProfessionInfo(profIndex)
        
        if name and skillLineID then
            -- Clave única para cada profesión
            local key = skillLineID
            
            if debug then
                print("|cff00ff00[DEBUG]|r Prof: " .. name .. " | Nivel: " .. skillLevel .. "/" .. skillMaxLevel .. " | Anterior: " .. tostring(lastSkillXP[key]))
            end
            
            -- Si tenemos un valor anterior, calcular ganancia
            if lastSkillXP[key] then
                local gain = skillLevel - lastSkillXP[key]
                if gain > 0 then
                    ShowProfXP(gain, name)
                end
            end
            
            -- Actualizar valor guardado
            lastSkillXP[key] = skillLevel
        end
    end
end

-- Eventos relevantes para profesiones
f:RegisterEvent("TRADE_SKILL_UPDATE")
f:RegisterEvent("SKILL_LINES_CHANGED")
f:RegisterEvent("CHAT_MSG_SKILL")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Inicializar valores al entrar
        C_Timer.After(1, CheckProfessionXP)
    elseif event == "CHAT_MSG_SKILL" then
        -- Mensaje del chat cuando subes skill
        local msg = ...
        if debug then
            print("|cff00ff00[DEBUG CHAT]|r " .. tostring(msg))
        end
        CheckProfessionXP()
    else
        -- Otros eventos de profesión
        CheckProfessionXP()
    end
end)

-- Inicializar al cargar
f:RegisterEvent("PLAYER_ENTERING_WORLD")

SLASH_PROFTEXT1 = "/proftext"
SlashCmdList["PROFTEXT"] = function(msg)
    msg = msg:lower()
    if msg == "off" then 
        enabled = false
        print("|cffff8800[BetterProfessionXP]|r Desactivado")
    elseif msg == "on" then 
        enabled = true
        print("|cff88ff00[BetterProfessionXP]|r Activado")
    elseif msg == "debug" then
        debug = not debug
        print("|cff00ffff[BetterProfessionXP]|r Debug: " .. (debug and "ON" or "OFF"))
    elseif msg == "reset" then
        lastSkillXP = {}
        CheckProfessionXP()
        print("|cffff00ff[BetterProfessionXP]|r Valores reseteados")
    elseif msg == "check" then
        print("|cff00ffff[BetterProfessionXP]|r Profesiones actuales:")
        CheckProfessionXP()
    else 
        print("|cffffff00Uso:|r /proftext on | off | debug | reset | check") 
    end
end