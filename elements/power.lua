--[[--
	function:
		.updatePower(o, event, unit, curPP, maxPP)
	vars:
		.ePower = UnitMana(unit)
		.ePowerMax = UnitManaMax(unit)
--]]--
local objects = nUF.objects

local	UnitMana, UnitManaMax =
		UnitMana, UnitManaMax

function nUF:UNIT_MANA(event, unit)
	local o = objects[unit]
	if not o or not o.updatePower then return end
	
	o.ePower, o.ePowerMax = UnitMana(unit), UnitManaMax(unit) 
	o:updatePower(event, unit, o.ePower, o.ePowerMax)
end
nUF.UNIT_MAXMANA = nUF.UNIT_MANA
nUF.UNIT_RAGE = nUF.UNIT_MANA
nUF.UNIT_MAXRAGE = nUF.UNIT_MANA
nUF.UNIT_FOCUS = nUF.UNIT_MANA
nUF.UNIT_MAXFOCUS = nUF.UNIT_MANA
nUF.UNIT_ENERGY = nUF.UNIT_MANA
nUF.UNIT_MAXENERGY = nUF.UNIT_MANA
nUF.UNIT_RUNIC_POWER = nUF.UNIT_MANA
nUF.UNIT_MAXRUNIC_POWER = nUF.UNIT_MANA

-- element activation
nUF:RegisterEvent("UNIT_MANA")
nUF:RegisterEvent("UNIT_MAXMANA")
nUF:RegisterEvent("UNIT_RAGE")
nUF:RegisterEvent("UNIT_MAXRAGE")
nUF:RegisterEvent("UNIT_FOCUS")
nUF:RegisterEvent("UNIT_MAXFOCUS")
nUF:RegisterEvent("UNIT_ENERGY")
nUF:RegisterEvent("UNIT_MAXENERGY")
nUF:RegisterEvent("UNIT_RUNIC_POWER")
nUF:RegisterEvent("UNIT_MAXRUNIC_POWER")

table.insert(nUF.element_update, nUF.UNIT_MANA)

-- frequentUpdates
local frequentUpdate = function(o, elapsed)
	if o.eDisabled then return end
	
	local curPP = UnitMana(o.unit)
	if curPP ~= o.ePower then
		o.ePower = curPP
		if not o.ePowerMax then o.ePowerMax = UnitManaMax(o.unit) end
		o:updatePower("FrequentUpdate", o.unit, curPP, o.ePowerMax)
	end
end
nUF.element_init[function(o)
	if o.updatePower and o.updatePowerFrequent then
		nUF:RegisterOnUpdate(o, frequentUpdate)
	end
end] = true
