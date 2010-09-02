--[[--
	.unit
	.id
--]]--
nUF = CreateFrame("Frame")
nUF:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

local printf = function(...) print("|cff33ff99nUF:|r ", ...) end
local noop = function() end

nUF.objects, nUF.element_init, nUF.element_update = {}, {}, {}

local UnitExists = UnitExists

local disableBlizzard = function(unit)
	if unit == "player" then
		PlayerFrame:UnregisterAllEvents()
		PlayerFrameHealthBar:UnregisterAllEvents()
		PlayerFrameManaBar:UnregisterAllEvents()
		PlayerFrame.Show = noop
		PlayerFrame:Hide()
	elseif unit == "pet" then
		PetFrame:UnregisterAllEvents()
		PetFrameHealthBar:UnregisterAllEvents()
		PetFrameManaBar:UnregisterAllEvents()
		PetFrame.Show = noop
		PetFrame:Hide()
	elseif unit == "target" then
		TargetFrame:UnregisterAllEvents()
		TargetFrameHealthBar:UnregisterAllEvents()
		TargetFrameManaBar:UnregisterAllEvents()
		TargetFrameSpellBar:UnregisterAllEvents()
		TargetFrame.Show = noop
		TargetFrame:Hide()
		ComboFrame:UnregisterAllEvents()
		ComboFrame.Show = noop
		ComboFrame:Hide()
	elseif unit == "focus" then
		FocusFrame:UnregisterAllEvents()
		FocusFrameHealthBar:UnregisterAllEvents()
		FocusFrameManaBar:UnregisterAllEvents()
		FocusFrameSpellBar:UnregisterAllEvents()
		FocusFrame.Show = noop
		FocusFrame:Hide()
	elseif unit == "targettarget" then
		TargetFrameToT:UnregisterAllEvents()
		TargetFrameToTHealthBar:UnregisterAllEvents()
		TargetFrameToTManaBar:UnregisterAllEvents()
		TargetFrameToT.Show = noop
		TargetFrameToT:Hide()
	elseif unit == "party" then
		for i=1,4 do
			local party = "PartyMemberFrame"..i
			local frame = _G[party]
			
			frame:UnregisterAllEvents()
			_G[party..'HealthBar']:UnregisterAllEvents()
			_G[party..'ManaBar']:UnregisterAllEvents()
			frame.Show = noop
			frame:Hide()
		end
	end
end

local updateElements = function(o, event)
	if not UnitExists(o.unit) then return end

	for i, f in next, nUF.element_update do
		f(nUF, event, o.unit)
	end
end
local onShow = function(o)
	nUF.objects[o.unit] = o
	updateElements(o, "OnShow")
	o:SetScript("OnEvent", updateElements)
end
local onHide = function(o)
	if not o.unit or nUF.objects[o.unit] ~= o then return end
	nUF.objects[o.unit] = nil
	o:SetScript("OnEvent", nil)
end
local onAttributeChanged = function(o, attribute, value)
	if attribute == "unit" and value then
		if not o.unit or o.unit ~= value then
			nUF.objects[value] = o
			o.unit = value
			o.id = value:match("^.-(%d+)")
			updateElements(o, "OnAttributeChanged")
		end
	end
end

local registerUpdateEvents = function(o, unit)
	if unit == "target" then
		o:RegisterEvent("PLAYER_TARGET_CHANGED")
	elseif unit == "focus" then
		o:RegisterEvent("PLAYER_FOCUS_CHANGED")
	elseif unit == "pet" then
		o:RegisterEvent("UNIT_PET")
	elseif unit == "mouseover" then
		o:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	elseif unit:match"target" then
		-- unit is invalid and needs polling mechanism
		local timer = 0
		nUF:RegisterOnUpdate(o, function(o, elapsed)
			timer = timer + elapsed
			if not o.unit then
				return
			elseif timer >= .25 then
				updateElements(o, "OnUpdate")
				timer = 0
			end
		end)
	end
end

local initObject = function(o)
	local style = o.style or o:GetParent().style

	style(o)

	o:RegisterForClicks("anydown")
	o:SetAttribute("*type1", "target")
	o:SetScript("OnAttributeChanged", onAttributeChanged)
	o:SetScript("OnShow", onShow)
	o:SetScript("OnHide", onHide)

	o:SetScript("OnEvent", updateElements)
	o:RegisterEvent("PLAYER_ENTERING_WORLD")

	for f, v in next, nUF.element_init do
		f(o)
	end

	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[o] = true
end

local multipleOnUpdate = function(o, elapsed)
	for f, _ in next, o.onUpdates do
		f(o, elapsed)
	end
end

function nUF:RegisterOnUpdate(o, func)
	if not o.onUpdates then
		o.onUpdates = {}
		o:SetScript("OnUpdate", func)
	else
		o:SetScript("OnUpdate", multipleOnUpdate)
	end
	o.onUpdates[func] = true
end

function nUF:NewUnit(unit, style, name)
	local o = CreateFrame("Button", name, UIParent, "SecureUnitButtonTemplate")
	o:SetAttribute("unit", unit)
	o.unit = unit
	o.id = unit:match("^.-(%d+)")
	o.style = style
	
	initObject(o)
	registerUpdateEvents(o, unit)

	nUF.objects[unit] = o
	RegisterUnitWatch(o)
	
	disableBlizzard(unit)
	
	return o
end

function nUF:NewHeader(style, name, isPet)
	local template
	if isPet then
		template = "SecureGroupPetHeaderTemplate"
	else
		disableBlizzard("party")
		template = "SecureGroupHeaderTemplate"
	end
	local header = CreateFrame("Frame", name, UIParent, template)
	header:SetAttribute("template", "SecureUnitButtonTemplate")
	header.initialConfigFunction = initObject
	header.style = style
	
	return header
end

function nUF:Integrity()
	for unit,o in next, nUF.objects do
		local name, server = UnitName(unit)
		if name ~= o.eName or server ~= o.eServer then
			printf("%s-%s ~=? %s-%s", name, server or 'nil', o.eName, o.eServer)
		end
	end
end
