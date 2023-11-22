util.AddNetworkString("EFTM_item:net:server:useItem")

function useMedkit(self, owner, part)
    if not self or not owner or not part then return end
    local durability = self:durability()

    if durability <= 0 then owner:removeItem(self) return end
    if not owner.EFTM.BODY[part] or owner.EFTM.BODY[part].life == 0 then return end
    local max = owner.EFTM.BODY[part].maxLife
    local life = owner.EFTM.BODY[part].life

    if life == max then return end

    timer.Simple(self.useTime or 5, function()
        if owner.EFTM.BODY[part].life == 0 then return end

        local add = math.min(max - life, durability)

        owner.EFTM.BODY[part].life = add
        owner.EFTM.usingItem = false

        if durability - add <= 0 then
            owner:removeItem(self)
        else
            self:durability(durability - add)
        end
    end)
end

function useTreatement(self, owner, part)
    if not self or not owner or not part then return end
    local durability = self:durability()

    if durability <= 0 then owner:removeItem(self) return end
    if not owner.EFTM.BODY[part] or owner.EFTM.BODY[part].life > 0 then return end

    timer.Simple(self.useTime or 10, function()
        owner.EFTM.BODY[part].life = 1
        owner.EFTM.BODY[part].maxLife = math.floor(owner.EFTM.BODY[part].maxLife * .5)
        owner.EFTM.usingItem = false

        if durability - 1 == 0 then
            owner:removeItem(self)
        else
            self:durability(durability - 1)
        end
    end)
end

function useDrink(self, owner, amount)

end

function useFood(self, owner, amount)

end

net.Receive("EFTM_item:net:server:useItem", function(len, ply)
    local itemPos = net.ReadUInt(8)
    local param = net.ReadUInt(4)
    local item = ply:getItemByPos(itemPos)

    if not item or not item:useable() then return end
    if ply.EFTM.usingItem then return end

    ply.EFTM.usingItem = true
    item.use(item, ply, param)
end)