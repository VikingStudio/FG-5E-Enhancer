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
		widgetHealthBar.setSize(math.floor(barw * 2.25), math.floor(barh / 5), "left");
		widgetHealthBar.setPosition("left", math.floor(w * 1.1), - math.floor(h * 1.275) ); 				
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
	widgetHealthDot.setSize( math.floor(w / 2.5), math.floor(h / 2.5) );				
	widgetHealthDot.setPosition("bottomright", - math.floor(w / 10), - math.floor(h / 10) ); 				
end

-- END larger healthdot section