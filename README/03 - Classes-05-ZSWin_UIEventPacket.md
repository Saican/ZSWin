# ZScript Windows v0.3.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Class ZUIEventPacket
### UI Process Packet

------------
ZObjects may process their own input data by overriding their *ZObj_UiProcess* method.  This method is an extension of the event handler class's *UiProcess* method.  As such, the *ZObj_UiProcess* method receives a *ZUIEventPacket* from the *UiProcess* method, which is almost functionally identical to the *UiEvent* struct.

------------


#### Public Members:
 - EventType, EVENTTYP - this enumeration represents what type of input event was received.
 - PlayerClient, int - this value corresponds to *consoleplayer* and is the player this event corresponds to.  *ZObj_UiProcess* use **must** check that actions being taken are for the correct player.
 - KeyString, string - this is the character equivalent of the pressed key.
 - KeyChar, int - ASCII value of the pressed key.
 - MouseX, int - X location of the mouse cursor.
 - MouseY, int - Y location of the mouse cursor.
 - IsShift, bool, should be true if the shift key is pressed, false otherwise.
 - IsAlt, bool, should be true if the alt key is pressed, false otherwise.
 - IsCtrl, bool, should be true if the ctrl key is pressed, false otherwise.

------------


#### Enumerations:
EVENTTYP - this enumeration is almost identical to the [EGUIEvent](https://github.com/coelckers/gzdoom/blob/734b15e412b72f508d90662b7824f92cf1ba32c9/wadsrc/static/zscript/events.zs#L54).  The only skipped values are the First and Last mouse events.  All EVENTTYP underlyers are identical to their EGUIEvent counterparts.
- Valid EVENTTYP Values:
	- EventType_None
	- EventType_KeyDown
	- EventType_KeyRepeat
	- EventType_KeyUp
	- EventType_Char
	-  EventType_MouseMove
	- EventType_LButtonDown
	- EventType_LButtonUp
	- EventType_LButtonClick
	- EventType_MButtonDown
	- EventType_MButtonUp
	- EventType_MButtonClick
	- EventType_RButtonDown
	- EventType_RButtonUp
	- EventType_RButtonClick
	- EventType_WheelUp
	- EventType_WheelDown

------------


#### Methods:
Init - packet constructor.
- Arguments:
	-  int, EventType - this should be assigned from the UiEvent.Type or a valid value from EVENTTYP.
	- int, PlayerClient - this is an alias for *consoleplayer* in ZScript Windows.  This should be assigned the player client to which this packet is assigned.  This member is unique to the packet and *ZObj_UiProcess* because, much like RenderOverlay, this method needs to differentiate between events coming from different players.  Just like RenderOverlay, when using *ZObj_UiProcess*, you must check that you are executing actions for the correct player.
	- string, KeyString - same as the UiEvent.KeyString, a string containing the character that corresponds to the pressed key.
	- int, KeyChar - not a char, but instead the ASCII value of the pressed key.
	- int, MouseX - X location of the mouse cursor.
	- int, MouseY - Y location of the mouse cursor.
	- bool, IsShift - same as the UiEvent.IsShift member.
	- bool, IsAlt - same as the UiEvent.IsAlt member.
	- bool, IsCtrl - same as the UiEvent.IsCtrl member.

------------


[Back to Class Detail Links](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes.md)

------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")
