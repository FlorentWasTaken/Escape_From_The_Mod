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

            if ply.EFTM.NEEDS.hunger > 0 then
                ply.EFTM.NEEDS.hunger = ply.EFTM.NEEDS.hunger - 1
            end

            if ply.EFTM.NEEDS.thirst > 0 then
                ply.EFTM.NEEDS.thirst = ply.EFTM.NEEDS.thirst - 1
            end
        end
    end)
end)