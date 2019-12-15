-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local nTokenDragUnits = nil;

local bDisplayDefaultHealth = false;
local fGetHealthInfo = null;

local bDisplayDefaultEffects = false;
local fGetEffectInfo = null;
local fParseEffectComp = null;
local aParseEffectTagConditional = {};
local aParseEffectBonusTag = {};
local aParseEffectSimpleTag = {};
local aParseEffectCondition = {};

function onInit()
	if User.isHost() then
		Token.onContainerChanged = onContainerChanged;
		Token.onTargetUpdate = onTargetUpdate;

		DB.addHandler("options.TFAC", "onUpdate", onOptionChanged);

		CombatManager.setCustomDeleteCombatantHandler(onCombatantDelete);
		CombatManager.addCombatantFieldChangeHandler("active", "onUpdate", updateActive);
		CombatManager.addCombatantFieldChangeHandler("space", "onUpdate", updateSpaceReach);
		CombatManager.addCombatantFieldChangeHandler("reach", "onUpdate", updateSpaceReach);
	end
	DB.addHandler("charsheet.*", "onDelete", deleteOwner);
	DB.addHandler("charsheet.*", "onObserverUpdate", updateOwner);

	Token.onAdd = onTokenAdd;
	Token.onDelete = onTokenDelete;
	Token.onDrop = onDrop;
	Token.onHover = onHover;
	Token.onDoubleClick = onDoubleClick;
	if Interface.getVersion() < 4 then
		Token.onScaleChanged = onScaleChanged;
	end

	CombatManager.addCombatantFieldChangeHandler("tokenrefid", "onUpdate", updateAttributes);
	CombatManager.addCombatantFieldChangeHandler("friendfoe", "onUpdate", updateFaction);
	CombatManager.addCombatantFieldChangeHandler("name", "onUpdate", updateName);
	CombatManager.addCombatantFieldChangeHandler("nonid_name", "onUpdate", updateName);
	CombatManager.addCombatantFieldChangeHandler("isidentified", "onUpdate", updateName);
	
	DB.addHandler("options.TNAM", "onUpdate", onOptionChanged);
end

function linkToken(nodeCT, newTokenInstance)
	local nodeContainer = nil;
	if newTokenInstance then
		nodeContainer = newTokenInstance.getContainerNode();
	end
	
	if nodeContainer then
		DB.setValue(nodeCT, "tokenrefnode", "string", nodeContainer.getNodeName());
		DB.setValue(nodeCT, "tokenrefid", "string", newTokenInstance.getId());
	else
		DB.setValue(nodeCT, "tokenrefnode", "string", "");
		DB.setValue(nodeCT, "tokenrefid", "string", "");
	end

	return true;
end
function onOptionChanged(nodeOption)
	for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
		local tokenCT = CombatManager.getTokenFromCT(nodeCT);
		if tokenCT then
			updateAttributesHelper(tokenCT, nodeCT);
		end
	end
end

function onCombatantDelete(nodeCT)
	if TokenManager2 and TokenManager2.onCombatantDelete then
		if TokenManager2.onCombatantDelete(nodeCT) then
			return;
		end
	end
	
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
		if sClass ~= "charsheet" then
			tokenCT.delete();
		else
			local aWidgets = getWidgetList(tokenCT);
			for _, vWidget in pairs(aWidgets) do
				vWidget.destroy();
			end

			tokenCT.setActivable(true);
			tokenCT.setActive(false);
			tokenCT.setActivable(false);
			tokenCT.setTargetsVisible(false);
			tokenCT.setModifiable(true);
			tokenCT.setVisible(nil);

			tokenCT.setName();
			tokenCT.setGridSize(0);
			tokenCT.removeAllUnderlays();
		end
	end
end
function onTokenAdd(tokenMap)
	ImageManager.onTokenAdd(tokenMap);
end
function onTokenDelete(tokenMap)
	ImageManager.onTokenDelete(tokenMap);

	if User.isHost() then
		CombatManager.onTokenDelete(tokenMap);
		PartyManager.onTokenDelete(tokenMap);
	end
end
function onContainerChanged(tokenCT, nodeOldContainer, nOldId)
	if nodeOldContainer then
		local nodeCT = CombatManager.getCTFromTokenRef(nodeOldContainer, nOldId);
		if nodeCT then
			local nodeNewContainer = tokenCT.getContainerNode();
			if nodeNewContainer then
				DB.setValue(nodeCT, "tokenrefnode", "string", nodeNewContainer.getNodeName());
				DB.setValue(nodeCT, "tokenrefid", "string", tokenCT.getId());
			else
				DB.setValue(nodeCT, "tokenrefnode", "string", "");
				DB.setValue(nodeCT, "tokenrefid", "string", "");
			end
		end
	end
	local nodePS = PartyManager.getNodeFromTokenRef(nodeOldContainer, nOldId);
	if nodePS then
		local nodeNewContainer = tokenCT.getContainerNode();
		if nodeNewContainer then
			DB.setValue(nodePS, "tokenrefnode", "string", nodeNewContainer.getNodeName());
			DB.setValue(nodePS, "tokenrefid", "string", tokenCT.getId());
		else
			DB.setValue(nodePS, "tokenrefnode", "string", "");
			DB.setValue(nodePS, "tokenrefid", "string", "");
		end
	end
end
function onScaleChanged(tokenCT)	
	local nodeCT = CombatManager.getCTFromToken(tokenCT);

	if nodeCT then
		updateNameScale(tokenCT);
		if bDisplayDefaultHealth then 
			local nPercentWounded = fGetHealthInfo(nodeCT);
			
			-- Horizontal health bar or regular health bar update
			if OptionsManager.getOption('CE_HHB') ~= "option_off" then 
				HealthGraphicUpdater.updateHealthBarScale(tokenCT, nPercentWounded); 
			else
				updateHealthBarScale(tokenCT, nPercentWounded); 
			end

		end
		if bDisplayDefaultEffects then
			updateEffectsHelper(tokenCT, nodeCT);
		end
		if TokenManager2 and TokenManager2.onScaleChanged then
			TokenManager2.onScaleChanged(tokenCT, nodeCT);
		end
	end
