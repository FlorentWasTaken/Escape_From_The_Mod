local ply = FindMetaTable("Player")

function ply:getItemByPos(pos)
    return self.EFTM.INVENTORY[pos]
end

function ply:removeItem(item)
    table.RemoveByValue(ply.EFTM.INVENTORY, item)
end

hook.Add("PlayerInitialSpawn", "EFTM:hook:server:loadPlayerItems", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply.EFTM.INVENTORY = {}
end)