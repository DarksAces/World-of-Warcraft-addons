local queue = {}
SLASH_CRAFTQUEUE1 = "/cq"
SlashCmdList["CRAFTQUEUE"] = function(msg)
    table.insert(queue, msg)
    print("Added to queue: " .. msg)
end
