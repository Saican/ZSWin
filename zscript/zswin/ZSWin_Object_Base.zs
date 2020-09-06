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
	ZEventSystem ZEvent;
	
	private bool wasEnabled, bIsEventInvalid;
	void EnabledLog() { wasEnabled = Enabled; }
	void EventInvalidate() { bIsEventInvalid = false; }
	void EventValidate() 
	{ 
		bIsEventInvalid = true; 
		zEvent.LetAllPost();
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
			ZEvent.SendNetworkEvent("zswin_AddToUITicker:zswin_ShowCheckEnabled", zEvent.GetStackIndex(self), 0);
		else if (wasEnabled && !Enabled)
			ZEvent.SendNetworkEvent("zswin_AddToUITicker:zswin_ShowCheckEnabled", zEvent.GetStackIndex(self), 1);		
		return Show;
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
		ZEvent.AddObjectToGlobalObjects(self);
		return self;
	}
	
	override void Tick()
	{
		if (self.bSelfDestroy)
			self.Destroy();
	}
	
	bool GetZHandler() 
	{
		ZEvent = ZEventSystem(EventHandler.Find("ZEventSystem"));
		if (ZEvent)
			return true;
		return false; 
	}
	
	virtual bool ValidateCursorLocation() { return bIsEventInvalid; }
	
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
	
	virtual void WhileMouseIdle() {}
	virtual void OnMouseMove() {}
	
	virtual void OnLeftMouseDown() {}
	virtual void OnLeftMouseUp() {}
	virtual void OnLeftMouseClick() {}
	
	virtual void OnMiddleMouseDown() {}
	virtual void OnMiddleMouseUp() {}
	virtual void OnMiddleMouseClick() {}
	
	virtual void OnRightMouseDown() {}
	virtual void OnRightMouseUp() {}
	virtual void OnRightMouseClick() {}
	
	virtual void OnWheelMouseDown() {}
	virtual void OnWheelMouseUp() {}
}