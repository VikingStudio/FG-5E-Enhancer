--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.


-- creates and returns an array containing token objects for comparing grid position of tokens
-- use: local aTokenMap = getTokenMap(imagecontrol)
-- pre: empty tokenMap
-- post: returns aTokenMap[node]{name, friendfoe, gridx, gridy, reach, size}, that contains positional and disposition (friend/foe/neutral) of all actors in the CT ;
function getTokenMap (imgCtrl)      
    local aTokenMap = {}
        
    -- iterate through CT, get token pixel position and determine x and y grid that token belongs to
    -- creat new token and add to tokenMap

    -- get grid size in pixels
    local gridSize = 0;
    local gridOffsetX = 0;
    local gridOffsetY = 0;

    if imgCtrl.hasGrid() then
        gridSize = imgCtrl.getGridSize();
        gridOffsetX, gridOffsetY = imgCtrl.getGridOffset();
    end

	-- get CT entries for loop
	local aEntries = CombatManager.getSortedCombatantList();

	-- loop through CT entries and perform main function logic
	-- go through the CT and find if there are any other foes, that are within 5' of the attacker, and not unconscious	
    if #aEntries > 0 then  
                      
        -- loop through CT entries, compare reach of foes to active token position and set bEnemy to true if within melee ranged and not unconscious
        local nIndexActive = 0;
        for i = nIndexActive + 1, #aEntries do                   
            local node = aEntries[i];     
            local sName = DB.getValue(node, "name", "");       
            local sFriendfoe = DB.getValue(node, "friendfoe", "");                 
            local token = CombatManager.getTokenFromCT(node);
            -- only add CT entries that have actual tokens on the map
            if token ~= nil then
                local x, y = token.getPosition();            
                local nReach = DB.getValue(node, "reach", "");   
                local sSize = DB.getValue(node, "size", ""); 
                local nHeight = DB.getValue(node, "height", "");
                if nHeight == nil then nHeight = 0; end
                if sSize == '' then sSize = 'Medium'; end -- PC entries don't have a 'size' entry in the <combattracker> DB section, so set them as medium by default
                
                local nGridx = (tonumber(x) + tonumber(gridOffsetX)) / gridSize;
                local nGridy = (tonumber(y) + tonumber(gridOffsetY)) / gridSize;   
                
                local nGridxRound = round(nGridx);
                local nGridyRound = round(nGridy);                                                     

                -- add the map token details to the aTokenMap array                
                aTokenMap[DB.getPath(node)] = { name = sName, friendfoe = sFriendfoe, gridx = tonumber(nGridxRound), gridy = tonumber(nGridyRound), reach = tonumber(nReach), size = sSize, height = tonumber(nHeight)};
            end
                            
            nIndexActive = nIndexActive + 1;            
        end
    end
    
    return aTokenMap;
end


-- DEPRECITATED, USING NAME AS INDEX FOR KEY'D TABLE INSTEAD
-- find index for actor in aTokenMap (as returend by getTokenMap above), searching by name
-- use: local nActorIndex = getActorIndexInTokenMap(aTokenMap, sName);
-- pre: actorIndex = -1
-- post: returns actorIndex = -1 if not found, or index in aTokenMap if found
function getActorIndexInTokenMap(aTokenMap, sName)
    local actorIndex = -1;    

    if #aTokenMap > 0 then 

        local nIndexActive = 0;
        for i = nIndexActive + 1, #aTokenMap do                          
            if                 
                aTokenMap[nIndexActive].name == sName then actorIndex = i;                  
            end
        end

    end

    -- set rActorIndex if found
    if not rActor then rActor = ''; end
    if (rActor.sName == sName) then rActorIndex = i; end    

    return actorIndex;
end


-- search for token on the aTokenMap from getTokenMap() by x and y location on the battlemap
-- use: local sActorName = getActorByGrid(aTokenMap, x, y);
-- pre: sActorName = ''
-- post: returns found sActorName in the token map for that grid if any, otherwise return empty string
function getActorByGrid(aTokenMap, x, y)
    local sActorNode = '';

    for k, v in pairs(aTokenMap) do                
        if v.gridx == x and v.gridy == y then sActorNode = k; end        
    end    
        
    return sActorNode;
