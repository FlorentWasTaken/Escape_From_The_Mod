GM.Name     = "Escape From The Mod"
GM.Author   = "Florent"
GM.Website  = "https://github.com/FlorentWasTaken/Escape_From_The_Mod"

DeriveGamemode("sandbox")

EFTM = {}
EFTM.Config = {}

if CLIENT then
    EFTM.Config.DefaultOpenInventory = KEY_I    // default key to open inventory
end