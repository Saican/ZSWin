/*
	ZSWin_BFGTerminal.zs
	

*/
class ZSWin_BFGTerminal : ZSWin_Terminal
{
	override ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string name, int player, bool uiToggle)
	{
		super.Init(GlobalEnabled, Globalshow, name, player, uiToggle);
		Title.Text = "BFG Terminal";
		[xLocation, yLocation] = WindowLocation_ScreenCenter(Width, Height);
		
		Text.Clear();
		Buttons.Clear();
		
		Text.Push(new("ZText").Init("txtBFGMenu", true, true, "The BFG9000 was developed by the UAC as a direct offensive weapon for the harsh combat conditions faced in the deepest levels of Hell.",
									Font.CR_White,		// text color...kinda obvious
									ZText.wrap,			// text wrap setting - this is given priority
									0,					// wrap width
									ZText.Left,			// alignment
									"consolefont",		// font name
									5,					// x location - relative to window
									55,					// y location - same
									1,					// alpha (float)
									"bigGroupBox"));  	// if provided the name of a ZShape, the width calculated width of the shape (x_End - x_Start) will be the wrap width
		
		Buttons.Push(new("BFGButton").Init("bfgButton", "Access BFG", Type:ZButton.zbtn, Width:200, btn_xLocation:WindowControlLocation_Center(200), btn_yLocation:300, txt_yLocation:10));
		return self;
	}
}