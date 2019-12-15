--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.

--[[
	This lua file handles ranged attack modifiers in D&D 5e.
]]--

function onInit()	
end


-- use: takes an actor and target, finding the ranges between the two, and if rAction is ranged weapon 
-- then returns disadvantage if between medium and max range or within meele range of conscious opponent, considers feats. Also return descriptive string.
-- use local bRanged, bInRange, bDis, sMessage = getRangeModifier5e(rActor, rTarget, sAttackType, sWeaponName); where sAttackType = 'R' for ranged weapon, 'M' for melee weapon
-- pre: rActor: FG generated object, rTarget: target FG generated object, rAction: FG generated object
-- post: returns (bRanged, bInRange, bDis, sMessage); bRanged = true if ranged weapon, bInRange = true if ranged weapon in range, bDis = true if disadvantage to attack (between medium and max range of weapon), sMessage = a message to output to chat if any 	
function getRangeModifier5e(rActor, rTarget, sAttackType, sWeaponName)
	local bRanged = false;
	local bInRange = true;
	local bDis = false;
	local sMessage = '';

	local medRange = 0;
	local maxRange = 0;


	-- main logic for finding modifiers for range attacks
	if (sAttackType == 'R') then
		bRanged = true;
		bRanged, medRange, maxRange = getWeaponRanges5e(rActor, sAttackType, sWeaponName);	

		local attackRange = getRangeBetweenTokens5e(rActor, rTarget, 5, 0);		

		-- check ranges and set return modifiers and variables accordingly
		-- compare ranges to global attackRange value	
		attackRange = tonumber(attackRange);
		medRange = tonumber(medRange);
		maxRange = tonumber(maxRange);			
		local sRangeString = '';
		if medRange == maxRange then
			sRangeString = '(' .. maxRange .. ')';
		else
			sRangeString = '(' .. medRange .. '/' .. maxRange .. ')';		
		end					

		-- Feats 
		-- Feat: Crossbow Expert (for PC): Being within 5 feet of a hostile creature doesn't impose disadvantage on your ranged attack rolls (while using crossbow).
		-- Feat: Sharpshooter (for PC): Attacking at long range doesn't impose disadvantage on your ranged weapon attack rolls.		

		-- check for feats that influence ranged attacks
		local bCrossbowExpert = false;
		local bCrossbowAttack = false;
		local bSharpShooter = false;		
		local bEnemyInMeleeRange = false;

		-- go through listed feats to see if the actor has the 'Crossbow Expert' or 'Sharpshooter' feat
		for i = 1, 9, 1
		do											
			local featName = DB.getText(DB.findNode(rActor.sCreatureNode),  'featlist.id-0000' .. i .. '.name', '');		
			--Debug.console('featName', featName);

			if featName == 'Crossbow Expert' then bCrossbowExpert = true; end
			if featName == 'Sharpshooter' then bSharpShooter = true; end
			if featName == '' then i=9; end
		end		
				

		-- Check if within melee range while Ranged Melee Modifier Setting in FG menu is on, if so apply
		local bRangedMeeleModifier = OptionsManager.getOption("CE_RMM"); 

		if bRangedMeeleModifier == 'on' then
			local ctrlImage = TokenHelper.getControlImageByActor(rActor);
			local aTokenMap = TokenHelper.getTokenMap(ctrlImage);	
			bEnemyInMeleeRange = TokenHelper.isEnemyInMeleeRange5e(aTokenMap, rActor);
			if bEnemyInMeleeRange == true then
				-- Feat: Crossbow Expert exception
				if bCrossbowExpert then							
					TokenHelper.postChatMessage('Ranged attack with active enemy in melee range, by Crossbow Expert.');		
				else
					bDis = true;
					TokenHelper.postChatMessage('Ranged attack with active enemy in melee range.');
				end
			end
		end
				

		-- Compare attack range to weapon ranges and apply modifiers as applicable. 
		-- ranged attack within melee range, disadvantage is handled above with bEnemyInMeleeRange
		if (attackRange < medRange) and (attackRange <= 5) then	
			bInRange = true;	
			if bRangedMeeleModifier == 'on' then
				if bCrossbowExpert then							
					sMessage = 'Ranged attack in melee range, by Crossbow Expert.';		
				else
					bDis = true;
					sMessage = 'Ranged attack in melee range.';
				end				
			else
				sMessage = 'Ranged attack at in melee range.';
			end
			
			Debug.console('ranged attack in melee range');	
		end	

		-- within medium range
		if (attackRange <= medRange) and (attackRange > 5) then
			sMessage = 'Ranged attack below medium range. ' .. sWeaponName .. ' ' .. sRangeString .. ' from ' .. attackRange .. ' feet.';			
		end

		--	outside melee range with ranged weapon, below medium range	
		if (attackRange < medRange) and (attackRange > 5) then
			bInRange = true;			
			Debug.console('ranged within medium range, no modifier given');			
		end		

		-- attack with ranged weapon, between medium and max range	
		if (attackRange > medRange) and (attackRange <= maxRange) then
			bInRange = true;						
		
			-- Feat: Sharpshooter exception
			if bSharpShooter then				
				sMessage = 'Ranged attack between medium and maximum range by Sharpshooter. ' .. sWeaponName .. ' ' .. sRangeString .. ', from ' .. attackRange .. ' feet.';
				
				Debug.console('Ranged attack, by Sharpshooter (feat).')
			else
				bDis = true;
				sMessage = 'Ranged attack between medium and maximum range. ' .. sWeaponName .. ' ' .. sRangeString .. ' from ' .. attackRange .. ' feet.';			
			end					
			
			Debug.console('ranged between medium and max range');			
		end

		-- attack with ranged weapon, beyond max range
		if (attackRange > maxRange) then
			bInRange = false;
			sMessage = 'The ranged attack is OUT OF RANGE and misses. ' .. sWeaponName .. ' ' .. sRangeString .. ' from ' .. attackRange .. ' feet.';

			Debug.console('ranged outside max range');				
		end			
	end	

	return bRanged, bInRange, bDis, sMessage;
