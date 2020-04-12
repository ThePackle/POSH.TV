# POSH.TV v0.6
* DEVELOPED BY THEPACKLE
* Twitter: https://twitter.com/thepackle
* Twitch: https://twitch.tv/thepackle

# Intro
POSH.TV is a Windows PowerShell-based IRC client for Twitch.tv. This was created utilizing PowerShell 7.0 in mind, but should still work with PowerShell 6.0.

# Why PowerShell?
Most Twitch.tv bots utilize one or several languages, including Java, Python, C++, Ruby,or so on; there was a Github link to a user (INPUT) that was working on creating their own PowerShell Twitch.tv client, but hadn't been updated in several months. Using what they had as a base, it was converted into a newer soft-coded format for anyone to use!

# FEATURES
- Initial setup script for new installations
- PowerShell chat client
- Chat logging to file (can be enabled or disabled)
- Add, Edit, or Remove customizable commands
- Add or Remove chat bot moderators (separate from Twitch chat mods)
- Integration with Speedrun.com API, allowing for PB and WR checks

# TO DO
- Dedicated PowerShell chat client GUI
- Quotes system
- Points system
- Change setup script to allow easy configuration changes (as opposed to restarting)

# v0.6
## Additions
- invoke-POSHTVSRAPI was created with two different functions:
    1) Grab the basic information about a runner, games, and categories and coorelate IDs with real names
    2) Asks the user, on initial install, to select which games they want converted to !pb with a user-defined chat abbreviation
- update-POSHTVSRAPI - Updates information from Speedrun.com API
- get-POSHTVSR - Searches local file for information on a specific run from a chat abbreviation
- update-POSHTVSR - Allows the user to update their locally defined chat abbreviation list or receive the latest listing from Speedrun.com's API

## Changes
- Added #Requires for invoke-POSHTV (6.0+ required)
- Added an incompatible version warning to the beginning of enable-POSHTV
- Logging is now sent to $env:appdata\POSHTV\logs\, if $logs is $true
- Collection check for your Speedrun.com PBs on startup (if applicable)
- Setting files were converted into a variable
- All Yes/No prompts are now done with switches instead of terrible y/n prompts
- Changed commands to use *-POSHTV* instead of *-TwitchBot*
- enable-POSHTV will now save settings in $env:APPDATA (user appdata folder)
- Updated enable-POSHTV to ask if the user is using Speedrun.com
- Changed logic order for some commands
- Updated add- and update-POSHTVCommand to receive separate parameters instead of them being combined
- Removed excess $global:[variable] calls

## Fixes
- Fixed an issue where uppercase commands wouldn't equal lowercase commands
- Fixed an issue where $syntax would carry a single space instead of $null
- Fixed an issue where $param would still have a space at the end of its text, breaking some commands.
- Fixed an issue where update-POSHTVCommand had two statements that did the same thing
- Fixed an issue where different games could report the same IGT
