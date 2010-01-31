--[[--
	.updatePlayerCombat(o, event, playerCombat)
	.ePlayerCombat = UnitAffectingCombat("player")
--]]--
function nUF:PLAYER_REGEN_DISABLED(event)
	local inCombat = UnitAffectingCombat("player")
	for _, o in next, nUF.objects do
		if o.updatePlayerCombat then
			o.ePlayerCombat = inCombat
			o:updatePlayerCombat(event, inCombat)
		end
	end
end
nUF.PLAYER_REGEN_ENABLED = nUF.PLAYER_REGEN_DISABLED

-- element activation
nUF:RegisterEvent("PLAYER_REGEN_DISABLED")
nUF:RegisterEvent("PLAYER_REGEN_ENABLED")

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updatePlayerCombat then return end
	
	o.ePlayerCombat = UnitAffectingCombat("player")
	o:updatePlayerCombat(event, o.ePlayerCombat)
end)
