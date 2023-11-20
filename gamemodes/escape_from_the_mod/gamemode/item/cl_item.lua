local function useItem(pos, quantity)
    net.Start("EFTM_item:net:server:useItem")
        net.WriteUInt(pos, 8)
        net.WriteUInt(quantity, 4)
    net.SendToServer()
end