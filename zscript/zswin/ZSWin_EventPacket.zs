/*
	ZSWin_EventPacket.zs
	
	This class represents event data being sent
	between scopes.

*/

class ZEventPacket
{
	string EventName;
	int FirstArg, SecondArg, ThirdArg, ClientPlayer;
	bool Manual;
	
	ZEventPacket Init (string EventName, int FirstArg, int SecondArg, int ThirdArg, int ClientPlayer = 0, bool Manual = false)
	{
		self.EventName = EventName;
		self.FirstArg = FirstArg;
		self.SecondArg = SecondArg;
		self.ThirdArg = ThirdArg;
		self.ClientPlayer = ClientPlayer;
		self.Manual = Manual;
		return self;
	}
}