end


-- function return the range between two coordinates on map in units of measurements
-- use: local nDistance = getRangeBetweenCoordinates(x1, y1, x2, y2)
-- pre: return 0;
-- post: return hypotenuse in the form of a number
function getRangeBetweenCoordinates(x1, y1, x2, y2)
	--[[
		Line math for finding distance between the center points of the actor and target tokens on the map:	
	
		Use Pythagoras trigonometry theory to find line (hypotenuse) on a flat plane:
		a^2 + b^2 = c^2

		thus on a flat plane: 						
			height = opposite (a); width = adjacent (b); hypontenuse = line length in pixels (c)						
	--]]			

	local c = 0;
	local a = y1 - y2;
	local b = x1 - x2;

	-- get hypotenuse line in pixels (c)
	c = math.sqrt((a^2)+(b^2)); 	
	
	return c;
end


-- returns range between actor and target in units of measurements of length for that map
-- use: local range = getRangeBetweenTokens(rActor, rTarget, hexWidth, heightDifference); where hexLenght is the in-game length for each hex on the map, heightDifference is height difference in units of measurements x grid width
-- pre: range = 0;
-- post: return range between rActor and rTarget tokens on battlemap in in-game feet 
function getRangeBetweenTokens5e(rActor, rTarget, hexWidth, heightDifference)
	--[[ 
		-- summary of approach
		1) Find center of actor token in cartesian space (x,y), on the map.
		2) Find center of target token in cartesian space (x,y), on the map.
		3) Find distance between actor and target in pixels (Line AB), by using pythagoras theorem, the hyptoneuse of the tringle created between actor and target.
		4) Find distance from center of token actor and target tokens, to the edge of the last square they occupy, in the direction of the the line between actor and target.
			This has to be done as the distance to the horizontal and vertical edges are not the same in radius, as those to other areas of the square. 
			A radius creating a circular shape from the center, touching the outside of the box at the horizontal and vertical edges of the square the token only it occupies.
		5) Subtract these pixels from line AB.
		6) Convert to in-game distance, using hexWidth paramater.
		7) Recalculate with heightDifference (passed as ingame units of distacne)
		8) For D&D add 5'.
		9) Return distance in in-game x units of distance.


		See included 'Range calculation math.jpg' and 'Range trigonometry math.jpg' images for demonstration of concept.
		
		Range trigonometry math image graph explained:
			A and C are the x,y coordinated center pixels of tokens on the map, each is inside the center of a perfect square of those who form the game map grid.
			If A is the attacker and C is the target.
			We find the total distance in pixels from A to B by finding the hypotenuse of the triangle ABC.
			We then need to find the distance between the tokens edges in pixels, that is the line EF.
			To do so we need to subtract the lines AE and CF from AC. That is EF = AC - AE - CF.
				In D&D 5e we then add 5' to that distance as we count the first grid target token touches. That is EF = AC - AE - CF + 5'.
			To find line AE we have the the angel φa of line AC and where that line intersects the first grid y line at the end of the token size. 
				We can use this to create triangle ADE, the length of AE will then be the hypotenuse of that new triangle.
			To find line CF, we have φb = 90-φa, after that we use the same math as for triangle ADE to find the hypotenuse of triangle CFG, which will give us the length of line CF. 						
	]]--
	
	
	-- get actor nodes from CT
	local actorNode = rActor.sCTNode;
	local targetNode = rTarget.sCTNode;					

	-- get tokens for actors from CT
	local actorToken = CombatManager.getTokenFromCT(actorNode);
	local targetToken = CombatManager.getTokenFromCT(targetNode);
	
	-- get token positions
	local actorX, actorY = actorToken.getPosition();
	local targetX, targetY = targetToken.getPosition();
	
	-- get map and grid size
	local ctrlImage = TokenHelper.getControlImageByToken(actorToken);

	local gridSize = ctrlImage.getGridSize();	
		

	-- tokens are measured at the center of their image, so for larger and above sized creatures, the tokens can span more than one hex
	-- so we have to consider this in our calculations to get correct results for range
	-- range is determined as such: actor | empty square | empty square | target = 5' (empty square) + 5' (empty square) + 5' (first square the enemy body occupies, no matter target size)
	local sActorSize = TokenHelper.getActorSize(rActor);
	local sTargetSize = TokenHelper.getActorSize(rTarget);
	
	-- find actor and target token width in pixles from center to the outer edge of the last grid they occupy for the absolute horizontal and vertical
	local nSizeModifierActor = getTokenRadius5e(sActorSize, gridSize);
	local nSizeModifierTarget = getTokenRadius5e(sTargetSize, gridSize);

	-- get distance from token centers to edge of the last square they occupy
	local actorDistanceToTokenEdge = getDistanceToTokenEdge5e(actorX, actorY, targetX, targetY, nSizeModifierActor);
	local targetDistanceToTokenEdge = getDistanceToTokenEdge5e(targetX, targetY, actorX, actorY, nSizeModifierTarget);					

	-- calculate in-game length
	local nDistance = getRangeBetweenCoordinates(actorX, actorY, targetX, targetY);	
	nDistance = nDistance - actorDistanceToTokenEdge - targetDistanceToTokenEdge + gridSize; -- + gridSize for those extra 5' feet in D&D 5e
	local rangeFlatPlane = (nDistance / gridSize) * hexWidth;	

	-- get height from tokens
	local actorHeight = HeightManager.getCTHeight(actorToken);
	local targetHeight = HeightManager.getCTHeight(targetToken);	

	-- calculate range with height included
	heightDifference = actorHeight - targetHeight;
	local rangeWithHeight = math.sqrt((heightDifference^2)+(rangeFlatPlane^2)); 			

	-- find final range to return
	local range = 0;	
	range = math.floor(rangeWithHeight);

	return tonumber(range);
