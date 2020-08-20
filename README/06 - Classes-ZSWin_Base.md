# ZScript Windows v0.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## ZSWin_Base
###Window base class

------------


####Public Members:
    class ZSWin_Base : actor abstract
    {
    	bool GlobalEnabled, GlobalShow, bDestroyed;
    	float GlobalAlpha;
    	string name;
    	int player, Priority;
    	ZSWin_Handler zHandler;
    	void DebugOut(string name, string msg, int color = Font.CR_Red, uint tics = 175, bool append = false);
    	bool IsPlayerIgnored();
    	virtual void Init(bool GlobalEnabled, bool GlobalShow, string name, int player);
    	override void Tick();
    }

####Properties:
- **GlobalEnabled** : bool, controls if the window is interactive.
-- Window and controls will be drawn using GlobalAlpha property.
- **GlobalShow** : bool, controls if the window is drawn.
-- System will also toggle GlobalEnabled to disable interactive processing.  The state of GlobalEnabled is preserved.
- **Name** : string, unique identifier for the window.
- **player** : int, consoleplayer the window corresponds to.
- **Priority** : int, draw order indicator.  
-- A value of 0 represent the highest priority, however this also means the window is drawn last.
- **zHandler** : ZSWin_Handler, this is a reference to the system event handler.

####Methods:
- ***DebugOut*** : Sends a string to the console window.
-- This method can be called at any time.  It may even be called from UI scoped methods through sending net events.  If a window is unable to send messages to the system event handler, it will hold them until it can.  Messages will be marked as "held messages" in the console window.
-- **Arguments**
--- name : string, this argument is required because of the way classes are initialized, however it's relatively unimportant for debug messages - these ZText instances are deleted as the console window is updated.
--- msg : string, the text that should appear in the console window.  This may be formated.
--- color : int, use the Font.CR_x color enumerations.
--- tics : uint, message duration onscreen.
--- append : bool, controls if the remaining tics is appended to the end of the message.

- ***Init*** : Class constructor.
-- **Arguments**
--- GlobalEnabled : bool, controls if the window is interactive.
--- GlobalShow : bool, controls if the window is drawn.
--- name : string, unique identifier for the window.
--- player : int, consoleplayer the window corresponds to.

- ***Tick*** : ZScript native method.
-- **Arguments** : none

[Back to Class Detail Links]()
[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")