end
function onTargetUpdate(tokenMap)
	TargetingManager.onTargetUpdate(tokenMap);
end

function onWheelHelper(tokenCT, notches)
	if not tokenCT then
		return;
	end
	
	local newscale = tokenCT.getScale();
	if Interface.getVersion() >= 4 then
		local adj = notches * 0.1;
		if adj < 0 then
			newscale = newscale * (1 + adj);
		else
			newscale = newscale * (1 / (1 - adj));
		end
	else
		if Input.isShiftPressed() then
			newscale = math.floor(newscale + notches);
			if newscale < 1 then
				newscale = 1;
			end
		else
			newscale = newscale + (notches * 0.1);
			if newscale < 0.1 then
				newscale = 0.1;
			end
		end
	end
	tokenCT.setScale(newscale);
end
function onWheelCT(nodeCT, notches)
	if not Input.isControlPressed() then
		return false;
	end
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		onWheelHelper(tokenCT, notches);
	end
end
function onDrop(tokenCT, draginfo)
	local nodeCT = CombatManager.getCTFromToken(tokenCT);
	if nodeCT then
		return CombatManager.onDrop("ct", nodeCT.getNodeName(), draginfo);
	else
		if draginfo.getType() == "targeting" then
			ChatManager.SystemMessage(Interface.getString("ct_error_targetingunlinkedtoken"));
			return true;
		end
	end
end
function onHover(tokenMap, bOver)
	local nodeCT = CombatManager.getCTFromToken(tokenMap);
	if nodeCT then
		if OptionsManager.isOption("TNAM", "hover") then
			for _, vWidget in pairs(getWidgetList(tokenMap, "name")) do
				vWidget.setVisible(bOver);
			end
		end
		if bDisplayDefaultHealth then
			local sOption;
			if User.isHost() then
				sOption = OptionsManager.getOption("TGMH");
			elseif DB.getValue(nodeCT, "friendfoe", "") == "friend" then
				sOption = OptionsManager.getOption("TPCH");
			else
				sOption = OptionsManager.getOption("TNPCH");
			end
			if (sOption == "barhover") or (sOption == "dothover") then
				for _, vWidget in pairs(getWidgetList(tokenMap, "health")) do
					vWidget.setVisible(bOver);
				end
			end
		end
		if bDisplayDefaultEffects then
			local sOption;
			if User.isHost() then
				sOption = OptionsManager.getOption("TGME");
			elseif DB.getValue(nodeCT, "friendfoe", "") == "friend" then
				sOption = OptionsManager.getOption("TPCE");
			else
				sOption = OptionsManager.getOption("TNPCE");
			end
			if (sOption == "hover") or (sOption == "markhover") then
				for _, vWidget in pairs(getWidgetList(tokenMap, "effect")) do
					vWidget.setVisible(bOver);
				end
			end
		end
		if TokenManager2 and TokenManager2.onHover then
			TokenManager2.onHover(tokenMap, nodeCT, bOver);
		end
	end
end
function onDoubleClick(tokenMap, vImage)
	local nodeCT = CombatManager.getCTFromToken(tokenMap);
	if nodeCT then
		if User.isHost() then
			local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
			if sRecord ~= "" then
				Interface.openWindow(sClass, sRecord);
			else
				Interface.openWindow(sClass, nodeCT);
			end
		else
			if (DB.getValue(nodeCT, "friendfoe", "") == "friend") then
				local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
				if sClass == "charsheet" then
					if sRecord ~= "" and DB.isOwner(sRecord) then
						Interface.openWindow(sClass, sRecord);
					else
						ChatManager.SystemMessage(Interface.getString("ct_error_openpclinkedtokenwithoutaccess"));
					end
				else
					local nodeActor;
					if sRecord ~= "" then
						nodeActor = DB.findNode(sRecord);
					else
						nodeActor = nodeCT;
					end
					if nodeActor then
						Interface.openWindow(sClass, nodeActor);
					else
						ChatManager.SystemMessage(Interface.getString("ct_error_openotherlinkedtokenwithoutaccess"));
					end
				end
				vImage.clearSelectedTokens();
			end
		end
	end
end

function updateAttributesFromToken(tokenMap)
	local nodeCT = CombatManager.getCTFromToken(tokenMap);
	if nodeCT then
		updateAttributesHelper(tokenMap, nodeCT);
	end
	
	if User.isHost() then
		local nodePS = PartyManager.getNodeFromToken(tokenMap);
		if nodePS then
			tokenMap.setTargetable(false);
			tokenMap.setActivable(true);
			tokenMap.setActive(false);
			tokenMap.setVisible(true);
			
			tokenMap.setName(DB.getValue(nodePS, "name", ""));
		end
	end
end
function updateAttributes(nodeField)
	local nodeCT = nodeField.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateAttributesHelper(tokenCT, nodeCT);
	end
end
function updateAttributesHelper(tokenCT, nodeCT)
	if User.isHost() then
		tokenCT.setTargetable(true);
		tokenCT.setActivable(true);
		
		if OptionsManager.isOption("TFAC", "on") then
			tokenCT.setOrientationMode("facing");
		else
			tokenCT.setOrientationMode();
		end
		
		updateActiveHelper(tokenCT, nodeCT);
		updateFactionHelper(tokenCT, nodeCT);
		updateSizeHelper(tokenCT, nodeCT);
	end
	updateOwnerHelper(tokenCT, nodeCT);
	
	updateNameHelper(tokenCT, nodeCT);
	updateTooltip(tokenCT, nodeCT);
	if bDisplayDefaultHealth then 
		updateHealthHelper(tokenCT, nodeCT); 
	end
	if bDisplayDefaultEffects then
		updateEffectsHelper(tokenCT, nodeCT);
	end
	if TokenManager2 and TokenManager2.updateAttributesHelper then
		TokenManager2.updateAttributesHelper(tokenCT, nodeCT);
	end
