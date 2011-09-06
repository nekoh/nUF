nUF.common = {}

--------------------------------------------------------------------------------
-- DATA ------------------------------------------------------------------------

nUF.common.playerClass = select(2, UnitClass("player"))

-- nUF.common.missingBuffs --
-- nUF.common.coolDowns --
do
	local function spellIcon(id)
		local _, _, icon = GetSpellInfo(id)
		return icon
	end
	local function spellName(id)
		local name = GetSpellInfo(id)
		return name
	end
	
	nUF.common.missingBuffs = {}
	if nUF.common.playerClass == "PRIEST" then
		nUF.common.missingBuffs[spellIcon(21562)] = {
			spellName(21562), -- Power Word: Fortitude
			spellName(6307), -- Blood Pact
		}
		nUF.common.missingBuffs[spellIcon(27683)] = {
			spellName(27683), -- Shadow Protection
		}
	elseif nUF.common.playerClass == "MAGE" then
		nUF.common.missingBuffs[spellIcon(1459)] = {
			spellName(1459), -- Arcane Intellect
			spellName(61316), -- Dalaran Brilliance
		}
	elseif nUF.common.playerClass == "DRUID" then
		nUF.common.missingBuffs[spellIcon(1126)] = {
			spellName(1126), -- Mark of the Wild
		}
	end
	
	nUF.common.coolDowns = {
		ALL = {
			spellName(33206), -- Pain Suppression
			spellName(47788), -- Guardian Spirit
			spellName(10060), -- Power Infusion
			
			spellName(1022), -- Hand of Protection
			spellName(1044), -- Hand of Freedom
			spellName(1038), -- Hand of Salvation
		},
		DEATHKNIGHT = {
			spellName(48707), -- Anti-Magic Shell
			spellName(48792), -- Icebound Fortitude
			spellName(49039), -- Lichborne
			spellName(55233), -- Vampiric Blood
		},
		DRUID = {
			spellName(22812), -- Barkskin
			spellName(61336), -- Survival Instincts
			spellName(50334), -- Berserk
		},
		HUNTER = {
			spellName(5384), -- Feign Death
			spellName(19263), -- Deterrence
		},
		MAGE = {
			spellName(12042), -- Arcane Power
			spellName(45438), -- Ice Block
		},
		PALADIN = {
			spellName(498), -- Divine Protection
			spellName(642), -- Divine Shield
		},
		PRIEST = {
			spellName(27827), -- Spirit of Redemption
			spellName(47585), -- Dispersion
		},
		ROGUE = {
			spellName(31224), -- Cloak of Shadows
			spellName(5277), -- Evasion
		},
		SHAMAN = {
			spellName(30823), -- Shamanistic Rage
		},
		WARLOCK = {
		},
		WARRIOR = {
			spellName(871), -- Shield Wall
			spellName(2565), -- Shield Block
			spellName(12975), -- Last Stand
			spellName(23920), -- Spell Reflection
		},
	}
	spellIcon, spellName = nil, nil
end

--------------------------------------------------------------------------------
-- FRAME ELEMENTS --------------------------------------------------------------

-- nUF.common.disabledColors --
do
	nUF.common.disabledColors = {
		DEAD = {1, .1, .1},
		Ghost = {.6, .6, .6},
		Offline = {1, .5, 0},
	}
end

-- nUF.common.framebackdrop --
-- nUF.common.aurabackdrop --
do
	nUF.common.framebackdrop = {
		bgFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16,
		edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}
	nUF.common.aurabackdrop = {
		bgFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 0,
	}
end

