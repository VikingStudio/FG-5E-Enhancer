-- Global Constants --

-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
-- The opacity is set to 20% by default, but is now modifiable on the fly in the Settings menu.
-- You can change the three colors here by changing the 6 characters after the first 2 (the alpha channel).
TOKENUNDERLAYCOLOR_1 = "3300FF00"; -- Tokens active turn. 
TOKENUNDERLAYCOLOR_2 = "33F9FF44"; -- Token added to battlemap, but not on combat tracker.
TOKENUNDERLAYCOLOR_3 = "330000FF"; -- Token mouse over hover.



function onInit()	
	Token.onClickDown = onClickDown;	
	registerMenuItems();
	updateUnderlayOpacity();
	DB.addHandler("options.CE_UOP", "onUpdate", updateUnderlayOpacity);			
end



-- Add menu items to the Settings menu, pertaining to the 5e Combat Enhancer extension.
function registerMenuItems() 	
	OptionsManager.registerOption2("CE_UOP", false, "option_header_5ecombatenhancer", "option_gm_underlay", "option_entry_cycler",
		{ labels = "100%|90%|80%|70%|60%|50%|40%|30%|20% (best)|10%", values = "option_val_100|option_val_90|option_val_80|option_val_70|option_val_60|option_val_50|option_val_40|option_val_30|option_val_20|option_val_10", default = "option_val_20" })		
	OptionsManager.registerOption2("CE_RBS", false, "option_header_5ecombatenhancer", "option_render_blood_splatter_on_death", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
	OptionsManager.registerOption2("CE_DSOD", false, "option_header_5ecombatenhancer", "option_draw_skull_on_death", "option_entry_cycler",
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" })
	OptionsManager.registerOption2("CE_DBOT", false, "option_header_5ecombatenhancer", "option_draw_blood_on_token", "option_entry_cycler",
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" })
	OptionsManager.registerOption2("CE_CTFNPC", false, "option_header_5ecombatenhancer", "option_fade_ct_npc_on_death", "option_entry_cycler",
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" })		
	OptionsManager.registerOption2("CE_CFNPC", false, "option_header_5ecombatenhancer", "option_fade_npc_effect_icons_on_death", "option_entry_cycler",
		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" })					
	OptionsManager.registerOption2("CE_BSS", false, "option_header_5ecombatenhancer", "option_blood_splatter_scaling", "option_entry_cycler",
		{ labels = "default|default x 0.5|default x 0.75|default x 1.25|default x 1.5|default x 1.75|default x 2", values = "default|default_1|default_2|default_3|default_4|default_5|default_6", default = "default" })
	OptionsManager.registerOption2("CE_TES", false, "option_header_5ecombatenhancer", "option_token_effect_size", "option_entry_cycler",
		{ labels = "tiny|small|medium", values = "option_tiny|option_small|option_medium", default = "option_medium" })
		-- { labels = "tiny|small|medium|large|huge|gargantuan", values = "option_tiny|option_small|option_medium|option_large|option_huge|option_gargantuan", default = "option_medium" })
	OptionsManager.registerOption2("CE_TEMN", false, "option_header_5ecombatenhancer", "option_token_effects_max_number", "option_entry_cycler",
		{ labels = "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", values = "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", default = "20" })		
--	OptionsManager.registerOption2("CE_BFSITF", false, "option_header_5ecombatenhancer", "option_bring_full_screen_interface_to_front", "option_entry_cycler",
--		{ labels = "option_val_off", values = "off", baselabel = "option_val_on", baseval = "on", default = "on" })				
	OptionsManager.registerOption2("CE_HFS", false, "option_header_5ecombatenhancer", "option_height_font_size", "option_entry_cycler",
		{ labels = "small|medium|large", values = "option_small|option_medium|option_large", default = "option_medium" })		
	OptionsManager.registerOption2("CE_ARM", false, "option_header_5ecombatenhancer", "option_automatic_ranged_modifiers", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })		
	OptionsManager.registerOption2("CE_SNIA", false, "option_header_5ecombatenhancer", "option_skip_non_initiatived_actor", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })		
	OptionsManager.registerOption2("CE_FR", false, "option_header_5ecombatenhancer", "option_flanking_rules", "option_entry_cycler",
		{ labels = "Advantage|+1|+2|+5", values = "option_val_on|option_val_1|option_val_2|option_val_on_5", baselabel = "option_val_off", baseval = "option_val_off", default = "option_val_off" })	
	OptionsManager.registerOption2("CE_HHB", false, "option_header_5ecombatenhancer", "option_horizontal_health_bars", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })							
	OptionsManager.registerOption2("CE_RMM", false, "option_header_5ecombatenhancer", "option_ranged_melee_modifier", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })											
end


-- changes the FM token underlay opacity to reflect selection in Settings menu
function updateUnderlayOpacity()
	local opacitySetting = OptionsManager.getOption('CE_UOP');	
	
	-- if no setting is found, return the 20% opacity settubg as it's the default
	if (opacitySetting == nil) or (opacitySetting == '') then
		opacitySetting = 'option_val_20'; 
	end

	-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
	-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
	local hexAlphaTable =
	{
		['option_val_100'] = 'FF',
		['option_val_90'] = 'E6',
		['option_val_80'] = 'CC',
		['option_val_70'] = 'B3',
		['option_val_60'] = '99',
		['option_val_50'] = '80',
		['option_val_40'] = '66',
		['option_val_30'] = '4D',
		['option_val_20'] = '33',
		['option_val_10'] = '1A',
	}

	-- replace alpha channel with new setting (first two characters)	
	TOKENUNDERLAYCOLOR_1 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_1, 3)	
	TOKENUNDERLAYCOLOR_2 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_2, 3)
	TOKENUNDERLAYCOLOR_3 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_3, 3)	
end


-- Delete token / and CT entry on mouse click.
-- Use: Mouse Left-click Token on combat map while holding down either 'Alt' or 'Alt+Ctrl'
-- Pre: Token on combat map
-- Post: Token removed from combat map (Alt) or combat map and combat tracker (Atl+Ctrl)
-- NOTE: button (number), Returns a numerical value indicating the button pressed (1 = left, 2 = middle, 4 = button 4, 5 = button 5). Right button is used for radial menus.
function onClickDown( token, button, image ) 
	-- Deletes token from combat map, if Alt held on left mouse click.
	if (Input.isAltPressed() == true) and (User.isHost() == true) and (button==1) then
		local nodeCT = CombatManager.getCTFromToken(token);
		token.delete();		

		-- Deletes token from combat tracker if Ctrl was also held on click.
		if (Input.isControlPressed() == true) then
			if nodeCT then -- only attempt delete if there is a CT entry
				nodeCT.delete();					
			end				
		end
	end	
end




-- Open record when token is shift-left clicked (direct copy from CoreRPG.pak FG v3.3.7, function onDoubleClick(tokenMap, vImage))
function openTokenInformationWindow(tokenMap, vImage)			
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
						local w = Interface.openWindow(sClass, nodeActor);						
						w.bringToFront();
					else
						ChatManager.SystemMessage(Interface.getString("ct_error_openotherlinkedtokenwithoutaccess"));
					end
				end
				vImage.clearSelectedTokens();
			end
		end
	end
end
