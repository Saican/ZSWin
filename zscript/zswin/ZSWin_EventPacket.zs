/*
	ZSWin_EventPacket.zs
	
	This class represents event data being sent
	between scopes.

*/

class ZEventPacket
{
	string EventName;
	int FirstArg, SecondArg, ThirdArg;
	
	ZEventPacket Init (string EventName, int FirstArg, int SecondArg, int ThirdArg)
	{
		self.EventName = EventName;
		self.FirstArg = FirstArg;
		self.SecondArg = SecondArg;
		self.ThirdArg = ThirdArg;
		return self;
	}
}