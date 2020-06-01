# FG-5E-Enhancer

A community extension I'm writing to improve D&D 5E in Fantasy Grounds Unity.

## Design Goal

A rewritten minimalist streamlined version of the original 5E Combat Enhancer Classic including a number of broader ranged improvements for playing 5E, written for Fantasy Grounds Unity.

This extension is not intended for backwards compatibility with FGC. While some features may work, others may not or not as intended. There is no testing done or support for its use in FGC.

While one of the design goals is to have a small as possible footprint. This extension is very large and complex, and therefore touches on numerous functionalities.
I am not able to put extra work into making sure it is compatible with other extensions, doing so would become an endless task and the extension already does and has taken countless of hours to develop.


### Prerequisites

You need to have a copy of Fantasy Grounds Unity installed on your computer. 
https://www.fantasygrounds.com/home/home.php


### Installing
    
1) Open the folder "- Extension files (main extension)"
Download the latest version of the extension file: "5E-Enhancer v?_?_?.ext"

Contains:
This is the actual extension, it includes the compressed codebase and a number of graphics.

2) Copy this file to your extension folder (example: Fantasy Grounds\Data\extensions\ [place file here] ).

3) Enable the '5E Enhancer v?_?_?' extension for your campaign in Fantasy Grounds.

### Installing (optional individual sub-extensions)

Parts of the whole extensions functionality has been cropped out into smaller sub-extensions. 
So if you don't want to use the whole extension but want some of its functionality, then you can download any or all of these for use with FG, and use them individually instead.

Special thanks to ScriedRaven on the FG forums who contributed these to the project from the original code, and fall under the original private license.

ps. These extensions are not officially supported, only the main extension is.


To install sub-extensions:

1) Open the folder "- Extension files (sub-extensions)"

2) Copy any or all of these .ext files to your extension folder (example: Fantasy Grounds\Data\extensions\ [place file here] ).

3) Enable the extensions for your campaign in Fantasy Grounds.


Conflicts: Flanking works on it's own, but conflicts with the wounds extension.

## Built With

