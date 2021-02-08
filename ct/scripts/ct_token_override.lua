function onHover(state)
	local nodeActiveCT = CombatManager.getActiveCT();
	local nodeCT = window.getDatabaseNode(); 
	local tokenCT = CombatManager.getTokenFromCT(nodeCT);

	if state and tokenCT then
		-- add blue underlay
		tokenCT.removeAllUnderlays(); 
		local space = nodeCT.getChild('space');  
		if space == nil then 
			space = 1;
		else
			space = space.getValue()/5/2+0.5; 
		end
		tokenCT.addUnderlay(space, CombatEnhancer.TOKENUNDERLAYCOLOR_3); 

	elseif tokenCT then
		TokenManager.updateSizeHelper(tokenCT, nodeCT);
	end
end
