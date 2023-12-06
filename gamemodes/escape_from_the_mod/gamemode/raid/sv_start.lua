IS_RAID_STARTED = false

util.AddNetworkString("EFTM_raid:net:server:startRaid")
util.AddNetworkString("EFTM_raid:net:server:stopRaid")

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
        net.Start("EFTM_raid:net:server:stopRaid")
        net.Send(p)
    end
end

local function clearRaid()
    game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"})
    bringRaidPlayers()
end

function startRaid()
    local extracts = util.TableToJSON(EFTM.CONFIG.MAP.extracts)

    clearRaid()
    timer.Pause("EFTM_raid:timer:server:raidStartup")
    IS_RAID_STARTED = true
    for _, p in ipairs(player.GetAll()) do
        if not p.EFTM.HAS_BEEN_INIT then continue end
        if not p:Alive() then p:Spawn() end

        p.EFTM.IN_HIDEOUT = false
        net.Start("EFTM_raid:net:server:startRaid")
            net.WriteString(extracts)
        net.Send(p)
        -- TODO : TP player to spawn point
    end
end

hook.Add("Initialize", "EFTM:hook:server:raidStartup", function()
    local count = 0

    timer.Create("EFTM_raid:timer:server:raidStartup", 10, 0, function()
        if IS_RAID_STARTED then return end
        local players = #player.GetAll()

        count = count + 1
        if count == 9 && players < 2 then
            notifyBroadcast(EFTM.CONFIG.LANGUAGE and EFTM.CONFIG.LANGUAGE.notifications and EFTM.CONFIG.LANGUAGE.notifications.cant_begin_raid, 2) -- can't start game
        elseif count == 9 && players >= 2 then
            notifyBroadcast(EFTM.CONFIG.LANGUAGE and EFTM.CONFIG.LANGUAGE.notifications and EFTM.CONFIG.LANGUAGE.notifications.raid_begin_soon, 1) -- game start in 10 sec
        elseif count == 10 && players >= 2 then
            startRaid()
            count = 0
        elseif count == 10 then
            count = 0
        end
    end)
end)