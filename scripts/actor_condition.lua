--[[
    Script to detecting and adding conditions as widgets to tokens.
]]--

function updateHealthCondition(tokenCT, nPercentWounded, sStatus)
    -- Debug.chat('actor condition', aWidgets, tokenCT, nPercentWounded, sStatus)
   --  Debug.chat('menu options, blood on token ', OptionsManager.getOption('CE_BOT'), ' bood pool on death ', OptionsManager.getOption('CE_BP') )
    
    
    --[[
	<icon name="health_moderate" file="graphics/token/health/health_moderate.png" />
	<icon name="health_heavy" file="graphics/token/health/health_heavy.png" />
    <icon name="health_critical" file="graphics/token/health/health_critical.png" />
            
    <icon name="health_dying" file="graphics/token/health/health_dying.png" />
	<icon name="health_dying_stable" file="graphics/token/health/health_dying_stable.png" />
	<icon name="health_dead" file="graphics/token/health/health_dead.png" />
    <icon name="health_dead_cross" 
    ]]--

    Debug.chat('status', sStatus)
    -- remove old widget graphics if any before drawing new one, also clears 
    local aWidgets = TokenManager.getWidgetList(tokenCT, "");
    -- local widgetActorCondition = aWidgets["actor_condition"];
    local widgetActorCondition = tokenCT.findWidget("actor_condition");
    
    Debug.chat('before destroy', aWidgets, widgetActorCondition);
    if widgetActorCondition then
        widgetActorCondition.destroy();
    end

    if (sStatus == 'Moderate') then
        if ( OptionsManager.getOption('CE_BOT') == "on" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_moderate");
        end
    elseif (sStatus == 'Heavy') then
        if ( OptionsManager.getOption('CE_BOT') == "on" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_heavy");
        end
    elseif (sStatus == 'Critical') then
        if ( OptionsManager.getOption('CE_BOT') == "on" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_critical");
        end
    elseif (sStatus == 'Dying') then
        -- widgetActorCondition = tokenCT.addBitmapWidget("dying");

         -- add skull or cross on actor death if enabled
        if ( OptionsManager.getOption('CE_SC') == "option_skull" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead");
        elseif ( OptionsManager.getOption('CE_SC') == "option_cross" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead_cross");
        end

        -- draw blood pool if active
        if ( OptionsManager.getOption('CE_BP') == "on" ) then
            BloodPool.addBloodPool(tokenCT);
        end
    else
        widgetActorCondition = nil
    end

    Debug.chat('cond before add', widgetActorCondition)
    if (widgetActorCondition ~= nil) then
        widgetActorCondition.setName("actor_condition");	
        resizeForTokenSize(tokenCT, widgetActorCondition);
        widgetActorCondition.setPosition("center", 0, 0);	
        widgetActorCondition.bringToFront();
        widgetActorCondition.setVisible(true);
    end
    Debug.chat('cond after add', widgetActorCondition, aWidgets)

    aWidgets = TokenManager.getWidgetList(tokenCT, "");
    widgetActorCondition = aWidgets["actor_condition"];
    Debug.chat('w', aWidgets, widgetActorCondition)
end

-- resizes condition art to span token size
function resizeForTokenSize(tokenCT, widget)
    local baseSize = 80;
    local sSize = Helper.getActorSize(tokenCT);

    
    -- shift location based on size of actor
    if (sSize == 'Large') then 
        widget.setSize(baseSize * 2, baseSize * 2);
    elseif (sSize == 'Huge') then 
        widget.setSize(baseSize * 3, baseSize * 3);
    elseif (sSize == 'Gargantuan') then 
        widget.setSize(baseSize* 4, baseSize * 4);
    else
        widget.setSize(baseSize, baseSize);
    end
end