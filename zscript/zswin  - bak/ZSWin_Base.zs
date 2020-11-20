class ZSWin_Base : thinker abstract
{
	private bool wasEnabled;
	bool GlobalEnabled,
		GlobalShow,
		bDestroyed;
	float GlobalAlpha;
	string WindowName;
	int player, Priority;
	ZSWin_StackHandler zHandler;
	void DebugOut(string WindowName, string msg, int color = Font.CR_Red, uint tics = 175, bool append = false) 
	{ 
		if (zHandler) 
			zHandler.DebugOut(WindowName, msg, color, tics, append); 
		else
			dar_HeldMsgs.Push(new("ZText").DebugInit(WindowName, msg, color, tics, append));
	}
	private Array<ZText> dar_HeldMsgs;
	
	bool IsPlayerIgnored() { return (consoleplayer != player); }
	
	virtual ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string WindowName, int player, bool uiToggle)
	{
		self.GlobalEnabled = GlobalEnabled;
		self.GlobalShow = GlobalShow;
		bDestroyed = false;
		if (GlobalEnabled)
			GlobalAlpha = 1.0;
		else
			GlobalAlpha = 0.5;
		self.WindowName = WindowName;
		self.player = player;
		zHandler = ZSWin_StackHandler(EventHandler.Find("ZSWin_StackHandler"));
		
		if (!zHandler)
		{
			self.destroy();
			ZSHandlerUtil.HaltAndCatchFire(string.Format("ZScript Windows ERROR! - Window Construction of window, %s, has failed to find the central event handler!  Construction aborted and window destroyed.", WindowName));
		}
		else
		{
			zHandler.AddWindow(self);
			Priority = 0;//zHandler.GetStackSize() - 1;
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
	
	/*
		
	*/
	bool ValidateCursorLocation()
	{
		int CursorX = zHandler.CursorX,
			CursorY = zHandler.CursorY;
		Array<WindowStats> higherStats;
		float nwdX, nwdY;
		[nwdX, nwdY] = ZDrawer.realWindowLocation(ZSWindow(self));		
		int realWidth, realHeight;
		[realWidth, realHeight] = ZDrawer.realWindowScale(ZSWindow(self));
		bool mouseOver = true;
		if (Priority > 0)
		{
			for (int i = 0; i < zHandler.GetStackSize(); i++)
			{
				WindowStats newStats = zHandler.GetWindowStats(i);
				if (newStats && newStats.Priority < self.Priority)
					higherStats.Push(newStats);
			}
			for (int i = 0; i < higherStats.Size(); i++)
			{
				if (higherStats[i].xLocation < CursorX && CursorX < higherStats[i].xLocation + higherStats[i].Width &&
					higherStats[i].yLocation < CursorY && CursorY < higherStats[i].yLocation + higherStats[i].Height)
				{
					mouseOver = false;
					break;
				}
			}
		}
		if (mouseOver && GlobalShow && GlobalEnabled &&
				nwdX < CursorX && CursorX < nwdX + realWidth &&
				nwdY < CursorY && CursorY < nwdY + realHeight)
			return true;
		else
			return false;
	}
	
	void ChangePriority(int p = -1)
	{
			console.printf("Priority change order received");
		if (zHandler.PriorityCallbackCount < zHandler.GetStackSize())
		{
			if (p >= 0)
				self.Priority = p;
			else
				self.Priority += 1;
			
			zHandler.PriorityCallbackCount++;
		}
	}
	
	virtual void WhileMouseIdle() {}
	virtual void OnMouseMove() {}
	
	virtual void OnLeftMouseDown() 
	{
		if (ValidateCursorLocation())
			zHandler.RequirePriorityCallback(zHandler.GetStackIndex(self));
			//EventHandler.SendNetworkEvent("zswin_PrioritySwitch", zHandler.GetStackIndex(self));
	}
	virtual void OnLeftMouseUp() 
	{
		//if (ValidateCursorLocation())
			//EventHandler.SendNetWorkEvent("zswin_PriorityComplete");
	}
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