end


-- return edge of the hex the token is in, if north or south edge returns the x coordinate, if west or east edge returns y coordinate
-- use: local nWestEdge = getTokenGridEdge(atokenMap, "Orc 1", 'W', imagecontrol.getGridSize); sEdge parameter should be 'N'/'S'/'W'/'E'.
-- pre: return nCoordinate = 0
-- post: return x or y edge pixel coordinate
function getTokenGridEdge(aTokenMap, sTokenName, sEdge, nGridSize)
    local nCoordinate = 0;

    -- find the x or y coordinate for token edge for 1x1 grid size token
    if sEdge == 'N' then
        nCoordinate = aTokenMap[sTokenName].gridy - nGridSize / 2;
    elseif sEdge == 'E' then       
        nCoordinate = aTokenMap[sTokenName].gridx + nGridSize / 2;
    elseif sEdge == 'S' then
        nCoordinate = aTokenMap[sTokenName].gridy + nGridSize / 2;
    elseif sEdge == 'W' then       
        nCoordinate = aTokenMap[sTokenName].gridx - nGridSize / 2;
    end

    return nCoordinate;
end


-- rounds up to next integer for n >=.5 and down at n < .5
-- use: round(number)
-- pre: -
-- post: returns next whole integer rounded to 
function round(n)    
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)        
end


-- post message to chat
-- use: postChatMessage("post this text as a message to chat")
-- pre: no message posted
-- post: if sMessage is not empty, then paste the string to the text chat window with an icon next to it
function postChatMessage(sMessage)    
    if sMessage ~= '' and sMessage ~= nil then
        local chatMessage = {font = "msgfont", icon = "roll_effect", text = sMessage};				
        Comm.deliverChatMessage(chatMessage);		
    end
end


-- get creature size in 5e terms
-- use: local sSize = getActorSize(rActor);
-- pre: sSize = 'Medium';
-- post: returns sSize string containing one of the following: Small/Medium/Large/Huge/Gargantuan
function getActorSize(rActor)
    local sSize = 'Medium';
    
    -- DB npc node entry structure: combattracker.list.id-00005.size or charactersheet.id-00001.size
    local nodeName = rActor.sCTNode .. '.size';    --rActor.sCTNode
    
    if DB.findNode(nodeName) ~= nil then
        sSize = DB.getText(nodeName);
    end         

    return sSize;
end


-- get creature reach in 5e terms (in feet)
-- use: local sSize = getActorReach(rActor);
-- pre: nReach = '5';
-- post: returns nReach number containing the reach
function getActorReach(rActor)
    local nReach = 5;
    
    -- DB npc node entry structure: combattracker.list.id-00005.reach or charactersheet.id-00001.reach
    local nodeName = rActor.sCTNode .. '.reach';    --rActor.sCTNode
    
    if DB.findNode(nodeName) ~= nil then
    nReach = DB.getValue(nodeName);
    end         

    return tonumber(nReach);
end


-- return ctrlImage window/map containing the currently active actor in the CT
-- use: local ctrlImg = getControlImageByActive();
-- pre: ctrlImage = nul
-- post: ctrlImage = active CT control image
function getControlImageByActive()    
    local nodeActive = CombatManager.getActiveCT();	
    local nodeActiveToken = CombatManager.getTokenFromCT(nodeActive);    
    local ctrlImage, winImage, bWindowOpened = ImageManager.getImageControl(nodeActiveToken, false);
        
    return ctrlImage;        
end


-- find and return rActor window controller
-- use: local ctrlImage = getControlImageByActor(rActor);
-- pre: ctrlImage null;
-- post: returns then image controller for the rActors if found (finds via node->token->image), else null
function getControlImageByActor(rActor)        
    local actorNode = rActor.sCTNode;
    local actorToken = CombatManager.getTokenFromCT(actorNode);
    
    local ctrlImage, winImage, bWindowOpened = ImageManager.getImageControl(actorToken, false);    

    return ctrlImage;
end


-- return ctrlImage window/map containing the passed token
-- use: local ctrlImg = getControlImageByToken(token);
-- pre: ctrlImage = nul
-- post: ctrlImage = token control image
function getControlImageByToken(token)    
    local ctrlImage, winImage, bWindowOpened;

	if token then        
        ctrlImage, winImage, bWindowOpened = ImageManager.getImageControl(token, false);