* [LUA](https://www.lua.org/) - Lua is a powerful, efficient, lightweight, embeddable scripting language. It supports procedural programming, object-oriented programming, functional programming, data-driven programming, and data description. 
* [XML](https://www.w3.org/TR/REC-xml/) - Extensible Markup Language (XML) 1.0 (Fifth Edition)
* [FG API](https://www.fantasygrounds.com/refdoc/) - Fantasy Grounds API as created by SmiteWorks.

## Versioning

I use [SemVer](http://semver.org/) for versioning, with version number MAJOR.MINOR.PATCH, increments.

## Authors

* **Styrmir Thorarinsson** - *All Work* - [Styrmir Thorarinsson](https://github.com/StyrmirThorarins)

## License

This project is licensed under private License - see the [LICENSE.md](LICENSE.md) file for details.
The license is held by Styrmir Thorarinsson and some proprietary code supplied by SmiteWorks.

This license extends to all use or inspiration of the whole or part of its work and code.

This license overrides any licences written or supplied with any sub-extensions or code derived from this project.

## Acknowledgments

* SmiteWorks rulesystem and API code.

# Menu Options '5E Enhancer, Battle Map Settings'
- Actor health widget conditions: Enable widgets on tokens that indicate their health, such as blood skulls.
- Automatic range modifiers: Enable range messages and automatic disadvantage on long ranges.
- Blood on tokens: Draw blood marks on tokens as their health deteriorates.
- Blood pools on death: Draw blood pools underneath tokens on death.
- Horizontal health bars: Enable horizontal health bars over tokens. 5 options available: Off | Left aligned, default height | Left aligned, taller | Centered, default height | Centered, taller.
- Larger health dots: Enable larger health dots for tokens. 3 options available: FGU Default size | Larger | Largest.
- Lock token rotation to Alt + Mouse Wheel: With this enabled the tokens only rotate if you're holding down the alt button while scrolling the mouse wheel over them. 
- Range rules to use: Select how to calculate ranges for automatic range modifiers. Standard, the default recommended. Actual pixel distance between the edges of the boxes surrounding the tokens divided by 5 for the width of the hexes you've set. RAW, rules as written, not tested fully.
Ranged in melee modifier (for medium sizes and smaller only): When enabled it adds a disadvantage for ranged attacks while there is an active enemy in melee range, if the attacker does not have the crossbow feat.
- Saving throw graphics: Adds saving grapical indicators for if a target succeeds of fails a saving throw. (use '/dsave' in the chat to delete these markers afterwards)
- Show faction/space underlay: Shows or hides the underlay added for tokens faction (friend/foe/neutral)
- Skipt CT actors that haven't rolled initiative: When enabled the CT will skip entries in the CT, without rolled initiatives or initiatives of 0, when the Next Actor / End Turn button is pressed.
- Skull or cross on actor death: Select the graphic to display on a token on your map when the actor drops to 0 hp's. Actor health widgets need to be enabled.
- Token deletion button combination: Select the button and mouse button combination to use for deleting tokens from the map and the CT. Added for mac users as it was easy to accidentally delete tokens with the default PC configuration.
- Token height font size: Determines the size of the fonts to use when drawing height widgets on tokens.
- Token underlay for CT active actor (DM only): Draws only the underlay of the active token on the map, clears all others. Re-add tokens to refresh. While this option is on it will remove all underlays and reach drawings for all tokens. Only the active token will get an underlay to highlight them for the DM.
- Token underlay opacity (DM only): Select the opacity of token underlays.
- Token underlay size (DM only): Select the size of the token underlay to draw.
- Use flanking rules (for medium sizes and smaller only): If enabled automatically adds the modifier you select to flanking attacks to mediums sized and smaller targets. Also considers height differences of the tokens.

# Menu Options '5E Enhancer, Window Resizing'
- New menu options that enable you to change your default window sizes for a lot of different types.

## Chat Macro Commands

- /dsave : delete save graphics from all tokens

## Features, Combat
- Delete tokens from map and CT with single mouse click. 
    Alt + left mouse-click on token on map, deletes the token from the map.
    Alt + Ctrl + left mouse-click on token on map, deletes the token from the map and from the CT.
- Add height widget to a token (DM only).
    Shift + mouse scroll on top of token.    
- Horizontal health bars, lightly transparent. Toggable in menu. Select health for tokens to be displayed as bars, select 'Combat Enhancer 5E > Horizontal health bars > On'. Add token from CT for new health bar.
- Larger health dot graphics for tokens. Toggable in menu. Add token from CT for new health dot.
- Automatic range finding from ranged attack. Toggable in menu. Disadvantage for medium to max range added automatically, sharpshooter feat negates this. Message output to chat.
- 'Reach underlay' and 'Faction/space underlay' made as toggle switches in the menu items. Re-add tokens to update.
- Active actor on CT token underlay made as toggle switches in the menu items. Clears all other underlays than the current actor.
- When an effect is dropped on a target in the CT or on a CT linked token on the map. If that target already has that effect, then it is removed from the target instead.    
- Changeable opacity underlay for active actor. Controllable by menu item. 
- Size of active actor underlay either full or half reach. Controllable by menu item.
- Blood splatters on token when taking damage. Controllable by menu item. 
- Blood pools on tokens on death. Controllable by menu item.
- Add X or skull or no graphics onto token on death. Controllable by menu item.

## Features, Interface
- Content Share, allows you and your players to right click on spells, character feats, features and traits and post the descriptive text directly to the chat text by selecting the new 'Post Text in Chat' menu option at the bottom.
- New menu options in your settings, under 'Window Resizer 5E'.
    Set as default window sizes on activation. But you can enable larger windows for any or all windows from the window menu.
    Resizes windows on the fly to whatever setting you choose.
    You can return to the default window sizes at any time.
    If a window has been resized manually and is therefore in the 'windowstate.xml' file of your campaign, that takes precedence over the extension. This enables you to manually configure any windows you'd like.

## Chat Commands
/dsave : Clears save graphics from all tokens. Short for delete save/s.




## Releases
v0.1.0 (September, 17th, 2019)  
Alpha version of 5E Enhancer. Not for general use, a number of features added and working fully or partially. A number of features still at alpha development phase.
- Content to text area share added with right-mouse click.
- Deletion of tokens with mouse click on map.
- Partial working horizontal health bars.
- Partial working larger health dots.
- Working automatic 2D range finding from ranged weapon or spell attacks. Adds disadvantage if attacks outside short range and not sharpshooter feat.
- Number of new graphics added.
- A lot of code refactoring and project organizing.
-- Breaking up of code into different .lua files where each handles very specific functionality.
-- Seperating and decoupling of code from SmiteWorks code base (5E ruleset and CoreRPG ruleset) whenever possible, for easier maintenance and clearer code, and future update proofing against ruleset updates.
-- General code cleanup.

v0.2.0 (October 15th, 2019) 
- Added 'manager_token.lua' from CoreRPG ruleset.
- 'Reach underlay' and 'Faction/space underlay' made as toggle switches in the menu items. (scripts/manager_token.lua: updateSizeHelper)
- Rewriting of horizontal health bars code, seamlessly integrated to run from manager_token.lua with minimal extra code in that ruleset file. Horizontal health bars now work flawlessly. (scripts/health_graphics.lua: drawHorizontalHealthBar, updateHealthBarScale | scripts/manager_token.lua: updateHealthHelper)
- Added menu option to toggle for default or larger health dots.
- Added larger health dots. (scripts/health_graphics.lua: drawLargerHealthDot | scripts/manager_token.lua: updateHealthHelper)

v0.3.1 (October 15th, 2019) 
- Fixed horizontal health bar scaling on token resize. (scripts/manager_token.lua: onScaleChanged)
- Added menu option to display and underlay under tokens on the map that are active in the combat tracker. Clears all other underlays than the current actor. (scrips/token_highlighter.lua | manager_token.lua: updateActiveHelper)

v0.3.2 (October 24th, 2019)
- Added code for window resizing. (scripts/window_resize.lua)
- Added menu items for window resizing. (5E Enhancer, Window Resizing)
- Changed menu name for battle map menu options for the extension, from '5E Enhancer' to '5E Enhancer, Battle Map Settings'.

=====================================
FGU Beta release (October 28th, 2019)
=====================================

v0.3.3 (October 30th, 2019)
- Bug: Missing element error message in Unity console. Fixed. Removed reference to missing element, "graphics/graphics_radial.xml" in extension.xml.
- Removed debug messages to chat for "Post Text in Chat". (scripts/content_share.lua)
- Larger health dot resized and repositioned. (scripts/health_graphics.lua: drawLargerHealthDot)
- Horizontal health bar resized and repositioned. (scripts/health_graphics.lua: updateHealthBarScale)

v0.4.0 (November 23rd, 2019)
- Added more menu option alternatives for 'Horizontal health bars'. 5 options available: Off | Left aligned, default height | Left aligned, taller | Centered, default height | Centered, taller.(scripts/health_graphics.lua: updateHealthBarScale)
- Rewriting of horizontal health bar scaling code. (scripts/health_graphics.lua: updateHealthBarScale)
- Added more menu option alternatives for 'Large health dots, settings'. 3 options available: FGU Default size | Larger | Largest. (scripts/health_graphics.lua: drawLargerHealthDot)
- Rewriting of larger health dot scaling code. (scripts/health_graphics.lua: drawLargerHealthDot)
- Maximum health dot size defined. (scripts/health_graphics.lua: drawLargerHealthDot)
- Removed all references for ruleset icons, only extension ones left. (graphics/graphics_icons.xml)
- Fixed missing folder from save graphics reference path. (graphics/graphics_icons.xml)

v0.5.0 (December 29th, 2019)
- Rewrote range finding code. It will now be the same as the range on the target arrow, as long as both tokens are inside a grid box. (scripts/automatic_range_modifier/range_finder.lua: getRange | scripts/ranged_attack_modifier.lua: getRangeModifier5e)
- Some changes to output text for ranged attacks. (scripts/ranged_attack_modifier.lua: getRangeModifier5e)
- Token health widget scaling for different grid and actor sizes fixed. Uses CT actor size descriptor text (tiny/small/medium/large/huge/gargantuan) to determine horizontal health bar width. (scripts/health_graphics.lua)

v0.6.0 (January 4th, 2020)
- When an effect is dropped on a target in the CT or on a CT linked token on the map. If that target already has that effect, then it is removed from the target instead. (scripts/token_effects_handler.lua, scripts/helper_functions.lua)

v0.7.0 (January 23rd, 2020)
- Blood splatters on token when taking damage. Controllable by menu item. 
- Add X or skull or no graphics widget on token death. Controllable by menu item.
- Blood pools on tokens on death. Controllable by menu item.
- Minimized horizontal health bar to 0% health, would go into the negative direction as a grey bar.
- Changeable opacity underlay for active actor. Controllable by menu option.
- Size of active actor underlay either full or half reach. Controllable by menu option.
- Fixed a number of bugs that popped up during use of previous version.

v0.7.1 (February 22nd, 2020)
- Fixed bug for when spell entries were added under actions (rather than spell section) for NPCs' in the DB. This would cause the automatic range finding logic not to work.

v0.8.0 (April 1st, 2020)
- Added flanking and menu options to configure (Adv/+1/+2/+5). Only works for medium or smaller targets and attackers.
- Added menu options to switch between key combination of "Alt + L-Click" or "Shift + Alt + L-Click", for deleting tokens from map.
- Added exit clause for automatic ranged weapon attacks from PC sheets, for non-standardized range entries.

v0.9.0 (April 14th, 2020)
- Altitude widget added on token when Shift + Scroll wheel over token.
- Altitude added to calculations of range for automatic range modifiers functionality.
- Altitude differences considered for automatic flanking. Only for medium or smaller sized combatants.
- Disadvantage added for ranged attacks in melee. Menu option toggle added.
- Menu option added to lock token rotation to only rotate when holding down Alt + Scroll mouse wheel. Removed general token lock option as this takes its place.
- Added menu option to skip actors in CT that haven't rolled initiative.
- Added menu switch to select ruleset to use for automatic range calculations. Standard | Variant (placeholder only) | RAW (Rules as Written)
- Prepared spell buttons for NPC's were off frame in CT. Fixed.
- Max range for weapons not read for automatic range attack modifiers. Fixed. 

V0.9.1 (April 20th, 2020)
- Added rescaling of token when Ctrl + Scroll wheel over token. Note: After rescaling drop token on map again to redraw all widgets to scale.
- Skipping actors in CT that haven't rolled initiative option, did not skip Friendly actors. Fixed.
- If damage was enough to instantly kill a target no death graphic (skull / cross) would appear. Fixed.
- If target already dead took damage again, the death graphic (skull / cross) would dissapear. Fixed.

v0.10.0 (May 18, 2020)
- Decreased code footprint:
Removed manager_combat.lua, created new overriding lua file for functions overridden.
Removed manager_token.lua, created new overriding lua file for functions overridden.
- Add saving throw result graphics on tokens.
- Added new text chat command to delete save graphics from all tokens. '/dsave' short for delete save/s. Menu item switch added.
- Automatic modifier for ranged attacks in melee only triggered when the target was is in melee. Added trigger for other active enemy (medium sized or smaller) when in melee range during attack. Crossbow expert exception included.
- Added exception for automatic range modifiers when spells have no readable maximum range (due to on-standard entry), then the function is exited instead of throwing an error. Text message output to chat and console.
- Height widgets didn't transfer between clients when added, only visible and used for range calculations on the client that added it. Fixed.
- Height only changeable by DM.
- Height widget didn't delete on 0 height. Fixed.
- Added load order.
- Under certain map circumstances the Token.onWheel function would not be passed a token. Added exit clause to handle that null reference.
- Resizing images if not of equal horizontal and vertical sizes would behave strangely. Fixed.
- A number of small errors cleaned up.

v0.10.1 (25th May, 2020)
- Slightly decreased height of certain window sizes when set to larger with the window resizer.
- Automatic flanking modifier if +1, +2, +5 would overwrite any other modifiers in place. Fixed.
- Added further descriptive to chat output for automatic flanking, to add clarity to modifiers seen in output.
- If a token had height, when flanking modifiers were enabled, sometimes this would cause an error, stopping the attack. Fixed.
- Modifying and adding height with shift + mouse wheel scroll, behaved a bit erratically at times. Fixed.
- Updated the readme file to included information about all the new menu items, macro- and keyboard mouse combination commands.

v0.10.2 (1st Jun, 2020)
- Removed RAW option for automatic range finding as it wasn't working properly.
- Increased amount of abilities limit when checking for feats on PC's.
- Ranged attacks in melee for PC's with the Crossbow feat were rolling at a disadvantage. Fixed.
- Special NPC attacks including a recharge were differently named in DB entry name compared to CT parsed attack name. Added additional lua string pattern matching to DB entry name comparison to overcome this. Now works. ps. Rolling the same attack from the NPC window would work as name correlated to the DB entry then.
- Underlay switching to active actor (for DM) when turned on was not working. Fixed.
- The 'Token underlay opacity' menu setting will now also affect the opacity of underlays drawn using the 'Show faction/underlay' menu option instead of 'Underlay switching for active actor...' menu option.

v0.10.3 (- Jun, 2020)
-


Ideas for future versions.
- Add map pinging, Ctrl + L-Click on map.
- Add death save functionality for NPCs.
- Update range number by drawn range arrow with extension calculated ranges (including for height).


Bug reports:
Effects in brackets don't get removed when it's dropped on the same target again, unlike regular text string ones.