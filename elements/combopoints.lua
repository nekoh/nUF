--[[--
	function:
		.updateComboPoints(o, event, unit, comboPoints)
	vars:
		.eComboPoints = GetComboPoints(unit, "target")
--]]--
local objects = nUF.objects

function nUF:UNIT_COMBO_POINTS(event, unit)
	local o
	if unit == "vehicle" then
		o = objects["player"]
	else
		o = objects[unit]
	end
	if not o or not o.updateComboPoints then return end
	
	o.eComboPoints = GetComboPoints(unit, "target")
	o:updateComboPoints(event, unit, o.eComboPoints)
end

-- element activation
nUF:RegisterEvent("UNIT_COMBO_POINTS")

table.insert(nUF.element_update, nUF.UNIT_COMBO_POINTS)
