--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	Position = {"BOTTOM", UIParent, "BOTTOM", 481, 328},
	FrameWidth = 175,
	HealthBarHeight = 20,
	PowerBarHeight = 3,
	BarTexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	Font = GameFontNormal:GetFont(),
	FontSize = 9,
}
local classSettings = {
}

-- override default settings with class settings if available
if classSettings[nUF.common.playerClass] then
	for k,v in next, classSettings[nUF.common.playerClass] do
		s[k] = v
	end
end

--------------------------------------------------------------------------------
-- UPDATE ELEMENTS -------------------------------------------------------------

local updateName = function(o, event, unit, name, server, class, lclass)
	o.NameText:SetText(name)
	nUF.common.updateTypeColor(o, event, unit)
end

local updateHealth = function(o, event, unit, curHP, maxHP, disabled, olddisabled)
	if disabled ~= olddisabled then
		local alpha = disabled and 0 or 1
		o.HealthBar:SetAlpha(alpha)
		o.HealBar:SetAlpha(alpha)
		o.HealthBarBG:SetAlpha(alpha)
		
		if disabled then
			local c = nUF.common.disabledColors[disabled]
			o.HealthText:SetText(disabled)
			o.HealthText:SetTextColor(c[1], c[2], c[3])
			return
		else
			o.HealthText:SetTextColor(1, 1, 1)
		end
	end
	
	o.HealthBar:SetMinMaxValues(0, maxHP)
	o.HealthBar:SetValue(curHP)
	
	o.HealBar:SetMinMaxValues(0, maxHP)
	o.HealBar:SetValue(curHP+o.incHeal)
	
	o.HealthText:SetFormattedText("%.1f%%", curHP/maxHP*100.0)
end 

local updateHeals = function(o, event, unit)
	o.incHeal = UnitGetIncomingHeals(unit) or 0
	if o.eDisabled then return end
	updateHealth(o, "updateHeals", unit, o.eHealth, o.eHealthMax)
end

local updatePower = function(o, event, unit, curPP, maxPP)
	o.PowerBar:SetMinMaxValues(0, maxPP)
	o.PowerBar:SetValue(curPP)
end

local updateAuras
do
	local UnitAura = UnitAura
	local setAura = nUF.common.setAura
	local getAura = nUF.common.getAura
	local coolDowns = nUF.common.coolDowns
	local size = s.HealthBarHeight+s.PowerBarHeight+3
	local auras = {}
	local buffcolor = {r=0, g=0, b=0}
	local cooldown_tables = { [2] = coolDowns.ALL }
	updateAuras = function(o, event, unit)
		local i = 0
		-- Cooldowns
		cooldown_tables[1] = coolDowns[o.eClass]
		for _, cds in next, cooldown_tables do
			for _, auraName in next, cds do
				local name, _, texture, charges, _, duration, expirationTime = UnitAura(unit, auraName, nil, "HELPFUL")
				if name then
					i = i + 1
					local aura = getAura(o, auras, i, size)
					setAura(aura, buffcolor, texture, charges, duration, expirationTime)
				end
			end
		end
		
		while auras[i+1] do
			i = i + 1
			auras[i]:Hide()
		end
		
	end
end

--------------------------------------------------------------------------------
-- FRAME STYLE + CREATION ------------------------------------------------------

local function style(o)
	o.menu = function() ToggleDropDownMenu(1, nil, _G["TargetFrameDropDown"], "cursor", 0, 0) end
	o:SetAttribute("*type2", "menu")
	
	o:SetScript("OnEnter", UnitFrame_OnEnter)
	
	o:SetBackdrop(nUF.common.framebackdrop)
	o:SetBackdropColor(0, 0, 0, 1)
	o:SetBackdropBorderColor(0, 0, 0, 0)
	
	o.Portrait = o:CreateTexture(nil, "ARTWORK")
	o.Portrait:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]])
	o.Portrait:SetWidth(s.HealthBarHeight+1+s.PowerBarHeight)
	o.Portrait:SetHeight(s.HealthBarHeight+1+s.PowerBarHeight)
	o.Portrait:SetPoint("TOPRIGHT", -2, -2)
	o.Portrait.model = CreateFrame("PlayerModel", nil, o)
	o.Portrait.model:SetAllPoints(o.Portrait)
	o.Portrait.model:SetScript("OnShow", function(self) self:SetCamera(0) end)
	
	o.HealthBarBG = o:CreateTexture(nil, "BORDER")
	o.HealthBarBG:SetTexture(s.BarTexture)
	o.HealthBarBG:SetPoint("TOPLEFT", 2, -2)
	o.HealthBarBG:SetPoint("TOPRIGHT", o.Portrait, "TOPLEFT", -1, 0)
	o.HealthBarBG:SetHeight(s.HealthBarHeight)
	
	o.HealBar = CreateFrame("StatusBar", nil, o)
	o.HealBar:SetStatusBarTexture(s.BarTexture)
	o.HealBar:SetStatusBarColor(0, 0, 0, 0.5)
	o.HealBar:SetAllPoints(o.HealthBarBG)
	
	o.HealthBar = CreateFrame("StatusBar", nil, o)
	o.HealthBar:SetStatusBarTexture(s.BarTexture)
	o.HealthBar:SetStatusBarColor(0, 0, 0, 0.7)
	o.HealthBar:SetAllPoints(o.HealthBarBG)
	
	o.PowerBar = CreateFrame("StatusBar", nil, o)
	o.PowerBar:SetStatusBarTexture(s.BarTexture)
	o.PowerBar:SetPoint("TOPLEFT", o.HealthBar, "BOTTOMLEFT", 0, -1)
	o.PowerBar:SetPoint("TOPRIGHT", o.HealthBar, "BOTTOMRIGHT", 0, -1)
	o.PowerBar:SetHeight(s.PowerBarHeight)
	
	o.PowerBarBG = o.PowerBar:CreateTexture(nil, "BORDER")
	o.PowerBarBG:SetTexture(s.BarTexture)
	o.PowerBarBG:SetAllPoints(o.PowerBar)
	o.PowerBarBG:SetAlpha(.25)
	
	local TEXT_ANCHOR = CreateFrame("Frame", nil, o)
	
	o.NameText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.NameText:SetFont(s.Font, s.FontSize, "OUTLINE")
	o.NameText:SetTextColor(1, 1, 1)
	o.NameText:SetPoint("LEFT", o.HealthBar, "LEFT", 3, 1)
	
	o.HealthText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.HealthText:SetFont(s.Font, s.FontSize, "OUTLINE")
	o.HealthText:SetTextColor(1, 1, 1)
	o.HealthText:SetPoint("RIGHT", o.HealthBar, "RIGHT", -3, 1)
	
	o.RaidTarget = TEXT_ANCHOR:CreateTexture(nil, "OVERLAY")
	o.RaidTarget:SetWidth(18)
	o.RaidTarget:SetHeight(18)
	o.RaidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	o.RaidTarget:SetPoint("CENTER", o, "TOP", 0, -3)
	
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateFaction = nUF.common.updateTypeColor
	o.updatePortrait = nUF.common.updatePortrait
	o.updateHealth = updateHealth
	o.updateHealPrediction = updateHeals
	o.incHeal = 0
	o.updatePower = updatePower
	o.updatePowerType = nUF.common.updatePowerType
	o.updateRaidTarget = nUF.common.updateRaidTarget
	o.updateAuras = updateAuras
end

local focus = nUF:NewUnit("focus", style, "nUF_focus")
focus:SetWidth(s.FrameWidth)
focus:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
focus:SetPoint(unpack(s.Position))