end
function updateTooltip(tokenCT, nodeCT)
	if TokenManager2 and TokenManager2.updateTooltip then
		TokenManager2.updateTooltip(tokenCT, nodeCT);
		return;
	end
	
	if User.isHost() then
		local aTooltip = {};
		local sFaction = DB.getValue(nodeCT, "friendfoe", "");
		
		local sOptTNAM = OptionsManager.getOption("TNAM");
		if sOptTNAM == "tooltip" then
			local sName = ActorManager.getDisplayName(nodeCT);
			table.insert(aTooltip, sName);
		end
		
		tokenCT.setName(table.concat(aTooltip, "\r"));
	end
end

function updateName(nodeName)
	local nodeCT = nodeName.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateNameHelper(tokenCT, nodeCT);
		updateTooltip(tokenCT, nodeCT);
	end
end
function updateNameHelper(tokenCT, nodeCT)
	local sOptTNAM = OptionsManager.getOption("TNAM");
	
	local sName = ActorManager.getDisplayName(nodeCT);
	local aWidgets = getWidgetList(tokenCT, "name");
	
	if sOptTNAM == "off" or sOptTNAM == "tooltip" then
		for _, vWidget in pairs(aWidgets) do
			vWidget.destroy();
		end
	else
		local w, h = tokenCT.getSize();
		if w > 10 then
			local nStarts, _, sNumber = string.find(sName, " ?(%d+)$");
			if nStarts then
				sName = string.sub(sName, 1, nStarts - 1);
			end
			local bWidgetsVisible = (sOptTNAM == "on");

			local widgetName = aWidgets["name"];
			if not widgetName then
				widgetName = tokenCT.addTextWidget("mini_name", "");
				widgetName.setPosition("top", 0, -2);
				widgetName.setFrame("mini_name", 5, 1, 5, 1);
				widgetName.setName("name");
			end
			if widgetName then
				widgetName.setVisible(bWidgetsVisible);
				widgetName.setText(sName);
				widgetName.setTooltipText(sName);
				if Interface.getVersion() >= 4 then
					widgetName.setMaxWidth(100);
				else
					updateNameScale(tokenCT);
				end
			end

			if sNumber then
				local widgetOrdinal = aWidgets["ordinal"];
				if not widgetOrdinal then
					widgetOrdinal = tokenCT.addTextWidget("sheetlabel", "");
					widgetOrdinal.setPosition("topright", -4, -2);
					widgetOrdinal.setFrame("tokennumber", 7, 1, 7, 1);
					widgetOrdinal.setName("ordinal");
				end
				if widgetOrdinal then
					widgetOrdinal.setVisible(bWidgetsVisible);
					widgetOrdinal.setText(sNumber);
				end
			else
				if aWidgets["ordinal"] then
					aWidgets["ordinal"].destroy();
				end
			end
		end
	end
end
-- Only called for FG versions < 4
function updateNameScale(tokenCT)
	local widgetName = tokenCT.findWidget("name");
	if widgetName then
		local w, h = tokenCT.getSize();
		if w > 10 then
			widgetName.setMaxWidth(w - 10);
		else
			widgetName.setMaxWidth(0);
		end
	end
end

function updateVisibility(nodeCT)
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateVisibilityHelper(tokenCT, nodeCT);
	end
	
	if DB.getValue(nodeCT, "tokenvis", 0) == 0 then
		TargetingManager.removeCTTargeted(nodeCT);
	end
end
function updateVisibilityHelper(tokenCT, nodeCT)
	if DB.getValue(nodeCT, "friendfoe", "") == "friend" then
		tokenCT.setVisible(true);
	else
		if DB.getValue(nodeCT, "tokenvis", 0) == 1 then
			if tokenCT.isVisible() ~= true then
				tokenCT.setVisible(nil);
			end
		else
			tokenCT.setVisible(false);
		end
	end
end

function deleteOwner(nodePC)
	local nodeCT = CombatManager.getCTFromNode(nodePC);
	if nodeCT then
		local tokenCT = CombatManager.getTokenFromCT(nodeCT);
		if tokenCT then
			if User.isHost() then
				if (Interface.getVersion() >= 4) then tokenCT.setOwner(); end
			else
				tokenCT.setTargetsVisible(false);
			end
		end
	end
end
function updateOwner(nodePC)
	local nodeCT = CombatManager.getCTFromNode(nodePC);
	if nodeCT then
		local tokenCT = CombatManager.getTokenFromCT(nodeCT);
		if tokenCT then
			updateOwnerHelper(tokenCT, nodeCT);
		end
	end
end
function updateOwnerHelper(tokenCT, nodeCT)
	if User.isHost() then
		if (Interface.getVersion() >= 4) then
			local nodeCreature = ActorManager.getCreatureNode(nodeCT);
			tokenCT.setOwner(DB.getOwner(nodeCreature));
		end
	else
		local bOwned = false;
		
		local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
		if DB.isOwner(sRecord) then
			bOwned = true;
		end

		tokenCT.setTargetsVisible(bOwned);
	end
end

function updateActive(nodeField)	
	local nodeCT = nodeField.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateActiveHelper(tokenCT, nodeCT);
	end
end
function updateActiveHelper(tokenCT, nodeCT)	

	TokenHighlighter.updateActiveHelper(tokenCT, nodeCT);

	if User.isHost() then
		if tokenCT.isActivable() then
			local bActive = (DB.getValue(nodeCT, "active", 0) == 1);
			if bActive then
				tokenCT.setActive(true);
			else
				tokenCT.setActive(false);
			end
		end
	end
