--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.


-- Global Constants --

-- Underlay colors for tokens on the map. First two numbers/letters refer to the alpha channel or transparency levels.
-- Alpha channel (ranging from 0-255) in hex, opacity at 40% = 66, 30% = 4D , 20% = 33, 10% = 1A.
-- The opacity is set to 20% by default, but is now modifiable on the fly in the Settings menu.
-- You can change the three colors here by changing the 6 characters after the first 2 (the alpha channel).
TOKENUNDERLAYCOLOR_1 = "3300FF00"; -- Tokens active turn. 
TOKENUNDERLAYCOLOR_2 = "33F9FF44"; -- Token added to battlemap, but not on combat tracker.
TOKENUNDERLAYCOLOR_3 = "330000FF"; -- Token mouse over hover.
