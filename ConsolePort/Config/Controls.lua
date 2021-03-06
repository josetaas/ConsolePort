---------------------------------------------------------------
-- Controls.lua: Base config, reset buttons, triggers, cvars
---------------------------------------------------------------
-- Creates the base config panel and account-wide cvar options.

local _, db = ...
---------------------------------------------------------------
		-- Resource tables.
local 	Settings, TUTORIAL, TEXTURE, ICONS,
		-- Fade wrappers
		FadeIn, FadeOut,
		-- Table functions
		Mixin, spairs,
		-- Mixins
		Catcher, CheckButton, PopupMixin, WindowMixin = 
		-------------------------------------
		nil, db.TUTORIAL, db.TEXTURE, db.ICONS,
		db.UIFrameFadeIn, db.UIFrameFadeOut,
		db.table.mixin, db.table.spairs,
		{}, {}, {}, {}
---------------------------------------------------------------
-- Controls: Account-wide addon CVars.
---------------------------------------------------------------
local function GetAddonSettings()
	return {
		{
			desc = TUTORIAL.CONFIG.MOUSEHANDLE,
		},
		{	cvar = "turnCharacter",
			desc = TUTORIAL.CONFIG.TURNMOVE,
			toggle = Settings.turnCharacter,
			needReload = true, 
		},
		{
			cvar = "preventMouseDrift",
			desc = TUTORIAL.CONFIG.MOUSEDRIFTING,
			toggle = Settings.preventMouseDrift,
		},
		{
			cvar = "doubleModTap",
			desc = format(TUTORIAL.CONFIG.DOUBLEMODTAP, ICONS.CP_M1, ICONS.CP_M2),
			toggle = Settings.doubleModTap,
		},
		{
			cvar = "lookAround",
			desc = format(TUTORIAL.CONFIG.LOOKAROUND, ICONS.CP_T_L3),
			toggle = Settings.disableSmartMouse
		},
		{	cvar = "disableSmartMouse",
			desc = TUTORIAL.CONFIG.DISABLEMOUSE,
			toggle = Settings.disableSmartMouse,
		},
		{
			desc = TUTORIAL.CONFIG.CONVENIENCE,
		},
		{	cvar = "autoExtra",
			desc = TUTORIAL.CONFIG.AUTOEXTRA,
			toggle = Settings.autoExtra,
		},
		{
			cvar = "cameraDistanceMoveSpeed",
			desc = TUTORIAL.CONFIG.FASTCAM,
			toggle = Settings.cameraDistanceMoveSpeed,
		},
		{
			cvar = "autoLootDefault",
			desc = TUTORIAL.CONFIG.AUTOLOOT,
			toggle = Settings.autoLootDefault,
		},
		{
			cvar = "autoSellJunk",
			desc = TUTORIAL.CONFIG.AUTOSELL,
			toggle = Settings.autoSellJunk,
		},
		{
			cvar = "disableMenu",
			desc = TUTORIAL.CONFIG.CPMENU,
			toggle = Settings.disableMenu,
			needReload = true,
		},
		{
			cvar = "disableHints",
			desc = TUTORIAL.HINTS.DISABLE,
			toggle = Settings.disableHints,
		},
		-- Mouse "events" to the user, but cvars internally
		{
			mouse = true,
			cvar = "mouseOnJump",
			desc = TUTORIAL.MOUSE.JUMPING,
			toggle = Settings.mouseOnJump,
		},
		{
			mouse = true,
			cvar = "mouseOnCenter",
			desc = TUTORIAL.MOUSE.CENTERCURSOR,
			toggle = Settings.mouseOnCenter,
		},
	}