end

function updateFaction(nodeFaction)
	local nodeCT = nodeFaction.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		if User.isHost() then
			updateFactionHelper(tokenCT, nodeCT);
		end
		updateTooltip(tokenCT, nodeCT);
		if bDisplayDefaultHealth then 
			updateHealthHelper(tokenCT, nodeCT); 
		end
		if bDisplayDefaultEffects then
			updateEffectsHelper(tokenCT, nodeCT);
		end
		if TokenManager2 and TokenManager2.updateFaction then
			TokenManager2.updateFaction(tokenCT, nodeCT);
		end
	end
end
function updateFactionHelper(tokenCT, nodeCT)
	if DB.getValue(nodeCT, "friendfoe", "") == "friend" then
		if Interface.getVersion() >= 4 then
			tokenCT.setPublicEdit(true);
			tokenCT.setPublicVision(true);
		else
			tokenCT.setModifiable(true);
		end
	else
		if Interface.getVersion() >= 4 then
			tokenCT.setPublicEdit(false);
			tokenCT.setPublicVision(false);
		else
			tokenCT.setModifiable(false);
		end
	end

	updateVisibilityHelper(tokenCT, nodeCT);
	updateSizeHelper(tokenCT, nodeCT);
end

function updateSpaceReach(nodeField)
	local nodeCT = nodeField.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateSizeHelper(tokenCT, nodeCT);
	end
end

function updateSizeHelper(tokenCT, nodeCT)	
	local nDU = GameSystem.getDistanceUnitsPerGrid();
	
	local nSpace = math.ceil(DB.getValue(nodeCT, "space", nDU) / nDU);
	local nHalfSpace = nSpace / 2;
	local nReach = math.ceil(DB.getValue(nodeCT, "reach", nDU) / nDU) + nHalfSpace;

	-- Clear underlays
	tokenCT.removeAllUnderlays();

	
	-- Reach underlay	
	if OptionsManager.getOption('CE_SRU') == "on" then
		local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
		if sClass == "charsheet" then
			tokenCT.addUnderlay(nReach, "4f000000", "hover");
		else
			tokenCT.addUnderlay(nReach, "4f000000", "hover,gmonly");
		end
	end	

	-- Faction/space underlay	
	if OptionsManager.getOption('CE_SFU') == "on" then
		local sFaction = DB.getValue(nodeCT, "friendfoe", "");
		if sFaction == "friend" then
			tokenCT.addUnderlay(nHalfSpace, "2f00ff00");
		elseif sFaction == "foe" then
			tokenCT.addUnderlay(nHalfSpace, "2fff0000");
		elseif sFaction == "neutral" then
			tokenCT.addUnderlay(nHalfSpace, "2fffff00");
		end
	end
	
	-- Set grid spacing
	tokenCT.setGridSize(nSpace);
end

local aWidgetSets = { ["name"] = { "name", "ordinal" } };
function registerWidgetSet(sKey, aSet)
	aWidgetSets[sKey] = aSet;
end
function getWidgetList(tokenCT, sSet)
	local aWidgets = {};

	if (sSet or "") == "" then
		for _,aSet in pairs(aWidgetSets) do
			for _,sWidget in pairs(aSet) do
				local w = tokenCT.findWidget(sWidget);
				if w then
					aWidgets[sWidget] = w;
				end
			end
		end
	else
		if aWidgetSets[sSet] then
			for _,sWidget in pairs(aWidgetSets[sSet]) do
				local w = tokenCT.findWidget(sWidget);
				if w then
					aWidgets[sWidget] = w;
				end
			end
		end
	end
	
	return aWidgets;
end

function setDragTokenUnits(nUnits)
	nTokenDragUnits = nUnits;
end
function endDragTokenWithUnits()
	nTokenDragUnits = nil;
end
function getTokenSpace(tokenMap)
	local nSpace = 1;
	if nTokenDragUnits then
		local nDU = GameSystem.getDistanceUnitsPerGrid();
		nSpace = math.max(math.ceil(nTokenDragUnits / nDU), 1);
	else
		local nodeCT = CombatManager.getCTFromToken(tokenMap);
		if nodeCT then
			nSpace = DB.getValue(nodeCT, "space", 1);
			local nDU = GameSystem.getDistanceUnitsPerGrid();
			nSpace = math.max(math.ceil(nSpace / nDU), 1);
		end
	end
	return nSpace;
end
function autoTokenScale(tokenMap)
	if Interface.getVersion() >= 4 then
		local aImage = tokenMap.getContainerNode().getValue();
		if not aImage or (aImage.gridsizex <= 0) or (aImage.gridsizey <= 0) then
			return;
		end
		
		local nGridScale = getTokenSpace(tokenMap);
		local sOptTASG = OptionsManager.getOption("TASG");
		if sOptTASG == "80" then
			nGridScale = nGridScale * 0.8;
		end
		tokenMap.setScale(nGridScale, nGridScale, true);
	else
		if tokenMap.getScale() ~= 1 then
			return;
		end
		
		local w, h = tokenMap.getImageSize();
		if w <= 0 or h <= 0 then
			return;
		end
		
		local aImage = tokenMap.getContainerNode().getValue();
		if not aImage or not aImage.gridsize or (aImage.gridsize <= 0) then
			return;
		end

		local nSpace = getTokenSpace(tokenMap);
		local nSpacePixels = nSpace * aImage.gridsize;
		local sOptTASG = OptionsManager.getOption("TASG");
		if sOptTASG == "80" then
			nSpacePixels = nSpacePixels * 0.8;
		end

		if aImage.tokenscale then
			local fNewScale = math.min((nSpacePixels * aImage.tokenscale) / w, (nSpacePixels * aImage.tokenscale) / h);
			if fNewScale < 0.9 or fNewScale > 1.1 then
				tokenMap.setScale(fNewScale);
			end
		elseif nSpacePixels > 0 then
			local fNewScale = math.min(w / nSpacePixels, h / nSpacePixels);
			tokenMap.setContainerScale(fNewScale);
		end
	end
