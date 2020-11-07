/*
	ZSWin_BFGWindow.zs
	
	This is the window the player interacts with to access the BFG in the demo map

*/
class ZSWin_BFGWindow : ZSWindow
{
	/*
		Windows created by lines need to override their Make method and initialize
		instead of using their own Init method.
		
		The reason for this is that the method called by the Event System to create the window must
		be a virtual.  Init is more functional but the call chain cannot be completed from within the
		Event System because the definition of Init that is useful occurs in a ZSWindow descendent.
		
		As this demonstration shows, you return the super.Init in order to continue initialization.
	*/
	override ZObjectBase Make(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType, float xLocation, float yLocation, float Alpha)
	{
		Width = 300;
		Height = 350;
		
		if (xLocation == 0 && yLocation == 0)
			[self.xLocation, self.yLocation] = WindowLocation_ScreenCenter();
		else
		{
			self.xLocation = xLocation;
			self.yLocation = yLocation;
		}
		
		BackgroundType = BACKTYP_ZWin;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = false;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		// Close Button
		AddControl(new("ZSWin_CloseButton").Init(self, Enabled, Show, "BFGWindowCloseButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS"));
		// Move Button
		AddControl(new("ZSWin_MoveButton").Init(self, Enabled, Show, "BFGWindowMoveButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
			IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS"));
		// Scale Button
		AddControl(new("ZSWin_ScaleButton").Init(self, Enabled, Show, "BFGWindowScaleButton", PlayerClient, UiToggle,
			Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
			IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS"));
			
		// Title - it's just another control like all the others
		AddControl(new("ZText").Init(self, Enabled, Show, "BFGWindowTitle", "Weapon Access Station", PlayerClient, UiToggle,
			TextWrap:ZText.TXTWRAP_Dynamic,TextFont:'bigfont', TextColor:'Gold'));
			
		AddControl(new("ZTextBox").Init(self, Enabled, Show, "BFGPasswordBox", PlayerClient, UiToggle,
			BorderColor:0xff0000, BorderAlpha:0.5, UseTrackingCursor:true,
			box_xLocation:5, box_yLocation:(self.Height - 200), Width:(self.Width - 10), Height:100, IsMultiLine:true, FontName:'newconsolefont', Text:"What's the password?", txt_xLocation:5, txt_yLocation:5));
			
		AddControl(new("BFGButton").Init(self, Enabled, Show, "BFGAccessButton", PlayerClient, UiToggle,
			Type:ZButton.BTN_ZButton, Width:(self.Width - 20), Btn_xLocation:((self.Width - (self.Width - 20)) / 2), Btn_yLocation:(self.Height - 75), 
			ButtonScaleType:ZControl.SCALE_Vertical, Text:"Access BFG 9000", FontName:'newsmallfont', TextAlignment:ZControl.TEXTALIGN_Center, TextWrap:ZControl.TXTWRAP_Dynamic,
			Txt_yLocation:5));
		
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