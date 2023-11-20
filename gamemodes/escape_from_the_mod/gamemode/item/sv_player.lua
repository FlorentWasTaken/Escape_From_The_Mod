local ply = FindMetaTable("Player")

function ply:getItemByPos(pos)
    return self.EFTM.inventory[pos]
end

hook.Add("PlayerSpawn", "EFTM:hook:server:loadPlayerItems", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply.EFTM.inventory = {}
end)