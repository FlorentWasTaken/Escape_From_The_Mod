util.AddNetworkString("EFTM_player:net:server:initFirstSpawn")

local function bringPlayerToHideout(ply)
    local hideoutLocation = EFTM.CONFIG.MAP.hideout_location or {x = 0, y = 0, z = 0, w = 0}
    local pos = Vector(hideoutLocation.x or 0, hideoutLocation.y or 0, hideoutLocation.z or 0)
    local rot = Angle(0, hideoutLocation.w or 180, 0)

    ply:SetPos(pos)
    ply:SetEyeAngles(rot)
end

hook.Add("CanPlayerSuicide", "EFTM:hook:server:disableSuicide", function(ply)
    return false
end)

hook.Add("PlayerSpawnProp", "EFTM:hook:server:disablePropsSpawn", function(ply, _)
    return false
end)

hook.Add("PlayerGiveSWEP", "EFTM:hook:server:disableWeaponGive", function(ply, _, _)
    return false
end)

hook.Add("PlayerLoadout", "EFTM:hook:server:disableDefaultLoadout", function(ply)
    return true
end)

hook.Add("CanPlayerEnterVehicle", "EFTM:hook:server:disableVehicleEntering", function(ply, _, _)
    return false
end)

hook.Add("AllowPlayerPickup", "EFTM:hook:server:disablePickup", function(ply, _)
    return false
end)

hook.Add("PlayerCanPickupItem", "EFTM:hook:server:disableItemPickup", function(ply, _)
    return false
end)

hook.Add("PlayerCanPickupWeapon", "EFTM:hook:server:disableWeaponPickup", function(ply, _)
    return false
end)

hook.Add("PlayerDeathSound", "EFTM:hook:server:muteDeathSound", function(ply)
    return true
end)

hook.Add("PlayerSwitchFlashlight", "EFTM:hook:server:disableFlashlight", function(ply, _)
    return false
end)

hook.Add("PlayerDeath", "EFTM_player:hook:server:manageDeathSpawn", function(ply)
    ply.EFTM.IN_HIDEOUT = true
end)

hook.Add("PlayerSpawn", "EFTM_player:hook:server:respawnManagement", function(ply)
    if not ply.EFTM.IN_HIDEOUT then return end

    bringPlayerToHideout(ply)
end)

net.Receive("EFTM_player:net:server:initFirstSpawn", function(len, ply)
    ply.EFTM = ply.EFTM or {}
    if ply.EFTM.HAS_BEEN_INIT or not EFTM.CONFIG.MAP then return end

    bringPlayerToHideout(ply)
    ply.EFTM.IN_HIDEOUT = true
    ply.EFTM.HAS_BEEN_INIT = true
end)
