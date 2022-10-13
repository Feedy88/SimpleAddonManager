local EDDM = LibStub("ElioteDropDownMenu-1.0")
local dropdownFrame = EDDM.UIDropDownMenu_GetOrCreate("ElioteAddonList_MenuFrame")

--- @type ElioteAddonList
local frame = ElioteAddonList

ButtonFrameTemplate_HidePortrait(frame)

local function CharacterDropDown_Initialize()
	local selectedValue = frame:GetCharacter() == true
	local info = {
		text = ALL,
		value = true,
		func = function(self)
			local value = self.value
			frame:SetCharacter(value)
			EDDM.UIDropDownMenu_SetSelectedValue(frame.CharacterDropDown, value)
			frame.ScrollFrame.update()
		end,
		checked = selectedValue
	};
	EDDM.UIDropDownMenu_AddButton(info);

	info.text = UnitName("player")
	info.value = UnitName("player")
	info.checked = not selectedValue
	EDDM.UIDropDownMenu_AddButton(info);
end

local separatorInfo = {
	text = "",
	hasArrow = false;
	dist = 0;
	isTitle = true;
	isUninteractable = true;
	notCheckable = true;
	iconOnly = true;
	icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
	tCoordLeft = 0;
	tCoordRight = 1;
	tCoordTop = 0;
	tCoordBottom = 1;
	tSizeX = 0;
	tSizeY = 8;
	tFitDropDownSizeX = true;
	iconInfo = {
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = 0,
		tCoordBottom = 1,
		tSizeX = 0,
		tSizeY = 8,
		tFitDropDownSizeX = true
	},
};

local function SaveCurrentAddonsToSet(setName)
	local db = frame:GetDb()
	local enabledAddons = {}
	local count = GetNumAddOns()
	for i = 1, count do
		if frame:IsAddonSelected(i) then
			local name = GetAddOnInfo(i)
			table.insert(enabledAddons, name)
		end
	end
	db.sets[setName] = db.sets[setName] or {}
	db.sets[setName].addons = enabledAddons
end

