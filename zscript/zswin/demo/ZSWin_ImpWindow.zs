/*
	ZSWin_ImpWindow.zs
	
	This file defines the demonstration windows created
	by the friendly imp in the demo map

*/

class ZSWin_ImpWindow : ZSWindow
{	
	ZSWin_ImpWindow Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
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
		
		BackgroundType = BACKTYP_GameTex1;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = true;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		AddControl(new("ZSWin_ImpSubWindow").Init(self, Enabled, Show, "ImpySubWindow", PlayerClient, UiToggle));
		// Close Button
		AddControl(new("ZSWin_CloseButton").Init(self, Enabled, Show, "ImpWindowCloseButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS"));
		// Move Button
		AddControl(new("ZSWin_MoveButton").Init(self, Enabled, Show, "ImpWindowMoveButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS"));
		// Scale Button
		AddControl(new("ZSWin_ScaleButton").Init(self, Enabled, Show, "ImpWindowScaleButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
			IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS"));
		
		/*
			This return is kind of odd, as the "return null" cannot be reached
			because of the call to HCF which will abort the VM.  The "return null"
			has to be present for code completion otherwise the compiler balks.
			
			The normal return is a special call to AddWindowToStack.			
			This will add the window to the event handler stack as a parent window.
			AddWindowToStack just returns the same window it recieves, it just needs to be
			in the call chain.
			
			Sub windows do not need to call AddWindowToStack.  Take a look at the ImpSubWindow
			return for a usage example.
		
		*/
		if(GetZHandler())
			return ZSWin_ImpWindow(ZEvent.AddWindowToStack(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType)));
		
		ZSHandlerUtil.HaltAndCatchFire(" - - IMP WINDOW DID NOT FIND THE ZSCRIPT WINDOWS EVENT HANDLER!");
		return null; // won't get here because of HCF, but has to be here for code completion
	}
	
	/*
		Just like OnMouseMove, this override sends itself as the other for the
		control events.  Same reason, ValidateCursorLocation needs it.
	*/
	override void OnLeftMouseDown()
	{
		if (ValidateCursorLocation())
			zEvent.PostPriorityIndex(zEvent.GetStackIndex(self));
		super.OnLeftMouseDown();
	}
	
	/*
		This allows the window to receive events again and has to be called.
		There's a mechanism in place to lock the system when the event is received
		so continued event reception does not cause crashy-ness.
	*/
	override void OnLeftMouseUp()
	{
		EventValidate();
		super.OnLeftMouseUp();
	}
}

/*
	This is a sub-window that acts a control of a parent window

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
		
		// Close Button
		AddControl(new("ZSWin_CloseButton").Init(self, Enabled, Show, "ImpSubWindowCloseButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS"));
		// Move Button
		AddControl(new("ZSWin_MoveButton").Init(self, Enabled, Show, "ImpSubWindowMoveButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS"));
		// Scale Button
		AddControl(new("ZSWin_ScaleButton").Init(self, Enabled, Show, "ImpSubWindowScaleButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
			IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS"));

		/*
			This return is kind of odd, as the "return null" cannot be reached
			because of the call to HCF which will abort the VM.  The "return null"
			has to be present for code completion otherwise the compiler balks.
			
			Since this window is a sub-window, it does not need to call AddWindowToStack.
			Instead it can just return its super.
		
		*/		
		if(GetZHandler())
			return ZSWin_ImpSubWindow(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
		
		ZSHandlerUtil.HaltAndCatchFire(" - - IMP SUB WINDOW DID NOT FIND THE ZSCRIPT WINDOWS EVENT HANDLER!");
		return null; // won't get here because of HCF, but has to be here for code completion
	}
	
	/*
		This window, being a sub-window of another window, should receive a
		non-null other argument.  This needs checked just like the parent argument
		through ValidateCursorLocation.  Just in case though, check  if other is valid first.
		
		One final important note is the call to PostPriorityIndex.  Unlike other calls, this one
		sets the default bool Ignore to true.  This will cause the system to ignore duplicate
		posts from the parent window(s).
	*/
	override void OnLeftMouseDown()
	{
		if (ValidateCursorLocation())
			zEvent.PostPriorityIndex(zEvent.GetStackIndex(GetRootWindow()), true);
		super.OnLeftMouseDown();
	}
	
	/*
		Same thing as any other window, gotta unlock the event system.
	*/
	override void OnLeftMouseUp()
	{
		EventValidate();
		super.OnLeftMouseUp();
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
		
		// Close Button
		AddControl(new("ZSWin_CloseButton").Init(self, Enabled, Show, "Imp2WindowCloseButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS"));
		// Move Button
		AddControl(new("ZSWin_MoveButton").Init(self, Enabled, Show, "Imp2WindowMoveButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS"));
		// Scale Button
		AddControl(new("ZSWin_ScaleButton").Init(self, Enabled, Show, "Imp2WindowScaleButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
			IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS"));
		
		if(GetZHandler())
			return ZSWin_ImpWindow2(ZEvent.AddWindowToStack(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType)));
		
		ZSHandlerUtil.HaltAndCatchFire(" - - IMP WINDOW2 DID NOT FIND THE ZSCRIPT WINDOWS EVENT HANDLER!");
		return null; // won't get here because of HCF, but has to be here for code completion
	}
	
	/*
		This window doesn't do anything special, so this is the basic left-click evaluation.
	*/
	override void OnLeftMouseDown()
	{
		if (ValidateCursorLocation())
			zEvent.PostPriorityIndex(zEvent.GetStackIndex(self));
		super.OnLeftMouseDown();
	}
	
	/*
		And unlock the system.  Why isn't this automatic?
		Windows are ZObjectBase's, just like everything else.
		Unlike everything else, windows receive the events from
		the event system and then pass those events to their controls.
		Since the event system is still pumping events to the windows,
		the locking mechanism in each window stops it from continuing to
		receive any more events until it is unlocked.  So the lock is
		unique to each window, not a global mechanism, and needs cleared
		when the event completes.
		
		For windows, the super has to be called because that is how
		the control events are called.  Controls don't generally have
		to call their super, unless there is some specific purpose, like
		a control contains other controls that receive events.
	*/
	override void OnLeftMouseUp()
	{
		EventValidate();
		super.OnLeftMouseUp();
	}	
}