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
	
-- Scaling of horizontal health bar
function updateHealthBarScale(tokenCT, nPercentWounded)	
	local widgetHealthBar = tokenCT.findWidget("healthbar");

	if widgetHealthBar then						
		
		--[[
		local wToken, hToken = tokenCT.getSize();
		widgetHealthBar.setSize(wToken, hToken);		
		local wBar, hBar = widgetHealthBar.getSize();

		token_health_minbar = 0;

		--Resize bar to match health percentage
		if wToken >= token_health_minbar then
			wBar = (math.max(1.0 - nPercentWounded, 0) * (math.min(wToken, wBar) - token_health_minbar)) + token_health_minbar;			
		else
			wBar = token_health_minbar;
		end			
		]]--

		local wScaled = getHealthBarWidthScale(tokenCT, nPercentWounded);		

		-- making health bars wider and taller, appearing on top, resize and place ratio wise due to different map grids and resolution sizes	

		-- Horizontal health bar, (left, default)
		if OptionsManager.getOption('CE_HHB') == "option_v1" then			
			widgetHealthBar.setSize(wScaled, 10, "left");
			widgetHealthBar.setPosition("top left", getLeftPositioning(tokenCT, nPercentWounded), -10);			
		end		

		-- Horizontal health bar, (left, taller)
		if OptionsManager.getOption('CE_HHB') == "option_v2" then										
			widgetHealthBar.setSize(wScaled, 20);
			widgetHealthBar.setPosition("top left", getLeftPositioning(tokenCT, nPercentWounded), -15); 							
		end

		-- Horizontal health bar, (centered, default)
		if OptionsManager.getOption('CE_HHB') == "option_v3" then
			widgetHealthBar.setSize(wScaled, 10);
			widgetHealthBar.setPosition("top center", 0, -10 ); 
		end

		-- Horizontal health bar, (centered, taller)
		if OptionsManager.getOption('CE_HHB') == "option_v4" then
			widgetHealthBar.setSize(wScaled, 20);
			widgetHealthBar.setPosition("top center", 0, - 15 ); 
		end		
	
	-- else
	--	drawHorizontalHealthBar(tokenCT, widgetHealthBar, true);
	end	
end


-- returns a % scaled version width of the horizontal health bar, considering remaining health
function getHealthBarWidthScale(tokenCT, nPercentWounded)	
	local sSize = getActorSize(tokenCT);
	local nScaledWidth = 100 - (nPercentWounded * 100);  -- scale is in % of token width
	
	if (sSize == 'Large') then 
		nScaledWidth = nScaledWidth * 2;
	elseif (sSize == 'Huge') then 
		nScaledWidth = nScaledWidth * 3;
	elseif (sSize == 'Gargantuan') then 
		nScaledWidth = nScaledWidth * 4;
	end
	
	return nScaledWidth;
end

-- returns a % scaled version of a left positioned horizontal health bar, for Token (GM) -> Auto-scale to grid = 80% of grid
function getLeftPositioning(tokenCT, nPercentWounded)	
	local sSize = getActorSize(tokenCT);
	local nPositioning = 0;


	-- check if Token (GM) -> Auto-scale to grid = 80% or 100% of grid
	local sAutoScaleSetting = OptionsManager.getOption("TASG"); -- off | 80 | 100
	
	if ( (sAutoScaleSetting == '80') or (sAutoScaleSetting == 'off') ) then
		nPositioning = 40;
	elseif (sAutoScaleSetting == '100') then
		nPositioning = 48;
	end

	-- shift location based on size of actor
	if (sSize == 'Large') then 
		nPositioning = math.floor( nPositioning * 2 );
	elseif (sSize == 'Huge') then 
		nPositioning = math.floor( nPositioning * 3 );
	elseif (sSize == 'Gargantuan') then 
		nPositioning = math.floor( nPositioning * 3.8 );
	end

	Debug.chat('positioning', nPositioning, nPercentWounded, math.floor( nPositioning + (nPositioning * nPercentWounded / 2 ) ), nPositioning * nPercentWounded / 2 );
	nPositioning = math.floor( nPositioning - (nPositioning * nPercentWounded / 2 ) );
	
	return nPositioning;
end

-- returns the text describing the size of the token, possible sizes: Tiny, Small, Medium, Large, Huge, Gargantuan
function getActorSize(tokenCT)
	local ctEntry = CombatManager.getCTFromToken(tokenCT);	
	local actor = ActorManager.getActorFromCT(ctEntry);	

	local dbPath = DB.getPath(actor.sCreatureNode, 'size');
	local sSize = DB.getText(dbPath);

	return sSize;
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
	widgetHealthDot.setName("tokenhealthdot");	
	widgetHealthDot.setColor(sColor);		
	widgetHealthDot.setTooltipText(sStatus);
	widgetHealthDot.isVisible(bVisible);

	local wToken, hToken = tokenCT.getSize();			
	local MAXDIMENSION = 40;						

	-- Larger
	if OptionsManager.getOption('CE_LHD') == "option_larger" then
		local dimension = math.floor( wToken * 0.2 );
		if (dimension > MAXDIMENSION) then dimension = MAXDIMENSION; end

		widgetHealthDot.setSize( dimension, dimension );				
		widgetHealthDot.setPosition("bottomright", - math.floor(wToken * 0.1), - math.floor(hToken * 0.1) ); 			
	end

	-- Largest
	if OptionsManager.getOption('CE_LHD') == "option_largest" then
		local dimension = math.floor( wToken * 0.4 );
		if (dimension > MAXDIMENSION) then dimension = MAXDIMENSION; end

		widgetHealthDot.setSize( dimension, dimension );				
		widgetHealthDot.setPosition("bottomright", - math.floor(wToken * 0.1), - math.floor(hToken * 0.1) ); 						
	end
end

-- END larger healthdot section