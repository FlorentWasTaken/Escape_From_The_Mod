util.AddNetworkString("EFTM_player:net:server:updateNeeds")

local function updateNeeds(ply)
    net.Start("EFTM_player:net:server:updateNeeds")
        net.WriteUInt(ply.EFTM.NEEDS.hunger, 7)
        net.WriteUInt(ply.EFTM.NEEDS.thirst, 7)
    net.Send(ply)
end

hook.Add("PlayerSpawn", "EFTM:hook:server:setupPlayerNeeds", function(ply, _)
    ply.EFTM.NEEDS = {
        ["hunger"] = 100,
        ["thirst"] = 100
    }
end)

hook.Add("Initialize", "EFTM:hook:server:manageNeeds", function()
    timer.Create("EFTM:timer:server:manageNeeds", 60, 0, function()
        local players = player.GetAll()

        for _, ply in ipairs(players) do
            if !IsValid(ply) || !ply.EFTM.NEEDS then continue end
            local rate = (ply.EFTM.BODY.stomach.life == 0 && 5) || 1
            local hunger = ply.EFTM.NEEDS.hunger
            local thirst = ply.EFTM.NEEDS.thirst

            if hunger - rate >= 0 then
                ply.EFTM.NEEDS.hunger = hunger - rate
            else
                ply.EFTM.NEEDS.hunger = 0
            end

            if thirst - (rate + 1) => 0 then
                ply.EFTM.NEEDS.thirst = thirst - (rate + 1)
            else
                ply.EFTM.NEEDS.thirst = 0
            end
        end
    end)
end)