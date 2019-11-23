--[[
    Script to create a horizontal health bar and a larger dot health icon.
]]--


-- START Horizontal Health Bar Section

-- Horizontal health bar: Changed health bar to appear above token, full token width when health 100%, horizontal health bar, above token
function drawHorizontalHealthBar(tokenCT, widgetHealthBar, bVisible)
	local nPercentWounded, sStatus, sColor = TokenManager2.getHealthInfo(CombatManager.getCTFromToken(tokenCT));

	if widgetHealthBar then
		widgetHealthBar.destroy();
	end

	widgetHealthBar = tokenCT.addBitmapWidget("healthbar_horizontal");
	widgetHealthBar.sendToBack();
	widgetHealthBar.setName("healthbar");			
	widgetHealthBar.setColor(sColor);
	widgetHealthBar.setTooltipText(sStatus);		
	widgetHealthBar.setVisible(bVisible);
	updateHealthBarScale(tokenCT, nPercentWounded);		
end
	
-- Manager.onScaleChanged

-- Scaling of horizontal health bar
function updateHealthBarScale(tokenCT, nPercentWounded)
	local widgetHealthBar = tokenCT.findWidget("healthbar");
	if widgetHealthBar then			
		
		local w, h = tokenCT.getSize();
		local barw, barh = widgetHealthBar.getSize();
		
		token_health_minbar = 0;

		--Resize bar to match health percentage
		if w >= token_health_minbar then
			barw = (math.max(1.0 - nPercentWounded, 0) * (math.min(w, barw) - token_health_minbar)) + token_health_minbar;
		else
			barw = token_health_minbar;
		end								

		-- making health bars wider and taller, appearing on top, resize and place ratio wise due to different map grids and resolution sizes	

		-- Horizontal health bar, (left, default)
		if OptionsManager.getOption('CE_HHB') == "option_v1" then			
			-- widgetHealthBar.setSize(barw - math.floor(barw * 0.01), math.floor(barh * 0.1), "left");
			widgetHealthBar.setSize(barw, math.floor(barh * 0.1), "left");
			widgetHealthBar.setPosition("left", (barw * 0.5), - math.floor(h * 0.59) ); 	
		end

		-- Horizontal health bar, (left, taller)
		if OptionsManager.getOption('CE_HHB') == "option_v2" then										
			widgetHealthBar.setSize(barw, math.floor(barh * 0.2), "left");								
			widgetHealthBar.setPosition("left", (barw * 0.5), - math.floor(h * 0.55) ); 						
		end

		-- Horizontal health bar, (centered, default)
		if OptionsManager.getOption('CE_HHB') == "option_v3" then
			widgetHealthBar.setSize(barw, math.floor(barh * 0.1), "left");
			widgetHealthBar.setPosition("center top", 0, - math.floor(h * 0.1) ); 
		end

		-- Horizontal health bar, (centered, taller)
		if OptionsManager.getOption('CE_HHB') == "option_v4" then
			widgetHealthBar.setSize(barw, math.floor(barh * 0.2), "left");
			widgetHealthBar.setPosition("center top", 0, - math.floor(h * 0.07) ); 
		end		
	end
end

-- END Horizontal Health Bar Section


-- START larger healthdot section

function drawLargerHealthDot(tokenCT, widgetHealthDot, bVisible)
	local nPercentWounded, sStatus, sColor = TokenManager2.getHealthInfo(CombatManager.getCTFromToken(tokenCT));

	if widgetHealthDot then
		widgetHealthDot.destroy();
	end

	widgetHealthDot = tokenCT.addBitmapWidget('healthdot_larger');		
	widgetHealthDot.sendToBack();	
	widgetHealthDot.setName("healthdot");	
	widgetHealthDot.setColor(sColor);		
	widgetHealthDot.setTooltipText(sStatus);
	widgetHealthDot.isVisible(bVisible);

	local w, h = tokenCT.getSize();			
	local MAXDIMENSION = 40;						

	-- Larger
	if OptionsManager.getOption('CE_LHD') == "option_larger" then
		local dimension = math.floor( w * 0.2 );
		if (dimension > MAXDIMENSION) then dimension = MAXDIMENSION; end

		widgetHealthDot.setSize( dimension, dimension );				
		widgetHealthDot.setPosition("bottomright", - math.floor(w * 0.1), - math.floor(h * 0.1) ); 			
	end

	-- Largest
	if OptionsManager.getOption('CE_LHD') == "option_largest" then
		local dimension = math.floor( w * 0.4 );
		if (dimension > MAXDIMENSION) then dimension = MAXDIMENSION; end

		widgetHealthDot.setSize( dimension, dimension );				
		widgetHealthDot.setPosition("bottomright", - math.floor(w * 0.1), - math.floor(h * 0.1) ); 						
	end
end

-- END larger healthdot section