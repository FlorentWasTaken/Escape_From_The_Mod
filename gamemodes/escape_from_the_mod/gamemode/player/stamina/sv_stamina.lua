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
	ply.EFTM = ply.EFTM || {}
	ply.EFTM.DEFAULT_RUN = ply:GetRunSpeed() || 400
	ply.EFTM.DEFAULT_WALK = ply:GetWalkSpeed() || 200
	ply.EFTM.DEFAULT_JUMP = ply:GetJumpPower() || 200
	ply.EFTM.STAMINA = 100
	ply.EFTM.STAMINA_REGEN = .05
end)

hook.Add("PlayerTick", "EFTM_player:hook:server:manageStamina", function(ply)
    if !ply:Alive() then return end

	if ply:IsSprinting() && ply:OnGround() && ply:GetVelocity():LengthSqr() >= ply.EFTM.DEFAULT_RUN * ply.EFTM.DEFAULT_RUN then
		ply.EFTM.STAMINA = math.Clamp(ply.EFTM.STAMINA - .05, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.EFTM.STAMINA)
		net.Send(ply)
	elseif !ply:IsSprinting() && ply.EFTM.STAMINA != 100 then
		ply.EFTM.STAMINA = math.Clamp(ply.EFTM.STAMINA + ply.EFTM.STAMINA_REGEN, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.EFTM.STAMINA)
		net.Send(ply)
	end

	if !ply.EFTM.LOW_STAMINA && ply.EFTM.STAMINA <= 15 then
		ply.EFTM.LOW_STAMINA = true
		ply:EmitSound("EFTM_player:sound:server:lowStaminaBreath")
	elseif ply.EFTM.LOW_STAMINA && ply.EFTM.STAMINA == 0 then
		ply:SetJumpPower(ply.EFTM.DEFAULT_JUMP * .5)
		ply:SetRunSpeed(ply.EFTM.DEFAULT_WALK)
	elseif ply.EFTM.LOW_STAMINA && ply.EFTM.STAMINA > 15 then
		ply:SetJumpPower(ply.EFTM.DEFAULT_JUMP)
		ply:SetRunSpeed(ply.EFTM.DEFAULT_RUN)
		ply.EFTM.LOW_STAMINA = false
		ply:StopSound("EFTM_player:sound:server:lowStaminaBreath")
	end
end)

hook.Add("KeyPress", "EFTM_player:hook:server:jumpManagement", function(ply, key)
	if !ply:Alive() || ply:InVehicle() || !ply:OnGround() then return end

	if key == IN_JUMP && ply.EFTM.STAMINA > 0 then
		ply.EFTM.STAMINA = math.Clamp(ply.EFTM.STAMINA - 20, 0, 100)
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.EFTM.STAMINA)
		net.Send(ply)
	end
end)

hook.Add("PlayerDeath", "EFTM_player:hook:server:resetStamina", function(ply)
	if ply.EFTM.STAMINA != 100 then
		ply.EFTM.STAMINA = 100
		net.Start("EFTM_player:net:server:updateStamina", true)
			net.WriteFloat(ply.EFTM.STAMINA)
		net.Send(ply)
		ply.EFTM.LOW_STAMINA = false
	end
	ply.EFTM.STAMINA_REGEN = .05
	ply:StopSound("EFTM_player:sound:server:lowStaminaBreath")
end)