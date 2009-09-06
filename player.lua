--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	Position = {"BOTTOM", UIParent, "BOTTOM", 0, 115},
	FrameWidth = 280,
	HealthBarHeight = 15,
	PowerBarHeight = 7,
	BarTexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	Font = GameFontNormal:GetFont(),
	FontSize = 9,
	FiveSecondRule = nil,
}
local classSettings = {
	PRIEST = {
		FiveSecondRule = true,
	},
	DRUID = {
		FiveSecondRule = true,
	},
}

-- override default settings with class settings if available
if classSettings[nUF.common.playerClass] then
	for k,v in pairs(classSettings[nUF.common.playerClass]) do
		s[k] = v
	end
end

-- Player Proccs ---------------------------------------------------------------
local playerProccs = {
	[GetSpellInfo(62659)] = "HARMFUL", -- Ulduar:General Vezax: Shadow Crash
}
if nUF.common.playerClass == "MAGE" then
	playerProccs[GetSpellInfo(44401)] = "HELPFUL" -- Missile Barrage
	playerProccs[GetSpellInfo(48108)] = "HELPFUL" -- Hot Streak
elseif nUF.common.playerClass == "PRIEST" then
	playerProccs[GetSpellInfo(33151)] = "HELPFUL" -- Surge of Light
	playerProccs[GetSpellInfo(34754)] = "HELPFUL" -- Holy Concentration
	playerProccs[GetSpellInfo(63731)] = "HELPFUL" -- Serendipity
	playerProccs[GetSpellInfo(52795)] = "HELPFUL" -- Borrowed Time
elseif nUF.common.playerClass == "DRUID" then
	playerProccs[GetSpellInfo(16870)] = "HELPFUL" -- Clearcasting
end
-- Self Buffs ------------------------------------------------------------------
local selfBuffs = {}
do
	local function spellIcon(id)
		local _, _, icon = GetSpellInfo(id)
		return icon
	end
	local function spellName(id)
		local name = GetSpellInfo(id)
		return name
	end
	if nUF.common.playerClass == "PRIEST" then
		selfBuffs[spellIcon(588)] = {
			spellName(588) -- Inner Fire
		}
	elseif nUF.common.playerClass == "MAGE" then
		selfBuffs[spellIcon(30482)] = {
			spellName(30482), -- Molten Armor
			spellName(6117), -- Mage Armor
			spellName(7302), -- Ice Armor
			spellName(168), -- Frost Armor
		}
	elseif nUF.common.playerClass == "WARLOCK" then
		selfBuffs[spellIcon(28176)] = {
			spellName(28176), -- Fel Armor
			spellName(706), -- Demon Armor
		}
		selfBuffs[spellIcon(19028)] = {
			spellName(19028), -- Soul Link
		}
	elseif nUF.common.playerClass == "DRUID" then
		selfBuffs[spellIcon(467)] = {
			spellName(467), -- Thorns
		}
	end
	spellIcon, spellName = nil, nil
	for icon, t in pairs(nUF.common.missingBuffs) do
		selfBuffs[icon] = t
	end
end

--------------------------------------------------------------------------------
-- UPDATE ELEMENTS -------------------------------------------------------------

local updateName = function(o, event, unit, name, server, class, lclass)
	o.NameText:SetText(name)
	local c = RAID_CLASS_COLORS[class]
	o.HealthBarBG:SetVertexColor(c.r, c.g, c.b)
end

local updateCombatResting = function(o, event)
	if o.ePlayerCombat then
		o.NameText:SetVertexColor(1, .5, .5)
	elseif o.ePlayerResting then
		o.NameText:SetVertexColor(.9, .7, .3)
	else
		o.NameText:SetVertexColor(1, 1, 1)
	end
end

local updateHealth
do
	local shortValue = nUF.common.shortValue
	updateHealth = function(o, event, unit, curHP, maxHP, disabled, olddisabled)
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
		
		local missingHP = curHP==maxHP and "" or shortValue(curHP-maxHP)
		o.HealthText:SetFormattedText("%s|cffff7f7f%s|r / %s", shortValue(curHP), missingHP, shortValue(maxHP))
	end
