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
    elseif Input.isControlPressed() then
        -- token scaling
        Debug.console('5E Enhancer: Token.onWheel handler warning produced on purpose to force fallback to original token scaling code.');
        Token.onWheel(token, notches);

        --local scale = token.getContainerScale();
        --scale = scale + notches * 0.1;
        --token.setContainerScale(scale);

        -- update health bar or dot graphics
        --TokenManagerOverride.updateHealthHelper(token, CombatManager.getCTFromToken(token));
    elseif rotateLock == 'off' then     
        -- token rotation for all
        token.setOrientation((token.getOrientation()+notches)%8);    
    elseif Input.isAltPressed() and rotateLock == 'on' then        
        -- token rotation only when Alt pressed
        token.setOrientation((token.getOrientation()+notches)%8);
    end

    return true;
end