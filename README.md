# AVsitter support for OpenSim NPC

By Typhaine Artez, base on PMAC 2.5 by Aine Caoimhe (even this doc ^^). **Version 1.0** *- April 2019*

Provided under Creative Commons [Attribution-Non-Commercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Please be sure you read and adhere to the terms of this license.


This script is a plugin for AVsitter 2, adding support for NPC (Non Playable Character) on OpenSim and compatible platforms.
It is heavily based on work for PMAC (Paramour Multi-Animation Controller) by Aine Caoimhe.

## USAGE

1) Drop the `[AV]npc` script in your object containing an existing setup of AVsitter.
2) Add NPC Notecards (see below for name format, compatible with PMAC)
3) Add a button in your menu with any name (for example NPC) and sending message 90514 (i.e. `BUTTON NPC|90514`)
4) Sit on your object and go in the menu containing your NPC button, click on it
5) You get a list of NPCs, click on one to rez it and it will sit on next available seat
6) Click on `UNSIT` button to remove the last sat NPC

## NPC Notecards

Create an appearance notecard and rename it to use the correct NPC naming format, compatible with PMAC:

```
.NPC[ss][r] [Firstname] [Lastname]
```

- it must begin with `.NPC` (note the period at the start)
- optional (used for compatibility with PMAC) **two numbers or letters** used for sorting and a letter `A`, `G` or `O`
- a space
- the first name to use for the NPC -- it **must** be a single word with no space
- a space
- a the last name to use for the NPC -- again it **must** be a single word with no space

If you don't supply a last name (NPC) will be appended to the rezzed NPC so the NPC would be named `Firstname (NPC)`.

The total of length of Firstname plus Lastname cannot exceed 24 characters (which becomes 25 character because of the space between them).

And it's a good idea to try to keep the combined length shorter if at all possible since in most cases only the first name and a bit of the last name will fit on a button.

Again, the name of the NPC must be unique from any other NPC even if the first part is different.
