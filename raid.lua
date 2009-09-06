--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------

-- default settings
local s = {
	Position = {"TOPLEFT", UIParent, "TOPLEFT", 848, -589},
	FrameWidth = 60,
	FrameHeight = 36,
	FrameGap = 0,
	BarTexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	NameLength = 5,
	Font = GameFontNormal:GetFont(),
	FontSize = 9,
	IconSize = 18,
	IconBorderSize = 2,
	IconAlpha = .7,
	MaxGroup = 7,
}
local classSettings = {
	PRIEST = {
		FrameWidth = 68,
		ShowHealth = true,
		FrequentHealth = true,
		NameLength = 10,
		FontSize = 10,
		ShowPets = true,
	},
	DRUID = {
		FrameWidth = 68,
		ShowHealth = true,
		FrequentHealth = true,
		NameLength = 10,
		FontSize = 10,
		ShowPets = true,
	},
}

-- override default settings with class settings if available
if classSettings[nUF.common.playerClass] then
	for k,v in pairs(classSettings[nUF.common.playerClass]) do
		s[k] = v
	end
end

-- Corners ---------------------------------------------------------------------
local cornerSetup = { }
if nUF.common.playerClass == "PRIEST" then
	cornerSetup[GetSpellInfo(139)] = { -- Renew
		size = 8,
		color = { 0,.8,0 },
		anchor = "TOPLEFT", x = 1, y = -1,
	}
	cornerSetup[GetSpellInfo(552)] = { -- Abolish Disease
		all = true,
		size = 6,
		color = { .4,.8,0 },
		anchor = "TOPLEFT", x = 8, y = -1,
	}
	cornerSetup[GetSpellInfo(33076)] = { -- Prayer of Mending
		all = true,
		size = 6,
		color = { .8,.8,0 },
		anchor = "LEFT", x = 1, y = 0,
	}
	cornerSetup[GetSpellInfo(17)] = { -- Power Word: Shield
		all = true,
		size = 8,
		color = { .8,.6,.3 },
		anchor = "BOTTOMLEFT", x = 1, y = 1,
	}
	cornerSetup[GetSpellInfo(6788)] = { -- Weakened Soul
		all = true,
		debuff = true,
		size = 6,
		color = { .8,.6,.3 },
		anchor = "BOTTOMLEFT", x = 8, y = 1,
	}
elseif nUF.common.playerClass == "DRUID" then
	cornerSetup[GetSpellInfo(774)] = { -- Rejuvenation
		size = 8,
		color = { .8,0,.4 },
		anchor = "TOPLEFT", x = 1, y = -1,
	}
	cornerSetup[GetSpellInfo(33763)] = { -- Lifebloom
		stacks = true,
		size = 8,
		color = { 0,.8,0 },
		anchor = "TOPLEFT", x = 1, y = -9,
	}
	cornerSetup[GetSpellInfo(8936)] = { -- Regrowth
		size = 8,
		color = { .4,.8,0 },
		anchor = "TOPLEFT", x = 1, y = -17,
	}
	cornerSetup[GetSpellInfo(2893)] = { -- Abolish Poison
		all = true,
		size = 6,
		color = { 0,1,0 },
		anchor = "TOPLEFT", x = 8, y = -1,
	}
	cornerSetup[GetSpellInfo(48438)] = { -- Wild Growth
		size = 6,
		color = { 0,.8,.4 },
		anchor = "RIGHT", x = -1, y = 0,
	}
end
-- Priorized Debuffs (in order) ------------------------------------------------
local prioDebuffs
do
	local function spellName(id)
		local name = GetSpellInfo(id)
		return name
	end
	prioDebuffs = {
		spellName(30108), -- Unstable Affliction
	}
	spellName = nil
