--[[
    Script to detecting and adding conditions as widgets to tokens.
]]--

function updateHealthCondition(tokenCT, nPercentWounded, sStatus)
    local aWidgets = TokenManager.getWidgetList(tokenCT, "");
    --Debug.chat('actor condition', aWidgets, tokenCT, nPercentWounded, sStatus)

    local widgetActorCondition = aWidgets["actor_condition"];
    --Debug.chat('widgetActorCondition before destroy', widgetActorCondition);

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
        if ( OptionsManager.getOption('CE_BOT') == "option_val_on" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_moderate");
        end
    elseif (sStatus == 'Heavy') then
        if ( OptionsManager.getOption('CE_BOT') == "option_val_on" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_heavy");
        end
    elseif (sStatus == 'Critical') then
        if ( OptionsManager.getOption('CE_BOT') == "option_val_on" ) then
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
        if ( OptionsManager.getOption('CE_BP') == "option_val_on" ) then
            BloodPool.addBloodPool(tokenCT);
        end
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
        -- Debug.chat('actor_condition widget added', aWidgets)
    end
end