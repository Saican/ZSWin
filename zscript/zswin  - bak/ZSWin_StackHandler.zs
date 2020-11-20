/*
	ZSWin_StackHandler.zs
	
	Input handler

*/

class ZSWin_StackHandler : EventHandler
{
	//
	// Internal Declarations
	//
	enum CMDTYP
	{
		dbugout,
		quikclose,
		cursorLog,
		windowPurge,
		rtick,
		nocmd,
	};
	
	enum CRSRSTATE
	{
		idle,
		mousemove = 6,
		leftmousedown,
		leftmouseup,
		leftmouseclick,
		middlemousedown,
		middlemouseup,
		middlemouseclick,
		rightmousedown,
		rightmouseup,
		rightmouseclick,
		wheelmouseup,
		wheelmousedown,
	};
	
	//
	// Internal Members
	//
	int CursorX, CursorY;	
	CRSRSTATE CursorState;
	
	bool bDebug, bDebugIsUpdating;
	private int debugPlayer;
	
	private Array<ZText> dar_DebugMsgs;
	private ZSWindow ncon;
	
	int PriorityCallbackCount;
	private int StackIndex;
	private double RenderTick;
	
	/*
	
		Window Stack and related components
	
	*/
	private Array<ZSWin_Base> winStack;
	private Array<ZSWin_Base> copyStack;
	//private bool bIsPriorityUpdating, bPrioritySwitchComplete, bPrioritySwitchFinished,
		//bIsGarbageCollecting, bGarbageCollectionComplete, bGarbageCollectionFinished;
	//private int PriorityIndex;
	
	//
	// ZScript Events
	//
	override void OnRegister()
	{
		SetOrder(ZSHandlerUtil.GetLowestPossibleOrder());
		console.printf(string.format("ZScript Windows v%s - Window Input Handler Registered with Order %d - Welcome!", ZSHandlerUtil.ZVERSION, self.Order));	
		bDebug = bDebugIsUpdating = false;
		CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
		CursorX = CursorY = 0;
		PriorityCallbackCount = 0;
		StackIndex = -1;
		RenderTick = 0;
		//bIsPriorityUpdating = bPrioritySwitchComplete = bPrioritySwitchFinished = false;
		//bIsGarbageCollecting = bGarbageCollectionComplete = bGarbageCollectionFinished = false;
		//PriorityIndex = -1;
	}
	
	override void WorldLineActivated(WorldEvent e)
	{
		if (e.ActivatedLine)
		{
			bool globEnabled, globShow, uiTog;
			string windowClass, windowName;
			int playerNum;
			
			globEnabled = e.ActivatedLine.GetUDMFInt("user_globalenabled");
			globShow = e.ActivatedLine.GetUDMFInt("user_globalshow");
			windowClass = e.ActivatedLine.GetUDMFString("user_windowclass");
			windowName = e.ActivatedLine.GetUDMFString("user_windowname");
			uiTog = e.ActivatedLine.GetUDMFInt("user_uitoggle");
			playerNum = e.ActivatedLine.GetUDMFInt("user_consoleplayer");
			
			// Only the class name is really something that can be checked
			// to see if there's something to try.
			// The bools just result in false if they aren't there,
			// and 0 is a valid player number.
			// Also an empty window name has protection in the stack methods.
			if (windowClass != "")
			{
				// Try and create something with the name
				let zwin = new(windowclass);
				if (zwin && zwin is "ZSWin_Base")
					ZSWin_Base(zwin).Init(globEnabled, globShow, windowName, playerNum, uiTog);
			}
		}
	}
	
