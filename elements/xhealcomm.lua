--[[--
	.updateHealComm(o, event, unit, healsTotal, healsPlayer, healsBefore)
--]]--
local HealComm = LibStub("LibHealComm-4.0")
local HealWithin = 3.1

local GetTime = GetTime

local playerGUID = nil
local playerTime = nil

local updateUnit = {}
local updateHeals = function(...)
	for i=1, select("#", ...) do
		updateUnit[select(i, ...)] = true
	end
	
	for unit,o in next, nUF.objects do
		if o.updateHealComm and updateUnit[o.eGUID] then
			local healsPlayer = playerTime and HealComm:GetHealAmount(o.eGUID, HealComm.CASTED_HEALS, playerTime, playerGUID) or 0
			local healsBefore = HealComm:GetOthersHealAmount(o.eGUID, HealComm.ALL_HEALS, playerTime) or 0
			local healsTotal = HealComm:GetHealAmount(o.eGUID, HealComm.ALL_HEALS, GetTime() + HealWithin) or 0
			local healModifier = HealComm:GetHealModifier(o.eGUID)
			o:updateHealComm("HealUpdate", unit, healsTotal*healModifier, healsPlayer*healModifier, healsBefore*healModifier)
		end
	end
	table.wipe(updateUnit)
end

-- LibHealComm callbacks
local HealUpdate
HealUpdate = function(...)
	playerGUID = UnitGUID("player")
	HealUpdate = function(event, casterGUID, spellID, healType, endTime, ...)
		if casterGUID == playerGUID and (healType == HealComm.DIRECT_HEALS or healType == HealComm.CHANNEL_HEALS) then
			playerTime = endTime
		end
		updateHeals(...)
	end
	HealUpdate(...)
end

local HealStop = function(event, casterGUID, spellID, healType, interruptType, ...)
	if casterGUID == playerGUID and (healType == HealComm.DIRECT_HEALS or healType == HealComm.CHANNEL_HEALS) then
		playerTime = nil
	end
	updateHeals(...)
end

local HealModifierUpdate = function(event, guid)
	updateHeals(guid)
end 
-- element activation
HealComm.RegisterCallback("nUF_HealComm", "HealComm_HealStarted", HealUpdate)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_HealUpdated", HealUpdate)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_HealDelayed", HealUpdate)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_HealStopped", HealStop)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_ModifierChanged", HealModifierUpdate)
HealComm.RegisterCallback("nUF_HealComm", "HealComm_GUIDDisappeared", HealModifierUpdate)

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateHealComm then return end
	
	local healsPlayer = playerTime and HealComm:GetHealAmount(o.eGUID, HealComm.CASTED_HEALS, playerTime, playerGUID) or 0
	local healsBefore = HealComm:GetOthersHealAmount(o.eGUID, HealComm.ALL_HEALS, playerTime) or 0
	local healsTotal = HealComm:GetHealAmount(o.eGUID, HealComm.ALL_HEALS, GetTime() + HealWithin) or 0
	local healModifier = HealComm:GetHealModifier(o.eGUID)
	o:updateHealComm(event, unit, healsTotal*healModifier, healsPlayer*healModifier, healsBefore*healModifier)
end)
