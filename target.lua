--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	Position = {"BOTTOM", UIParent, "BOTTOM", 0, 215},
	FrameWidth = 280,
	HealthBarHeight = 19,
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

-- Important Player Buffs ------------------------------------------------------
local playerBuffs = {}
if nUF.common.playerClass == "PRIEST" then
	playerBuffs[GetSpellInfo(17)] = 2 -- Power Word: Shield
	playerBuffs[GetSpellInfo(33076)] = 2 -- Prayer of Mending
	playerBuffs[GetSpellInfo(552)] = 2 -- Ablish Disease
	playerBuffs[GetSpellInfo(139)] = 1 -- Renew
elseif nUF.common.playerClass == "DRUID" then
	playerBuffs[GetSpellInfo(2893)] = 2 -- Ablish Poison
	playerBuffs[GetSpellInfo(774)] = 1 -- Rejuvenation
	playerBuffs[GetSpellInfo(33763)] = 1 -- Lifebloom
	playerBuffs[GetSpellInfo(8936)] = 1 -- Regrowth
end
-- Important Player Debuffs ----------------------------------------------------
local playerDebuffs = {
	[GetSpellInfo(65280)] = 2, -- Hodir: Singed
}
if nUF.common.playerClass == "MAGE" then
	playerDebuffs[GetSpellInfo(22959)] = 2 -- Improved Scorch
	playerDebuffs[GetSpellInfo(12579)] = 2 -- Winter's Chill
	
	playerDebuffs[GetSpellInfo(44457)] = 1 -- Living Bomb
elseif nUF.common.playerClass == "PRIEST" then
	playerDebuffs[GetSpellInfo(6788)] = 2 -- Weakened Soul
	
	playerDebuffs[GetSpellInfo(589)] = 1 -- Shadow Word: Pain
	playerDebuffs[GetSpellInfo(2944)] = 1 -- Devouring Plague
	playerDebuffs[GetSpellInfo(15286)] = 1 -- Vampiric Embrace
	playerDebuffs[GetSpellInfo(34914)] = 1 -- Vampiric Touch
elseif nUF.common.playerClass == "WARLOCK" then
	playerDebuffs[GetSpellInfo(17800)] = 2 -- Shadow Mastery
	playerDebuffs[GetSpellInfo(22959)] = 2 -- Improved Scorch
	playerDebuffs[GetSpellInfo(12579)] = 2 -- Winter's Chill
	playerDebuffs[GetSpellInfo(1490)] = 2 -- Curse of Elements
	playerDebuffs[GetSpellInfo(60433)] = 2 -- Earth and Moon
	playerDebuffs[GetSpellInfo(51735)] = 2 -- Ebon Plague
elseif nUF.common.playerClass == "DRUID" then
	playerDebuffs[GetSpellInfo(5570)] = 1 -- Insect Swarm
	playerDebuffs[GetSpellInfo(8921)] = 1 -- Moonfire
end

--------------------------------------------------------------------------------
-- UPDATE ELEMENTS -------------------------------------------------------------

local updateName = function(o, event, unit, name, server, class, lclass)
	o.NameText:SetText(name)
	nUF.common.updateTypeColor(o, event, unit)
end