local function SetsDropDownCreate()
	local menu = {
		{ text = "Sets", isTitle = true, notCheckable = true },
	}
	local db = frame:GetDb()

	for setName, set in pairs(db.sets) do
		local setMenu = {
			text = setName,
			notCheckable = true,
			hasArrow = true,
			menuList = {
				{ text = setName, isTitle = true, notCheckable = true },
				{ text = #set.addons .. " AddOns", notCheckable = true },
				separatorInfo,
				{
					text = "Save",
					notCheckable = true,
					func = function()
						frame:ShowConfirmDialog(
								"Save current addons to this set '" .. setName .. "'?",
								function()
									SaveCurrentAddonsToSet(setName)
								end
						)
					end
				},
				{
					text = "Load",
					notCheckable = true,
					func = function()
						frame:ShowConfirmDialog(
								"Load the set '" .. setName .. "'?",
								function()
									local enabledAddons = db.sets[setName].addons
									local character = frame:GetCharacter()
									DisableAllAddOns(character)
									for _, name in ipairs(enabledAddons) do
										EnableAddOn(name, character)
									end
									frame.ScrollFrame.update()
								end
						)
					end
				},
				{
					text = "Rename",
					notCheckable = true,
					func = function()
						frame:ShowInputDialog(
								"Enter the new name for the set '" .. setName .. "'",
								function(text)
									db.sets[text] = db.sets[setName]
									db.sets[setName] = nil
								end
						)
					end
				},
				{
					text = "Delete",
					notCheckable = true,
					func = function()
						frame:ShowConfirmDialog(
								"Delete the set '" .. setName .. "'?",
								function()
									db.sets[setName] = nil
								end
						)
					end
				},
			}
		}
		table.insert(menu, setMenu)
	end

	table.insert(menu, separatorInfo)
	table.insert(menu, {
		text = "Create new set",
		func = function()
			frame:ShowInputDialog(
					"Type the name for the new set",
					function(text)
						SaveCurrentAddonsToSet(text)
					end
			)
		end,
		notCheckable = true
	})

	return menu
end

frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:SetPoint("CENTER", 0, 24)
frame:SetSize(frame.MIN_SIZE_W, frame.MIN_SIZE_H)
frame:SetResizable(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:SetMinResize(frame.MIN_SIZE_W, frame.MIN_SIZE_H)
frame:SetScript("OnMouseDown", function(self)
	self:StartMoving()
end)
frame:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)
frame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

frame.Sizer = CreateFrame("Button", nil, frame, "PanelResizeButtonTemplate")
frame.Sizer:SetScript("OnMouseDown", function()
	frame:StartSizing("BOTTOMRIGHT", true)
end)
frame.Sizer:SetScript("OnMouseUp", function()
	frame:StopMovingOrSizing()
end)
frame.Sizer:SetPoint("BOTTOMRIGHT", -4, 4)

frame.CharacterDropDown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
frame.CharacterDropDown:SetPoint("TOPLEFT", 0, -30)
frame.CharacterDropDown.Button:SetScript("OnMouseDown", function(self)
	if self:IsEnabled() then
		EDDM.ToggleDropDownMenu(nil, nil, self:GetParent());
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end)
EDDM.UIDropDownMenu_Initialize(frame.CharacterDropDown, CharacterDropDown_Initialize)
EDDM.UIDropDownMenu_SetSelectedValue(frame.CharacterDropDown, true)

frame.ForceLoadCheck = CreateFrame("CheckButton", nil, frame)
frame.ForceLoadCheck:SetSize(22, 22)
frame.ForceLoadCheck:SetPoint("TOPLEFT", 4, -1)
frame.ForceLoadCheck.Text = frame.ForceLoadCheck:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
frame.ForceLoadCheck.Text:SetPoint("LEFT", 24, 0)
frame.ForceLoadCheck.Text:SetText(ADDON_FORCE_LOAD)
frame.ForceLoadCheck:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
frame.ForceLoadCheck:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
frame.ForceLoadCheck:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
frame.ForceLoadCheck:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
frame.ForceLoadCheck:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
frame.ForceLoadCheck:SetScript("OnClick", function(self)
	if (self:GetChecked()) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		SetAddonVersionCheck(false)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		SetAddonVersionCheck(true)
	end
	frame.ScrollFrame.update()
end)

frame.CancelButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
frame.CancelButton:SetPoint("BOTTOMRIGHT", -24, 4)
frame.CancelButton:SetSize(100, 22)
frame.CancelButton:SetText(CANCEL)
frame.CancelButton:SetScript("OnClick", function()
	ResetAddOns()
	frame.ScrollFrame.update()
	frame:Hide()
end)

frame.OkButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
frame.OkButton:SetPoint("TOPRIGHT", frame.CancelButton, "TOPLEFT", 0, 0)
frame.OkButton:SetSize(100, 22)
frame.OkButton:SetText(OKAY)
frame.OkButton:SetScript("OnClick", function()
	SaveAddOns()
	frame.ScrollFrame.update()
	frame:Hide()
	if (frame.edited) then
		ReloadUI()
	end
end)

frame.EnableAllButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
frame.EnableAllButton:SetPoint("BOTTOMLEFT", 4, 4)
frame.EnableAllButton:SetSize(120, 22)
frame.EnableAllButton:SetText(ENABLE_ALL_ADDONS)
frame.EnableAllButton:SetScript("OnClick", function()
	local character = frame:GetCharacter()
	EnableAllAddOns(character)
	frame.ScrollFrame.update()
end)

frame.DisableAllButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
frame.DisableAllButton:SetPoint("TOPLEFT", frame.EnableAllButton, "TOPRIGHT", 0, 0)
frame.DisableAllButton:SetSize(120, 22)
frame.DisableAllButton:SetText(DISABLE_ALL_ADDONS)
frame.DisableAllButton:SetScript("OnClick", function()
	local character = frame:GetCharacter()
	DisableAllAddOns(character)
	frame.ScrollFrame.update()
end)

function frame:SetCategoryVisibility(show, resize)
	local fw = frame:GetWidth()
	if (show) then
		frame.CategoryButton.icon:SetAtlas("common-icon-backarrow")
		frame.ScrollFrame:SetPoint("BOTTOMRIGHT", (-30 - frame.CATEGORY_SIZE_W), 30)
		if (resize) then
			frame:SetWidth(math.max(frame.MIN_SIZE_W, fw + frame.CATEGORY_SIZE_W))
		end
		frame.CategoryButton:SetPoint("TOPRIGHT", -5 - frame.CATEGORY_SIZE_W, -27)
		frame:SetMinResize(frame.MIN_SIZE_W + frame.CATEGORY_SIZE_W, frame.MIN_SIZE_H)
		frame.CategoryFrame:Show()
	else
		frame.CategoryButton.icon:SetAtlas("common-icon-forwardarrow")
		frame.ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 30)
		if (resize) then
			frame:SetWidth(math.max(frame.MIN_SIZE_W, fw - frame.CATEGORY_SIZE_W))
		end
		frame.CategoryButton:SetPoint("TOPRIGHT", -5, -27)
		frame:SetMinResize(frame.MIN_SIZE_W, frame.MIN_SIZE_H)
		frame.CategoryFrame:Hide()
	end
	frame.ScrollFrame.update()
	frame.CategoryFrame.ScrollFrame.update()
