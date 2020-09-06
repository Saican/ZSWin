/*
	ZSWin_WindowPacket.zs
	
	This class is used to initialize windows
	from events like WorldLineActivated
	
	Like all Packet classes this is a transport class
	that shepards data between contexts and events.

*/

class ZWindowPacket
{
	bool Enabled, Show, UiToggle;
	string WindowName, ClassName;
	float xLocation, yLocation, Alpha;
	int playerClient, ClipType;
	
	ZWindowPacket Init (bool Enabled, bool Show, bool UiToggle,
						string WindowName, string ClassName,
						int ClipType, float xLocation, float yLocation, float Alpha,
						int playerClient)
	{
		self.Enabled = Enabled;
		self.Show = Show;
		self.UiToggle = UiToggle;
		self.WindowName = WindowName;
		self.ClassName = ClassName;
		self.ClipType = ClipType;
		self.xLocation = xLocation;
		self.yLocation = yLocation;
		self.Alpha = Alpha;
		self.playerClient = playerClient;
		return self;
	}
}