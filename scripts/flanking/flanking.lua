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
	local sDirection = '';
	if  aTokenMap[sActorPath].size == 'Medium' or aTokenMap[sActorPath].size == 'Small' or aTokenMap[sActorPath].size == 'Tiny' then
		if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then
			if (actorX == targetX) and (actorY == targetY + 1) then sDirection = 'N1'; end
			if (actorX == targetX - 1) and (actorY == targetY + 1) then sDirection = 'NE'; end	
			if (actorX == targetX - 1) and (actorY == targetY) then sDirection = 'E1'; end
			if (actorX == targetX - 1) and (actorY == targetY - 1) then sDirection = 'SE'; end
			if (actorX == targetX) and (actorY == targetY - 1) then sDirection = 'S1'; end
			if (actorX == targetX + 1) and (actorY == targetY - 1) then sDirection = 'SW'; end
			if (actorX == targetX + 1) and (actorY == targetY) then sDirection = 'W1'; end					
			if (actorX == targetX + 1) and (actorY == targetY + 1) then sDirection = 'NW'; end									 
		end	
	
		-- if target is large look for top left corner of target token.
		if aTokenMap[sTargetPath].size == 'Large' then
			if (actorX == targetX) and (actorY == targetY + 2) then sDirection = 'N1'; end
			if (actorX == targetX + 1) and (actorY == targetY + 2) then sDirection = 'N2'; end
			if (actorX == targetX - 1) and (actorY == targetY + 2) then sDirection = 'NE'; end	
			if (actorX == targetX - 1) and (actorY == targetY) then sDirection = 'E1';end
			if (actorX == targetX - 1) and (actorY == targetY + 1) then sDirection = 'E2'; end
			if (actorX == targetX - 1) and (actorY == targetY - 1) then sDirection = 'SE'; end
			if (actorX == targetX) and (actorY == targetY - 1) then sDirection = 'S1'; end
			if (actorX == targetX + 1) and (actorY == targetY - 1) then sDirection = 'S2'; end
			if (actorX == targetX + 2) and (actorY == targetY - 1) then sDirection = 'SW'; end
			if (actorX == targetX + 2) and (actorY == targetY) then sDirection = 'W1'; end
			if (actorX == targetX + 2) and (actorY == targetY + 1) then sDirection = 'W2'; end
			if (actorX == targetX + 2) and (actorY == targetY + 2) then sDirection = 'NW'; end
		end
	end

	--large actor medium or smaller target; searches from top left corner of actor
	if  aTokenMap[sActorPath].size == 'Large' then
		if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then
			if (actorX == targetX) and (actorY == targetY + 1) then sDirection = 'N2'; end
			if (actorX == targetX - 1) and (actorY == targetY + 1) then sDirection = 'N1'; end
			if (actorX == targetX - 2) and (actorY == targetY + 1) then sDirection = 'NE'; end	
			if (actorX == targetX - 2) and (actorY == targetY) then sDirection = 'E2'; end
			if (actorX == targetX - 2) and (actorY == targetY - 1) then sDirection = 'E1'; end
			if (actorX == targetX - 2) and (actorY == targetY - 2) then sDirection = 'SE'; end
			if (actorX == targetX) and (actorY == targetY - 2) then sDirection = 'S2'; end
			if (actorX == targetX - 1) and (actorY == targetY - 2) then sDirection = 'S1'; end
			if (actorX == targetX + 1) and (actorY == targetY - 2) then sDirection = 'SW'; end
			if (actorX == targetX + 1) and (actorY == targetY) then sDirection = 'W2'; end	
			if (actorX == targetX + 1) and (actorY == targetY - 1) then sDirection= 'W1'; end		
			if (actorX == targetX + 1) and (actorY == targetY + 1) then sDirection = 'NW'; end									 
		end	
	
		--Large actor large target; searches from top left of actor to top left of target
		if aTokenMap[sTargetPath].size == 'Large' then
			if (actorX == targetX - 1) and (actorY == targetY + 2) then sDirection = 'N1'; end
			if (actorX == targetX) and (actorY == targetY + 2) then sDirection = 'N2'; end
			if (actorX == targetX + 1) and (actorY == targetY + 2) then sDirection = 'N3'; end
			if (actorX == targetX - 2) and (actorY == targetY + 2) then sDirection = 'NE'; end	
			if (actorX == targetX - 2) and (actorY == targetY - 1) then sDirection = 'E1'; end
			if (actorX == targetX - 2) and (actorY == targetY) then sDirection = 'E2'; end
			if (actorX == targetX - 2) and (actorY == targetY + 1) then sDirection = 'E3'; end
			if (actorX == targetX - 2) and (actorY == targetY - 2) then sDirection = 'SE'; end
			if (actorX == targetX - 1) and (actorY == targetY - 2) then sDirection = 'S1'; end
			if (actorX == targetX) and (actorY == targetY - 2) then sDirection = 'S2'; end
			if (actorX == targetX + 1) and (actorY == targetY - 2) then sDirection = 'S3'; end
			if (actorX == targetX + 2) and (actorY == targetY - 2) then sDirection = 'SW'; end
			if (actorX == targetX + 2) and (actorY == targetY -1) then sDirection = 'W1'; end
			if (actorX == targetX + 2) and (actorY == targetY) then sDirection = 'W2'; end	
			if (actorX == targetX + 2) and (actorY == targetY + 1) then sDirection = 'W3'; end	
			if (actorX == targetX + 2) and (actorY == targetY + 2) then sDirection = 'NW'; end
		end
	end

	-- search for medium ally
	local sAllyPath = '';
	local sAllyPathB = '';
	local sAllyPathC = '';
	local sAllyPathD = '';
	local sAllyPathE = '';
	if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then	
		if sDirection == 'N1' or sDirection == 'N2'  then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 1); end
		if sDirection == 'NE' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1); end
		if sDirection == 'E1' or sDirection == 'E2' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY); end
		if sDirection == 'SE' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 1); end
		if sDirection == 'S1' or sDirection == 'S2' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1); end
		if sDirection == 'SW' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1); end
		if sDirection == 'W1' or sDirection == 'W2' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY); end
		if sDirection == 'NW' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 1); end
	end

	-- large target token begins search from top left corner.
	if aTokenMap[sTargetPath].size == 'Large' then
		if sDirection == 'N1' or sDirection == 'N2' or sDirection == 'N3' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 1);
			sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1); end
		if sDirection == 'NE' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1); end
		if sDirection == 'E1' or sDirection == 'E2' or sDirection == 'E3' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY);
			sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1); end
		if sDirection == 'SE' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 2); end
		if sDirection == 'S1' or sDirection == 'S2' or sDirection == 'S3'	then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 2);
			sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2); end
		if sDirection == 'SW' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2); end
		if sDirection == 'W1' or sDirection == 'W2' or sDirection == 'W3' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY);
			sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1); end
		if sDirection == 'NW' then
			sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 1); end
	end

	--if large token found when looking for medium ally, then remove them
	if sAllyPath ~= '' then
		if (aTokenMap[sAllyPath].size ~= 'Medium') and (aTokenMap[sAllyPath].size ~= 'Small') and (aTokenMap[sAllyPath].size ~= 'Tiny') then sAllyPath = ''; end
	end
	if sAllyPathB ~= '' then
		if (aTokenMap[sAllyPathB].size ~= 'Medium') and (aTokenMap[sAllyPathB].size ~= 'Small') and (aTokenMap[sAllyPathB].size ~= 'Tiny')
		then sAllyPath = ''; end
	end
	-- Search for large ally
	-- Only check if sAllyPath and sAllyPathB ~= '': so no tokens already found as an ally
	if (sAllyPath == '') and (sAllyPathB == '') then
			--medium target;large ally
		if aTokenMap[sTargetPath].size == 'Medium' or aTokenMap[sTargetPath].size == 'Small' or aTokenMap[sTargetPath].size == 'Tiny' then
			if sDirection == 'N1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2); 
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1); end
			end
			if sDirection == 'N2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2); 
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1); end
			end
			if sDirection == 'NE' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1); end
			if sDirection == 'E1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 1);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1); end
			end
			if sDirection == 'E2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2); end
			end
			if sDirection == 'SE' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1); end
			if sDirection == 'S1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 1);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY); end
			end
			if sDirection == 'S2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY); end
			end
			if sDirection == 'SW' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY); end
			if sDirection == 'W1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 1); end
			end
			if sDirection == 'W2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2); end
			end
			if sDirection == 'NW' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2); end
		end
		
		--large target; large ally
		if aTokenMap[sTargetPath].size == 'Large' then
			if sDirection == 'N1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1); end
			end
			if sDirection == 'N2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2); end
			if sDirection == 'N3' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY - 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1); end
			end
			if sDirection == 'NE' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY - 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1);
			end
			if sDirection == 'E1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2); end
			end
			if sDirection == 'E2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1); end
			if sDirection == 'E3' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY - 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1); end
			end
			if sDirection == 'SE' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2);
			end
			if sDirection == 'S1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX + 2, targetY + 1); end
			end
			if sDirection == 'S2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2); end
			if sDirection == 'S3' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX, targetY + 2);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX + 1, targetY + 2);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1); end
			end
			if sDirection == 'SW' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2);
			end
			if sDirection == 'W1' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY + 2); end
			end
			if sDirection == 'W2' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1); 
			end
			if sDirection == 'W3' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY + 1);
				if  aTokenMap[sActorPath].size == 'Large' then
					sAllyPathD = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
					sAllyPathE = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2); end
			end
			if sDirection == 'NW' then
				sAllyPath = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 2);
				sAllyPathB = TokenHelper.getActorByGrid(aTokenMap, targetX - 2, targetY - 1);
				sAllyPathC = TokenHelper.getActorByGrid(aTokenMap, targetX - 1, targetY - 2);
			end
		end

		--if medium ally found while looking for large ally, remove medium
		if (sAllyPath ~= '') then
			if aTokenMap[sAllyPath].size ~= 'Large' then
				sAllyPath = ''; end
			end
		if (sAllyPathB ~= '') then
			if aTokenMap[sAllyPathB].size ~= 'Large' then
			 sAllyPathB = ''; end
		end
		if (sAllyPathC ~= '') then
			if aTokenMap[sAllyPathC].size ~= 'Large' then
				sAllyPathC = ''; end
		end
		if (sAllyPathD ~= '') then
			if aTokenMap[sAllyPathD].size ~= 'Large' then
				sAllyPathD = ''; end
		end
		if (sAllyPathE ~= '') then
			if aTokenMap[sAllyPathE].size ~= 'Large' then
				sAllyPathE = ''; end
		end
	end
	
	-- get ally CT entry
	local allyNodePath = '';
	local allyNodePathB = '';
	local allyNodePathC = '';
	local allyNodePathD = '';
	local allyNodePathE = '';
	local aEntries = CombatManager.getSortedCombatantList();	    	
	local nIndexActive = 0;
	if sAllyPath ~= '' then 
		for i = nIndexActive + 1, #aEntries do     
			local entryNodePath = DB.getPath(aEntries[i]);
			if entryNodePath == sAllyPath then allyNodePath = entryNodePath; end
				
			nIndexActive = nIndexActive + 1;     
		end
	end
	if sAllyPathB ~= '' then 
		for i = nIndexActive + 1, #aEntries do     
			local entryNodePath = DB.getPath(aEntries[i]);
			if entryNodePath == sAllyPathB then allyNodePathB = entryNodePath; end
				
			nIndexActive = nIndexActive + 1;     
		end
	end
	if sAllyPathC ~= '' then
		for i = nIndexActive + 1, #aEntries do     
			local entryNodePath = DB.getPath(aEntries[i]);
			if entryNodePath == sAllyPathC then allyNodePathC = entryNodePath; end
				
			nIndexActive = nIndexActive + 1;     
		end
	end
	if sAllyPathD ~= '' then
		for i = nIndexActive + 1, #aEntries do     
			local entryNodePath = DB.getPath(aEntries[i]);
			if entryNodePath == sAllyPathD then allyNodePathD = entryNodePath; end
				
			nIndexActive = nIndexActive + 1;     
		end
	end
	if sAllyPathE ~= '' then
		for i = nIndexActive + 1, #aEntries do     
			local entryNodePath = DB.getPath(aEntries[i]);
			if entryNodePath == sAllyPathE then allyNodePathE = entryNodePath; end
				
			nIndexActive = nIndexActive + 1;     
		end
	end

	-- consider altitude
	-- get nodes -> tokens -> token height
	local actorNode = rActor.sCTNode;
    local targetNode = rTarget.sCTNode;		        
		local allyNode = CombatManager.getCTFromNode(allyNodePath);
		local allyNodeB = CombatManager.getCTFromNode(allyNodePathB);
		local allyNodeC = CombatManager.getCTFromNode(allyNodePathC);
		local allyNodeD = CombatManager.getCTFromNode(allyNodePathD);
		local allyNodeE = CombatManager.getCTFromNode(allyNodePathE);

	local actorToken = CombatManager.getTokenFromCT(actorNode);
	local targetToken = CombatManager.getTokenFromCT(targetNode);	
		local allyToken = CombatManager.getTokenFromCT(allyNode);
		local allyTokenB = CombatManager.getTokenFromCT(allyNodeB);
		local allyTokenC = CombatManager.getTokenFromCT(allyNodeC);
		local allyTokenD = CombatManager.getTokenFromCT(allyNodeD);
		local allyTokenE = CombatManager.getTokenFromCT(allyNodeE);

	-- get height
	local actorHeight = TokenHeight.getTokenHeight(actorToken);
	local targetHeight = TokenHeight.getTokenHeight(targetToken);	
	local allyHeight = TokenHeight.getTokenHeight(allyToken);
	local allyHeightB = TokenHeight.getTokenHeight(allyTokenB);
	local allyHeightC = TokenHeight.getTokenHeight(allyTokenC);
	local allyHeightD = TokenHeight.getTokenHeight(allyTokenD);
	local allyHeightE = TokenHeight.getTokenHeight(allyTokenE);
	
	-- if either actor or ally are out of range of melee attack, height wise, then no flanking benefit
	local bOutOfRange = false;
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeight^2 - targetHeight^2) > 5) then bOutOfRange = true end
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeightB^2 - targetHeight^2) > 5) then bOutOfRange = true end
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeightC^2 - targetHeight^2) > 5) then bOutOfRange = true end	
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeightD^2 - targetHeight^2) > 5) then bOutOfRange = true end	
	if (math.sqrt(actorHeight^2 - targetHeight^2) > 5) or (math.sqrt(allyHeightE^2 - targetHeight^2) > 5) then bOutOfRange = true end	

	local actorFriendFoe = aTokenMap[sActorPath].friendfoe;
	local allyFriendFoe = '';

	if sAllyPath ~= '' then
		allyFriendFoe = aTokenMap[sAllyPath].friendfoe;
	end
	if sAllyPathB ~= '' then
		allyFriendFoeB = aTokenMap[sAllyPathB].friendfoe;
	end
	if sAllyPathC ~= '' then
		allyFriendFoeC = aTokenMap[sAllyPathC].friendfoe;
	end
	if sAllyPathD ~= '' then
		allyFriendFoeD = aTokenMap[sAllyPathD].friendfoe;
	end
	if sAllyPathE ~= '' then
		allyFriendFoeE = aTokenMap[sAllyPathE].friendfoe;
	end



	-- set bFlanking=true, if a flanking ally is found that is not unconscious/paralyzed/petrified/prone/stunned/restrained
	if (actorFriendFoe == allyFriendFoe) or (actorFriendFoe == allyFriendFoeB) or (actorFriendFoe == allyFriendFoeC) then
		local bAllyDisabled = TokenHelper.isActorDisabled5e(sAllyPath);
		local bAllyDisabledB = TokenHelper.isActorDisabled5e(sAllyPathB);
		local bAllyDisabledC = TokenHelper.isActorDisabled5e(sAllyPathC);
		local bAllyDisabledD = TokenHelper.isActorDisabled5e(sAllyPathD);
		local bAllyDisabledE = TokenHelper.isActorDisabled5e(sAllyPathE);

		if ((bAllyDisabled == false) and (allyNodePath ~= '')) or ((bAllyDisabledB == false) and (allyNodePathB ~= '')) or ((bAllyDisabledC == false) and (allyNodePathC ~= '')) or ((bAllyDisabledD == false) and (allyNodePathD ~= '')) or ((bAllyDisabledE == false) and (allyNodePathE ~= ''))
		then
			bFlanking = true;
		end	
	end
	if bOutOfRange == true then bFlanking = false; end
		
	return bFlanking;
end
