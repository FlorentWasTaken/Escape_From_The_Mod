AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("gui/hud/cl_hud.lua")
AddCSLuaFile("gui/inventory/cl_inventory.lua")
AddCSLuaFile("player/stamina/cl_stamina.lua")
AddCSLuaFile("player/spawn/cl_spawn.lua")
AddCSLuaFile("player/health/cl_health.lua")
AddCSLuaFile("player/needs/cl_needs.lua")
AddCSLuaFile("item/cl_item.lua")
AddCSLuaFile("raid/cl_raid.lua")

include("shared.lua")
include("gui/hud/sv_hud.lua")
include("gui/inventory/sv_inventory.lua")
include("player/stamina/sv_stamina.lua")
include("player/spawn/sv_spawn.lua")
include("item/sv_use.lua")
include("item/sv_item.lua")
include("player/health/sv_health.lua")
include("player/needs/sv_needs.lua")
include("raid/sv_start.lua")
include("raid/sv_extract.lua")

-- tests files
include("tests/init.lua")

local function loadSettings()
	local map = game.GetMap()
	local mapPath = string.format("gamemodes/escape_from_the_mod/config/maps/%s.JSON", map)

	if not file.Exists(mapPath, "GAME") or file.IsDir(mapPath, "GAME") then
		return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo config file for %s\n", map))
	end
	local mapConfigContent = file.Read(mapPath, "GAME")

	if not mapConfigContent or mapConfigContent == "" then
		return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid config file for %s\n", map))
	end

	EFTM.CONFIG.MAP = util.JSONToTable(mapConfigContent)
	MsgC(Color(0, 200, 0), "Escape From The Mod:\nGamemode has successfully loaded\n")
end

local function loadLanguage()
	local langPath = string.format("gamemodes/escape_from_the_mod/config/lang/%s.JSON", _LANGUAGE or "en_US")

	if file.Exists(langPath, "GAME") and not file.IsDir(langPath, "GAME") then
		local langConfigContent = file.Read(langPath, "GAME")

		if (not langConfigContent or langConfigContent == "") and _LANGUAGE == "en_US" then
			return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid language file\n", _LANGUAGE))
		elseif (not langConfigContent or langConfigContent == "") and _LANGUAGE ~= "en_US" then
			MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid language file for %s switching to en_US\n", _LANGUAGE))
			_LANGUAGE = "en_US"
			return loadLanguage()
		end
		EFTM.CONFIG.LANGUAGE = util.JSONToTable(langConfigContent)
	elseif _LANGUAGE ~= "en_US" then
		MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid language file for %s switching to en_US\n", _LANGUAGE))
		_LANGUAGE = "en_US"
		return loadLanguage()
	else
		return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid language file\n"))
	end
	EFTM.CONFIG.LANG = _LANGUAGE
	MsgC(Color(0, 200, 0), "Escape From The Mod:\nLanguage has successfully loaded\n")
end

local function initSql()
	local path = "gamemodes/escape_from_the_mod/init.sql"

	if not file.Exists(path, "GAME") or file.IsDir(path, "GAME") then
		return MsgC(Color(216, 20, 20), "Escape From The Mod:\nCan't read init.sql\n")
	end
	local data = file.Read(path, "GAME")

	if sql.Query(data) == false then
		return MsgC(Color(216, 20, 20), "Escape From The Mod:\n" .. sql.LastError())
	end
	MsgC(Color(0, 200, 0), "Escape From The Mod:\nDatabase successfully init\n")
end

hook.Add("Initialize", "EFTM:hook:server:loadSettings", function()
	loadSettings()
	loadLanguage()
	loadItems()
	initSql()
end)

HTTP({
	failed = function(reason)
		MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nHTTP request failed %s\n", reason))
	end,
	success = function(code, body, headers)
		if code ~= 200 then
            return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nHTTP request failed %d\n", code))
        elseif body ~= _VERSION then
            MsgC(Color(201, 168, 25), string.format("Escape From The Mod:\nA new update is available !\nPlease download the new version:\n%s\n", _WEBSITE))
        end
	end,
	method = "GET",
	url = "https://raw.githubusercontent.com/FlorentWasTaken/Escape_From_The_Mod/main/VERSION"
})
