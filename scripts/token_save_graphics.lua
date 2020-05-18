-- overriding 5E Ruleset manager_action_save.lua: applySave function to draw save result graphics on tokens, after saving throw has been thrown
-- addSaveWidget, deleteSaveWidgets handle functionality to do so

function onInit()
	ActionSave.applySave = applySave;
	Comm.registerSlashHandler("dsave", deleteSaveWidgets, "5E Enhancer: Delete saves")

    -- add watchers for DB entry for save
    --DB.addHandler("combattracker.list.*.savingthrowresult", "onAdd", dbWatcher);
    DB.addHandler("combattracker.list.*.savingthrowresult", "onUpdate", dbWatcher);
    --DB.addHandler("combattracker.list.*.savingthrowresult", "onDelete", deleteSaveWidgets);
end

function dbWatcher(node)
	local sSave = node.getValue();
	local ctNode = DB.getParent(node);	
    addSaveWidget(ctNode, sSave);
end

function applySave(rSource, rOrigin, rAction, sUser)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};
	
	msgShort.text = "Save";
	msgLong.text = "Save [" .. rAction.nTotal ..  "]";
	if rAction.nTarget > 0 then
		msgLong.text = msgLong.text .. "[vs. DC " .. rAction.nTarget .. "]";
	end
	msgShort.text = msgShort.text .. " ->";
	msgLong.text = msgLong.text .. " ->";
	if rSource then
		msgShort.text = msgShort.text .. " [for " .. ActorManager.getDisplayName(rSource) .. "]";
		msgLong.text = msgLong.text .. " [for " .. ActorManager.getDisplayName(rSource) .. "]";
	end
	if rOrigin then
		msgShort.text = msgShort.text .. " [vs " .. ActorManager.getDisplayName(rOrigin) .. "]";
		msgLong.text = msgLong.text .. " [vs " .. ActorManager.getDisplayName(rOrigin) .. "]";
	end
	
	msgShort.icon = "roll_cast";
		
	local sAttack = "";
	local bHalfMatch = false;
	if rAction.sSaveDesc then
		sAttack = rAction.sSaveDesc:match("%[SAVE VS[^]]*%] ([^[]+)") or "";
		bHalfMatch = (rAction.sSaveDesc:match("%[HALF ON SAVE%]") ~= nil);
	end
	rAction.sResult = "";
	
	if rAction.nTarget > 0 then
		if rAction.nTotal >= rAction.nTarget then
			msgLong.text = msgLong.text .. " [SUCCESS]";
			
			if rSource then
				local bHalfDamage = bHalfMatch;
				local bAvoidDamage = false;
				if bHalfDamage then
					if EffectManager5E.hasEffectCondition(rSource, "Avoidance") then
						bAvoidDamage = true;
						msgLong.text = msgLong.text .. " [AVOIDANCE]";
					elseif EffectManager5E.hasEffectCondition(rSource, "Evasion") then
						local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
						if sSave then
							sSave = sSave:lower();
						end
						if sSave == "dexterity" then
							bAvoidDamage = true;
							msgLong.text = msgLong.text .. " [EVASION]";
						end
					end
				end
				
				if bAvoidDamage then
					rAction.sResult = "none";
					rAction.bRemoveOnMiss = false;
				elseif bHalfDamage then
					rAction.sResult = "half_success";
					rAction.bRemoveOnMiss = false;
				end
				
				if rOrigin and rAction.bRemoveOnMiss then
					TargetingManager.removeTarget(ActorManager.getCTNodeName(rOrigin), ActorManager.getCTNodeName(rSource));
				end
			end
		else
			msgLong.text = msgLong.text .. " [FAILURE]";

			if rSource then
				local bHalfDamage = false;
				if bHalfMatch then
					if EffectManager5E.hasEffectCondition(rSource, "Avoidance") then
						bHalfDamage = true;
						msgLong.text = msgLong.text .. " [AVOIDANCE]";
					elseif EffectManager5E.hasEffectCondition(rSource, "Evasion") then
						local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
						if sSave then
							sSave = sSave:lower();
						end
						if sSave == "dexterity" then
							bHalfDamage = true;
							msgLong.text = msgLong.text .. " [EVASION]";
						end
					end
				end
				
				if bHalfDamage then
					rAction.sResult = "half_failure";
				end
			end
		end
	end
	
	ActionsManager.outputResult(rAction.bSecret, rSource, rOrigin, msgLong, msgShort);
	
	if rSource and rOrigin then
		ActionDamage.setDamageState(rOrigin, rSource, StringManager.trim(sAttack), rAction.sResult);
    end
    
	-- Override section: Draw save result bitmap widget on top of token
	if OptionsManager.getOption("CE_STG") == "on" then
		checkSave(rSource, rAction);
	end
end


-- Check save results, call for bitmap widget draw
function checkSave(rSource, rAction)		
		-- Create DB entry for save
		local ctNodePath = rSource.sCTNode;
		local ctNode = DB.findNode(ctNodePath);		
		local dbNode = DB.getChild(ctNode, "savingthrowresult");		

		if (dbNode == nil) then
			dbNode = ctNode.createChild("savingthrowresult", "string");
		end

		if rAction.nTotal >= rAction.nTarget then
			-- success		
			dbNode.setValue('SUCCESS');
		else
			-- failure		
			dbNode.setValue('FAILURE');
		end	
end



-- Draw save result bitmap widget on top of token
function addSaveWidget(ctNode, sSuccess)
	local tokenCT = CombatManager.getTokenFromCT(ctNode);

	local saveIconName = '';
	
	if sSuccess == 'SUCCESS' then
		saveIconName = 'save_success_d20';
	else
		saveIconName = 'save_fail_d20';
	end

	-- start by deleting any other instances of a save bitmap widget on token before adding a new one if any
	local saveWidget = tokenCT.findWidget("save");
								
	if saveWidget then
		saveWidget.destroy();
	end     

    -- add new bitmap save widget
    saveWidget = tokenCT.addBitmapWidget(saveIconName);
    saveWidget.setName("save");	
    saveWidget.setPosition("center");
    saveWidget.bringToFront();
    Helper.resizeForTokenSize(tokenCT, saveWidget, 1);
    saveWidget.setVisible(true);
end


-- capture chat macro command '/dsave'
-- delete all bitmap widgets with 'save' name
function deleteSaveWidgets(sCommand, sParams)
	-- get CT entries for loop
	local aEntries = CombatManager.getSortedCombatantList();

	-- iterate through whole CT
    if #aEntries > 0 then                      
        local nIndexActive = 0;
        for i = nIndexActive + 1, #aEntries do                   
			local node = aEntries[i];                  
			
			-- delete if db entry
			local dbSaveEntry = DB.getChild(node, "savingthrowresult");
			if dbSaveEntry then 
				DB.deleteNode(dbSaveEntry);
			end

            local token = CombatManager.getTokenFromCT(node);			
            if token ~= nil then
				-- delete individual save bitmap widget if found for that token
				local aWidgets = TokenManager.getWidgetList(token, "");				
				local widgetSaves = token.findWidget("save");
								
				if widgetSaves then
					widgetSaves.destroy();
				end       
			end
			
            nIndexActive = nIndexActive + 1;
        end
	end

	Helper.postChatMessage('/dsave: Save cleared.');
end