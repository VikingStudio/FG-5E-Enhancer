-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

CT_MAIN_PATH = "combattracker";
CT_COMBATANT_PATH = "combattracker.list.*";
CT_LIST = "combattracker.list";
CT_ROUND = "combattracker.round";

local sActiveCT = nil;
OOB_MSGTYPE_ENDTURN = "endturn";

function onInit()
	Interface.onDesktopInit = onDesktopInit;

	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_ENDTURN, handleEndTurn);
end

function onDesktopInit()
	DB.addHandler(CT_COMBATANT_PATH, "onDelete", onDeleteCombatantEvent);
	DB.addHandler(DB.getPath(CT_COMBATANT_PATH, "effects"), "onChildAdded", onAddCombatantEffectEvent);
	DB.addHandler(DB.getPath(CT_COMBATANT_PATH, "effects"), "onChildDeleted", onDeleteCombatantEffectEvent);
	DB.addHandler("charsheet.*", "onDelete", onCharDelete);
end

--
-- COMBATANT HANDLERS
-- NOTE: Combatant list/count handler is single linked, combat event handlers are multi-linked, and field handlers are unmanaged (ruleset code must add/remove)
--

local fCustomGetCombatantNodes = nil;
function setCustomGetCombatantNodes(f)
	fCustomGetCombatantNodes = f;
end

local aCustomDeleteCombatantHandlers = {};
function setCustomDeleteCombatantHandler(f)
	table.insert(aCustomDeleteCombatantHandlers, f);
end
function removeCustomDeleteCombatantHandler(f)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete == f then
			table.remove(aCustomDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEvent(nodeCT)
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete(nodeCT) then
			return true;
		end
	end
	return false;
end

local aCustomAddCombatantEffectHandlers = {};
function setCustomAddCombatantEffectHandler(f)
	table.insert(aCustomAddCombatantEffectHandlers, f);
end
function removeCustomAddCombatantEffectHandler(f)
	for kCustomAdd,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd == f then
			table.remove(aCustomAddCombatantEffectHandlers, kCustomAdd);
			return true;
		end
	end
	return false;
end
function onAddCombatantEffectEvent(nodeEffectList, nodeEffect)
	for _,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd(nodeEffectList.getParent(), nodeEffect) then
			return true;
		end
	end
	return false;
end

local aCustomDeleteCombatantEffectHandlers = {};
function setCustomDeleteCombatantEffectHandler(f)
	table.insert(aCustomDeleteCombatantEffectHandlers, f);
end
function removeCustomDeleteCombatantEffectHandler(f)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete == f then
			table.remove(aCustomDeleteCombatantEffectHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEffectEvent(nodeEffectList)
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete(nodeEffectList.getParent()) then
			return true;
		end
	end
	return false;
end

function addCombatantFieldChangeHandler(sField, sEvent, f)
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, sField), sEvent, f);
end
function removeCombatantFieldChangeHandler(sField, sEvent, f)
	DB.removeHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, sField), sEvent, f);
end
function addCombatantEffectFieldChangeHandler(sField, sEvent, f)
	DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects.*", sField), sEvent, f);
end
function removeCombatantEffectFieldChangeHandler(sField, sEvent, f)
	DB.removeHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH, "effects.*", sField), sEvent, f);
end

--
-- MULTI HANDLERS
-- NOTE: Handlers added here will all be called in the order they were added.
--

local aCustomDrop = {};
function setCustomDrop(fDrop)
	table.insert(aCustomDrop, fDrop);
end
function onDropEvent(rSource, rTarget, draginfo)
	if #aCustomDrop > 0 then
		for _,fCustomDrop in ipairs(aCustomDrop) do
			if fCustomDrop(rSource, rTarget, draginfo) then
				return true;
			end
		end
	end
end

local aCustomRoundStart = {};
function setCustomRoundStart(fRoundStart)
	table.insert(aCustomRoundStart, fRoundStart);
end
function onRoundStartEvent(nCurrent)
	if #aCustomRoundStart > 0 then
		for _,fCustomRoundStart in ipairs(aCustomRoundStart) do
			fCustomRoundStart(nCurrent);
		end
	end
end

local aCustomTurnStart = {};
function setCustomTurnStart(fTurnStart)
	table.insert(aCustomTurnStart, fTurnStart);
end
function onTurnStartEvent(nodeCT)
	if #aCustomTurnStart > 0 then
		for _,fCustomTurnStart in ipairs(aCustomTurnStart) do
			fCustomTurnStart(nodeCT);
		end
	end
end

local aCustomTurnEnd = {};
function setCustomTurnEnd(fTurnEnd)
	table.insert(aCustomTurnEnd, fTurnEnd);
end
function onTurnEndEvent(nodeCT)
	if #aCustomTurnEnd > 0 then
		for _,fCustomTurnEnd in ipairs(aCustomTurnEnd) do
			fCustomTurnEnd(nodeCT);
		end
	end
end

local aCustomInitChange = {};
function setCustomInitChange(fInitChange)
	table.insert(aCustomInitChange, fInitChange);
