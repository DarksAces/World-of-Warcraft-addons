local function CreateCopyFrame()
    local f = CreateFrame("Frame", "ChatCopyFrame", UIParent, "DialogBoxFrame")
    f:SetPoint("CENTER")
    f:SetSize(500, 400)
    f:Hide()
    
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, -30)
    scroll:SetPoint("BOTTOMRIGHT", -30, 40)
    
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(450)
    scroll:SetScrollChild(edit)
    
    return f, edit
end

local frame, editBox = CreateCopyFrame()

SLASH_CHATCOPY1 = "/copy"
SlashCmdList["CHATCOPY"] = function()
    frame:Show()
    local text = ""
    for i = 1, ChatFrame1:GetNumMessages() do
        text = text .. ChatFrame1:GetMessage(i) .. "\n"
    end
    editBox:SetText(text)
    editBox:HighlightText()
end
