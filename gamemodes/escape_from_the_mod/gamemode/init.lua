AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("gui/hud/cl_hud.lua")
AddCSLuaFile("gui/inventory/cl_inventory.lua")
AddCSLuaFile("player/cl_stamina.lua")

include("shared.lua")
include("player/sv_stamina.lua")

hook.Add("CanPlayerSuicide", "EFTM:hook:server:DisableSuicide", function(ply)
    return false
end)

HTTP({
	failed = function(reason)
		MsgC(Color(216, 20, 20), string.format("HTTP request failed %s\n", reason))
	end,
	success = function(code, body, headers)
		if code != 200 then
            return MsgC(Color(216, 20, 20), string.format("HTTP request failed %d\n", code))
        elseif body != _VERSION then
            MsgC(Color(201, 168, 25), string.format("A new update is available !\nPlease download the new version\n%s\n", _WEBSITE))
        end
	end,
	method = "GET",
	url = "https://raw.githubusercontent.com/FlorentWasTaken/Escape_From_The_Mod/main/VERSION"
})