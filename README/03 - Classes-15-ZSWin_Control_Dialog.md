# ZScript Windows v0.4.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Class ZConversation : ZControl
### NPC Dialog System

------------
This control emulates the functionality of the Universal Strife Dialog Format (USDF).

------------

#### Public Members: 
 - **bTransferToActor**, bool, if true, cost exchanges will transfer to the root actor's inventory (the base window).
 - **WaitMessageTicks**, int, specifies how many ticks (1/35th of a second) to wait.  While public, this member is used internally.
 - **WaitForMessage**, bool, if true, the control will wait the number of ticks specified by WaitForMessageTicks before performing actions like changing pages.  While public, this member is used internally.
 - **NPCName**, ZText, this is the actual text control that stores and draws the name of the NPC.
 - **NPCDialog**, ZText, this is the actual text control that stores and draws what the NPC is saying to the player.
 - **PlayerChoices**, fixed ZButton array, this array has a defined size of 5 objects, equivalent to the number of choices a player may make in a given page.  The buttons therefore function as the source of input and output for choices.

------------
#### Constants:
**NUMCHOICES** - this value represents how many choices a play may be presented with in a given page.

------------
#### Methods:
- *Remember!* - ZScript has a method argument skipping mechanic called "named arguments", which is utilized by ZScript Windows.  Do not be overwhelmed by the constructor argument list, the majority is defaulted allowing you to set what you need and skip the rest.
- Note that defaulted arguments are named in braces [ ].

1. **AddDialogPage** - adds the given dialog page to the control's array of dialog pages.
	- **newPage**, ZDialogPage, the page to be pushed to the array.
2. **FindDialogPageNumber** - returns the index of the given dialog page, or -1 if not found.
	- **pn**, string, the name of the dialog page to locate.
3. **GetDialogPageByName** - returns a reference to the given dialog page, or null if not found.
	- **pn**, string, the name of the dialog page to locate.
4. **GetDialogPageByIndex** - returns a reference to the given dialog page, or null if not found.
	- **i**, int, index of the dialog page to locate.
5. **AddDialogToPage** - adds the given text to the given dialog page (what the NPC can say to the player).
	- **dialog**, string, the text to be added to the dialog page.
	- **page**, string, the name of the page to add the dialog to.
	- **[skill]**, OPTSKILL, enum, represents the game skill value for filtering dialog.  This is actually an int, but you should use "ZDialog.OPTSKILL_x" as the OPTSKILL underlyers correspond to ACS game skill values.  Defaults to OPTSKILL_ALL.
6. **GetPageNumber** - returns the index of the currently loaded dialog page.
1. **Init** - ZConversation constructor.
	- **ControlParent**, ZObjectBase, reference to the ZObject containing this control.
	- **Enabled**, bool, if true the control may be interacted with.
	- **Show**, bool, if true the control will be drawn.
	- **PlayerClient**, int, the consoleplayer this control corresponds to.
	- **UiToggle**, bool, if true the creation of this object causes UI Mode to be activated for the consoleplayer this control's parent window corresponds to.
	- **[bTransferToActor]**, bool, if true, cost exchanges will transfer the currency to the root ZObject (the base window).  Defaults to false.
	- **[bDefault_NPCName]**, bool, if true, the control will automatically create a ZText object for the NPCName with default settings.  Defaults to false.
	- **[bDefault_NPCDialog]**, bool, if true, the control will automatically create a ZText object for the NPCDialog with default settings.  Defaults to false.
	- **[bDefault_Buttons]**, bool, if true, the control will automatically create the ZButtons necessary to populate the PlayerChoices array.
8. **CreateSubControl** - similar to a window's "AddControl", but less functional, this method handles the heavy lifting of creating ZObjects that are part of a ZConversation.  This method has multiple returns, first it returns boolean, second it returns a reference to the actor the method created.
	- **controlName**, string, the class name of the ZObject to be created.
9. **Start** - loads the first dialog page into the system.

------------
#### Usage Example:

```cpp

```


------------


[Back to Class Detail Links](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes.md)

------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")
