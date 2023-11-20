local useableType = {
    ["drinks"] = useDrink,
    ["medkit"] = useMedkit,
    ["treatment"] = useTreatement
}

Item = {}

function Item:new(name)
    local obj = {}

    if !EFTM.CONFIG.ITEMS || !EFTM.CONFIG.ITEMS[name] then return nil end
    local cfg = EFTM.CONFIG.ITEMS[name]

    setmetatable(obj, self)
    self.__index = self
    obj.name = cfg.name
    obj.type = cfg.type
    obj.durability = cfg.durability && tonumber(cfg.durability) || -1
    obj.horizontal = cfg.horizontal_size && tonumber(cfg.horizontal_size) || 1
    obj.vertical = cfg.vertical_size && tonumber(cfg.vertical_size) || 1
    obj.use = useableType[cfg.type] || nil
    return obj
end

function Item:durability(durability)
    if !durability || type(durability) ~= "number" || durability < 0 then
        return durability
    end

    self.durability = durability
end

function Item:debug()
    print(string.format("Name: %s", self.name))
    print(string.format("Type: %s", self.type))
    print(string.format("Durabilty: %d", self.durability))
    print(string.format("Horizontal size: %d", self.horizontal))
    print(string.format("Vertical size: %d\n", self.vertical))
end

function Item:useable()
    if !useableType[self.type] then return false end
    return true
end

function loadItems()
	local itemPath = string.format("gamemodes/escape_from_the_mod/config/%s.JSON", _ITEMS)

	if !file.Exists(itemPath, "GAME") || file.IsDir(itemPath, "GAME") then
		return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo items config file for %s\n", _ITEMS))
	end
	local itemConfigContent = file.Read(itemPath, "GAME")

	if !itemConfigContent || itemConfigContent == "" then
		return MsgC(Color(216, 20, 20), string.format("Escape From The Mod:\nNo valid items config file for %s\n", _ITEMS))
	end

    EFTM.CONFIG.ITEMS = util.JSONToTable(itemConfigContent)
	MsgC(Color(0, 200, 0), "Escape From The Mod:\nItems have successfully loaded\n")
end