end
-- Debuff BlackList ------------------------------------------------------------
local blackList = {
	[GetSpellInfo(26218)] = true, -- Mistletoe

	[GetSpellInfo(6788)] = true, -- Weakened Soul
	[GetSpellInfo(8326)] = true, -- Ghost
	[GetSpellInfo(25771)] = true, -- Forbearance
	[GetSpellInfo(41425)] = true, -- Hypothermia
	[GetSpellInfo(57724)] = true, -- Sated (Bloodlust)
	[GetSpellInfo(55711)] = true, -- Weakened Heart (Hunter)
	
	[GetSpellInfo(58539)] = true, -- Watcher's Corpse
	
	[GetSpellInfo(58105)] = true, -- Sartharion: Power of Shadron
	[GetSpellInfo(61248)] = true, -- Sartharion: Power of Tenebron
	[GetSpellInfo(61251)] = true, -- Sartharion: Power of Vesperon
	[GetSpellInfo(56438)] = true, -- Malygos: Arcane Overload
	[GetSpellInfo(28679)] = true, -- Gothik the Harvester: Harvest Soul
	[GetSpellInfo(28832)] = true, -- 4H: Mark of Korth'azz
	[GetSpellInfo(28833)] = true, -- 4H: Mark of Blaumeux
	[GetSpellInfo(28834)] = true, -- 4H: Mark of Rivendare
	[GetSpellInfo(28835)] = true, -- 4H: Mark of Zeliek
	[GetSpellInfo(28531)] = true, -- Sapphiron: Frost Aura
	[GetSpellInfo(64023)] = true, -- Razorscale: Flame Buffet
	[GetSpellInfo(62776)] = true, -- XT-002 Deconstructor: Tympanic Tantrum
	[GetSpellInfo(64236)] = true, -- XT-002 Deconstructor: Static Charged
	[GetSpellInfo(62532)] = true, -- Freya: Conservator's Grip
	[GetSpellInfo(62619)] = true, -- Freya: Pheromones
	[GetSpellInfo(62604)] = true, -- Thorim: Frostbolt Volley
	[GetSpellInfo(62692)] = true, -- General Vezax: Aura of Despair
	[GetSpellInfo(63050)] = true, -- Yogg-Saron: Sanity
	[GetSpellInfo(63038)] = true, -- Yogg-Saron: Dark Volley
	[GetSpellInfo(64145)] = true, -- Yogg-Saron: Diminish Power
	[GetSpellInfo(63138)] = true, -- Yogg-Saron: Sara's Fervor
	[GetSpellInfo(67590)] = true, -- Twin Valkyr: Powering Up
}

--------------------------------------------------------------------------------
-- UPDATE ELEMENTS -------------------------------------------------------------

local updateName = function(o, event, unit, name, server, class, lclass)
	if not class then return end
	local c = RAID_CLASS_COLORS[class]
	
	if s.ShowHealth and o.incHeal > 0 then
		o.NameText:SetText("+"..nUF.common.shortValue(o.incHeal, 1000))
		o.NameText:SetTextColor(.1, 1, .1)
	else
		o.NameText:SetText(string.utf8sub(name, 1, s.NameLength))
		o.NameText:SetTextColor(c.r, c.g, c.b)
	end
	
	if o.charmed then
		o.HealthBarBG:SetVertexColor(1, .1, .1)
	else
		o.HealthBarBG:SetVertexColor(c.r, c.g, c.b)
	end
end

local updateHealth
do
	local shortValue = nUF.common.shortValue
	updateHealth = function(o, event, unit, curHP, maxHP, disabled, olddisabled)
		if disabled ~= olddisabled then
			local alpha = disabled and 0 or 1
			o:SetBackdropColor(0, 0, 0, alpha)
			o.HealthBar:SetAlpha(alpha)
			o.HealBar:SetAlpha(alpha)
			o.HealthBarBG:SetAlpha(alpha)
			o.CenterIcon:SetAlpha(alpha)
			
			if disabled then
				local c = nUF.common.disabledColors[disabled]
				o.HealthText:SetText(disabled)
				o.HealthText:SetTextColor(c[1], c[2], c[3])
				return
			else
				local c = RAID_CLASS_COLORS[o.eClass]
				if c then o.HealthText:SetTextColor(c.r, c.g, c.b) end
			end
		end
		
		o.HealthBar:SetMinMaxValues(0, maxHP)
		o.HealthBar:SetValue(curHP)
		
		o.HealBar:SetMinMaxValues(0, maxHP)
		o.HealBar:SetValue(curHP+o.incHeal)
		
		if s.ShowHealth and (maxHP-curHP) > 999 then
			o.HealthText:SetText(shortValue(curHP-maxHP, 1000))
			local c = RAID_CLASS_COLORS[o.eClass]
			if c then o.HealthText:SetTextColor(c.r, c.g, c.b) end
		elseif not s.ShowHealth and o.incHeal > 0 then
			o.HealthText:SetFormattedText("+%s", shortValue(o.incHeal, 1000))
			o.HealthText:SetTextColor(.1, 1, .1)
		else
			o.HealthText:SetText()
		end
	end
