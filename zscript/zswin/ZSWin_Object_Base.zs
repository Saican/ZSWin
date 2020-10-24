/*
	ZSWin_Object_Base.zs
	
	UI Base Object - All ZScript Windows UI Object inherit from this

*/

class ZObjectBase : thinker abstract
{
	enum SCALETYP
	{
		SCALE_Horizontal,
		SCALE_Vertical,
		SCALE_Both,
		SCALE_NONE,
	};
	
	ZObjectBase ControlParent;
	
	enum CLIPTYP
	{
		CLIP_Window,
		CLIP_Parent,
		CLIP_NONE,
	};
	
	CLIPTYP ClipType;
	
	bool bSelfDestroy, Enabled, Show;
	string Name;
	int PlayerClient, Priority, Width, Height;
	float xLocation, yLocation, Alpha;
	
	private bool wasEnabled, bIsEventInvalid;
	void EnabledLog() { wasEnabled = Enabled; }
	bool IsEventInvalid() { return !bIsEventInvalid; }
	void EventInvalidate() { bIsEventInvalid = false; }
	void EventValidate() 
	{ 
		bIsEventInvalid = true; 
		//zEvent.LetAllPost();
		//EventHandler.SendNetworkEvent("zevent_LetAllPost", PlayerClient);
		ZNetCommand("zobj_LetAllPost", PlayerClient);
	}
	
	clearscope static void ZNetCommand(string cmd, int pc, int arg_a = 0, int arg_b = 0, int arg_c = 0)
	{
		EventHandler.SendNetworkEvent(string.Format("%s?%d", cmd, pc), arg_a, arg_b, arg_c);
	}	
	
	bool IsPlayerIgnored() { return (consoleplayer != PlayerClient); }
	
	/*
		While the Show and Enabled variables are public,
		ShowCheck creates the special relationship between the two.
		
		This method returns the value of Show, and toggles Enabled
		based on the value of Show.
	
	*/
	clearscope bool ShowCheck()
	{
		if (!Show)
			ZNetCommand(string.Format("zobj_ShowCheckEnabled,%s", self.Name), PlayerClient);
			//EventHandler.SendNetworkEvent("zswin_AddToUITicker:zswin_ShowCheckEnabled", zEvent.GetStackIndex(self), 0);
		else if (wasEnabled && !Enabled)
			ZNetCommand(string.Format("zobj_ShowCheckEnabled,%s", self.Name), PlayerClient, true);
			//EventHandler.SendNetworkEvent("zswin_AddToUITicker:zswin_ShowCheckEnabled", zEvent.GetStackIndex(self), 1);		
		return Show;
	}
	
	private void showCheckEnabled(string n, bool t)
	{
		if (n ~== self.Name)
		{
			if (t)
				self.Enabled = true;
			else
			{
				self.EnabledLog();
				self.Enabled = false;
			}
		}
	}
	
