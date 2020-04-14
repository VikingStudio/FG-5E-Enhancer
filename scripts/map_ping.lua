--[[
    Script to handle the DM pinging the map. Doing so adds a ping token and moves the players maps to center on that location.
]]--

function onInit()		
	-- Token.onClickDown = onClickDown;	
end

function onClickDown( token, button, image ) 
	-- Deletes token from combat map, if Alt held on left mouse click.
	if (Input.isControlPressed() == true) and (User.isHost() == true) and (button==1) then
        
        --local nodeCT = CombatManager.getCTFromToken(token);
        --token.delete();		
        
		Debug.chat('image ', image)
		--[[
		imagecontrol
		  .setViewpoint(x,y,zoom)
		  .addToken(prototypename,x,y)

		Input.getMousePosition()  return: x, y
		]]--

	end	
end