/*
	ZSWin_Handler.zs
	
	ZScript Windows Event Handler

*/
class ZSWin_Handler : EventHandler
{
	const ZVERSION = "0.1";
	
	enum CRSRSTATE
	{
		idle,
		leftmousedown = 7,
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
	// Enums are just ints so this method really just checks for a valid range
	CRSRSTATE intToCursorState(int i)
	{
		if (leftmousedown <= i && i <= wheelmousedown)
			return i;
		else
			return 0;
	}
	// The three most important variables - the state of the cursor, and it's location
	CRSRSTATE CursorState;
	int CursorX, CursorY;
	
	bool bDebug, bDebugIsUpdating;
	private int debugPlayer;
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
	private Array<ZText> dar_DebugMsgs;
	int GetDebugSize() { return dar_DebugMsgs.Size(); }
	private ZSWindow ncon;
	bool SetWindowToConsole(ZSWindow nwd) { return (ncon = nwd); }	
	private Array<ZSWin_Base> winStack;
	void AddWindow(ZSWin_Base win) 
	{ 
		if (win != null ? (win.WindowName != "" ? true : false) : false) 
		{
			winStack.Push(win); 
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
	int GetStackSize() { return winStack.Size(); }
	uint GetStackIndex(ZSWin_Base nwd) { return winStack.Find(nwd); }
	WindowStats GetWindowStats(int StackIndex = 0, string name = "")
	{
		if (name == "")
			return new("WindowStats").Init(winStack[StackIndex].Priority, ZSWindow(winStack[StackIndex]).Width, ZSWindow(winStack[StackIndex]).Height, ZSWindow(winStack[StackIndex]).xLocation, ZSWindow(winStack[StackIndex]).yLocation); // 0 is a valid index :P
		else
		{
			for (int i = 0; i < winStack.Size(); i++)
			{
				if (winStack[i].WindowName == name)
					return new("WindowStats").Init(winStack[i].Priority, ZSWindow(winStack[i]).Width, ZSWindow(winStack[i]).Height, ZSWindow(winStack[i]).xLocation, ZSWindow(winStack[i]).yLocation);
			}
		}
		
		return null;
	}

	override void OnRegister()
	{
		console.Printf(string.format("ZScript Windows v%s - Welcome!", ZVERSION));
		bDebug = bDebugIsUpdating = false;
		CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
		CursorX = CursorY = 0;
	}
	
	override bool UiProcess(UiEvent e)
	{
		// Log the cursor location
		SendNetworkEvent(string.Format("zswin_cursorLocationLog:%d:%d", e.MouseX, e.MouseY));
		SendNetworkEvent("zswin_cursorActionLog", e.Type);
		
		switch (e.Type)
		{
			case UiEvent.Type_KeyDown:
				// This results in a NetworkProcess_String call where the QuikClose check is processed
				SendNetworkEvent(string.format("zswin_quikCloseCheck:%s", e.KeyString));
				break;
			case UiEvent.Type_KeyUp:
				if (KeyBindings.NameKeys(Bindings.GetKeysForCommand("zswin_cmd_cursorToggle"), 0) ~== e.KeyString)
					SendNetworkEvent("zswin_UI_cursorToggle");
				break;
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

	override void NetworkProcess(ConsoleEvent e)
	{
		// zswin_cursorToggle is sent by InputProcess
		// zswin_UI_cursorToggle is sent by UiProcess
		// Basically the two event processors trade places when the mouse is on.
		// What is received by the two events is very different and not compatible,
		// so the two separate events are necessary.
		// The final zswin_x_cursorToggle variable is the zswin_cmd_cursorToggle.
		// This is the command alias for the toggle keybind and is only good for
		// getting what key is bound to the toggle keybind.
		// NetworkProcess and UiProcess look at this value differently; I think NetworkProcess
		// deals with it as some kind of engine-specific value, while UiProcess can actually
		// get the character the key represents - as a string, which is fine, chars are annoying.
		bool bStringProcessed = true;
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
		if (e.Name ~== "zswin_cursorActionLog")
		{
			bStringProcessed = false;
			CursorState = intToCursorState(e.Args[0]);
		}
		// Debugging Check
		if (e.Name ~== "zswin_debugToggle")
		{
			bStringProcessed = false;
			debugPlayer = e.Player;
			bDebug = !bDebug;
			CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
		}
		// All other net events get string processed to see if they are sending string args or need ignored
		// This will only happen if none of the above events are caught.
		if (bStringProcessed)
			NetworkProcess_String(e);
	}

	// String args get converted to an enum
	enum CMDTYP
	{
		dbugout,
		quikclose,
		cursorLog,
		windowPurge,
		nocmd,
	};
	// This is the supporting string conversion method
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
				case cursorLog:
					if (cmdc.Size() == 3) // must be a command and the x/y of the mouse
					{
						CursorX = cmdc[1].ToInt();
						CursorY = cmdc[2].ToInt();
					}
					else
						DebugOut("mousePosition", "ERROR! - Not enough args for cursor log!");
					break;
				case windowPurge:
					if (cmdc.Size() == 2) // command and window name
					{
						for (int i = 0; i < winStack.Size(); i++)
						{
							if (winStack[i].WindowName == cmdc[1])
								ZSWindow(winStack[i]).bStackPurged = true;
						}
					}
					else
						DebugOut("windowPurge", "ERROR! - No window name for purge!");
					break;
				default:
					DebugOut("badCmd", string.Format("NOTICE! Received unknown net event, \"%s\".  Ignore if event corresponds to a different mod.", cmdc[0]), Font.CR_Yellow);
					break;
			}
		}
	}
	
	/*
		I am seriously not a fan of this method of ZWindow creation.
		I feel that this is a hack and that is NOT what ZScript was
		created for but was meant to combat.
		
		I understand users might want to execute a line special and
		create a window, but that doesn't mean I have to like it.
		
		So, to make this as safe as possible, I have implemented the
		following precautions:
		
		The class name must have a valid value.
		It must result in a working class when calling "new"
		It must be a ZSWin_Base in order to call Init.
	
	*/
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
		Takes a window name - the unique identifier
		and sets it to be deleted
		
		Optionally can send the toggle cursor event
	
	*/
	void SetWindowForPurge(string name, bool uiToggle)
	{
		if (uiToggle)
			SendNetworkEvent("zswin_UI_cursorToggle");
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].WindowName == name)
				ZSWindow(winStack[i]).bStackPurged = true;
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
		Primary Draw Caller
	
