util.AddNetworkString("EFTM_item:net:server:useItem")

function useMedkit(self, owner, part)

end

function useTreatement(self, owner, part)

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
    item.use(item, ply, param)
end)