end

--
-- Common token manager add-on health bar/dot functionality
--
-- Callback assumed input of:
--		* nodeCT
-- Assume callback function provided returns 3 parameters
--		* percent wounded (number), 
--		* status text (string), 
--		* status color (string, hex color)
--

TOKEN_HEALTHBAR_GRAPHIC_WIDTH = 20;
TOKEN_HEALTHBAR_GRAPHIC_HEIGHT = 200;

TOKEN_HEALTHBAR_FGU_HOFFSET = 0;
TOKEN_HEALTHBAR_FGU_WIDTH = 10;
TOKEN_HEALTHDOT_FGU_HOFFSET = 0;
TOKEN_HEALTHDOT_FGU_VOFFSET = 0;
TOKEN_HEALTHDOT_FGU_SIZE = 10;

TOKEN_HEALTHBAR_FGC_VMIN = 14; -- Depends on graphic, and how much to show at zero health
TOKEN_HEALTHBAR_FGC_VEXTEND = 5; -- Runover for health bar vertically
TOKEN_HEALTHBAR_FGC_HOFFSET = -5; -- Offset for health bar horizontally (from right edge center)
TOKEN_HEALTHDOT_FGC_HOFFSET = -5;
TOKEN_HEALTHDOT_FGC_VOFFSET = -5;
TOKEN_HEALTHDOT_FGC_SIZE = 20;

function addDefaultHealthFeatures(f, aHealthFields)
	if not f then return; end
	bDisplayDefaultHealth = true;
	fGetHealthInfo = f;
	registerWidgetSet("health", {"healthbar", "healthdot"});

	for _,sField in ipairs(aHealthFields) do
		CombatManager.addCombatantFieldChangeHandler(sField, "onUpdate", updateHealth);
	end

	OptionsManager.registerOption2("TGMH", false, "option_header_token", "option_label_TGMH", "option_entry_cycler", 
			{ labels = "option_val_bar|option_val_barhover|option_val_dot|option_val_dothover", values = "bar|barhover|dot|dothover", baselabel = "option_val_off", baseval = "off", default = "dot" });
	OptionsManager.registerOption2("TNPCH", false, "option_header_token", "option_label_TNPCH", "option_entry_cycler", 
			{ labels = "option_val_bar|option_val_barhover|option_val_dot|option_val_dothover", values = "bar|barhover|dot|dothover", baselabel = "option_val_off", baseval = "off", default = "dot" });
	OptionsManager.registerOption2("TPCH", false, "option_header_token", "option_label_TPCH", "option_entry_cycler", 
			{ labels = "option_val_bar|option_val_barhover|option_val_dot|option_val_dothover", values = "bar|barhover|dot|dothover", baselabel = "option_val_off", baseval = "off", default = "dot" });
	OptionsManager.registerOption2("WNDC", false, "option_header_combat", "option_label_WNDC", "option_entry_cycler", 
			{ labels = "option_val_detailed", values = "detailed", baselabel = "option_val_simple", baseval = "off", default = "off" });
	DB.addHandler("options.TGMH", "onUpdate", onOptionChanged);
	DB.addHandler("options.TNPCH", "onUpdate", onOptionChanged);
	DB.addHandler("options.TPCH", "onUpdate", onOptionChanged);
	DB.addHandler("options.WNDC", "onUpdate", onOptionChanged);
end
function updateHealth(nodeField)
	local nodeCT = nodeField.getParent();
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateHealthHelper(tokenCT, nodeCT);
		updateTooltip(tokenCT, nodeCT);
	end