local updateInfo
do
	local classhex = {}
	do
		for class, c in next, RAID_CLASS_COLORS do
			classhex[class] = ("%02X%02X%02X"):format(c.r * 255, c.g * 255, c.b * 255)
		end
	end
	updateInfo = function(o, event, unit)
		local level, class = UnitLevel(unit)
		if not UnitCanAttack("player", unit) then
			o.InfoText:SetTextColor(1, 1, 1)
		elseif level > 0 then
			local c = GetQuestDifficultyColor(level)
			o.InfoText:SetTextColor(c.r, c.g, c.b)
		else
			o.InfoText:SetTextColor(1, .3, .3)
		end
		if level <= 0 then
			level = "??"
		end
		if UnitIsPlayer(unit) then
			class = ("|cff%s%s|r"):format(classhex[o.eClass] or "ffffff", o.eLClass or UNKNOWN)
		else
			class = UnitClassification(unit)
			if class == "elite" then
				level = level.."+"
			elseif class == "rare" then
				level = level.." Rare"
			elseif class == "rareelite" then
				level = level.."+ Rare"
			elseif class == "worldboss" then
				level = "BOSS"
			end
			class = UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN
		end
		o.InfoText:SetFormattedText("%s %s", level, class)
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
		
		if o.incPlayerHeal > 0 then
			local barwidth = o.HealthBar:GetWidth()
			local modifier = barwidth / maxHP
			local pos = min((curHP + o.incHealBefore) * modifier, barwidth)
			local width = o.incPlayerHeal * modifier
			o.MyHealBar:ClearAllPoints()
			o.MyHealBar:SetPoint("LEFT", o.HealthBar, "LEFT", pos, 0)
			o.MyHealBar:SetWidth(width)
			o.MyHealBar:Show()
		else
			o.MyHealBar:Hide()
		end
		
		if UnitCanAttack("player", unit) then
			o.HealthText:SetFormattedText("%s / %s  %.1f", shortValue(curHP), shortValue(maxHP), curHP/maxHP*100)
		else
			local missingHP = curHP==maxHP and "" or shortValue(curHP-maxHP)
			o.HealthText:SetFormattedText("%s|cffff7f7f%s|r / %s", shortValue(curHP), missingHP, shortValue(maxHP))
		end
	end
end

local updateHeals = function(o, event, unit, incHealTotal, incHealPlayer, incHealBefore)
	o.incHeal = incHealTotal
	
	o.incHealBefore = incHealBefore
	o.incPlayerHeal = incHealPlayer
	if o.incHeal > 0 then
		o.HealText:SetFormattedText("+%s", nUF.common.shortValue(o.incHeal))
	else
		o.HealText:SetText()
	end
	if o.eDisabled then return end
	updateHealth(o, "updateHeals", unit, o.eHealth, o.eHealthMax)
end

local updatePower = function(o, event, unit, curPP, maxPP)
	o.PowerBar:SetMinMaxValues(0, maxPP)
	o.PowerBar:SetValue(curPP)
	
	if maxPP == 0 then
		o.PowerText:SetText()
	else
		o.PowerText:SetFormattedText("%s / %s", curPP, maxPP)
	end
end

local updateAuras
do
	local UnitAura = UnitAura
	local createAura = nUF.common.createAura
	local setAura = nUF.common.setAura
	local getAura = nUF.common.getAura
	local coolDowns = nUF.common.coolDowns
	local size, isize = 19, s.HealthBarHeight+s.PowerBarHeight+3
	local buffs, debuffs, iauras = {}, {}, {}
	local auras_per_row = floor(s.FrameWidth/(size+1))
	local buffcolor = {r=0, g=0, b=0}
	local last_lines = 0
	local cooldown_tables = { [2] = coolDowns.ALL }
	updateAuras = function(o, event, unit)
		local count = 0
		-- debuffs
		for i = 1, 32 do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, i, "HARMFUL")
			if name then
				count = count + 1
				local debuff = debuffs[i]
				if not debuff then
					debuff = createAura(o, unit, i, size)
					debuff.filter = "HARMFUL"
					if i == 1 then
						debuff:SetPoint("TOPRIGHT", o, "BOTTOMRIGHT", 0, 0)
					elseif i > auras_per_row then
						debuff:SetPoint("BOTTOM", debuffs[i-auras_per_row], "TOP", 0, 1)
					else
						debuff:SetPoint("RIGHT", debuffs[i-1], "LEFT", -1, 0)
					end
					debuffs[i] = debuff
				end
				local c = DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(debuff, c, texture, charges, duration, expirationTime)
			elseif debuffs[i] then
				debuffs[i]:Hide()
			else break
			end
		end
		
		-- buffs
		for i = 1, 32 do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, i, "HELPFUL")
			if name then
				count = count + 1
				local buff = buffs[i]
				if not buff then
					buff = createAura(o, unit, i, size)
					buff.filter = "HELPFUL"
					if i == 1 then
						buff:SetPoint("TOPLEFT", o, "BOTTOMLEFT", 0, 0)
					elseif i > auras_per_row then
						buff:SetPoint("TOP", buffs[i-auras_per_row], "BOTTOM", 0, -1)
					else
						buff:SetPoint("LEFT", buffs[i-1], "RIGHT", 1, 0)
					end
					buffs[i] = buff
				end
				setAura(buff, nil, texture, charges, duration, expirationTime)
			elseif buffs[i] then
				buffs[i]:Hide()
			else break
			end
		end
		
		-- rearrange
		local lines = count > 0 and floor((count-1)/auras_per_row) or 0
		if last_lines ~= lines then
			last_lines = lines

			if debuffs[1] then
				debuffs[1]:ClearAllPoints()
				debuffs[1]:SetPoint("TOPRIGHT", o, "BOTTOMRIGHT", 0, -(size+1)*lines)
			end
		end
		
		local i = 0
		-- Cooldowns
		cooldown_tables[1] = coolDowns[o.eClass]
		for _, cds in next, cooldown_tables do
			for _, auraName in next, cds do
				local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, auraName, nil, "HELPFUL")
				if name then
					i = i + 1
					local aura = getAura(o, iauras, i, isize, 12)
					setAura(aura, buffcolor, texture, charges, duration, expirationTime)
				end
			end
		end
		-- Player Buffs
		for auraName, self in next, playerBuffs do
			local name, _, texture, charges, debuffType, duration, expirationTime, caster = UnitAura(unit, auraName, nil, "HELPFUL")
			if name and (self==2 or caster=="player") then
				i = i + 1
				local aura = getAura(o, iauras, i, isize, 12)
				setAura(aura, buffcolor, texture, charges, duration, expirationTime)
			end
		end
		-- Player Debuffs
		for auraName, self in next, playerDebuffs do
			local name, _, texture, charges, debuffType, duration, expirationTime, caster = UnitAura(unit, auraName, nil, "HARMFUL")
			if name and (self==2 or caster=="player") then
				i = i + 1
				local aura = getAura(o, iauras, i, isize, 12)
				local c = DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(aura, c, texture, charges, duration, expirationTime)
			end
		end
		
		while iauras[i+1] do
			i = i + 1
			iauras[i]:Hide()
		end
		
	end
