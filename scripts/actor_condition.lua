--[[
    Script to detecting and adding conditions as widgets to tokens.
]]--

function updateHealthCondition(tokenCT, nPercentWounded, sStatus)
    local aWidgets = TokenManager.getWidgetList(tokenCT, "");
    Debug.chat('actor condition', aWidgets, tokenCT, nPercentWounded, sStatus)
    local widgetActorCondition = aWidgets["actor_condition"];

	if widgetActorCondition then
		widgetActorCondition.destroy();
    end
    
    
    --[[
	<icon name="health_moderate" file="graphics/token/health/health_moderate.png" />
	<icon name="health_heavy" file="graphics/token/health/health_heavy.png" />
    <icon name="health_critical" file="graphics/token/health/health_critical.png" />
            
    <icon name="health_dying" file="graphics/token/health/health_dying.png" />
	<icon name="health_dying_stable" file="graphics/token/health/health_dying_stable.png" />
	<icon name="health_dead" file="graphics/token/health/health_dead.png" />
    <icon name="health_dead_cross" 
    ]]--
    if (sStatus == 'Moderate') then
        widgetActorCondition = tokenCT.addBitmapWidget("health_moderate");
    elseif (sStatus == 'Heavy') then
        widgetActorCondition = tokenCT.addBitmapWidget("health_heavy");
    elseif (sStatus == 'Critical') then
        widgetActorCondition = tokenCT.addBitmapWidget("health_critical");
    elseif (sStatus == 'Dying') then
        -- widgetActorCondition = tokenCT.addBitmapWidget("dying");
         -- skull or cross on actor death
        if OptionsManager.getOption('CE_SC') == "option_skull" then
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead");
        else
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead_cross");
        end

        BloodPool.addBloodPool(tokenCT);
    else
        if widgetActorCondition then
            widgetActorCondition.destroy();
        end
    end

    if widgetActorCondition then
        widgetActorCondition.bringToFront();
        widgetActorCondition.setName("actor_condition");	
        --widgetActorCondition.setColor(sColor);
        --widgetActorCondition.setTooltipText(sStatus);		
        widgetActorCondition.setVisible(true);

        widgetActorCondition.setSize(80, 80);
        widgetActorCondition.setPosition("center", 0, 0);	
        
        aWidgets = TokenManager.getWidgetList(tokenCT, "");
        Debug.chat('actor_condition widget added', aWidgets)
    end
end