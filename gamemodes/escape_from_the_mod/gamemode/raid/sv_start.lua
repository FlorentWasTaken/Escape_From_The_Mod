util.AddNetworkString("EFTM_raid:net:server:startRaid")
util.AddNetworkString("EFTM_raid:net:server:stopRaid")

IS_RAID_STARTED = false

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

local function countAvailablePlayer()
    local count = 0

    for k, v in ipairs(player.GetAll()) do
        if not p.EFTM.HAS_BEEN_INIT then continue end
        count = count + 1
    end
    return count
end

local function managePlayerSpawn(players, spawns, extracts, spawnCount)
    local currentTime = CurTime()
    local currentZone = 1
    local waitingPlayers = {}

    for _, p in ipairs(players) do
        if not p.EFTM.HAS_BEEN_INIT or not p.EFTM.IN_HIDEOUT then continue end
        if not p:Alive() then p:Spawn() end

        for k, v in ipairs(spawns[currentZone]) do
            if v.LastSpawn and v.LastSpawn > currentTime - 10 then continue end

            spawns[currentZone].LastSpawn = currentTime
            p.EFTM.IN_HIDEOUT = false
            p.EFTM.EXTRACT_ZONE = currentZone
            net.Start("EFTM_raid:net:server:startRaid")
                net.WriteString(extracts)
                net.WriteUInt(EFTM.CONFIG.MAP.raid_duration or 900, 12) -- Raid duration
            net.Send(p)
            currentZone = currentZone + 1
            p:SetPos(Vector(v.x, v.y, v.z))
            p:SetEyeAngles(Angle(0, v.w, 0))

            if currentZone > spawnCount then currentZone = 1 end
            break
        end
        if p.EFTM.IN_HIDEOUT then table.insert(waitingPlayers, p) end
    end
    return waitingPlayers
end

function startRaid()
    if not EFTM.CONFIG.MAP.spawns then return end
    if not EFTM.CONFIG.MAP.extracts then return end

    local extracts = util.TableToJSON(EFTM.CONFIG.MAP.extracts)
    local spawns = table.Copy(EFTM.CONFIG.MAP.spawns)
    local spawnCount = #spawns
    local waitingPlayers = {}

    clearRaid()
    timer.Pause("EFTM_raid:timer:server:raidStartup")
    IS_RAID_STARTED = true
    waitingPlayers = managePlayerSpawn(player.GetAll(), spawns, extracts, spawnCount)

    if #waitingPlayers == 0 then return end
    timer.Create("EFTM_raid:timer:server:waitingPlayersSpawn", 12, 0, function()
        waitingPlayers = managePlayerSpawn(player.GetAll(), spawns, extracts, spawnCount)
        if #waitingPlayers == 0 then timer.Remove("EFTM_raid:timer:server:waitingPlayersSpawn") end
    end)
end

hook.Add("Initialize", "EFTM_raid:hook:server:raidStartup", function()
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
