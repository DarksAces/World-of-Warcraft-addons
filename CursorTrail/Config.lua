local _, ns = ...
ns.Config = {}

ns.Config.defaults = {
    enabled = true,
    maxPoints = 30,
    lineWidth = 4,
    trailLength = 1.5,
    color = {r = 0.2, g = 0.6, b = 1.0, a = 0.8},
    updateRate = 0.015,
    minDistance = 5,
    classColor = false,
    rainbow = false,
    pulse = false,
    texture = "solid",
    combatMode = 1,
    clickEffects = true,
    -- NEW SETTINGS
    soundEffects = true,
    sparkles = false,
    shadowTrail = false,
    idleAura = false,
}

ns.Config.namedColors = {
    ["red"]     = {1.0, 0.0, 0.0},
    ["green"]   = {0.0, 1.0, 0.0},
    ["blue"]    = {0.0, 0.0, 1.0},
    ["cyan"]    = {0.0, 1.0, 1.0},
    ["magenta"] = {1.0, 0.0, 1.0},
    ["yellow"]  = {1.0, 1.0, 0.0},
    ["white"]   = {1.0, 1.0, 1.0},
    ["black"]   = {0.0, 0.0, 0.0},
    ["orange"]  = {1.0, 0.5, 0.0},
    ["purple"]  = {0.6, 0.2, 0.8},
    ["pink"]    = {1.0, 0.4, 0.7},
    ["gold"]    = {1.0, 0.8, 0.0},
    ["teal"]    = {0.0, 0.5, 0.5},
}

ns.Config.textureOptions = {
    ["solid"] = "Solid",
    ["glow"]  = "Interface\\COMMON\\Indicator-Gray",
    ["soft"]  = "Interface\\COMMON\\Indicator-White",
    ["star"]  = "Interface\\Cooldown\\star4",
    ["spot"]  = "Interface\\COMMON\\Indicator-Yellow",
}

ns.Config.combatModes = {
    [1] = "Always",
    [2] = "Combat Only",
    [3] = "Out of Combat Only"
}

ns.Config.presets = {
    ["Electric Blue"] = { color={0.2, 0.6, 1.0, 0.9}, width=3, length=1.2, texture="glow", pulse=false, rainbow=false, sparkles=false, shadow=false, aura=true },
    ["Fire Trail"]    = { color={1.0, 0.4, 0.1, 0.8}, width=5, length=1.8, texture="soft", pulse=true, rainbow=false, sparkles=true, shadow=true, aura=false },
    ["Neon Green"]    = { color={0.2, 1.0, 0.3, 0.9}, width=4, length=1.5, texture="solid", pulse=false, rainbow=false, sparkles=false, shadow=false, aura=false },
    ["Rainbow Power"] = { color={1,1,1,1}, width=6, length=2.0, texture="star", pulse=true, rainbow=true, sparkles=true, shadow=false, aura=true },
    ["Classy"]        = { color={1,1,1,1}, width=4, length=1.5, texture="glow", pulse=false, classColor=true, sparkles=false, shadow=true, aura=false },
}

function ns.Config.ApplyPreset(name)
    local p = ns.Config.presets[name]
    if p then
        CursorTrailDB.color.r = p.color[1]
        CursorTrailDB.color.g = p.color[2]
        CursorTrailDB.color.b = p.color[3]
        CursorTrailDB.color.a = p.color[4] or 1
        CursorTrailDB.lineWidth = p.width
        CursorTrailDB.trailLength = p.length
        CursorTrailDB.texture = p.texture or "glow"
        CursorTrailDB.pulse = p.pulse
        CursorTrailDB.rainbow = p.rainbow
        CursorTrailDB.classColor = p.classColor or false
        CursorTrailDB.sparkles = p.sparkles or false
        CursorTrailDB.shadowTrail = p.shadow or false
        CursorTrailDB.idleAura = p.aura or false
        print("|cff00ccffCursorTrail|r: Applied preset " .. name)
    end
end

