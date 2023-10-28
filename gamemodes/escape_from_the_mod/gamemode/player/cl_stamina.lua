PLAYER_STAMINA = 100

net.Receive("EFTM_player:net:server:updateStamina", function(len)
    PLAYER_STAMINA = net.ReadFloat()
end)