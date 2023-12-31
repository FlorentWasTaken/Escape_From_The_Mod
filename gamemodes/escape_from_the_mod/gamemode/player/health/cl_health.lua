local totalHealth = {
    ["head"] = 35,
    ["thorax"] = 85,
    ["stomach"] = 70,
    ["right-arm"] = 60,
    ["left-arm"] = 60,
    ["right-leg"] = 65,
    ["left-leg"] = 65
}

local boneReplacement = {
    [1] = "head",
    [2] = "thorax",
    [3] = "stomach",
    [4] = "left-arm",
    [5] = "right-arm",
    [6] = "left-leg",
    [7] = "right-leg"
}

PLAYER_BODY = {}

local function resetHealth()
    PLAYER_BODY = {
        ["head"] = {life = totalHealth["head"], bleeding = false},
        ["thorax"] = {life = totalHealth["thorax"], bleeding = false},
        ["stomach"] = {life = totalHealth["stomach"], bleeding = false},
        ["right-arm"] = {life = totalHealth["right-arm"], bleeding = false, broken = false},
        ["left-arm"] = {life = totalHealth["left-arm"], bleeding = false, broken = false},
        ["right-leg"] = {life = totalHealth["right-leg"], bleeding = false, broken = false},
        ["left-leg"] = {life = totalHealth["left-leg"], bleeding = false, broken = false},
    }
end
resetHealth()

net.Receive("EFTM_player:net:server:updateHealth", function(len)
    local part = net.ReadUInt(3)
    local newHealth = net.ReadUInt(7)
    local zone = boneReplacement[part]

    if not zone then return end
    PLAYER_BODY[zone].life = newHealth
end)

net.Receive("EFTM_player:net:server:updateBleedingState", function(len)
    local part = net.ReadUInt(3)
    local newStatus = net.ReadBool()
    local zone = boneReplacement[part]

    if not zone then return end
    PLAYER_BODY[zone].bleeding = newStatus
end)

net.Receive("EFTM_player:net:server:updateBrokenState", function(len)
    local part = net.ReadUInt(3)
    local newStatus = net.ReadBool()
    local zone = boneReplacement[part]

    if not zone then return end
    PLAYER_BODY[zone].broken = newStatus
end)