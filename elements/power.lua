--[[--
	.updatePower(o, event, unit, curPP, maxPP)
	.ePower = UnitPower(unit)
	.ePowerMax = UnitPowerMax(unit)
--]]--
local objects = nUF.objects

local	UnitPower, UnitPowerMax =
		UnitPower, UnitPowerMax

function nUF:UNIT_POWER(event, unit)
	local o = objects[unit]
	if not o or not o.updatePower then return end
	
	o.ePower, o.ePowerMax = UnitPower(unit), UnitPowerMax(unit) 
	o:updatePower(event, unit, o.ePower, o.ePowerMax)
end
nUF.UNIT_MAXPOWER = nUF.UNIT_POWER

-- element activation
nUF:RegisterEvent("UNIT_POWER")
nUF:RegisterEvent("UNIT_MAXPOWER")

table.insert(nUF.element_update, nUF.UNIT_POWER)

-- frequentUpdates
local frequentUpdate = function(o, elapsed)
	if o.eDisabled then return end
	
	local curPP = UnitPower(o.unit)
	if curPP ~= o.ePower then
		o.ePower = curPP
		if not o.ePowerMax then o.ePowerMax = UnitPowerMax(o.unit) end
		o:updatePower("FrequentUpdate", o.unit, curPP, o.ePowerMax)
	end
end
nUF.element_init[function(o)
	if o.updatePower and o.updatePowerFrequent then
		nUF:RegisterOnUpdate(o, frequentUpdate)
	end
end] = true