	/*
		World Tick Rate Updater
		
		Anything that needs to to at 35 ticks a second goes here.
	
	*/
	/*override void WorldTick()
	{
		//
		// - Priority Switching
		// --------------------
		// - These events need to take place at the game's tick rate so UI ticks pass
		// - causing RenderOverlay to use the copyStack while the winStack is manipulated.
		// - This doesn't have any negative impact on the draw switch visually.
		// - It's more like for a few frames the draw order is actually wrong because it's
		// - reading the copied data.  Once it switches back to the winStack the draw order
		// - is correct again.  The user sees and experiences nothing but the windows switching
		// - draw order.
		//
		//if (bIsPriorityUpdating && !bPrioritySwitchComplete && !bPrioritySwitchFinished)
			//SendNetworkEvent("zswin_PrioritySwitchComplete");
		//else if (bIsPriorityUpdating && bPrioritySwitchComplete && !bPrioritySwitchFinished)
			//SendNetworkEvent("zswin_PrioritySwitchFinished");		
		//else if (bIsPriorityUpdating && bPrioritySwitchComplete && bPrioritySwitchFinished)
			//SendNetworkEvent("zswin_PrioritySwitchRelease");
		
		//
		// - Garbage Collection
		// --------------------
		// - Oh no, window's can't just go away.  Remember there's this one method that is continuously
		// - trying to access some bit of window info and if that fails, the VM explodes.
		// - So window deletions are handled the same way as priority switching.
		//
		//if (bIsGarbageCollecting && !bGarbageCollectionComplete && !bGarbageCollectionFinished)
			//SendNetworkEvent("zswin_GarbageCollectComplete");
		//else if (bIsGarbageCollecting && bGarbageCollectionComplete && !bGarbageCollectionFinished)
			//SendNetworkEvent("zswin_GarbageCollectFinished");
		//else if(bIsGarbageCollecting && bGarbageCollectionComplete && bGarbageCollectionFinished)
			//SendNetworkEvent("zswin_GarbageCollectRelease");
		
		//
		// - Debug messages
		//
		
		// If there is a console window and debugging is off, tell it to destroy itself
		if (ncon && !bDebug)
			ZSWin_Base(ncon).bDestroyed = true;
		// There is no console window and there should be, so make a console window
		else if (!ncon && bDebug)
		{
			let zconsole = new("ZSWin_Console");
			if (zconsole)
				zconsole.Init(true, true, "ZConsoleWindow", consoleplayer, false);
		}
		
		// Iterate through the debug messages - if it still has time to display it gets passed to the new array,
		// otherwise it's skipped and erased.
		Array<ZText> newMsgs;
		for (int i = 0; i < dar_DebugMsgs.Size(); i++)
		{
			if (ZText(dar_DebugMsgs[i]).tics > 0)
			{
				ZText(dar_DebugMsgs[i]).tics--;
				newMsgs.Push(new("ZText").DebugInit(ZText(dar_DebugMsgs[i]).ControlName, 
											ZText(dar_DebugMsgs[i]).Text, 
											ZText(dar_DebugMsgs[i]).CRColor, 
											ZText(dar_DebugMsgs[i]).Tics, 
											ZText(dar_DebugMsgs[i]).TicAppend));
			}		
		}
		
		// Clear out old messages and add in the new ones
		dar_DebugMsgs.Clear();
		dar_DebugMsgs.Move(newMsgs);
		// Update the console window
		if (ncon)
		{
			bDebugIsUpdating = true; // Whichever window is the console will be looking at this to know it's being updated
			ncon.IsUpdating();		 // Makes copies of the window arrays for use until updating is done.
								     // - The problem is actually RenderOveraly going at the framerate and WorldTick going at script speed!
									 // - I'm basically having to multi-thread these classes to keep stuff synced!!
									 
			// Ok obviously this loop pushes the new messages to the console window :P
			for (int i = 0; i < dar_DebugMsgs.Size(); i++)
			{
				ncon.Text.Push(new("ZText").Init(ZText(dar_DebugMsgs[i]).ControlName,
												ZText(dar_DebugMsgs[i]).Enabled,
												true,
												ZText(dar_DebugMsgs[i]).TicAppend ? 
													string.Format("%s : tics - %d", ZText(dar_DebugMsgs[i]).Text, ZText(dar_DebugMsgs[i]).Tics) : 
													ZText(dar_DebugMsgs[i]).Text,
												ZText(dar_DebugMsgs[i]).CRColor,
												ZText.nowrap,
												0,
												ZText.left,
												"newsmallfont",
												0,
												30 + (20 * i)));
			}
		}
	}*/
	
