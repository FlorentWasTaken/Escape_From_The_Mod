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
        deadly = true,
    },
    ["thorax"] = {
        total = 85,
        deadly = true,
    },
    ["stomach"] = {
        total = 70,
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

local function dealDamage(ply, zone, dmg)
    local health = ply:Health()
    local damage = dmg:GetDamage()
    local zoneHealth = ply.EFTM.BODY[zone].life
    local lastHealth = zoneHealth - damage

    if lastHealth <= 0 && totalHealth[zone].deadly then
        ply:SetHealth(0)
    elseif lastHealth > 0 then
        ply.EFTM.BODY[zone].life = lastHealth
    end
    if !ply.EFTM.BODY[zone].bleeding then
        ply.EFTM.BODY[zone].bleeding = math.random(1, 10) <= 2
        if ply.EFTM.BODY[zone].bleeding then
            ply.EFTM.BLEEDING = true
        end
    end
end

hook.Add("PlayerSpawn", "EFTM:hook:server:setupPlayerHealth", function(ply, _)
    ply:SetMaxHealth(440)
    ply:SetHealth(440)
    ply.EFTM.BLEEDING = false
    ply.EFTM.BODY = {
        ["head"] = {life = totalHealth["head"].total, bleeding = false},
        ["thorax"] = {life = totalHealth["thorax"].total, bleeding = false},
        ["stomach"] = {life = totalHealth["stomach"].total, bleeding = false},
        ["right-arm"] = {life = totalHealth["right-arm"].total, bleeding = false, broken = false},
        ["left-arm"] = {life = totalHealth["left-arm"].total, bleeding = false, broken = false},
        ["right-leg"] = {life = totalHealth["right-leg"].total, bleeding = false, broken = false},
        ["left-leg"] = {life = totalHealth["left-leg"].total, bleeding = false, broken = false},
    }
end)

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

        if !replacement then replacement = "stomach" return end
        dealDamage(ent, replacement, dmg)
    end
end)

hook.Add("Initialize", "EFTM:hook:server:manageBleeding", function()
    timer.Create("EFTM:timer:server:manageBleeding", 6, 0, function()
        local players = player.GetAll()

        for _, ply in ipairs(players) do
            if !IsValid(ply) || !ply.EFTM.BLEEDING then continue end
            for k, v in pairs(ply.EFTM.BODY) do
                if !v.bleeding then continue end
                local partHealth = v.life

                if partHealth - 1 >= 0 then
                    ply.EFTM.BODY[k].life = partHealth - 1
                else
                    for i, j in pairs(ply.EFTM.BODY) do
                        if j.life > 0 then
                            ply.EFTM.BODY[i].life = j.life - 1
                        end
                    end
                end
                ply:SetHealth(ply:Health() - 1)
            end
        end
    end)
end)