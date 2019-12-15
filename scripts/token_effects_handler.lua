--[[
    Script for showing a tokens effects in a tooltip on hover.
]] --

--[[
		Related menu items

        <string name="option_label_TGME">GM: Show effects</string>  -> TGME (tooltip|on|hover|mark|markhover)
        <string name="option_label_TNPCE">Player: Show Enemy effects</string> -> TNPCE (tooltip|on|hover|mark|markhover)
        <string name="option_label_TPCE">Player: Show Ally effects</string> -> TPCE (tooltip|on|hover|mark|markhover)

        <string name="option_val_tooltip">Tooltip</string>  -> TNAM (tooltip|on|hover)

        Token function onHover( target, state ) 


    ct_effect.lua

    function onDrop(x, y, draginfo)
        if not User.isHost() then
            return;
        end
        if draginfo.isType("combattrackerentry") then
            EffectManager.setEffectSource(getDatabaseNode(), draginfo.getCustomData());
            return true;
        end
    end        

    --]]

    -- Token.onHover = tokenHover;

    --[[
    DB.addHandler("combattracker.list.*.effects.*.label", "onAdd", setEffects)
    DB.addHandler("combattracker.list.*.effects.*.label", "onUpdate", setEffects)
    DB.addHandler("combattracker.list.*.effects.*.isgmonly", "onAdd", setEffects)
    DB.addHandler("combattracker.list.*.effects.*.isgmonly", "onUpdate", setEffects)
    DB.addHandler("combattracker.list.*.effects.*.isactive", "onAdd", setEffects)
    DB.addHandler("combattracker.list.*.effects.*.isactive", "onUpdate", setEffects)
    DB.addHandler("combattracker.list.*.effects", "onChildUpdate", setEffects)
    --]]



    --[[
        PSEUDOCODE / STEPS

        on item drop on token
        get content
        if effect, get text content and put in string
        get CT entry for token
        get list of effects in array
        iterate through array, comparing text string of effect, to dropped text string of effect
        if equal text string found in array, then remove it from the CT entry of effect for NPC/PC entry
        exit loop
    ]]--

function onInit()		
    addEffectOriginal = EffectManager.addEffect;
    EffectManager.addEffect = addEffectDuplicateCheck;	
end

function addEffectDuplicateCheck(sUser, sIdentity, nodeCT, rNewEffect, bShowMsg)
    local effectsConcatTable = EffectManager.getEffectsString(nodeCT, true);

    local sNewEffectName = getTrimmedEffectName(rNewEffect.sName);    
    local effectsTable = Helper.split3(effectsConcatTable,'|');

    -- look for duplicate effect on actor
    for index, value in ipairs(effectsTable) do    
        local sValueName = getTrimmedEffectName(value);
        Debug.chat('compare', sValueName, string.len( sValueName ), sNewEffectName, string.len( sNewEffectName ));

        if ( sValueName == sNewEffectName ) then
            Debug.chat('match found')
            removeEffect(nodeCT, sValueName);
            return;
        end
    end

    -- if no duplicate found while running hte loop above, add new effect
    addEffectOriginal(sUser, sIdentity, nodeCT, rNewEffect, bShowMsg);
end

-- gets name of effect and trims off whitespaces at the start and end of string
function getTrimmedEffectName (str)
    str = Helper.getEffectName(str);
    str = Helper.removeOuterWhiteSpaces(str);

    return str;
end

function removeEffect(nodeCTEntry, sEffPatternToRemove)    
	if not sEffPatternToRemove then
		return;
	end
    for _,nodeEffect in pairs(DB.getChildren(nodeCTEntry, "effects")) do
        
        -- Debug.chat('db search', sEffPatternToRemove, nodeEffect, DB.getValue(nodeEffect, "label", ""), DB.getValue(nodeEffect, "label", ""):match(sEffPatternToRemove));
		if DB.getValue(nodeEffect, "label", ""):match(sEffPatternToRemove) then
			nodeEffect.delete();
			return;
		end
	end
end


function tokenHover(target, state)
    --Token.onHover(target,state);
    local textWidget

    if (state == true) then
        local tokenPackage = Token.getToken(target.getContainerNode().getNodeName(), target.getId())
        textWidget = target.getContainerNode().addtextwidget("effects_text")
        --local tokenPackage = token.getToken(token)

        local ctEntry = ManagerCombat.getCTFromToken(target)
        local ctActorEntry = ManagerActor.getCTFromToken(target)
        local sEffects = ManagerEffect.getEffectsString(ctEntry, false) -- getEffectsString(nodeCTEntry, bPublicOnly)

        textWidget.setText(sEffects)
        textWidget.isVisible(true)
        textWidget.bringToFront()
    else
        textWidget.destroy()
    end

    Debug.chat("ctEntry", ctEntry, "ctActorEntry", ctActorEntry, "sEffects", sEffects)
end

function setEffects()
end
