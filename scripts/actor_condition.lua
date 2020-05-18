--[[
    Script to detecting and adding conditions as widgets to tokens.
]]--

function updateHealthCondition(tokenCT, nPercentWounded, sStatus)
    --[[
	<icon name="health_moderate" file="graphics/token/health/health_moderate.png" />
	<icon name="health_heavy" file="graphics/token/health/health_heavy.png" />
    <icon name="health_critical" file="graphics/token/health/health_critical.png" />
            
    <icon name="health_dying" file="graphics/token/health/health_dying.png" />
	<icon name="health_dying_stable" file="graphics/token/health/health_dying_stable.png" />
	<icon name="health_dead" file="graphics/token/health/health_dead.png" />
    <icon name="health_dead_cross" 
    ]]--

    -- remove old widget graphics if any before drawing new one, also clears 
    --local aWidgets = TokenManagerOverride.getWidgetList(tokenCT, "");
    -- local widgetActorCondition = aWidgets["actor_condition"];

    -- remove/clear current condition or blood pool widgets if any
    local widgetActorCondition = tokenCT.findWidget("actor_condition");
    if widgetActorCondition then
        widgetActorCondition.destroy();
    end
    local widgetBloodPool = tokenCT.findWidget("blood_pool");    

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
    elseif (sStatus == 'Dying' or sStatus == 'Dying (1)' or sStatus == 'Dying (2)' or sStatus == 'Dead') then
        -- widgetActorCondition = tokenCT.addBitmapWidget("dying");

         -- add skull or cross on actor death if enabled
        if ( OptionsManager.getOption('CE_SC') == "option_skull" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead");
        elseif ( OptionsManager.getOption('CE_SC') == "option_cross" ) then
            widgetActorCondition = tokenCT.addBitmapWidget("health_dead_cross");
        end

        -- draw blood pool if active
        if ( OptionsManager.getOption('CE_BP') == "on" and widgetBloodPool == nil) then
            BloodPool.addBloodPool(tokenCT);
        end
    else
        widgetActorCondition = nil;
        if widgetBloodPool then
            widgetBloodPool.destroy();
        end
    end

    if (widgetActorCondition ~= nil) then
        widgetActorCondition.setName("actor_condition");	
        Helper.resizeForTokenSize(tokenCT, widgetActorCondition);
        widgetActorCondition.setPosition("center", 0, 0);	
        widgetActorCondition.bringToFront();
        widgetActorCondition.setVisible(true);
    end

    -- testTokenAdd(tokenCT);
end


function testTokenAdd(tokenCT)
    -- Debug.chat('test start')
    ctrlImage, windowInstance, bWindowOpened = ImageManager.getImageControl(tokenCT, false);
    -- Debug.chat('contols', ctrlImage, windowInstance, bWindowOpened)
    -- Debug.chat('all tokens before', ctrlImage.getTokens());

    local bloodToken = ctrlImage.addToken("blood_pool_1", 100, 100);
    -- Debug.chat('bloodToken', bloodToken)
    bloodToken.setSize(100, 100);
    -- Debug.chat('all tokens after', ctrlImage.getTokens());
    -- Debug.chat('test end')
end