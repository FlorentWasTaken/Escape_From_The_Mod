local notHidden = {
    ["CHudGMod"] = true, // correspond to HUDPaint hook
}

hook.Add("HUDShouldDraw", "EFTM_gui:hook:client:hideHUD", function(name)
	return notHidden[ name ] == false
end)