-- nUF.common.createAura --
-- nUF.common.setAura --
do
	local DebuffTypeColor = DebuffTypeColor
	local font = GameFontNormal:GetFont()
	local fontsize = 9
	local function onAuraEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetUnitAura(self.unit, self.id, self.filter)
	end
	local function onAuraLeave()
		GameTooltip:Hide()
	end
	nUF.common.createAura = function(parent, unit, id, size, fsize, borderSize)
		local f = CreateFrame("Frame", nil, parent)
		f:SetWidth(size)
		f:SetHeight(size)
		f:SetBackdrop(nUF.common.aurabackdrop)
		f:SetBackdropColor(0, 0, 0)
		
		borderSize = borderSize or 1
		f.texture = f:CreateTexture(nil, "ARTWORK")
		f.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		f.texture:SetPoint("TOPLEFT", borderSize, -borderSize)
		f.texture:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		f.texture:Show()
		
		f.charges = f:CreateFontString(nil, "OVERLAY")
		f.charges:SetJustifyH("RIGHT")
		f.charges:SetTextColor(1, 1, 1, 1)
		f.charges:SetFont(font, fsize or fontsize, "OUTLINE")
		f.charges:SetPoint("BOTTOMRIGHT", 0, 1)
		
		f.cd = CreateFrame("Cooldown", nil, f)
		f.cd:SetReverse(true)
		f.cd:SetPoint("TOPLEFT", borderSize, -borderSize)
		f.cd:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		
		if unit and id then
			f.unit = unit
			f.id = id
			f:EnableMouse(true)
			f:SetScript("OnEnter", onAuraEnter)
			f:SetScript("OnLeave", onAuraLeave)
		end
		return f
	end
	nUF.common.setAura = function(aura, c, texture, charges, duration, expirationTime, desaturated)
		if c then aura:SetBackdropColor(c.r, c.g, c.b) end
		aura.texture:SetTexture(texture)
		--aura.texture:SetDesaturated(not not desaturated)
		
		if charges > 1 then
			aura.charges:SetText(charges)
		else
			aura.charges:SetText()
		end
		if duration and duration ~= 0 and not desaturated then
			aura.cd:SetCooldown(expirationTime-duration, duration)
		else
			aura.cd:Hide()
		end
		aura:Show()
	end
	nUF.common.getAura = function(o, auras, i, size, fsize)
		local aura = auras[i]
		if not aura then
			aura = nUF.common.createAura(o, nil, nil, size, fsize)
			if i == 1 then
				aura:SetPoint("RIGHT", o, "LEFT", 0, 0)
			else
				aura:SetPoint("RIGHT", auras[i-1], "LEFT", -1, 0)
			end
			auras[i] = aura
		end
		return aura
	end
end

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS ------------------------------------------------------------

-- nUF.common.shortValue --
do
	nUF.common.shortValue = function(value, minval)
		minval = minval or 10000
		if value < minval and value > -minval then
			return value
		elseif value < 100000 and value > -100000 then
			return ("%.1fk"):format(value / 1000)
		elseif value < 1000000 and value > -1000000 then
			return ("%.0fk"):format(value / 1000)
		elseif value < 10000000 and value > -10000000 then
			return ("%.2fm"):format(value / 1000000)
		else
			return ("%.1fm"):format(value / 1000000)
		end
	end
end

--------------------------------------------------------------------------------
-- ELEMENT UPDATER FUNCTIONS ---------------------------------------------------

-- nUF.common.updatePowerType --
do
	local powerColoring = {
		[0] = {  48/255, 113/255, 191/255}, -- Mana
		[1] = { 226/255,  45/255,  75/255}, -- Rage
		[2] = { 255/255, 210/255,   0/255}, -- Focus
		[3] = { 255/255, 220/255,  25/255}, -- Energy
		[4] = {   0/255, 255/255, 255/255}, -- Happiness
		[5] = { 128/255, 128/255, 128/255}, -- Runes
		[6] = {   0/255, 209/255, 255/255}, -- Runic Power
	}
	nUF.common.updatePowerType = function(o, event, unit, powertype)
		local c = powerColoring[powertype]
		o.PowerBar:SetStatusBarColor(c[1], c[2], c[3])
		o.PowerBarBG:SetVertexColor(c[1], c[2], c[3], .25)
	end
end

-- nUF.common.updateTypeColor --
do
	local function hostilityColor(unit)
		if UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
			if UnitCanAttack(unit, "player") then
				-- they can attack me
				if UnitCanAttack("player", unit) then
					-- and I can attack them
					return 1.0, 0.4, 0.4
				else
					-- but I can't attack them
					return 1.0, 1.0, 1.0
				end
			elseif UnitCanAttack("player", unit) then
				-- they can't attack me, but I can attack them
				return 1.0, 1.0, 0.4
			else
				-- either enemy or friend, no violence
				return 1.0, 1.0, 1.0
			end
		elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			return 0.6, 0.6, 0.6
		else
			local reaction = UnitReaction("player", unit)
			if reaction then
				return FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
			else --neutral
				return 1.0, 1.0, 1.0
			end
		end
	end
	nUF.common.updateTypeColor = function(o, event, unit)
		local isPlayer, isFriend = UnitIsPlayer(unit), UnitIsFriend("player", unit)
		
		if isPlayer then
			local c = RAID_CLASS_COLORS[o.eClass]
			o.HealthBarBG:SetVertexColor(c.r, c.g, c.b)
			if isFriend then
				o.NameText:SetTextColor(c.r, c.g, c.b)
			else
				local r, g, b = hostilityColor(unit)
				o.NameText:SetTextColor(r, g, b)
			end
		else
			local r, g, b = hostilityColor(unit)
			o.HealthBarBG:SetVertexColor(r, g, b)
			o.NameText:SetTextColor(r, g, b)
		end
		
	end
end 

