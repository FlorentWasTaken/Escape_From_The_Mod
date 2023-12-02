local isExtracting = false
local extracts = nil

local function startExtracting(extract)
    net.Start("EFTM_raid:net:server:startExtracting")
        net.WriteUInt(extract, 4)
    net.SendToServer()
end

local function checkCoordDist(xStatic, xEntity)
    return xStatic - 15 <= xEntity <= xStatic + 15
end

net.Receive("EFTM_raid:net:server:startRaid", function(len)
    extracts = util.JSONToTable(net.ReadString())

    timer.Create("EFTM:timer:client:raidTimer", 1, 0, function()
        if isExtracting then return end

        local pos = LocalPlayer():GetPos()
        local maxDist = 15

        for k, v in ipairs(extracts) do
            if checkCoordDist(v.x, pos.x) and checkCoordDist(v.y, pos.y) and checkCoordDist(v.z, pos.z) then
                startExtracting(k)
                isExtracting = true
                break
            end
        end
    end)
end)

net.Receive("EFTM_raid:net:server:stopExtracting", function(len)
    isExtracting = false
end)

net.Receive("EFTM_raid:net:server:stopRaid", function(len)
    timer.Remove("EFTM:timer:client:raidTimer")
end)
