﻿--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	Position = {"BOTTOM", UIParent, "BOTTOM", 0, 115},
	FrameWidth = 280,
	HealthBarHeight = 15,
	PowerBarHeight = 7,
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

-- Player Proccs ---------------------------------------------------------------
local playerProccs = {
	[GetSpellInfo(62659)] = "HARMFUL", -- Ulduar:General Vezax: Shadow Crash
}
if nUF.common.playerClass == "MAGE" then
--	playerProccs[GetSpellInfo(44401)] = "HELPFUL" -- Missile Barrage TODO CATA
--	playerProccs[GetSpellInfo(48108)] = "HELPFUL" -- Hot Streak TODO CATA
elseif nUF.common.playerClass == "PRIEST" then
--	playerProccs[GetSpellInfo(33151)] = "HELPFUL" -- Surge of Light TODO: gone
--	playerProccs[GetSpellInfo(34754)] = "HELPFUL" -- Holy Concentration TODO: CATA
	playerProccs[GetSpellInfo(63731)] = "HELPFUL" -- Serendipity
	playerProccs[GetSpellInfo(52795)] = "HELPFUL" -- Borrowed Time
	playerProccs[GetSpellInfo(17)] = "HELPFUL" -- Power Word: Shield
	playerProccs[GetSpellInfo(33076)] = "HELPFUL" -- Prayer of Mending
	playerProccs[GetSpellInfo(139)] = "HELPFUL|PLAYER" -- Renew
elseif nUF.common.playerClass == "DRUID" then
	playerProccs[GetSpellInfo(16870)] = "HELPFUL" -- Clearcasting
elseif nUF.common.playerClass == "WARLOCK" then
	playerProccs[GetSpellInfo(17941)] = "HELPFUL" -- Shadow Trance
	playerProccs[GetSpellInfo(64368)] = "HELPFUL" -- Eradication
	playerProccs[GetSpellInfo(71165)] = "HELPFUL" -- Molten Core
	playerProccs[GetSpellInfo(63167)] = "HELPFUL" -- Decimation
	playerProccs[GetSpellInfo(34936)] = "HELPFUL" -- Backlash
	playerProccs[GetSpellInfo(47283)] = "HELPFUL" -- Empowered Imp
	playerProccs[GetSpellInfo(54274)] = "HELPFUL" -- Backdraft
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
			spellName(588), -- Inner Fire
			spellName(73413), -- Inner Will
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
	elseif nUF.common.playerClass == "HUNTER" then
		selfBuffs[spellIcon(13165)] = {
			spellName(13165), -- Aspect of the Hawk
		}
	end
	spellIcon, spellName = nil, nil
	for icon, t in next, nUF.common.missingBuffs do
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

local updateHeals = function(o, event, unit)
	o.incHeal = UnitGetIncomingHeals(unit) or 0
	if o.eDisabled then return end
	updateHealth(o, "updateHeals", unit, o.eHealth, o.eHealthMax)
end

local updatePower
do
	updatePower = function(o, event, unit, curPP, maxPP)
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
	local createAura = nUF.common.createAura
	local setAura = nUF.common.setAura
	local getAura = nUF.common.getAura
	local dispelPrio = {}
	if nUF.common.playerClass == "PRIEST" then
		dispelPrio.Magic = 4
		dispelPrio.Disease = 1
	elseif nUF.common.playerClass == "SHAMAN" then
		dispelPrio.Curse = 3
		dispelPrio.Poison = 2
		dispelPrio.Disease = 1
	elseif nUF.common.playerClass == "PALADIN" then
		dispelPrio.Magic = 4
		dispelPrio.Poison = 2
		dispelPrio.Disease = 1
	elseif nUF.common.playerClass == "MAGE" then
		dispelPrio.Curse = 3
	elseif nUF.common.playerClass == "DRUID" then
		dispelPrio.Curse = 3
		dispelPrio.Poison = 2
	elseif nUF.common.playerClass == "WARLOCK" then
		dispelPrio.Magic = 4
	end
	local size = s.HealthBarHeight+s.PowerBarHeight+3
	local auras = {}
	local debuffs = {}
	local buffcolor = {r=0, g=0, b=0}
	updateAuras = function(o, event, unit)
		local lastprio = 0
		local dc = nil
		
		for i = 1, 32 do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, i, "HARMFUL")
			if name then
				local debuff = debuffs[i]
				if not debuff then
					debuff = createAura(o, unit, i, 33, 11, 2)
					debuff.filter = "HARMFUL"
					if i ~= 1 then
						debuff:SetPoint("LEFT", debuffs[i-1], "RIGHT", 1, 0)
					end
					debuffs[i] = debuff
				end
				if i == 1 then
					debuff:ClearAllPoints()
					if GetNumRaidMembers() > 4 then
						debuff:SetPoint("TOPLEFT", o, "BOTTOMRIGHT", 3, -1)
					else
						debuff:SetPoint("BOTTOMLEFT", o, "BOTTOMRIGHT", 3, 1)
					end
				end
				local c = DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(debuff, c, texture, charges, duration, expirationTime)
				
				local prio = dispelPrio[debuffType]
				if prio and prio > lastprio then
					lastprio = prio
					dc = c
				end
			elseif debuffs[i] then
				debuffs[i]:Hide()
			else break
			end
		end
		
		if dc then
			o:SetBackdropColor(dc.r, dc.g, dc.b, 1)
		else
			o:SetBackdropColor(0, 0, 0, 1)
		end
		
		local i = 0
		-- Self/Missing Buffs
		for texture, t in next, selfBuffs do
			local found = nil
			for i, buffName in next, t do
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
		for proccName, filter in next, playerProccs do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, proccName, nil, filter)
			if name then
				i = i + 1
				local aura = getAura(o, auras, i, size)
				local c = filter=="HELPFUL" and buffcolor or filter=="HELPFUL|PLAYER" and buffcolor or DebuffTypeColor[debuffType] or DebuffTypeColor.none
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
	o:SetAttribute("*type2", "menu")
	
	o:SetScript("OnEnter", function(...) if not o.ePlayerCombat then UnitFrame_OnEnter(...) end end)
	
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
	o.RaidTarget:SetPoint("CENTER", o, "TOP", 20, -3)
	
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
	
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateHealth = updateHealth
	o.updateHealthFrequent = true
	o.updateHealPrediction = updateHeals
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
