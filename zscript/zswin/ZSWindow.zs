class ZSWindow : ZSWin_Base abstract
{
	//
	// PRIVATE MEMBERS
	//
	
	//
	// INTERNAL BUT PUBLIC MEMBERS
	//
	bool bStackPurged;
	
	
	//
	// PUBLIC MEMBERS
	//
	const DEFLOC_X = 100.0;
	const DEFLOC_Y = 50.0;
	
	// Starting width/height of the window - in pixels
	int Width, 
		Height;
		
	// Starting X/Y Position of the window - from upper left hand corner of screen
	float xLocation, 
		yLocation;
	
	/*
		Backgrounds and borders work a lot like Tooltips.  Based on the game, the system
		can select which background and border to use, or use custom options defined by the
		window.
	
	*/
	// Background
	enum BACKTYP
	{
		Game_Tex1,
		Game_Tex2,
		Game_Tex3,
		ZWin_Default,
		CustomBackground,
		noBackground,
	};
	BACKTYP BackgroundType;
	float BackgroundAlpha;
	bool Stretch;
	TextureId BackgroundTexture;
	
	// Border
	enum BORDERTYP
	{
		Game,
		Line,
		ThickLine,
		ZWin_Border,
		noBorder,
	};
	BORDERTYP BorderType;
	color BorderColor;
	float BorderThickness,
		BorderAlpha;		
	ZBorder gfxBorder;
	
	// Text
	ZText Title;
	bool SysUpdate_Text;
	Array<ZText> Text;
	private Array<ZText> CopyText;
	ui int GetTextSize() { return (ConsoleUpdater || SysUpdate_Text) && zHandler.bDebugIsUpdating ? CopyText.Size() : Text.Size(); }
	ui ZText GetText(int i) { return (ConsoleUpdater || SysUpdate_Text) && zHandler.bDebugIsUpdating ? CopyText[i] : Text[i]; }
	ui ZText FindText(string Name) 
	{ 
		for (int i = 0; i < GetTextSize(); i++) 
		{ 
			if (GetText(i).Name ~== Name) 
				return GetText(i); 
		} 
		return null; 
	}
	
	// Lines and Boxes
	bool SysUpdate_Shapes;
	Array<ZShape> Shapes;
	private Array<ZShape> CopyShapes;
	ui int GetShapeSize() { return SysUpdate_Shapes && zHandler.bDebugIsUpdating ? CopyShapes.Size() : Shapes.Size(); }
	ui ZShape GetShape(int i) { return SysUpdate_Shapes && zHandler.bDebugIsUpdating ? CopyShapes[i] : Shapes[i]; }
	ui ZShape FindShape(string Name) 
	{ 
		for (int i = 0; i < GetShapeSize(); i++) 
		{ 
			if (GetShape(i).Name ~== Name) 
				return GetShape(i); 
		} 
		return null; 
	}
	
	// Buttons
	bool SysUpdate_Buttons;
	Array<ZButton> Buttons;
	private Array<ZButton> CopyButtons;
	ui int GetButtonSize() {return SysUpdate_Buttons && zHandler.bDebugIsUpdating ? CopyButtons.Size() : Buttons.Size(); }
	ui ZButton GetButton(int i) { return SysUpdate_Buttons && zHandler.bDebugIsUpdating ? CopyButtons[i] : Buttons[i]; }
	ui ZButton FindButton(string Name)
	{
		for (int i = 0; i < GetButtonSize(); i++)
		{
			if (GetButton(i).Name ~== Name)
				return GetButton(i);
		}
		return null;
	}
	
	private bool ConsoleUpdater;
	bool SetWindowToConsole() { return zHandler ? ConsoleUpdater = zHandler.SetWindowToConsole(self) : false; }
	void IsUpdating(bool updating = true) 
	{
		if ((SysUpdate_Text || ConsoleUpdater) && updating)
			CopyText.Move(Text);
		else
			CopyText.Clear();	
		
		if (SysUpdate_Shapes && updating)
			CopyShapes.Move(Shapes);
		else
			CopyShapes.Clear();
		
		if (SysUpdate_Buttons && updating)
			CopyButtons.Move(Buttons);
		else
			CopyButtons.Clear();
	}
	
	override void Tick()
	{
		super.Tick();
		if (ConsoleUpdater && (zHandler ? zHandler.bDebugIsUpdating && Text.Size() == zHandler.GetDebugSize() : false))
		{
			zHandler.bDebugIsUpdating = false;
			IsUpdating(false);
		}
	}
	
	private void PassiveGibZoning()
	{
		
	}
	
	// This methos sets everything to a safe default value
	void TrueZero()
	{
		ConsoleUpdater = false;
		Width = Height = 0;
		xLocation = yLocation = 0.0;
		
		BackgroundType = noBackground;
		BackgroundAlpha = 1.0;
		Stretch = false;
		// BackgroundTexture can be skipped - it's only important if Type is something other than noBackground
		
		BorderType = noBorder;
		BorderColor = "White";
		BorderThickness = 1;
		BorderAlpha = 1.0;
	}
	
	override void Init(bool enabled, string name, int player)
	{
		DebugOut("WindowInitMsg", "Window abstract initialized.", Font.CR_Yellow);		
		super.Init(enabled, name, player);
		
		bStackPurged = false;
		
		backgroundInit();
		if (BorderType == ZWin_Border)
			borderInit();
	}
		
	// Sets up internal background options
	// Custom backgrounds need to handle this manually
	private void backgroundInit()
	{
		if (BackgroundType == ZWin_Default)
			BackgroundTexture = TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY);
		// Game options
		else if (Backgroundtype != CustomBackground && Backgroundtype != noBackground)
		{
			switch (gameinfo.gametype)
			{
				case GAME_Doom:
					switch (BackgroundType)
					{
						case Game_Tex1:
							BackgroundTexture = TexMan.CheckForTexture("SHAWN2", TexMan.TYPE_ANY);
							break;
						case Game_Tex2:
							BackgroundTexture = TexMan.CheckForTexture("ROCK2", TexMan.TYPE_ANY);
							break;
						case Game_Tex3:
							BackgroundTexture = TexMan.CheckForTexture("GSTONE1", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Heretic:
				case GAME_Hexen:
					switch (BackgroundType)
					{
						case Game_Tex1:
							BackgroundTexture = TexMan.CheckForTexture("GRNBLOK1", TexMan.TYPE_ANY);
							break;
						case Game_Tex2:
							BackgroundTexture = TexMan.CheckForTexture("GRSTNPB", TexMan.TYPE_ANY);
							break;
						case Game_Tex3:
							BackgroundTexture = TexMan.CheckForTexture("WOODWL", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Strife:
					switch (BackgroundType)
					{
						case Game_Tex1:
							BackgroundTexture = TexMan.CheckForTexture("PIPWAL11", TexMan.TYPE_ANY);
							break;
						case Game_Tex2:
							BackgroundTexture = TexMan.CheckForTexture("BRKGRY01", TexMan.TYPE_ANY);
							break;
						case Game_Tex3:
							BackgroundTexture = TexMan.CheckForTexture("WINDW04", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Chex:
					switch (BackgroundType)
					{
						case Game_Tex1:
							BackgroundTexture = TexMan.CheckForTexture("BIGDOOR4", TexMan.TYPE_ANY);
							break;
						case Game_Tex2:
							BackgroundTexture = TexMan.CheckForTexture("STONE", TexMan.TYPE_ANY);
							break;
						case Game_Tex3:
							BackgroundTexture = TexMan.CheckForTexture("COMP2", TexMan.TYPE_ANY);
							break;
					}
					break;
			}
		}		
	}
	
	// Initializes the "Classic Z-Windows" Border
	private void borderInit()
	{
		let newBorder = new("ZBorder");
		if (newBorder)
		{
			newBorder.Corner_TopLeft = TexMan.CheckForTexture("CRNR_TL", TexMan.TYPE_ANY);
			newBorder.Corner_TopRight = TexMan.CheckForTexture("CRNR_TR", TexMan.TYPE_ANY);
			newBorder.Corner_BottomLeft = TexMan.CheckForTexture("CRNR_BL", TexMan.TYPE_ANY);
			newBorder.Corner_BottomRight = TexMan.CheckForTexture("CRNR_BR", TexMan.TYPE_ANY);
			newBorder.Side_Top = TexMan.CheckForTexture("SIDE_T", TexMan.TYPE_ANY);
			newBorder.Side_Bottom = TexMan.CheckForTexture("SIDE_B", TexMan.TYPE_ANY);
			newBorder.Side_Left = TexMan.CheckForTexture("SIDE_L", TexMan.TYPE_ANY);
			newBorder.Side_Right = TexMan.CheckForTexture("SIDE_R", TexMan.TYPE_ANY);
			
			if (newBorder.Corner_TopLeft.IsValid() && newBorder.Corner_TopRight.IsValid() && newBorder.Corner_BottomLeft.IsValid() && newBorder.Corner_BottomRight.IsValid() &&
				newBorder.Side_Top.IsValid() && newBorder.Side_Bottom.IsValid() && newBorder.Side_Left.IsValid() && newBorder.Side_Right.IsValid())
			{
				Vector2 txy = TexMan.GetScaledSize(newBorder.Corner_TopLeft);
				newBorder.BorderWidth = txy.x;
				newBorder.BorderHeight = txy.y;
				gfxBorder = newBorder;
			}
			else
			{
				DebugOut("ZWinBorderError", "ERROR! Window failed to find all of the textures required for the Classic Z-Window's Border.  Defaulting to Line type.");
				BorderType = Line;
			}
		}
	}
	
	float, float WindowLocation_ScreenCenter(int width, int height)
	{
		return float((Screen.GetWidth() - width) / 2), float((Screen.GetHeight() - height) / 2);
	}
	
	float, float WindowLocation_Default()
	{
		return DEFLOC_X, DEFLOC_Y;
	}
	
	void ControlClear()
	{
		Text.Clear();
		Shapes.Clear();
		Buttons.Clear();
	}
	
	/* - End of methods - */
}