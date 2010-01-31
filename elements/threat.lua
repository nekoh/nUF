--[[--
	.updateThreat(o, event, unit, newThreat, oldThreat)
	.eThreat = UnitThreatSituation(unit)
--]]--
local	UnitThreatSituation =
		UnitThreatSituation

function nUF:UNIT_THREAT_SITUATION_UPDATE(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateThreat then return end
	
	local oldThreat = o.eThreat or 0
	o.eThreat = UnitThreatSituation(unit) or 0
	o:updateThreat(event, unit, o.eThreat, oldThreat)
end

-- element activation
nUF:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")

table.insert(nUF.element_update, nUF.UNIT_THREAT_SITUATION_UPDATE)