	/*
	
	
	*/
	override void RenderOverlay(RenderEvent e)
	{
		SendNetworkEvent(string.format("zswin_RenderTick:%f", e.FracTic));
		
		if (PriorityCallbackCount == GetStackSize())
		{
			for (int i = winStack.Size() - 1; i >= 0; i--)
			{
				ZSWindow nwd = ZSWindow(GetWindowByPriority(i));
				if (nwd != null ? (nwd.player == consoleplayer && nwd.GlobalShow) : false)
				{
					ZDrawer.WindowProcess_Background(nwd);
					ZDrawer.WindowProcess_Border(nwd);
					ZDrawer.WindowProcess_Text(nwd);
					ZDrawer.WindowProcess_Shapes(nwd);
					ZDrawer.WindowProcess_Buttons(nwd);
					ZDrawer.WindowProcess_Graphics(nwd);						
				}
				//else
					//ZSHandlerUtil.HaltAndCatchFire(string.format(" - - THIS IS NOT SUPPOSED TO HAPPEN ANYMORE!\n - - ZSCRIPT WINDOWS EPIC FAIL!  TRIED TO ACCESS INVALID WINDOW WITH PRIORITY %d", i));
			}
		}
		//else
			//console.printf(string.format("Callbackcount : %d, Stack Size : %d, RenderTick : %f", PriorityCallbackCount, GetStackSize(), RenderTick));
	}
	
	override bool UiProcess(UiEvent e)
	{
		// Log the cursor location and event for playism use
		SendNetworkEvent(string.Format("zswin_cursorLocationLog:%d:%d", e.MouseX, e.MouseY));
		SendNetworkEvent("zswin_cursorActionLog", e.Type);
		
		// Call control events by type
		SendNetworkEvent("zswin_ActiveGibZone", e.Type);
		// Call window priority GibZoning
		SendNetworkEvent("zwin_WindowGibZone", e.Type);
	
		// Handler Events - This is anything specific the handler needs to do based on an input.
		switch (e.Type)
		{
			case UiEvent.Type_None:			
				break;
			case UiEvent.Type_KeyDown:
				// This results in a NetworkProcess_String call where the QuikClose check is processed
				SendNetworkEvent(string.format("zswin_quikCloseCheck:%s", e.KeyString));
				break;
			case UiEvent.Type_KeyRepeat:
				break;
			case UiEvent.Type_KeyUp:
				// Check if the key is the bind for the cursor toggle
				if (KeyBindings.NameKeys(Bindings.GetKeysForCommand("zswin_cmd_cursorToggle"), 0) ~== e.KeyString)
					SendNetworkEvent("zswin_UI_cursorToggle");
				break;
			case UiEvent.Type_Char:
			case UiEvent.Type_MouseMove:
			case UiEvent.Type_LButtonDown:
			case UiEvent.Type_LButtonUp:
			case UiEvent.Type_LButtonClick:
			case UiEvent.Type_MButtonDown:
			case UiEvent.Type_MButtonUp:
			case UiEvent.Type_MButtonClick:
			case UiEvent.Type_RButtonDown:
			case UiEvent.Type_RButtonUp:
			case UiEvent.Type_RButtonClick:
			case UiEvent.Type_WheelUp:
			case UiEvent.Type_WheelDown:
			default:
				// No error here - just got First/Last Mouse Event - what even are those?
				break;
		}
		return false;
	}
	
	override bool InputProcess(InputEvent e)
	{
		if (e.Type == InputEvent.Type_KeyUp)
			SendNetworkEvent("zswin_cursorToggle", e.KeyScan);
		return false;
	}
	
	override void UiTick()
	{
		if (PriorityCallbackCount == 0 && RenderTick < 0.5)
			SendNetworkEvent("zswin_PrioritySwitch");
		else
			console.printf(string.format("render tick is too late %f", RenderTick));
	}
	