--        local nodeImgCtrl = token.getContainerNode(); 
--        local nodeToken = nodeImgCtrl.getParent(); 
--		if not wndImg then
--			wndImg = Interface.openWindow("imagewindow",nodeImg); 			
--		end	        
    end        
    
    return ctrlImage;    
end


-- find if there are any enemies within 5' that are not unconscious or not otherwise disabled from attacking
-- use: local bMeleeRangedEnemies = isEnemyInMeleeRange5e(rActor, n), where n is altitude difference if any between the actor and enemy in feet
-- pre: return false
-- post: returns true if enemy found in CT within 5' that is not unconscious or otherwise unable to act, otherwise return false	
function isEnemyInMeleeRange5e(aTokenMap, rActor)	   
	local bEnemyInMeeleRange = false;		
	local sActorPath = DB.getPath(rActor.sCTNode);    
    
	-- search for tokens in the X grid range
    local aTokensX = {};	        
	for k,v in pairs(aTokenMap) do			
		if 	k ~= sActorPath then					
			-- add to list if token found near actor token at x-grid of: x-1/x+0/x+1.
			if (aTokenMap[sActorPath].gridx == v.gridx - 1) or (aTokenMap[sActorPath].gridx == v.gridx) or (aTokenMap[sActorPath].gridx == v.gridx + 1) then				
				aTokensX[k] = {friendfoe = v.friendfoe, gridx = v.gridx, gridy = v.gridy, reach = v.reach, size = v.size, height = v.height};				
			end				
		end	  	
	end

	-- search for tokens in the Y grid range
	local aTokensXandY = {};	
	for k, v in pairs(aTokensX) do		
		-- add to list if token found near actor token at y-grid of: y-1/y+0/y+1.
		if (aTokenMap[sActorPath].gridy == v.gridy - 1) or (aTokenMap[sActorPath].gridy == v.gridy) or (aTokenMap[sActorPath].gridy == v.gridy + 1) then				
			aTokensXandY[k] = {friendfoe = v.friendfoe, gridx = v.gridx, gridy = v.gridy, reach = v.reach, size = v.size, height = v.height};				
		end				
	end	
		
	
	for k, v in pairs(aTokensXandY) do			
		-- check if tokens are foes (friend vs foe, or foe vs friend), neutral are ignored
		if (aTokenMap[sActorPath].friendfoe ~= v.friendfoe and v.friendfoe ~= 'neutral' and v.friendfoe ~= '') then    -- '' is for faction (friend/foe/neutral/faction)
            -- check if unconscious and other conditions that might make a foe unable to act normally     
                       
            local enemyCTNode = ActorManager.getActorFromCT(k);                                
            local isEnemyDisabled = isActorDisabled5e(enemyCTNode);
            
			if isEnemyDisabled == false then						
				-- if not disabled finally check for altitude difference, if within range then enemy is found within range
				if (aTokenMap[sActorPath].height <= v.height + 5) and (aTokenMap[sActorPath].height >= v.height - 5) then
					bEnemyInMeeleRange = true;		
				end
			end		
		end		
	end
	
	return bEnemyInMeeleRange;
end


-- checks if actor in CT is unable to attack in some fashion
-- use: local bDisabled = isActorDisabled5e(nodeCT);
-- pre: bDisabled = false
-- post: bDisabled = true or false depending on if actor is unable to attack due to a condition
function isActorDisabled5e (nodeCT)
	local bDisabled = false;            

    local actor = ActorManager.getActorFromCT(nodeCT.sCTNode);    
        
	if EffectManager5E.hasEffectCondition(actor, "Incapacitated") or EffectManager5E.hasEffectCondition(actor, "Paralyzed") 
		or EffectManager5E.hasEffectCondition(actor, "Petrified") or EffectManager5E.hasEffectCondition(actor, "Restrained")
		or EffectManager5E.hasEffectCondition(actor, "Stunned") or EffectManager5E.hasEffectCondition(actor, "Unconscious")	
	then
		bDisabled = true;
	end
    
	return bDisabled;
end