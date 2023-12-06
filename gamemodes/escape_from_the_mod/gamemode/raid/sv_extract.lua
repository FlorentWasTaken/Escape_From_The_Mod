util.AddNetworkString("EFTM_raid:net:server:startExtracting")
util.AddNetworkString("EFTM_raid:net:server:stopExtracting")

local function cancelExtract(ply)
    net.Start("EFTM_raid:net:server:stopExtracting")
    net.Send(ply)
end

local function checkLastPlayer()
    for k, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.EFTM and not v.EFTM.IN_HIDEOUT then
            return false
        end
    end
    return true
end

local function stopRaid()
    IS_RAID_STARTED = false
    timer.UnPause("EFTM_raid:timer:server:raidStartup")
end

net.Receive("EFTM_raid:net:server:startExtracting", function(len, ply)
    local extract = net.ReadUInt(4)

    if not extract or extract == 0 then return cancelExtract(ply) end
    if not ply:Alive() or ply.EFTM.IS_EXTRACTING then return cancelExtract(ply) end
    local tbl = EFTM.CONFIG.MAP

    if not tbl or not tbl.extracts or not tbl.extracts[extract] then return cancelExtract(ply) end
    local extractTbl = tbl.extracts[extract]
    local extractPos = Vector(extractTbl.x, extractTbl.y, extractTbl.z)
    local maxDist = 225

    if extractPos:DistToSqr(ply:GetPos()) > maxDist then return cancelExtract(ply) end -- 225 = 15²
    local timerName = "EFTM_raid:timer:server:extracting_" .. ply:SteamID64()
    local timerCount = 0
    ply.EFTM.IS_EXTRACTING = true

    timer.Create(timerName, 1, 10, function()
        if not IsValid(ply) or not ply.EFTM.IS_EXTRACTING or not ply:Alive() then timer.Remove(timerName) return cancelExtract(ply) end
        if extractPos:DistToSqr(ply:GetPos()) > maxDist then timer.Remove(timerName) ply.EFTM.IS_EXTRACTING = false return cancelExtract(ply) end

        timerCount = timerCount + 1
        if timerCount >= 10 then
            local hideoutLocation = EFTM.CONFIG.MAP.hideout_location or {x = 0, y = 0, z = 0, w = 0}
            local pos = Vector(hideoutLocation.x or 0, hideoutLocation.y or 0, hideoutLocation.z or 0)
            local rot = Angle(0, hideoutLocation.w or 180, 0)

            ply.EFTM.IS_EXTRACTING = false
            timer.Remove(timerName)
            ply:SetPos(pos)
            ply:SetEyeAngles(rot)
            ply.EFTM.IN_HIDEOUT = true
            if checkLastPlayer() then
                stopRaid()
            end
        end
    end)
end)
