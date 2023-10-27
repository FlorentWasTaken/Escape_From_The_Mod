util.AddNetworkString("EFTM_player:net:server:updateStamina")

hook.Add("PlayerInitialSpawn", "EFTM_player:hook:server:setupStats", function(ply)
	ply.DEFAULTRUN = ply:GetRunSpeed() or 400
	ply.DEFAULTWALK = ply:GetWalkSpeed() or 200
	ply.DEFAULTJUMP = ply:GetJumpPower() or 200
end)

hook.Add("PlayerTick", "EFTM_player:hook:server:manageStamina", function(ply)
    if !ply:Alive() then return end
end)