--[[
	Script for adding the extensions menu items.
]]--

function onInit()		
	registerMenuItems();		
end

-- Add menu items to the Settings menu, pertaining to the 5e Combat Enhancer extension.
function registerMenuItems() 	
	OptionsManager.registerOption2("CE_ARM", false, "option_header_combatenhancer5e", "option_automatic_ranged_modifiers", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })		
	OptionsManager.registerOption2("CE_HHB", false, "option_header_combatenhancer5e", "option_horizontal_health_bars", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })
	OptionsManager.registerOption2("CE_STR", false, "option_header_combatenhancer5e", "option_stop_token_rotate", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" })										
	OptionsManager.registerOption2("CE_HFS", false, "option_header_combatenhancer5e", "option_height_font_size", "option_entry_cycler",
		{ labels = "small|medium|large", values = "option_small|option_medium|option_large", default = "option_medium" })						
	OptionsManager.registerOption2("CE_UOP", false, "option_header_combatenhancer5e", "option_gm_underlay", "option_entry_cycler",
		{ labels = "100%|90%|80%|70%|60%|50%|40%|30%|20% (best)|10%", values = "option_val_100|option_val_90|option_val_80|option_val_70|option_val_60|option_val_50|option_val_40|option_val_30|option_val_20|option_val_10", default = "option_val_20" })																
end