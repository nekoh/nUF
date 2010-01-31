--[[--
	.updateFaction(o, event, unit)
--]]--
function nUF:UNIT_FACTION(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateFaction then return end
	
	o:updateFaction(event, unit)
end

-- element activation
nUF:RegisterEvent("UNIT_FACTION")

table.insert(nUF.element_update, nUF.UNIT_FACTION)
