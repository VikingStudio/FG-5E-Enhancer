--[[
    Script to manage height indicators on tokens.
]]--

function onInit()    
    Token.onWheel = onWheel;
end


function onWheel(token, notches)
    if token == nil then
        return;
    end

    local rotateLock = OptionsManager.getOption('CE_TRA');

    if Input.isShiftPressed() and User.isHost() then    
        TokenHeight.updateHeight(token, notches);
		return true;
    elseif Input.isControlPressed() then
		return nil;
    elseif rotateLock == 'off' then     
        Debug.console('rotatelock is off');
        -- token rotation for all
        token.setOrientation((token.getOrientation()+notches)%8);    
    elseif Input.isAltPressed() and rotateLock == 'on' then        
        Debug.console('Alt pressed and rotatelock is on');
        -- token rotation only when Alt pressed
        token.setOrientation((token.getOrientation()+notches)%8);
    end

    return true;
end