end

local updateHeals = function(o, event, unit, incHealBefore, incPlayerHeal, incHealAfter)
	o.incHeal = floor(incHealBefore + incPlayerHeal + incHealAfter)
	if o.eDisabled then return end
	updateHealth(o, "updateHeals", unit, o.eHealth, o.eHealthMax)
end

local updatePower
do
	local lastPP = 0
	updatePower = function(o, event, unit, curPP, maxPP)
		if o.FiveSecondRuleBar and o.FiveSecondRuleBar.lastSpellTime then
			if curPP < lastPP then
				local elapsed = GetTime() - o.FiveSecondRuleBar.lastSpellTime
				if elapsed < .5 then
					o.FiveSecondRuleBar.timer = elapsed
					o.FiveSecondRuleBar:Show()
				end
			end
			o.FiveSecondRuleBar.lastSpellTime = nil
		end
		lastPP = curPP
		
		o.PowerBar:SetMinMaxValues(0, maxPP)
		o.PowerBar:SetValue(curPP)
		
		o.PowerText:SetFormattedText("%s / %s", curPP, maxPP)
	end
end

local updateComboPoints = function(o, event, unit, comboPoints)
	for i = 1, 5 do
		if comboPoints >= i then
			o.ComboPoint[i]:Show()
		else
			o.ComboPoint[i]:Hide()
		end
		if comboPoints == 5 then
			o.ComboPoint[i]:SetBackdropColor(1, 0, 0, 1)
		else
			o.ComboPoint[i]:SetBackdropColor(1, .6, 0, 1)
		end
	end
end

local updateThreat = function(o, event, unit, newThreat, oldThreat)
	if GetNumPartyMembers() == 0 then
		return o:SetBackdropBorderColor(0, 0, 0, 0)
	end
	
	if newThreat < 1 then
		o:SetBackdropBorderColor(0, 0, 0, 0)
	elseif newThreat == 1 then
		o:SetBackdropBorderColor(1, .6, .1, 1)
		if oldThreat < 1 then
			PlaySoundFile([[Sound\Creature\CThun\CThunYouWillDIe.wav]])
		end
	else
		o:SetBackdropBorderColor(1, .1, .1, 1)
		if oldThreat < 2 then
			PlaySoundFile([[Interface\AddOns\nUF\media\babe.wav]])
		end
	end
end

