--[[--
	function:
		.updateInRange(o, event, unit, inRange)
	vars:
		.eInRange = UnitInRange(unit) or not UnitIsConnected(unit)
--]]--
local	UnitInRange, IsSpellInRange, UnitIsConnected =
		UnitInRange, IsSpellInRange, UnitIsConnected

if select(2,UnitClass("player")) == "PRIEST" then
	local inRange = UnitInRange
	UnitInRange = function(unit)
		return IsSpellInRange("Flash Heal", unit) == 1 or inRange(unit) -- TODO: change ?
	end
end

-- element activation
local timer = 0
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(f, elapsed)
	timer = timer + elapsed

	if timer >= .5 then
		timer = 0
		for unit, o in pairs(nUF.objects) do
			if o.updateInRange then
				local inRange = UnitInRange(unit) or not UnitIsConnected(unit)
				if inRange ~= o.eInRange then
					o.eInRange = inRange
					o:updateInRange("RangeUpdate", unit, inRange)
				end
			end
		end
	end
end)

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateInRange then return end

	o.eInRange = UnitInRange(unit) or not UnitIsConnected(unit)
	o:updateInRange(event, unit, o.eInRange)
end)
