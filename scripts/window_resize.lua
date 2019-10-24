function onInit() 
    Interface.onWindowOpened = windowResize;
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