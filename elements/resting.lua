--[[--
	function:
		.updatePlayerResting(o, event, unit)
	vars:
		.ePlayerResting = IsResting()
--]]--
function nUF:PLAYER_UPDATE_RESTING(event)
	local resting = IsResting()
	for unit, o in pairs(nUF.objects) do
		if o.updatePlayerResting then
			o.ePlayerResting = resting
			o:updatePlayerResting(event, resting)
		end
	end
end

-- element activation
nUF:RegisterEvent("PLAYER_UPDATE_RESTING")

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updatePlayerResting then return end
	
	o.ePlayerResting = IsResting()
	o:updatePlayerResting(event, o.ePlayerResting)
end)
