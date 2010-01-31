--[[--
	.updateLevel(o, event, unit)
--]]--
function nUF:UNIT_LEVEL(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateLevel then return end
	
	o:updateLevel(event, unit)
end

-- element activation
nUF:RegisterEvent("UNIT_LEVEL")

table.insert(nUF.element_update, nUF.UNIT_LEVEL)
