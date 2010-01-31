--[[--
	.updatePortrait(o, event, unit)
--]]--
function nUF:UNIT_PORTRAIT_UPDATE(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updatePortrait then return end
	
	o:updatePortrait(event, unit)
end

-- element activation
nUF:RegisterEvent("UNIT_PORTRAIT_UPDATE")

table.insert(nUF.element_update, nUF.UNIT_PORTRAIT_UPDATE)
