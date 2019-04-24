// [AV]npc - AVsitter support for OpenSim NPC
// By Typhaine Artez, base on PMAC 2.5 by Aine Caoimhe
// Version 1.0 - April 2019
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// This script uses the following OSSL functions so they must be enabled for the owner of the script
// osIsNpc(), osNpcCreate(), osNpcSit(), osNpcRemove()

integer NPC_MESSAGENUMBER = 90514;  // 14=position of "N" in alphabet ;-)
string MAIN_SCRIPT = "[AV]sitA";

list invNpc;                // [notecard, NPC name] list
list sitters;               // avatar key or NULL_KEY for all seats
key menu_user = NULL_KEY;
integer menu_handle;
integer menu_page;

init() {
    // build NPC list from inventory notecards
    integer i = llGetInventoryNumber(INVENTORY_NOTECARD);
    while (~(--i)) {
        string name = llGetInventoryName(INVENTORY_NOTECARD, i);
        if (!llSubStringIndex(name, ".NPC")) {
            list newNpc = [ name, llDumpList2String(llList2List(llParseString2List(name, [], [" "]), 1, -1), " ") ];
            integer n = llListFindList(invNpc, [name]);
            if (~n) invNpc = llListReplaceList(invNpc, newNpc, n, n+2);
            else invNpc = newNpc + invNpc;
        }
    }

    // detect number of seats
    sitters = [NULL_KEY];
    for (i = 1; INVENTORY_SCRIPT == llGetInventoryType(MAIN_SCRIPT + " " + (string)i); ++i)
        sitters += NULL_KEY;

    // update used seats
    integer p = llGetNumberOfPrims();
    integer c = llGetObjectPrimCount(llGetKey());
    for (i = 0; ++c <= p; ++i)
        setSeat(llGetLinkKey(c), i);
}

setSeat(key who, integer seat) {
    sitters = llListReplaceList(sitters, [who], seat, seat);
}

menuNpc(key id) {
    list buttons;
    string txt = "ADD NPC\nSelect the NPC to add. It will occupy the first available position\n\n";
    integer i;
    for (;i < llGetListLength(invNpc); i+=2)
        buttons += llList2String(invNpc, i+1);
    buttons = llList2List(buttons, menu_page, menu_page+8);
    txt += llDumpList2String(buttons, "\n");
    while (9 > llGetListLength(buttons))
        buttons += [ " " ];
    buttons += [ "NEXT >", "UNSIT", "BACK" ];

    llListenRemove(menu_handle);
    integer channel = ((integer)llFrand(0x7FFFFF80) + 1) * -1;
    menu_handle = llListen(channel, "", id, "");
    menu_user = id;
    llDialog(id, txt, llList2List(buttons,9,11)+llList2List(buttons,6,8)+llList2List(buttons,3,5)+llList2List(buttons,0,2), channel);
    llSetTimerEvent(120);   // timeout 2 minutes
}

menuClose() {
    llSetTimerEvent(0.0);
    llListenRemove(menu_handle);
    menu_user = NULL_KEY;
    menu_page = 0;
}

default {
    on_rez(integer p) {
        llResetScript();
    }
    state_entry() {
        init();
    }
    changed(integer c) {
        if (CHANGED_OWNER & c) llResetScript();
        if (CHANGED_INVENTORY & c) init();
    }
    link_message(integer sender, integer num, string str, key id) {
        if (llGetLinkNumber() != sender) return;
        if (90065 == num) setSeat(NULL_KEY, (integer)str);
        else if (90070 == num) setSeat(id, (integer)str);
        else if (90030 == num) {
            // swap
            sitters = llListReplaceList(sitters, [NULL_KEY], (integer)str, (integer)str);
            sitters = llListReplaceList(sitters, [NULL_KEY], (integer)id, (integer)id);
        }
        else if (NPC_MESSAGENUMBER == num) {
            if (NULL_KEY == menu_user || id == menu_user) menuNpc(id);
        }
    }
    listen(integer channel, string name, key id, string msg) {
        llSetTimerEvent(0.0);
        if ("BACK" == msg) {
            llMessageLinked(LINK_SET, 90004, "", menu_user);
            menuClose();
        }
        else if ("< PREV" == msg || "NEXT >" == msg) {
            if ("< PREV" == msg) menu_page -= 9;
            else menu_page += 9;
            if (menu_page >= llGetListLength(invNpc)/2) menu_page = 0;
            else if (menu_page <= -9) menu_page = llGetListLength(invNpc)/2 - 9;
            if (menu_page < 0) menu_page = 0;
            menuNpc(id);
        }
        else if ("UNSIT" == msg) {
            integer i = llGetListLength(sitters);
            while (~(--i)) {
                key who = llList2Key(sitters, i);
                if (NULL_KEY != who && osIsNpc(who)) {
                    osNpcRemove(who);
                    setSeat(NULL_KEY, i);
                    i = 0;
                }
            }
            menuNpc(id);
        }
        else {
            if (!~llListFindList(sitters, [NULL_KEY])) {
                llRegionSayTo(id, 0, "No free seat available to add a NPC.");
                menuNpc(id);
            }
            else {
                string npc = llList2String(invNpc, llListFindList(invNpc, [msg])-1);
                if (INVENTORY_NOTECARD != llGetInventoryType(npc)) {
                    llRegionSayTo(id, 0, "The notecard for NPC "+msg+" could not be found.");
                    menuNpc(id);
                }
                else {
                    list npcNames = llParseString2List(msg, [" "], []);
                    if (1 == llGetListLength(npcNames)) npcNames += "(NPC)";
                    key created = osNpcCreate(llList2String(npcNames, 0), llList2String(npcNames, 1), llGetPos()+<0.0, 0.0, 2.0>, npc, OS_NPC_SENSE_AS_AGENT|0x8);
                    osNpcSit(created, llGetKey(), OS_NPC_SIT_NOW);
                    llMessageLinked(LINK_SET, 90004, "", menu_user);
                    menuClose();
                }
            }
        }
    }
    timer() {
        menuClose();
    }
}
