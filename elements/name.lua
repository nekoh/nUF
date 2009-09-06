--[[--
	function:
		.updateName(o, event, unit, name, server)
	vars:
		.eName, .eServer = UnitName(unit)
		.eLClass, .eClass = UnitClass(unit)
--]]--
function nUF:UNIT_NAME_UPDATE(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateName then return end
	
	o.eName, o.eServer = UnitName(unit)
	o.eLClass, o.eClass = UnitClass(unit)
	o:updateName(event, unit, o.eName, o.eServer, o.eClass, o.eLClass)
end

-- element activation
nUF:RegisterEvent("UNIT_NAME_UPDATE")

table.insert(nUF.element_update, nUF.UNIT_NAME_UPDATE)
