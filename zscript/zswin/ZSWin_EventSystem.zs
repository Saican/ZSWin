/*
	ZSWin_EventSystem.zs
	
	ZScript Windows v0.3 Event Handler

*/

class ZEventSystem : ZSHandlerUtil
{
	//
	// - HANDLER INTERNALS
	// -------------------
	//
	
	/*
		This works like the engine's AllClasses array but is specific to ZObjects
	*/
	private ZABST allZObjects;
	private array<ZObjectBase> incomingZObjects;
	//clearscope int GetSizeAllZObjects() { return allZObjects.Size(); }
	//clearscope uint GetIndexAllZObjects(ZObjectBase zobj) { return allZObjects.Find(zobj); }
	//clearscope ZObjectBase GetByIndexAllZObjects(int i) { if (i < allZObjects.Size()) return allZObjects[i]; else return null; }
	clearscope ZObjectBase FindZObject(string n)
	{
		//for (int i = 0; i < allZObjects.Size(); i++)
		//{
			//if (allZObjects[i].Name ~== n)
				//return allZObjects[i];
		//}
		ZABST_Node node = allZObjects.Find(n);
		if (node)
			return ZObjectBase(node.Data);
		return null;
	}
	
	/*
		Window stack and related components
	*/
	private array<ZWindowPacket> windowPackets;
	private array<ZObjectBase> incomingWindows;
	private array<ZObjectBase> winStack;
	private int priorityStackIndex;
	private bool ignorePostDuplicate;
	private array<int> outgoingWindows;
	
