util.AddNetworkString("EFTM_player:net:server:initFirstSpawn")

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

net.Receive("EFTM_player:net:server:initFirstSpawn", function(len, ply)
    ply.EFTM = ply.EFTM || {}
    if ply.EFTM.HAS_BEEN_INIT then return end

    local hideoutLocation = EFTM.CONFIG.MAP.hideout_location || {x = 0, y = 0, z = 0, w = 0}
    local pos = Vector(hideoutLocation.x || 0, hideoutLocation.y || 0, hideoutLocation.z || 0)
    local rot = Angle(0, hideoutLocation.w || 180, 0)

    ply:SetPos(pos)
    ply:SetEyeAngles(rot)
    ply.EFTM.HAS_BEEN_INIT = true
end)