end
---------------------------------------------------------------
-- Mouse: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	return {
		{ 	event 	= {"PLAYER_STARTED_MOVING"},
			desc 	= TUTORIAL.MOUSE.STARTED_MOVING,
			toggle 	= db.Mouse.Events["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= TUTORIAL.MOUSE.TARGET_CHANGED,
			toggle 	= db.Mouse.Events["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_FAILED"},
			desc 	= TUTORIAL.MOUSE.DIRECT_SPELL_CAST,
			toggle 	= db.Mouse.Events["UNIT_SPELLCAST_SENT"]
		},
		{	event 	= {	"GOSSIP_SHOW", "GOSSIP_CLOSED",
						"MERCHANT_SHOW", "MERCHANT_CLOSED",
						"TAXIMAP_OPENED", "TAXIMAP_CLOSED",
						"QUEST_GREETING", "QUEST_DETAIL",
						"QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED",
						"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= TUTORIAL.MOUSE.NPC_INTERACTION,
			toggle 	= db.Mouse.Events["GOSSIP_SHOW"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= TUTORIAL.MOUSE.QUEST_AUTOCOMPLETE,
			toggle 	= db.Mouse.Events["QUEST_AUTOCOMPLETE"]
		},
		{	event	= {"LOOT_OPENED", "LOOT_CLOSED"},
			desc 	= TUTORIAL.MOUSE.LOOTING,
			toggle 	= db.Mouse.Events["LOOT_OPENED"]
		}
	}
end

---------------------------------------------------------------
-- Controls: Reset buttons
---------------------------------------------------------------

function PopupMixin:OnClick()
	local popup, config = ConsolePortPopup, ConsolePortConfig
	if not self.dontHide then
		popup:Hide()
		config:Hide()
	end
end

local function ResetBindingsOnClick(self)
	if not InCombatLockdown() then
		self:GetParent():GetParent():Hide()
		ConsolePort:CalibrateController(true)
	end
end

local function ResetAllOnClick(self)
	self:SetText(TUTORIAL.CONFIG.CONFIRMRESET)
	self:SetScript("OnClick", function(self)
		SlashCmdList["CONSOLEPORT"]("resetall")
	end)
end

---------------------------------------------------------------
-- Bind catcher
---------------------------------------------------------------
function Catcher:OnCatch(key)
	FadeIn(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 1)
	self:SetScript("OnKeyUp", nil)
	self:EnableKeyboard(false)
	local action = key and GetBindingAction(key)
	if action and action:match("CP_*") then
		self.CurrentButton = action
		if self.CurrentButton then
			self:SetText(format(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[action]))
		end
	elseif key then
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
end

function Catcher:OnClick()
	self:EnableKeyboard(true)
	self:SetScript("OnKeyUp", self.OnCatch)
	FadeOut(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 0)
	self:SetText(TUTORIAL.BIND.CATCHER)
end

function Catcher:OnHide()
	self:OnCatch()
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Catcher:OnShow()
	self.CurrentButton = Settings.interactWith
	if self.CurrentButton then
		self:SetText(format(TUTORIAL.CONFIG.INTERACTASSIGNED, db.TEXTURE[self.CurrentButton]))
	else
		self:SetText(TUTORIAL.CONFIG.INTERACTCATCHER)
	end
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

---------------------------------------------------------------
-- Checkbutton wrapper
---------------------------------------------------------------
function CheckButton:OnClick()
	for i, button in pairs(self.set) do
		button:SetChecked(false)
	end
	self:SetChecked(true)
end

---------------------------------------------------------------
-- WindowMixin
---------------------------------------------------------------
function WindowMixin:Save()
	local needReload
	-- general settings
	for i, Check in pairs(self.General) do
		local old = Settings[Check.Cvar]
		Settings[Check.Cvar] = Check:GetChecked()
		if Check.Reload and Check:GetChecked() ~= old then
			needReload = true
		end
	end
	-- trigger textures
	for i, Check in pairs(self.Triggers) do
		if Check.Value and Check.Value ~= Settings[Check.Cvar] then
			Settings[Check.Cvar] = Check.Value
			needReload = true
		end
	end

	-- target highlight
	Settings.alwaysHighlight = self.AssistModule.Mode

	ConsolePort:UpdateCVars()
	ConsolePort:UpdateCameraDriver()

	-- mouse events
	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			db.Mouse.Events[Event] = Check:GetChecked()
		end
	end

	-- interact button
	if self.InteractModule.Enable:GetChecked() and self.InteractModule.BindCatcher.CurrentButton then
		Settings.interactWith = self.InteractModule.BindCatcher.CurrentButton
		Settings.mouseOverMode = self.InteractModule.MouseOver:GetChecked()
		Settings.interactNPC = self.InteractModule.NPC:GetChecked()
		Settings.interactAuto = self.InteractModule.Auto:GetChecked()
	else
		Settings.interactWith = false
		Settings.mouseOverMode = false
		Settings.interactNPC = false
		Settings.interactAuto = false
	end

	ConsolePortSettings = db.Settings
	ConsolePortMouse = db.Mouse

	ConsolePort:LoadEvents()
	ConsolePort:LoadControllerTheme()
	ConsolePort:UpdateMouseDriver()
	ConsolePort:SetupUtilityBelt()
	return needReload
end

---------------------------------------------------------------
-- Controls: Create panel and children 
---------------------------------------------------------------
db.PANELS[#db.PANELS + 1] = {"Controls", CONTROLS_LABEL, false, WindowMixin, function(self, Controls)
	local red, green, blue = db.Atlas.GetCC()

	Settings = db.Settings

	local function CreateButton(name, text, OnClick, point, dontHide)
		local button = db.Atlas.GetFutureButton("$parent"..name, Controls.Controller.Container)
		button:SetPoint(unpack(point))
		button:SetText(text)
		button:SetScript("OnClick", OnClick)
		Mixin(button, PopupMixin)
		button.dontHide = dontHide
		return button
	end

	Controls.Controller = db.Atlas.GetFutureButton("$parentController", Controls)
	Controls.Controller.Popup = ConsolePortPopup
	Controls.Controller:SetPoint("LEFT", ConsolePortConfigDefault, "RIGHT", 0, 0)
	Controls.Controller:SetText(TUTORIAL.CONFIG.CONTROLLERBUTTON)
	Controls.Controller:SetScript("OnClick", function(self)
		self.Popup:SetPopup(self:GetText(), self.Container, nil, nil, 350)
	end)

	Controls.Controller.Container = CreateFrame("Frame", "$parentPopup", Controls.Controller)

	Controls.ResetController = CreateButton("ResetController", TUTORIAL.CONFIG.CONTROLLER, ConsolePort.SelectController, {"CENTER", 0, 72})
	Controls.ResetBindings = CreateButton("ResetBindings", TUTORIAL.CONFIG.BINDRESET, ResetBindingsOnClick, {"TOP", Controls.ResetController, "BOTTOM", 0, -2})
	Controls.ResetAll = CreateButton("ResetAll", TUTORIAL.CONFIG.FULLRESET, ResetAllOnClick, {"TOP", Controls.ResetBindings, "BOTTOM", 0, -2}, true)
	Controls.ShowSlash = CreateButton("ShowSlash", TUTORIAL.CONFIG.SHOWSLASH, SlashCmdList["CONSOLEPORT"], {"TOP", Controls.ResetAll, "BOTTOM", 0, -2}, true)

	------------------------------------------------------------------------------------------------------------------------------

	Controls.InteractModule = CreateFrame("Frame", nil, Controls)
	Controls.InteractModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.InteractModule:SetPoint("TOPRIGHT", -302, -8)
	Controls.InteractModule:SetSize(308, 308)

	Controls.MouseModule = CreateFrame("Frame", nil, Controls)
	Controls.MouseModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.MouseModule:SetPoint("TOPRIGHT", -8, -8)
	Controls.MouseModule:SetSize(316, 308)

	Controls.GeneralModule = CreateFrame("Frame", nil, Controls)
	Controls.GeneralModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.GeneralModule:SetPoint("TOPLEFT", 8, -8)
	Controls.GeneralModule:SetSize(388, 480)

	Controls.AssistModule = CreateFrame("Frame", nil, Controls)
	Controls.AssistModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.AssistModule:SetPoint("TOPLEFT", Controls.InteractModule, "BOTTOMLEFT", 0, 20)
	Controls.AssistModule:SetSize(214, 192)

	Controls.CameraModule = CreateFrame("Frame", nil, Controls)
	Controls.CameraModule:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.CameraModule:SetPoint("BOTTOMRIGHT", -8, 8)
	Controls.CameraModule:SetSize(410, 362)

	Controls.TriggerModule = db.Atlas.GetGlassWindow("$parentTriggerModule", Controls, nil, true)
	Controls.TriggerModule.Close:Hide()
	Controls.TriggerModule.BG:SetAlpha(0.1)
	Controls.TriggerModule:SetPoint("BOTTOMLEFT", 8, 8)
	Controls.TriggerModule:SetSize(580, 190)

	------------------------------------------------------------------------------------------------------------------------------
	function Controls.InteractModule:OnShow()
		if self.Enable:GetChecked() then
			FadeOut(self.Hand, 0.5, 1, 0.1)
			FadeOut(self.Dude, 0.5, 1, 0.1)
			self.MouseOver:Show()
			self.Auto:Show()
			self.NPC:Show()
			self.BindWrapper:Show()
		else
			self.MouseOver:Hide()
			self.Auto:Hide()
			self.NPC:Hide()
			self.BindWrapper:Hide()
			FadeIn(self.Hand, 0.5, 0.1, 1)
			FadeIn(self.Dude, 0.5, 0.1, 1)
		end
	end

	Mixin(Controls.InteractModule, Controls.InteractModule)

	Controls.InteractModule.Header = Controls.InteractModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.InteractModule.Header:SetText(TUTORIAL.CONFIG.INTERACTHEADER)
	Controls.InteractModule.Header:SetPoint("TOPLEFT", 24, -24)

	Controls.InteractModule.Dude = Controls.InteractModule:CreateTexture(nil, "BACKGROUND", nil, 1)
	Controls.InteractModule.Dude:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver")
	Controls.InteractModule.Dude:SetPoint("CENTER", 0, 0)
	Controls.InteractModule.Dude:SetSize(128, 128)

	Controls.InteractModule.Hand = Controls.InteractModule:CreateTexture(nil, "BACKGROUND", nil, 2)
	Controls.InteractModule.Hand:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor")
	Controls.InteractModule.Hand:SetPoint("CENTER", 16, -40)
	Controls.InteractModule.Hand:SetSize(64, 64)

	Controls.InteractModule.Description = Controls.InteractModule:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	Controls.InteractModule.Description:SetPoint("BOTTOM", 0, 32)
	Controls.InteractModule.Description:SetText(TUTORIAL.CONFIG.INTERACTDESC)
	Controls.InteractModule.Description:SetJustifyH("CENTER")

	Controls.InteractModule.BindWrapper = db.Atlas.GetGlassWindow("$parentBindWrapper", Controls.InteractModule, nil, true)
	Controls.InteractModule.BindWrapper:SetBackdrop(db.Atlas.Backdrops.Border)
	Controls.InteractModule.BindWrapper:SetPoint("BOTTOM", 0, 54)
	Controls.InteractModule.BindWrapper:SetSize(256, 90)
	Controls.InteractModule.BindWrapper.Close:Hide()
	Controls.InteractModule.BindWrapper:Hide()

	Controls.InteractModule.BindCatcher = db.Atlas.GetFutureButton("$parentBindCatcher", Controls.InteractModule.BindWrapper, nil, nil, 200)
	Controls.InteractModule.BindCatcher.HighlightTexture:ClearAllPoints()
	Controls.InteractModule.BindCatcher.HighlightTexture:SetAllPoints(Controls.InteractModule.BindCatcher)
	Controls.InteractModule.BindCatcher:SetHeight(60)
	Controls.InteractModule.BindCatcher:SetPoint("CENTER", 0, 0)
	Controls.InteractModule.BindCatcher.Cover:Hide()

	Mixin(Controls.InteractModule.BindCatcher, Catcher)
	Controls.InteractModule.BindCatcher:OnShow()

	local function InteractCheckButton(name, point, label, setting)
		local button = CreateFrame("CheckButton", nil, Controls.InteractModule, "ChatConfigCheckButtonTemplate")
		local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		button.Text = text

		text:SetPoint("LEFT", 30, 0)
		text:SetText(label)

		button:SetPoint(unpack(point))
		button:SetChecked(setting)
		button:SetScript("OnClick", function(self) self:GetParent():OnShow() end)

		Controls.InteractModule[name] = button
	end

	local interactButtons = {
		{name = "Enable", point = {"TOPLEFT", 24, -48}, label = TUTORIAL.CONFIG.INTERACTCHECK, setting = Settings.interactWith},
		{name = "MouseOver", point = {"TOPLEFT", 24, -78}, label = TUTORIAL.CONFIG.MOUSEOVERMODE, setting = Settings.mouseOverMode},
		{name = "NPC", point = {"TOPLEFT", 24, -108}, label = TUTORIAL.CONFIG.INTERACTNPC, setting = Settings.interactNPC},
		{name = "Auto", point = {"TOPLEFT", 24, -138}, label = TUTORIAL.CONFIG.INTERACTAUTO, setting = Settings.interactAuto},
	}

	for _, setup in pairs(interactButtons) do
		InteractCheckButton(setup.name, setup.point, setup.label, setup.setting)
	end

	------------------------------------------------------------------------------------------------------------------------------
	Controls.MouseModule.Header = Controls.MouseModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.MouseModule.Header:SetText(TUTORIAL.CONFIG.MOUSEHEADER)
	Controls.MouseModule.Header:SetPoint("TOPLEFT", 24, -24)

	Controls.Events = {}
	for i, setting in pairs(GetMouseSettings()) do
		local check = CreateFrame("CheckButton", "$parentMouseEvent"..i, Controls.MouseModule, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Events = setting.event
		check.Description = text
		check:SetPoint("TOPLEFT", 24, -30*i-18)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Controls.Events, check)
	end

	------------------------------------------------------------------------------------------------------------------------------
	Controls.GeneralModule.Header = Controls.GeneralModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.GeneralModule.Header:SetText(TUTORIAL.CONFIG.GENERALHEADER)
	Controls.GeneralModule.Header:SetPoint("TOPLEFT", 24, -24)

	local mouseCvarOffset = #Controls.Events
	Controls.General = {}
	for i, setting in pairs(GetAddonSettings()) do
		if setting.cvar then
			local check = CreateFrame("CheckButton", "$parentGeneralSetting"..i, Controls.GeneralModule, "ChatConfigCheckButtonTemplate")
			local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			text:SetText(setting.desc)
			check:SetChecked(setting.toggle)
			check.Description = text
			check.Cvar = setting.cvar
			check.Reload = setting.needReload
			text:SetPoint("LEFT", check, 30, 0)
			if setting.mouse then
				mouseCvarOffset = mouseCvarOffset + 1
				check:SetPoint("TOPLEFT", Controls.MouseModule, "TOPLEFT", 24, -30*mouseCvarOffset-18)
			else
				check:SetPoint("TOPLEFT", 24, -30*i-18)
			end
			tinsert(Controls.General, check)
		else
			local text = Controls.GeneralModule:CreateFontString("$parentGeneralSetting"..i, "OVERLAY", "GameFontNormalLeftOrange")
			text:SetText(setting.desc)
			text:SetPoint("TOPLEFT", 24, -30*i-24)
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	local function TriggerClick(self)
		local parent = self.parent
		local oldVal = parent.Index
		local allSets = parent.AllSets
		parent.Index = self.num
		parent.Value = self.name
		if allSets then
			for x, trigger in pairs(allSets) do
				if trigger ~= parent then
					for i, button in pairs(trigger.Set) do
						if i == self.num and button:GetChecked() then
							button:SetChecked(false)
							local swapTo = trigger.Set[oldVal]
							swapTo:SetChecked(true)
							trigger.Value = swapTo.name
							trigger.Index = swapTo.num
						end
					end
				end
			end
		end
	end
	------------------------------------------------------------------------------------------------------------------------------
	Controls.TriggerModule.Header = Controls.TriggerModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.TriggerModule.Header:SetText(TUTORIAL.CONFIG.TRIGGERHEADER)
	Controls.TriggerModule.Header:SetPoint("TOPLEFT", 24, -24)

	Controls.TriggerModule.HelpButton = CreateFrame("Button", "$parentHelpButton", Controls.TriggerModule)
	Controls.TriggerModule.HelpButton:SetSize(64, 64)
	Controls.TriggerModule.HelpButton:SetNormalTexture("Interface\\Common\\help-i")
	Controls.TriggerModule.HelpButton:SetHighlightTexture("Interface\\Common\\help-i")
	Controls.TriggerModule.HelpButton:SetPoint("TOPRIGHT", -4, -4)
	Controls.TriggerModule.HelpButton:SetScript("OnEnter", function(self)
		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(TUTORIAL.CONFIG.TRIGGERHELP)
		GameTooltip:Show()
	end)
	Controls.TriggerModule.HelpButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	Controls.Triggers = {}

	local triggerGraphics = {
		[TUTORIAL.BIND.SHIFT] 	= {offset = 0, cvar = "CP_M1"},
		[TUTORIAL.BIND.CTRL] 	= {offset = 1, cvar = "CP_M2"},
		[TUTORIAL.BIND.T1] 		= {offset = 2, cvar = "CP_T1"},
		[TUTORIAL.BIND.T2] 		= {offset = 3, cvar = "CP_T2"},
	}

	for name, info in pairs(triggerGraphics) do
		local trigger = Controls:CreateTexture("$parent"..info.cvar, "ARTWORK")
		trigger:SetSize(76, 50)
		trigger:SetPoint("TOPLEFT", Controls.TriggerModule.Header, "TOPLEFT", info.offset * 120 + 60, -24)
		trigger.AllSets = Controls.Triggers
		trigger.Value = Settings[info.cvar]
		trigger.Cvar = info.cvar

		local triggerText = Controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		triggerText:SetText(name)
		triggerText:SetPoint("CENTER", trigger, 0, 20)
		triggerText:SetTextColor(0.5, 0.5, 0.5)

		tinsert(Controls.Triggers, trigger)

		Controls[name] = trigger
	end

	local TEXTURE_PATH = "Interface\\AddOns\\ConsolePort\\Controllers\\%s\\Icons32\\%s"
	local triggers = {
		CP_TL1 = format(TEXTURE_PATH, Settings.type, "CP_TL1"),
		CP_TL2 = format(TEXTURE_PATH, Settings.type, "CP_TL2"),
		CP_TR1 = format(TEXTURE_PATH, Settings.type, "CP_TR1"),
		CP_TR2 = format(TEXTURE_PATH, Settings.type, "CP_TR2"),
	}

	local radioButtons = {
		{parent = Controls[TUTORIAL.BIND.SHIFT],	default = Settings.CP_M1},
		{parent = Controls[TUTORIAL.BIND.CTRL], 	default = Settings.CP_M2},
		{parent = Controls[TUTORIAL.BIND.T1], 	default = Settings.CP_T1},
		{parent = Controls[TUTORIAL.BIND.T2], 	default = Settings.CP_T2},
	}

	for i, radio in pairs(radioButtons) do
		local num = 1
		radio.parent.Set = {}
		for name, texture in spairs(triggers) do
			local button = CreateFrame("CheckButton", "$parentTrigger"..i..name, Controls)

			button:SetBackdrop(db.Atlas.Backdrops.BorderSmall)

			button:SetHighlightTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked")
			button:SetCheckedTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Checked")

			button.Checked = button:GetCheckedTexture()
			button.Highlight = button:GetHighlightTexture()

			button.Checked:SetTexCoord(0, 1, 1, 0)
			button.Highlight:SetTexCoord(0, 1, 1, 0)

			button.Checked:ClearAllPoints()
			button.Checked:SetPoint("CENTER", 0, 0)
			button.Checked:SetSize(104, 16)
			button.Checked:SetVertexColor(red, green, blue)

			button.Highlight:ClearAllPoints()
			button.Highlight:SetPoint("CENTER", 0, 0)
			button.Highlight:SetSize(104, 16)

			button:SetSize(120, 32)

			button.num = num
			button.set = radio.parent.Set
			button.name = name
			button.parent = radio.parent
			if i == 1 then
				button.text = button:CreateTexture(nil, "OVERLAY")
				button.text:SetTexture(texture)
				button.text:SetPoint("RIGHT", button, "LEFT", 0, 0)
				button.text:SetSize(32, 32)
			end
			button:SetPoint("TOP", radio.parent, "TOP", 0, -24*(num-1)-12)
			if name == radio.default then
				radio.parent.Index = num
				radio.parent.Value = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radio.parent.Set, button)
			button:SetScript("OnClick", TriggerClick)
			Mixin(button, CheckButton)
			num = num + 1
		end
	end

	------------------------------------------------------------------------------------------------------------------------------
	Controls.AssistModule.Header = Controls.AssistModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.AssistModule.Header:SetText(TUTORIAL.CONFIG.TARGETHEADER)
	Controls.AssistModule.Header:SetPoint("TOPLEFT", 24, -24)

	radioButtons = {
		{name = TUTORIAL.CONFIG.TARGETSCAN},
		{name = TUTORIAL.CONFIG.TARGETNONE, value = 1},
		{name = TUTORIAL.CONFIG.TARGETALWAYS, value = 2},
	}

	Controls.AssistModule.Set = {}

	local function AssistClick(self)
		self:GetParent().Mode = self.Value
	end

	for i, radio in pairs(radioButtons) do
		local check = CreateFrame("CheckButton", "$parentRadio"..i, Controls.AssistModule, "UIRadioButtonTemplate")			
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(radio.name)
		check:SetChecked(Settings.alwaysHighlight == radio.value)
		check.Value = radio.value
		text:SetPoint("LEFT", check, 20, 0)
		check:SetPoint("TOPLEFT", 20, -30*i-30)
		check.set = Controls.AssistModule.Set
		tinsert(check.set, check)
		check:SetScript("OnClick", AssistClick)
		Mixin(check, CheckButton)
	end

	------------------------------------------------------------------------------------------------------------------------------
	Controls.CameraModule.Header = Controls.CameraModule:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Controls.CameraModule.Header:SetText(TUTORIAL.CONFIG.CAMERAHEADER)
	Controls.CameraModule.Header:SetPoint("TOPLEFT", 24, -24)

	---- Under construction 
	Controls.UnderConstruction = Controls.CameraModule:CreateTexture("ARTWORK")
	Controls.UnderConstruction:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset.blp")
	Controls.UnderConstruction:SetTexCoord(0.875, 1, 0.875, 1)
	Controls.UnderConstruction:SetSize(128, 128)
	Controls.UnderConstruction:SetPoint("CENTER")
	----
end}