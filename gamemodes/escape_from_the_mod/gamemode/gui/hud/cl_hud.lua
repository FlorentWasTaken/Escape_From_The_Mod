local notifications = {}
local notHidden = {
    ["CHudGMod"] = true, // correspond to HUDPaint hook
}

hook.Add("HUDShouldDraw", "EFTM_gui:hook:client:hideHUD", function(name)
	return notHidden[name] ~= nil
end)

hook.Add("ScoreboardShow", "EFTM_gui:hook:client:hideScoreboard", function()
    return true
end)

hook.Add("ContextMenuOpen", "EFTM_gui:hook:client:hideContextMenu", function()
    return false
end)

hook.Add("HUDPaint", "EFTM_gui:client:paintHUD", function()
    local scrw, scrh = ScrW(), ScrH()
    local time = os.time()
    local width, height = 0, 0
    local x, y = 0, 0

    for k, v in ipairs(notifications) do
        if time - v.startTime >= 5 then
            table.remove(notifications, k)
            continue
        end
        surface.SetFont("GModNotify")
        width, height = surface.GetTextSize(v.message)
        x = scrw - width - scrw * .05
        y = scrh - height - k * scrh * .025
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(x, y)

        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(x, y, scrw - x, height)
        surface.DrawText(v.message)
    end
end)

net.Receive("EFTM_gui:net:server:notify", function(len)
    local message = net.ReadString()

    if not message then return end

    table.insert(notifications, {message = message, size = string.len(message), startTime = os.time()})
end)