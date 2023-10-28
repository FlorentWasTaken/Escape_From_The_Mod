util.AddNetworkString("EFTM_player:net:server:updateStamina")

hook.Add("PlayerInitialSpawn", "EFTM_player:hook:server:setupStats", function(ply)
	ply.DEFAULTRUN = ply:GetRunSpeed() or 400
	ply.DEFAULTWALK = ply:GetWalkSpeed() or 200
	ply.DEFAULTJUMP = ply:GetJumpPower() or 200
	ply.STAMINA = 100
end)

hook.Add("PlayerTick", "EFTM_player:hook:server:manageStamina", function(ply)
    if !ply:Alive() then return end
	if ply:IsSprinting() && ply:OnGround() && ply:GetVelocity():LengthSqr() >= ply.DEFAULTWALK * ply.DEFAULTWALK then
		ply.STAMINA = math.Clamp(ply.STAMINA - .05, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
	elseif !ply:IsSprinting() && ply.STAMINA ~= 100 then
		ply.STAMINA = math.Clamp(ply.STAMINA + .05, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
	end
end)