end
function updateHealthHelper(tokenCT, nodeCT)
	local sOptTH;
	if User.isHost() then
		sOptTH = OptionsManager.getOption("TGMH");
	elseif DB.getValue(nodeCT, "friendfoe", "") == "friend" then
		sOptTH = OptionsManager.getOption("TPCH");
	else
		sOptTH = OptionsManager.getOption("TNPCH");
	end
	local aWidgets = getWidgetList(tokenCT, "health");

	if sOptTH == "off" then
		for _,vWidget in pairs(aWidgets) do
			vWidget.destroy();
		end
	else
		local nPercentWounded,sStatus,sColor = fGetHealthInfo(nodeCT);
		if sOptTH == "bar" or sOptTH == "barhover" then
			local w, h = tokenCT.getSize();
		
			local bAddBar = false;
			if Interface.getVersion() >= 4 then
				if h > 0 then
					bAddBar = true; 
				end
			else
				if h >= TOKEN_HEALTHBAR_FGC_VMIN then
					bAddBar = true;
				end
			end						

			if bAddBar then
				local widgetHealthBar = aWidgets["healthbar"];

				-- START Draw horizontal health bar if menu option set
				if OptionsManager.getOption('CE_HHB') ~= "option_off" then
					if not widgetHealthBar then	
						HealthGraphicUpdater.drawHorizontalHealthBar(tokenCT, nil, sOptTH == "bar")
					end
					if widgetHealthBar then
						HealthGraphicUpdater.drawHorizontalHealthBar(tokenCT, widgetHealthBar, sOptTH == "bar")
					end
				-- END Draw horizontal health bar if menu option set
			
				else
					if not widgetHealthBar then					
						widgetHealthBar = tokenCT.addBitmapWidget("healthbar");
						widgetHealthBar.sendToBack();
						widgetHealthBar.setName("healthbar");
					end
					if widgetHealthBar then
						widgetHealthBar.sendToBack();
						widgetHealthBar.setColor(sColor);
						widgetHealthBar.setTooltipText(sStatus);
						widgetHealthBar.setVisible(sOptTH == "bar");
						updateHealthBarScale(tokenCT, nPercentWounded);
					end
				end					
			end
			
			if aWidgets["healthdot"] then
				aWidgets["healthdot"].destroy();
			end
		elseif sOptTH == "dot" or sOptTH == "dothover" then
			local widgetHealthDot = aWidgets["healthdot"];

			-- START Draw larger health dot if menu option set
			if OptionsManager.getOption('CE_LHD') ~= "option_off" then
				if not widgetHealthDot then	
					HealthGraphicUpdater.drawLargerHealthDot(tokenCT, nil, sOptTH == "dothover")
				end
				if widgetHealthDot then
					HealthGraphicUpdater.drawLargerHealthDot(tokenCT, widgetHealthDot, sOptTH == "dothover")
				end
			-- END Draw larger health dot if menu option set			

			else			
				if not widgetHealthDot then
					widgetHealthDot = tokenCT.addBitmapWidget("healthdot");
					if Interface.getVersion() >= 4 then
						widgetHealthDot.setPosition("bottomright", TOKEN_HEALTHDOT_FGU_HOFFSET, TOKEN_HEALTHDOT_FGU_VOFFSET);
					else
						widgetHealthDot.setPosition("bottomright", TOKEN_HEALTHDOT_FGC_HOFFSET, TOKEN_HEALTHDOT_FGC_VOFFSET);
					end
					widgetHealthDot.setName("healthdot");
					if Interface.getVersion() >= 4 then
						widgetHealthDot.setSize(TOKEN_HEALTHDOT_FGU_SIZE, TOKEN_HEALTHDOT_FGU_SIZE);
					else
						widgetHealthDot.setSize(TOKEN_HEALTHDOT_FGC_SIZE, TOKEN_HEALTHDOT_FGC_SIZE);
					end
				end
						
				if widgetHealthDot then
					widgetHealthDot.setColor(sColor);
					widgetHealthDot.setTooltipText(sStatus);
					widgetHealthDot.setVisible(sOptTH == "dot");
				end

			end

			if aWidgets["healthbar"] then
				aWidgets["healthbar"].destroy();
			end
		end
	end
end
function updateHealthBarScale(tokenCT, nPercentWounded)
	local widgetHealthBar = tokenCT.findWidget("healthbar");
	if widgetHealthBar then
		if Interface.getVersion() >= 4 then
			local nPercentHealth = math.max(1.0 - nPercentWounded, 0);

			local barw = TOKEN_HEALTHBAR_FGU_WIDTH;
			local barh = nPercentHealth * 100;
			
			local sOptTASG = OptionsManager.getOption("TASG");
			if sOptTASG == "80" then
				barw = barw * 0.8;
				barh = barh * 0.8;
			end
			
			local nClip = TOKEN_HEALTHBAR_GRAPHIC_HEIGHT * nPercentWounded;
			widgetHealthBar.setClipRegion(0, nClip, TOKEN_HEALTHBAR_GRAPHIC_WIDTH, TOKEN_HEALTHBAR_GRAPHIC_HEIGHT - nClip);
			widgetHealthBar.setSize(barw, barh);
			widgetHealthBar.setPosition("bottomright", TOKEN_HEALTHBAR_FGU_HOFFSET, -(barh / 2));
		else
			local w, h = tokenCT.getSize();
			h = h + TOKEN_HEALTHBAR_FGC_VEXTEND;

			widgetHealthBar.setSize();
			local barw,barh = widgetHealthBar.getSize();
			
			-- Resize bar to match health percentage, but preserve bulb portion of bar graphic
			if h >= TOKEN_HEALTHBAR_FGC_VMIN then
				barh = (math.max(1.0 - nPercentWounded, 0) * (math.min(h, barh) - TOKEN_HEALTHBAR_FGC_VMIN)) + TOKEN_HEALTHBAR_FGC_VMIN;
			else
				barh = TOKEN_HEALTHBAR_FGC_VMIN;
			end

			widgetHealthBar.setSize(barw, barh, "bottom");
			widgetHealthBar.setPosition("bottomright", TOKEN_HEALTHBAR_FGC_HOFFSET, -(barh / 2) + TOKEN_HEALTHBAR_FGC_VEXTEND);
		end
	end
end

--
-- Common token manager add-on effect functionality
--
-- Callback assumed input of: 
--		* nodeCT
--		* bSkipGMOnlyEffects
-- Callback assumed output of: 
--		* integer-based array of tables with following format
-- 			{ 
--				sName = "<Effect name to display>", (Currently, as effect icon tooltips when each displayed)
--				sIcon = "<Effect icon asset to display on token>",
--				sEffect = "<Original effect string>" (Currently used for large tooltips (multiple effects))
--			}
--

TOKEN_MAX_EFFECTS = 6;
TOKEN_EFFECT_MARGIN = 0;
TOKEN_EFFECT_OFFSETMAXX = 14; -- Prevent overlap with health bar

TOKEN_EFFECT_FGC_SIZE_SMALL = 18;
TOKEN_EFFECT_FGC_SIZE_STANDARD = 24;
TOKEN_EFFECT_FGC_SIZE_LARGE = 30;

TOKEN_EFFECT_FGU_SIZE_SMALL = 10;
TOKEN_EFFECT_FGU_SIZE_STANDARD = 15;
TOKEN_EFFECT_FGU_SIZE_LARGE = 20;

