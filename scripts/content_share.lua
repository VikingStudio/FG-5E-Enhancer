--[[
    Script to post spell and ability descriptions into chat.
]]--

function onInit()
    Interface.onWindowOpened = windowCheck;            
end   


function windowCheck(w)
    --Debug.chat('onInit', w.getClass(), w.getDatabaseNode( ))
    if w == nil then return; end    
    
    local class = w.getClass();

    -- note = note, power = spell, ref_ability = freat + feature + trait
    if class == 'note' or class == 'power' or class == 'ref_ability' then
        w.registerMenuItem(Interface.getString("textshare"), "textshare", 5);        
    end

    onMenuSelection = menuAction;    
end
 

function menuAction(selection, subselection, subsubselection)
    --Debug.chat('menu selection', selection, 'class', getClass())
    if selection == 5 then    
        local sMessage = createOutput();
        postChatMessage(sMessage);
    end
end

function createOutput()       
    --Debug.chat('ouputContent: class', getClass(), 'node', getDatabaseNode());
    local class = getClass();
    local node = getDatabaseNode();
    local sMessage;

    -- note or character ability
    --[[ class:
        note = notes
        ref_ability = character feature
        reference_feat = feat
        encounter = story

    ]]--

    -- note entry, class feature, character feat, story entry
    if class == 'note' or class == 'ref_ability' or class == 'reference_feat' or class == 'encounter' then        
        sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('text').getText();
    end

    -- spell power
    if class == 'power' then
        sMessage = node.getChild('name').getText() .. '\rSpell\r\r'
            .. 'Level ' .. node.getChild('level').getText() .. ' ' .. node.getChild('school').getText() .. '\r'
            .. 'Range ' .. node.getChild('range').getText() .. '\r'
            .. 'Components ' .. node.getChild('components').getText() ..  '\r'
            .. 'Duration ' .. node.getChild('duration').getText() .. '\r\r'
            .. node.getChild('description').getText() .. '\r\r'            
            .. 'Source ' .. node.getChild('source').getText();
    end    

    -- NPC CT spell power
    if class == 'ct_power_detail' then        
        sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('desc').getText();
    end        

    -- items in item list
    if class == 'reference_equipment' then                
        sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('description').getText();
    end     

    -- reference manual page
    if class == 'referencemanualpage' then                        
        n = 1;
        local childNode = node .. '.blocks.id-' .. getIdDBString(n);			
        Debug.chat('childNode', childNode)        
        while DB.findNode(childNode) ~= nil do	            
            sMessage = sMessage .. childNode.getChild(text).getText() .. '\r';     
            
            n = n + 1;
            childNode = node .. '.blocks.id-' .. getIdDBString(n);			
        end
    end       

    -- item on character
    if class == 'item' then           
        local type = node.getChild('type').getText();
        Debug.chat('type', type)

        if type == 'Wondrous Item' then
            local isIdentified = node.getChild('isidentified').getNumber();
            if isIdentified == 0 then                 
                sMessage = node.getChild('nonid_name').getText() .. '\r\r' .. node.getChild('nonidentified').getText();
            else                
                sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('description').getText();
            end
        end    
        
        if type == 'Weapon' then            
            sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('subtype').getText() .. '\r' .. node.getChild('damage').getText() .. '\r' .. node.getChild('properties').getText();
        end   
        
        if type == 'Armor' then            
            sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('subtype').getText() .. '\r' .. 'AC: ' ..  node.getChild('ac').getText() .. '\r' .. node.getChild('description').getText();
        end           
        
        if type == 'Adventuring Gear' then            
            sMessage = node.getChild('name').getText() .. '\r\r' .. node.getChild('description').getText();
        end                     
    end            


    return sMessage;    
end

-- post message to chat
-- use: postChatMessage("post this text as a message to chat")
-- pre: no message posted
-- post: if sMessage is not empty, then paste the string to the text chat window with an icon next to it
function postChatMessage(sMessage)        
    if sMessage ~= '' and sMessage ~= nil then
        local chatMessage = {font = "msgfont", icon = "dot_blue", text = sMessage};				
        Comm.deliverChatMessage(chatMessage);		
    end
end


-- returns id-00001 formatted string
-- use local idString = getIdDBString(n);
-- pre: sId = 'id-'
-- post: xml database formatted string, ex: id-00001, id-014255
function getIdDBString(nId)
	local sId = 'id-';

	if nId < 10 then sId = sId .. '0000' .. nId; end
	if nId < 100 and nId >= 10 then sId = sId .. '000' .. nId; end
	if nId < 1000 and nId >= 100 then sId = sId .. '00' .. nId; end
	if nId < 10000 and nId >= 1000 then sId = sId .. '0' .. nId; end
	if nId >= 10000 then sId = sId .. nId; end

	return sId;
end