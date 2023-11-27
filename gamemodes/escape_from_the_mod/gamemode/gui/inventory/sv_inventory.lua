local _player = FindMetaTable("Player")

function _player:getItemByPos(pos)
    return self.EFTM.INVENTORY[pos]
end

function _player:removeItem(item)
    table.RemoveByValue(self.EFTM.INVENTORY, item)
end

hook.Add("PlayerInitialSpawn", "EFTM:hook:server:loadPlayerItems", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply.EFTM.INVENTORY = {}
end)
