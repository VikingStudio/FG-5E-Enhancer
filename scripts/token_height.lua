-- Script that handles height widgets and corresponding db entries for tokens.


function onInit()
    -- add watchers for DB entry for height actions
    --DB.addHandler("combattracker.list.*.height", "onAdd", dbWatcher);
    DB.addHandler("combattracker.list.*.height", "onUpdate", dbWatcher);
    --DB.addHandler("combattracker.list.*.height", "onDelete", dbWatcher);
end

function dbWatcher(node)
    local token = CombatManager.getTokenFromCT(DB.getParent(node));
    updateHeight(token, 0);
end

-- reads, adds, removes db entries for height
-- creates and destroyes height widget
function updateHeight(token, notches)
    local ctNode = CombatManager.getCTFromToken(token);
    local dbNode = DB.getChild(ctNode, "height");
    local nHeight = 0;

    if dbNode ~= nil then
        if dbNode.getValue() ~= nil then
            nHeight = tonumber(dbNode.getValue());
        end    
    end

    Debug.console("5E Enhancer: Recursive warning while updating height in DB known, has no effect on it working.")

    -- update height
    nHeight = nHeight + (5 * notches);

    -- manage CT DB entry
    if nHeight ~= 0 then
        DB.setValue(ctNode, "height", "number", nHeight);
    else
        DB.deleteChild(ctNode, "height");
    end

    -- update text widget        
    updateHeightWidget(token, nHeight);
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

function updateHeightWidget(token, nHeight)  
    local widget = token.findWidget("tokenheight");
    if widget == nil then
        widget = token.addTextWidget( getFontName(), '' );
    end
    widget.setName("tokenheight"); 
    widget.setFrame('tempmodmini', 10, 10, 10, 4);
    widget.setPosition("bottom right", 0, 0);
    widget.setColor('#000000');
    widget.setText(nHeight .. ' ft.');

    -- visibility    
    if nHeight == 0 or nHeight == nil then
        widget.setVisible(false);
        widget.destroy();
    else
        widget.bringToFront();       
        widget.setVisible(true);
    end        
end

function getTokenHeight(token)
    local nHeight = 0;
    
    local ctNode = CombatManager.getCTFromToken(token);
    local dbNode = DB.getChild(ctNode, "height");

    if dbNode ~= nil then
        if dbNode.getValue() ~= nil then
            nHeight = tonumber(dbNode.getValue());
        end    
    end

    return nHeight;
end


-- DEPRICATED (backup)
function updateHeight_original(token, notches)
    -- height text widget    
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

        -- Create height node in CT
        local ctNode = CombatManager.getCTFromToken(token); 
        local heightNode = ctNode.createChild("height","number");
        heightNode.setValue(nHeight);

        local dbNode = DB.getChild(ctNode, "height");
        local dbHeight = dbNode.getValue();

        if (dbNode ~= nil) and (nHeight == 0) then
            DB.deleteChild(ct, "height");
        end
    end    
end


-- DEPRICATED (backup): return the integer of the tokens height
function getTokenHeight_original(token)
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