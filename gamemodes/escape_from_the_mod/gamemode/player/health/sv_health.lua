util.AddNetworkString("EFTM_player:net:server:updateHealth")
util.AddNetworkString("EFTM_player:net:server:updateBleedingState")
util.AddNetworkString("EFTM_player:net:server:updateBrokenState")

local _player = FindMetaTable("Player")

local boneReplacement = {
    [1] = "head",
    [2] = "thorax",
    [3] = "stomach",
    [4] = "left-arm",
    [5] = "right-arm",
    [6] = "left-leg",
    [7] = "right-leg"
}

local totalHealth = {
    ["head"] = {
        total = 35,
        deadly = true,
        index = 1,
    },
    ["thorax"] = {
        total = 85,
        deadly = true,
        index = 2,
    },
    ["stomach"] = {
        total = 70,
        index = 3,
    },
    ["right-arm"] = {
        total = 60,
        canBreak = true,
        index = 4,
    },
    ["left-arm"] = {
        total = 60,
        canBreak = true,
        index = 5,
    },
    ["right-leg"] = {
        total = 65,
        canBreak = true,
        index = 6,
    },
    ["left-leg"] = {
        total = 65,
        canBreak = true,
        index = 7,
    }
}

local firedBullets = {}

local function updateBleedingState(ply, zone, status)
    if not IsValid(ply) or not boneReplacement[zone] then return end

    net.Start("EFTM_player:net:server:updateBleedingState")
        net.WriteUInt(totalHealth[zone].index, 3)
        net.WriteBool(status)
    net.Send(ply)
end

local function updateBrokenState(ply, zone, status)
    if not IsValid(ply) or not boneReplacement[zone] then return end

    net.Start("EFTM_player:net:server:updateBrokenState")
        net.WriteUInt(totalHealth[zone].index, 3)
        net.WriteBool(status)
    net.Send(ply)
end

function _player:bodyPartHealth(part, health)
    if not part or not self:Alive() then return 0 end
    if not totalHealth[part] or type(health) ~= "number" then return 0 end
    if health == nil then return self.EFTM.BODY[part].life end
    local checked = math.Clamp(health, 0, self.EFTM.BODY[part].maxLife)

    self.EFTM.BODY[part].life = checked
    self:SetHealth(self:Health() + checked)
    updatePartHealth(self, part, checked)
end

function _player:brokenPart(part, broken)
    if not part or not self:Alive() then return 0 end
    if not totalHealth[part] or type(broken) ~= "boolean" then return 0 end
    if broken == nil then return self.EFTM.BODY[part].broken end

    self.EFTM.BODY[part].broken = broken
    updateBrokenState(self, part, broken)
end

function _player:bleedingPart(part, bleeding)
    if not part or not self:Alive() then return 0 end
    if not totalHealth[part] or type(broken) ~= "boolean" then return 0 end
    if bleeding == nil then return self.EFTM.BODY[part].bleeding end

    self.EFTM.BODY[part].bleeding = bleeding
    updateBleedingState(self, part, bleeding)
end

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

function updatePartHealth(ply, zone, health)
    if not IsValid(ply) or not boneReplacement[zone] or health < 0 then return end

    net.Start("EFTM_player:net:server:updateHealth")
        net.WriteUInt(totalHealth[zone].index, 3)
        net.WriteUInt(health, 7)
    net.Send(ply)
end

local function bleedTest(ply, zone)
    if ply.EFTM.BODY[zone].bleeding or math.random(1, 10) > 2 then return end

    ply.EFTM.BLEEDING = true
    ply.EFTM.BODY[zone].bleeding = true
    updateBleedingState(ply, zone, true)
end

local function breakTest(ply, zone)
    if not totalHealth[zone].canBreak or ply.EFTM.BODY[zone].broken or math.random(1, 10) > 2 then return end

    ply.EFTM.BODY[zone].broken = true
    ply:SetRunSpeed(ply:GetRunSpeed() - ply.EFTM.DEFAULT_RUN * .2)
    ply:SetWalkSpeed(ply:GetWalkSpeed() - ply.EFTM.DEFAULT_WALK * .1)
    updateBrokenState(ply, zone, true)
end

