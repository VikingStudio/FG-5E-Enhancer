--[[
    Script to add blood pools/splatter under tokens on actor death.					
]]--

function addBloodPool(tokenCT)
    Debug.chat('blood pool called', tokenCT)

    local randomImage = math.random(10); -- return 1-10    
    local bloodPoolName = 'blood_pool_' .. randomImage;



    -- as token
    local tokenWidth, tokenHeight = tokenCT.getImageSize();
    local tokenImageScale = tokenCT.getScale();

    -- get image window container and add token underneath actor token
    ctrlImage, windowInstance, bWindowOpened = ImageManager.getImageControl(tokenCT, false);
    -- Debug.chat('window container', ctrlImage, windowInstance, bWindowOpened)

    local tokenContainer = tokenCT.getContainerNode();
    local tokenX, tokenY = tokenCT.getPosition();
    -- local imageControl = tokenContainer;
    if (ctrlImage == nil) then
        return;
    end

    local bloodToken = ctrlImage.addToken(bloodPoolName, tokenX + 200, tokenY + 200);
    Debug.chat('bloodToken', bloodToken, bloodPoolName)

    -- randomize token size
    local sizeMultiplier = math.random() * 2 + 0.1;  -- math.random() returns number between 0 and 1
    local baseTokenSize = tokenWidth * tokenImageScale;
    -- bloodToken.setSize(baseTokenSize * sizeMultiplier, baseTokenSize * sizeMultiplier);

    local size = resizeForOriginalTokenSize(tokenCT);
    bloodToken.setSize(tokenWidth * tokenImageScale, tokenHeight * tokenImageScale);

    -- randomize token orientation
    local rotation = math.random(360); -- math.random(360) returns a number between 1 and 360    
    bloodToken.setOrientation(rotation);
    

    -- as widget
    --[[
    local bloodPool = tokenCT.addBitmapWidget(bloodPoolName);
    bloodPool.sendToBack();
    bloodPool.setName("blood_pool");	
    bloodPool.setVisible(true);
    bloodPool.setPosition("center", 0, 0);
    bloodPool.setSize(baseTokenSize * sizeMultiplier, baseTokenSize * sizeMultiplier);
    ]]--    
end

-- resizes condition art to span token size
function resizeForOriginalTokenSize(tokenCT)
    local baseSize = 80;
    local sSize = Helper.getActorSize(tokenCT);

    
    -- shift location based on size of actor
    if (sSize == 'Large') then 
        return baseSize * 2;
    elseif (sSize == 'Huge') then 
        return baseSize * 3;
    elseif (sSize == 'Gargantuan') then 
        return baseSize * 4;
    else
        return baseSize;
    end
end