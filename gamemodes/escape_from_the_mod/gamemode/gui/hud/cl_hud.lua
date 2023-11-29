local notifications = {}
local showWeaponSelector = 0
local notHidden = {
    ["CHudGMod"] = true, -- correspond to HUDPaint hook
}
local materials = {
    Material("eftm/icons/notification_icon_alert.png"), -- green alert
    Material("eftm/icons/notification_icon_alert_red"), -- red alert
    Material("eftm/inventory/inventory_weapon_box.png"), -- hot bar box
    Material("eftm/inventory/inventory_box.png") -- normal inventory box
}

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawText = surface.DrawText
local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect
local SetFont = surface.SetFont
local GetTextSize = surface.GetTextSize
local SetTextColor = surface.SetTextColor
local SetTextPos = surface.SetTextPos
local DrawOutlinedRect = surface.DrawOutlinedRect
local floor = math.floor

local function displayNotification()
    local scrw, scrh = ScrW(), ScrH()
    local time = RealTime()
    local width, height = 0, 0
    local x, y = 0, 0

    for k, v in ipairs(notifications) do
        if time - v.startTime >= 5 then
            table.remove(notifications, k)
            continue
        end
        SetFont("GModNotify")
        width, height = GetTextSize(v.message)
        x = scrw - width - scrw * .05
        y = scrh - height - k * scrh * .025
        SetTextColor(255, 255, 255)
        SetTextPos(x + height * 1.1, y)

        SetDrawColor(0, 0, 0, 255)
        DrawRect(x, y, scrw - x, height)
        DrawText(v.message)
        SetDrawColor(255, 255, 255, 255)
        SetMaterial(materials[v.type])
        DrawTexturedRect(x, y, height, height)
    end
end

local function displayWeaponSelector()
    if showWeaponSelector < RealTime() - 5 then return end
    local scrw, scrh = ScrW(), ScrH()
    local width, height = floor(scrw * .035), scrw * .035
    local boxCount = 11
    local weaponCount = 4
    local spaceSize = scrw * .001
    local jumpSize = spaceSize * 10
    local leftPos = 0

    SetDrawColor(34, 34, 34, 150)
    DrawRect(leftPos, scrh - height * .2, weaponCount * width + (weaponCount - 1) * spaceSize, height * .2)
    DrawRect(floor(leftPos + width * weaponCount + weaponCount * spaceSize + jumpSize), scrh - height * .2, (boxCount - weaponCount) * width + ((boxCount - weaponCount) - 1) * spaceSize + 1, height * .2)
    for i = 0, boxCount - 1, 1 do
        local space = floor(i * spaceSize)
        local x, y = i > 3 and floor(leftPos + width * i + space + jumpSize) or floor(leftPos + width * i + space), scrh - height * 1.2

        SetDrawColor(0, 0, 0, 200)
        DrawRect(x, y, width, height)
        SetDrawColor(88, 93, 96, 255)
        DrawOutlinedRect(x, y, width, height, 1)
        SetDrawColor(43, 43, 43, 255)
        DrawOutlinedRect(x + 1, y + 1, width - 2, height - 2, 1)
    end
end

hook.Add("HUDShouldDraw", "EFTM_gui:hook:client:hideHUD", function(name)
	return notHidden[name] ~= nil
end)

hook.Add("ScoreboardShow", "EFTM_gui:hook:client:hideScoreboard", function()
    return true
end)

hook.Add("ContextMenuOpen", "EFTM_gui:hook:client:hideContextMenu", function()
    return false
end)

hook.Add("HUDPaint", "EFTM_gui:client:paintHUD", function()
    displayNotification()
    displayWeaponSelector()
end)

hook.Add("PlayerBindPress", "EFTM_gui:client:checkPressedBind", function(ply, bind, pressed, code)
    if not pressed or (code ~= 112 and code ~= 113) then return end

    showWeaponSelector = RealTime()
end)

net.Receive("EFTM_gui:net:server:notify", function(len)
    local message = net.ReadString()
    local messageType = net.ReadUInt(2)

    if not message then return end

    table.insert(notifications, {message = message, type = messageType, size = string.len(message), startTime = RealTime()})
end)