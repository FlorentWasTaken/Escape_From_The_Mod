local boneReplacement = {
	["ValveBiped.Bip01_Neck1"] = "head",
    ["ValveBiped.Bip01_Head1"] = "head",
    ["ValveBiped.Bip01_Pelvis"] = "stomach",
	["ValveBiped.Bip01_Spine"] = "thorax",
	["ValveBiped.Bip01_Spine1"] = "thorax",
    ["ValveBiped.Bip01_Spine2"] = "thorax",
	["ValveBiped.Bip01_Spine4"] = "thorax",
	["ValveBiped.Bip01_R_Clavicle"] = "thorax",
	["ValveBiped.Bip01_L_Clavicle"] = "thorax",
	["ValveBiped.Bip01_R_Shoulder"] = "right-arm",
	["ValveBiped.Bip01_L_Shoulder"] = "left-arm",
    ["ValveBiped.Bip01_R_Forearm"] = "right-arm",
    ["ValveBiped.Bip01_L_Forearm"] = "left-arm",
    ["ValveBiped.Bip01_R_Hand"] = "right-arm",
    ["ValveBiped.Bip01_L_Hand"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger0"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger01"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger02"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger1"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger11"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger12"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger2"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger21"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger22"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger3"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger31"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger32"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger4"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger41"] = "left-arm",
    ["ValveBiped.Bip01_L_Finger42"] = "left-arm",
    ["ValveBiped.Bip01_R_Finger0"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger01"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger02"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger1"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger11"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger12"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger2"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger21"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger22"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger3"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger31"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger32"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger4"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger41"] = "right-arm",
    ["ValveBiped.Bip01_R_Finger42"] = "right-arm",
    ["ValveBiped.Bip01_R_Calf"] = "right-leg",
    ["ValveBiped.Bip01_L_Calf"] = "left-leg",
    ["ValveBiped.Bip01_R_Foot"] = "right-leg",
    ["ValveBiped.Bip01_L_Foot"] = "left-leg",
    ["ValveBiped.Bip01_R_Thigh"] = "right-leg",
    ["ValveBiped.Bip01_L_Thigh"] = "left-leg",
	["ValveBiped.Bip01_R_Toe0"] = "right-leg",
	["ValveBiped.Bip01_L_Toe0"] = "left-leg"
}

local totalHealth = {
    ["head"] = {
        total = 35,
    },
    ["thorax"] = {
        total = 85,
    },
    ["stomach"] = {
        total = 70,
    },
    ["right-arm"] = {
        total = 60,
    },
    ["left-arm"] = {
        total = 60,
    },
    ["right-leg"] = {
        total = 65,
    },
    ["left-leg"] = {
        total = 65,
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

    for i = len, len, -1 do
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
        local bone = ent:GetBoneName(hitboxbone)

        if !boneReplacement[bone] then return end
        // damage function here
    end
end)