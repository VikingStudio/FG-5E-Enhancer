# UNDER DEVELOPMENT ALPHA STATE

# FG-5E-Enhancer

A community extension I'm writing to improve D&D 5E in Fantasy Grounds Unity.

## Design Goal

A rewritten minimalist streamlined version of the original 5E Combat Enhancer Classic including a number of broader ranged improvements for playing 5E, written for Fantasy Grounds Unity.

### Prerequisites

You need to have a copy of Fantasy Grounds Unity installed on your computer. 
https://www.fantasygrounds.com/home/home.php


### Installing
    
1) Open the folder "- Extension Files"
Download the latest version of the extension file: "5E-Enhancer v?_?_?.ext"

Contains:
This is the actual extension, it includes the compressed codebase and a number of graphics.

2) Copy this file to your extension folder (example: Fantasy Grounds\Data\extensions\ [place file here] ).

3) Enable the '5E Enhancer v?_?_?' extension for your campaign in Fantasy Grounds.


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

## Acknowledgments

* SmiteWorks rulesystem and API code.

# Menu Options '5E Enhancer, Battle Map Settings'
- Automatic range modifiers: Enable range messages and automatic disadvantage on long ranges.
- Horizontal health bars: Enable horizontal health bars over tokens. 5 options available: Off | Left aligned, default height | Left aligned, taller | Centered, default height | Centered, taller.
- Larger health dots: Enable larger health dots for tokens. 3 options available: FGU Default size | Larger | Largest.
- Show CT active actor underlay (DM only): Toggle to add underlay under CT active actor.
- Show faction/space underlay: Shows or hides the underlay added for tokens faction (friend/foe/neutral). Re-add tokens to update.
- Show reach underlay: Shows or hides the reach underlay added on hover for tokens. Re-add tokens to update.
- Stop token rotation: Stops token rotation as much as possible when mouse wheel is scrolled over token. Tries to reset it as turning straight up on mouse scroll.
- Token underlay opacity (GM only): Select the opacity of the graphical highlight underneath tokens when hovering over items in the combat tracker.

# Menu Options '5E Enhancer, Window Resizing'
- New menu options that enable you to change your default window sizes for a lot of different types.

## Features, Combat
- Delete tokens from map and CT with single mouse click. 
    Alt + left mouse-click on token on map, deletes the token from the map.
    Alt + Ctrl + left mouse-click on token on map, deletes the token from the map and from the CT.
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


## Roadmap
Primary
- Effects as tooltip option on hover over token option.
- On token click, highlight same actor in CT.
Secondary
- Altitude for tokens.
- Save success or fail graphics on target on combat map. Button to clear.

## In the Works
- Remove all blood tokens with button press. 
    If token placed underneath original token, then should be removed with remove all tokens menu.
- Added highlighting of selected token in CT and added frame graphics to accomplish this. (ct_actor_higlighter.lua)

## Things to patch
- Create new larger graphics large health dot and health bar. Are a bit blurred in FGU.

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

v0.6.0 (January, 4th, 2020)
- When an effect is dropped on a target in the CT or on a CT linked token on the map. If that target already has that effect, then it is removed from the target instead. (scripts/token_effects_handler.lua, scripts/helper_functions.lua)

v0.7.0 (January , 23rd, 2020)
- Blood splatters on token when taking damage. Controllable by menu item. 
- Add X or skull or no graphics widget on token death. Controllable by menu item.
- Blood pools on tokens on death. Controllable by menu item.
- Minimized horizontal health bar to 0% health, would go into the negative direction as a grey bar.
- Changeable opacity underlay for active actor. Controllable by menu option.
- Size of active actor underlay either full or half reach. Controllable by menu option.
- Fixed a number of bugs that popped up during use of previous version.