end


-- get distance from center of token to the edge of the last square that token occupies, in pixels, given and angle between source and target
-- use: local actorDistanceToTokenEdge = getDistanceToTokenEdge5e(actorX, actorY, targetX, targetY, nActorTokenRadius);
-- pre: return 0
-- post: return distance from center of token, to point where outbound line to target intercepts the outline edge of the last box the token occupies
function getDistanceToTokenEdge5e (sourceX, sourceY, targetX, targetY, sourceTokenRadius)
	-- find the angle of the line between actor and target token centers
	local radians = math.atan2(targetY - sourceY, targetX - sourceX);
	local angle = radians * (180 / math.pi);	-- angle φ in angle in °	
		
	-- find intercept of that line from center of token to edge of grid
	-- angle between -45 and 45 degrees, then edge is y-line from x co-ordinate East, etc.
	-- then find line length from center of token to where the line between actor and target intercepts the out edge of the last grid box the actor occupies
	local nInterceptX = 0;	
	local nInterceptY = 0;
	local nDistanceToEdge = 0;	
	local aInterceptPoint = {};
	local A = {sourceX, sourceY};		
	local B = {targetX, targetY};
	local C = {};
	local D = {};	

	if angle >= -45 and angle <= 45 then 
		Debug.console('source between -45 to 45 degrees'); 
		nInterceptX = sourceX + sourceTokenRadius; 		
		C = {nInterceptX, 1};
		D = {nInterceptX, 100000};
		aInterceptPoint = getLineInterception(A, B, C, D);
		if aInterceptPoint ~= 0 then		
			nDistanceToEdge = getRangeBetweenCoordinates(sourceX, sourceY, aInterceptPoint[1], aInterceptPoint[2]);				
		end
	end
	if angle > 45 and angle <= 135 then 
		Debug.console('source between 45 to 135 degrees'); 
		nInterceptY = sourceY + sourceTokenRadius; 
		C = {1, nInterceptY};
		D = {100000, nInterceptY};
		aInterceptPoint = getLineInterception(A, B, C, D);
		if aInterceptPoint ~= 0 then
			nDistanceToEdge = getRangeBetweenCoordinates(sourceX, sourceY, aInterceptPoint[1], aInterceptPoint[2]);
		end
	end
	if (angle > 135 and angle <= 180) or (angle <= -135 and angle >= -180) then 
		Debug.console('source between 135 to -135 degrees'); 
		nInterceptX = sourceX - sourceTokenRadius; 
		C = {nInterceptX, 1};
		D = {nInterceptX, 100000};
		aInterceptPoint = getLineInterception(A, B, C, D);
		if aInterceptPoint ~= 0 then
			nDistanceToEdge = getRangeBetweenCoordinates(sourceX, sourceY, aInterceptPoint[1], aInterceptPoint[2]);
		end
	end
	if angle > -135 and angle < -45 then 
		Debug.console('source between -45 to -135 degrees'); 
		nInterceptY = sourceY - sourceTokenRadius; 
		C = {1, nInterceptY};
		D = {100000, nInterceptY};
		aInterceptPoint = getLineInterception(A, B, C, D);
		if aInterceptPoint ~= 0 then
			nDistanceToEdge = getRangeBetweenCoordinates(sourceX, sourceY, aInterceptPoint[1], aInterceptPoint[2]);
		end
	end
		
	return nDistanceToEdge;
