/*
	ZSWin_BFGWindow.zs
	
	This is the window the player interacts with to access the BFG in the demo map

*/

/*
	This is a standard window definition.  It contains a constructor called Init,
	and two event overrides, OnLeftMouseDown, and OnLeftMouseUp.
	
	The constructor, Init, is where the various feature of the window are defined.
	
	OnLeftMouseDown and OnLeftMouseUp are interactive events that will be called
	when their corresponding real-world interaction with the computer takes place,
	in this case, clicking the left mouse button.

*/
class ZSWin_BFGWindow : ZSWindow
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
	ZSWin_BFGWindow Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_NONE, float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		/*
			The argument list contains the bare essentials to create a valid window,
			so some members, including important ones, must be assigned here.
		
		*/
		// Starting dimensions
		Width = 300;
		Height = 350;

		// This just creates some defaults for the x/y location		
		if (xLocation == 0 && yLocation == 0)
			[self.xLocation, self.yLocation] = WindowLocation_ScreenCenter();
		else
		{
			self.xLocation = xLocation;
			self.yLocation = yLocation;
		}
		
		// Background
		BackgroundType = BACKTYP_ZWin;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = false;
		
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
		bool spawned;
		actor btn_close, btn_move, btn_scale, txt_title, txtbox_password, btn_BFG;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "BFGWindowCloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "BFGWindowMoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "BFGWindowScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");
		// Title
		[spawned, txt_title] = AddControl("ZText");
		if (spawned && txt_title)
			ZText(txt_title).Init(self, Enabled, Show, "BFGWindowTitle", "Weapon Access Station", PlayerClient, UiToggle,
								TextWrap:ZText.TXTWRAP_Dynamic,TextFont:'bigfont', TextColor:'Gold');
		// Password Textbox
		[spawned, txtbox_password] = AddControl("ZTextBox");
		if (spawned && txtbox_password)
			ZTextBox(txtbox_password).Init(self, Enabled, Show, "BFGPasswordBox", PlayerClient, UiToggle,
										BorderColor:0xff0000, BorderAlpha:0.5, UseTrackingCursor:true,
										box_xLocation:5, box_yLocation:(self.Height - 200), Width:(self.Width - 10), Height:100, IsMultiLine:true, 
										FontName:'newconsolefont', Text:"What's the password?", txt_xLocation:5, txt_yLocation:5);
		// BFG Button		
		[spawned, btn_BFG] = AddControl("BFGButton");
		if (spawned && btn_BFG)
			BFGButton(btn_BFG).Init(self, Enabled, Show, "BFGAccessButton", PlayerClient, UiToggle,
								Type:ZButton.BTN_ZButton, Width:(self.Width - 20), Btn_xLocation:((self.Width - (self.Width - 20)) / 2), Btn_yLocation:(self.Height - 75), 
								ButtonScaleType:ZControl.SCALE_Vertical, Text:"Access BFG 9000", FontName:'newsmallfont', TextAlignment:ZControl.TEXTALIGN_Center, TextWrap:ZControl.TXTWRAP_Dynamic,
								Txt_yLocation:5);

		/*
			Return your class type, in this case ZSWin_BFGWindow, and call the super.Init,
			passing along those 6 required args.
		
		*/		
		return ZSWin_BFGWindow(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
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