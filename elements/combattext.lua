--[[--
	function:
		.updateCombatText(o, event, unit, action, flags, amount, damageType)
--]]--
local objects = nUF.objects

function nUF:UNIT_COMBAT(event, unit, action, flags, amount, damageType)
	local o = objects[unit]
	if not o or not o.updateCombatText then return end

	o:updateCombatText(event, unit, action, flags, amount, damageType)
end

-- element activation
nUF:RegisterEvent("UNIT_COMBAT")
