util.AddNetworkString("EFTM_gui:net:server:notify")

function notifyPlayer(ply, message, messageType)
    if not ply or not IsValid(ply) or not message or not messageType then return end
    if type(message) ~= "string" or type(messageType) ~= "number" then return end

    net.Start("EFTM_gui:net:server:notify")
        net.WriteString(message)
        net.WriteUInt(messageType, 2)
    net.Send(ply)
end

function notifyBroadcast(message, messageType)
    if not message or not messageType then return end
    if type(message) ~= "string" or type(messageType) ~= "number" then return end

    net.Start("EFTM_gui:net:server:notify")
        net.WriteString(message)
        net.WriteUInt(messageType, 2)
    net.Broadcast()
end