util.AddNetworkString("EFTM_gui:net:server:notify")

function notifyPlayer(ply, message)
    if not ply or not IsValid(ply) or not message then return end

    net.Start("EFTM_gui:net:server:notify")
        net.WriteString(message)
    net.Send(ply)
end