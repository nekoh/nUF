--[[--
	.updateName(o, event, unit, name, server, class, localized_class, guid)
	.eName, .eServer = UnitName(unit)
	.eLClass, .eClass = UnitClass(unit)
	.eGUID = UnitGUID(unit)
--]]--
function nUF:UNIT_NAME_UPDATE(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateName then return end
	
	o.eName, o.eServer = UnitName(unit)
	o.eLClass, o.eClass = UnitClass(unit)
	o.eGUID = UnitGUID(unit)
	o:updateName(event, unit, o.eName, o.eServer, o.eClass, o.eLClass, o.eGUID)
end

-- element activation
nUF:RegisterEvent("UNIT_NAME_UPDATE")

table.insert(nUF.element_update, nUF.UNIT_NAME_UPDATE)
