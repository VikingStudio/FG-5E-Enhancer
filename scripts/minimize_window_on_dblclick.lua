--[[
windowcontroller
function onDoubleClick( x, y )

This function is called when the left mouse button is pressed down twice in succession on the control. Note that if this function is present and returns nil, the onClickDown function is called as well.

Parameters
x   (number)   
The X coordinate relative to the top left corner of the control
y   (number)   
The Y coordinate relative to the top left corner of the control

Return values
(boolean)
This function should return true if it handled the event and the processing of the event should be stopped. A value of false indicates that the default framework functionality for the this particular control should not be executed, but the processing should continue for the element below this control, if any. A return value of nil (or the absence of a return statement) indicates that the framework should continue handling the event normally. 
]]--

function onInit() 
    --Interface.onWindowOpened = windowResize;
    -- windowcontrol.onDoubleClick = checkForMinmize;
end

function checkForMinmize(x,y)
    Debug.chat('checkForMinmize', x, y);
end


-- If  there is an entry in windowstate.xml then windw.setSize will not run, as windowstate.xml has higher priority.
function windowResize(window)
    local wClass = window.getClass();

    --Debug.chat('Window opened:', window, wClass);

    -- background window (original 350x350)
    if (wClass == 'reference_background') then
        local menuSelection = OptionsManager.getOption('IM_BG'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end  
    
    -- class window (original 350x350)
    if (wClass == 'reference_class') then
        local menuSelection = OptionsManager.getOption('IM_CLASS'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(500, 750);
        end                    
    end     

    -- CT NPC power entry (original 300x300)
    if (wClass == 'ct_power_detail') then
        local menuSelection = OptionsManager.getOption('IM_NPCPOWER'); 

        if (menuSelection == 'option_default') then
            window.setSize(300, 300);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(400, 300);
        end        
    end

    -- feat window (original 350x350)
    if (wClass == 'reference_feat') then
        local menuSelection = OptionsManager.getOption('IM_FEAT'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end       

    -- item window (original 350x350)
    if (wClass == 'reference_equipment') then
        local menuSelection = OptionsManager.getOption('IM_ITEM'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end    

    -- note window (original 350x350)
    if (wClass == 'note') then
        local menuSelection = OptionsManager.getOption('IM_NOTE'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(500, 750);
        end                    
    end   

    -- NPC window (original 460x550)
    if (wClass == 'reference_npc') then
        local menuSelection = OptionsManager.getOption('IM_NPC'); 

        if (menuSelection == 'option_default') then
            window.setSize(460, 550);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(550, 650);
        end                    
    end   

    -- PC abilities (feats, features) (original 350x350)
    if (wClass == 'ref_ability') then
        local menuSelection = OptionsManager.getOption('IM_PCA'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end      

    -- race window (original 350x350)
    if (wClass == 'reference_race') then
        local menuSelection = OptionsManager.getOption('IM_RACE'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(500, 750);
        end                    
    end   

    -- skill window (original 350x350)
    if (wClass == 'reference_skill') then
        local menuSelection = OptionsManager.getOption('IM_SKILL'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end   

    -- Story window (original 400x650)
    if (wClass == 'encounter') then
        local menuSelection = OptionsManager.getOption('IM_STORY'); 

        if (menuSelection == 'option_default') then
            window.setSize(400, 650);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(500, 750);
        end                    
    end        

    -- spell window (original 350x350)
    if (wClass == 'power') then
        local menuSelection = OptionsManager.getOption('IM_SPELL'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(450, 350);
        end                    
    end
    
    -- Quest (original 350x350)
    if (wClass == 'quest') then
        local menuSelection = OptionsManager.getOption('IM_QUEST'); 

        if (menuSelection == 'option_default') then
            window.setSize(350, 350);
        end

        if (menuSelection == 'option_larger') then
            window.setSize(500, 750);
        end                    
    end       
end