	*/
	override void RenderOverlay(RenderEvent e)
	{
		// Iterate through window stack, in order.
		for (int i = 0; i < winStack.Size(); i++)
		{
			// Check that this window can be drawn for the given player.
			if (winStack[i] ? (consoleplayer == ZSWin_Base(winStack[i]).player && ZSWin_Base(winStack[i]).GlobalShow) : false)
			{
				let nwd = ZSWindow(winStack[i]);
				zsys.WindowProcess_Background(nwd);
				zsys.WindowProcess_Border(nwd);
				zsys.WindowProcess_Text(nwd);
				zsys.WindowProcess_Shapes(nwd);
				zsys.WindowProcess_Buttons(nwd);
				zsys.WindowProcess_Graphics(nwd);
			}
			// This EventHandler call appears to be causing the ZScript VSCode Extension to choke.
			// Since this is just debugging code it's perfectly safe to comment it out if working in VSCode with the ZScript Extension
			// - There is another line in the WindowProcess_Text method which causes the same issue.
			else if (winStack[i])
				SendNetworkEvent(string.Format("zswin_debugOut:%s:%s", "renderProcess", string.Format("Window %s not valid for player %d", winStack[i].WindowName, consoleplayer)));
		}
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
			[nwdX, nwdY] = zsys.realWindowLocation(nwd);
			Screen.SetClipRect(nwdX, nwdY, nwd.Width, nwd.Height);		
		}
		else
			Screen.ClearClipRect();
	}
	
