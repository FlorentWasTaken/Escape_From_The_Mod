CreateClientConVar("EFTM_inventory:ccvar:client:openInventory", EFTM.CONFIG.DEFAULT_OPEN_INVENTORY || KEY_I, true, false, "Default key used to open inventory in the Escape From The Mod gamemode")

local openInventoryKey = cvars.Number("EFTM_inventory:ccvar:client:openInventory", EFTM.CONFIG.DEFAULT_OPEN_INVENTORY || KEY_I)

hook.Add("PlayerButtonDown", "EFTM_inventory:hook:client:openInventory", function(ply, button)
    if button != openInventoryKey then return end
end)