--[[
    Generic helper functions for the extension
]]--

-- post message to chat
-- use: postChatMessage("post this text as a message to chat")
-- pre: no message posted
-- post: if sMessage is not empty, then paste the string to the text chat window with an icon next to it
function postChatMessage(sMessage, sType)    
    if sMessage ~= '' and sMessage ~= nil then
        local chatMessage = '';

        if sType == 'rangedAttack' then        			
            chatMessage = {font = "msgfont", icon = "ranged_attack_1", text = sMessage};	
        else
            chatMessage = {font = "msgfont", icon = "roll_effect", text = sMessage};	
        end

        Comm.deliverChatMessage(chatMessage);		
    end
end

-- rounds up to next integer for n >=.5 and down at n < .5
-- use: round(number)
-- pre: -
-- post: returns next whole integer rounded to 
function round(n)    
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n);        
end