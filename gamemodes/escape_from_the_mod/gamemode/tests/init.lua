local function configTests()
    if not assert(EFTM ~= nil, "EFTM table isn't init") then return false end
    if not assert(EFTM.CONFIG ~= nil, "EFTM.CONFIG table isn't init") then return false end
    if not assert(EFTM.CONFIG.MAP ~= nil, "EFTM.CONFIG.MAP table isn't init") then return false end
    if not assert(EFTM.CONFIG.LANGUAGE ~= nil, "EFTM.CONFIG.LANGUAGE isn't init") then return false end
    if not assert(EFTM.CONFIG.LANG ~= nil, "EFTM.CONFIG.LANG isn't init") then return false end
    return true
end
