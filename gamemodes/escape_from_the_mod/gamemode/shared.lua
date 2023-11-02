_VERSION = "VERSION 0.0.1"
_WEBSITE = "https://github.com/FlorentWasTaken/Escape_From_The_Mod"
_LANGUAGE = "en_US"
_ITEMS = "default_items"

GM.Name     = "Escape From The Mod"
GM.Author   = "Florent"
GM.Website  = _WEBSITE

DeriveGamemode("sandbox")

EFTM = {}
EFTM.CONFIG = {}

if CLIENT then
    EFTM.CONFIG.DEFAULT_OPEN_INVENTORY = KEY_I    // default key to open inventory
end
