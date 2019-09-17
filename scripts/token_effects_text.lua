--[[
    Script for showing a tokens effects in a tooltip on hover.
]]--

    --[[
		Related menu items

        <string name="option_label_TGME">GM: Show effects</string>  -> TGME (tooltip|on|hover|mark|markhover)
        <string name="option_label_TNPCE">Player: Show Enemy effects</string> -> TNPCE (tooltip|on|hover|mark|markhover)
        <string name="option_label_TPCE">Player: Show Ally effects</string> -> TPCE (tooltip|on|hover|mark|markhover)

        <string name="option_val_tooltip">Tooltip</string>  -> TNAM (tooltip|on|hover)

        Token function onHover( target, state ) 


        

    --]]

    function onInit()	
        -- Token.onHover = tokenHover;	
        
        DB.addHandler("combattracker.list.*.effects.*.label", "onAdd", setEffects);
        DB.addHandler("combattracker.list.*.effects.*.label", "onUpdate", setEffects);     
        DB.addHandler("combattracker.list.*.effects.*.isgmonly", "onAdd", setEffects);
        DB.addHandler("combattracker.list.*.effects.*.isgmonly", "onUpdate", setEffects);        
        DB.addHandler("combattracker.list.*.effects.*.isactive", "onAdd", setEffects);
        DB.addHandler("combattracker.list.*.effects.*.isactive", "onUpdate", setEffects);    	       
        DB.addHandler("combattracker.list.*.effects", "onChildUpdate", setEffects);        
    end

    function tokenHover(target,state)
        --Token.onHover(target,state);
        local textWidget;

        if (state == true) then
            local tokenPackage = Token.getToken(target.getContainerNode().getNodeName(), target.getId())
            textWidget = target.getContainerNode().addtextwidget('effects_text');
            --local tokenPackage = token.getToken(token)
    
            local ctEntry = ManagerCombat.getCTFromToken(target);
            local ctActorEntry = ManagerActor.getCTFromToken(target);
            local sEffects = ManagerEffect.getEffectsString(ctEntry, false); -- getEffectsString(nodeCTEntry, bPublicOnly)

            textWidget.setText(sEffects);
            textWidget.isVisible(true);
            textWidget.bringToFront();
        else
            textWidget.destroy();
        end

        Debug.chat('ctEntry', ctEntry, 'ctActorEntry', ctActorEntry, 'sEffects', sEffects);
    end

    function setEffects()
    end