/*
	ZSWin_EventPacket.zs
	
	This class represents event data being sent
	between scopes.

*/

class ZEventPacket
{
	string EventName;
	int FirstArg, SecondArg, ThirdArg, PlayerClient;
	bool Manual;
	
	ZEventPacket Init (string EventName, int FirstArg, int SecondArg, int ThirdArg, int PlayerClient = 0, bool Manual = false)
	{
		self.EventName = EventName;
		self.FirstArg = FirstArg;
		self.SecondArg = SecondArg;
		self.ThirdArg = ThirdArg;
		self.PlayerClient = PlayerClient;
		self.Manual = Manual;
		return self;
	}
}