	/*
		Updater - runs at world speed
	
	*/
	override void WorldTick()
	{
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
		
		// Window Processing Stack Monitor
		//
		// Windows need to tell the handler that they need to go away, basically asking permission to be destroyed.
		// The reason for this is that the window stack needs to be updated if a window is being destroyed.
		// This loop looks for windows that have requested to be purged, tells them go ahead, and skips them when
		// adding windows to the new stack array.  Last step is clear out the actual stack array and move over the
		// new stack of windows.
		Array<ZSWin_Base> newStack;
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i] ? (!ZSWindow(winStack[i]).bStackPurged) : false)
				newStack.Push(winStack[i]);
			else if (winStack[i])
			{
				winStack[i].bDestroyed = true;
				// This window is going away so all the windows behind it have to
				// have their priorities adjusted by 1 (0 is highest priority so subtract)
				for (int j = i - 1; j >= 0; j--)
					winStack[j].Priority -= 1;
			}
		}
		
		DebugOut("WinStkContents", string.Format("ZSWin Handler - Processing Stack contains %d objects, New Stack contains %d objects, %d objects destroyed.", winStack.Size(), newStack.Size(), winStack.Size() - newStack.Size()), Font.CR_LightBlue, 175, true);
			
		if (winStack.Size() != newStack.Size())
		{
			winStack.Clear();
			winStack.Move(newStack);
		}
		
		// Priority GibZoning
		// 
		// Windows handle GibZoning for their controls.
		// The handler handles GibZoning for the windows.
		if (CursorState != idle) // idle actually excludes mousemove
		{
			// returns winStack index of window that was clicked on - so 0 is a valid index
			// returns -1 if no window was clicked on
			int priorityWin = windowPriorityGibZoning();
			if (priorityWin >= 0)
			{
				winStack[priorityWin].Priority = 0;
				for (int i = priorityWin + 1; i < winStack.Size(); i++)
					winStack[i].Priority += 1;
			}
		}
		
		// Priority Sorting
		//
		// Window priority represents the draw order, however it runs in reverse.
		// 0 represents the highest priority with ascending values representing lower priorities
		// What is means is that a window with lower priority will be drawn before a window with higher priority
		// This should make no difference to interactive performance and is just a curiosity of the system functionality
		//
		// This also means that the window stack must be sorted from lowest to highest.
		// So more looping...*sigh
		// This is acceptably simple, since the priorityStack can be initialized to the size of the window stack,
		// then windows sorted in by priority.
		// (priorityStack.Size() - 1) - winStack[i].Priority results in the inversion of the array.
		// If a window has a priority of 3 and the size is 3, the result is 0
		// If a window has a priority of 0 and the size is 3, the result is 3
		Array<ZSWin_Base> priorityStack;
		priorityStack.Reserve(winStack.Size());
		for (int i = 0; i < winStack.Size(); i++)
		{
			console.printf(string.format("winstack size: %d, priority stack size: %d, i: %d, priority: %d", winStack.Size(), priorityStack.Size(), i, winStack[i].Priority));
			priorityStack[(priorityStack.Size() - 1) - winStack[i].Priority] = winStack[i];
		}
		winStack.Clear();
		winStack.Move(priorityStack);
	}
	
	/*
		This method is pretty simple, it figures out which window was interacted with.
		It runs the window stack in reverse, since the last window has highest priority,		
		
		Returns -1 if no window is found
	
	*/
	private int windowPriorityGibZoning()
	{
		for (int i = winStack.Size() - 1; i >= 0; i--)
		{
			ZSWindow nwd = ZSWindow(winStack[i]);
			if (!nwd.IsPlayerIgnored() && nwd.GlobalShow && nwd.GlobalEnabled && CursorState != idle &&
				nwd.xLocation < CursorX && CursorX < nwd.xLocation + nwd.Width &&
				nwd.yLocation < CursorY && CursorY < nwd.yLocation + nwd.Height)
				return i;
		}
		
		return -1;
	}
	
	/* - END OF METHODS - */
}