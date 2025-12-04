local frame = CreateFrame("Frame")
frame:RegisterEvent("ROLE_POLL_BEGIN")

frame:SetScript("OnEvent", function()
    -- CompleteLFGRoleCheck(true) -- Auto accept
    print("Role check received.")
end)