end

--------------------------------------------------------------------------------
-- FRAME STYLE + CREATION ------------------------------------------------------

local function style(o)
	o.menu = function() ToggleDropDownMenu(1, nil, _G["TargetFrameDropDown"], "cursor", 0, 0) end
	o:RegisterForClicks("anyup")
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
	
	o.MyHealBar = o:CreateTexture(nil, "ARTWORK")
	o.MyHealBar:SetTexture(s.BarTexture)
	o.MyHealBar:SetVertexColor(0.1, 1, 0.1, 0.8)
	o.MyHealBar:SetHeight(s.HealthBarHeight*.8)
	o.MyHealBar:Hide()
	
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
	
	o.HealText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.HealText:SetFont(s.Font, s.FontSize, "OUTLINE")
	o.HealText:SetTextColor(.1, 1, .1)
	o.HealText:SetPoint("BOTTOMRIGHT", o.HealthText, "TOPRIGHT", 0, 1)
	
	o.InfoText = o.PowerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.InfoText:SetFont(s.Font, s.FontSize)
	o.InfoText:SetTextColor(1, 1, 1)
	o.InfoText:SetPoint("LEFT", 3, 1)
	
	o.PowerText = o.PowerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.PowerText:SetFont(s.Font, s.FontSize)
	o.PowerText:SetTextColor(1, 1, 1)
	o.PowerText:SetPoint("RIGHT", -3, 1)
	
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
	
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateFaction = nUF.common.updateTypeColor
	o.updatePortrait = nUF.common.updatePortrait
	o.updateHealth = updateHealth
	o.updateHealthFrequent = true
	o.updateHealComm = updateHeals
	o.incHeal, o.incPlayerHeal = 0, 0
	o.updatePower = updatePower
	o.updatePowerFrequent = true
	o.updatePowerType = nUF.common.updatePowerType
	o.updateLevel = updateInfo
	o.updateRaidTarget = nUF.common.updateRaidTarget
	o.updateThreat = nUF.common.updateThreat
	o.updateCombatText = nUF.common.updateCombatText
	o.updateAuras = updateAuras
end

local target = nUF:NewUnit("target", style, "nUF_target")
target:SetWidth(s.FrameWidth)
target:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
target:SetPoint(unpack(s.Position))
