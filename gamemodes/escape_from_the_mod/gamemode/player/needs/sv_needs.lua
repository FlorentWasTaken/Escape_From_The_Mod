util.AddNetworkString("EFTM_player:net:server:updateNeeds")

local _player = FindMetaTable("Player")

local function updateNeeds(ply)
    net.Start("EFTM_player:net:server:updateNeeds")
        net.WriteUInt(ply.EFTM.NEEDS.hunger, 7)
        net.WriteUInt(ply.EFTM.NEEDS.thirst, 7)
    net.Send(ply)
end


function _player:hunger(amount)
    if amount == nil then return self.EFTM.NEEDS.hunger end
    self.EFTM.NEEDS.hunger = math.Clamp(amount, 0, 100)
    updateNeeds(self)
end

function _player:thirst(amount)
    if amount == nil then return self.EFTM.NEEDS.thirst end
    self.EFTM.NEEDS.thirst = math.Clamp(amount, 0, 100)
    updateNeeds(self)
end

local function dealNeedsDamage(ply, dmg)
    for k, v in pairs(ply.EFTM.BODY) do
        if dmg <= 0 then return end

        if v.life - dmg >= 0 then
            local newHealth = v.life - dmg
            local life = ply:Health()

            if (newHealth == 0 and v.deadly) or life - newHealth <= 0 then
                return ply:Kill()
            end
            ply.EFTM.BODY[k].life = newHealth
            ply:SetHealth(life - dmg)
            updatePartHealth(ply, k, newHealth)
            break
        else
            local newHealth = math.Clamp(v.life - dmg, 0, v.life)
            local life = ply:Health()
            local dealedDamage = v.life - newHealth

            if (newHealth == 0 and v.deadly) or life - dealedDamage <= 0 then
                return ply:Kill()
            end
            ply.EFTM.BODY[k].life = newHealth
            dmg = dmg - v.life
            ply:SetHealth(life - dealedDamage)
            updatePartHealth(ply, k, newHealth)
        end
    end
end

hook.Add("PlayerSpawn", "EFTM:hook:server:setupPlayerNeeds", function(ply, _)
    ply.EFTM.NEEDS = {
        ["hunger"] = 100,
        ["thirst"] = 100
    }
end)

hook.Add("Initialize", "EFTM:hook:server:manageNeeds", function()
    timer.Create("EFTM:timer:server:manageNeeds", 60, 0, function()
        local players = player.GetAll()

        for _, ply in ipairs(players) do
            if not IsValid(ply) or not ply.EFTM.NEEDS then continue end
            local rate = (ply.EFTM.BODY.stomach.life == 0 and 5) or 1
            local hunger = ply.EFTM.NEEDS.hunger
            local thirst = ply.EFTM.NEEDS.thirst

            if hunger == 0 then
                ply.EFTM.STAMINA_REGEN = 0
            elseif hunger - rate >= 0 then
                ply.EFTM.NEEDS.hunger = hunger - rate
            else
                ply.EFTM.NEEDS.hunger = 0
            end

            if thirst - (rate + 1) >= 0 then
                ply.EFTM.NEEDS.thirst = thirst - (rate + 1)
            else
                ply.EFTM.NEEDS.thirst = 0
            end
        end
    end)

    timer.Create("EFTM:timer:server:manageNeeds", 2, 0, function()
        local players = player.GetAll()

        for _, ply in ipairs(players) do
            if not IsValid(ply) or not ply.EFTM.NEEDS then continue end
            local hunger = ply.EFTM.NEEDS.hunger
            local thirst = ply.EFTM.NEEDS.thirst

            if hunger == 0 and thirst == 0 then
                dealNeedsDamage(ply, 2)
            elseif hunger == 0 or thirst == 0 then
                dealNeedsDamage(ply, 1)
            end
        end
    end)
end)