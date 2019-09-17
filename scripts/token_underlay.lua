--[[
    Script for drawing underlays under tokens on the map for the DM when hovering over entries in the CT.
]]--


function onInit()	
	updateUnderlayOpacity();
	DB.addHandler("options.CE_UOP", "onUpdate", updateUnderlayOpacity);			
end


--[[

CombatManager.getTokenFromCT(vEntry)
tokeninstance.addUnderlay( size, color, [mode] ) 

-- tokeninstance.addUnderlay( size, color, [mode] ) 
-- tokeninstance.removeAllUnderlays( ) 
--]]

-- Global Constants --

-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
-- The opacity is set to 20% by default, but is now modifiable on the fly in the Settings menu.
-- You can change the three colors here by changing the 6 characters after the first 2 (the alpha channel).
TOKENUNDERLAYCOLOR_1 = "3300FF00"; -- Tokens active turn. 
TOKENUNDERLAYCOLOR_3 = "330000FF"; -- Token mouse over hover.
TOKENUNDERLAYCOLOR_2 = "33F9FF44"; -- Token added to battlemap, but not on combat tracker.


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
	TOKENUNDERLAYCOLOR_3 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_3, 3)	
	TOKENUNDERLAYCOLOR_2 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_2, 3)	
end