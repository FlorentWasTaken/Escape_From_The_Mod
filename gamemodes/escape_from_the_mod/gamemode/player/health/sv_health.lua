local boneReplacement = {
    [0] = "stomach",
    [1] = "head",
    [2] = "thorax",
    [3] = "stomach",
    [4] = "left-arm",
    [5] = "right-arm",
    [6] = "left-leg",
    [7] = "right-leg",
    [8] = "stomach"
}

local totalHealth = {
    ["head"] = {
        total = 35,
        canBreak = false,
    },
    ["thorax"] = {
        total = 85,
        canBreak = false,
    },
    ["stomach"] = {
        total = 70,
        canBreak = false,
    },
    ["right-arm"] = {
        total = 60,
        canBreak = true,
    },
    ["left-arm"] = {
        total = 60,
        canBreak = true,
    },
    ["right-leg"] = {
        total = 65,
        canBreak = true,
    },
    ["left-leg"] = {
        total = 65,
        canBreak = true,
    }
}

local firedBullets = {}

local function getBulletDirection(pos1, pos2, ply)
	local trace = {
		start = pos1,
		endpos = pos2,
		filter = function(ent) return ent == ply end,
		ignoreworld = true
	}
	local tr = util.TraceLine(trace)

	return tr.Hit, tr.HitBox
end

hook.Add("EntityFireBullets", "EFTM:hook:server:manageDamageBullets", function(ent, data)
    if !ent:IsValid() then return end

    if #firedBullets > 20 then
        table.remove(firedBullets, 1)
    end
    table.insert(firedBullets, {entity = ent, direction = data.Dir})
end)

hook.Add("EntityTakeDamage", "EFTM:hook:server:manageDamage", function(ent, dmg)
    if !ent:IsValid() then return end
    local dmgPos = dmg:GetDamagePosition()
    local attacker = dmg:GetAttacker()

    if !attacker:IsValid() then return end
    local len = #firedBullets
    local dir = nil

    for i = len, 0, -1 do
        local tab = firedBullets[i]

        if !tab then continue end

        if tab.entity == attacker then
            dir = tab.direction
            break
        end
    end

    if !dir then return end
    local dirMul = (dir * 100)
    local hit, hitbox = getBulletDirection(dmgPos - dirMul, dmgPos + dirMul, ent)
    local hitboxbone = ent:GetHitBoxBone(hitbox, 0)

    if hit and hitboxbone != nil then
        local zone = ent:GetHitBoxHitGroup(hitbox, 0)
        local replacement = boneReplacement[zone]

        if !replacement then return end

    end
end)