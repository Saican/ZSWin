/*
	ZSWin_CursorPacket.zs
	
	This class is a utility wrapper for sending
	information about the cursor to the playism context

*/

class ZCRSRPKT
{
	int CursorX, CursorY, CursorEvent;
	
	ZCRSRPKT Init(int CursorX, int CursorY, int CursorEvent)
	{
		self.CursorX = CursorX;
		self.CursorY = CursorY;
		self.CursorEvent = CursorEvent;
		return self;
	}
	
	enum CRSRSTATE
	{
		CRSR_Idle,
		CRSR_MouseMove = 6,
		CRSR_LeftMouseDown,
		CRSR_LeftMouseUp,
		CRSR_LeftMouseClick,
		CRSR_MiddleMouseDown,
		CRSR_MiddleMouseUp,
		CRSR_MiddleMouseClick,
		CRSR_RightMouseDown,
		CRSR_RightMouseUp,
		CRSR_RightMouseClick,
		CRSR_WheelMouseUp,
		CRSR_WheelMouseDown,
	};
}