function ns.Config.SetupSlashCommands()
    SLASH_CURSORTRAIL1 = "/cursortrail"
    SLASH_CURSORTRAIL2 = "/ctrail"

    SlashCmdList.CURSORTRAIL = function(msg)
        local cmd, arg = msg:match("^(%S+)%s*(.-)$")
        cmd = cmd and cmd:lower() or ""
        
        if cmd == "" or cmd == "ui" or cmd == "panel" then
            if CursorTrailOptionsPanel and CursorTrailOptionsPanel:IsShown() then
                CursorTrailOptionsPanel:Hide()
            else
                if CursorTrailOptionsPanel then
                    CursorTrailOptionsPanel:Show()
                end
            end
        elseif cmd == "on" or cmd == "enable" then
            CursorTrailDB.enabled = true
            print("|cff00ccffCursorTrail|r: Enabled")
        elseif cmd == "off" or cmd == "disable" then
            CursorTrailDB.enabled = false
            print("|cff00ccffCursorTrail|r: Disabled")
        elseif cmd == "reset" then
            CursorTrailDB = CopyTable(ns.Config.defaults)
            ns.Effects.ClearTrail()
            print("|cff00ccffCursorTrail|r: Reset to defaults")
        
        elseif cmd == "combat" then
            CursorTrailDB.combatMode = CursorTrailDB.combatMode + 1
            if CursorTrailDB.combatMode > 3 then CursorTrailDB.combatMode = 1 end
            print("|cff00ccffCursorTrail|r: Combat Mode: " .. ns.Config.combatModes[CursorTrailDB.combatMode])
            ns.Core.CheckCombatState()
            
        elseif cmd == "click" or cmd == "ripple" then
            CursorTrailDB.clickEffects = not CursorTrailDB.clickEffects
            print("|cff00ccffCursorTrail|r: Click Effects " .. (CursorTrailDB.clickEffects and "ON" or "OFF"))
            
        elseif cmd == "sound" then
            CursorTrailDB.soundEffects = not CursorTrailDB.soundEffects
            print("|cff00ccffCursorTrail|r: Sound Effects " .. (CursorTrailDB.soundEffects and "ON" or "OFF"))

        elseif cmd == "sparkles" then
            CursorTrailDB.sparkles = not CursorTrailDB.sparkles
            print("|cff00ccffCursorTrail|r: Sparkles " .. (CursorTrailDB.sparkles and "ON" or "OFF"))

        elseif cmd == "shadow" then
            CursorTrailDB.shadowTrail = not CursorTrailDB.shadowTrail
            print("|cff00ccffCursorTrail|r: Shadow Trail " .. (CursorTrailDB.shadowTrail and "ON" or "OFF"))

        elseif cmd == "aura" then
            CursorTrailDB.idleAura = not CursorTrailDB.idleAura
            print("|cff00ccffCursorTrail|r: Idle Aura " .. (CursorTrailDB.idleAura and "ON" or "OFF"))
            
        elseif cmd == "class" then
            CursorTrailDB.classColor = not CursorTrailDB.classColor
            print("|cff00ccffCursorTrail|r: Class Color " .. (CursorTrailDB.classColor and "ON" or "OFF"))
        elseif cmd == "rainbow" then
            CursorTrailDB.rainbow = not CursorTrailDB.rainbow
            print("|cff00ccffCursorTrail|r: Rainbow Mode " .. (CursorTrailDB.rainbow and "ON" or "OFF"))
        elseif cmd == "pulse" then
            CursorTrailDB.pulse = not CursorTrailDB.pulse
            print("|cff00ccffCursorTrail|r: Pulse Effect " .. (CursorTrailDB.pulse and "ON" or "OFF"))
        
        elseif cmd == "width" and tonumber(arg) then
            CursorTrailDB.lineWidth = tonumber(arg)
            print("|cff00ccffCursorTrail|r: Width set to " .. arg)
        
        elseif cmd == "color" then
            if arg and ns.Config.namedColors[arg:lower()] then
                local c = ns.Config.namedColors[arg:lower()]
                CursorTrailDB.color.r = c[1]
                CursorTrailDB.color.g = c[2]
                CursorTrailDB.color.b = c[3]
                CursorTrailDB.classColor = false
                CursorTrailDB.rainbow = false
                print("|cff00ccffCursorTrail|r: Color set to " .. arg)
            else
                print("|cff00ccffCursorTrail|r Available Colors:")
                local s = ""
                for name, _ in pairs(ns.Config.namedColors) do s = s .. name .. ", " end
                print(s)
            end
            
        elseif cmd == "texture" then
            if arg and ns.Config.textureOptions[arg:lower()] then
                CursorTrailDB.texture = arg:lower()
                print("|cff00ccffCursorTrail|r: Texture set to " .. arg:lower())
            else
                print("|cff00ccffCursorTrail|r Textures: solid, glow, soft, star, spot")
            end
            
        elseif cmd == "preset" then
            if ns.Config.presets[arg] then
                ns.Config.ApplyPreset(arg)
            else
                print("|cff00ccffCursorTrail|r: Presets:")
                for k in pairs(ns.Config.presets) do print(" - " .. k) end
            end
            
        else
            print("|cff00ccffCursorTrail|r Commands:")
            print(" /ctrail on/off - Toggle addon")
            print(" /ctrail combat - Toggle mode (Always, Combat, NoCombat)")
            print(" /ctrail click - Toggle click ripples")
            print(" /ctrail sound - Toggle click sounds")
            print(" /ctrail sparkles - Toggle magical sparkles")
            print(" /ctrail shadow - Toggle ghost trail shadow")
            print(" /ctrail aura - Toggle idle cursor aura")
            print(" /ctrail color <name> - Set color")
            print(" /ctrail texture <name> - Set line texture")
            print(" /ctrail rainbow | class | pulse - Visual toggles")
            print(" /ctrail width <num> - Set width")
            print(" /ctrail preset <name> - Apply preset")
            print(" /ctrail reset - Restore defaults")
        end
    end
end
