/*
	ZSWin_InputPacket.zs
	
	This packet works pretty much just like the
	cursor packet.

*/

class ZInputPacket
{
	string KeyString;
	bool IsShift, IsCtrl, IsAlt;
	
	ZInputPacket Init(string KeyString, bool IsShift, bool IsCtrl, bool IsAlt)
	{
		self.KeyString = KeyString;
		self.IsShift = IsShift;
		self.IsCtrl = IsCtrl;
		self.IsAlt = IsAlt;
		return self;
	}
}