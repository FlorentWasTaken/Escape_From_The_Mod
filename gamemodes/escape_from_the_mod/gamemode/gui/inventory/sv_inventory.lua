local _player = FindMetaTable("Player")

Slot = {}

function Slot:new(_type)
    local obj = {}

    if _type ~= "X" and _type ~= "Y" then return nil end

    setmetatable(obj, self)
    self.__index = self
    self.type = _type -- correspond to X or Y
    self.replacement = nil -- correspond to the item pos in ITEMS table
    return obj
end

function _player:getItemByPos(pos)
    return self.EFTM.INVENTORY.ITEMS[pos]
end

function _player:removeItem(item)
    table.RemoveByValue(self.EFTM.INVENTORY.ITEMS, item)
end

hook.Add("PlayerInitialSpawn", "EFTM:hook:server:loadPlayerItems", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply.EFTM.INVENTORY = {
        BAG = {ITEMS = {}, SHAPE = {}},
        POCKETS = {ITEMS = {}, SHAPE = {{Slot:new("X"), Slot:new("Y"), Slot:new("X"), Slot:new("Y")}}}, -- X or Y = 1 square but X and X = rectangle
        RIG = {ITEMS = {}, SHAPE = {}}
    }
end)
