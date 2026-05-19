local ADDON_NAME, ns = ...
ns.Core = {}

ns.Core.Frame = CreateFrame("Frame")
ns.Core.hideConditions = {}

function ns.Core.CheckCombatState()
    local inCombat = InCombatLockdown()
    local mode = CursorTrailDB and CursorTrailDB.combatMode or 1
    
    ns.Core.hideConditions["combat_mode"] = nil
    
    if mode == 2 and not inCombat then -- Combat Only
        ns.Core.hideConditions["combat_mode"] = true
    elseif mode == 3 and inCombat then -- Non-Combat Only
        ns.Core.hideConditions["combat_mode"] = true
    end
end

ns.Core.Frame:RegisterEvent("ADDON_LOADED")
ns.Core.Frame:RegisterEvent("CINEMATIC_START")
ns.Core.Frame:RegisterEvent("CINEMATIC_STOP")
ns.Core.Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
ns.Core.Frame:RegisterEvent("PLAYER_REGEN_ENABLED")

ns.Core.Frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if not CursorTrailDB then
            CursorTrailDB = CopyTable(ns.Config.defaults)
        else
            for k, v in pairs(ns.Config.defaults) do
                if CursorTrailDB[k] == nil then
                    CursorTrailDB[k] = v
                end
            end
            if CursorTrailDB.glow == true then
                CursorTrailDB.texture = "glow"
                CursorTrailDB.glow = nil
            end
        end
        self:UnregisterEvent("ADDON_LOADED")
        ns.Config.SetupSlashCommands()
        print("|cff00ccffCursorTrail|r: Loaded! |cffffee00/ctrail|r for options.")
        
    elseif event == "CINEMATIC_START" then
        ns.Core.hideConditions["cinematic"] = true
    elseif event == "CINEMATIC_STOP" then
        ns.Core.hideConditions["cinematic"] = nil
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        ns.Core.CheckCombatState()
    end
end)

hooksecurefunc("Screenshot", function()
    ns.Core.hideConditions["screenshot"] = true
    C_Timer.After(0.5, function() ns.Core.hideConditions["screenshot"] = nil end)
end)