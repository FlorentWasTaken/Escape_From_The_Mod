Item = {}

local function checkNumber(nbr)
    if !nbr || type(nbr) ~= "number" || nbr <= 0 then return false end
    return true
end

function Item:new(name, config)
    local obj = {}

    if (!config.type || type(config.type) ~= "string") then
        return nil
    elseif !checkNumber(config.horizontal_size) || !checkNumber(config.vertical_size) then
        return nil
    end

    setmetatable(obj, self)
    self.__index = self
    obj.name = name
    obj.type = config.type
    obj.durability = config.durability || -1
    obj.horizontal = config.horizontal_size
    obj.vertical = config.vertical_size
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
