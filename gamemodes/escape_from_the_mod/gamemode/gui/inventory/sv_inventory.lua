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

function _player:getItemByPos(pos, inv)
    return self.EFTM.INVENTORY[inv].ITEMS[pos]
end

function _player:removeItem(item, inv)
    table.RemoveByValue(self.EFTM.INVENTORY[inv].ITEMS, item)
end

local function doesItemFit(tbl, columnSize, rowSize, actualType, sizeX, sizeY, k, kk)
    for i = k, columnSize, 1 do
        for ii = kk, rowSize, 1 do
            local obj = tbl[i][ii]

            if obj and obj.type ~= actualType then
                return false
            elseif i - k >= sizeY and ii - kk >= sizeX then -- stop loop if we are checking more than necessary
                return true
            end
        end
    end
    return true
end

local function fillSlot(tbl, columnSize, rowSize, typeReplacement, sizeX, sizeY, k, kk)
    for i = k, columnSize, 1 do
        for ii = kk, rowSize, 1 do
            tbl[i][ii].replacement = typeReplacement
            if i >= sizeY and ii >= sizeX then return end
        end
    end
end

function _player:quickMoveItem(item, inv)
    if inv == nil then
        inv = "RIG"
    elseif inv == "RIG" then
        inv = "POCKETS"
    elseif inv == "POCKETS" then
        inv = "BAG"
    elseif inv == "BAG" then
        return false
    end

    if table.Empty(self.EFTM.INVENTORY[inv].SHAPE) then
        return self:quickMoveItem(item, inv)
    end
    local tbl = self.EFTM.INVENTORY[inv].SHAPE
    local columnSize = #tbl
    local sizeX, sizeY = item.horizontal, item.vertical

    if item.vertical > columSize then -- item can't fit in
        return self:quickMoveItem(item, inv)
    end

    for k, v in ipairs(tbl) do -- row
        local rowSize = #v

        for kk, vv in ipairs(v) do -- column
            if vv.replacement ~= nil then continue end -- item already present here
            if rowSize - kk < item.horizontal then break end -- item can't fit in

            if doesItemFit(tbl, columnSize, rowSize, vv.type, sizeX, sizeY, k, kk) then
                table.insert(self.EFTM.INVENTORY[inv].inventory, item)
                fillSlot(tbl, columnSize, rowSize, #self.EFTM.INVENTORY[inv].inventory, sizeX, sizeY, k, kk)
                return true
            end
        end
    end
    return false
end

hook.Add("PlayerInitialSpawn", "EFTM:hook:server:loadPlayerItems", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply.EFTM.INVENTORY = { -- if you want to create empty space use "Z" as type
        RIG = {ITEMS = {}, SHAPE = {}},
        POCKETS = {ITEMS = {}, SHAPE = {{Slot:new("X"), Slot:new("Y"), Slot:new("X"), Slot:new("Y")}}}, -- X or Y = 1 square but X and X = rectangle
        BAG = {ITEMS = {}, SHAPE = {}}
    }
end)
