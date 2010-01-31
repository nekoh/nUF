--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

local s = {
	FrameWidth = 208,
	HealthBarHeight = 13,
	PowerBarHeight = 1,
	BarTexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	Font = GameFontNormal:GetFont(),
	FontSize = 9,
}
local classSettings = {
	PRIEST = {
		targettargettarget = true,
	}
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

local updateHeals = function(o, event, unit, incHealTotal, incHealPlayer, incHealBefore)
	o.incHeal = incHealTotal
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
	local size = s.HealthBarHeight+s.PowerBarHeight+3
	local buffcolor = {r=0, g=0, b=0}
	updateAuras = function(o, event, unit)
		local filter = UnitIsFriend("player", unit) and "HARMFUL" or "HELPFUL"
		for i = 1, 4 do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(unit, i, filter)
			if name then
				local aura = getAura(o, o.Auras, i, size)
				local c = filter=="HELPFUL" and buffcolor or DebuffTypeColor[debuffType] or DebuffTypeColor.none
				setAura(aura, c, texture, charges, duration, expirationTime)
			elseif o.Auras[i] then
				o.Auras[i]:Hide()
			else break
			end
		end
	end
end

--------------------------------------------------------------------------------
-- FRAME STYLE + CREATION ------------------------------------------------------

local function style(o)
	o:RegisterForClicks("anyup")
	
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
	o.RaidTarget:SetWidth(14)
	o.RaidTarget:SetHeight(14)
	o.RaidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	o.RaidTarget:SetPoint("CENTER", o, "TOP", 0, -3)
	
	o.Auras = {}
	
	o:SetNormalTexture(1 ,1 , 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateHealth = updateHealth
	o.updateHealComm = updateHeals
	o.incHeal = 0
	o.updatePower = updatePower
	o.updatePowerType = nUF.common.updatePowerType
	o.updateRaidTarget = nUF.common.updateRaidTarget
	o.updateAuras = updateAuras
end

local targettarget = nUF:NewUnit("targettarget", style, "nUF_targettarget")
targettarget:SetWidth(s.FrameWidth)
targettarget:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
targettarget:SetPoint("BOTTOMRIGHT", "nUF_target", "TOPRIGHT", 0, -1)
if s.targettargettarget then
	local targettargettarget = nUF:NewUnit("targettargettarget", style, "nUF_targettargettarget")
	targettargettarget:SetWidth(s.FrameWidth)
	targettargettarget:SetHeight(s.HealthBarHeight+s.PowerBarHeight+5)
	targettargettarget:SetPoint("BOTTOMRIGHT", "nUF_targettarget", "TOPRIGHT", 0, -1)
end
