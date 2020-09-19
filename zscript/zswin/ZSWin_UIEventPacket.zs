/*
	ZSWin_UIEventPacket.zs
	
	UiProcess Packet

*/

class ZUIEventPacket
{
	enum EVENTTYP
	{
		EventType_None,
		EventType_KeyDown,
		EventType_KeyRepeat,
		EventType_KeyUp,
		EventType_Char,
		EventType_MouseMove = 6,
		EventType_LButtonDown,
		EventType_LButtonUp,
		EventType_LButtonClick,
		EventType_MButtonDown,
		EventType_MButtonUp,
		EventType_MButtonClick,
		EventType_RButtonDown,
		EventType_RButtonUp,
		EventType_RButtonClick,
		EventType_WheelUp,
		EventType_WheelDown,
	};
	EVENTTYP EventType;
	string KeyString;
	int KeyChar, MouseX, MouseY;
	bool IsShift, IsAlt, IsCtrl;
	
	ZUIEventPacket Init(int EventType, string KeyString, int KeyChar, int MouseX, int MouseY, bool IsShift, bool IsAlt, bool IsCtrl)
	{
		self.EventType = EventType;
		self.KeyString = KeyString;
		self.KeyChar = KeyChar;
		self.MouseX = MouseX;
		self.MouseY = MouseY;
		self.IsShift = IsShift;
		self.IsAlt = IsAlt;
		self.IsCtrl = IsCtrl;
		return self;
	}
}