	/*
		Get methods for accessing the stack
	*/
	clearscope int GetStackSize() { return winStack.Size(); }
	clearscope uint GetStackIndex (ZObjectBase zobj) { return winStack.Find(zobj); }
	clearscope ZObjectBase GetWindowByIndex(int i) { return winStack[i]; }
	clearscope ZObjectBase GetWindowByPriority (int p)
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].Priority == p)
				return winStack[i];
		}
		return null;
	}
	clearscope ZObjectBase GetWindowByName(string n)
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].Name ~== n)
				return winStack[i];
		}
		return null;
	}

	/*
		This is used to enforce unique names all objects.
	*/
	clearscope bool NameIsUnique(string n)
	{
		ZABST_Node node = allZObjects.Find(n);
		if(node)
			return false;
		return true;
	}
	
	/*
		These are debug messages that can be output from manual net events
	*/
	private void debugStackSizeToConsole() { console.printf(string.Format("ZEvent System Stack Size is currently : %d", winStack.Size())); }
	private void debugStackPriorityToConsole()
	{
		if (winStack.Size() > 0)
		{
			for (int i = 0; i < winStack.Size(); i++)
				console.printf(string.Format("Window : %s, has priority : %d", winStack[i].Name, winStack[i].Priority));
			console.printf(string.format("Priority Stack Index is : %d", priorityStackIndex));
			console.printf(string.format("Ignoring Duplicate Posts: %d", ignorePostDuplicate));
		}
		else
			console.printf("ZEvent System does not contain any windows.");
	}
	/*
		Oooo!  Glad I added this in, I was suspicious that deletion was going to leave
		dangling pointers and sure enough, you can orphan thinkers if controls are not
		set to be deleted as well.
	*/
	private void debugGetGlobalObjectCount()
	{
		int zcount = 0;
		ThinkerIterator zobjfinder = ThinkerIterator.Create("ZObjectBase");
		Thinker t;
		while (t = ZObjectBase(zobjfinder.Next()))
			zcount++;
		console.printf(string.Format("ZEvent System found %d ZObjects in the present level.", zcount));
	}
	
	private void debugGetEventGlobalCount() { console.printf(string.Format("ZEvent System is accounting for %d objects in its global array.", allZObjects.Count())); }
	
	private void debugPrintOutEveryName(ZABST_Node node)
	{
		console.printf(string.Format("Object name: %s, has hash value: %d, has tree balance: %d, has a left child: %s, has a right child: %s", node.ObjectName, node.Hash, node.Balance, node.Left ? "yes" : "no", node.Right ? "yes" : "no"));
		if (node.Left)
			debugPrintOutEveryName(node.Left);
		if (node.Right)
			debugPrintOutEveryName(node.Right);
	}
	
	private void debugGetTreeBalance() { console.printf(string.Format("ZEvent Global Tree has a %d balance factor", allZObjects.GetRootBalance())); }
	
	/*
		Cursor packet - contains the cursor data
	*/
	private ZUIEventPacket cursor;
	
	/*
		Event packets - this is for events that need executed by UITick
	*/
	private array<ZEventPacket> incomingEvents;
	void AddEventPacket(string n, int fa, int sa, int ta) { incomingEvents.Push(new("ZEventPacket").Init(n, fa, sa, ta)); }
	private void clearUIEvents() { if (incomingEvents.Size() > 0) incomingEvents.Clear(); }
	
	/*
		QuikClose Input Nullifier
		
		This is set to true when a control needs MOST of the keyboard for input,
		like text boxes, so only the Esc key will toggle UI mode.
		
		This is set only through a net command.
	*/
	private bool bNiceQuikClose;
	private void quikCloseInputRangeLimit(bool limit) { bNiceQuikClose = limit; }
	
	//
	// - ZSCRIPT METHODS - In definition order
	// ---------------------------------------
	// - Well, ZScript Windows stuff was supposed to
	// - stay on it's own side of the comments but keeping
	// - things organized means some stuff is here too,
	// - but it's support stuff, like NetworkProcess_String
	// - and the enumeration stuff.
	//
	
	/*
		First-time setup
		
	*/
	override void OnRegister()
	{
		// Get the lowest unused order value
		SetOrder(GetLowestPossibleOrder());
		// Say hello the game world
		console.printf(string.format("ZScript Windows v%s - Window Event System Registered with Order %d for Player #%d - Welcome!", ZSHandlerUtil.ZVERSION, self.Order, consoleplayer));
		// If this isn't -1 stuff thinks there's stuff going on, 0 is a valid stack index
		priorityStackIndex = -1;
		ignorePostDuplicate = false;
		bNiceQuikClose = false;
		allZObjects = new("ZABST").Init();
		cursor = new("ZUIEventPacket").Init(0, 0, "", 0, 0, 0, false, false, false);
	}
	
	/*
		Catch for creating windows through line events
	
	*/
	override void WorldLineActivated(WorldEvent e)
	{
		if (e.ActivatedLine)
		{
			bool enabled, show, uitoggle;
			string wname, classname;
			float xloc, yloc, alpha;
			int player, clip;
			
			enabled = e.ActivatedLine.GetUDMFInt("user_enabled");
			show = e.ActivatedLine.GetUDMFInt("user_show");
			classname = e.ActivatedLine.GetUDMFString("user_windowclass");
			wname = e.ActivatedLine.GetUDMFString("user_windowname");
			uitoggle = e.ActivatedLine.GetUDMFInt("user_uitoggle");
			player = e.ActivatedLine.GetUDMFInt("user_consoleplayer");
			clip = e.ActivatedLine.GetUDMFInt("user_cliptype");
			xloc = e.ActivatedLine.GetUDMFFloat("user_xlocation");
			yloc = e.ActivatedLine.GetUDMFFloat("user_ylocation");
			alpha = e.ActivatedLine.GetUDMFFloat("user_alpha");
			
			if (wname != "")  // Probably safe to assume the line isn't trying to make a window
			{				  // Also saves a call to ClassNameIsAClass - oh god call that only if you have to
				if (classname != "" && ClassNameIsAClass(classname))
					windowPackets.Push(new("ZWindowPacket").Init(enabled, show, uitoggle, wname, classname, clip, xloc, yloc, alpha, player));
				else
					console.printf(string.Format("\nZSWIN Event System - Line Activation ERROR!\nLine with index #%d, executing special #%d tried to create an invalid window class \"%s\"!\n\nPLEASE CHECK YOUR \"user_windowclass\" UDMF VARIABLE FOR THE CORRECT CLASS NAME!\nTHIS TYPE OF FAILURE IS COSTLY ON THE SYSTEM DUE TO ERROR CHECKING.  PLEASE CORRECT THE PROBLEM.", e.ActivatedLine.Index(), e.ActivatedLine.Special, className));
			}
		}
	}
	
	/*
		Guess what?  You call "new" with an invalid class name and the VM crashes.
		This protects the system by ensuring that whatever string
		WorldLineActivated gets for a classname is actually a class.
		And guess how it does it?  By a search of the global AllClasses array.
		Maybe I should bold that - BY SEARCHING THE ALLCLASSES ARRAY.
		
		This isn't the world's worst thing, but it can and will get costly in mods
		that add say hundreds of classes to the game.  EVERYTHING is going get 
		searched here. So for the base games that's bad enough.  Russian Overkill,
		Brutal Doom, Beautiful Doom, Total Chaos, Reelism...must I go on?
		
		BoA, HD, Samsara.  Ok, I'll stop, I think the point is made.
		
		This method is important enough though that it is public for wider system use.
	*/
	bool ClassNameIsAClass(string classname)
	{
		for (int i = 0; i < AllClasses.Size(); i++)  // The vm gods have to hate me
		{
			if (AllClasses[i].GetClassName() == classname)
				return true;
		}
		// Oh boy the worst case scenario - we just ran the whole array and got nill - what a waste of processing time.
		// Should just abort the vm here with a big old hcf instead of being nice and error messaging.
		// If you can't tell, I HATE this WorldLineActivated thing.  I mean - seriously - it has to be protected like this,
		// it can get called from any old line that get activated with the damn UDMF variables - this restricts it to UDMF
		// maps.  This method sucks, just plain sucks.  I don't like it.  And I hate supporting it.  Simple as that.
		console.Printf("ZScript Windows would like to thank you for wasting processing time searching the AllClasses array for the class name, %s, which is an invalid class name.\nPlease fix your mod, or alert the mod author, to the problem - this is an unacceptable waste of processing time and this feature will be removed if it is abused.");
		return false;
	}
	
	/*
		Window Drawer - Remember! This is called multiple times per tick
		and always after UiTick!
	
	*/
	override void RenderOverlay(RenderEvent e)
	{
		for (int i = winStack.Size() - 1; i >= 0; i--)
		{
			let nwd = GetWindowByPriority(i);
			if (nwd && nwd.PlayerClient == consoleplayer && nwd.Show && !nwd.bSelfDestroy)
				nwd.ObjectDraw(winStack[i]);
		}
	}
	
	/*
		Receives input events when the handler is in UI Mode
	
	*/
	override bool UiProcess(UiEvent e)
	{		
		// Handler Events - This is anything specific the handler needs to do based on an input.
		switch (e.Type)
		{
			case UiEvent.Type_None:			
				break;
			case UiEvent.Type_KeyDown:
				// This results in a NetworkProcess_String call where the QuikClose check is processed
				// KeyString is used to check various binds, KeyChar is used to check specific keys (Esc and tilde)
				zEventCommand(string.Format("zevsys_QuikCloseCheck,%s", e.KeyString), consoleplayer, e.KeyChar);
				break;
			case UiEvent.Type_KeyRepeat:
				break;
			case UiEvent.Type_KeyUp:
				// Check if the key is the bind for the cursor toggle
				if (!bNiceQuikClose && KeyBindings.NameKeys(Bindings.GetKeysForCommand("zswin_cmd_cursorToggle"), 0) ~== e.KeyString)
					zEventCommand("zevsys_UI_CursorToggle", consoleplayer);
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
		
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].PlayerClient == consoleplayer)
			{
				if (winStack[i].ZObj_UiProcess(new("ZUIEventPacket").Init(e.Type, consoleplayer, e.KeyString, e.KeyChar, e.MouseX, e.MouseY, e.IsShift, e.IsAlt, e.IsCtrl)))
					break;
			}
		}
		
		zEventCommand(string.Format("zevsys_UpdateCursorData,%d,%d,%s,%d,%d,%d", e.Type, consoleplayer, e.KeyString, e.KeyChar, e.MouseX, e.MouseY), e.IsShift, e.IsAlt, e.IsCtrl);
		//SendNetworkEvent(string.Format("zswin_UpdateCursorData:%d:%d:%s:%d:%d:%d", e.Type, consoleplayer, e.KeyString, e.KeyChar, e.MouseX, e.MouseY), e.IsShift, e.IsAlt, e.IsCtrl);
		
		return false;
	}
	
	/*
		Window Driver - Remember! This is called only once per game tick,
		always before RenderOverlay, and is how any window maninpulation happens!
	
	*/
	override void UiTick()
	{			
		// Call Window Events
		zEventCommand("zevsys_CallWindowEvents", consoleplayer);
		
		// Deletion
		if (outgoingWindows.Size() > 0)
			zEventCommand("zevsys_DeleteOutgoingWindows", consoleplayer);
		// Priority
		if (priorityStackIndex != -1 && incomingWindows.Size() == 0)
			zEventCommand("zevsys_PrioritySwitch", consoleplayer);
		// Window Packets - they get added to incoming if valid
		if (windowPackets.Size() > 0)
			zEventCommand("zevsys_AddPacketsToIncoming", consoleplayer);
		// Incoming
		if (incomingWindows.Size() > 0)
			zEventCommand("zevsys_AddIncomingToStack", consoleplayer);
		// All objects get added to the global arrays
		if (incomingZObjects.Size() > 0)
			zEventCommand("zevsys_AddObjectToGlobalObjects", consoleplayer);
		
		// Incoming events from the last tick - this would be events send from UI scoped methods
		if (incomingEvents.Size() > 0)
		{
			for (int i = 0; i < incomingEvents.Size(); i++)
				zEventCommand(incomingEvents[i].EventName, consoleplayer, incomingEvents[i].FirstArg, incomingEvents[i].SecondArg, incomingEvents[i].ThirdArg);
			zEventCommand("zevsys_ClearIncomingUIEvents", consoleplayer);
		}
		
		// Call the window UiTick - this is done last, all other things should be done so
		// this should be a safe place for windows to do their thing.
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].PlayerClient == consoleplayer)
			{
				if(winStack[i].ZObj_UiTick())
					break;
			}
		}
	}
	
	/*
		Receives input when the handler is not in UI Mode
	
	*/
	override bool InputProcess(InputEvent e)
	{
		if (e.Type == InputEvent.Type_KeyUp && keyIsCursorBind(e.KeyScan))
			zEventCommand("zevsys_CursorToggle", consoleplayer);
			//SendNetworkEvent("zswin_CursorToggle");
		return false;
	}
	
	/*
		Communication server - anything going between scopes passes through here
	
	*/
	enum ZNETCMD
	{
		ZNCMD_AddIncoming,
		ZNCMD_PrioritySwitch,
		ZNCMD_UpdateCursorData,
		ZNCMD_ClearUIIncoming,
		ZNCMD_QuickCloseCheck,
		ZNCMD_CursorToggle,
		ZNCMD_CallWindowEvents,
		ZNCMD_DeleteOutgoingWindows,
		ZNCMD_AddPacketsToIncoming,
		ZNCMD_AddObjectToGlobalObjects,
		
		ZNCMD_HandlerIncomingGlobal,		
		ZNCMD_AddToUITicker,
		ZNCMD_SetWindowForDestruction,
		ZNCMD_PostStackIndex,
		ZNCMD_AddWindowToStack,
		ZNCMD_ControlFullInput,

		ZNCMD_ControlUpdate,
		ZNCMD_LetAllPost,
		
		ZNCMD_ManualStackSizeOut,
		ZNCMD_ManualStackPriorityOut,
		ZNCMD_ManualGlobalZObjectCount,
		ZNCMD_ManualEventGlobalCount,
		ZNCMD_ManualGlobalNamePrint,
		ZNCMD_ManualGetTreeBalance,
		
		ZNCMD_TryString,
	};
	
	/*
		Converts a string to a ZNETCMD
	*/
	private ZNETCMD stringToZNetworkCommand(string e)
	{
		// Internal commands - these are sent from within the Event System
		if (e ~== "zevsys_AddIncomingToStack")
			return ZNCMD_AddIncoming;
		if (e ~== "zevsys_PrioritySwitch")
			return ZNCMD_PrioritySwitch;
		if (e ~== "zevsys_UpdateCursorData")
			return ZNCMD_UpdateCursorData;
		if (e ~== "zevsys_ClearIncomingUIEvents")
			return ZNCMD_ClearUIIncoming;
		if (e ~== "zevsys_QuikCloseCheck")
			return ZNCMD_QuickCloseCheck;
		if (e ~== "zevsys_UI_CursorToggle" || e ~== "zevsys_CursorToggle")
			return ZNCMD_CursorToggle;
		if (e ~== "zevsys_CallWindowEvents")
			return ZNCMD_CallWindowEvents;
		if (e ~== "zevsys_DeleteOutgoingWindows")
			return ZNCMD_DeleteOutgoingWindows;
		if (e ~== "zevsys_AddPacketsToIncoming")
			return ZNCMD_AddPacketsToIncoming;
		if (e ~== "zevsys_AddObjectToGlobalObjects")
			return ZNCMD_AddObjectToGlobalObjects;

		// External Commands - these are sent from ZObjects
		if (e ~== "zevsys_AlertHandlersToNewGlobal")
			return ZNCMD_HandlerIncomingGlobal;
		if (e ~== "zevsys_AddToUITicker")
			return ZNCMD_AddToUITicker;
		if (e ~== "zevsys_SetWindowForDestruction")
			return ZNCMD_SetWindowForDestruction;
		if (e ~== "zevsys_PostPriorityIndex")
			return ZNCMD_PostStackIndex;
		if (e ~== "zevsys_AddWindowToStack")
			return ZNCMD_AddWindowToStack;
		if (e ~== "zevsys_ControlFullInput")
			return ZNCMD_ControlFullInput;
		
		if (e ~== "zobj_ControlUpdate")
			return ZNCMD_ControlUpdate;
		if (e ~== "zobj_LetAllPost")
			return ZNCMD_LetAllPost;
		
		// Manual Commands
		if (e ~== "zswin_stacksizeout")
			return ZNCMD_ManualStackSizeOut;
		if (e ~== "zswin_stackpriorityout")
			return ZNCMD_ManualStackPriorityOut;
		if (e ~== "zswin_globalobjectcount")
			return ZNCMD_ManualGlobalZObjectCount;
		if (e ~== "zswin_eventglobalcount")
			return ZNCMD_ManualEventGlobalCount;
		if (e ~== "zswin_printallnames")
			return ZNCMD_ManualGlobalNamePrint;
		if (e ~== "zswin_gettreebalance")
			return ZNCMD_ManualGetTreeBalance;
		// All else fails, try to string process the command
		else
			return ZNCMD_TryString;
	}
	
	/*
		EVENT COMMAND FORMATTING
		
		ZScript Windows reserves the following characters for
		formatted command strings:
		
		? : ,
		
		Question Mark Usage
		 - This character is reserved exclusively for internal use.
		 - This character separates the command string from the player client
		 
		Colon Usage
		 - This character separates individual commands
		 
		Comma Usage
		 - This character separates commands and arguments
		 
		Example
		
		zcmd_CommandA,data_argX:zcmd_CommandB,data_argY?playerClient
		
		Command Processing Logic:
		-------------------------
		Step 1 - NetworkProcess
			- Try to split the command string into the command and the player ID
			- If that succeeds and the player ID is the same as the consoleplayer,
			  attempt to figure out what the command is.
			- Simple commands are processed here that don't require further processing.
		Step 2 - NetworkProcess_String
			- If command conversion returns TryString, the entire ConsoleEvent is passed
			  along and the process restarts.
			- Assuming the command is for a valid player, the string processing of the
			  command functions as follows:
					1 - Split the string with a colon (:) as a delimiter.  These strings
					    are treated as individual commands, possibly with arguments.
					2 - Execute each command sequentially.  Attempt to split each command
					    string with a comma (,) as a delimiter.  The first string in the
						array is treated as the command, and all others as arguments.
		Step 3 - ZObject Event Extension
			- Regardless of what occurred in the previous steps, the entire contents of
			  ConsoleEvent data is replicated and passed to valid ZObjects, in this case
			  ZSWindows, through ZEventPackets.
			- Command processing at this stage is at the discretion of the control.
			
			
		Command Specifics:
		------------------
		AddToUITicker - This command will create an event packet to be processed by the UITicker
						event of the Event Systetm, containing a second command and arguments,
						to be executed by the net command system.
					  - Command follows the standard command format.
					  - Example: this command will add "zobj_ControlUpdate" and the ZObject's name to the command queue.
							ZNetCommand(string.Format("zevsys_AddToUITicker,zobj_ControlUpdate,%s", self.Name));
							
	*/
	clearscope private void zEventCommand(string cmd, int plyr_id, int arg_a = 0, int arg_b = 0, int arg_c = 0)
	{
		SendNetworkEvent(string.Format("%s?%d", cmd, plyr_id), arg_a, arg_b, arg_c);
	}
	
	/*
		Main context communication method
	*/
	override void NetworkProcess(ConsoleEvent e)
	{
		Array<string> cmdc;
		e.Name.Split(cmdc, "?");		
		if (cmdc.Size() == 2 ? (cmdc[1].ToInt() == consoleplayer) : false)
		{
			if (!e.IsManual)  // there's no reason any of these events should ever be manually called
			{
				switch (stringToZNetworkCommand(cmdc[0]))
				//switch (stringToZNetworkCommand(e.Name))
				{
					case ZNCMD_AddIncoming:
						passIncomingToStack();
						break;
					case ZNCMD_PrioritySwitch:
						windowPrioritySwitch();
						break;
					case ZNCMD_ClearUIIncoming:
						clearUIEvents();
						break;
					case ZNCMD_CursorToggle:
						cursorToggle();
						break;
					case ZNCMD_CallWindowEvents:
						windowEventCaller();
						break;
					//case ZNCMD_SetWindowForDestruction:
						//setWindowForDestruction(e.Args[0]);
						//break;
					case ZNCMD_DeleteOutgoingWindows:
						deleteOutgoingWindows();
						break;
					case ZNCMD_AddPacketsToIncoming:
						passPacketsToIncoming();
						break;
					case ZNCMD_AddObjectToGlobalObjects:
						passIncomingToGlobalObjects();
						break;
					case ZNCMD_ControlFullInput:
						quikCloseInputRangeLimit(e.Args[0]);
						break;
					case ZNCMD_LetAllPost:
						letAllPost();
						break;
					// String Processing
					default:
						NetworkProcess_String(e);
						break;
				}
			}
			else // These may be called manually - mostly debugging stuff
			{
				switch (stringToZNetworkCommand(e.Name))
				{
					case ZNCMD_ManualStackSizeOut:
						debugStackSizeToConsole();
						break;
					case ZNCMD_ManualStackPriorityOut:
						debugStackPriorityToConsole();
						break;
					case ZNCMD_ManualGlobalZObjectCount:
						debugGetGlobalObjectCount();
						break;
					case ZNCMD_ManualEventGlobalCount:
						debugGetEventGlobalCount();
						break;
					case ZNCMD_ManualGlobalNamePrint:
						debugPrintOutEveryName(allZObjects.Root);
						break;
					case ZNCMD_ManualGetTreeBalance:
						debugGetTreeBalance();
						break;
				}
			}
		}
		// These are a select few commands that will be sent normally
		else
		{
			if (!e.IsManual)
			{
				Array<string> cmde;
				e.Name.Split(cmde, ":");
				for (int i = 0; i < cmde.Size(); i++)
				{
					if (cmde[i] != "")
					{
						Array<string> cmd;
						cmde[i].Split(cmd, ",");
						if (cmd.Size() > 0)
						{
							switch (stringToZNetworkCommand(cmd[0]))
							{
								case ZNCMD_HandlerIncomingGlobal:
									if (cmd.Size() == 2)
										addObjectToGlobalObjects(cmd[1]);
									else
										console.printf("Invalid attempt to add ZObject to globals!");
									break;
								case ZNCMD_SetWindowForDestruction:
									if (cmd.Size() == 2)
										setWindowForDestruction(cmd[1]);
									else
										console.printf("Invalid attempt to set window for destruction!");
									break;
								case ZNCMD_AddWindowToStack:
									if (cmd.Size() == 2)
										addWindowToStack(cmd[1]);
									else
										console.printf("Invalid attempt to add window to stack!");
									break;
							}
						}
					}
				}
			}
			else {}
		}
		
		for (int i = 0; i < winStack.Size(); i++)
		{
			if (winStack[i].PlayerClient == consoleplayer)
			{
				if (winStack[i].ZObj_NetProcess(new("ZEventPacket").Init(e.Name, e.Args[0], e.Args[1], e.Args[2], e.Player, e.IsManual)))
					break;
			}
		}
	}
	
	/*
		Processing for more complicated net events that 
		send information through their name
	*/
	private void NetworkProcess_String(ConsoleEvent e)
	{
		Array<string> cmdPlyr;
		e.Name.Split(cmdPlyr, "?");
		if (cmdPlyr.Size() == 2 ? (cmdPlyr[1].ToInt() == consoleplayer) : false)
		{
			Array<string> cmdc;
			cmdPlyr[0].Split(cmdc, ":");
			for (int i = 0; i < cmdc.Size(); i++)
			{
				if (cmdc[i] != "")
				{
					Array<string> cmd;
					cmdc[i].Split(cmd, ",");
					if (cmd.Size() > 0)
					{
						switch (stringToZNetworkCommand(cmd[0]))
						{
						case ZNCMD_UpdateCursorData:
							if (cmd.Size() != 7)
								console.printf(string.format("Update Cursor from Event System received %d args!", cmd.Size()));
							else
								updateCursorData(cmd[1].ToInt(), cmd[2].ToInt(), cmd[3], cmd[4].ToInt(), cmd[5].ToInt(), cmd[6].ToInt(), e.Args[0], e.Args[1], e.Args[2]);
							break;
						case ZNCMD_AddToUITicker:
							// Instead of having some special format for this command
							// this just jams the string back together to create the
							// event name.
							if (cmd.Size() >= 2)
							{
								string addCmd = cmd[1];
								bool addPkt = true;
								int cmdArgs = 0;
								if (cmd.Size() > 2)
								{
									for (cmdArgs = 2; cmdArgs < cmd.Size(); cmdArgs++)
									{
										if (cmd[cmdArgs] != "")
											addCmd.AppendFormat(",%s", cmd[cmdArgs]);
										else
										{
											addPkt = false;
											break;
										}
									}
								}
								if (addPkt)
									AddEventPacket(addCmd, e.Args[0], e.Args[1], e.Args[2]);
								else
									console.printf(string.Format("Add To UI Ticker got an empty argument adding \"%s\" at index, %d", addcmd, cmdArgs));
							}
							break;
						case ZNCMD_QuickCloseCheck:
							if (cmd.Size() == 2)
								quickCloseCheck(cmd[1], e.Args[0]);
							else
								console.printf("Quik Close Check did not get a valid key string!");
							break;
						case ZNCMD_ControlUpdate:
							if (cmd.Size() == 2)
								controlUpdateEvent(cmd[1]);
							else
								console.printf("Control Update did not get a valid control name!");
							break;
						case ZNCMD_PostStackIndex:
							if (cmd.Size() == 2)
								postPriorityIndex(cmd[1], e.Args[0]);
							else
								console.printf("Post Stack Index did not get a valid window name!");
							break;
						default:
							/* debug out if it's on, otherwise this net command probably came from something else */
							break;
						}
					}
					else { /* probably smart to hcf here, becuz what now?  there's some fuckery here. just no, you broke it or something. */}
				}
			}
		}
	}
	
	//
	// - ZSCRIPT WINDOWS
	// -----------------
	//
	
	/*
		Windows - and only windows - have to call this IN IMPLEMENTATION
		to have the instance added to the window stack.
		
		This has to be done by the windows themselves because ZObjectBase is
		the base of all objects, so this cannot be done in the base.
		
		As demonstrated in the ImpWindow, this is supposed to be called as part
		of the final descendent's Init return.  This method passs it's zobj argument
		back up to its caller.
		
		Just like all things, this cannot be done instantaneously, this has
		to be done on the next UiTick, so incoming windows go to the incomingWindows
		array and will be added in next tick.
		
		This method attempts to protect the window stack by not accepting
		any null references, the reference must be a ZSWindow descendent, and the object
		Name may not be empty (further name restrictions may be put in place if certain
		words require string conversions)
	
	*/
	//ZObjectBase AddWindowToStack(ZObjectBase zobj)
	private void addWindowToStack(string n)
	{
		ThinkerIterator nwdFinder = ThinkerIterator.Create("ZSWindow");
		ZSWindow enwd;
		while (enwd = ZSWindow(nwdFinder.Next()))
		{
			if (enwd.Name ~== n)
				break;
		}
		
		if (enwd != null ? (enwd is "ZSWindow" ? (enwd.Name != "" && NameIsUnique(enwd.Name)) : false) : false)
			incomingWindows.Push(enwd);
		else if (enwd != null)
		{
			if (enwd is "ZSWindow")
			{
				/* debug message invalid name */
				//zobj.bSelfDestroy = true;
				// this should be ok for a window not in the stack,
				// but right now ZObjectBase does not do anything with its ticker
				// so detecting the window needs destroyed isn't there.
			}
			else
			{/* debug messaage invalid object */}
		}
		else
			HaltAndCatchFire(" - - NOPE!  EITHER AddWindowToStack WAS CALLED FROM AN INVALID USE OR\n - - MEMORY MANAGEMENT IS BROKEN AND SO IS THE GAME!\n - - AddWindowToStack RECEIVED NULL WINDOW REFERENCE!");
	}
	
	/*
		Moves incoming windows to the stack
	*/
	private void passIncomingToStack()
	{
		for (int i = 0; i < winStack.Size(); i++)
			winStack[i].Priority += incomingWindows.Size();
		
		// Not sure abut append without testing so we'll just use push
		for (int i = 0; i < incomingWindows.Size(); i++)
		{
			if (i < incomingWindows.Size() - 1)
				incomingWindows[i].Priority = (winStack.Size() == 0 ? 1 : winStack.Size()) + i;
			else
				incomingWindows[i].Priority = 0;
			winStack.Push(incomingWindows[i]);
		}
		
		incomingWindows.Clear();
	}
	
	/*
		Moves window packets to the incoming list
	*/
	private void passPacketsToIncoming()
	{
		for (int i = 0; i < windowPackets.Size(); i++)
		{
			let zobj = new(windowPackets[i].ClassName);
			if (zobj && zobj is "ZSWindow")
				incomingWindows.Push(ZSWindow(zobj).Make(null, windowPackets[i].Enabled, windowPackets[i].Show, windowPackets[i].WindowName, windowPackets[i].playerClient, windowPackets[i].UiToggle,
												windowPackets[i].ClipType, windowPackets[i].xLocation, windowPackets[i].yLocation, windowPackets[i].Alpha));
		}
		
		windowPackets.Clear();
	}
	
	/*
		Finds the ZObject with the give name, and adds
		that object to the incoming objects list.
		
	*/
	private void addObjectToGlobalObjects(string n)
	{
		ThinkerIterator zobjFinder = ThinkerIterator.Create("ZObjectBase");
		ZObjectBase zobj;
		while (zobj = ZObjectBase(zobjFinder.Next()))
		{
			if (zobj.Name ~== n ? NameIsUnique(zobj.Name) : false)
			{
				incomingZObjects.Push(zobj);
				break;
			}
			else if (zobj.Name ~== n ? !NameIsUnique(zobj.Name) : false)
			{
				// Destroy object and debug out invalid name
				break;
			}
		}
	}
	
	/*
		Adds any objects in the incoming array to the allZObjects array.
	*/
	private void passIncomingToGlobalObjects()
	{
		for (int i = 0; i < incomingZObjects.Size(); i++)
			allZObjects.Insert(incomingZObjects[i], incomingZObjects[i].Name);
		incomingZObjects.Clear();
	}
	
	/*
		Calls the ObjectUpdate method on an object at the given
		global index.
	*/
	private void controlUpdateEvent(string controlName)
	{
		let zobj = FindZObject(controlName);
		if (zobj)
			zobj.ObjectUpdate();
	}
	
	/*
		Called by an object to signal that the window at the given
		window stack index needs to be priority 0.
	*/
	private void postPriorityIndex(string n, bool Ignore = false) 
	{
		if (!ignorePostDuplicate)
		{
			priorityStackIndex = GetStackIndex(GetWindowByName(n)); 
			winStack[priorityStackIndex].EventInvalidate();
			ignorePostDuplicate = Ignore;
		}
	}
	
	/*
		Performs the actual priority switch on the window stack.
		This has no impact on a window's controls.
	*/
	private void windowPrioritySwitch()
	{
		if (winStack[priorityStackIndex].Priority > 0)
		{
			array<int> plist;
			for (int i = 0; i < winStack.Size(); i++)
			{
				if (i == priorityStackIndex)
					plist.Push(0);
				else if (winStack[i].Priority < winStack.Size() - 1)
					plist.Push(winStack[i].Priority + 1);
				else
					plist.Push(winStack[i].Priority);
			}
			
			if (plist.Size() == winStack.Size())
			{
				for (int i = 0; i < plist.Size(); i++)
					winStack[i].Priority = plist[i];
			}
		}
		
		priorityStackIndex = -1;
	}
	
	private void letAllPost() { ignorePostDuplicate = false; }
	
	/*private void windowShowCheckEnabled(int wsi, bool t)
	{
		if (t)
			winStack[wsi].Enabled = true;
		else
		{
			winStack[wsi].EnabledLog();
			winStack[wsi].Enabled = false;
		}
	}*/

	/*
		Sends the toggle cursor event, if UI processing
		isn't already on.
	
	*/
	void SendUIToggleEvent()
	{
		if (!self.IsUiProcessor)
			zEventCommand("zevsys_UI_cursorToggle", consoleplayer);
			//SendNetworkEvent("zswin_UI_cursorToggle");
	}
	
	/*
		Toggles the system bools required for mouse control
	*/
	private void cursorToggle()
	{
		self.IsUiProcessor = !self.IsUiProcessor;
		self.RequireMouse = !self.RequireMouse;		
	}
	
	/*
		This method iterates the window stack and calls the
		window events based on the cursor event.
	*/
	private void windowEventCaller()
	{
		for (int i = 0; i < winStack.Size(); i++)
		{
			// Window must be for the current player, window must be shown, and window must be enabled to be interacted with
			if (winStack[i].PlayerClient == consoleplayer && winStack[i].Show && winStack[i].Enabled)
			{
				switch (cursor.EventType)
				{
					case ZUIEventPacket.EventType_MouseMove:
						winStack[i].OnMouseMove(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_LButtonDown:
						winStack[i].OnLeftMouseDown(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_LButtonUp:
						winStack[i].OnLeftMouseUp(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_LButtonClick:
						winStack[i].OnLeftMouseClick(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_MButtonDown:
						winStack[i].OnMiddleMouseDown(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_MButtonUp:
						winStack[i].OnMiddleMouseUp(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_MButtonClick:
						winStack[i].OnMiddleMouseClick(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_RButtonDown:
						winStack[i].OnRightMouseDown(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_RButtonUp:
						winStack[i].OnRightMouseUp(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_RButtonClick:
						winStack[i].OnRightMouseClick(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_WheelUp:
						winStack[i].OnWheelMouseDown(cursor.EventType);
						break;
					case ZUIEventPacket.EventType_WheelDown:
						winStack[i].OnWheelMouseUp(cursor.EventType);
						break;
					default:
					case ZUIEventPacket.EventType_None:
						winStack[i].WhileMouseIdle(cursor.EventType);
						break;
				}
			}
		}		
	}
	
	/*
		Adds the given window stack index the list of windows to be deleted.
	*/
	private void setWindowForDestruction(string n)
	{
		outgoingWindows.Push(GetStackIndex(GetWindowByName(n)));
	}
	
	/*
		Think this looks bad?  Look at removeOutgoingFromGlobal, which this method calls.
		
		This is the process by which windows and their controls are deleted from the system
		and the level.  This is actually stupid levels of important, not just because of the
		VM crash that will happen if this isn't done right, but because ZScript Windows has
		found a way to circumvent the engine's garbage collection, through basically its own
		memory management.  If a ZObject is not destroyed when it is removed from any part of
		the ZScript Windows code, that object has no references to it of any meaningful value.
		Under the hood the gc should still have the thinker it is reference lists, there may
		be some lingering references in scripts or other actors, but unless something actually
		does something with the ZObject references, they just sit there consuming memory.
		
		This means, at least hypothetically, it should be possible to crash the engine through
		what is essentially a memory leak by creating ZObjects, then removing them from the
		ZEvent System without deleting them from the game.  You would have to do this a really
		ridiculous number to times to cause the crash.  You also could see this take place
		through something as simple as the Windows Task Manager; just watch the memory usage of
		the engine, I used to do that with old Z-Windows when I had memory problems.
		
		But this is solved with the code below.  You delete a window, it and it's controls
		go away, for good.  Turn it off if you want it to persist but not be on the player's screen.
		
		The real problem here is the linear lists used for everything, if I had
		binary trees, especially AVL trees, I could do this with an O(log n) time instead of
		whatever monsterous hell this is - mostly linear, might be capable of exponetial time
		under the right circumstances (deleting every window and control currently in the system).
	*/
	private void deleteOutgoingWindows()
	{
		array<ZObjectBase> newStack;
		// Iterate through the entire stack
		for (int i = 0; i < winStack.Size(); i++)
		{
			// Compare each window to the outgoing list
			bool notOutgoing = true;
			for (int j = 0; j < outgoingWindows.Size(); j++)
			{
				// This window is getting deleted
				if (i == outgoingWindows[j])
				{
					notOutgoing = false;
					// Remove every reference from the global array
					removeOutgoingFromGlobal(winstack[i]);
					
					// Go find every window of lesser priority and decrease it's priority value by 1
					for (int k = winStack[i].Priority + 1; k < winStack.Size(); k++)
						GetWindowByPriority(k).Priority -= 1;
					break;
				}
			}
			
			// Window's not getting deleted.
			if (notOutgoing)
				newStack.Push(winStack[i]);
		}
		
		// Last step before the stack gets anhiliated - tell the windows getting deleted to delete themselves.
		for (int i = 0; i < outgoingWindows.Size(); i++)
			winStack[outgoingWindows[i]].bSelfDestroy = true;
		
		outgoingWindows.Clear();
		winStack.Clear();
		winStack.Move(newStack);
	}
	
	/*
		This is the second half of deletion.
		This method removes ZObjects from the global array.
		
		Since the global array is not an array but a tree, should just
		be able to call Delete on the tree and give it the object name.
		
		However there is still the need to removing incoming events
	*/
	private void removeOutgoingFromGlobal(ZObjectBase zobj)
	{
		/*array<ZObjectBase> newGlobal;
		for (int i = 0; i < allZObjects.Count; i++)
		{
			bool notOutgoing = true;
			if (allZObjects[i].Name ~== zobj.Name)
				notOutgoing = false;
			else if (zobj is "ZSWindow") // idk how this wouldn't be the case
			{
				for (int j = 0; j < ZSWindow(zobj).GetControlSize(); j++)
				{
					if (ZSWindow(zobj).GetControlByIndex(j) is "ZSWindow")
						removeOutgoingFromGlobal(ZSWindow(zobj).GetControlByIndex(j));
					else if (allZObjects[i].Name ~== ZSWindow(zobj).GetControlByIndex(j).Name)
					{
						notOutgoing = false;
						break;
					}
				}
			}
			
			if (!notOutgoing && incomingEvents.Size() > 0)
			{
				array<bool> deleteIndex;
				deleteIndex.Reserve(incomingEvents.Size());
				for (int j = 0; j < deleteIndex.Size(); j++)
					deleteIndex[j] = false;
				
				for (int j = 0; j < incomingEvents.Size(); j++)
				{
					if (incomingEvents[j].EventName ~== "zswin_ControlUpdate" && incomingEvents[j].FirstArg == i)
						deleteIndex[j] = true;
				}
				
				array<ZEventPacket> newPackets;
				for (int j = 0; j < deleteIndex.Size(); j++)
				{
					if (!deleteIndex[j])
						newPackets.Push(incomingEvents[j]);
				}
				incomingEvents.Clear();
				incomingEvents.Move(newPackets);
			}
			
			if (notOutgoing)
				newGlobal.Push(allZObjects[i]);
		}
		
		allZObjects.Clear();
		allZObjects.Move(newGlobal);*/
	}
	
	/*
		Wrapper for checking if the given key is the bind for the cursor toggle
	*/
	clearscope private bool keyIsCursorBind(int keyId)
	{
		int key1, key2;
		[key1, key2] = Bindings.GetKeysForCommand("zswin_cmd_cursorToggle");
		return ((key1 && key1 == keyId) || (key2 && key2 == keyId));
	}
	
	/*
		Checks if the given key is any of the supportted keys for QuikClose.
		
		Future expansion should hopefully support Esc and tilde (~)
		
		Woohoo!  QuikClose now supports Esc and tilde!
	*/
	private void quickCloseCheck(string keyId, int askey)
	{
		int key1, key2;
		bool quikclose = false;
		
		// Esc key - this is always checked
		if (askey == 27)
			quikclose = true;
		
		// If a control isn't needing full keyboard control - check the tilde key and binds
		if (!bNiceQuikClose)
		{
			// tilde key
			if (askey == 96)
				quikclose = true;
			// The rest are key binds - pretty self explanatory
			[key1, key2] = Bindings.GetKeysForCommand("+forward");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+back");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+moveleft");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+moveright");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+left");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+right");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("turn180");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+jump");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("+crouch");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
			[key1, key2] = Bindings.GetKeysForCommand("crouch");
			if(KeyBindings.NameKeys(key1, key2) ~== keyId)
				quikclose = true;
		}
		
		if (quikclose)
			zEventCommand("zevsys_UI_CursorToggle", consoleplayer);
	}
	
	/*
		Gets the cursor packet from the last tick.
	*/
	private void updateCursorData(int type, int player, string key, int kchar, int mx, int my, bool ishft, bool ialt, bool ictrl)
	{
		cursor.EventType = type;
		cursor.PlayerClient = player;
		cursor.KeyString = key;
		cursor.KeyChar = kchar;
		cursor.MouseX = mx;
		cursor.MouseY = my;
		cursor.IsShift = ishft;
		cursor.IsAlt = ialt;
		cursor.IsCtrl = ictrl;
	}
	
	/* - END OF METHODS - */
}