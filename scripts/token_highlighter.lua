--[[
    Script that adds a underlay to token for the active CT actor. Different color depending on faction.
]]--


function onInit()
    TokenManager.updateActiveHelper = updateActiveHelper;    
end

function updateActiveHelper(tokenCT, nodeCT)    
    
    -- Faction/space underlay
    if OptionsManager.getOption("CE_SAAU") == "on" then
        local nDU = GameSystem.getDistanceUnitsPerGrid();

        local nSpace = math.ceil(DB.getValue(nodeCT, "space", nDU) / nDU);
        if ( OptionsManager.getOption('CE_US') == 'option_half' ) then
            nSpace = nSpace / 2;
        end
        
        removeAllTokenUnderlays();

        local opacityPercentage = OptionsManager.getOption('CE_UOP');	
        
        -- if no setting is found, return the 20% opacity settubg as it is the default
        if (opacityPercentage == nil) or (opacityPercentage == '') then
            opacityPercentage = '20'; 
        end
        
        local sFaction = DB.getValue(nodeCT, "friendfoe", "");
        if sFaction == "friend" then
            tokenCT.addUnderlay(nSpace, changeHexColorOpacity("2f00ff00", opacityPercentage) );
        elseif sFaction == "foe" then
            tokenCT.addUnderlay(nSpace, changeHexColorOpacity("2fff0000", opacityPercentage) );
        elseif sFaction == "neutral" then
            tokenCT.addUnderlay(nSpace, changeHexColorOpacity("2fffff00", opacityPercentage) );
        end    
    end
end

-- remove all underlays for all tokens on the map
function removeAllTokenUnderlays()       
    for _,v in pairs(CombatManager.getCombatantNodes()) do        
        local token = CombatManager.getTokenFromCT(v);
        
        if (token ~= nil) then
            token.removeAllUnderlays();
        end
	end    
end

-- changes the FM token underlay opacity to reflect selection in Settings menu

-- Hexademical colors ex: 3300FF00, 33F9FF44, 330000FF
-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
-- The opacity is set to 20% by default, but is now modifiable on the fly in the Settings menu.
-- You can change the three colors here by changing the 6 characters after the first 2 (the alpha channel).
function changeHexColorOpacity(hexColor, opacityPercentage)

	local hexAlphaTable =
	{
		['100'] = 'FF',
		['90'] = 'E6',
		['80'] = 'CC',
		['70'] = 'B3',
		['60'] = '99',
		['50'] = '80',
		['40'] = '66',
		['30'] = '4D',
		['20'] = '33',
		['10'] = '1A',
	}

    -- replace alpha channel with new setting (first two characters)	
    local newAlphaColor = hexAlphaTable[opacityPercentage] .. string.sub(hexColor, 3);
	return newAlphaColor;
end
