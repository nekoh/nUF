--[[--
	.updateHealAssign(o, event, unit, isHealAssigned)
--]]--
local assigns = {
}

local listener = CreateFrame("Frame")
listener:RegisterEvent("CHAT_MSG_ADDON")
listener:SetScript("OnEvent", function(self,event,prefix,msg,distribution,sender)
	if prefix == "CWCHA" and distribution == "WHISPER" then
		local target, duration = string.match(msg, "^(%S+) (%d+)$")
		local isHealAssigned = duration ~= "0"
		assigns[target] = isHealAssigned
		for unit,o in next, nUF.objects do
			if o.updateHealAssign and target == o.eName then
				o:updateHealAssign("HealAssignUpdate", unit, isHealAssigned)
			end
		end
	end
end)

table.insert(nUF.element_update, function(nUF, event, unit)
	local o = nUF.objects[unit]
	if not o or not o.updateHealAssign then return end
	
	local isHealAssigned = assigns[o.eName]
	o:updateHealAssign(event, unit, isHealAssigned)
end)