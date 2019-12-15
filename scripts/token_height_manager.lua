--[[
    Script to manage height indicators on tokens.
]]--

function onInit()    
    Token.onWheel = tokenHeightChange;
end

function tokenHeightChange(target, notches)
    Debug.chat('tokenWheel', notches)

    if Input.isShiftPressed() then        
        local nHeight = 0;
        local heightWidget = target.findWidget("tokenheight");
        Debug.chat('heightWidget', heightWidget);
        -- add up update widget
        if (heightWidget == nil) then
            if notches == '1' then nHeight = 5; end
            if notches == '-1' then nHeight = -5; end
            Debug.chat('nHeight 1', nHeight);

            heightWidget = target.addTextWidget();
            heightWidget = updateHeightWidget(heightWidget, nHeight);
        else
            -- regex pattern: ^\S\d*   (returns - modifier and numbers at start of string, ex.: '-120 ft.' or '-120 ft', returns '-120')
            local sPattern = '^\S\d*';
            local sHeight = heightWidget.getText();
            Debug.chat('sHeight 2', sHeight);
            nHeight = tonumber(string.find(sHeight, sPattern));
            Debug.chat('nHeight 2', nHeight);

            if notches == '1' then nHeight = nHeight + 5; end
            if notches == '-1' then nHeight = nHeight - 5; end         

            heightWidget = updateHeightWidget(heightWidget, nHeight);
        end

        Debug.chat('Height:', nHeight);
    end    

end


function updateHeightWidget(widget, nHeight)     
    Debug.chat('widget update', widget, nHeight);

    widget.setName("tokenheight"); 
    widget.setPosition("right", 0, 0); 
    widget.setFrame('tempmodmini', 10, 10, 10, 4); 
    widget.setColor('00000000');

    -- font size alternatives
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
    widget.setText(nHeight .. ' ft');

    -- visibility    
    if nHeight == 0 then
        widget.isVisible(false);
    else
        widget.bringToFront();
        widget.isVisible(true);
    end        

    Debug.chat('widget text', widget.getText() );
end