	override void NetworkProcess(ConsoleEvent e)
	{
		// Start out planning on string processing the command,
		// but if the command is any of the following, they'll set this to false.
		bool bStringProcessed = true;
		
		// Cursor Toggle
		if (e.Name ~== "zswin_cursorToggle" || e.Name ~== "zswin_UI_cursorToggle")
		{
			bStringProcessed = false;
			int key1, key2;
			[key1, key2] = Bindings.GetKeysForCommand("zswin_cmd_cursorToggle");
			if (((key1 && key1 == e.Args[0]) || (key2 && key2 ==  e.Args[0])) || e.Name ~== "zswin_UI_cursorToggle")
			{
				self.IsUiProcessor = !self.IsUiProcessor;
				self.RequireMouse = !self.RequireMouse;
			}
		}
		
		// Log the cursor's action
		if (e.Name ~== "zswin_cursorActionLog")
		{
			bStringProcessed = false;
			CursorState = intToCursorState(e.Args[0]);
		}
		//
		// The cursor's location is string processed
		
		//
		// OUTGOING EVENTS
		//
		// Call the control events
		if (e.Name ~== "zswin_ActiveGibZone")
		{
			bStringProcessed = false;
			ActiveGibZoning(e.Args[0]);
		}
		// Call the window events
		if (e.Name ~== "zwin_WindowGibZone")
		{
			bStringProcessed = false;
			WindowGibZoning_EventCaller(e.Args[0]);
		}
		
		//
		// PRIORITY SWITCHING
		//
		// Priority Switch Initialize
		if (e.Name ~== "zswin_PrioritySwitch")
		{
			console.printf("priority switch received");
			bStringProcessed = false;
			WindowGibZoning_PrioritySwitch();
		}
		/*if (e.Name ~== "zswin_PriorityComplete")
			bStringProcessed = stackAccessHalt = false;*/
		// Complete Priority Switch
		/*if (e.Name ~== "zswin_PrioritySwitchComplete")
		{
			bStringProcessed = false;
			WindowGibZoning_PrioritySwitchComplete();
		}
		// Finish Priority Switch
		if (e.Name ~== "zswin_PrioritySwitchFinished")
		{
			bStringProcessed = false;
			WindowGibZoning_PrioritySwitchFinished();
		}
		// Priority Switch Resest
		if (e.Name ~== "zswin_PrioritySwitchRelease")
		{
			bStringProcessed = false;
			WindowGibZoning_PrioritySwitchRelease();
		}*/
		
		//
		// GARBAGE COLLECTING
		//
		if (e.Name ~== "zswin_GarbageCollect")
		{
			bStringProcessed = false;
			WindowGarbageCollection();
		}
		/*if (e.Name ~== "zswin_GarbageCollectComplete")
		{
			bStringProcessed = false;
			WindowGarbageCollection_Complete();
		}
		if (e.Name ~== "zswin_GarbageCollectFinished")
		{
			bStringProcessed = false;
			WindowGarbageCollection_Finished();
		}
		if (e.Name ~== "zswin_GarbageCollectRelease")
		{
			bStringProcessed = false;
			WindowGarbageCollection_Release();
		}*/
		
		//
		// MISC & STRING PROCESSING
		//
		// Debugging Check
		if (e.Name ~== "zswin_debugToggle")
		{
			bStringProcessed = false;
			debugPlayer = e.Player;
			bDebug = !bDebug;
			CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
			// If there is a console window and debugging is off, tell it to destroy itself
			if (ncon && !bDebug)
				ZSWin_Base(ncon).bDestroyed = true;
			// There is no console window and there should be, so make a console window
			else if (!ncon && bDebug)
			{
				let zconsole = new("ZSWin_Console");
				if (zconsole)
					zconsole.Init(true, true, "ZConsoleWindow", consoleplayer, false);
			}
		}
		// All other net events get string processed to see if they are sending string args or need ignored
		// This will only happen if none of the above events are caught.
		if (bStringProcessed)
			NetworkProcess_String(e);
	}
	
	
	//
	// ZScript Windows Methods
	//
	
	private CMDTYP stringToCmd(string e)
	{
		if (e ~== "zswin_debugOut")
			return dbugout;
		else if (e ~== "zswin_quikCloseCheck")
			return quikclose;
		else if (e ~== "zswin_cursorLocationLog")
			return cursorLog;
		else if (e ~== "zswin_windowPurge")
			return windowPurge;
		else if (e ~== "zswin_RenderTick")
			return rtick;
		else
			return nocmd;
	}
	
	private bool stringToBool(string e)
	{
		if (e ~== "true") 
			return true;
		else 
			return false;
	}
	
