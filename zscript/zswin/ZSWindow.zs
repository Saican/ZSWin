class ZSWindow : ZSWin_Base abstract
{
	//
	// Movement
	//
	private int lockedCursorX, lockedCursorY;
	void LockMoveOrigin() 
	{ 
		lockedCursorX = zHandler.CursorX; 
		lockedCursorY = zHandler.CursorY; 
	}
	void MoveAccumulate()
	{
		int diffx, diffy;
		[diffx, diffy] = MoveDifference();
		moveAccumulateX += diffx;
		moveAccumulateY += diffy;
		lockedCursorX = lockedCursorY = 0;
	}
	int moveAccumulateX, moveAccumulateY;
	clearscope int, int MoveDifference()
	{
		if (lockedCursorX > 0 && lockedCursorY > 0)
			return zHandler.CursorX - lockedCursorX, zHandler.CursorY - lockedCursorY;
		else
			return 0, 0;
	}
	
	//
	// INTERNAL BUT PUBLIC MEMBERS
	//
	bool bStackPurged;
	void Close(bool UIToggle = true) { zHandler.SetWindowForPurge(self.name, UIToggle); }
	
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
	private int _GetTextSize() { return (ConsoleUpdater || SysUpdate_Text) && zHandler.bDebugIsUpdating ? CopyText.Size() : Text.Size(); }
	ui ZText GetText(int i) { return (ConsoleUpdater || SysUpdate_Text) && zHandler.bDebugIsUpdating ? CopyText[i] : Text[i]; }
	private ZText _GetText(int i) { return (ConsoleUpdater || SysUpdate_Text) && zHandler.bDebugIsUpdating ? CopyText[i] : Text[i]; }
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
	private int _GetShapeSize() { return SysUpdate_Shapes && zHandler.bDebugIsUpdating ? CopyShapes.Size() : Shapes.Size(); }
	ui ZShape GetShape(int i) { return SysUpdate_Shapes && zHandler.bDebugIsUpdating ? CopyShapes[i] : Shapes[i]; }
	private ZShape _GetShape(int i) { return SysUpdate_Shapes && zHandler.bDebugIsUpdating ? CopyShapes[i] : Shapes[i]; }
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
	private int _GetButtonSize() {return SysUpdate_Buttons && zHandler.bDebugIsUpdating ? CopyButtons.Size() : Buttons.Size(); }
	ui ZButton GetButton(int i) { return SysUpdate_Buttons && zHandler.bDebugIsUpdating ? CopyButtons[i] : Buttons[i]; }
	private ZButton _GetButton(int i) { return SysUpdate_Buttons && zHandler.bDebugIsUpdating ? CopyButtons[i] : Buttons[i]; }
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
		
		if (GlobalEnabled /*&& zHandler.CursorState != zHandler.idle*/)
		{
			PassiveGibZoning();
			ActiveGibZoning();
		}
	}
	
	/*
		This method looks to see if the cusor is over a button.
		However the button may not be visually under another window.
		The checks attempt to see if any portion of the button is visible,
		and if so this area is checked.
	
	*/
	private void PassiveGibZoning()
	{
		// Get the location of the cursor
		int CursorX = zHandler.CursorX, 
			CursorY = zHandler.CursorY;
		// The the real window location
		float nwdX, nwdY;
		[nwdX, nwdY] = zsys.realWindowLocation(self);	
		// Get the stats of every window of higher priority
		Array<WindowStats> higherStats;
		for (int i = zHandler.GetStackIndex(self) + 1; i < zHandler.GetStackSize(); i++)
			higherStats.Push(zHandler.GetWindowStats(i));
		
		for (int i = 0; i < Buttons.Size(); i++)
		{
			if (_GetButton(i).Enabled)
			{
				// Check if the mouse is over a button - do this first to skip the next part
				if (nwdX + _GetButton(i).xLocation < CursorX && CursorX < nwdX + _GetButton(i).xLocation + _GetButton(i).Width &&
					nwdY + _GetButton(i).yLocation < CursorY && CursorY < nwdY + _GetButton(i).yLocation + _GetButton(i).Height)
				{
					bool mouseOver = false;
					// Check if the button is under any of the windows in higherStats
					if (higherStats.Size() > 0)
					{
						for (int j = 0; j < higherStats.Size(); j++)
						{
							float availX = 0, availY = 0,
								splitX = 0, splitY = 0;
							int availWidth = 0, availHeight = 0,
								splitWidth = 0, splitHeight = 0;
							bool splitDims = false;
							// Button is covered so skip it
							if (higherStats[j].xLocation < nwdX + _GetButton(i).xLocation &&
								higherStats[j].xLocation + higherStats[j].Width > nwdX + _GetButton(i).xLocation + _GetButton(i).Width &&
								higherStats[j].yLocation < nwdY + _GetButton(i).yLocation &&
								higherStats[j].yLocation + higherStats[j].Height > nwdY + _GetButton(i).yLocation + _GetButton(i).Height)
								break;
							// Check if any part of the button is covered up
							// left side is covered up
							if (higherStats[j].xLocation < nwdX + _GetButton(i).xLocation && 
								higherStats[j].xLocation + higherStats[j].Width > nwdX + _GetButton(i).xLocation &&
								higherStats[j].xLocation + higherStats[j].Width < nwdX + _GetButton(i).xLocation + _GetButton(i).Width)
							{
								availX = higherStats[j].xLocation + higherStats[j].Width;
								availWidth = (nwdX + _GetButton(i).xLocation + _GetButton(i).Width) - (higherStats[j].xLocation + higherStats[j].Width);
							}
							// right side is covered up
							else if (higherStats[j].xLocation > nwdX + _GetButton(i).xLocation &&
									higherStats[j].xLocation < nwdX + _GetButton(i).xLocation + _GetButton(i).Width &&
									higherStats[j].xLocation + higherStats[j].Width > nwdX + _GetButton(i).xLocation + _GetButton(i).Width)
							{
								availX = nwdX + _GetButton(i).xLocation;
								availWidth = higherStats[j].xLocation - (nwdX + _GetButton(i).xLocation);
							}
							// the window is literally between the button!
							else if (higherStats[j].xLocation > nwdX + _GetButton(i).xLocation &&
									higherStats[j].xLocation < nwdX + _GetButton(i).xLocation + _GetButton(i).Width &&
									higherStats[j].xLocation + higherStats[j].Width > nwdX + _GetButton(i).xLocation &&
									higherStats[j].xLocation + higherStats[j].Width < nwdX + _GetButton(i).xLocation + _GetButton(i).Width)
							{	// honestly a buttons's width may allow another window to fit between it - true evil will be the y values
								splitDims = true;
								availX = nwdX + _GetButton(i).xLocation;
								availWidth = higherStats[j].xLocation - (nwdX + _GetButton(i).xLocation);
								splitX = higherStats[j].xLocation + higherStats[j].Width;
								splitWidth = (nwdX + _GetButton(i).xLocation + _GetButton(i).Width) - higherStats[j].xLocation + higherStats[j].Width;
							}
							else
							{
								availX = nwdX + _GetButton(i).xLocation;
								availWidth = _GetButton(i).Width;
							}
							
							// top is covered up
							if (higherStats[j].yLocation < nwdY + _GetButton(i).yLocation && 
								higherStats[j].yLocation + higherStats[j].Height > nwdY + _GetButton(i).yLocation &&
								higherStats[j].yLocation + higherStats[j].Height < nwdY + _GetButton(i).yLocation + _GetButton(i).Height)
							{
								availY = higherStats[j].yLocation + higherStats[j].Height;
								availHeight = (nwdY + _GetButton(i).yLocation + _GetButton(i).Height) - (higherStats[j].yLocation + higherStats[j].Height);
							}
							// bottom is covered up
							else if (higherStats[j].yLocation > nwdY + _GetButton(i).yLocation &&
									higherStats[j].yLocation < nwdY + _GetButton(i).yLocation + _GetButton(i).Height &&
									higherStats[j].yLocation + higherStats[j].Height > nwdY + _GetButton(i).yLocation + _GetButton(i).Height)
							{
								availY = nwdY + _GetButton(i).yLocation;
								availHeight = higherStats[j].yLocation - (nwdY + _GetButton(i).yLocation);
							}
							// the window is literally between the button!
							else if (higherStats[j].yLocation > nwdY + _GetButton(i).yLocation &&
									higherStats[j].yLocation < nwdY + _GetButton(i).yLocation + _GetButton(i).Height &&
									higherStats[j].yLocation + higherStats[j].Height > nwdY + _GetButton(i).yLocation &&
									higherStats[j].yLocation + higherStats[j].Height < nwdY + _GetButton(i).yLocation + _GetButton(i).Height)
							{	// this is true evil - is the button really that tall or is the window really that short???!!!!
								splitDims = true;
								availY = nwdY + _GetButton(i).yLocation;
								availHeight = higherStats[j].yLocation - (nwdY + _GetButton(i).yLocation);
								splitY = higherStats[j].yLocation + higherStats[j].Height;
								splitHeight = (nwdY + _GetButton(i).yLocation + _GetButton(i).Height) - higherStats[j].yLocation + higherStats[j].Height;
							}
							else
							{
								availY = nwdY + _GetButton(i).yLocation;
								availHeight = _GetButton(i).Height;
							}

							// Finally, check the adjusted dimensions, if it's clear, the check continues, if not we're done here.
							if ((availX < CursorX && CursorX < availX + availWidth &&
								availY < CursorY && CursorY < availY + availHeight) ||
								(splitDims && splitX < CursorX && CursorX < splitX + splitWidth &&
								splitY < CursorY && CursorY < splitY + splitHeight))
								mouseOver = true;
							else
							{
								mouseOver = false;
								break; // Where the mouse is is covered so higher windows don't matter
							}
						}
					}
					else
						mouseOver = true;
					
					if (mouseOver && _GetButton(i).State == ZButton.idle)
						_GetButton(i).State = ZButton.highlight;
				}
				else
					_GetButton(i).State = ZButton.idle;
			}
		}
	}
	
	private void ActiveGibZoning()
	{
		for (int i = 0; i < _GetTextSize(); i++)
		{
			_GetText(i).ShowCheck();
			if (_GetText(i).Enabled)
				ActiveGibZoning_EventCaller(ZControl_Base(_GetText(i)));
		}
		for (int i = 0; i < _GetShapeSize(); i++)
		{
			_GetShape(i).ShowCheck();
			if (_GetShape(i).Enabled)
				ActiveGibZoning_EventCaller(ZControl_Base(_GetShape(i)));
		}
		for (int i = 0; i < _GetButtonSize(); i++)
		{
			_GetButton(i).ShowCheck();
			if (_GetButton(i).Enabled)
				ActiveGibZoning_EventCaller(ZControl_Base(_GetButton(i)));
		}
	}
	
	private void ActiveGibZoning_EventCaller(ZControl_Base control)
	{
		switch (zHandler.CursorState)
		{
			case zHandler.leftmousedown:
				control.OnLeftMouseDown(self);
				break;
			case zHandler.leftmouseup:
				control.OnLeftMouseUp(self);
				break;
			case zHandler.leftmouseclick:
				control.OnLeftMouseClick(self);
				break;
			case zHandler.middlemousedown:
				control.OnMiddleMouseDown(self);
				break;
			case zHandler.middlemouseup:
				control.OnMiddleMouseUp(self);
				break;
			case zHandler.middlemouseclick:
				control.OnMiddleMouseClick(self);
				break;
			case zHandler.rightmousedown:
				control.OnRightMouseDown(self);
				break;
			case zHandler.rightmouseup:
				control.OnRightMouseUp(self);
				break;
			case zHandler.rightmouseclick:
				control.OnRightMouseClick(self);
				break;
			case zHandler.wheelmouseup:
				control.OnWheelMouseDown(self);
				break;
			case zHandler.wheelmousedown:
				control.OnWheelMouseUp(self);
				break;
		}
	}
	
	/*
		This method defaults everything to safe values.
		
		Don't ever trust any programming language to do it for you,
		even if it says it does.
	
	*/
	void TrueZero()
	{
		ConsoleUpdater = false;
		Width = Height = 0;
		xLocation = yLocation = 0.0;
		lockedCursorX = lockedCursorY = 0;
		moveAccumulateX = moveAccumulateY = 0;
		
		BackgroundType = noBackground;
		BackgroundAlpha = 1.0;
		Stretch = false;
		// BackgroundTexture can be skipped - it's only important if Type is something other than noBackground
		
		BorderType = noBorder;
		BorderColor = "White";
		BorderThickness = 1;
		BorderAlpha = 1.0;
	}
	
	/*
		Class constructor
	
	*/
	override ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string name, int player, bool uiToggle)
	{
		DebugOut("WindowInitMsg", "Window abstract initialized.", Font.CR_Yellow);		
		super.Init(GlobalEnabled, GlobalShow, name, player, uiToggle);
		
		bStackPurged = false;
		
		backgroundInit();
		if (BorderType == ZWin_Border)
			borderInit();
		
		return self;
	}
	
	/*
		Sets up internal background options
		Custom backgrounds need to handle this manually
		
	*/
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
	
	/*
		Initializes the "Classic Z-Windows" Border
		
	*/
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
	
	/*
		Takes the width and heigh of the window and returns
		an X/Y location that will center the window on the screen.
	
	*/
	float, float WindowLocation_ScreenCenter(int width, int height)
	{
		return float((Screen.GetWidth() - width) / 2), float((Screen.GetHeight() - height) / 2);
	}
	
	/*
		Returns the default X/Y locations
	
	*/
	float, float WindowLocation_Default()
	{
		return DEFLOC_X, DEFLOC_Y;
	}
	
	/*
		Takes the width (or height) of a control and returns
		an X (or Y) location that will center the control in
		the window.
	
	*/
	float WindowControlLocation_Center(float controlWidth)
	{
		return (Width / 2) - (controlWidth / 2);
	}
	
	/*
		Clears all window control arrays
	
	*/
	void ControlClear()
	{
		Text.Clear();
		Shapes.Clear();
		Buttons.Clear();
	}
	
	/* - End of methods - */
}