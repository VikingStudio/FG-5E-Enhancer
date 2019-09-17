--[[
    Script to manage height indicators on tokens.
]]--

-- Token function onWheel( target, notches ) 

function onInit()
    -- Token.onWheel = tokenHeightChange;
end

function tokenHeightChange(target, notches)
    --Debug.chat('tokenWheel', notches)

    if Input.isShiftPressed() then
        local heightWidget = target.addTextWidget();
        local sHeight = heightWidget.getText();

        if sHeight == '' then             
            if notches == '1' then sHeight = '5 ft.'; end
            if notches == '-1' then sHeight = '-5 ft.'; end
        else
            -- regex pattern: ^\S\d*   (returns - modifier and numbers at start of string, ex.: '-120 ft.',returns '-120')
            sPattern = '^\S\d*';
            local nHeight = string.find(sHeight, sPattern);

            if notches == '1' then sHeight = nHeight + 5 .. ' ft.'; end
            if notches == '-1' then sHeight = nHeight - 5 .. ' ft.'; end            
        end            

        if sHeight == '0 ft.' or sHeight == '' then
            heightWidget.isVisible(false);
        else
            heightWidget.bringToFront();
            heightWidget.isVisible(true);
        end


        Debug.chat('Height:', sHeight);
    end    
    --[[
    local fontSize = OptionsManager.getOption("CE_HFS");
    if fontSize == 'option_small' then
        wdg = token.addTextWidget("height_small",height .. ' ft'); 
    elseif fontSize == 'option_medium' then
        wdg = token.addTextWidget("height_medium",height .. ' ft'); 
    else 
        wdg = token.addTextWidget("height_large",height .. ' ft'); 
    end    
    ]]--
end