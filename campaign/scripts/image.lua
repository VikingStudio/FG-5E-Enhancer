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