end

frame.CategoryButton = CreateFrame("Button", nil, frame, "UIPanelSquareButton")
frame.CategoryButton:SetPoint("TOPRIGHT", -5, -27)
frame.CategoryButton:SetSize(30, 30)
frame.CategoryButton.icon:SetAtlas("common-icon-forwardarrow")
frame.CategoryButton.icon:SetTexCoord(0, 1, 0, 1)
frame.CategoryButton.icon:SetSize(15, 15)
frame.CategoryButton:SetScript("OnClick", function()
	local db = frame:GetDb()
	db.isCategoryFrameVisible = not db.isCategoryFrameVisible
	frame:SetCategoryVisibility(db.isCategoryFrameVisible, true)
end)

frame.SearchBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
frame.SearchBox:SetPoint("RIGHT", frame.CategoryButton, "LEFT", -4, 0)
frame.SearchBox:SetSize(130, 20)

frame.SetsButton = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
frame.SetsButton:SetPoint("TOPRIGHT", frame.SearchBox, "TOPLEFT", -10, 0)
frame.SetsButton:SetSize(80, 22)
frame.SetsButton:SetText("Sets")
frame.SetsButton:SetScript("OnClick", function()
	EDDM.EasyMenu(SetsDropDownCreate(), dropdownFrame, frame.SetsButton, 0, 0, "MENU")
end)

local function AddonsFromCategories(categories)
	if categories == nil or next(categories) == nil then
		return nil
	end
	local m = {}
	for categoryName, _ in pairs(categories) do
		local userTable, tocTable = frame:GetCategoryTable(categoryName)
		if (userTable) then
			for name, _ in pairs(userTable.addons) do
				m[name] = true
			end
		end
		if (tocTable) then
			for name, _ in pairs(tocTable.addons) do
				m[name] = true
			end
		end
	end
	return m
end

local addons = {}
local function CreateList(filter, categories)
	addons = {}
	local categoriesAddons = AddonsFromCategories(categories)
	local count = GetNumAddOns()
	for addonIndex = 1, count do
		local name, title = GetAddOnInfo(addonIndex)
		if (categoriesAddons == nil or categoriesAddons[name]) then
			if (name:upper():match(filter:upper()) or title:upper():match(filter:upper())) then
				table.insert(addons, { index = addonIndex })
			end
		end
	end
end

function frame:GetAddonsList()
	return addons
end

function frame:UpdateListFilters()
	CreateList(frame.SearchBox:GetText(), frame:SelectedCategories())
	frame.ScrollFrame.ScrollBar:SetValue(0)
	frame.ScrollFrame.update()
end

frame.SearchBox:SetScript("OnTextChanged", function(self)
	SearchBoxTemplate_OnTextChanged(self)
	frame:UpdateListFilters()
end)
