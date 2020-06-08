--[[
	Script to override range figure drawn next to targeting arrowsio.
	Overrides CoreRPG campaign/scripts/image.lua.
]]--

function onInit()
	if User.isHost() then
		setTokenOrientationMode(false);
	end
	onCursorModeChanged();
	onGridStateChanged();	
end

function onCursorModeChanged(sTool)
	window.onCursorModeChanged();
end

function onGridStateChanged(gridtype)
	window.onGridStateChanged();
end

function onTargetSelect(aTargets)
	local aSelected = getSelectedTokens();
	if #aSelected == 0 then
		local tokenActive = TargetingManager.getActiveToken(self);
		if tokenActive then
			local bAllTargeted = true;
			for _,vToken in ipairs(aTargets) do
				if not vToken.isTargetedBy(tokenActive) then
					bAllTargeted = false;
					break;
				end
			end
			
			for _,vToken in ipairs(aTargets) do
				tokenActive.setTarget(not bAllTargeted, vToken);
			end
			return true;
		end
	end
end

function onDrop(x, y, draginfo)
	local sDragType = draginfo.getType();
	
	if sDragType == "shortcut" then
		local sClass,_ = draginfo.getShortcutData();
		if sClass == "charsheet" then
			if not Input.isShiftPressed() then
				return true;
			end
		end
		
	elseif sDragType == "combattrackerff" then
		return CombatManager.handleFactionDropOnImage(draginfo, self, x, y);
	end
end


-------------------------------------------------------------
-- ADDITIONS TO THE CoreRPG campaign/scripts/image.lua below
-------------------------------------------------------------

-- sub in the measurement text for our custom varient for height
function onMeasurePointer(pixellength,pointertype,startx,starty,endx,endy)
	Debug.chat('onMeasurePointer called')
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