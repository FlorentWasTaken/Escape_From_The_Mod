hook.Add("InitPostEntity", "EFTM_player:hook:client:initFirstSpawn", function()
	net.Start("EFTM_player:net:server:initFirstSpawn")
	net.SendToServer()
end)