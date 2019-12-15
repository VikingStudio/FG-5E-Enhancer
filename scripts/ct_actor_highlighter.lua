--[[
	When token clicked on map, actor owner of that token on the CT is highlighted.
]]--

function onInit()		    
    Token.onClickDown = ctHighLightActor;
end

function ctHighLightActor(target, button, image)         
    local targetNode = ActorManager.getActorFromToken(target);
    Debug.chat('targetNode', targetNode);

    local ctEntry = targetNode.sCreatureNode;
    Debug.chat('ctEntry', ctEntry);
    -- ctEntry.setFrame("ctentrybox_active");

    -- from 5e ruleset ct_entry.lua
    local sFaction = friendfoe.getStringValue();

	if DB.getValue(ctEntry.getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		nonid_name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		nonid_name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end