end

local updateHeals = function(o, event, unit, incHealBefore, incPlayerHeal, incHealAfter)
	o.incHeal = floor(incHealBefore + incPlayerHeal + incHealAfter)
	
	if s.ShowHealth then
		if o.incHeal > 0 then
			o.NameText:SetText("+"..nUF.common.shortValue(o.incHeal, 1000))
			o.NameText:SetTextColor(.1, 1, .1)
		else
			updateName(o, "updateHeals", unit, o.eName, o.eServer, o.eClass, o.eLClass)
		end
	end
	if o.eDisabled then return end
	updateHealth(o, "updateHeals", unit, o.eHealth, o.eHealthMax)
end

local updateInRange = function(o, event, unit, inRange)
	if inRange then
		o:SetAlpha(1)
	else
		o:SetAlpha(.4)
	end
end

local updateAuras, updateMissingBuffs
do
	local UnitAura = UnitAura
	local setAura = nUF.common.setAura
	local coolDowns = nUF.common.coolDowns
	local missingBuffs = nUF.common.missingBuffs
	local dispelPrio = {
		Magic = 4,
		Curse = 3,
		Poison = 2,
		Disease = 1,
	}
	if nUF.common.playerClass == "PRIEST" then
		dispelPrio.Curse = nil
		dispelPrio.Poison = nil
	elseif nUF.common.playerClass == "SHAMAN" then
		dispelPrio.Magic = nil
	elseif nUF.common.playerClass == "PALADIN" then
		dispelPrio.Curse = nil
	elseif nUF.common.playerClass == "MAGE" then
		dispelPrio.Magic = nil
		dispelPrio.Poison = nil
		dispelPrio.Disease = nil
	elseif nUF.common.playerClass == "DRUID" then
		dispelPrio.Magic = nil
		dispelPrio.Disease = nil
	end
	local buffcolor = {r=0, g=0, b=0}
	local cooldown_tables = { [2] = coolDowns.ALL }
	updateAuras = function(o)
		
		-- Priorized Debuffs
		local debuff, icon
		for i, debuffName in ipairs(prioDebuffs) do
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(o.unit, debuffName, nil, "HARMFUL")
			if name then
				setAura(o.Debuff, DebuffTypeColor[debuffType] or DebuffTypeColor.none, texture, charges, duration, expirationTime)
				debuff = name
				break
			end
		end
		
		o.CenterIcon.prio = 0
		local i = 0
		repeat
			i = i + 1
			local name, _, texture, charges, debuffType, duration, expirationTime = UnitAura(o.unit, i, "HARMFUL")
			if name and name ~= debuff and not blackList[name] then
				if not debuff then
					debuff = name
					setAura(o.Debuff, DebuffTypeColor[debuffType] or DebuffTypeColor.none, texture, charges, duration, expirationTime)
				end
				
				-- Dispelable ?
				local prio = dispelPrio[debuffType]
				if prio and prio > o.CenterIcon.prio then
					o.CenterIcon.prio = prio
					icon = name
					setAura(o.CenterIcon, DebuffTypeColor[debuffType] or DebuffTypeColor.none, texture, charges, duration, expirationTime)
					if debuff == name then
						o.Debuff:Hide()
					else
						o.Debuff:Show()
					end
				elseif debuff == icon then
					debuff = name
					setAura(o.Debuff, DebuffTypeColor[debuffType] or DebuffTypeColor.none, texture, charges, duration, expirationTime)
				end
			end
		until not name
		if not debuff then o.Debuff:Hide() end
		
		updateMissingBuffs(o)
		
		-- Corners
		for auraName, corner in pairs(o.Corners) do
			local name, _, _, charges, _, duration, expirationTime, caster = UnitAura(o.unit, auraName, nil, corner.debuff and "HARMFUL" or "HELPFUL")
			if name and (corner.all or caster=="player") then
				if duration and duration ~= 0 then
					corner.cd:SetCooldown(expirationTime-duration, duration)
				else
					corner.cd:Hide()
				end
				corner:Show()
			else
				corner:Hide()
			end
		end
		
		local charmed = UnitIsCharmed(o.unit)
		if charmed ~= o.charmed then
			o.charmed = charmed
			updateName(o, "updateAuras", o.unit, o.eName, o.eServer, o.eClass, o.eLClass)
		end
		
		-- Cooldown
		cooldown_tables[1] = coolDowns[o.eClass]
		for _, cds in pairs(cooldown_tables) do
			for _, auraName in ipairs(cds) do
				local name, _, texture, charges, _, duration, expirationTime = UnitAura(o.unit, auraName, nil, "HELPFUL")
				if name then
					return setAura(o.CoolDown, nil, texture, charges, duration, expirationTime)
				end
			end
		end
		o.CoolDown:Hide()
	end
	updateMissingBuffs = function(o)
		if o.CenterIcon.prio == 0 then
			if o.ePlayerCombat then return o.CenterIcon:Hide() end
			
			for texture, t in pairs(missingBuffs) do
				local found = nil
				for i, buffName in ipairs(t) do
					if UnitAura(o.unit, buffName, nil, "HELPFUL") then
						found = true
						break
					end
				end
				if not found then
					setAura(o.CenterIcon, buffcolor, texture, 0)
					return
				end
			end
			o.CenterIcon:Hide()
		end
	end