-- nUF.common.updatePortrait --
do
	local classIcons = {
		["WARRIOR"] = {0.015, 0.235, 0.02, 0.235},
		["MAGE"] = {0.265, 0.48109375, 0.02, 0.235},
		["ROGUE"] = {0.51109375, 0.7271875, 0.02, 0.235},
		["DRUID"] = {0.7571875, 0.97328125, 0.02, 0.235},
		["HUNTER"] = {0.015, 0.235, 0.27, 0.485},
		["SHAMAN"] = {0.265, 0.48109375, 0.27, 0.485},
		["PRIEST"] = {0.51109375, 0.7271875, 0.27, 0.485},
		["WARLOCK"] = {0.7571875, 0.97328125, 0.27, 0.485},
		["PALADIN"] = {0.015, 0.235, 0.52, 0.735},
		["DEATHKNIGHT"] = { 0.265, 0.485, 0.515, 0.735},
	}
	nUF.common.updatePortrait = function(o, event, unit)
		if not o.Portrait.model or not UnitIsConnected(unit) or not UnitIsVisible(unit) then
			local coords = classIcons[select(2, UnitClass(unit)) or "WARRIOR"]
			o.Portrait:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
			if o.Portrait.model then
				o.Portrait.model:Hide()
			end
		else
			o.Portrait:SetTexCoord(1, 1, 1, 1)
			o.Portrait.model:SetUnit(unit)
			o.Portrait.model:SetCamera(0)
			o.Portrait.model:Show()
		end
	end
end

-- nUF.common.updateRaidTarget --
do
	nUF.common.updateRaidTarget = function(o, event, unit, index)
		SetRaidTargetIconTexture(o.RaidTarget, index)
	end
end

-- nUF.common.updateThreat --
do
	nUF.common.updateThreat = function(o, event, unit, newThreat, oldThreat)
		if newThreat < 1 then
			o:SetBackdropBorderColor(0, 0, 0, 0)
		elseif newThreat == 1 then
			o:SetBackdropBorderColor(1, .6, .1, 1)
		else
			o:SetBackdropBorderColor(1, .1, .1, 1)
		end
	end
end

-- nUF.common.updateCombatText --
do
	local maxalpha = 0.7
	local show_time = COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME + COMBATFEEDBACK_FADEOUTTIME
	local font = GameFontNormal:GetFont()
	local texts = {}
	local updateTime = 0
	local combattextframe = CreateFrame("Frame")
	combattextframe:SetScript("OnUpdate", function(self, elapsed)
		updateTime = updateTime + elapsed
		if updateTime < 0.1 then return end

		for text, time in next, texts do
			time = time - updateTime
			if time < 0 then
				text:Hide()
				texts[text] = nil
			else
				texts[text] = time
			end
		end
		updateTime = 0
		if not next(texts) then
			self:Hide()
		end
	end)
	combattextframe:Hide()
	nUF.common.updateCombatText = function(o, event, unit, eventtype, flags, amount, type)
		local scale, text = 1.0
		local r,g,b = 1,1,1
		if eventtype == "WOUND" then
			if amount ~= 0 then
				if flags == "CRITICAL" or flags == "CRUSHING" then
					scale = 1.5
				elseif flags == "GLANCING" then
					scale = .75
				end
				if UnitInParty( unit ) or UnitInRaid( unit ) then
					g,b = 0,0
				elseif type > 0 then
					b = 0
				end
				text = "-"..amount
			elseif flags == "ABSORB" or flags == "BLOCK" or flags == "RESIST" then
				scale = .75
				text = CombatFeedbackText[flags]
			else
				text = CombatFeedbackText[flags]
			end
		elseif eventtype == "HEAL" then
			text = "+"..amount
			r,b = 0,0
			if flags == "CRITICAL" then
				scale = 1.3
			end
		elseif eventtype == "IMMUNE" or eventtype == "BLOCK" then
			scale = .75
			text = CombatFeedbackText[eventtype]
		elseif eventtype == "ENERGIZE" then
			text = amount
			r,g,b = .41,.8,.94
			if flags == "CRITICAL" then
				scale = 1.3
			end
		else
			text = CombatFeedbackText[eventtype]
		end
		
		local text1 = o.CombatText
		local text2 = o.CombatText2
		if text2 and text1:IsShown() then
			text2:SetFont(font, text2.size*text1.scale, "OUTLINE")
			text2:SetText(text1:GetText())
			text2:SetTextColor(text1:GetTextColor())
			text2:SetAlpha(text1:GetAlpha())
			text2:Show()
			texts[text2] = texts[text1]
		end

		text1.scale = scale
		text1:SetFont(font, text1.size*scale, "OUTLINE")
		text1:SetText(text)
		text1:SetTextColor(r, g, b)
		text1:SetAlpha(maxalpha)
		text1:Show()
		texts[text1] = show_time

		combattextframe:Show()
	end
end