end
function onInitChangeEvent(nodeOldCT, nodeNewCT)
	if #aCustomInitChange > 0 then
		for _,fCustomInitChange in ipairs(aCustomInitChange) do
			fCustomInitChange(nodeOldCT, nodeNewCT);
		end
	end
end

local aCustomCombatReset = {};
function setCustomCombatReset(fCombatReset)
	table.insert(aCustomCombatReset, fCombatReset);
end
function onCombatResetEvent()
	if #aCustomCombatReset > 0 then
		for _,fCustomCombatReset in ipairs(aCustomCombatReset) do
			fCustomCombatReset();
		end
	end
end

--
-- SINGLE HANDLERS
-- NOTE: Setting these handlers will override previous handlers
--

local fCustomSort = nil;
function setCustomSort(fSort)
	fCustomSort = fSort;
end
function getCustomSort()
	return fCustomSort;
end
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
function onSortCompare(node1, node2)
	if fCustomSort then
		return not fCustomSort(node1, node2);
	end
	
	return not sortfuncSimple(node1, node2);
end

local fCustomAddPC = nil;
function setCustomAddPC(fAddPC)
	fCustomAddPC = fAddPC;
end
function getCustomAddPC()
	return fCustomAddPC;
end
local fCustomAddNPC = nil;
function setCustomAddNPC(fAddNPC)
	fCustomAddNPC = fAddNPC;
end
function getCustomAddNPC()
	return fCustomAddNPC;
end
local fCustomAddBattle = nil;
function setCustomAddBattle(fAddBattle)
	fCustomAddBattle = fAddBattle;
end
function getCustomAddBattle()
	return fCustomAddBattle;
end
local fCustomNPCSpaceReach = nil;
function setCustomNPCSpaceReach(fNPCSpaceReach)
	fCustomNPCSpaceReach = fNPCSpaceReach;
end
function getCustomNPCSpaceReach()
	return fCustomNPCSpaceReach;
end


--
-- GENERAL
--

function getCombatantNodes()
	if fCustomGetCombatantNodes then
		return fCustomGetCombatantNodes();
	end
	return DB.getChildren(CT_LIST);
end

function getCombatantCount()
	if fCustomGetCombatantNodes then
		return #(fCustomGetCombatantNodes());
	end
	return DB.getChildCount(CT_LIST);
end

function getActiveCT()
	for _,v in pairs(getCombatantNodes()) do
		if DB.getValue(v, "active", 0) == 1 then
			return v;
		end
	end
	return nil;
end

function getCTFromNode(varNode)
	-- Get path name desired
	local sNode = "";
	if type(varNode) == "string" then
		sNode = varNode;
	elseif type(varNode) == "databasenode" then
		sNode = varNode.getNodeName();
	else
		return nil, "";
	end
	
	-- Check for exact CT match
	for _,v in pairs(getCombatantNodes()) do
		if v.getNodeName() == sNode then
			return v, v.getNodeName();
		end
	end

	-- Otherwise, check for link match
	for _,v in pairs(getCombatantNodes()) do
		local sClass, sRecord = DB.getValue(v, "link", "", "");
		if sRecord == sNode then
			return v, v.getNodeName();
		end
	end

	return nil, "";
end

function getCTFromTokenRef(vContainer, nId)
	local sContainerNode = nil;
	if type(vContainer) == "string" then
		sContainerNode = vContainer;
	elseif type(vContainer) == "databasenode" then
		sContainerNode = vContainer.getNodeName();
	else
		return nil;
	end
	
	for _,v in pairs(getCombatantNodes()) do
		local sCTContainerName = DB.getValue(v, "tokenrefnode", "");
		local nCTId = tonumber(DB.getValue(v, "tokenrefid", "")) or 0;
		if (sCTContainerName == sContainerNode) and (nCTId == nId) then
			return v;
		end
	end
	
	return nil;
end

function getCTFromToken(token)
	if not token then
		return nil;
	end
	
	local nodeContainer = token.getContainerNode();
	local nID = token.getId();

	return getCTFromTokenRef(nodeContainer, nID);
end

