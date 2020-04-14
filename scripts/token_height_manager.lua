--[[
    Script to manage height indicators on tokens.
]]--

function onInit()    
    Token.onWheel = onWheel;
end

function onWheel(token, notches)
    local rotateLock = OptionsManager.getOption('CE_TRA');    

    if Input.isShiftPressed() then        
        local nHeight = 0;
        local heightWidget = token.findWidget("tokenheight");

        -- add up update widget
        if (heightWidget == nil) then
            nHeight = 5 * notches;

            heightWidget = token.addTextWidget( getFontName(), '5 ft.' );
            heightWidget = updateHeightWidget(heightWidget, nHeight);
        else
            -- regex pattern: ^[-]?[0-9]+   (returns - modifier and numbers at start of string, ex.: '-120 ft.' or '-120 ft', returns '-120')
            -- from the start of the string, zero or one of '-', then one or more of 0-9
            local sPattern = '^[-]?[0-9]+';
            local sHeight = heightWidget.getText();

            sHeight = sHeight:match(sPattern);
            nHeight = tonumber(sHeight);

            nHeight = nHeight + (5 * notches); 

            heightWidget = updateHeightWidget(heightWidget, nHeight);
        end
    elseif rotateLock == 'off' then        
        token.setOrientation((token.getOrientation()+notches)%8);    
    elseif Input.isAltPressed() and rotateLock == 'on' then        
        token.setOrientation((token.getOrientation()+notches)%8);
    end

    return true;
end

-- return the integer of the tokens height
function getTokenHeight(token)
    local nHeight = 0;
    local heightWidget = token.findWidget("tokenheight"); 
    
    if (heightWidget == nil) then
        return 0;        
    elseif (heightWidget ~= nil) then
        -- regex pattern: ^[-]?[0-9]+   (returns - modifier and numbers at start of string, ex.: '-120 ft.' or '-120 ft', returns '-120')
        -- from the start of the string, zero or one of '-', then one or more of 0-9
        local sPattern = '^[-]?[0-9]+';
        local sHeight = heightWidget.getText();

        sHeight = sHeight:match(sPattern);
        nHeight = tonumber(sHeight);

        return nHeight;
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
end