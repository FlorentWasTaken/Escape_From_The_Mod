PLAYER_NEEDS = {}

local function resetNeeds()
    PLAYER_NEEDS = {
        ["hunger"] = 100,
        ["thirst"] = 100
    }
end
resetNeeds()

net.Receive("EFTM_player:net:server:updateNeeds", function(len)
    PLAYER_NEEDS.hunger = net.ReadUInt(7)
    PLAYER_NEEDS.thirst = net.ReadUInt(7)
end)