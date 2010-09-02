--[[--
	.updateHealPrediction(o, event, unit)
--]]--
function nUF:UNIT_HEAL_PREDICTION(event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateHealPrediction then return end
	
	o:updateHealPrediction(event, unit)
end

-- element activation
nUF:RegisterEvent("UNIT_HEAL_PREDICTION")

table.insert(nUF.element_update, nUF.UNIT_HEAL_PREDICTION)
