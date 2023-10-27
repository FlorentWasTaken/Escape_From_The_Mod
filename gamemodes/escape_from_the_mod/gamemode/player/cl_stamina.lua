PLAYER_STAMINA = 100

net.Receive("EFTM_player:net:server:updateStamina", function(stamina)
    PLAYER_STAMINA = stamina
end)