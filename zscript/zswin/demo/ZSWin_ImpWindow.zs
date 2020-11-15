/*
	ZSWin_ImpWindow.zs
	
	This file defines the demonstration windows created
	by the friendly imp in the demo map

*/

/*
	This is a standard window definition.  It contains a constructor called Init,
	and two event overrides, OnLeftMouseDown, and OnLeftMouseUp.
	
	The constructor, Init, is where the various feature of the window are defined.
	
	OnLeftMouseDown and OnLeftMouseUp are interactive events that will be called
	when their corresponding real-world interaction with the computer takes place,
	in this case, clicking the left mouse button.

*/
class ZSWin_ImpWindow : ZSWindow
{	
	/*
		This is the window constructor.
		
		Init is not a virtual method, so return your descendent class, as shown here.
		Only the first six arguments are required by ancestry, so you may also tweak
		the argument list to fit your needs.
		
		Remember that ZObjects are Actors!  So, you may add states, and have access to
		the full breadth of options regarding Actors.  How the Init method is called
		is only limited by the engine itself.
	
	*/
	ZSWin_ImpWindow Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_NONE, float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		/*
			The argument list contains the bare essentials to create a valid window,
			so some members, including important ones, must be assigned here.
		
		*/
		// Starting dimensions
		Width = 350;
		Height = 380;
		
		// This just creates some defaults for the x/y location
		if (xLocation == 0)
			self.xLocation = 200;
		else
			self.xLocation = xLocation;
		if (yLocation == 0)
			self.yLocation = 200;
		else
			self.yLocation = yLocation;
		
		// Background
		BackgroundType = BACKTYP_GameTex1;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = true;
		
		// Border
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		/*
			Controls are also actors and are spawned into the game world
			using the AddControl method.  This method does some internal
			things but also functions as a wrapper for A_SpawnItemEx.
			
			This means creating controls is three steps:
				1 - call AddControl to create the control you want
				2 - check that spawning succeeded
				3 - if it did, cast the actor pointer to your desired control type,
					and call the control's Init method to customize.
		
		*/
		
		// Windows can be controls of other windows - this window is defined below with more information.
		//AddControl(new("ZSWin_ImpSubWindow").Init(self, Enabled, Show, "ImpySubWindow", PlayerClient, UiToggle));
		
		bool spawned;
		actor btn_close, btn_move, btn_scale, nwd_subwindow;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "ImpWindowCloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "ImpWindowMoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "ImpWindowScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");
		
		/*
			Return your class type, in this case ZSWin_ImpWindow, and call the super.Init,
			passing along those 6 required args.
		
		*/
		return ZSWin_ImpWindow(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
	}
	
	/*
		Clicking is two steps, pushing down on the button,
		and releasing it.  This is step one.
		
		Three things happen here, first, there is a check
		to see if the cursor is actually on top of the window,
		second, if the cursor is on top of the window, inform
		the event system that this window needs to be drawn on
		top of everything else, and third, call the super of
		this event.
		
		The argument "t" is the "type" as sent from the UiProcess
		method.
	*/
	override void OnLeftMouseDown(int t)
	{
		if (ValidateCursorLocation())
			PostPrioritySwitch();
		super.OnLeftMouseDown(t);
	}
	
	/*
		We humans are slow compared to computers.  The event,
		OnLeftMouseDown, can actually occur several times before
		the player gets their finger off the mouse button.
		
		So there's a mechanism called Validation to halt repeated
		event calls to basically make the machine now wait for
		the player to do things at their pace.  Users don't really
		encounter Validation except for here, where the completion
		of an interaction, in this case releasing the left mouse
		button needs to be handled by calling EventValidate.
		
		Last step is to call the super.  You do this for every event.
	*/
	override void OnLeftMouseUp(int t)
	{
		EventValidate();
		super.OnLeftMouseUp(t);
	}
}



/*
	This is the sub-window that is a control of the window above.
	

*/
class ZSWin_ImpSubWindow : ZSWindow
{
	ZSWin_ImpSubWindow Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_NONE, float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		Width = 200;
		Height = 200;
		if (xLocation == 0)
			self.xLocation = 100;
		if (yLocation == 0)
			self.yLocation = 100;
		
		BackgroundType = BACKTYP_GameTex1;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = true;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		bool spawned;
		actor btn_close, btn_move, btn_scale;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "ImpSubWindowCloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "ImpSubWindowMoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "ImpSubWindowScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");
		
		/*
			To be a sub-window, this window needs to not add itself to
			the event system's list of windows, called the window stack.
			
			To do this simply set SkipStackAdd, the last argument of the list, to true.
			Normally you skip this argument.
		
		*/
		return ZSWin_ImpSubWindow(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType, true));
	}
	
	/*
		This event differs in that you set the PostPrioritySwitch
		argument, Ignore, to true.  This stops duplicate attempts
		by the parent window to cause a priority switch.
		
	*/
	override void OnLeftMouseDown(int t)
	{
		if (ValidateCursorLocation())
			PostPrioritySwitch(true);
		super.OnLeftMouseDown(t);
	}
	
	override void OnLeftMouseUp(int t)
	{
		EventValidate();
		super.OnLeftMouseUp(t);
	}
}


class ZSWin_ImpWindow2 : ZSWindow
{
	ZSWin_ImpWindow2 Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_NONE, float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		// Starting dimensions
		Width = 350;
		Height = 380;
		
		if (xLocation == 0)
			self.xLocation = 200;
		else
			self.xLocation = xLocation;
		if (yLocation == 0)
			self.yLocation = 200;
		else
			self.yLocation = yLocation;
		
		BackgroundType = BACKTYP_GameTex2;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = false;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		bool spawned;
		actor btn_close, btn_move, btn_scale;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "ImpWindow2CloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "ImpWindow2MoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "ImpWindow2ScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");
		
		return ZSWin_ImpWindow2(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
	}

	override void OnLeftMouseDown(int t)
	{
		if (ValidateCursorLocation())
			PostPrioritySwitch();
		super.OnLeftMouseDown(t);
	}
	
	override void OnLeftMouseUp(int t)
	{
		EventValidate();
		super.OnLeftMouseUp(t);
	}	
}