	private void NetworkProcess_String(ConsoleEvent e)
	{
		Array<string> cmdc;
		e.Name.Split(cmdc, ":");
		
		if (cmdc.Size() >= 1)
		{
			switch (stringToCmd(cmdc[0]))
			{
				// Send debug message to console window
				case dbugout:
					if (cmdc.Size() > 2) // have to have at least a name and text
					{
						int c = Font.CR_Red;
						if (cmdc.Size() > 3)
							c = cmdc[3].ToInt();
						uint t = 175;
						if (cmdc.Size() > 4)
							t = cmdc[4].ToInt();
						bool a = false;
						if (cmdc.Size() > 5)
							a = stringToBool(cmdc[5]);
						DebugOut(cmdc[1], cmdc[2], c, t, a);
					}
					else
						DebugOut("netCmd", "ERROR! - Got an invalid debug out message from a UI context method!");
					break;
				/*
					This version of Quik Close takes more inputs into account
					than the original, which only looked at forward/back, strafe left/right,
					and turn left/right.
					
					*need to do esc key as well
				
				*/
				case quikclose:
					if (cmdc.Size() == 2) // have to have a keystring to check
					{
						int key1, key2;
						bool quikclose = false;
						[key1, key2] = Bindings.GetKeysForCommand("+forward");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+back");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+moveleft");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+moveright");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+left");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+right");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("turn180");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+jump");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("+crouch");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						[key1, key2] = Bindings.GetKeysForCommand("crouch");
						if(KeyBindings.NameKeys(key1, key2) ~== cmdc[1])
							quikclose = true;
						
						if (quikclose)
							SendNetworkEvent("zswin_UI_cursorToggle");
					}
					else
						DebugOut("quikClose", "ERROR! - Did not get a valid key for Quik Close check!");
					break;
				// Save the cursor's location for playism use
				case cursorLog:
					if (cmdc.Size() == 3) // must be a command and the x/y of the mouse
					{
						CursorX = cmdc[1].ToInt();
						CursorY = cmdc[2].ToInt();
					}
					else
						DebugOut("mousePosition", "ERROR! - Not enough args for cursor log!");
					break;
				// Delete the given window
				case windowPurge:
					if (cmdc.Size() == 2) // command and window name
					{
						for (int i = 0; i < winStack.Size(); i++)
						{
							if (winStack[i].WindowName == cmdc[1])
							{
								ZSWindow(winStack[i]).bStackPurged = true;
								SendNetworkEvent("zswin_GarbageCollect");
								break;
							}
						}
					}
					else
						DebugOut("windowPurge", "ERROR! - No window name for purge!");
					break;
				case rtick:
					if (cmdc.Size() == 2)
					{
						RenderTick = cmdc[1].ToDouble();
					}
					break;
				// Anything else, just in case sends out what it got.
				default:
					DebugOut("badCmd", string.Format("NOTICE! Received unknown net event, \"%s\".  Ignore if event corresponds to a different mod.", cmdc[0]), Font.CR_Yellow);
					break;
			}
		}
	}
	
	CRSRSTATE intToCursorState(int i)
	{
		if (mousemove <= i && i <= wheelmousedown)
			return i;
		else
			return 0;
	}
	
	/*
		Name		: 	DebugOut
		Description : 	Main method of sending debug info to the screen.
		Args		:	1 - string, unique id for the message
						2 - string, the message
						[3] - int, text color - send Font.CR_x enums
						[4] - uint, unsigned int, text duration on screen, in tics
						[5] - bool, if true duration time remaining is appended to string
		Notes		:	console.printf is still perfectly vailid, but it's been noticed
						that calling it with the console window running can cause update
						desyncing of the console window.
						
						Args 3-5 are defaulted.
		
	
	*/
	void DebugOut(string Name, string Text, int color = Font.CR_Red, uint tics = 175, bool append = false)
	{ 
		if (bDebug) 
		{
			bool bAdded = true;
			int sameIndex = 0;
			
			for (int i = 0; i < dar_DebugMsgs.Size(); i++)
			{
				if (ZText(dar_DebugMsgs[i]).Text == Text)
					bAdded = false;
			}
			
			if (bAdded)
				dar_DebugMsgs.Push(new("ZText").DebugInit(Name, Text, color, tics, append)); 
		}
	}
	
	int GetDebugSize() { return dar_DebugMsgs.Size(); }
	
	bool SetWindowToConsole(ZSWindow nwd) { return (ncon = nwd); }
	
	//clearscope bool GetStackState() { return !(bIsPriorityUpdating || bPrioritySwitchComplete || bPrioritySwitchFinished ||
		//						bIsGarbageCollecting || bGarbageCollectionComplete || bGarbageCollectionFinished); }
								
	void AddWindow(ZSWin_Base win) 
	{ 
		if (win != null ? (win.WindowName != "" ? true : false) : false) 
		{
			RequirePriorityCallback(winStack.Push(win));
			copyStack.Push(win);
			DebugOut("WinStkMsg", string.Format("ZSWin Handler - Window, %s, for player %d added to processing stack", win.WindowName, win.player), Font.CR_Gold);
		}
		else if (win != null)
		{
			win.bDestroyed = true;
			DebugOut("WinStkError_NoName", "ZSWin Handler: ERROR! - Window with empty name received! Window destroyed.");
		}
		else
			DebugOut("WinStkError_NullWindow", "ZSWin Handler: ERROR! - Got a null window!");
	}
	
	clearscope int GetStackSize() 
	{
		//if ((!bIsPriorityUpdating || bPrioritySwitchComplete) ||
			//(!bIsGarbageCollecting || bGarbageCollectionComplete))
		if (RenderTick > 0.5)
			return winStack.Size();
		else
			return copyStack.Size();
	}
	
	uint GetStackIndex(ZSWin_Base nwd) 
	{
		//if ((!bIsPriorityUpdating || bPrioritySwitchComplete) ||
			//(!bIsGarbageCollecting || bGarbageCollectionComplete))
		if (RenderTick > 0.5)
			return winStack.Find(nwd);
		else
			return copyStack.Find(nwd);
	}
	
	clearscope ZSWin_Base GetWindow(int i) 
	{ 
		//if ((!bIsPriorityUpdating || bPrioritySwitchComplete) ||
			//(!bIsGarbageCollecting || bGarbageCollectionComplete))
			//{
				//console.printf("returning winstack");
		if (RenderTick > 0.5)
			return winStack[i];
			//}
		else
		//{
			//console.printf("returning copy stack");
			return copyStack[i];
		//}
	}
	
	clearscope ZSWin_Base GetWindowByPriority(int p)
	{
		//if ((!bIsPriorityUpdating || bPrioritySwitchComplete) ||
			//(!bIsGarbageCollecting || bGarbageCollectionComplete))
		//{
		if (RenderTick > 0.5)
		{
			for (int i = 0; i < winStack.Size(); i++)
			{
				console.printf(string.format("getwindowbypriority got priority: %d, i is : %d", p, i));
				console.printf(string.format("window priority: %d", winStack[i].Priority));
				if (winStack[i].Priority == p)
					return winStack[i];
			}
		}
		else
		{
			for (int i = 0; i < copyStack.Size(); i++)
			{
				if (copyStack[i].Priority == p)
					return copyStack[i];
			}
		}
		
		return null;
	}
	
	ZSWin_Base FindWindow(string WindowName)
	{
		for (int i = 0; i < GetStackSize(); i++)
		{
			if (GetWindow(i).WindowName ~== WindowName)
				return GetWindow(i);
		}
		return null;
	}
	
	WindowStats GetWindowStats(int StackIndex = 0, string name = "")
	{
		float stx, sty;
		int stw, sth;
		if (name == "")
		{
			console.printf(string.format("stack index is %d", StackIndex));
			[stx, sty] = ZDrawer.realWindowLocation(ZSWindow(GetWindow(StackIndex)));
			[stw, sth] = ZDrawer.realWindowScale(ZSWindow(GetWindow(StackIndex)));
			return new("WindowStats").Init(ZSWindow(GetWindow(StackIndex)).Priority, stw, sth, stx, sty);
		}
		else
		{
			for (int i = 0; i < winStack.Size(); i++)
			{
				if (winStack[i].WindowName == name)
				{
					[stx, sty] = ZDrawer.realWindowLocation(ZSWindow(GetWindow(i)));
					[stw, sth] = ZDrawer.realWindowScale(ZSWindow(GetWindow(i)));
					return new("WindowStats").Init(ZSWindow(GetWindow(i)).Priority, stw, sth, stx, sty);
				}
			}
		}
		
		return null;
	}
	
	/*
		Iterates through each window in the stack
		and the contents of each control array,
		calling the EventCaller for the given cursor state.
	
	*/
	private void ActiveGibZoning(CRSRSTATE state)
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			for (int j = 0; j < ZSWindow(winStack[i])._GetTextSize(); j++)
			{
				ZSWindow(winStack[i])._GetText(j).ShowCheck();
				if (ZSWindow(winStack[i])._GetText(j).Enabled)
					ActiveGibZoning_EventCaller(ZControl_Base(ZSWindow(winStack[i])._GetText(j)), ZSWindow(winStack[i]), state);
			}
			for (int j = 0; j < ZSWindow(winStack[i])._GetShapeSize(); j++)
			{
				ZSWindow(winStack[i])._GetShape(j).ShowCheck();
				if (ZSWindow(winStack[i])._GetShape(j).Enabled)
					ActiveGibZoning_EventCaller(ZControl_Base(ZSWindow(winStack[i])._GetShape(j)), ZSWindow(winStack[i]), state);
			}
			for (int j = 0; j < ZSWindow(winStack[i])._GetButtonSize(); j++)
			{
				ZSWindow(winStack[i])._GetButton(j).ShowCheck();
				if (ZSWindow(winStack[i])._GetButton(j).Enabled)
					ActiveGibZoning_EventCaller(ZControl_Base(ZSWindow(winStack[i])._GetButton(j)), ZSWindow(winStack[i]), state);
			}
		}
	}
	
	/*
		This is what actually calls a control's events.
		
	*/
	private void ActiveGibZoning_EventCaller(ZControl_Base control, ZSWindow nwd, CRSRSTATE state)
	{
		switch (state)
		{
			case idle:
				control.WhileMouseIdle(nwd);
				break;
			case mousemove:
				control.OnMouseMove(nwd);
				break;
			case leftmousedown:
				control.OnLeftMouseDown(nwd);
				break;
			case leftmouseup:
				control.OnLeftMouseUp(nwd);
				break;
			case leftmouseclick:
				control.OnLeftMouseClick(nwd);
				break;
			case middlemousedown:
				control.OnMiddleMouseDown(nwd);
				break;
			case middlemouseup:
				control.OnMiddleMouseUp(nwd);
				break;
			case middlemouseclick:
				control.OnMiddleMouseClick(nwd);
				break;
			case rightmousedown:
				control.OnRightMouseDown(nwd);
				break;
			case rightmouseup:
				control.OnRightMouseUp(nwd);
				break;
			case rightmouseclick:
				control.OnRightMouseClick(nwd);
				break;
			case wheelmouseup:
				control.OnWheelMouseDown(nwd);
				break;
			case wheelmousedown:
				control.OnWheelMouseUp(nwd);
				break;
		}
	}
	
	void RequirePriorityCallback(int StackIndex)
	{
		console.printf("priority callback initiated");
		self.StackIndex = StackIndex;
		PriorityCallbackCount = 0;
	}
	
	/*
		Called as a result of a Window's LeftButtonDown event
		This is step one in priority switching.
		Basically just tells the system, hey we're going to do a priority switch.
	
	*/
	private void WindowGibZoning_PrioritySwitch()
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (i == StackIndex)
				winStack[i].ChangePriority(0);
			else
				winStack[i].ChangePriority();
		}
		
		// Got an index
		//if (PriorityIndex >= 0 && !bIsPriorityUpdating && !bPrioritySwitchComplete && !bPrioritySwitchFinished &&
			//winStack[PriorityIndex].Priority != 0)
				//bIsPriorityUpdating = true;
		/*if (PriorityIndex >= 0)
		{
			for (int i = 0; i < winStack.Size(); i++)
			{
				if (i == PriorityIndex)
					winStack[i].Priority = 0;
				else if (winStack[i].Priority < winStack.Size() - 1)
					winStack[i].Priority += 1;
			}
		}*/
	}
	
	/*
		Second step in priority switching.
		Go through the window stack and change everyone's priority.
		This step will allow the system to resume using the window stack at this point.
	
	*/
	private void WindowGibZoning_PrioritySwitchComplete()
	{
		//if (PriorityIndex >= 0)
		//{
			//for (int i = 0; i < winStack.Size(); i++)
			//{
				//if (i == PriorityIndex)
					//winStack[i].Priority = 0;
				//else if (winStack[i].Priority < winStack.Size() - 1)
					//winStack[i].Priority += 1;
			//}
			
			//bPrioritySwitchComplete = true;
		//}
	}
	
	/*
		Third step in priority switching.
		The copyStack is outdated so this method updates it.
		
	*/
	private void WindowGibZoning_PrioritySwitchFinished()
	{
		//for (int i = 0; i < winStack.Size(); i++)
			//copyStack[i].Priority = winStack[i].Priority;
		//bPrioritySwitchFinished = true;
	}
	
	/*
		Fourth and final step in priority switching.
		Reset all the flags and the priority index, job done!
		
	*/
	private void WindowGibZoning_PrioritySwitchRelease()
	{
		//bIsPriorityUpdating = bPrioritySwitchComplete = bPrioritySwitchFinished = false;
		//PriorityIndex = -1;		
	}
	
	/*
		This method calls the window's events
		
	*/
	private void WindowGibZoning_EventCaller(CRSRSTATE state)
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (!winStack[i].IsPlayerIgnored() && winStack[i].GlobalShow && winStack[i].GlobalEnabled)
			{
				switch (state)
				{
					case idle:
						winStack[i].WhileMouseIdle();
						break;
					case mousemove:
						winStack[i].OnMouseMove();
						break;
					case leftmousedown:
						winStack[i].OnLeftMouseDown();
						break;
					case leftmouseup:
						winStack[i].OnLeftMouseUp();
						break;
					case leftmouseclick:
						winStack[i].OnLeftMouseClick();
						break;
					case middlemousedown:
						winStack[i].OnMiddleMouseDown();
						break;
					case middlemouseup:
						winStack[i].OnMiddleMouseUp();
						break;
					case middlemouseclick:
						winStack[i].OnMiddleMouseClick();
						break;
					case rightmousedown:
						winStack[i].OnRightMouseDown();
						break;
					case rightmouseup:
						winStack[i].OnRightMouseUp();
						break;
					case rightmouseclick:
						winStack[i].OnRightMouseClick();
						break;
					case wheelmouseup:
						winStack[i].OnWheelMouseDown();
						break;
					case wheelmousedown:
						winStack[i].OnWheelMouseUp();
						break;
				}
			}
		}
	}
	
	private void WindowGarbageCollection()
	{
		//if (!bIsGarbageCollecting && !bGarbageCollectionComplete && !bGarbageCollectionFinished)
			//bIsGarbageCollecting = true;
	}
	
	private void WindowGarbageCollection_Complete()
	{
		/*//bGarbageCollectionComplete = true;
		//Array<ZSWin_Base> newStack;
		//for (int i = 0; i < winStack.Size(); i++)
		//{		
			//if (winStack[i] ? (ZSWindow(winStack[i]).bStackPurged) : false)
				//winStack[i].bDestroyed = true;
			//else if (winStack[i])
				//newStack.Push(winStack[i]);
			//else
				//ZSHandlerUtil.HaltAndCatchFire(string.format(" - - WE DON'T NEED NO WATER LET THE MOTHERFUCKER BURN!\n - - ONLY CHUCK NORRIS IS MORE EPIC THAN THE EPICNESS OF ZSCRIPT WINDOWS FAIL!\n - - GARBAGE COLLECTOR TRIED TO ACCESS INVALID WINDOW IN TEH STACK AT INDEX %d", i));
		//}
		
		//// Someone got deleted so the priorities need ammended and the newstack moved across
		//if (newStack.Size() != winStack.Size())
		//{
			//for (int i = 0; i < winStack.Size(); i++)
			//{
				//let zfnd = GetWindowByPriority(i);
				//if (!zfnd)
				//{
					for (int j = 0; j < newStack.Size(); j++)
					{
						if (newStack[j].Priority > i)
							newStack[j].Priority -= 1;
					}
				}
			}
			
			winStack.Clear();
			winStack.Move(newStack);
		}
		
		bGarbageCollectionComplete = true;*/
	}
	
	private void WindowGarbageCollection_Finished()
	{
		//copyStack.Clear();
		//copyStack.Copy(winStack);
		//bGarbageCollectionFinished = true;
	}
	
	private void WindowGarbageCollection_Release()
	{
		//bIsGarbageCollecting = bGarbageCollectionComplete = bGarbageCollectionFinished = false;
	}
	
	/*
		Takes a window name - the unique identifier
		and sets it to be deleted
		
		Optionally can send the toggle cursor event
	
	*/
	void SetWindowForPurge(string name, bool uiToggle)
	{
		console.printf("was told to garbage collect");
		
		if (uiToggle)
			SendNetworkEvent("zswin_UI_cursorToggle");
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].WindowName == name)
			{
				ZSWindow(winStack[i]).bStackPurged = true;
				SendNetworkEvent("zswin_GarbageCollect");
				break;
			}
		}		
	}
	
	/*
		Sends the toggle cursor event, if UI processing
		isn't already on.
	
	*/
	void SendUIToggleEvent()
	{
		if (!self.IsUiProcessor)
			SendNetworkEvent("zswin_UI_cursorToggle");
	}
	
	/*
		Sets (or clears) the clipping rectange to
		the location and size of the window.
	
	*/
	ui void WindowClip(ZSWindow nwd = null, bool set = true)
	{
		if (set)
		{
			float nwdX, nwdY;
			[nwdX, nwdY] = ZDrawer.realWindowLocation(nwd);
			int realWidth, realHeight;
			[realWidth, realHeight] = ZDrawer.realWindowScale(nwd);
			Screen.SetClipRect(nwdX, nwdY, realWidth, realHeight);		
		}
		else
			Screen.ClearClipRect();
	}
	
	/* - END OF METHODS - */
}