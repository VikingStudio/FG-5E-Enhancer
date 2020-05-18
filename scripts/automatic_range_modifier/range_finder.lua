-- Returns the range between two tokens on the battlemap, minor modifications to core code snippet from 5E Ruleset -> manager_actor2.lua.

function onInit()
	ImageManager.onMeasurePointer = onMeasurePointer;
end


function getRange(rAttacker, rDefender)    
	local nodeAttacker = ActorManager.getCTNode(rAttacker);
    local nodeDefender = ActorManager.getCTNode(rDefender);
        
    if nodeAttacker and nodeDefender then

		local tokenAttacker = CombatManager.getTokenFromCT(nodeAttacker);
        local tokenDefender = CombatManager.getTokenFromCT(nodeDefender);        

		    if tokenAttacker and tokenDefender then
			    local nodeAttackerContainer = tokenAttacker.getContainerNode();
                local nodeDefenderContainer = tokenDefender.getContainerNode();                
                
                if nodeAttackerContainer.getNodeName() == nodeDefenderContainer.getNodeName() then
				    local nDU = GameSystem.getDistanceUnitsPerGrid();
					local nAttackerSpace = math.ceil(DB.getValue(nodeAttacker, "space", nDU) / nDU);
					local nDefenderSpace = math.ceil(DB.getValue(nodeDefender, "space", nDU) / nDU);
					local xAttacker, yAttacker = tokenAttacker.getPosition();
                    local xDefender, yDefender = tokenDefender.getPosition();
                    
                    -- START OF NEW CODE REPLACEMENT
                    local ctrlImage = TokenHelper.getControlImageByToken(tokenAttacker);
                    local nGrid = ctrlImage.getGridSize();
                    -- END OF NEW CODE REPLACEMENT 
                    
					local xDiff = math.abs(xAttacker - xDefender);
					local yDiff = math.abs(yAttacker - yDefender);
					local gx = math.floor(xDiff / nGrid);
					local gy = math.floor(yDiff / nGrid);
					
					local nSquares = 0;
					local nStraights = 0;
                    
                    if gx > gy then
					    nSquares = nSquares + gy;
					    nSquares = nSquares + gx - gy;
					else
					    nSquares = nSquares + gx;
						nSquares = nSquares + gy - gx;
					end
					nSquares = nSquares - (nAttackerSpace / 2);
					nSquares = nSquares - (nDefenderSpace / 2);
                    
					-- START OF NEW CODE REPLACEMENT
					local rangeRules = OptionsManager.getOption('CE_RRU'); -- (option_standard|option_variant|option_raw)
					local distance2D = 0;
					local distance3D = 0;
					
					if (rangeRules == 'option_standard') then
						distance2D = math.ceil( (nSquares + 1) * nDU );
					end
					if (rangeRules == 'option_variant') then
						distance2D = Interface.getDistanceDiagMult();
						Debug.chat('option_variant range', distance2D);
					end
					if (rangeRules == 'option_raw') then
						distance2D = math.ceil(((xDiff^2+yDiff^2)^0.5)/(nGrid/nDU));
					end						
										
					-- get height from tokens
					local actorHeight = TokenHeight.getTokenHeight(tokenAttacker);
					local targetHeight = TokenHeight.getTokenHeight(tokenDefender);	

					-- calculate range with height included
					local heightDifference = actorHeight - targetHeight;
					distance3D = math.sqrt((heightDifference^2)+(distance2D^2)); 			

					-- find final range to return
					distance3D = math.floor(distance3D);
					Debug.console('Precise range of attack: ', distance3D);			

					local modulo = distance3D % 5;

					if (modulo > 0) then 
						distance3D = distance3D - modulo + nDU;
					end

					return distance3D;
                    -- END OF NEW CODE REPLACEMENT 
                end		
                	
	        end
    end        
end


-- sub in the measurement text for our custom varient for height
function onMeasurePointer(pixellength,pointertype,startx,starty,endx,endy)
	local lock = acquireMeasureSemaphore(); 
	if lock then
		--Debug.console("node of CT " .. tostring(type(DB.findNode('combattracker.list')))); 
		local gridSize = self.getGridSize(); 
		local snapSX,snapSY = snapToGrid(startx,starty); 
		local snapEX,snapEY = snapToGrid(endx,endy); 
		--Debug.console('coords are x:' .. snapSX/gridSize .. ' y: ' .. snapSY/gridSize .. ' to x: ' .. snapEX/gridSize .. ' y: ' .. snapEY/gridSize); 

		--local ctNodeStart,ctNodeEnd = getCTNodesAt(startx,starty,endx,endy,gridSize); 
		local ctNodeStart,ctNodeEnd = getCTNodesAt(startx,starty,endx,endy); 


		local heightDistance = 0; 
		if HeightManager ~= nil then
			local sh = getCTEntryHeight(ctNodeStart);
			local eh = getCTEntryHeight(ctNodeEnd); 
			-- height is stored in 5ft units, we're working in raw units
			heightDistance = math.abs(eh-sh)/5; 
		end

		local lenX = math.floor(math.abs(snapSX - snapEX)/gridSize); 
		local lenY = math.floor(math.abs(snapSY - snapEY)/gridSize); 
		local baseDistance = math.max(lenX,lenY) + math.floor(math.min(lenX,lenY)/2); 
		local distance = baseDistance;

		--local offX,offY = getGridOffset(); 
		--Debug.console('offX: ' .. offX .. ' offY: ' .. offY); 


		--Debug.console('baseDistance: ' .. baseDistance .. ' heightDistance: ' .. heightDistance); 
		if heightDistance > 0 then
			distance = math.sqrt((baseDistance^2)+(heightDistance^2)); 
			distance = math.floor((distance*10)+0.5)/10; 
		end
		releaseMeasureSemaphore(); 		

		--Debug.chat('' .. (distance*5) .. ' ft');
		return ('' .. (distance*5) .. ' ft'); 
		--return ('' .. (distance*5) .. ' ft' .. ' SH: ' .. sh .. ' EH: ' .. eh); 
		--return ('' .. distance .. ' units'); 
		--return ('X: ' .. lenX .. ' Y: ' .. lenY); 
	end
	return ''; 
end