_VERSION = "VERSION 0.0.1"
_WEBSITE = "https://github.com/FlorentWasTaken/Escape_From_The_Mod"

GM.Name     = "Escape From The Mod"
GM.Author   = "Florent"
GM.Website  = _WEBSITE

DeriveGamemode("sandbox")

EFTM = {}
EFTM.Config = {}

if CLIENT then
    EFTM.Config.DefaultOpenInventory = KEY_I    // default key to open inventory
end