function getTokenFromCT(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	
	if not nodeCT then
		return nil;
	end
	
	return Token.getToken(DB.getValue(nodeCT, "tokenrefnode", ""), DB.getValue(nodeCT, "tokenrefid", ""));
end

function getCurrentUserCT()
	if User.isHost() then
		return getActiveCT();
	end
	
	-- If active identity is owned, then use that one
	local nodeActive = getActiveCT();
	local sClass, sRecord = DB.getValue(nodeActive, "link", "npc", "");
	if sClass == "charsheet" then
		local aOwned = User.getOwnedIdentities();
		for _,v in ipairs(aOwned) do
			if sRecord == ("charsheet." .. v) then
				return nodeActive;
			end
		end
	end
	
	-- Otherwise, use active identity (if any)
	local sID = User.getCurrentIdentity();
	if sID then
		return getCTFromNode("charsheet." .. sID);
	end

	return nil;
end

function openMap(vNode)
	local nodeCT = getCTFromNode(vNode);
	if not nodeCT then return; end
	centerOnToken(nodeCT, true);
end

function isCTHidden(vEntry)
	local nodeCT = nil;
	if type(vEntry) == "string" then
		nodeCT = DB.findNode(vEntry);
	elseif type(vEntry) == "databasenode" then
		nodeCT = vEntry;
	end
	if not nodeCT then
		return false;
	end
	
	if DB.getValue(nodeCT, "friendfoe", "") == "friend" then
		return false;
	end
	if DB.getValue(nodeCT, "tokenvis", 0) == 1 then
		return false;
	end
	return true;
end

function onCharDelete(nodeChar)
	local nodeCT = getCTFromNode(nodeChar);
	if nodeCT then
		DB.setValue(nodeCT, "link", "windowreference", "npc", "");
	end
end

function onTokenDelete(tokenMap)
	local nodeCT = getCTFromToken(tokenMap);
	if nodeCT then
		DB.setValue(nodeCT, "tokenrefnode", "string", "");
		DB.setValue(nodeCT, "tokenrefid", "string", "");
	end
end

--
-- COMBAT TRACKER SORT
--
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
--

function sortfuncSimple(node1, node2)
	return node1.getNodeName() < node2.getNodeName();
end

function sortfuncStandard(node1, node2)
	local bHost = User.isHost();
	local sOptCTSI = OptionsManager.getOption("CTSI");
	
	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");
	
	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
	
	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return node1.getNodeName() < node2.getNodeName();
end

function sortfuncDnD(node1, node2)
	local bHost = User.isHost();
	local sOptCTSI = OptionsManager.getOption("CTSI");
	local sOptCTSI = OptionsManager.getOption("CTSI");
	
	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");
	
	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
	
	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
			
			nValue1 = DB.getValue(node1, "init", 0);
			nValue2 = DB.getValue(node2, "init", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return node1.getNodeName() < node2.getNodeName();
end

function getSortedCombatantList()
	local aEntries = {};
	for _,v in pairs(getCombatantNodes()) do
		table.insert(aEntries, v);
	end
	if #aEntries > 0 then
		if fCustomSort then
			table.sort(aEntries, fCustomSort);
		else
			table.sort(aEntries, sortfuncSimple);
		end
	end
	return aEntries;
end

--
-- TURN FUNCTIONS
--

function handleEndTurn(msgOOB)
	local rActor = ActorManager.getActorFromCT(getActiveCT());
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sActorType == "pc" then
		if nodeActor.getOwner() == msgOOB.user then
			nextActor();
		end
	end
end

function notifyEndTurn()
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_ENDTURN;
	msgOOB.user = User.getUsername();

	Comm.deliverOOBMessage(msgOOB, "");
end

function addGMIdentity(nodeEntry)
	if OptionsManager.isOption("CTAV", "on") then
		local sName = ActorManager.getDisplayName(nodeEntry);
		local sClass,_ = DB.getValue(nodeEntry, "link", "", "");
		
		if sClass == "charsheet" or sName == "" then
			GmIdentityManager.activateGMIdentity();
		else
			if GmIdentityManager.existsIdentity(sName) then
				GmIdentityManager.setCurrent(sName);
			else
				sActiveCT = sName;
				GmIdentityManager.addIdentity(sName);
			end
		end
	end
end

function clearGMIdentity()
	if sActiveCT then
		GmIdentityManager.removeIdentity(sActiveCT);
		sActiveCT = nil;
	end
end

-- Handle turn notification (including bell ring based on option)
function showTurnMessage(nodeEntry, bActivate, bSkipBell)
	local sName = ActorManager.getDisplayName(nodeEntry);
	local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
	local sFaction = DB.getValue(nodeEntry, "friendfoe", "");
	local bHidden = isCTHidden(nodeEntry);

	local msg = {font = "narratorfont", icon = "turn_flag"};
	msg.text = "[" .. Interface.getString("combat_tag_turn") .. "] " .. sName;
	if OptionsManager.isOption("RSHE", "on") then
		local sEffects = EffectManager.getEffectsString(nodeEntry, true);
		if sEffects ~= "" then
			msg.text = msg.text .. " - [" .. sEffects .. "]";
		end
	end
	if bHidden then
		msg.secret = true;
		Comm.addChatMessage(msg);
	else
		Comm.deliverChatMessage(msg);
	end
	if not bHidden and (sClass == "charsheet") then
		if bActivate and not bSkipBell and OptionsManager.isOption("RING", "on") then
			if sRecord ~= "" then
				local nodePC = DB.findNode(sRecord);
				if nodePC then
					local sOwner = nodePC.getOwner();
					if sOwner then
						User.ringBell(sOwner);
					end
				end
			end
		end
	end
end

function requestActivation(nodeEntry, bSkipBell)
	-- De-activate all other entries
	for _,v in pairs(getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end
	
	-- Set active flag
	DB.setValue(nodeEntry, "active", "number", 1);

	-- Turn notification
	showTurnMessage(nodeEntry, true, bSkipBell);

	-- Handle GM identity list updates (based on option)
	clearGMIdentity();
	addGMIdentity(nodeEntry);
end

function centerOnToken(nodeEntry, bOpen)
	if not User.isHost() then
		local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
		if sClass ~= "charsheet" then return; end
		local bOwned = DB.isOwner(sRecord);
		if not bOwned then return; end
	end
	ImageManager.centerOnToken(getTokenFromCT(nodeEntry), bOpen);
end

function nextActor(bSkipBell, bNoRoundAdvance)
	if not User.isHost() then
		return;
	end

	local nodeActive = getActiveCT();
	local nIndexActive = 0;
	
	-- Check the skip hidden NPC option
	local bSkipHidden = OptionsManager.isOption("CTSH", "on");
	-- Check the ship for actors that haven't rolled initiative
	local bSkipNonInitiativedActors = OptionsManager.isOption("CE_SNIA", "on");		
	-- Determine the next actor
	local nodeNext = nil;
	local aEntries = getSortedCombatantList();
	if #aEntries > 0 then
		if nodeActive then
			for i = 1,#aEntries do
				if aEntries[i] == nodeActive then
					nIndexActive = i;
					break;
				end
			end
		end
		if bSkipHidden or bSkipNonInitiativedActors then
			local nIndexNext = 0;
			for i = nIndexActive + 1, #aEntries do
				--if DB.getValue(aEntries[i], "friendfoe", "") == "friend" then       <-- Original Code: Won't skip if actor is friendly
				if DB.getValue(aEntries[i], "friendfoe", "") == "SKIP THIS SECTION JUMP RIGHT TO THE ELSE BELOW" then
					nIndexNext = i;
					-- check if initiative is 0 value (default in db if no entry). if so set index to 1 (first actor) and exit function, as all non-iniatived actors will be piled at the bottom of the CT				
					local initiative = DB.getValue(aEntries[i], 'initresult');					
					if initiative == 0 then
						nIndexActive = 0;
						Debug.console('CT actor has no rolled initiative');						
					end		
					break;
				else
					if not isCTHidden(aEntries[i]) then
						nIndexNext = i;
						
						-- check if initiative is 0 value (default in db if no entry). if so set index to 1 (first actor) and exit function, as all non-iniatived actors will be piled at the bottom of the CT				
						local initiative = DB.getValue(aEntries[i], 'initresult');						
						if initiative == 0 then
							nIndexNext = 0;
							Debug.console('CT actor has no rolled initiative');						
						end		
						break;
					end
				end
			end
			if nIndexNext > nIndexActive then
				nodeNext = aEntries[nIndexNext];
				for i = nIndexActive + 1, nIndexNext - 1 do
					showTurnMessage(aEntries[i], false);
				end
			end
		else
			nodeNext = aEntries[nIndexActive + 1];
		end
		
		-- if nodeActive then
			-- for i = 1,#aEntries do
				-- if aEntries[i] == nodeActive then
					-- nodeNext = aEntries[i+1];
				-- end
			-- end
		-- else
			-- nodeNext = aEntries[1];
		-- end
	end

	-- If next actor available, advance effects, activate and start turn
	if nodeNext then
		-- End turn for current actor
		onTurnEndEvent(nodeActive);
	
		-- Process effects in between current and next actors
		if nodeActive then
			onInitChangeEvent(nodeActive, nodeNext);
		else
			onInitChangeEvent(nil, nodeNext);
		end
		
		-- Start turn for next actor
		requestActivation(nodeNext, bSkipBell);
		onTurnStartEvent(nodeNext);
	elseif not bNoRoundAdvance then
		if bSkipHidden or bSkipNonInitiativedActors then
			for i = nIndexActive + 1, #aEntries do
				showTurnMessage(aEntries[i], false);
			end
		end
		nextRound(1);
	end
end

function nextRound(nRounds)
	if not User.isHost() then
		return;
	end

	local nodeActive = getActiveCT();
	local nCurrent = DB.getValue(CT_ROUND, 0);

	-- If current actor, then advance based on that
	local nStartCounter = 1;
	local aEntries = getSortedCombatantList();
	if nodeActive then
		DB.setValue(nodeActive, "active", "number", 0);
		clearGMIdentity();

		local bFastTurn = false;
		for i = 1,#aEntries do
			if aEntries[i] == nodeActive then
				bFastTurn = true;
				onTurnEndEvent(nodeActive);
			elseif bFastTurn then
				onTurnStartEvent(aEntries[i]);
				onTurnEndEvent(aEntries[i]);
			end
		end
		
		onInitChangeEvent(nodeActive);

		nStartCounter = nStartCounter + 1;

		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = "[" .. Interface.getString("combat_tag_round") .. " " .. nCurrent .. "]";
		Comm.deliverChatMessage(msg);
	end
	for i = nStartCounter, nRounds do
		for i = 1,#aEntries do
			onTurnStartEvent(aEntries[i]);
			onTurnEndEvent(aEntries[i]);
		end
		
		onInitChangeEvent();
		
		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = "[" .. Interface.getString("combat_tag_round") .. " " .. nCurrent .. "]";
		Comm.deliverChatMessage(msg);
	end

	-- Update round counter
	DB.setValue(CT_ROUND, "number", nCurrent);
	
	-- Custom round start callback (such as per round initiative rolling)
	onRoundStartEvent(nCurrent);
	
	-- Check option to see if we should advance to first actor or stop on round start
	if OptionsManager.isOption("RNDS", "off") then
		local bSkipBell = (nRounds > 1);
		if getCombatantCount() > 0 then
			nextActor(bSkipBell, true);
		end
	end
end

--
-- DROP HANDLING
--

function onDrop(nodetype, nodename, draginfo)
	local rSource = ActionsManager.decodeActors(draginfo);
	local rTarget = ActorManager.getActor(nodetype, nodename);
	if rTarget then
		local sDragType = draginfo.getType();

		-- Faction changes
		if sDragType == "combattrackerff" then
			if User.isHost() then
				DB.setValue(ActorManager.getCTNode(rTarget), "friendfoe", "string", draginfo.getStringData());
				return true;
			end
		-- Actor targeting
		elseif sDragType == "targeting" then
			if User.isHost() then
				local _,sNodeSourceCT = draginfo.getShortcutData();
				TargetingManager.addCTTarget(DB.findNode(sNodeSourceCT), ActorManager.getCTNode(rTarget));
				return true;
			end
		-- Effect targeting
		elseif sDragType == "effect_targeting" then
			local _,sEffectNode = draginfo.getShortcutData();
			EffectManager.addEffectTarget(sEffectNode, ActorManager.getCTNodeName(rTarget));
			return true;
		end
	end
	
	-- Actions
	local sDragType = draginfo.getType();
	if StringManager.contains(GameSystem.targetactions, sDragType) then
		ActionsManager.actionDrop(draginfo, rTarget);
		return true;
	end

	return onDropEvent(rSource, rTarget, draginfo);
end

--
-- ADD FUNCTIONS
--

function addPC(nodePC)
	if fCustomAddPC then
		return fCustomAddPC(nodePC);
	end
	
	-- Parameter validation
	if not nodePC then
		return;
	end

	-- Create a new combat tracker window
	local nodeEntry = DB.createChild(CT_LIST);
	if not nodeEntry then
		return;
	end
	
	-- Set up the CT specific information
	DB.setValue(nodeEntry, "link", "windowreference", "charsheet", nodePC.getNodeName());
	DB.setValue(nodeEntry, "friendfoe", "string", "friend");

	local sToken = DB.getValue(nodePC, "token", nil);
	if not sToken or sToken == "" then
		sToken = "portrait_" .. nodePC.getName() .. "_token"
	end
	DB.setValue(nodeEntry, "token", "token", sToken);
end

function onBattleNPCLoadCallback(aCustom, bFoundWildcard)
	addBattle(aCustom.nodeBattle);
	
	if bFoundWildcard then
		Comm.SystemMessage(Interface.getString("module_message_missinglink_wildcard_battle"));
	end
end

function addBattle(nodeBattle)
	local aModulesToLoad = {};
	local sTargetNPCList = LibraryData.getCustomData("battle", "npclist") or "npclist";
	for _, vNPCItem in pairs(DB.getChildren(nodeBattle, sTargetNPCList)) do
		local sClass, sRecord = DB.getValue(vNPCItem, "link", "", "");
		if sRecord ~= "" then
			local nodeNPC = DB.findNode(sRecord);
			if not nodeNPC then
				local sModule = sRecord:match("@(.*)$");
				if sModule and sModule ~= "" and sModule ~= "*" then
					if not StringManager.contains(aModulesToLoad, sModule) then
						table.insert(aModulesToLoad, sModule);
					end
				end
			end
		end
		for _,vPlacement in pairs(DB.getChildren(vNPCItem, "maplink")) do
			local sClass, sRecord = DB.getValue(vPlacement, "imageref", "", "");
			if sRecord ~= "" then
				local nodeImage = DB.findNode(sRecord);
				if not nodeImage then
					local sModule = sRecord:match("@(.*)$");
					if sModule and sModule ~= "" and sModule ~= "*" then
						if not StringManager.contains(aModulesToLoad, sModule) then
							table.insert(aModulesToLoad, sModule);
						end
					end
				end
			end
		end
	end
	if #aModulesToLoad > 0 then
		local wSelect = Interface.openWindow("module_dialog_missinglink", "");
		wSelect.initialize(aModulesToLoad, onBattleNPCLoadCallback, { nodeBattle = nodeBattle });
		return;
	end
	
	if fCustomAddBattle then
		return fCustomAddBattle(nodeBattle);
	end
	
	-- Cycle through the NPC list, and add them to the tracker
	for _, vNPCItem in pairs(DB.getChildren(nodeBattle, sTargetNPCList)) do
		-- Get link database node
		local nodeNPC = nil;
		local sClass, sRecord = DB.getValue(vNPCItem, "link", "", "");
		if sRecord ~= "" then
			nodeNPC = DB.findNode(sRecord);
		end
		local sName = DB.getValue(vNPCItem, "name", "");
		
		if nodeNPC then
			local aPlacement = {};
			for _,vPlacement in pairs(DB.getChildren(vNPCItem, "maplink")) do
				local rPlacement = {};
				local _, sRecord = DB.getValue(vPlacement, "imageref", "", "");
				rPlacement.imagelink = sRecord;
				rPlacement.imagex = DB.getValue(vPlacement, "imagex", 0);
				rPlacement.imagey = DB.getValue(vPlacement, "imagey", 0);
				table.insert(aPlacement, rPlacement);
			end
			
			local nCount = DB.getValue(vNPCItem, "count", 0);
			for i = 1, nCount do
				local nodeEntry = addNPC(sClass, nodeNPC, sName);
				if nodeEntry then
					local sFaction = DB.getValue(vNPCItem, "faction", "");
					if sFaction ~= "" then
						DB.setValue(nodeEntry, "friendfoe", "string", sFaction);
					end
					local sToken = DB.getValue(vNPCItem, "token", "");
					if sToken == "" or not Interface.isToken(sToken) then
						local sLetter = StringManager.trim(sName):match("^([a-zA-Z])");
						if sLetter then
							sToken = "tokens/Medium/" .. sLetter:lower() .. ".png@Letter Tokens";
						else
							sToken = "tokens/Medium/z.png@Letter Tokens";
						end
					end
					if sToken ~= "" then
						DB.setValue(nodeEntry, "token", "token", sToken);
						
						if aPlacement[i] and aPlacement[i].imagelink ~= "" then
							TokenManager.setDragTokenUnits(DB.getValue(nodeEntry, "space"));
							local tokenAdded = Token.addToken(aPlacement[i].imagelink, sToken, aPlacement[i].imagex, aPlacement[i].imagey);
							TokenManager.endDragTokenWithUnits(nodeEntry);
							if tokenAdded then
								TokenManager.linkToken(nodeEntry, tokenAdded);
							end
						end
					end
					
					-- Set identification state from encounter record, and disable source link to prevent overriding ID for existing CT entries when identification state changes
					local sSourceClass,sSourceRecord = DB.getValue(nodeEntry, "sourcelink", "", "");
					DB.setValue(nodeEntry, "sourcelink", "windowreference", "", "");
					DB.setValue(nodeEntry, "isidentified", "number", DB.getValue(vNPCItem, "isidentified", 1));
					DB.setValue(nodeEntry, "sourcelink", "windowreference", sSourceClass, sSourceRecord);
				else
					ChatManager.SystemMessage(Interface.getString("ct_error_addnpcfail") .. " (" .. sName .. ")");
				end
			end
		else
			ChatManager.SystemMessage(Interface.getString("ct_error_addnpcfail2") .. " (" .. sName .. ")");
		end
	end
	
	Interface.openWindow("combattracker_host", "combattracker");
end

function stripCreatureNumber(s)
	local nStarts, _, sNumber = string.find(s, " ?(%d+)$");
	if nStarts then
		return string.sub(s, 1, nStarts - 1), sNumber;
	end
	return s;
end

function randomName(sBaseName)
	local aNames = {};
	for _,v in pairs(getCombatantNodes()) do
		local sName = DB.getValue(v, "name", "");
		if sName ~= "" then
			table.insert(aNames, DB.getValue(v, "name", ""));
		end
	end
	
	local nRandomRange = getCombatantCount() * 2;
	local sNewName = sBaseName;
	local nSuffix;
	local bContinue = true;
	while bContinue do
		bContinue = false;
		nSuffix = math.random(nRandomRange);
		sNewName = sBaseName .. " " .. nSuffix;
		if StringManager.contains(aNames, sNewName) then
			bContinue = true;
		end
	end

	return sNewName, nSuffix;
end

function addNPC(sClass, nodeNPC, sName)
	if fCustomAddNPC then
		return fCustomAddNPC(sClass, nodeNPC, sName);
	end
	
	local nodeEntry, nodeLastMatch = addNPCHelper(nodeNPC, sName);
	
	return nodeEntry;
end

function addNPCHelper(nodeNPC, sName)
	-- Parameter validation
	if not nodeNPC then
		return nil;
	end

	-- Setup
	local aCurrentCombatants = getCombatantNodes();
	
	-- Get the name to use for this addition
	local bIsCTNPC = (UtilityManager.getRootNodeName(nodeNPC) == CT_MAIN_PATH);
	local sNameLocal = sName;
	if not sNameLocal then
		sNameLocal = DB.getValue(nodeNPC, "name", "");
		if bIsCTNPC then
			sNameLocal = stripCreatureNumber(sNameLocal);
		end
	end
	local sNonIDLocal = DB.getValue(nodeNPC, "nonid_name", "");
	if sNonIDLocal == "" then
		sNonIDLocal = Interface.getString("library_recordtype_empty_nonid_npc");
	elseif bIsCTNPC then
		sNonIDLocal = stripCreatureNumber(sNonIDLocal);
	end
	
	local nLocalID = DB.getValue(nodeNPC, "isidentified", 1);
	if not bIsCTNPC then
		local sSourcePath = nodeNPC.getPath()
		local aMatches = {};
		for _,v in pairs(aCurrentCombatants) do
			local _,sRecord = DB.getValue(v, "sourcelink", "", "");
			if sRecord == sSourcePath then
				table.insert(aMatches, v);
			end
		end
		if #aMatches > 0 then
			nLocalID = 0;
			for _,v in ipairs(aMatches) do
				if DB.getValue(v, "isidentified", 1) == 1 then
					nLocalID = 1;
				end
			end
		end
	end
	
	local nodeLastMatch = nil;
	if sNameLocal:len() > 0 then
		-- Determine the number of NPCs with the same name
		local nNameHigh = 0;
		local aMatchesWithNumber = {};
		local aMatchesToNumber = {};
		for _,v in pairs(aCurrentCombatants) do
			local sEntryName = DB.getValue(v, "name", "");
			local sTemp, sNumber = stripCreatureNumber(sEntryName);
			if sTemp == sNameLocal then
				nodeLastMatch = v;
				
				local nNumber = tonumber(sNumber) or 0;
				if nNumber > 0 then
					nNameHigh = math.max(nNameHigh, nNumber);
					table.insert(aMatchesWithNumber, v);
				else
					table.insert(aMatchesToNumber, v);
				end
			end
		end
	
		-- If multiple NPCs of same name, then figure out whether we need to adjust the name based on options
		local sOptNNPC = OptionsManager.getOption("NNPC");
		if sOptNNPC ~= "off" then
			local nNameCount = #aMatchesWithNumber + #aMatchesToNumber;
			
			for _,v in ipairs(aMatchesToNumber) do
				local sEntryName = DB.getValue(v, "name", "");
				local sEntryNonIDName = DB.getValue(v, "nonid_name", "");
				if sEntryNonIDName == "" then
					sEntryNonIDName = Interface.getString("library_recordtype_empty_nonid_npc");
				end
				if sOptNNPC == "append" then
					nNameHigh = nNameHigh + 1;
					DB.setValue(v, "name", "string", sEntryName .. " " .. nNameHigh);
					DB.setValue(v, "nonid_name", "string", sEntryNonIDName .. " " .. nNameHigh);
				elseif sOptNNPC == "random" then
					local sNewName, nSuffix = randomName(sEntryName);
					DB.setValue(v, "name", "string", sNewName);
					DB.setValue(v, "nonid_name", "string", sEntryNonIDName .. " " .. nSuffix);
				end
			end
			
			if nNameCount > 0 then
				if sOptNNPC == "append" then
					nNameHigh = nNameHigh + 1;
					sNameLocal = sNameLocal .. " " .. nNameHigh;
					sNonIDLocal = sNonIDLocal .. " " .. nNameHigh;
				elseif sOptNNPC == "random" then
					local sNewName, nSuffix = randomName(sNameLocal);
					sNameLocal = sNewName;
					sNonIDLocal = sNonIDLocal .. " " .. nSuffix;
				end
			end
		end
	end
	
	DB.createNode(CT_LIST);
	local nodeEntry = DB.createChild(CT_LIST);
	if not nodeEntry then
		return nil;
	end
	DB.copyNode(nodeNPC, nodeEntry);

	-- Remove any combatant specific information
	DB.setValue(nodeEntry, "active", "number", 0);
	DB.setValue(nodeEntry, "tokenrefid", "string", "");
	DB.setValue(nodeEntry, "tokenrefnode", "string", "");
	DB.deleteChildren(nodeEntry, "effects");
	
	-- Set the final name value
	DB.setValue(nodeEntry, "name", "string", sNameLocal);
	DB.setValue(nodeEntry, "nonid_name", "string", sNonIDLocal);
	DB.setValue(nodeEntry, "isidentified", "number", nLocalID);
	
	-- Lock NPC record view by default when copying to CT
	DB.setValue(nodeEntry, "locked", "number", 1);

	-- Set up the CT specific information
	DB.setValue(nodeEntry, "link", "windowreference", "", ""); -- Workaround to force field update on client; client does not pass network update to other clients if setValue creates value node with default value
	DB.setValue(nodeEntry, "link", "windowreference", "npc", "");
	DB.setValue(nodeEntry, "friendfoe", "string", "foe");
	if not bIsCTNPC then
		DB.setValue(nodeEntry, "sourcelink", "windowreference", "npc", nodeNPC.getPath());
	end
	
	-- Calculate space/reach
	local nSpace, nReach = getNPCSpaceReach(nodeNPC);
	DB.setValue(nodeEntry, "space", "number", nSpace);
	DB.setValue(nodeEntry, "reach", "number", nReach);

	-- Set default letter token, if no token defined
	local sToken = DB.getValue(nodeNPC, "token", "");
	if sToken == "" or not Interface.isToken(sToken) then
		local sLetter = StringManager.trim(sNameLocal):match("^([a-zA-Z])");
		if sLetter then
			sToken = "tokens/Medium/" .. sLetter:lower() .. ".png@Letter Tokens";
		else
			sToken = "tokens/Medium/z.png@Letter Tokens";
		end
		DB.setValue(nodeEntry, "token", "token", sToken);
	end
	
	return nodeEntry, nodeLastMatch;
end

function getNPCSpaceReach(nodeNPC)
	if fCustomNPCSpaceReach then
		return fCustomNPCSpaceReach(nodeNPC);
	end
	
	local nDU = GameSystem.getDistanceUnitsPerGrid();
	local nSpace = (tonumber(DB.getValue(nodeNPC, "space", nDU)) or nDU);
	local nReach = (tonumber(DB.getValue(nodeNPC, "reach", nDU)) or nDU);
	return nSpace, nReach;
end

--
-- RESET FUNCTIONS
--

function resetInit()
	-- De-activate all entries
	for _,v in pairs(getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end
	
	-- Clear GM identity additions (based on option)
	clearGMIdentity();

	-- Reset the round counter
	DB.setValue(CT_ROUND, "number", 1);
	
	onCombatResetEvent();
end

function resetCombatantEffects()
	for _,v in pairs(getCombatantNodes()) do
		local nodeEffects = v.getChild("effects");
		if nodeEffects then
			for _,vEffect in pairs(nodeEffects.getChildren()) do
				vEffect.delete();
			end
		end
	end
end

--
-- GENERAL ITERATION FUNCTIONS
--

function callForEachCombatant(f, ...)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		f(v, ...);
	end
end

function callForEachCombatantEffect(f, ...)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		local nodeEffects = v.getChild("effects");
		if nodeEffects then
			for _,nodeEffect in pairs(nodeEffects.getChildren()) do
				f(nodeEffect, ...);
			end
		end
	end
end

--
-- COMMON RULESET SPECIFIC FUNCTIONS
--

function rollTypeInit(sType, fRollCombatantEntryInit, ...)
	for _,v in pairs(CombatManager.getCombatantNodes()) do
		local bRoll = true;
		if sType then
			local sClass,_ = DB.getValue(v, "link", "", "");
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false;
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false;
			end
		end
		
		if bRoll then
			DB.setValue(v, "initresult", "number", -10000);
		end
	end

	for _,v in pairs(CombatManager.getCombatantNodes()) do
		local bRoll = true;
		if sType then
			local sClass,_ = DB.getValue(v, "link", "", "");
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false;
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false;
			end
		end
		
		if bRoll then
			fRollCombatantEntryInit(v, ...);
		end
	end
end

--
-- COMBAT TRACKER SUPPORT
--

function handleFactionDropOnImage(draginfo, imagecontrol, x, y)
	if not User.isHost() then return; end
	
	if not UtilityManager.isClientFGU() then
		-- Determine image viewpoint
		-- Handle zoom factor (>100% or <100%) and offset drop coordinates
		local vpx, vpy, vpz = imagecontrol.getViewpoint();
		x = x / vpz;
		y = y / vpz;
	end
	
	-- If grid, then snap drop point and adjust drop spread
	local nDropSpread = 15;
	if imagecontrol.hasGrid() then
		x, y = imagecontrol.snapToGrid(x, y);
		nDropSpread = imagecontrol.getGridSize();
	end

	-- Grab faction data from drag object, and apply to each combatant node
	local sFaction = draginfo.getStringData();
	for _,v in pairs(getCombatantNodes()) do
		if DB.getValue(v, "friendfoe", "") == sFaction then
			local sToken = DB.getValue(v, "token", "");
			if sToken ~= "" then
				-- Add it to the image at the drop coordinates
				TokenManager.setDragTokenUnits(DB.getValue(v, "space"));
				local tokenMap = imagecontrol.addToken(sToken, x, y);
				TokenManager.endDragTokenWithUnits();

				-- Update token references
				replaceCombatantToken(v, tokenMap);
				
				-- Offset drop coordinates for next token
				if UtilityManager.isClientFGU() then
					x = x - nDropSpread;
					y = y - nDropSpread;
				else
					if x >= (nDropSpread * 1.5) then
						x = x - nDropSpread;
					end
					if y >= (nDropSpread * 1.5) then
						y = y - nDropSpread;
					end
				end
			end
		end
	end
	
	return true;
end

function replaceCombatantToken(nodeCT, newTokenInstance)
	local oldTokenInstance = CombatManager.getTokenFromCT(nodeCT);
	if oldTokenInstance and oldTokenInstance ~= newTokenInstance then
		if not newTokenInstance then
			local nodeContainerOld = oldTokenInstance.getContainerNode();
			if nodeContainerOld then
				local x,y = oldTokenInstance.getPosition();
				TokenManager.setDragTokenUnits(DB.getValue(nodeCT, "space"));
				newTokenInstance = Token.addToken(nodeContainerOld.getNodeName(), DB.getValue(nodeCT, "token", ""), x, y);
				TokenManager.endDragTokenWithUnits();
			end
		end
		oldTokenInstance.delete();
	end

	TokenManager.linkToken(nodeCT, newTokenInstance);
	TokenManager.updateVisibility(nodeCT);
	TargetingManager.updateTargetsFromCT(nodeCT, newTokenInstance);
end
