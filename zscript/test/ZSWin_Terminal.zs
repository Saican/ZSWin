/*
	This is a demo ZS-Window that can actually be inherited from
	and modified.
	
	Usage would call PostBeginPlay as a super, and then initialize to 
	desired outcome.  Inherited windows do not need to override Init.
	
	You may call DebugOut at any point to send messages to the screen,
	however until the window has found the handler, messages will be
	held in a temporary array and printed when possible.

*/
class ZSWin_Terminal : ZSWindow
{	
	override ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string name, int player, bool uiToggle)
	{
		DebugOut("InitMsg", string.Format("Initializing window, %s.", name), Font.CR_Gray);
		
		// This has to be called first prior to all other initialization
		TrueZero();
		
		// Starting dimensions
		Width = 350;
		Height = 350;
		
		// Starting location
		//[xLocation, yLocation] = WindowLocation_ScreenCenter(Width, Height);
		//[xLocation, yLocation] = WindowLocation_Default();
		xLocation = 200;
		yLocation = 200;
		
		BackgroundType = ZWin_Default;
		BackgroundAlpha = 0.8;
		Stretch = true;
		
		BorderType = ZWin_Border;
	
		Title = new("ZText").Init("DemoTitle", true, true, "ZScript Windows v0.1 Demo Terminal - Welcome, Slayer!", 
								Font.CR_Gold, 
								ZText.wrap,
								0,	// if 0, the text is wrapped to the window width
								ZText.left, 
								"bigfont", 
								0);
								
		Text.Push(new("ZText").Init("txtNews_A", true, true, "Z-Windows is back!  ZScript Windows is a full rewrite of the GDCC-based mod.  All of the same features are present, but instead of hackily creating this functionality by hand, the power of ZScript has been unleashed!  ZScript Windows functions the same as its predecessor, it isn't telling you what your interface should look like, it's just telling you how to display it.  Whether making a HUD or a conversation system, ZScript Windows offers an intuitive interface for rapidly creating your ideas.",
									Font.CR_White,		// text color...kinda obvious
									ZText.wrap,			// text wrap setting - this is given priority
									0,					// wrap width
									ZText.Left,			// alignment
									"consolefont",		// font name
									5,					// x location - relative to window
									55,					// y location - same
									1,					// alpha (float)
									"bigGroupBox"));  	// if provided the name of a ZShape, the width calculated width of the shape (x_End - x_Start) will be the wrap width
									
		Shapes.Push(new("ZShape").Init("bigGroupbox", true, true, ZShape.thinroundgroupbox,
										"Green",
										0, 45, 			// start x/y
										Width, Height, 	// end x/y
										1, 				// alpha
										3,	 			// thickness
										ZShape.noscale, // scaling in relation to window resizing
										20,				// radius for round corners
										10,				// number of vertices on curve
										new("ZText").Init("bigGroupbox_Title", true, true, "Slaying GUIs with ZScript!", // if the shape is a groupbox, the GroupTitle needs initialized
											Font.CR_Orange,
											ZText.nowrap, 	// text wrapping is ignored for the title
											0,
											ZText.left,		// alignment is also ignored
											"newsmallfont",
											30)));			// xLocation is relative to the x_Start of the shape
		
		// Buttons may be initialized with as little as 2 arguments!
		// - All other args are defaulted so you can use named arguments to set what you need.
		// - Here I skipped the Enabled argument to jump to the button type
		Buttons.Push(new("TerminalButton").Init("testButton", "Close", Type:ZButton.zbtn, btn_xLocation:15, btn_yLocation:300, txt_yLocation:10));
		Buttons.Push(new("ZSWin_MoveButton").Init("moveButton", "", Width:25, btn_xLocation:(self.Width - 25), Stretch:true,
						"BMOVEIS", "BMOVEHS", "BMOVEAS", borderType:ZControl_Base.noshape));
		//self.GlobalEnabled = false;
		//self.GlobalShow = false;

		// Call the super last - it does further initializaton from what is defined here
		return super.Init(GlobalEnabled, GlobalShow, name, player, uiToggle);
		
	}
	
	// YOU MUST CALL THE SUPER TO THIS OVERRIDE - IF YOU USE IT!!!!
	// OTHERWISE YOUR WINDOW WILL NOT DO ANYTHING!!!!
	//
	// In other words, if you don't need to use the Tick method, then don't override it.
	override void Tick()
	{
		super.Tick();
		DebugOut("PriorityName", string.Format("Window: %s, priority is: %d, stack index: %d", self.Name, self.Priority, zHandler.GetStackIndex(self)));
	}
}