end

--------------------------------------------------------------------------------
-- FRAME STYLE + CREATION ------------------------------------------------------

local onEnter = function(o, ...) if not o.ePlayerCombat then UnitFrame_OnEnter(o, ...) end end
local onLeave = function(o, ...)
	local _, unit = GameTooltip:GetUnit()
	if not o.unit or not unit or unit == o.unit then
		UnitFrame_OnLeave(o, ...)
	end
end
local function style(o)
	o:RegisterForClicks("anyup")
	
	o:SetScript("OnEnter", onEnter)
	o:SetScript("OnLeave", UnitFrame_OnLeave)
	
	o:SetBackdrop(nUF.common.framebackdrop)
	o:SetBackdropColor(0, 0, 0, 1)
	o:SetBackdropBorderColor(0, 0, 0, 0)
	
	o.HealthBarBG = o:CreateTexture(nil, "BORDER")
	o.HealthBarBG:SetTexture(s.BarTexture)
	o.HealthBarBG:SetPoint("TOPLEFT", 2, -2)
	o.HealthBarBG:SetPoint("BOTTOMRIGHT", -2, 2)
	
	o.HealBar = CreateFrame("StatusBar", nil, o)
	o.HealBar:SetStatusBarTexture(s.BarTexture)
	o.HealBar:SetStatusBarColor(0, 0, 0, 0.5)
	o.HealBar:SetAllPoints(o.HealthBarBG)
	
	o.HealthBar = CreateFrame("StatusBar", nil, o)
	o.HealthBar:SetStatusBarTexture(s.BarTexture)
	o.HealthBar:SetStatusBarColor(0, 0, 0, 0.7)
	o.HealthBar:SetAllPoints(o.HealthBarBG)
	
	local textheight = (s.FrameHeight-4)/2
	local TEXT_ANCHOR = CreateFrame("Frame", nil, o)
	
	o.NameText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.NameText:SetFont(s.Font, s.FontSize)
	o.NameText:SetTextColor(1, 1, 1)
	o.NameText:SetJustifyH("CENTER")
	o.NameText:SetJustifyV("CENTER")
	o.NameText:SetWidth(s.FrameWidth-4)
	o.NameText:SetHeight(textheight)
	o.NameText:SetPoint("BOTTOM", o, "CENTER")
	
	o.HealthText = TEXT_ANCHOR:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	o.HealthText:SetFont(s.Font, s.FontSize)
	o.HealthText:SetTextColor(1, 1, 1)
	o.HealthText:SetJustifyH("CENTER")
	o.HealthText:SetJustifyV("CENTER")
	o.HealthText:SetWidth(s.FrameWidth-4)
	o.HealthText:SetHeight(textheight)
	o.HealthText:SetPoint("TOP", o, "CENTER")
	
	o.CenterIcon = nUF.common.createAura(TEXT_ANCHOR, nil, nil, s.IconSize, nil, s.IconBorderSize)
	o.CenterIcon:SetAlpha(s.IconAlpha)
	o.CenterIcon:SetPoint("CENTER", o , "CENTER")
	o.CenterIcon.prio = 0
	
	o.CoolDown = nUF.common.createAura(TEXT_ANCHOR, nil, nil, 14)
	o.CoolDown:SetPoint("TOPRIGHT", o, "TOPRIGHT", -1, -1)
	
	o.Debuff = nUF.common.createAura(TEXT_ANCHOR, nil, nil, 14)
	o.Debuff:SetPoint("BOTTOMRIGHT", o, "BOTTOMRIGHT", -1, 1)
	
	o.Corners = {}
	for auraName, c in pairs(cornerSetup) do
		local corner = CreateFrame("Frame", nil, TEXT_ANCHOR)
		corner:SetWidth(c.size)
		corner:SetHeight(c.size)
		corner:SetBackdrop(nUF.common.framebackdrop)
		corner:SetBackdropBorderColor(0,0,0,1)
		corner:SetBackdropColor(c.color[1], c.color[2], c.color[3], 1)
		corner:SetPoint(c.anchor, o, c.anchor, c.x, c.y)
		corner.cd = CreateFrame("Cooldown", nil, corner)
		corner.cd:SetReverse(true)
		corner.cd:SetAllPoints(corner)
		
		corner.all = c.all
		corner.debuff = c.debuff
		--TODO corner.stacks
		
		o.Corners[auraName] = corner
	end
	
	o:SetNormalTexture(1, 1, 1, 0)
	o:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	
	-- events
	o.updateName = updateName
	o.updateHealth = updateHealth
	if s.FrequentHealth then
		o.updateHealthFrequent = true
	end
	o.updateHealComm = updateHeals
	o.incHeal = 0
	o.updatePlayerCombat = updateMissingBuffs
	o.updateThreat = nUF.common.updateThreat
	o.updateInRange = updateInRange
	o.updateAuras = updateAuras
	
	o:SetAttribute("initial-width", s.FrameWidth)
	o:SetAttribute("initial-height", s.FrameHeight)
