# UNDER DEVELOPMENT ALPHA STATE

# FG-5E-Enhancer

A community extension I'm writing to improve a number of D&D 5E features in Fantasy Grounds Unity.

## Design Goal

A minimalist streamlined version of the original Combat Enhancer Classic including numerous broader ranged improvement for playing 5E, written for Fantasy Grounds Unity.

### Prerequisites

You need to have a copy of Fantasy Grounds installed on your computer. 
https://www.fantasygrounds.com/home/home.php


### Installing
    
Open the folder "- Extension Files"
      
Extension file: "5E-Enhancer v?_?_?.ext"

Includes: 
    This is the actual extension, it includes the compressed codebase and a number of graphics.

Where to place:
    Copy this file to your extension folder (example: Fantasy Grounds\Data\extensions\ [place file here] ).


## Built With

* [LUA](https://www.lua.org/) - Lua is a powerful, efficient, lightweight, embeddable scripting language. It supports procedural programming, object-oriented programming, functional programming, data-driven programming, and data description. 
* [XML](https://www.w3.org/TR/REC-xml/) - Extensible Markup Language (XML) 1.0 (Fifth Edition)
* [FG API](https://www.fantasygrounds.com/refdoc/) - Fantasy Grounds API as created by SmiteWorks.

## Versioning

I use [SemVer](http://semver.org/) for versioning, with version number MAJOR.MINOR.PATCH, increments.

## Authors

* **Styrmir Thorarinsson** - *All Work* - [Styrmir Thorarinsson](https://github.com/StyrmirThorarins)

## License

This project is licensed under private License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* SmiteWorks rulesystem and API code.

## Menu Options '5E Enhancer'
- Automatic range modifiers: Enable range messages and automatic disadvantage on long ranges.
- Horizontal health bars: Enable horizontal health bars over tokens.
- Larger health dots: Enable larger health dots for tokens.
- Show CT active actor underlay (DM only): Toggle to add underlay under CT active actor.
- Show faction/space underlay: Shows or hides the underlay added for tokens faction (friend/foe/neutral). Re-add tokens to update.
- Show reach underlay: Shows or hides the reach underlay added on hover for tokens. Re-add tokens to update.
- Stop token rotation: Stops token rotation as much as possible when mouse wheel is scrolled over token. Tries to reset it as turning straight up on mouse scroll.
- Token height font size: Size of height widget text on top of tokens.
- Token underlay opacity (GM only): Select the opacity of the graphical highlight underneath tokens when hovering over items in the combat tracker.

## Features
- Content Share, allows you and your players to right click on spells, character feats, features and traits and post the descriptive text directly to the chat text by selecting the new 'Post Text in Chat' menu option at the bottom.
- Delete tokens from map and CT with single mouse click. 
    Alt + left mouse-click on token on map, deletes the token from the map.
    Alt + Ctrl + left mouse-click on token on map, deletes the token from the map and from the CT.
- Horizontal health bars, lightly transparent. Toggable in menu. Select health for tokens to be displayed as bars, select 'Combat Enhancer 5E > Horizontal health bars > On'. Add token from CT for new health bar.
- Larger health dot graphics for tokens. Toggable in menu. Add token from CT for new health dot.
- Automatic range finding from ranged attack. Toggable in menu. Disadvantage for medium to max range added automatically, sharpshooter feat negates this. Message output to chat.
- 'Reach underlay' and 'Faction/space underlay' made as toggle switches in the menu items. Re-add tokens to update.


## Roadmap
Primary
- Highlight of selected token for GM, underlay, with opacity settings in menu.
- Drag and drop conditions on targets in CT or tokens on map, if already on target then remove, otherwise add.
- Effects as tooltip option on hover over token option.
Secondary
- Altitude for tokens.
- Save success or fail graphics on target on combat map. Button to clear.

## Things to patch
- Horizontal health bar, resizing and positioning is not working on token resize

## Releases
v0.1.0 (17th, September, 2019)  
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

v0.2.0
- Added 'manager_token.lua' from CoreRPG ruleset.
- 'Reach underlay' and 'Faction/space underlay' made as toggle switches in the menu items. (scripts/manager_token.lua: updateSizeHelper)
- Rewriting of horizontal health bars code, seamlessly integrated to run from manager_token.lua with minimal extra code in that ruleset file. Horizontal health bars now work flawlessly. (scripts/health_graphics.lua: drawHorizontalHealthBar, updateHealthBarScale | scripts/manager_token.lua: updateHealthHelper)
- Added menu option to toggle for default or larger health dots.
- Added larger health dots. (Scripts/health_graphics.lua: drawLargerHealthDot | scripts/manager_token.lua: updateHealthHelper)