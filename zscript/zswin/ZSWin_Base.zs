class ZSWin_Base : thinker abstract
{
	private bool wasEnabled;
	bool GlobalEnabled,
		GlobalShow,
		bDestroyed;
	float GlobalAlpha;
	//name of the window
	string WindowName;

	int player, Priority;
	//pointer to the event which draw all stufff of this window on player screen
	ZSWin_Handler zHandler;
	void DebugOut(string name, string msg, int color = Font.CR_Red, uint tics = 175, bool append = false) 
	{ 
		if (zHandler) 
			zHandler.DebugOut(name, msg, color, tics, append); 
		else
			dar_HeldMsgs.Push(new("ZText").DebugInit(name, msg, color, tics, append));
	}
	private Array<ZText> dar_HeldMsgs;
	
	bool IsPlayerIgnored() { return (consoleplayer != player); }
	
	//init window virtual
	virtual ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string name, int player, bool uiToggle)
	{
		DebugOut("baseInitMsg", "Window base initialized", Font.CR_Green);
		self.GlobalEnabled = GlobalEnabled;
		self.GlobalShow = GlobalShow;
		bDestroyed = false;
		if (GlobalEnabled)
			GlobalAlpha = 1.0;
		else
			GlobalAlpha = 0.5;
		self.WindowName = name;
		self.player = player;
		//search for controlling event
		zHandler = ZSWin_Handler(EventHandler.Find("ZSWin_Handler"));
		//if something goes wrong, print message into console what goes wrong
		if (!zHandler)
		{
			console.printf(string.format("ZScript Windows ERROR! - Window Construction of window, %s, has failed to find the central event handler!  Construction aborted and window destroyed.", name));
			self.destroy();
		}
		else
		{
			zHandler.AddWindow(self);
			Priority = zHandler.GetStackIndex(self);
			if (uiToggle)
				zHandler.SendUIToggleEvent();
		}
		
		return self;
	}
	
	override void Tick()
	{
		if (Level.Time > 1)
		{
			// Self Destruction
			if (bDestroyed)
			{
				DebugOut("WindowDestroyMsg", string.format("Object named, %s, marked for destruction.  Goodbye!", WindowName == "" ? "NO NAME" : WindowName));
				self.Destroy();
			}
			
			// Held Messages for the console
			if (zHandler && dar_HeldMsgs.Size() > 0)
			{
				for (int i = 0; i < dar_HeldMsgs.Size(); i++)
					DebugOut(string.Format("HeldMsg%d", i), string.format("Held Window Initialization Message: %s", ZText(dar_HeldMsgs[i]).Text), ZText(dar_HeldMsgs[i]).CRColor, ZText(dar_HeldMsgs[i]).Tics, ZText(dar_HeldMsgs[i]).TicAppend);
				
				dar_HeldMsgs.Clear();
			}
			
			// Global Alpha
			GlobalAlpha = 0.5 + (0.5 * (GlobalEnabled));
			
			// Global Show/Enabled toggle
			if (!GlobalShow)
			{
				wasEnabled = GlobalEnabled;
				GlobalEnabled = false;
			}
			else if (wasEnabled && !GlobalEnabled)
				GlobalEnabled = true;
		}
	}
}