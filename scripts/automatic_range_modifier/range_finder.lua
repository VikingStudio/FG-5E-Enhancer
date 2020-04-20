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
					local actorHeight = TokenWheelManager.getTokenHeight(tokenAttacker);
					local targetHeight = TokenWheelManager.getTokenHeight(tokenDefender);	

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
