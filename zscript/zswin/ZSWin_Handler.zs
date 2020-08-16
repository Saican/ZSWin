
class ZSWin_Handler : EventHandler
{
	const TIC = 35;
	const ZVERSION = "0.1";
	
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
		if (win != null ? (win.name != "" ? true : false) : false) 
		{
			winStack.Push(win); 
			DebugOut("WinStkMsg", string.format("ZSWin Handler - Window, %s, for player #%d, with TID, %d added to processing stack.", win.name, win.player, win.tid), Font.CR_Gold);
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

	override void OnRegister()
	{
		console.Printf(string.format("ZScript Windows v%s - Welcome!", ZVERSION));
		bDebug = bDebugIsUpdating = false;
		CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
		CursorX = CursorY = 0;
	}
	
	override bool UiProcess(UiEvent e)
	{
		SendNetworkEvent("zswin_cursorLocationLog", e.MouseX, e.MouseY);
		
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
				break;
			case UiEvent.Type_LButtonUp:
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
		if (e.Name == "zswin_cursorToggle" || e.Name == "zswin_UI_cursorToggle")
		{
			int key1, key2;
			[key1, key2] = Bindings.GetKeysForCommand("zswin_cmd_cursorToggle");
			if (((key1 && key1 == e.Args[0]) || (key2 && key2 ==  e.Args[0])) || e.Name == "zswin_UI_cursorToggle")
			{
				self.IsUiProcessor = !self.IsUiProcessor;
				self.RequireMouse = !self.RequireMouse;
			}
		}
		// Log the cursor location - windows need this to do passive GibZoning
		else if (e.Name == "zswin_cursorLocationLog")
		{
			CursorX = e.Args[0];
			CursorY = e.Args[1];
		}
		// Debugging Check
		else if (e.Name == "zswin_debugToggle")
		{
			debugPlayer = e.Player;
			bDebug = !bDebug;
			CVar.GetCVar('ZSWINVAR_DEBUG').SetBool(bDebug);
		}
		// All other net events get string processed to see if they are sending string args or need ignored
		else
			NetworkProcess_String(e);
	}

	enum CMDTYP
	{
		dbugout,
		quikclose,
		nocmd,
	};
	
	private CMDTYP stringToCmd(string e)
	{
		if (e ~== "zswin_debugOut")
			return dbugout;
		else if (e ~== "zswin_quikCloseCheck")
			return quikclose;
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
				default:
					DebugOut("badCmd", string.Format("NOTICE! Received unknown net event, \"%s\".  Ignore if event corresponds to a different mod.", cmdc[0]), Font.CR_Yellow);
					break;
			}
		}
	}

	// This is the primary draw caller
	override void RenderOverlay(RenderEvent e)
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			// Check that this window can be drawn for the given player.
			if (consoleplayer == ZSWin_Base(winStack[i]).player)
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
			else
				EventHandler.SendNetworkEvent(string.Format("zswin_debugOut:%s:%s", "renderProcess", string.Format("Window %s not valid for player %d", winStack[i].name, consoleplayer)));
		}
	}
	
	//
	// One of the only public ui draw methods,
	// this will either set the clipping rectangle to the window dimensions,
	// or clear the clipping rectangle.
	//
	ui void WindowClip(ZSWindow nwd = null, bool set = true)
	{
		if (set)
			Screen.SetClipRect(nwd.xLocation, nwd.yLocation, nwd.Width, nwd.Height);		
		else
			Screen.ClearClipRect();
	}
	
	override void WorldTick()
	{
		//
		// - Debug messages
		//
		
		// If there is a console window and debugging is off, tell it to destroy itself
		if (ncon && !bDebug)
			ZSWin_Base(ncon).bDestroyed = true;
		// There is no console window and there should be, so call up old croney ACS to get a console window.
		// Seems hacky but its the legit method here - windows are actors!
		else if (!ncon && bDebug)
			CallACS("ZSWin_SpawnConsole", 0, debugPlayer);
		
		// Iterate through the debug messages - if it still has time to display it gets passed to the new array,
		// otherwise it's skipped and erased.
		Array<ZText> newMsgs;
		for (int i = 0; i < dar_DebugMsgs.Size(); i++)
		{
			if (ZText(dar_DebugMsgs[i]).tics > 0)
			{
				ZText(dar_DebugMsgs[i]).tics--;
				newMsgs.Push(new("ZText").DebugInit(ZText(dar_DebugMsgs[i]).Name, 
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
				ncon.Text.Push(new("ZText").Init(ZText(dar_DebugMsgs[i]).Name,
												ZText(dar_DebugMsgs[i]).Enabled,
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
			if (!ZSWindow(winStack[i]).bStackPurged)
				newStack.Push(winStack[i]);
			else
				winStack[i].bDestroyed = true;
		}
		
		DebugOut("WinStkContents", string.Format("ZSWin Handler - Processing Stack contains %d objects, New Stack contains %d objects, %d objects destroyed.", winStack.Size(), newStack.Size(), winStack.Size() - newStack.Size()), Font.CR_LightBlue, 175, true);
			
		if (winStack.Size() != newStack.Size())
		{
			winStack.Clear();
			winStack.Move(newStack);
		}
	}
	
	/* - END OF METHODS - */
}