local updateAuras
do
	local UnitAura = UnitAura
	local size = s.HealthBarHeight+s.PowerBarHeight+3
	local setAura = nUF.common.setAura
	local getAura = nUF.common.getAura
	local auras = {}
	local buffcolor = {r=0, g=0, b=0}
	updateAuras = function(o, event, unit)
		local i = 0
		
		-- Self/Missing Buffs
		for texture, t in pairs(selfBuffs) do
			local found = nil
			for i, buffName in ipairs(t) do
				if UnitAura(unit, buffName, nil, "HELPFUL") then
					found = true
					break
				end
			end
			if not found then
				i = i + 1
				local aura = getAura(o, auras, i, size)
				setAura(aura, buffcolor, texture, 0)
			end
		end
		
		-- Player Proccs
		for proccName, filter in pairs(playerProccs) do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, proccName, nil, filter)
			if name then
				i = i + 1
				local aura = getAura(o, auras, i, size)
				local c = filter=="HELPFUL" and buffcolor or DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(aura, c, texture, charges, duration, expirationTime)
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
	o.menu = function() ToggleDropDownMenu(1, nil, _G["PlayerFrameDropDown"], "cursor", 0, 0) end
	o:RegisterForClicks("anyup")
	o:SetAttribute("*type2", "menu")
	
	o:SetScript("OnEnter", function(...) if not o.ePlayerCombat then UnitFrame_OnEnter(...) end end)
	o:SetScript("OnLeave", UnitFrame_OnLeave)
	
	o:RegisterForClicks("anyup")
	
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
	
	o.PowerText = o.PowerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.PowerText:SetFont(s.Font, s.FontSize)
	o.PowerText:SetTextColor(1, 1, 1)
	o.PowerText:SetPoint("CENTER", 0, 1)
	
	o.RaidTarget = TEXT_ANCHOR:CreateTexture(nil, "OVERLAY")
	o.RaidTarget:SetWidth(18)
	o.RaidTarget:SetHeight(18)
	o.RaidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	o.RaidTarget:SetPoint("CENTER", o, "TOP", 0, -3)
	
	o.CombatText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.CombatText.size = 15
	o.CombatText:SetPoint("CENTER", o.HealthBar)
	o.CombatText:Hide()
	o.CombatText2 = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.CombatText2.size = 10
	o.CombatText2:SetPoint("BOTTOM", o.CombatText, "TOP", 0, 1)
	o.CombatText2:Hide()
	
	o.ComboPoint = {}
	local width = (s.FrameWidth-4)/5
	for i = 1, 5 do
		o.ComboPoint[i] = CreateFrame("Frame", nil, o)
		o.ComboPoint[i]:SetWidth(width)
		o.ComboPoint[i]:SetHeight(3)
		o.ComboPoint[i]:SetBackdrop(nUF.common.framebackdrop)
		o.ComboPoint[i]:SetBackdropBorderColor(0, 0, 0, 1)
		if i == 1 then
			o.ComboPoint[i]:SetPoint("BOTTOMLEFT", o, "TOPLEFT", 0, 0)
		else
			o.ComboPoint[i]:SetPoint("LEFT", o.ComboPoint[i-1], "RIGHT", 1, 0)
		end
	end
	
	if s.FiveSecondRule then
		o.FiveSecondRuleBar = CreateFrame("StatusBar", nil, o.PowerBar)
		o.FiveSecondRuleBar:SetStatusBarTexture(s.BarTexture)
		o.FiveSecondRuleBar:SetStatusBarColor(1, 1, 1)
		o.FiveSecondRuleBar:SetMinMaxValues(0, 500)
		o.FiveSecondRuleBar:SetPoint("TOPLEFT", o.PowerBar, "BOTTOMLEFT", 0, 0)
		o.FiveSecondRuleBar:SetPoint("TOPRIGHT", o.PowerBar, "BOTTOMRIGHT", 0, 0)
		o.FiveSecondRuleBar:SetHeight(1)
		o.FiveSecondRuleBar:Hide()
		o.FiveSecondRuleBar:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		o.FiveSecondRuleBar:SetScript("OnEvent", function(bar, event, unit)
			if unit == "player" then
				bar.lastSpellTime = GetTime()
			end
		end)
		o.FiveSecondRuleBar.timer = 0
		o.FiveSecondRuleBar:SetScript("OnUpdate", function(bar, elapsed)
			bar.timer = bar.timer + elapsed
			if bar.timer < 5 then
				bar:SetValue(bar.timer * 100)
			else
				bar:Hide()
			end
		end)
	end
	
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateHealth = updateHealth
	o.updateHealthFrequent = true
	o.updateHealComm = updateHeals
	o.incHeal = 0
	o.updatePower = updatePower
	o.updatePowerFrequent = true
	o.updatePowerType = nUF.common.updatePowerType
	o.updateRaidTarget = nUF.common.updateRaidTarget
	o.updatePlayerCombat = updateCombatResting
	o.updatePlayerResting = updateCombatResting
	o.updateThreat = updateThreat
	o.updateCombatText = nUF.common.updateCombatText
	o.updateComboPoints = updateComboPoints
	o.updateAuras = updateAuras
end

local player = nUF:NewUnit("player", style, "nUF_player")
player:SetWidth(s.FrameWidth)
player:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
player:SetPoint(unpack(s.Position))
