--[[
    Script to create a horizontal health bar and a larger dot health icon.
]]--

function onInit()
		DB.addHandler("options.CE_HHB", "onUpdate", drawHealth);

		-- change health bar when token first added or taking wounds			
		DB.addHandler("combattracker.list.*.hp", "onUpdate", drawHealth);
		DB.addHandler("combattracker.list.*.hptemp", "onUpdate", drawHealth);
		DB.addHandler("combattracker.list.*.wounds", "onUpdate", drawHealth);
	
		DB.addHandler("combattracker.list.*.tokenscale", "onUpdate", rescaleHealth);
		
		--Token.onAdd = tokenAdd;
		--TokenManager.onAdd = tokenAdd;
end


--[[ 
/////////////////////////////	
Horizontal Health Bar Section 
/////////////////////////////
]]--

-- returns string to indicate type of health to show depending on menu settings
-- use: local sHealthType = getHealthIndicator();
-- pre: sHealthType = 'barHorizontal'
-- post: returns sHealthType: 'barDefault', 'barHorizontal', 'dot'
function getHealthIndicator()	
	--[[
		Related menu items :
		
		<string name="option_label_TGMH">GM: Show health</string>	-> TGMH (tooltip|bar|barhover|dot|dothover)	
		<string name="option_label_TNPCH">Player: Show Enemy health</string> -> TNPCH (tooltip|bar|barhover|dot|dothover)		
		<string name="option_label_TPCH">Player: Show Ally health</string>	-> TPCH (tooltip|bar|barhover|dot|dothover)
	]]--

	local sHealthType = 'barHorizontal'; -- bar, barHorizontal, dot

	local horizontalHB = OptionsManager.getOption('CE_HHB'); -- (on|off)
	local GMShowHealth = OptionsManager.getOption('TGMH'); -- (tooltip|bar|barhover|dot|dothover)
	local showEnemyHealth = OptionsManager.getOption('TNPCH'); -- (tooltip|bar|barhover|dot|dothover)
	local showAllyHealth = OptionsManager.getOption('TPCH'); -- (tooltip|bar|barhover|dot|dothover)

	if horizontalHB == "on" and GMShowHealth == 'bar' then
		sHealthType = 'barHorizontal';
	end		
	if horizontalHB == "off" and GMShowHealth == 'bar' then	
		sHealthType = 'barDefault';
	end
	if GMShowHealth == 'dot' then	
		sHealthType = 'dot';
	end

	return sHealthType;
end	


function tokenAdd2(tokenMap)
	ImageManager.onTokenAdd(tokenMap);
	--Debug.chat('tokenMap', tokenMap)
	drawHealth(tokenMap);
end

-- runs when token is first added to map
function tokenAdd(token)
	--Debug.chat('tokenAdd', token)

	-- get CT entry from token and call drawHealth	
	local nodeContainer, nID = CombatManager.getCTFromToken(token);
	local containernode = token.getContainerNode();
	local containerid = token.getId();
	--Debug.chat('tokenAdd variables', nodeContainer, nID, containernode, containerid, token2)
	drawHealth(containernode);
end

-- draw horizontal health bar, or default vertial
function drawHealth (sourceNode)	
	--Debug.chat('drawHealth', sourceNode)
	local node = sourceNode.getParent(); -- get CT top level entry
	local token = CombatManager.getTokenFromCT(node);	

	--Debug.chat('node', node, 'token', token)

	if token then						
		-- horizontal health bars if menu setting on, otherwise use default slim vertical health bars										
		if getHealthIndicator() == 'barHorizontal' then								
			drawHorizontalHealthBar(token, node);								
		end
		if getHealthIndicator() == 'dot' then								
			drawDot(token, node);								
		end		
	end
end

-- Horizontal health bar: Changed health bar to appear above token, full token width when health 100%, horizontal health bar, above token
function drawHorizontalHealthBar(token, node)			
	local healthBar = token.findWidget('healthbar');
	healthBar.destroy();

	healthBar = token.addBitmapWidget('healthbar_horizontal');		
	healthBar.setName("healthbar");
	healthBar.sendToBack();

	--Debug.chat('token', token, 'node', node, 'healthBar', healthBar);
	if healthBar then
		local nPercentWounded, sStatus, sColor = TokenManager2.getHealthInfo(node);
							
		local w, h = token.getSize();				

		healthBar.setSize(w, h);
		local barw, barh = healthBar.getSize();
		
		token_health_minbar = 0;

		--Resize bar to match health percentage
		if w >= token_health_minbar then
			barw = (math.max(1.0 - nPercentWounded, 0) * (math.min(w, barw) - token_health_minbar)) + token_health_minbar;
		else
			barw = token_health_minbar;
		end				
		
		-- add status and color to bar
		healthBar.setTooltipText(sStatus);
		healthBar.setColor(sColor);		

		-- making health bars wider and taller, appearing on top, resize and place ratio wise due to different mat grids and resolution sizes	
		healthBar.setSize(barw - math.floor(barw / 90), math.floor(barh / 10), "left");
		healthBar.setPosition("left", (barw / 2), - math.floor(h / 1.7) ); 				
		
	end
end

function rescaleHealth(sourcenode)
	local node = sourceNode.getParent(); -- get CT top level entry
	local token = CombatManager.getTokenFromCT(node);			

	-- scale for wide horizontal health bars if menu setting on, otherwise use default slim vertical health bars
	if getHealthIndicator() == 'barHorizontal' then				
		drawHorizontalHealthBar(token, node);
	end			
end

--[[ End of Horizontal Health Bar Section ]]--


--[[ 
////////////////
larger healthdot 
////////////////	
]]--

function drawDot(token, node)
	local nPercentWounded, sStatus, sColor = TokenManager2.getHealthInfo(node);

	local healthDot = token.findWidget('healthdot');
	healthDot.destroy();

	healthDot = token.addBitmapWidget('healthdot_larger');		
	healthDot.setName("healthdot");	

	healthDot.setTooltipText(sStatus);
	healthDot.setColor(sColor);		

	local w, h = token.getSize();									
	healthDot.setSize( math.floor(w / 5), math.floor(h / 5) );				
	healthDot.setPosition("bottomright", - math.floor(w / 10), - math.floor(h / 10) ); 		

	healthDot.isVisible(true);
	healthDot.sendToBack();	
end