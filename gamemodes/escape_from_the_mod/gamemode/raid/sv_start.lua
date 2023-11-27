local function bringRaidPlayers()
    for _, p in ipairs(player.GetAll()) do
        if not p.EFTM.HAS_BEEN_INIT or p.EFTM.IN_HIDEOUT then continue end
        if not p:Alive() then p:Spawn() end
        local hideoutLocation = EFTM.CONFIG.MAP.hideout_location or {x = 0, y = 0, z = 0, w = 0}
        local pos = Vector(hideoutLocation.x or 0, hideoutLocation.y or 0, hideoutLocation.z or 0)
        local rot = Angle(0, hideoutLocation.w or 180, 0)

        p:SetPos(pos)
        p:SetEyeAngles(rot)
        p.EFTM.IN_HIDEOUT = true
    end
end

local function clearRaid()
    game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"})
    bringRaidPlayers()
end

function startRaid()
    clearRaid()
    for _, p in ipairs(player.GetAll()) do
        if not p.EFTM.HAS_BEEN_INIT then continue end
        if not p:Alive() then p:Spawn() end

        p.EFTM.IN_HIDEOUT = false
    end
end