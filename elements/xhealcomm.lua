--[[--
	function:
		.updateHealComm(o, event, unit, healsBefore, playerHeals, healsAfter)
--]]--
local HealComm = LibStub("LibHealComm-3.0")

local	UnitName =
		UnitName

local playerName = UnitName("player")
local playerHeals = {}
local playerTime = 0

local updateHeals = function(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		
		for unit,o in pairs(nUF.objects) do
			if o.updateHealComm then
				local uname = o.eServer and (o.eName.."-"..o.eServer) or o.eName
				if name == uname then
					local healsBefore, healsAfter = HealComm:UnitIncomingHealGet(name, playerTime)
					local healModifier = HealComm:UnitHealModifierGet(name)
					o:updateHealComm("HealUpdate", unit, (healsBefore or 0)*healModifier, (playerHeals[name] or 0)*healModifier, (healsAfter or 0)*healModifier)
				end
			end
		end
	end
end

-- LibHealComm callbacks
local function DirectHealStart(event, healerName, healSize, endTime, ...)
	if healerName == playerName then
		for i = 1, select("#", ...) do
			playerHeals[select(i, ...)] = healSize
		end
		playerTime = endTime
	end
	updateHeals(...)
end

local function DirectHealStop(event, healerName, healSize, succeeded, ...)
	if healerName == playerName then
		playerHeals = wipe(playerHeals)
	end
	updateHeals(...)
end

local function HealModifierUpdate(event, unit, targetName, healModifier)
	updateHeals(targetName)
end

-- element activation
HealComm.RegisterCallback("nUF_HealComm", "HealComm_DirectHealStart", DirectHealStart)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_DirectHealDelayed", DirectHealStart)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_DirectHealStop", DirectHealStop)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_HealModifierUpdate", HealModifierUpdate)

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateHealComm then return end
	
	local name = o.eServer and (o.eName.."-"..o.eServer) or o.eName
	local healsBefore, healsAfter = HealComm:UnitIncomingHealGet(name, playerTime)
	local healModifier = HealComm:UnitHealModifierGet(name)
	o:updateHealComm(event, unit, (healsBefore or 0)*healModifier, (playerHeals[name] or 0)*healModifier, (healsAfter or 0)*healModifier)
end)
