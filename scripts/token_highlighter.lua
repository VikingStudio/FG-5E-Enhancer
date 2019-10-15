--[[
    Script that adds a underlay to token for the active CT actor. Different color depending on faction.
]]--

function updateActiveHelper(tokenCT, nodeCT)
    -- Faction/space underlay
    if OptionsManager.getOption("CE_SAAU") == "on" then
        local nDU = GameSystem.getDistanceUnitsPerGrid()

        local nSpace = math.ceil(DB.getValue(nodeCT, "space", nDU) / nDU)
        local nHalfSpace = nSpace / 2
        
        removeAllTokenUnderlays();

        local sFaction = DB.getValue(nodeCT, "friendfoe", "")
        if sFaction == "friend" then
            tokenCT.addUnderlay(nHalfSpace, "2f00ff00")
        elseif sFaction == "foe" then
            tokenCT.addUnderlay(nHalfSpace, "2fff0000")
        elseif sFaction == "neutral" then
            tokenCT.addUnderlay(nHalfSpace, "2fffff00")
        end
    end
end

-- remove all underlays for all tokens on the map
function removeAllTokenUnderlays()        
    for _,v in pairs(CombatManager.getCombatantNodes()) do        
        local token = CombatManager.getTokenFromCT(v);
        
        if (token ~= nil) then
            token.removeAllUnderlays()
        end
	end    
end