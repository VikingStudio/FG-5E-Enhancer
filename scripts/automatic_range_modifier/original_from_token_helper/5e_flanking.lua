--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.


-- check for flanking advantage for melee attack
-- use: local bFlanking = isFlanking(rActor, rTarget);
-- pre: bFlanking = false
-- post: returns true if  actor has a flanking attack on target flanking, else false
function isFlanking(rActor, rTarget)
	local bFlanking = false;	
	
	-- make sure there is an actor and target, otherwise return false
	if rActor == nil or rTarget == nil then
		return false;
	end

	-- get token map and actor grid location
	local ctrlImage = TokenHelper.getControlImageByActor(rActor);	
	local aTokenMap;
	-- if actor not on map then don't check for flanking
	if (ctrlImage ~= nil) then
		aTokenMap = TokenHelper.getTokenMap(ctrlImage);		
	else 
		return false;
	end

	
	--[[
		Design doc:
		first get attack direction from attacker to target (N, NE, E, SE, S, SW, W, NW)
		check for target size, as this determines in what squares flanking ally can be
		if attacker from NE, SE, SW, NW corners, then only the very opposite square offer advantage
		if attacker attacking from any side square, then if ally in any opposite square offers advantage
			this translates for sizes:
				Medium or smaller: 1 opposite square
				Large:  2 opposite squares
				Huge:   3 opposite squares
				Gargantuan: 4 opposite squares						
		Search for ally that is not unconscious/paralyzed/petrified/stunned/prone/restrained in those squares.
		Check for altitude differences between actor, target and ally to make sure within range of melee.
		If such an ally is fund, return bFlanking as true (take that result and apply an advantage outside of this function if appropriate)
	]]--

	-- find attack direction	
	local sActorPath = DB.getPath(rActor.sCTNode);
	local sTargetPath = DB.getPath(rTarget.sCTNode);

	local actorX = aTokenMap[sActorPath].gridx;
	local actorY = aTokenMap[sActorPath].gridy;
	local targetX = aTokenMap[sTargetPath].gridx;
	local targetY = aTokenMap[sTargetPath].gridy;
	
	
	-- determine direction of attack and set sDirection to N, NE, E, SE, S, SW, W, NW.
	local sDirection;
	if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then
		if (actorX == targetX) and (actorY == targetY + 1) then sDirection = 'N'; end
		if (actorX == targetX - 1) and (actorY == targetY + 1) then sDirection = 'NE'; end	
		if (actorX == targetX - 1) and (actorY == targetY) then sDirection = 'E'; end
		if (actorX == targetX - 1) and (actorY == targetY - 1) then sDirection = 'SE'; end
		if (actorX == targetX) and (actorY == targetY - 1) then sDirection = 'S'; end
		if (actorX == targetX + 1) and (actorY == targetY - 1) then sDirection = 'SW'; end
		if (actorX == targetX + 1) and (actorY == targetY) then sDirection = 'W'; end					
		if (actorX == targetX + 1) and (actorY == targetY + 1) then sDirection = 'NW'; end												 
	end
	if aTokenMap[sTargetPath].size == 'Large' then
	end	

	-- search for ally
	local sAllyPath = '';
	if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then	
		if sDirection == 'N' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 1);	end
		if sDirection == 'NE' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1); end
		if sDirection == 'E' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY);	end
		if sDirection == 'SE' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 1); end
		if sDirection == 'S' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1);	end
		if sDirection == 'SW' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1); end
		if sDirection == 'W' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY);	end
		if sDirection == 'NW' then sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 1); end
	end
	
	-- get ally CT entry
	local allyNodePath = '';
	local aEntries = CombatManager.getSortedCombatantList();	    	
	local nIndexActive = 0;	
	for i = nIndexActive + 1, #aEntries do     
		local entryNodePath = DB.getPath(aEntries[i]);

        if entryNodePath == sAllyPath then allyNodePath = entryNodePath; end				
		nIndexActive = nIndexActive + 1;     
	end	

	-- consider altitude
	-- get nodes -> tokens -> token height
	local actorNode = rActor.sCTNode;
    local targetNode = rTarget.sCTNode;		        
    local allyNode = CombatManager.getCTFromNode(allyNodePath);  

	local actorToken = CombatManager.getTokenFromCT(actorNode);
	local targetToken = CombatManager.getTokenFromCT(targetNode);	
    local allyToken = CombatManager.getTokenFromCT(allyNode);        

	-- get height
	local actorHeight = HeightManager.getCTHeight(actorToken);
	local targetHeight = HeightManager.getCTHeight(targetToken);	
	local allyHeight = HeightManager.getCTHeight(allyToken);

	-- if either actor or ally are out of range of melee attack, height wise, then no flanking benefit
	local bOutOfRange = false;
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeight^2 - targetHeight^2) > 5) then bOutOfRange = true; end				

	local actorFriendFoe = aTokenMap[sActorPath].friendfoe;
	local allyFriendFoe = '';
	if sAllyPath ~= '' then allyFriendFoe = aTokenMap[sAllyPath].friendfoe; end
	
	-- set bFlanking=true, if a flanking ally is found that is not unconscious/paralyzed/petrified/prone/stunned/restrained
	if actorFriendFoe == allyFriendFoe then 			
		local bAllyDisabled = TokenHelper.isActorDisabled5e(sAllyPath);
		if (bAllyDisabled == false) and (allyNodePath ~= '')
		then
			bFlanking = true;
		end	
	end

	if bOutOfRange == true then bFlanking = false; end
			
	return bFlanking;
end