SLASH_SPECSWITCHER1 = "/ss"
SlashCmdList["SPECSWITCHER"] = function(msg)
    local specIndex = tonumber(msg)
    if specIndex then
        SetSpecialization(specIndex)
    else
        print("Usage: /ss <specIndex>")
    end
end
