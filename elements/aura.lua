--[[--
	.updateAuras(o, event, unit)
--]]--
local objects = nUF.objects

function nUF:UNIT_AURA(event, unit)
	local o = objects[unit]
	if not o or not o.updateAuras then return end
	
	o:updateAuras(event, unit)
end

-- element activation
nUF:RegisterEvent("UNIT_AURA")

table.insert(nUF.element_update, nUF.UNIT_AURA)