end

local RaidGroup = {}
for i = 1, s.MaxGroup do
	RaidGroup[i] = nUF:NewHeader(style, "nUF_Raid" .. i)
	RaidGroup[i]:SetAttribute("showRaid", true)
	RaidGroup[i]:SetAttribute("showParty", true)
	RaidGroup[i]:SetAttribute("groupFilter", tostring(i))
	RaidGroup[i]:SetAttribute("yOffset", -s.FrameGap)
	if i == 1 then
		RaidGroup[i]:SetPoint(unpack(s.Position))
	else
		RaidGroup[i]:SetPoint("TOPLEFT", RaidGroup[i-1], "TOPRIGHT", s.FrameGap, 0)
	end
	RaidGroup[i]:Show()
end

if s.ShowPets then
	local PetGroup = nUF:NewHeader(style, "nUF_Pets", true)
	PetGroup:SetAttribute("showRaid", true)
	PetGroup:SetAttribute("showParty", true)
	PetGroup:SetAttribute("groupFilter", "1,2,3,4,5")
	PetGroup:SetAttribute("yOffset", -s.FrameGap)
	PetGroup:SetAttribute("maxColumns", 5)
	PetGroup:SetAttribute("unitsPerColumn", 5)
	PetGroup:SetAttribute("columnSpacing", s.FrameGap)
	PetGroup:SetAttribute("columnAnchorPoint", "LEFT")
	PetGroup:Hide()

	-- position the petframe correctly
	local petposition = CreateFrame("Frame")
	petposition:SetScript("OnEvent", function()
		if UnitAffectingCombat("player") or InCombatLockdown() then
			petposition:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			petposition:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local max = 1
			for i = 1, GetNumRaidMembers() do
				local name, rank, subgroup = GetRaidRosterInfo(i)
				if subgroup <= s.MaxGroup and max < subgroup then
					max = subgroup
				end
			end
			if max > 5 then
				PetGroup:Hide()
			else
				PetGroup:ClearAllPoints()
				PetGroup:SetPoint("TOPLEFT", RaidGroup[max], "TOPRIGHT", 3+s.FrameGap, 0)
				PetGroup:Show()
			end
		end
	end)
	petposition:RegisterEvent("PARTY_MEMBERS_CHANGED")
	petposition:RegisterEvent("PARTY_LEADER_CHANGED")
	petposition:RegisterEvent("RAID_ROSTER_UPDATE")
	petposition:RegisterEvent("PLAYER_LOGIN")
end
