--[[--
	.updateRaidTarget(o, event, unit, raidTarget)
	.eRaidTarget = GetRaidTargetIndex(unit)
--]]--
local	GetRaidTargetIndex =
		GetRaidTargetIndex

function nUF:RAID_TARGET_UPDATE(event)
	for unit, o in next, nUF.objects do
		if o.updateRaidTarget then
			o.eRaidTarget = GetRaidTargetIndex(unit) or 0
			o:updateRaidTarget(event, unit, o.eRaidTarget)
		end
	end
end

-- element activation
nUF:RegisterEvent("RAID_TARGET_UPDATE")

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateRaidTarget then return end
	
	o.eRaidTarget = GetRaidTargetIndex(unit) or 0
	o:updateRaidTarget(event, unit, o.eRaidTarget)
end)
