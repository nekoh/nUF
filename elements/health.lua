--[[--
	.updateHealth(o, event, unit, curHP, maxHP, disabled, oldDisabled)
	.eHealth = UnitHealth(unit)
	.eHealthMax = UnitHealthMax(unit)
	.eDisabled = "DEAD", "Ghost", "Offline"
--]]--
local objects = nUF.objects

local	UnitIsDead, UnitIsGhost, UnitIsConnected =
		UnitIsDead, UnitIsGhost, UnitIsConnected
local	UnitHealth, UnitHealthMax =
		UnitHealth, UnitHealthMax

function nUF:UNIT_HEALTH(event, unit)
	local o = objects[unit]
	if not o or not o.updateHealth then return end
	
	local oldDisabled = o.eDisabled
	if UnitIsDead(unit) then
		o.eDisabled = "DEAD"
	elseif UnitIsGhost(unit) then
		o.eDisabled = "Ghost"
	elseif not UnitIsConnected(unit) then
		o.eDisabled = "Offline"
	else
		o.eDisabled = nil
	end
	if o.eDisabled then
		if o.eDisabled ~= oldDisabled then
			o:updateHealth(event, unit, nil, nil, o.eDisabled, oldDisabled)
		end
		return
	end
	
	o.eHealth, o.eHealthMax = UnitHealth(unit), UnitHealthMax(unit)
	o:updateHealth(event, unit, o.eHealth, o.eHealthMax, o.eDisabled, oldDisabled)
end
nUF.UNIT_MAXHEALTH = nUF.UNIT_HEALTH

-- element activation
nUF:RegisterEvent("UNIT_HEALTH")
nUF:RegisterEvent("UNIT_MAXHEALTH")

table.insert(nUF.element_update, nUF.UNIT_HEALTH)

-- frequentUpdates
local frequentUpdate = function(o, elapsed)
	if o.eDisabled then return end
	
	local curHP = UnitHealth(o.unit)
	if curHP ~= o.eHealth then
		o.eHealth = curHP
		if not o.eHealthMax then o.eHealthMax = UnitHealthMax(o.unit) end
		o:updateHealth("FrequentUpdate", o.unit, curHP, o.eHealthMax)
	end
end
nUF.element_init[function(o)
	if o.updateHealth and o.updateHealthFrequent then
		nUF:RegisterOnUpdate(o, frequentUpdate)
	end
end] = true
