-- functions that are overridden in the CoreRPG Ruleset, from manager_token.lua file
-- horizontal health bar calls
-- token faction underlay drawing

local fGetHealthInfo = null;

function onInit()
    TokenManager.updateHealthHelper = updateHealthHelper;
    TokenManager.updateHealthBarScale = updateHealthBarScale;
	TokenManager.updateSizeHelper = updateSizeHelper;
	--TokenManager.addDefaultHealthFeatures(TokenManager2.getHealthInfo, {"hp", "hptemp", "wounds", "deathsavefail"});
	fGetHealthInfo = TokenManager2.getHealthInfo;
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
	local aWidgets = TokenManager.getWidgetList(tokenCT, "health");

	if sOptTH == "off" then
		for _,vWidget in pairs(aWidgets) do
			vWidget.destroy();
		end
	else
		local nPercentWounded,sStatus,sColor = fGetHealthInfo(nodeCT);

		-- START Manage actor token condition widget if enabled
		if OptionsManager.getOption('CE_HCW') ~= "option_off" then
			ActorCondition.updateHealthCondition(tokenCT, nPercentWounded, sStatus);
		end
		-- END Manage actor token condition widget if enabled

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
	
		local opacityPercentage = OptionsManager.getOption('CE_UOP');	
		TokenHighlighter.changeHexColorOpacity("2f00ff00", opacityPercentage) 

		if sFaction == "friend" then
			tokenCT.addUnderlay(nHalfSpace, TokenHighlighter.changeHexColorOpacity("2f00ff00", opacityPercentage));
		elseif sFaction == "foe" then
			tokenCT.addUnderlay(nHalfSpace, TokenHighlighter.changeHexColorOpacity("2fff0000", opacityPercentage));
		elseif sFaction == "neutral" then
			tokenCT.addUnderlay(nHalfSpace, TokenHighlighter.changeHexColorOpacity("2fffff00", opacityPercentage));
		end
	end
	
	-- Set grid spacing
	tokenCT.setGridSize(nSpace);
end