end


-- return token radius in pixels from center of grid in a circle that touches the vertical/horizontal edges of the perfect square hexes at the 90/-90 and 180/-180 degree angles
-- use: local nSizeModifier = getTokenRadius5e(sSourceSize, nGridSize); sSourceSize = Tiny/Small/Medium/Large/Huge/Gargantuan
-- pre: nTokenRadius = 0
-- post: nTokenRadius = return the radius in pixels
function getTokenRadius5e(sSourceSize, nGridSize)
	local nTokenRadius = 0;

	if sSourceSize == 'Large' then nTokenRadius = nGridSize * 1; 
	elseif sSourceSize == 'Huge' then nTokenRadius = nGridSize * 1.5; 
	elseif sSourceSize == 'Gargantuan' then nTokenRadius = nGridSize * 2; 
	else nTokenRadius = nGridSize * 0.5; end	
	
	return nTokenRadius;
end



-- send in two lines, line 1 from point A to point B, line 2 from point C to point D, each point is an array of two values, point[x,y]
-- use: local interceptPoint = getLineInterception (A, B, C, D); where A = {x,y},.. etc.
-- pre: return 0
-- post: return 0 if prallel lines, return array {x,y} where lines intersect if they do
function getLineInterception (A, B, C, D)	
	--[[
		Pseudocode:			

		determinant = a1 b2 - a2 b1
		if (determinant == 0)
		{
			-- Lines are parallel
		}
		else
		{
			x = (c1b2 - c2b1)/determinant
			y = (a1c2 - a2c1)/determinant
		}
	]]--	

	-- AB line represented as a1x + b1y = c1  
	local a1 = B[2] - A[2]; 
	local b1 = A[1] - B[1]; 
	local c1 = a1 * A[1] + b1 * A[2]; 

	-- CD line represented as a2x + b2y = c2  
	local a2 = D[2] - C[2]; 
	local b2 = C[1] - D[1]; 
	local c2 = a2 * C[1] + b2 * C[2]; 

	local determinant = a1 * b2 - a2 * b1; 

	if determinant == 0 then		
		return 0; 	
	else	
		local x = (b2 * c1 - b1 * c2) / determinant; 
		local y = (a1 * c2 - a2 * c1) / determinant; 
		local interceptPoint = {x,y};	
		
		return interceptPoint;	
	end	
