--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	Position = {"BOTTOMRIGHT", "nUF_player", "TOPLEFT", -10, 15},
	FrameWidth = 190,
	HealthBarHeight = 19,
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
	
	o.HealthText:SetFormattedText("%.0f%%", curHP/maxHP*100.0)
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
	local size = 19
	local max_auras = floor(s.FrameWidth/(size+1))
	local buffs, debuffs = {}, {}
	updateAuras = function(o, event, unit)
		local count = 0
		-- debuffs
		for i = 1, max_auras do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, i, "HARMFUL")
			if name and max_auras > count then
				local debuff = debuffs[i]
				if not debuff then
					debuff = nUF.common.createAura(o, unit, i, size)
					debuff.filter = "HARMFUL"
					if i == 1 then
						debuff:SetPoint("BOTTOMRIGHT", o, "TOPRIGHT", 0, 0)
					else
						debuff:SetPoint("RIGHT", debuffs[i-1], "LEFT", -1, 0)
					end
					debuffs[i] = debuff
				end
				local c = DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(debuff, c, texture, charges, duration, expirationTime)
				count = count + 1
			elseif debuffs[i] then
				debuffs[i]:Hide()
			else break
			end
		end
		
		-- buffs
		for i = 1, max_auras do
			local name, _, texture, charges, _, duration, expirationTime = UnitAura(unit, i, "HELPFUL")
			if name and max_auras > count then
				local buff = buffs[i]
				if not buff then
					buff = nUF.common.createAura(o, unit, i, size)
					buff.filter = "HELPFUL"
					if i == 1 then
						buff:SetPoint("BOTTOMLEFT", o, "TOPLEFT", 0, 0)
					else
						buff:SetPoint("LEFT", buffs[i-1], "RIGHT", 1, 0)
					end
					buffs[i] = buff
				end
				setAura(buff, nil, texture, charges, duration, expirationTime)
				count = count + 1
			elseif buffs[i] then
				buffs[i]:Hide()
			else break
			end
		end
	end
end

--------------------------------------------------------------------------------
-- FRAME STYLE + CREATION ------------------------------------------------------

local function style(o)
	o.menu = function() ToggleDropDownMenu(1, nil, _G["PetFrameDropDown"], "cursor", 0, 0) end
	o:SetAttribute("*type2", "menu")

	o:SetScript("OnEnter", function(...) if not UnitAffectingCombat("player") then UnitFrame_OnEnter(...) end end)

	o:SetBackdrop(nUF.common.framebackdrop)
	o:SetBackdropColor(0, 0, 0, 1)
	o:SetBackdropBorderColor(0, 0, 0, 0)
	
	o.HealthBarBG = o:CreateTexture(nil, "BORDER")
	o.HealthBarBG:SetTexture(s.BarTexture)
	o.HealthBarBG:SetPoint("TOPLEFT", 2, -2)
	o.HealthBarBG:SetPoint("TOPRIGHT", -2, -2)
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
	
	o.CombatText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.CombatText.size = 13
	o.CombatText:SetPoint("CENTER", o.HealthBar)
	o.CombatText:Hide()
	o.CombatText2 = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.CombatText2.size = 9
	o.CombatText2:SetPoint("BOTTOM", o.CombatText, "TOP", 0, 1)
	o.CombatText2:Hide()
	
	-- set textures
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateHealth = updateHealth
	o.updateHealPrediction = updateHeals
	o.incHeal = 0
	o.updatePower = updatePower
	o.updatePowerFrequent = true
	o.updatePowerType = nUF.common.updatePowerType
	o.updateRaidTarget = nUF.common.updateRaidTarget
	o.updateThreat = nUF.common.updateThreat
	o.updateCombatText = nUF.common.updateCombatText
	o.updateAuras = updateAuras
end

local pet = nUF:NewUnit("pet", style, "nUF_pet")
pet:SetWidth(s.FrameWidth)
pet:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
pet:SetPoint(unpack(s.Position))
