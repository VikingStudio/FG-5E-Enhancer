--[[
    Script to handle the DM pinging the map. Doing so adds a ping token and moves the players maps to center on that location.
]]--

function onInit()	
	Token.onClickDown = onClickDown;			
end


-- Delete token / and CT entry on mouse click.
-- Use: Mouse Left-click Token on combat map while holding down either 'Alt' or 'Alt+Ctrl'
-- Pre: Token on combat map
-- Post: Token removed from combat map (Alt) or combat map and combat tracker (Atl+Ctrl)
-- NOTE: button (number), Returns a numerical value indicating the button pressed (1 = left, 2 = middle, 4 = button 4, 5 = button 5). Right button is used for radial menus.
function onClickDown( token, button, image ) 
	-- Deletes token from combat map, if Alt held on left mouse click.
	if (Input.isShift() == true) and (User.isHost() == true) and (button==1) then
        
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