	ZObjectBase Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle, CLIPTYP ClipType = CLIP_NONE)
	{
		self.ControlParent = ControlParent;
		self.Enabled = Enabled;
		wasEnabled = self.Enabled;
		self.Show = Show;
		self.Name = Name;
		self.PlayerClient = PlayerClient;
		// Ui Toggle needs implemented yet
		self.ClipType = ClipType;
		
		bSelfDestroy = false;
		bIsEventInvalid = true;
		EventHandler.SendNetworkEvent(string.Format("zevsys_AlertHandlersToNewGlobal,%s", self.Name));
		//ZEvent.AddObjectToGlobalObjects(self);
		return self;
	}
	
	ZObjectBase HCF(string msg)
	{
		ZSHandlerUtil.HaltAndCatchFire(msg);
		return null;
	}
	
	override void Tick()
	{
		if (self.bSelfDestroy)
			self.Destroy();
	}
	
	/*
		This method is called by the Event System's UiProcess method.
		It works exactly the same, return false if you want further
		calls to be executed.
	*/
	ui virtual bool ZObj_UiProcess(ZUIEventPacket e) { return false; }
	
	/*
		This method is called by the Event System's UITick in order for
		ZObject's to process UI information.
		
		This method works like UIProcess, returning true causes all further
		calls to be aborted, thus eating everything for that tick.
		
		This method is public to users however it should be used with care.
		If you override, you MUST call the super.  Simplest way is to just
		return the super, which window and control bases will end up here.
	
	*/
	ui virtual bool ZObj_UiTick() { return false; }
	
	/*
		This method is called by the Event System's NetworkProcess,
		which allows ZObjects to send and receive their own net commands.
		
		This method continues the trend and follows ZObj_UiTick in that
		the method returns boolean, and true will result in further
		NetProcess calls being aborted.  Same thing applies, just call the super.
		
		Unlike it's command parent, this method takes an Event Packet for
		its event arguments.
	
	*/
	enum ZOBJNETCMD
	{
		ZOBJCMD_ShowCheckEnabled,
		
		ZOBJCMD_TryString,
	};
	
	private ZOBJNETCMD stringToZObjNetCommand(string e)
	{
		if (e ~== "zobj_ShowCheckEnabled")
			return ZOBJCMD_ShowCheckEnabled;
		else
			return ZOBJCMD_TryString;
	}
	
	virtual bool ZObj_NetProcess(ZEventPacket e) 
	{ 
		Array<string> cmdc;
		e.EventName.Split(cmdc, "?");
		if (cmdc.Size() == 2 ? (cmdc[1].ToInt() == self.PlayerClient) : false)
		{
			if (!e.Manual)
			{
				switch (stringToZObjNetCommand(cmdc[0]))
				{
					default:
						ZObj_NetProcess_String(e);
						break;
				}
			}
			else {}
		}
		return false; 
	}
	
	private void ZObj_NetProcess_String(ZEventPacket e)
	{
		// Separate the command string from the player number
		Array<string> cmdPlyr;
		e.EventName.Split(cmdPlyr, "?");
		// Check there's two halves and the second half is equal the this object's assigned player
		if (cmdPlyr.Size() == 2 ? (cmdPlyr[1].ToInt() == self.PlayerClient) : false)
		{
			// Split the command string into a command list
			Array<string> cmdc;
			cmdPlyr[0].Split(cmdc, ":");
			// Execute the command ist
			for (int i = 0; i < cmdc.Size(); i++)
			{
				if (cmdc[i] != "")
				{
					// Chop up each command into an argument list
					Array<string> cmd;
					cmdc[i].Split(cmd, ",");
					// There's at least something, right? (no argument command)
					if (cmd.Size() > 0)
					{
						// Index 0 of the command should be the command itself
						switch (stringToZObjNetCommand(cmd[0]))
						{
							case ZOBJCMD_ShowCheckEnabled:
								if (cmd.Size() == 2)
									self.showCheckEnabled(cmd[1], e.FirstArg);
								else
									console.printf(string.Format("ZObject, %s, received invalid Show Check command!", self.Name));
								break;
						}
					}
				}
			}
		}
	}
	
	clearscope virtual bool ValidateCursorLocation() { return bIsEventInvalid; }
	
	/*
		Event virtuals
		
		For windows in the event handler stack, the parent argument is
		useless because it's a reference to the window.  For everything else,
		its a reference to the parent object.
	
	*/
	ui virtual void ObjectDraw(ZObjectBase parent) {}
	
	/*
		This method is a unique event virtual.
		It is not routinely called by the system.
		Instead it is called as the result of a control sending
		an AddToUITick event from a UI context method, and requesting
		this method be called through a ControlUpdate event in the Event
		System's UITick method.
		
		This method is meant to be overriden by a control in order to
		to update its information internally prior to render events.
	*/
	virtual void ObjectUpdate() {}
	
	/*
		The int argument represents the UIProcess type - useful for switch/case 
		checking of input events
	*/
	virtual void WhileMouseIdle(int t) {}
	virtual void OnMouseMove(int t) {}
	
	virtual void OnLeftMouseDown(int t) {}
	virtual void OnLeftMouseUp(int t) {}
	virtual void OnLeftMouseClick(int t) {}
	
	virtual void OnMiddleMouseDown(int t) {}
	virtual void OnMiddleMouseUp(int t) {}
	virtual void OnMiddleMouseClick(int t) {}
	
	virtual void OnRightMouseDown(int t) {}
	virtual void OnRightMouseUp(int t) {}
	virtual void OnRightMouseClick(int t) {}
	
	virtual void OnWheelMouseDown(int t) {}
	virtual void OnWheelMouseUp(int t) {}
}