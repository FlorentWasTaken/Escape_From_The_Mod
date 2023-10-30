util.AddNetworkString("EFTM_player:net:server:updateStamina")

sound.Add({
	name = "EFTM_player:sound:server:lowStaminaBreath",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = { 80, 120 },
	sound = "player/breathe1.wav"
})

hook.Add("PlayerInitialSpawn", "EFTM_player:hook:server:setupStats", function(ply)
	ply.DEFAULT_RUN = ply:GetRunSpeed() || 400
	ply.DEFAULT_WALK = ply:GetWalkSpeed() || 200
	ply.DEFAULT_JUMP = ply:GetJumpPower() || 200
	ply.STAMINA = 100
end)

hook.Add("PlayerTick", "EFTM_player:hook:server:manageStamina", function(ply)
    if !ply:Alive() then return end

	if ply:IsSprinting() && ply:OnGround() && ply:GetVelocity():LengthSqr() >= ply.DEFAULT_RUN * ply.DEFAULT_RUN then
		ply.STAMINA = math.Clamp(ply.STAMINA - .05, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
	elseif !ply:IsSprinting() && ply.STAMINA != 100 then
		ply.STAMINA = math.Clamp(ply.STAMINA + .05, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
	end

	if !ply.LOW_STAMINA && ply.STAMINA <= 15 then
		ply.LOW_STAMINA = true
		ply:EmitSound("EFTM_player:sound:server:lowStaminaBreath")
	elseif ply.LOW_STAMINA && ply.STAMINA == 0 then
		ply:SetJumpPower(ply.DEFAULT_JUMP * .5)
		ply:SetRunSpeed(ply.DEFAULT_WALK)
	elseif ply.LOW_STAMINA && ply.STAMINA > 15 then
		ply:SetJumpPower(ply.DEFAULT_JUMP)
		ply:SetRunSpeed(ply.DEFAULT_RUN)
		ply.LOW_STAMINA = false
		ply:StopSound("EFTM_player:sound:server:lowStaminaBreath")
	end
end)

hook.Add("KeyPress", "EFTM_player:hook:server:jumpManagement", function(ply, key)
	if !ply:Alive() || ply:InVehicle() || !ply:OnGround() then return end

	if key == IN_JUMP && ply.STAMINA > 0 then
		ply.STAMINA = math.Clamp(ply.STAMINA - 20, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
	end
end)

hook.Add("PlayerDeath", "EFTM_player:hook:server:resetStamina", function(ply)
	if ply.STAMINA != 100 then
		ply.STAMINA = 100
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.STAMINA)
		net.Send(ply)
		ply.LOW_STAMINA = false
	end
	ply:StopSound("EFTM_player:sound:server:lowStaminaBreath")
end)