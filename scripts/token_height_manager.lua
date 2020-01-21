--[[
    Script to manage height indicators on tokens.
]]--

function onInit()    
    -- Token.onWheel = tokenHeightChange;
end

function tokenHeightChange(token, notches)
    -- textWidgetTest(token);

    Debug.chat('tokenWheel', notches)

    if Input.isShiftPressed() then        
        local nHeight = 0;
        local heightWidget = token.findWidget("tokenheight");
        Debug.chat('heightWidget', heightWidget);
        -- add up update widget
        if (heightWidget == nil) then
            if notches >= 1 then nHeight = 5 * notches; end
            if notches <= -1 then nHeight = -5 * notches; end
            Debug.chat('nHeight 1', nHeight);

            heightWidget = token.addTextWidget( getFontName(), '5 ft.' );
            heightWidget = updateHeightWidget(heightWidget, nHeight);
        else
            -- regex pattern: ^[-]?[0-9]+   (returns - modifier and numbers at start of string, ex.: '-120 ft.' or '-120 ft', returns '-120')
            -- from the start of the string, zero or one of '-', then one or more of 0-9
            local sPattern = '^[-]?[0-9]+';
            local sHeight = heightWidget.getText();
            Debug.chat('sHeight 2', sHeight);
            sHeight = sHeight:match(sPattern);
            nHeight = tonumber(sHeight);
            Debug.chat('nHeight 2', sHeight, nHeight);

            if notches >= 1 then nHeight = nHeight + (5 * notches); end
            if notches <= -1 then nHeight = nHeight - (5 * notches); end     

            heightWidget = updateHeightWidget(heightWidget, nHeight);
        end

        Debug.chat('Height:', nHeight);
    end    

end

function getFontName()
    local fontName;

    --height_large, height_medium, height_small
    local fontSize = OptionsManager.getOption("CE_HFS");
    if ( fontSize == 'option_small' ) then
        fontName = "height_small";
    elseif ( fontSize == 'option_medium' ) then
        fontName = "height_medium";
    else 
        fontName = "height_large"; 
    end

    return fontName;
end

function updateHeightWidget(widget, nHeight)     
    -- Debug.chat('widget update', widget, nHeight);

    widget.setName("tokenheight"); 
    widget.setFrame('tempmodmini', 10, 10, 10, 4);
    widget.setPosition("bottom right", 0, 0);     
    widget.setColor('#000000');
    widget.setText(nHeight .. ' ft.');

    -- visibility    
    if nHeight == 0 then
        widget.setVisible(false);
        widget.destroy();
    else
        widget.bringToFront();       
        widget.setVisible(true);
    end        

    Debug.chat('widget text', widget );
end

function textWidgetTest(token)
    wdg = token.addTextWidget("height_large", 'HEIGHT'); 
    wdg.setVisible(true);
    wdg.setName("test_widget"); 
    wdg.setPosition("right",0,0); 
    wdg.setFrame('tempmodmini',10,10,10,4);
    wdg.setColor('#FFA242');
    wdg.setMaxWidth(200);
    wdg.bringToFront(); 

    Debug.chat('Test widget created', wdg)
end