end



-- use: send in rActor and rAction as generated when an attack is performed by an entry in the CT
--		local bRanged, medRange, maxRange = getWeaponRanges5e(rActor, sRanged, sWeaponName); where sRange is either 'M' for melee or 'R' for ranged
-- pre: rActor: FG generated object, rAction: FG generated object
-- post: returns (bRanged, medRange, maxRange); bRanged = true if ranged attack, medRange = integer medium range, maxRange = integer max range
function getWeaponRanges5e(rActor, sRanged, sWeaponName)
	local bRanged = false;
	local medRange = 0; -- medium range
	local maxRange = 0; -- maximum range	


	if sRanged == 'R' then			
		bRanged = true;			

		-- NPC and PC db structures are different so need different handlers for finding ranges between the two		
		-- NPC handling
		if (rActor.sType == 'npc') then			
			-- look through actions for match
			local nodeParent = rActor.sCreatureNode .. '.actions';
			local actionNodes = DB.getChildren(nodeParent);

			for k, v in pairs(actionNodes) do
				local nodeChild = nodeParent .. '.' .. k;				
				local nodeName = DB.getText(nodeChild .. '.name');
			
				if ( nodeName:lower() == sWeaponName:lower() ) then					
					local description = DB.getText(nodeChild .. '.desc');
										
					-- search for 'range * ft', return range as substring, split substring in two (medium/max range)					
					-- string input ex. 'Thrown (range 30/120)''  and 'range 30/120 ft.''	
					local rangeText = '';
					rangeText = string.match(description, "range%s%d*/%d*");
					
					if rangeText ~= nil then						
						-- find '/' index
						-- medRange = start of numbers to before index
						-- maxRange = after index to end
						local index = string.find(rangeText, '/');								
						medRange = string.sub(rangeText, 7, index - 1);
						maxRange = string.sub(rangeText, index + 1, string.len(rangeText));								
					else
						-- this exception is needed as some modules have a slightly different range entries
						-- string input ex. 'Thrown (range 30 ft./120)''  and 'range 30 ft./120 ft.''	
						rangeText = string.match(description, "range%s%d*%sft./%d*");
						local index = string.find(rangeText, '/');								
						medRange = string.sub(rangeText, 7, index - 4);
						maxRange = string.sub(rangeText, index + 1, string.len(rangeText));		
					end	
				end								
			end			

			-- look through spells for match
			nodeParent = rActor.sCreatureNode .. '.spells';
			local spellNodes = DB.getChildren(nodeParent);
			
			for k, v in pairs(spellNodes) do
				local nodeChild = nodeParent .. '.' .. k;				
				local nodeName = DB.getText(nodeChild .. '.name');
							
				if ( nodeName:lower() == sWeaponName:lower() ) then					
					local description = DB.getText(nodeChild .. '.desc');					
					-- search for 'range * ft', return range as substring, split substring in two (medium/max range)
					-- string input ex. 'Range: 120'					
					local rangeText = string.match(description, "Range:%s%d*");																					
					medRange = string.sub(rangeText, 8, string.len(rangeText));
					maxRange = medRange;									
				end
			end				


		-- PC handling
		elseif (rActor.sType == 'pc') then			
			-- db weapon entry on character sheet character example: charactersheet.id-00001.weaponlist.id-00001
			-- name: .name
			-- properties: .properties
			-- full example: charactersheet.id-00001.weaponlist.id-00001.name.properties			

			-- look through actions for match
			local nodeParent = rActor.sCreatureNode .. '.weaponlist';
			local actionNodes = DB.getChildren(nodeParent);

			-- iterate through PC weapon entries and find the one that corresponds to the rAction.label one
			-- finding range values if applicable
			for k, v in pairs(actionNodes) do
				local nodeChild = nodeParent .. '.' .. k;				
				local nodeName = DB.getText(nodeChild .. '.name');
	
				if ( nodeName:lower() == sWeaponName:lower() ) then					
					local description = DB.getText(nodeChild .. '.properties');
					
					-- search for 'range * ft', return range as substring, split substring in two (medium/max range)
					-- string input ex. 'Thrown (range 30/120)''  and 'range 30/120 ft.''				
					local rangeText = string.match(description, "range%s%d*/%d*");				
					-- find '/' index
					-- medRange = start of numbers to before index
					-- maxRange = after index to end
					local index = string.find(rangeText, '/');								
					medRange = string.sub( rangeText, 7, index - 1);
					maxRange = string.sub(rangeText, index + 1, string.len(rangeText));					
				end
			end	
			
			-- look through spells for match
			nodeParent = rActor.sCreatureNode .. '.powers';
			local spellNodes = DB.getChildren(nodeParent);
			
			for k, v in pairs(spellNodes) do
				local nodeChild = nodeParent .. '.' .. k;				
				local nodeName = DB.getText(nodeChild .. '.name');
														
				if ( nodeName:lower() == sWeaponName:lower() ) then					
					local description = DB.getText(nodeChild .. '.range');										
					local rangeText = string.match(description, "%d*");																					
					medRange = rangeText;
					maxRange = medRange;									
				end
			end				
		end

	end	

	return bRanged, medRange, maxRange;
