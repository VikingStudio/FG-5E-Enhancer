--[[
    Script stops token rotation on map, while moving scroll button on hovering over token, if menu option set to on.
]]--

function onInit()
    Token.onWheel = noTokenRotation;
end

function noTokenRotation(target, notches)    
    local stopTokenRotate = OptionsManager.getOption('CE_STR'); -- (on|off)
    
    if stopTokenRotate == 'on' then        
         -- orientation of 7, is upright and non rotated, moving to first rotation to the right gives 0, then onwards to 7.
        if (target.getOrientation() ~= 7) then                        
            target.setOrientation(7);            
        end
    end
end