function addDefaultEffectFeatures(f, f2)
	bDisplayDefaultEffects = true;
	fGetEffectInfo = f or getEffectInfoDefault;
	fParseEffectComp = f2 or EffectManager.parseEffectCompSimple;
	local aEffectSet = {}; for i = 1, TOKEN_MAX_EFFECTS do table.insert(aEffectSet, "effect" .. i); end
	registerWidgetSet("effect", aEffectSet);

	CombatManager.setCustomAddCombatantEffectHandler(updateEffects);
	CombatManager.setCustomDeleteCombatantEffectHandler(updateEffects);
	CombatManager.addCombatantEffectFieldChangeHandler("isactive", "onAdd", updateEffectsField);
	CombatManager.addCombatantEffectFieldChangeHandler("isactive", "onUpdate", updateEffectsField);
	CombatManager.addCombatantEffectFieldChangeHandler("isgmonly", "onAdd", updateEffectsField);
	CombatManager.addCombatantEffectFieldChangeHandler("isgmonly", "onUpdate", updateEffectsField);
	CombatManager.addCombatantEffectFieldChangeHandler("label", "onAdd", updateEffectsField);
	CombatManager.addCombatantEffectFieldChangeHandler("label", "onUpdate", updateEffectsField);

	OptionsManager.registerOption2("TGME", false, "option_header_token", "option_label_TGME", "option_entry_cycler", 
			{ labels = "option_val_icons|option_val_iconshover|option_val_mark|option_val_markhover", values = "on|hover|mark|markhover", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("TNPCE", false, "option_header_token", "option_label_TNPCE", "option_entry_cycler", 
			{ labels = "option_val_icons|option_val_iconshover|option_val_mark|option_val_markhover", values = "on|hover|mark|markhover", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("TPCE", false, "option_header_token", "option_label_TPCE", "option_entry_cycler", 
			{ labels = "option_val_icons|option_val_iconshover|option_val_mark|option_val_markhover", values = "on|hover|mark|markhover", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("TESZ", false, "option_header_token", "option_label_TESZ", "option_entry_cycler", 
			{ labels = "option_val_small|option_val_large", values = "small|large", baselabel = "option_val_standard", baseval = "", default = "" });
	DB.addHandler("options.TGME", "onUpdate", onOptionChanged);
	DB.addHandler("options.TNPCE", "onUpdate", onOptionChanged);
	DB.addHandler("options.TPCE", "onUpdate", onOptionChanged);
	DB.addHandler("options.TESZ", "onUpdate", onOptionChanged);
end
function updateEffectsField(nodeEffectField)
	updateEffects(nodeEffectField.getChild("...."));
end
function updateEffects(nodeCT)
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);
	if tokenCT then
		updateEffectsHelper(tokenCT, nodeCT);
		updateTooltip(tokenCT, nodeCT);
	end
end
function updateEffectsHelper(tokenCT, nodeCT)
	local sOptTE;
	if User.isHost() then
		sOptTE = OptionsManager.getOption("TGME");
	elseif DB.getValue(nodeCT, "friendfoe", "") == "friend" then
		sOptTE = OptionsManager.getOption("TPCE");
	else
		sOptTE = OptionsManager.getOption("TNPCE");
	end

	local sOptTASG = OptionsManager.getOption("TASG");
	local sOptTESZ = OptionsManager.getOption("TESZ");
	local nEffectSize;
	if Interface.getVersion() >= 4 then
		nEffectSize = TOKEN_EFFECT_FGU_SIZE_STANDARD;
		if sOptTESZ == "small" then
			nEffectSize = TOKEN_EFFECT_FGU_SIZE_SMALL;
		elseif sOptTESZ == "large" then
			nEffectSize = TOKEN_EFFECT_FGU_SIZE_LARGE;
		end
		if sOptTASG == "80" then
			nEffectSize = nEffectSize * 0.8;
		end
	else
		nEffectSize = TOKEN_EFFECT_FGC_SIZE_STANDARD;
		if sOptTESZ == "small" then
			nEffectSize = TOKEN_EFFECT_FGC_SIZE_SMALL;
		elseif sOptTESZ == "large" then
			nEffectSize = TOKEN_EFFECT_FGC_SIZE_LARGE;
		end
	end
	
	local aWidgets = getWidgetList(tokenCT, "effect");
	
	if sOptTE == "off" then
		for _, vWidget in pairs(aWidgets) do
			vWidget.destroy();
		end
	elseif sOptTE == "mark" or sOptTE == "markhover" then
		local bWidgetsVisible = (sOptTE == "mark");
		
		local aTooltip = {};
		local aCondList = fGetEffectInfo(nodeCT);
		for _,v in ipairs(aCondList) do
			table.insert(aTooltip, v.sEffect);
		end
		
		if #aTooltip > 0 then
			local w = aWidgets["effect1"];
			if not w then
				w = tokenCT.addBitmapWidget();
				if w then
					w.setName("effect1");
				end
			end
			if w then
				w.setBitmap("cond_generic");
				w.setTooltipText(table.concat(aTooltip, "\r"));
				w.setPosition("bottomleft", (nEffectSize / 2), -(nEffectSize / 2));
				w.setSize(nEffectSize, nEffectSize);
				w.setVisible(bWidgetsVisible);
			end
			for i = 2, TOKEN_MAX_EFFECTS do
				local w = aWidgets["effect" .. i];
				if w then
					w.destroy();
				end
			end
		else
			for i = 1, TOKEN_MAX_EFFECTS do
				local w = aWidgets["effect" .. i];
				if w then
					w.destroy();
				end
			end
		end
	else
		local bWidgetsVisible = (sOptTE == "on");
		
		local aCondList = fGetEffectInfo(nodeCT);
		local nConds = #aCondList;
		
		local wTokenEffectMax;
		if Interface.getVersion() >= 4 then
			if sOptTASG == "80" then
				wTokenEffectMax = 60;
			else
				wTokenEffectMax = 80;
			end
		else
			local wToken,_ = tokenCT.getSize();
			wTokenEffectMax = wToken - TOKEN_EFFECT_OFFSETMAXX;
		end
		
		local wLast = nil;
		local lastposx = 0;
		local posx = 0;
		local i = 1;
		local nMaxLoop = math.min(nConds, TOKEN_MAX_EFFECTS);
		while i <= nMaxLoop do
			local w = aWidgets["effect" .. i];
			if not w then
				w = tokenCT.addBitmapWidget();
				if w then
					w.setName("effect" .. i);
				end
			end
			if w then
				w.setBitmap(aCondList[i].sIcon);
				w.setTooltipText(aCondList[i].sName);
				if wLast and posx + nEffectSize > wTokenEffectMax then
					w.destroy();
					wLast.setBitmap("cond_more");
					wLast.setPosition("bottomleft", lastposx + (nEffectSize / 2), -(nEffectSize / 2));
					wLast.setSize(nEffectSize, nEffectSize);
					local aTooltip = {};
					table.insert(aTooltip, wLast.getTooltipText());
					for j = i, nConds do
						table.insert(aTooltip, aCondList[j].sEffect);
					end
					wLast.setTooltipText(table.concat(aTooltip, "\r"));
					i = i + 1;
					break;
				end
				if i == nMaxLoop and nConds > nMaxLoop then
					w.setBitmap("cond_more");
					local aTooltip = {};
					for j = i, nConds do
						table.insert(aTooltip, aCondList[j].sEffect);
					end
					w.setTooltipText(table.concat(aTooltip, "\r"));
				end
				w.setPosition("bottomleft", posx + (nEffectSize / 2), -(nEffectSize / 2));
				w.setSize(nEffectSize, nEffectSize);
				lastposx = posx;
				posx = posx + nEffectSize + TOKEN_EFFECT_MARGIN;
				w.setVisible(bWidgetsVisible);
				wLast = w;
			end
			i = i + 1;
		end
		while i <= TOKEN_MAX_EFFECTS do
			local w = aWidgets["effect" .. i];
			if w then
				w.destroy();
			end
			i = i + 1;
		end
	end
end

function addEffectTagIconConditional(sType, f)
	aParseEffectTagConditional[sType] = f;
end
function addEffectTagIconBonus(vType)
	if type(vType) == "table" then
		for _,v in pairs(vType) do
			aParseEffectBonusTag[v] = true;
		end
	elseif type(vType) == "string" then
		aParseEffectBonusTag[vType] = true;
	end
end
function addEffectTagIconSimple(vType, sIcon)
	if type(vType) == "table" then
		for kTag,vTag in pairs(vType) do
			aParseEffectSimpleTag[kTag] = vTag;
		end
	elseif type(vType) == "string" then
		if not sIcon then return; end
		aParseEffectSimpleTag[vType] = sIcon;
	end
end
function addEffectConditionIcon(vType, sIcon)
	if type(vType) == "table" then
		for kCond,vCond in pairs(vType) do
			aParseEffectCondition[kCond:lower()] = vCond;
		end
	elseif type(vType) == "string" then
		if not sIcon then return; end
		aParseEffectCondition[vType] = sIcon;
	end
end
function getEffectInfoDefault(nodeCT, bSkipGMOnly)
	local aIconList = {};

	local rActor = ActorManager.getActor("ct", nodeCT);
	
	-- Iterate through effects
	local aSorted = {};
	for _,nodeChild in pairs(DB.getChildren(nodeCT, "effects")) do
		table.insert(aSorted, nodeChild);
	end
	table.sort(aSorted, function (a, b) return a.getName() < b.getName() end);

	for k,v in pairs(aSorted) do
		if DB.getValue(v, "isactive", 0) == 1 then
			if (not bSkipGMOnly and User.isHost()) or (DB.getValue(v, "isgmonly", 0) == 0) then
				local sLabel = DB.getValue(v, "label", "");
				
				local aEffectIcons = {};
				local aEffectComps = EffectManager.parseEffect(sLabel);
				for kComp,sEffectComp in ipairs(aEffectComps) do
					local vComp = fParseEffectComp(sEffectComp);
					local sTag = vComp.type;
					
					local sNewIcon = nil;
					local bContinue = true;
					local bBonusEffectMatch = false;
					
					for kCustom,_ in pairs(aParseEffectTagConditional) do
						if kCustom == sTag then
							bContinue = aParseEffectTagConditional[kCustom](rActor, v, vComp);
							sNewIcon = "";
							break;
						end
					end
					if not bContinue then
						break;
					end
					
					if not sNewIcon then
						for kBonus,_ in pairs(aParseEffectBonusTag) do
							if kBonus == sTag then
								bBonusEffectMatch = true;
								if #(vComp.dice) > 0 or vComp.mod > 0 then
									sNewIcon = "cond_bonus";
								elseif vComp.mod < 0 then
									sNewIcon = "cond_penalty";
								else
									sNewIcon = "";
								end
								break;
							end
						end
					end
					if not sNewIcon then
						sNewIcon = aParseEffectSimpleTag[sTag];
					end
					if not sNewIcon then
						sTag = vComp.original:lower();
						sNewIcon = aParseEffectCondition[sTag];
					end
					
					aEffectIcons[kComp] = sNewIcon;
				end
				
				if #aEffectComps > 0 then
					-- If the first effect component didn't match anything, use it as a name
					local sFinalName = nil;
					if not aEffectIcons[1] then
						sFinalName = aEffectComps[1].original;
					end
					
					-- If all icons match, then use the matching icon, otherwise, use the generic icon
					local sFinalIcon = nil;
					local bSame = true;
					for _,vIcon in pairs(aEffectIcons) do
						if (vIcon or "") ~= "" then
							if sFinalIcon then
								if sFinalIcon ~= vIcon then
									sFinalIcon = nil;
									break;
								end
							else
								sFinalIcon = vIcon;
							end
						end
					end
					
					table.insert(aIconList, { sName = sFinalName or sLabel, sIcon = sFinalIcon or "cond_generic", sEffect = sLabel } );
				end
			end
		end
	end
	
	return aIconList;
end
