--[[
    Generic helper functions for the extension
]] --

-- Global Constants --

-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
-- The opacity is set to 20% by default, but is now modifiable on the fly in the Settings menu.
-- You can change the three colors here by changing the 6 characters after the first 2 (the alpha channel).
TOKENUNDERLAYCOLOR_1 = "3300FF00" -- Tokens active turn.
TOKENUNDERLAYCOLOR_2 = "33F9FF44" -- Token added to battlemap, but not on combat tracker.
TOKENUNDERLAYCOLOR_3 = "330000FF" -- Token mouse over hover.

function onInit()
	updateUnderlayOpacity()
	DB.addHandler("options.CE_UOP", "onUpdate", updateUnderlayOpacity)
end

-- post message to chat
-- use: postChatMessage("post this text as a message to chat")
-- pre: no message posted
-- post: if sMessage is not empty, then paste the string to the text chat window with an icon next to it
function postChatMessage(sMessage, sType)
	if sMessage ~= "" and sMessage ~= nil then
		local chatMessage = ""

		if sType == "rangedAttack" then
			chatMessage = {font = "msgfont", icon = "ranged_attack_1", text = sMessage}
		else
			chatMessage = {font = "msgfont", icon = "roll_effect", text = sMessage}
		end

		Comm.deliverChatMessage(chatMessage)
	end
end

-- rounds up to next integer for n >=.5 and down at n < .5
-- use: round(number)
-- pre: -
-- post: returns next whole integer rounded to
function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

-- changes the FM token underlay opacity to reflect selection in Settings menu
function updateUnderlayOpacity()
	local opacitySetting = OptionsManager.getOption("CE_UOP")

	-- if no setting is found, return the 20% opacity settubg as it's the default
	if (opacitySetting == nil) or (opacitySetting == "") then
		opacitySetting = "option_val_20"
	end

	-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
	-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
	local hexAlphaTable = {
		["option_val_100"] = "FF",
		["option_val_90"] = "E6",
		["option_val_80"] = "CC",
		["option_val_70"] = "B3",
		["option_val_60"] = "99",
		["option_val_50"] = "80",
		["option_val_40"] = "66",
		["option_val_30"] = "4D",
		["option_val_20"] = "33",
		["option_val_10"] = "1A"
	}

	-- replace alpha channel with new setting (first two characters)
	TOKENUNDERLAYCOLOR_1 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_1, 3)
	TOKENUNDERLAYCOLOR_2 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_2, 3)
	TOKENUNDERLAYCOLOR_3 = hexAlphaTable[opacitySetting] .. string.sub(TOKENUNDERLAYCOLOR_3, 3)
end

-- pass in string and pattern to split by, returns a table
function split(string, splitLetter)
	local splitTable = {}; -- NOTE: use {n = 0} in Lua-5.0
	local s, e, cap = string:find(splitLetter, 1);

	while s do
		if (s ~= 1 or cap ~= "") then
			table.insert(splitTable, cap);
		end

		s, e, cap = string:find(splitLetter, e);
	end
	 --

	--[[
	if (last_end <= #string) then
	   cap = str:sub(last_end);
	   table.insert(splitTable, cap);
	end
   ]] 
   
   return splitTable;
end

-- pass in string and pattern to split by, returns a table
function split2(str, pat)
	local t = {} -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)

	while s do
		if (s ~= 1 or cap ~= "") then
			table.insert(t, cap)
		end

		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end

	if (last_end <= #str) then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end

	return t
end

function split3 (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end

	local t={};
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end

	return t;
end

-- remove whitespace at start and end of string
function removeOuterWhiteSpaces (str)
	-- str = str:match("^%s*(.+)%s*$");
	str = str:match( "^%s*(.-)%s*$" );

	--[[
	str = " \t \r \n String with spaces  \t  \r  \n  "
	print( string.format( "Leading whitespace removed: %s", str:match( "^%s*(.+)" ) ) )
	print( string.format( "Trailing whitespace removed: %s", str:match( "(.-)%s*$" ) ) )
	print( string.format( "Leading and trailing whitespace removed: %s", str:match( "^%s*(.-)%s*$" ) ) )
	]]--

	return str;
end



-- returns effect name from effect string
function getEffectName (str)
	local ruleset = getRuleset();
	--Debug.chat('ruleset', ruleset);

	-- if DnD 5E
	if (ruleset == "CoreRPG") then
		str = str:match("[^;]*");
	end

	-- if DnD 5E
	if (ruleset == "5E") then
		str = str:match("[^;]*");
	end

	-- if SWADE
	if (ruleset == "SavageWorlds") then
		str = str:match("[^[]*");
	end

	return str;
end

-- returns the ruleset name
-- ex.: CoreRPG, 5E, SavageWorlds
function getRuleset ()
	local ruleset = User.getRulesetName();
	
	return ruleset;
end

-- returns the text describing the size of the token, possible sizes: Tiny, Small, Medium, Large, Huge, Gargantuan
function getActorSize(tokenCT)
	local ctEntry = CombatManager.getCTFromToken(tokenCT);	
	local actor = ActorManager.getActorFromCT(ctEntry);	

	local dbPath = DB.getPath(actor.sCreatureNode, 'size');
	local sSize = DB.getText(dbPath);

	return sSize;
end


-- resizes condition art to span token size
-- scaling is an optional parameter, if nil set to 1
function resizeForTokenSize(tokenCT, widget, scaling)
	if (scaling == nil) then scaling = 1; end
    local baseSize = 80;
    local sSize = getActorSize(tokenCT);
    
	-- change size depending on token size description
	if (sSize == 'Tiny') or (sSize == 'Small') then
		widget.setSize(baseSize * 0.5 * scaling, baseSize * 0.5 * scaling);
    elseif (sSize == 'Large') then 
        widget.setSize(baseSize * 2 * scaling, baseSize * 2 * scaling);
    elseif (sSize == 'Huge') then 
        widget.setSize(baseSize * 3 * scaling, baseSize * 3 * scaling);
    elseif (sSize == 'Gargantuan') then 
        widget.setSize(baseSize * 4 * scaling, baseSize * 4 * scaling);
    else
        widget.setSize(baseSize * scaling, baseSize * scaling);
    end
end