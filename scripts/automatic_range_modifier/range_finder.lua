-- Returns the range between two tokens on the battlemap, minor modifications to core code snippet from 5E Ruleset -> manager_actor2.lua.

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
					local distance = math.ceil( (nSquares + 1) * nDU );			
					local modulo = distance % 5;

					if (modulo > 0) then 
						distance = distance - modulo + nDU;
					end

					return distance;
                    -- END OF NEW CODE REPLACEMENT 
                end		
                	
	        end
    end        
end