local function dealDamage(ply, zone, dmg, ignoreBleeding)
    local health = ply:Health()
    local damage = type(dmg) == "number" and dmg or dmg:GetDamage()
    local zoneHealth = ply.EFTM.BODY[zone].life
    local lastHealth = zoneHealth - damage

    if lastHealth <= 0 and totalHealth[zone].deadly then
        ply:Kill()
    elseif lastHealth > 0 then
        ply.EFTM.BODY[zone].life = lastHealth
        if not ignoreBleeding then bleedTest(ply, zone) end
        breakTest(ply, zone)
        updatePartHealth(ply, zone, lastHealth)
    elseif lastHealth <= 0 then
        for k, v in pairs(ply.EFTM.BODY) do
            if damage <= 0 then return end

            if v.life - damage >= 0 then
                local newHealth = v.life - damage

                ply.EFTM.BODY[k].life = newHealth
                if newHealth == 0 and v.deadly then
                    return ply:Kill()
                end
                updatePartHealth(ply, k, newHealth)
                if not ignoreBleeding then bleedTest(ply, k) end
                breakTest(ply, k)
                break
            else
                local newHealth = math.Clamp(v.life - damage, 0, v.life)

                ply.EFTM.BODY[k].life = newHealth
                damage = damage - v.life
                if newHealth == 0 and v.deadly then
                    return ply:Kill()
                end
                updatePartHealth(ply, k, newHealth)
                if not ignoreBleeding then bleedTest(ply, k) end
                breakTest(ply, k)
            end
        end
    end
end

hook.Add("PlayerInitialSpawn", "EFTM:hook:server:setupPlayerHealth", function(ply, _)
    ply.EFTM = ply.EFTM or {}
    ply:SetMaxHealth(440)
    ply:SetHealth(440)
    ply.EFTM.BLEEDING = false
    ply.EFTM.BODY = {
        ["head"] = {life = totalHealth["head"].total, maxLife = totalHealth["head"].total, bleeding = false},
        ["thorax"] = {life = totalHealth["thorax"].total, maxLife = totalHealth["thorax"].total, bleeding = false},
        ["stomach"] = {life = totalHealth["stomach"].total, maxLife = totalHealth["stomach"].total, bleeding = false},
        ["right-arm"] = {life = totalHealth["right-arm"].total, maxLife = totalHealth["right-arm"].total, bleeding = false, broken = false},
        ["left-arm"] = {life = totalHealth["left-arm"].total, maxLife = totalHealth["left-arm"].total, bleeding = false, broken = false},
        ["right-leg"] = {life = totalHealth["right-leg"].total, maxLife = totalHealth["right-leg"].total, bleeding = false, broken = false},
        ["left-leg"] = {life = totalHealth["left-leg"].total, maxLife = totalHealth["left-leg"].total, bleeding = false, broken = false},
    }
end)

hook.Add("EntityFireBullets", "EFTM:hook:server:manageDamageBullets", function(ent, data)
    if not IsValid(ent) then return end

    if #firedBullets > 20 then
        table.remove(firedBullets, 1)
    end
    table.insert(firedBullets, {entity = ent, direction = data.Dir})
end)

hook.Add("EntityTakeDamage", "EFTM:hook:server:manageDamage", function(ent, dmg)
    if not IsValid(ent) then return end
    local dmgPos = dmg:GetDamagePosition()
    local attacker = dmg:GetAttacker()

    if not IsValid(attacker) then return end
    local len = #firedBullets
    local dir = nil

    for i = len, 0, -1 do
        local tab = firedBullets[i]

        if not tab then continue end

        if tab.entity == attacker then
            dir = tab.direction
            break
        end
    end

    if not dir then return end
    local dirMul = (dir * 100)
    local hit, hitbox = getBulletDirection(dmgPos - dirMul, dmgPos + dirMul, ent)
    local hitboxbone = ent:GetHitBoxBone(hitbox, 0)

    if hit and hitboxbone ~= nil then
        local zone = ent:GetHitBoxHitGroup(hitbox, 0)
        local replacement = boneReplacement[zone]

        if not replacement then replacement = "stomach" return end
        dealDamage(ent, replacement, dmg)
    end
end)

hook.Add("GetFallDamage", "EFTM:hook:server:manageFallDamage", function(ply, speed)
    local damage = math.floor(speed / 8)

    if damage % 2 ~= 0 then damage = damage + 1 end

    dealDamage(ply, "left-leg", damage * .5, true)
    dealDamage(ply, "right-leg", damage * .5, true)
    return damage
end)

hook.Add("Initialize", "EFTM:hook:server:manageBleeding", function()
    timer.Create("EFTM:timer:server:manageBleeding", 6, 0, function()
        local players = player.GetAll()

        for _, ply in ipairs(players) do
            if not IsValid(ply) or not ply.EFTM.BLEEDING then continue end
            for k, v in pairs(ply.EFTM.BODY) do
                if not v.bleeding then continue end
                local partHealth = v.life

                if partHealth - 1 >= 0 then
                    ply.EFTM.BODY[k].life = partHealth - 1
                    updatePartHealth(ply, k, partHealth - 1)
                else
                    for i, j in pairs(ply.EFTM.BODY) do
                        if j.life > 0 then
                            ply.EFTM.BODY[i].life = j.life - 1
                            updatePartHealth(ply, i, j.life - 1)
                        end
                    end
                end
                ply:SetHealth(ply:Health() - 1)
                if ply:Health() <= 0 then
                    ply:Kill()
                end
            end
        end
    end)
end)