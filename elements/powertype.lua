--[[--
	function:
		.updatePortrait(o, event, unit, powerType)
	vars:
		.ePowerType = UnitPowerType(unit)
--]]--
function nUF:UNIT_DISPLAYPOWER(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updatePowerType then return end
	
	o.ePowerType = UnitPowerType(unit)
	o:updatePowerType(event, unit, o.ePowerType)
end

-- element activation
nUF:RegisterEvent("UNIT_DISPLAYPOWER")

table.insert(nUF.element_update, nUF.UNIT_DISPLAYPOWER)