end


-- RETIRED IN PREFERENCE TO: DB.getChildren(), deleting items from the db iterated list does not update the index numbers, so iteration that expects a non-broken 
-- continual iteration will break once there is a gap in the count due to a deleted item from said list
-- returns id-00001 formatted string
-- use local idString = getIdDBString(n);
-- pre: sId = 'id-'
-- post: xml database formatted string, ex: id-00001, id-014255
function getIdDBString(nId)
	local sId = 'id-';

	if nId < 10 then sId = sId .. '0000' .. nId; end
	if nId < 100 and nId >= 10 then sId = sId .. '000' .. nId; end
	if nId < 1000 and nId >= 100 then sId = sId .. '00' .. nId; end
	if nId < 10000 and nId >= 1000 then sId = sId .. '0' .. nId; end
	if nId >= 10000 then sId = sId .. nId; end

	return sId;
end


-- only run range function logic if this function returns true, it checks there are entries in the CT, there are tokens on map, the map is open
-- if any of these are missing then errors will be thrown running getRangeModifer5e and the functions it relies on
-- this occurs in various situations, such as theater of the mind, some CT entries in CT and not on map, map not open etc.
-- use: local bConditions = checkConditions(rSourse, rTarget);
-- pre: return true
-- post: return false if any required condition is not met, otherwise return true 
function checkConditions(rSource, rTarget)	
	-- check parameters	
	if rSource == nil or rTarget == nil then return false; end
	
	-- check nodes
	local sourceNode = rSource.sCTNode;
	local targetNode = rTarget.sCTNode;		
	if sourceNode == nil or targetNode == nil then return false; end	

	-- check for tokens on map
	local sourceToken = CombatManager.getTokenFromCT(sourceNode);
	local targetToken = CombatManager.getTokenFromCT(targetNode);		
	if sourceToken == nil or targetToken == nil then return false; end

	-- check for map window open
	local ctrlImage = TokenHelper.getControlImageByToken(sourceToken);		
	if ctrlImage == nil then return false; end

	return true;
end