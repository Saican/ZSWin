/*
	ZSWin_Control_TextBox.zs
	
	Text Input Class Definition
	
	This control is more intertwined with it's ZText control
	so users are very much encouraged to consider this instance read-only.

*/

class ZTextBox : ZControl
{
	// Type Cursor
	const CURSORTIME = 30;			// cursor blink rate in ticks
	private int cursorTickTime,		// blink rate counter
				cursorIndex,		// character index - cursor is to the left of character at index
				cursorLine;			// for multi-line text boxes, this is the index of the broken line
	clearscope int, int GetCursorIndex() { return cursorIndex, cursorLine; }
	private bool bCursorBlink;		// blink toggle
	// Public Cursor members
	bool IsMultiLine,				// Must be true for the textbox to have multiple lines
		UseTrackingCursor, 
		UseTrackingColor, 
		InvertCursorColor;
	color CursorColor, 
		TrackingCursorColor;
	
	// Background stuff
	enum BACKTYP
	{
		BACKTYP_GameTex1,
		BACKTYP_GameTex2,
		BACKTYP_GameTex3,
		BACKTYP_Custom,
		BACKTYP_Color,
		BACKTYP_NONE,
	};
	BACKTYP BackgroundType;
	color BackgroundColor;
	TextureId BackgroundTexture;
	bool StretchTexture, AnimateTexture;
	
	// Border
	enum BORDERTYP
	{
		BORDER_Frame,
		BORDER_ThinLine,
		BORDER_ThickLine,
		BORDER_NONE,
	};
	BORDERTYP BorderType;
	int BorderThickness;
	color BorderColor;
	float BorderAlpha;
	
	// Text components
	ZText Text;
	// If using pasword chars, this string will be used to hold the actual string
	// Set UseTrackingCursor to true to draw a second cursor that follows the mouse
	bool UsePasswordChars;
	private string controlText;
	
	int CursorX, CursorY;
	
	// Input
	private int lineCount;
	private bool bShift, bAlt, bCtrl;
	
	/*
		Unlike a button, a textbox is a bit more restrictive
		on what options are available via the constructor for
		the construction of the ZText.  This instance has to
		stay in the box.
	
	*/
	ZTextBox Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		BACKTYP BackgroundType = BACKTYP_Color, color BackgroundColor = 0xffffff, bool StretchTexture = false, bool AnimateTexture = false, string CustomBackgroundTexture = "", 
		BORDERTYP BorderType = BORDER_ThinLine, int BorderThickness = 1, color BorderColor = 0x808080, float BorderAlpha = 1,
		CLIPTYP ClipType = CLIP_Parent, SCALETYP ScaleType = SCALE_NONE, 
		bool InvertCursorColor = true, color CursorColor = 0x000000, bool UseTrackingCursor = false, bool UseTrackingColor = false, color TrackingCursorColor = 0x000000,
		float box_xLocation = 0, float box_yLocation = 0, float box_Alpha = 1, int Width = 100, int Height = 25, bool UsePasswordChars = false, bool IsMultiLine = false,
		TEXTALIGN TextAlignment = TEXTALIGN_Left, TXTWRAP TextWrap = TXTWRAP_NONE, int WrapWidth = 0, name FontName = 'consolefont', name TextColor = 'Black', string Text = "",
		float txt_xLocation = 0, float txt_yLocation = 0, float txt_Alpha = 1)
	{	
		self.cursorTickTime = 0;
		self.cursorIndex = Text.Length();
		self.cursorLine = 0;
		self.bCursorBlink = false;
		self.CursorColor = CursorColor;
		self.InvertCursorColor = InvertCursorColor;
		self.UseTrackingCursor = UseTrackingCursor;
		self.TrackingCursorColor = TrackingCursorColor;
		self.UseTrackingColor = UseTrackingColor;
		
		self.lineCount = 0;
		self.bShift = false;
		
		// Background
		self.BackgroundType = BackgroundType;
		self.BackgroundColor = BackgroundColor;
		self.StretchTexture = StretchTexture;
		self.AnimateTexture = AnimateTexture;
		backgroundInit(CustomBackgroundTexture);
		
		// Border
		self.BorderType = BorderType;
		self.BorderThickness = BorderThickness;
		self.BorderColor = BorderColor;
		self.BorderAlpha = BorderAlpha;
		
		// Base
		self.Width = Width;
		self.Height = Height;
		self.xLocation = ControlParent.xLocation + box_xLocation;
		self.yLocation = ControlParent.yLocation + box_yLocation;
		self.Alpha = box_Alpha;
		
		// Text
		self.UsePasswordChars = UsePasswordChars;
		self.IsMultiLine = IsMultiLine;
		self.Text = new("ZText").Init(self, Enabled, Show, string.Format("%s_txt", Name), Text, PlayerClient, UiToggle,
			ClipType, ScaleType, TextAlignment, 
			IsMultiLine ? (TextWrap != TXTWRAP_NONE ? TextWrap : TXTWRAP_Wrap) : TXTWRAP_NONE, 
			WrapWidth, FontName, TextColor, txt_xLocation, txt_yLocation, txt_Alpha);
			
		return ZTextBox(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ScaleType, TextAlignment, ClipType));
	}
	
	private void backgroundInit(string CustomBackgroundTexture)
	{
		if (BackgroundType != BACKTYP_Color && BackgroundType != BACKTYP_Custom && BackgroundType != BACKTYP_NONE)
		{
			switch (gameinfo.gametype)
			{
				case GAME_Doom:
					switch (BackgroundType)
					{
						case BACKTYP_GameTex1:
							BackgroundTexture = TexMan.CheckForTexture("FWATER1", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex2:
							BackgroundTexture = TexMan.CheckForTexture("ROCK2", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex3:
							BackgroundTexture = TexMan.CheckForTexture("GSTONE1", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Heretic:
				case GAME_Hexen:
					switch (BackgroundType)
					{
						case BACKTYP_GameTex1:
							BackgroundTexture = TexMan.CheckForTexture("GRNBLOK1", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex2:
							BackgroundTexture = TexMan.CheckForTexture("GRSTNPB", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex3:
							BackgroundTexture = TexMan.CheckForTexture("WOODWL", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Strife:
					switch (BackgroundType)
					{
						case BACKTYP_GameTex1:
							BackgroundTexture = TexMan.CheckForTexture("PIPWAL11", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex2:
							BackgroundTexture = TexMan.CheckForTexture("BRKGRY01", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex3:
							BackgroundTexture = TexMan.CheckForTexture("WINDW04", TexMan.TYPE_ANY);
							break;
					}
					break;
				case GAME_Chex:
					switch (BackgroundType)
					{
						case BACKTYP_GameTex1:
							BackgroundTexture = TexMan.CheckForTexture("BIGDOOR4", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex2:
							BackgroundTexture = TexMan.CheckForTexture("STONE", TexMan.TYPE_ANY);
							break;
						case BACKTYP_GameTex3:
							BackgroundTexture = TexMan.CheckForTexture("COMP2", TexMan.TYPE_ANY);
							break;
					}
					break;
			}
		}
		else if (BackgroundType == BACKTYP_Custom)
		{
			let custTex = TexMan.CheckForTexture(CustomBackgroundTexture, TexMan.TYPE_ANY);
			if (custTex.IsValid())
				BackgroundTexture = custTex;
			else
			{
				let defTex = TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY);
				if (defTex.IsValid())
					BackgroundTexture = defTex;
				else
				{
					BackgroundType = BACKTYP_NONE;
					/* debug error - no background for textbox! don't hcf though */
				}
			}
		}
	}
	
	/*
		The textbox uses is Tick method to iterate
		it's cursor blink counter.
	
	*/
	override void Tick()
	{	
		if (cursorTickTime == CURSORTIME)
		{
			bCursorBlink = !bCursorBlink;
			cursorTickTime = 0;
		}
		else
			cursorTickTime++;
	}
	
	/*
		This enum represents the ASCII values of the control keys,
		thus the direct underlyer manipulation.
	
	*/
	enum ControlKeys
	{
		CKEY_Home = 3,
		CKEY_End,
		CKEY_LeftArrow,
		CKEY_RightArrow,
		CKEY_Backspace = 8,
		CKEY_HorizontalTab,
		CKEY_DownArrow,
		CKEY_UpArrow,
		CKEY_CarriageReturn = 13,
		CKEY_NONE,
	};
	
	override bool ZObj_UiProcess(ZUIEventPacket e)
	{
		if (e.MouseX != CursorX || e.MouseY != CursorY)
			ZNetCommand(string.Format("ztxt_updateCursorLocation,%s", self.Name), self.PlayerClient, e.MouseX, e.MouseY);
		
		if (HasFocus)
		{
			switch (e.EventType)
			{
				case ZUIEventPacket.EventType_KeyDown:
					console.printf(string.format("textbox got keydown event, keystring: %s, ascii: %d, is shift: %d, is alt: %d, is control: %d",
						e.KeyString, e.KeyChar, e.IsShift, e.IsAlt, e.IsCtrl));
					switch (e.KeyChar)
					{
						case CKEY_Home:
							ZNetCommand(string.Format("ztxt_CursorIndexHome,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_End:
							ZNetCommand(string.Format("ztxt_CursorIndexEnd,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_LeftArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, -1);
							break;
						case CKEY_RightArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 1);
							break;
						case CKEY_Backspace:
							ZNetCommand(string.Format("ztxt_RemoveLastCharacter,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_HorizontalTab:
							break;
						case CKEY_DownArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 0, 1);
							break;
						case CKEY_UpArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 0, -1);
							break;
						case CKEY_CarriageReturn:
							break;
						default:
							// First of all none of the characters with a value less than 32 are anything to actually print onscreen.
							if (e.KeyChar > 31)
							{
								//console.printf(string.format("Textbox UiProcess, in KeyDown event, got %s key string, Shift is %s", e.KeyString, e.IsShift ? "true" : "false"));
								// Next, what character gets supplied here is pretty much bogus,
								// but this is where control keys can be caught, i.e. Shift, Ctrl, and Alt.
								// These booleans from the actual UiProcess event are just passed along out of the UI context from here as ints.
								ZNetCommand(string.Format("ztxt_keyDownInput,%s", self.Name), self.PlayerClient, e.IsShift, e.IsAlt, e.IsCtrl);
							}
							break;
					}
					break;
				case ZUIEventPacket.EventType_KeyRepeat:
					switch (e.KeyChar)
					{
						case CKEY_Home:
							ZNetCommand(string.Format("ztxt_CursorIndexHome,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_End:
							ZNetCommand(string.Format("ztxt_CursorIndexEnd,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_LeftArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, -1);
							break;
						case CKEY_RightArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 1);
							break;
						case CKEY_Backspace:
							ZNetCommand(string.Format("ztxt_RemoveLastCharacter,%s", self.Name), self.PlayerClient);
							break;
						case CKEY_DownArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 0, 1);
							break;
						case CKEY_UpArrow:
							ZNetCommand(string.Format("ztxt_CursorPositionChange,%s", self.Name), self.PlayerClient, 0, -1);
							break;
						default:
							if (e.KeyChar > 31)
								ZNetCommand(string.Format("ztxt_keyRepeatInput,%s", self.Name), self.PlayerClient);
							break;
					}						
					break;
				case ZUIEventPacket.EventType_KeyUp:
					ZNetCommand(string.Format("ztxt_keyClearInput,%s", self.Name), self.PlayerClient);
					break;
				case ZUIEventPacket.EventType_Char:
					//console.printf(string.format("Texbox UI Process, in Char event, received %s character string, Shift is %s", e.KeyString, e.IsShift ? "true" : "false"));
					// This event is where the correct character is actually received - still not sending the string but the ASCII value for conversion.
					ZNetCommand(string.Format("ztxt_appendInput,%s", self.Name), self.PlayerClient, e.KeyChar);
					break;
			}
		}
		return super.ZObj_UiProcess(e);
	}
	
	/*
		The ZText control is known globally, but it is a child control of the textbox,
		so for the ZText's UiTick to be called, the textbox must make the call from its
		own UiTick method.
	
	*/
	override bool ZObj_UiTick()
	{
		if (self.IsMultiline)
			return Text.ZObj_UiTick();
		else
			return super.ZObj_UiTick();
	}
	
	enum ZTextBoxCommand
	{
		ZTBCMD_UpdateCursorLocation,
		ZTBCMD_KeyDownInput,
		ZTBCMD_KeyRepeatInput,
		ZTBCMD_KeyClearInput,
		ZTBCMD_AppendInput,
		ZTBCMD_SendCursorHome,
		ZTBCMD_SendCursorEnd,
		ZTBCMD_CursorPositionChange,
		ZTBCMD_Backspace,
		ZTBCMD_CursorBreakToNextLine,
		
		ZTBCMD_NONE,
	};
	
	private ZTextBoxCommand stringToTextBoxCommand(string e)
	{
		if (e ~== "ztxt_updateCursorLocation")
			return ZTBCMD_UpdateCursorLocation;
		if (e ~== "ztxt_keyDownInput")
			return ZTBCMD_KeyDownInput;
		if (e ~== "ztxt_keyRepeatInput")
			return ZTBCMD_KeyRepeatInput;
		if (e ~== "ztxt_keyClearInput")
			return ZTBCMD_KeyClearInput;
		if (e ~== "ztxt_appendInput")
			return ZTBCMD_AppendInput;
		if (e ~== "ztxt_CursorIndexHome")
			return ZTBCMD_SendCursorHome;
		if (e ~== "ztxt_CursorIndexEnd")
			return ZTBCMD_SendCursorEnd;
		if (e ~== "ztxt_CursorPositionChange")
			return ZTBCMD_CursorPositionChange;
		if (e ~== "ztxt_RemoveLastCharacter")
			return ZTBCMD_Backspace;
		if (e ~== "ztxt_CursorBreakToNextLine")
			return ZTBCMD_CursorBreakToNextLine;
		else
			return ZTBCMD_NONE;
	}
	
	override bool ZObj_NetProcess(ZEventPacket e)
	{
		Array<string> cmdPlyr;
		e.EventName.Split(cmdPlyr, "?");
		if (cmdPlyr.Size() == 2 ? (cmdPlyr[1].ToInt() == self.PlayerClient) : false)
		{
			if (!e.Manual)
			{
				Array<string> cmdc;
				cmdPlyr[0].Split(cmdc, ":");
				for (int i = 0; i < cmdc.Size(); i++)
				{
					if (cmdc[i] != "")
					{
						Array<string> cmd;
						cmdc[i].Split(cmd, ",");
						if (cmd.Size() >= 2 ? (cmd[1] ~== self.Name) : false)
						{
							switch (stringToTextBoxCommand(cmd[0]))
							{
								// Log where the cursor is
								case ZTBCMD_UpdateCursorLocation:
									self.CursorX = e.FirstArg;
									self.CursorY = e.SecondArg;
									break;
								// Log the input
								case ZTBCMD_KeyDownInput:
									self.bShift = e.FirstArg;
									self.bAlt = e.SecondArg;
									self.bShift = e.ThirdArg;
									break;
								// Key was released so clear input log
								case ZTBCMD_KeyClearInput:
									textboxClearInput();
									break;
								// Signal that input can repeat
								case ZTBCMD_KeyRepeatInput:  // fall through to append
								// Have input/repeating input, add it to the string.
								case ZTBCMD_AppendInput:
									textboxAppendInput(e.FirstArg);
									break;
								// Locate the cursor to the start of the string
								case ZTBCMD_SendCursorHome:
									textboxSetCursorLocation(0, 0);
									break;
								// Locate the cursor to the end of the string
								case ZTBCMD_SendCursorEnd:
									if (IsMultiLine && self.Text.WrappedText)
										textboxSetCursorLocation(self.Text.WrappedText.StringAt(self.Text.WrappedText.Count() - 1).Length(), self.Text.WrappedText.Count() - 1);
									else if (!IsMultiLine)
										textboxSetCursorLocation(self.Text.Text.Length(), 0);
									break;
								// Cursor move with the arrow keys
								case ZTBCMD_CursorPositionChange:
									textboxMoveCursorLocation(e.FirstArg, e.SecondArg);
									break;
								// Idk, remove the last inserted character and move the cursor back?
								case ZTBCMD_Backspace:
									textboxRemoveLastCharacter();
									break;
								case ZTBCMD_CursorBreakToNextLine:
									if (IsMultiLine && self.Text.WrappedText)
									{
										// At the end of the string
										if (cursorLine == lineCount - 1 && cursorIndex > self.Text.WrappedText.StringAt(cursorLine).Length())
											textboxSetCursorLocation(self.Text.WrappedText.StringAt(self.Text.WrappedText.Count() - 1).Length(), self.Text.WrappedText.Count() - 1);
										// Somewhere else
										else if (cursorIndex > self.Text.WrappedText.StringAt(cursorLine).Length())
											textboxMoveCursorLocation(cursorIndex - self.Text.WrappedText.StringAt(cursorLine).Length(), 1);
										lineCount = self.Text.WrappedText.Count();
									}
									break;
							}
						}
					}
				}
			}
			else {}
		}
		return super.ZObj_NetProcess(e);
	}
	
	/*
		This sets the cursor index to where the cursor is in relation to the string
		
	*/
	private void textboxFocusCursorLocation()
	{
		if (HasFocus)
		{
			let nwd = GetParentWindow(self.ControlParent);
			float mx, my;
			[mx, my] = nwd.MoveDifference();
			int sw, sh;
			[sw, sh] = nwd.ScaleDifference();
			
			// These lines use branchless programming to add the scaling accumulates - note the accumulates are multiplied by the result of a boolean (either 0 or 1);
			// this is more efficient than opening up a branch for each circumstance.
			int txdex = self.Text.xLocation + nwd.moveAccumulateX + mx + ((nwd.scaleAccumulateX + sw) * (self.ScaleType == SCALE_Horizontal || self.ScaleType == SCALE_Both)),
				tydex = self.Text.yLocation + nwd.moveAccumulateY + my + ((nwd.scaleAccumulateY + sh) * (self.ScaleType == SCALE_Vertical || self.ScaleType == SCALE_Both));
			if (IsMultiLine && self.Text.WrappedText)
			{
				// Since the textbox is multi-line, figure out what line the cursor should be on (where it is vertically)
				for (int i = 0; i < self.Text.WrappedText.Count(); i++)
				{
					// If the next line is less than the cursor position, add that line in
					if (tydex + Font.GetFont(self.Text.TextFont).GetHeight() < CursorY)
						tydex += Font.GetFont(self.Text.TextFont).GetHeight();
					// Found the line the cursor is on
					else
					{
						cursorLine = i;
						// Now figure out where in the line the cursor is horizontally
						for (int j = 0; j < self.Text.WrappedText.StringAt(i).Length(); j++)
						{
							// If the character is less than the cursor position add the character width in.
							if (txdex + Font.GetFont(self.Text.TextFont).GetCharWidth(self.Text.WrappedText.StringAt(i).ByteAt(j)) < CursorX)
								txdex += Font.GetFont(self.Text.TextFont).GetCharWidth(self.Text.WrappedText.StringAt(i).ByteAt(j));
							// Found where to put the cursor
							else
							{
								cursorIndex = j;
								if (bCursorBlink)
									bCursorBlink = false;
								cursorTickTime = 0;
								break;
							}							
						}
						break;
					}
				}
			}
			else
			{
				// Textbox is not multi-line so just run the length of the string
				for (int i = 0; i < self.Text.Text.Length(); i++)
				{
					// If the character is less than the cursor position add the character width in
					if (txdex + Font.GetFont(self.Text.TextFont).GetCharWidth(self.Text.Text.ByteAt(i)) < CursorX)
						txdex += Font.GetFont(self.Text.TextFont).GetCharWidth(self.Text.Text.ByteAt(i));
					// Found where to put the cursor
					else
					{
						cursorIndex = i;
						if (bCursorBlink)
							bCursorBlink = false;
						cursorTickTime = 0;
						break;
					}
				}
			}
		}
	}
	
	/*
		This directly sets the cursor location
	
	*/
	private void textboxSetCursorLocation(int index, int line)
	{
		cursorIndex = index;
		cursorLine = line;
	}
	
	/*
		This is an incremental move of the cursor
	
	*/
	private void textboxMoveCursorLocation(int index, int line)
	{
		if (IsMultiLine)
		{
			if (cursorIndex + index >= 0 && cursorIndex + index <= self.Text.WrappedText.StringAt(cursorLine).Length())
				cursorIndex += index;
			
			if (cursorLine + line >= 0 && cursorLine + line < self.Text.WrappedText.Count())
			{
				cursorLine += line;
				if (cursorIndex > self.Text.WrappedText.StringAt(cursorLine).Length())
					cursorIndex = self.Text.WrappedText.StringAt(cursorLine).Length();
			}
		}
		else if (cursorIndex + index >= 0 && cursorIndex + index <= self.Text.Text.Length())
			cursorIndex += index;
	}
	
	/*
		This inserts the input character into the string.
		The ZText will update itself if it text wraps.
	
	*/
	private void textboxAppendInput(int inputChar)
	{
			console.printf(string.format("should have inserted character : %s (%d), at index: %d, on line: %d, shift is: %s", string.Format("%c",inputChar), inputChar, cursorIndex, cursorLine, bShift ? "true" : "false"));
			
			string astr;
			int appendIndex = 0;
			// Text is multi-line so figure out string index by line (index is relative to line)
			if (IsMultiLine)
			{
				// Get line length for each line prior to the current line
				for (int i = 0; i < cursorLine; i++)
					appendIndex += Text.WrappedText.StringAt(i).Length() + 1;  // HEY!  C-isms!  Gotta include the \n
				// Ok the fun bit - what does appending do to this line?
				// This checks if the string width plus the new character is greater than the wrapping width,
				// if it is, add in 1 for the extra /n that's about to be thrown in.
				if (Font.GetFont(self.Text.TextFont).StringWidth(self.Text.WrappedText.StringAt(cursorLine)) + Font.GetFont(self.Text.TextFont).GetCharWidth(inputChar) > self.Text.GetTextWrapWidth())
					appendIndex += cursorIndex + 1;
				else
					appendIndex += cursorIndex;
			}
			// Much easier - just go straight to the index
			else
				appendIndex = cursorIndex;
			
			// And slice and dice and jam the string back together.
			astr.AppendFormat("%s%s%s",
							self.Text.Text.Mid(0, appendIndex), 
							bShift ? string.Format("%c", inputChar) : string.Format("%c", inputChar).MakeLower(), 
							self.Text.Text.Mid(appendIndex, self.Text.Text.Length()));  // Length is too large so it'll run till the end of the string
			self.Text.Text = astr;
			cursorIndex++;			
	}
	
	/*
		This removes the character at the cursor location, i.e.
		the string manipulation that has to take place because you,
		yes you Geoffrey, hit the Backspace key.
		
	*/
	private void textboxRemoveLastCharacter()
	{
		if (cursorIndex > 0)
		{
			string astr;
			int backIndex = 0;
			if (IsMultiLine)
			{
				for (int i = 0; i < cursorLine; i++)
					backIndex += Text.WrappedText.StringAt(i).Length() + 1;
				backIndex += cursorIndex;
			}
			else
				backIndex = cursorIndex;
			astr.AppendFormat("%s%s",
							self.Text.Text.Mid(0, backIndex - 1),
							self.Text.Text.Mid(backIndex, self.Text.Text.Length()));
			self.Text.Text = astr;
			cursorIndex--;
		}
	}
	
	/*
		Got a KeyUp event so the current status of
		the control key globals isn't valid anymore,
		so set the back to false.
	
	*/
	private void textboxClearInput()
	{
		bShift = bAlt = bCtrl = false;
	}

	/*
		The text box and the cursor are drawn separately
		because the cursor needs to be drawn on top of everything else.
	
	*/
	override void ObjectDraw(ZObjectBase parent)
	{
		ObjectDraw_TextBox(self);
		if (Text)
			Text.ObjectDraw(self);
		
		ZNetCommand(string.Format("ztxt_CursorBreakToNextLine,%s", self.Name), self.PlayerClient);
		ObjectDraw_TextBoxCursor(self);
	}
	
	ui static void ObjectDraw_TextBox(ZTextBox txb)
	{
		let nwd = GetParentWindow(txb.ControlParent);
		float pclipX, pclipY;
		int pclipWdth, pclipHght;
		bool bClipped = true;
		switch (txb.ClipType)
		{
			case CLIP_Window:
				[pclipX, pclipY] = GetParentWindowLocation(txb.ControlParent);
				[pclipWdth, pclipHght] = GetParentWindowScale(txb.ControlParent);
				break;
			case CLIP_Parent: // This should use the ControlParent's values with moving and scaling accounted for
				float mx, my;
				[mx, my] = nwd.MoveDifference();
				// EVERYTHING MOVES!!!!!!!! - kinda miss C macros - we could just macro this math repitition
				pclipX = txb.ControlParent.xLocation + nwd.moveAccumulateX + mx;
				pclipY = txb.ControlParent.yLocation + nwd.moveAccumulateY + my;
				int sx, sy;
				[sx, sy] = nwd.ScaleDifference();
				if (txb.ControlParent is "ZControl")
				{
					switch (ZControl(txb.ControlParent).ScaleType)
					{
						case SCALE_Horizontal:
							pclipWdth = txb.ControlParent.Width + nwd.scaleAccumulateX + sx;
							pclipHght = txb.ControlParent.Height;
							break;						
						case SCALE_Vertical:
							pclipWdth = txb.ControlParent.Width;
							pclipHght = txb.ControlParent.Height + nwd.scaleAccumulateY + sy;
							break;
						case SCALE_Both:
							pclipWdth = txb.ControlParent.Width + nwd.scaleAccumulateX + sx;
							pclipHght = txb.ControlParent.Height + nwd.scaleAccumulateY + sy;
							break;
						default:
							pclipWdth = txb.ControlParent.Width;
							pclipHght = txb.ControlParent.Height;
							break;
					}
				}
				else
				{
					pclipWdth = txb.ControlParent.Width + nwd.scaleAccumulateX + sx;
					pclipHght = txb.ControlParent.Height + nwd.scaleAccumulateY + sy;
				}
				break;
			default:
				bClipped = false;
				break;
		}
		
		float sxloc, syloc;
		[sxloc, syloc] = nwd.MoveDifference();
		sxloc += txb.xLocation + nwd.moveAccumulateX;
		syloc += txb.yLocation + nwd.moveAccumulateY;
		int nsclx, nscly;
		[nsclx, nscly] = nwd.ScaleDifference();
		switch (txb.ScaleType)
		{
			case SCALE_Horizontal:
				sxloc += nwd.scaleAccumulateX + nsclx;
				break;
			case SCALE_Vertical:
				syloc += nwd.scaleAccumulateY + nscly;
				break;
			case SCALE_Both:
				sxloc += nwd.scaleAccumulateX + nsclx;
				syloc += nwd.scaleAccumulateY + nscly;
				break;
			// don't need a default here, variables are already set
		}
		
		if (txb.Show)
		{
			if (bClipped)
				screen.SetClipRect(pclipX, pclipY, pclipWdth, pclipHght);
			
			// Background
			switch (txb.BackgroundType)
			{
				// These all fall through because just draw the background texture
				case BACKTYP_GameTex1:
				case BACKTYP_GameTex2:
				case BACKTYP_GameTex3:
				case BACKTYP_Custom:
					// This is basically just slap the texture on the screen in this box here.
					if (txb.StretchTexture)
						screen.DrawTexture(txb.BackgroundTexture,
										txb.AnimateTexture, 
										sxloc, 
										syloc,
										DTA_Alpha, txb.Alpha,
										DTA_DestWidth, txb.Width,
										DTA_DestHeight, txb.Height);
					else
					{
						/*
							What this does is first it gets the dimensions of the texture.
							Then it draws that texture in columns, offsetting each loop by
							the x/y of the texture.
							
							Why do and not while loops?  What if the box is really small?
							Smaller than the dimensions of the texture.  Gotta draw at least once.
						*/
						int tx, ty, w = 0;
						Vector2 txy = TexMan.GetScaledSize(txb.BackgroundTexture);
						tx = txy.x;
						ty = txy.y;
						do
						{
							int h = 0;
							do
							{
								screen.DrawTexture (txb.BackgroundTexture,
									txb.AnimateTexture,
									sxloc + (tx * w),
									syloc + (ty * h),
									DTA_Alpha, txb.Alpha,
									DTA_DestWidth, tx,
									DTA_DestHeight, ty);
								h++;
							} while ((((h - 1) * ty) + ty) < txb.Height);
							w++;
						} while ((((w - 1) * tx) + tx) <= txb.Width);
					}
					break;
				// This one is special because it uses a little DrawThickLine trickery
				case BACKTYP_Color:
					screen.DrawThickLine(sxloc,
										syloc + (txb.Height % 2 == 0 ? txb.Height / 2 : ((txb.Height - 1) / 2) + 1),
										sxloc + txb.Width,
										syloc + (txb.Height % 2 == 0 ? txb.Height / 2 : ((txb.Height - 1) / 2) + 1),
										txb.Height,
										txb.BackgroundColor,
										int(255 * txb.Alpha));
					break;
				default:
					/* debug error - invalid background type */
				case BACKTYP_NONE:
					break;
			}
			
			if (bClipped)
				screen.ClearClipRect();
			
			int bdrx, bdry,
				bdrwdth, bdrhght;
			bool clplft = false,
				clprht = false,
				clptop = false,
				clpbot = false;
			
			// Left
			if (pclipX > sxloc)
			{
				bdrx = pclipX;
				clplft = true;
			}
			else
				bdrx = sxloc;
			
			// Top
			if (pclipY > syloc)
			{
				bdry = pclipY;
				clptop = true;
			}
			else
				bdry = syloc;
			
			// Right
			if (pclipX + pclipWdth < sxloc)
				bdrwdth = 0;
			else if (pclipX + pclipWdth < sxloc + txb.Width)
			{
				bdrwdth = (pclipX + pclipWdth) - sxloc;
				clprht = true;
			}
			else
				bdrwdth = txb.Width;
			
			// Bottom
			if (pclipY + pclipHght < syloc)
				bdrhght = 0;
			else if (pclipY + pclipHght < syloc + txb.Height)
			{
				bdrhght = (pclipY + pclipHght) - syloc;
				clpbot = true;
			}
			else
				bdrhght = txb.Height;
			
			// Border
			switch (txb.BorderType)
			{
				case BORDER_Frame:
					screen.DrawFrame(txb.xLocation, txb.yLocation, txb.Width, txb.Height);
					break;
				case BORDER_ThinLine:
					// Top
					if (!clptop)
						screen.DrawLine(bdrx,
										bdry,
										bdrx + bdrwdth,
										bdry,
										txb.BorderColor,
										int(255 * txb.BorderAlpha));
					// Bottom
					if (!clpbot)
						screen.DrawLine(bdrx,
										bdry + bdrhght,
										bdrx + bdrwdth,
										bdry + bdrhght,
										txb.BorderColor,
										int(255 * txb.BorderAlpha));
					// Left
					if (!clplft)
						screen.DrawLine(bdrx,
										bdry,
										bdrx,
										bdry + bdrhght + 1,
										txb.BorderColor,
										int(255 * txb.BorderAlpha));
					// Right
					if (!clprht)
						screen.DrawLine(bdrx + bdrwdth + 1,
										bdry,
										bdrx + bdrwdth + 1,
										bdry + bdrhght + 1,
										txb.BorderColor,
										int(255 * txb.BorderAlpha));
					break;
				case BORDER_ThickLine:
					// Top
					if (!clptop)
						screen.DrawThickLine(bdrx - (!clplft ? txb.BorderThickness : 0),
											bdry - (txb.BorderThickness > 1 ? (txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : ((txb.BorderThickness - 1) / 2) + 1) : txb.BorderThickness),
											bdrx + bdrwdth + (!clprht ? txb.BorderThickness : 0),
											bdry - (txb.BorderThickness > 1 ? (txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : ((txb.BorderThickness - 1) / 2) + 1) : txb.BorderThickness),
											txb.BorderThickness,
											txb.BorderColor,
											int(255 * txb.BorderAlpha));
					// Bottom
					if (!clpbot)
						screen.DrawThickLine(bdrx - (!clplft ? txb.BorderThickness : 0),
											bdry + bdrhght + (txb.BorderThickness > 1 ? (txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : (txb.BorderThickness - 1) / 2) : txb.BorderThickness),
											bdrx + bdrwdth + (!clprht ? txb.BorderThickness : 0),
											bdry + bdrhght + (txb.BorderThickness > 1 ? (txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : (txb.BorderThickness - 1) / 2) : txb.BorderThickness),
											txb.BorderThickness,
											txb.BorderColor,
											int(255 * txb.BorderAlpha));
					// Left
					if (!clplft)
						screen.DrawThickLine(bdrx - (txb.BorderThickness > 1 ?(txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : (txb.BorderThickness - 1) / 2) : txb.BorderThickness),
											bdry,
											bdrx - (txb.BorderThickness > 1 ?(txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : (txb.BorderThickness - 1) / 2) : txb.BorderThickness),
											bdry + bdrhght,
											txb.BorderThickness,
											txb.BorderColor,
											int(255 * txb.BorderAlpha));
					// Right
					if (!clprht)
						screen.DrawThickLine(bdrx + bdrwdth + (txb.BorderThickness > 1 ?(txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : ((txb.BorderThickness - 1) / 2) + 1) : txb.BorderThickness),
											bdry,
											bdrx + bdrwdth + (txb.BorderThickness > 1 ?(txb.BorderThickness % 2 == 0 ? txb.BorderThickness / 2 : ((txb.BorderThickness - 1) / 2) + 1) : txb.BorderThickness),
											bdry + bdrhght,
											txb.BorderThickness,
											txb.BorderColor,
											int(255 * txb.BorderAlpha));
					break;
				default:
					/* debug error - invalid border type*/
				case BORDER_None:
					break;
			}
		}	
	}
	
	/*
		This currently doesn't handle wrapped text.
	
	*/
	ui static void ObjectDraw_TextBoxCursor(ZTextBox txb)
	{
		if (txb.Show)
		{
			let nwd = GetParentWindow(txb.ControlParent);
			float mx, my;
			[mx, my] = nwd.MoveDifference();
			int sw, sh;
			[sw, sh] = nwd.ScaleDifference();
			
			int crsrx = txb.Text.xLocation + nwd.moveAccumulateX + mx + ((nwd.scaleAccumulateX + sw) * (txb.ScaleType == SCALE_Horizontal || txb.ScaleType == SCALE_Both)), 
				crsry = txb.Text.yLocation + nwd.moveAccumulateY + my + ((nwd.scaleAccumulateY + sh) * (txb.ScaleType == SCALE_Vertical || txb.ScaleType == SCALE_Both)), 
				crsrhght = Font.GetFont(txb.Text.TextFont).GetHeight();
			int crsrdex, crsrline;
			[crsrdex, crsrline] = txb.GetCursorIndex();
				
			// Tracking cursor
			if (txb.UseTrackingCursor && txb.ValidateCursorLocation())
			{
				int trackCursorX = crsrx,
					trackCursorY = crsry;
				if (txb.IsMultiLine)
				{
					if (txb.Text.WrappedText)
					{
						for (int i = 0; i < txb.Text.WrappedText.Count(); i++)
						{
							if (trackCursorY + crsrhght < txb.CursorY && i != txb.Text.WrappedText.Count() - 1)
								trackCursorY += crsrhght;
							else
							{
								for (int j = 0; j < txb.Text.WrappedText.StringAt(i).Length(); j++)
								{
									if (trackCursorX + Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.WrappedText.StringAt(i).ByteAt(j)) < txb.CursorX)
										trackCursorX += Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.WrappedText.StringAt(i).ByteAt(j));
									else
										break;
								}
								break;
							}
						}
					}
				}
				else
				{
					for (int i = 0; i < txb.Text.Text.Length(); i++)
					{
						if (trackCursorX + Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.Text.ByteAt(i)) < txb.CursorX)
							trackCursorX += Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.Text.ByteAt(i));
					}
				}
				
				screen.DrawLine(trackCursorX,
					trackCursorY,
					trackCursorX,
					trackCursorY + crsrhght,
					txb.InvertColor(txb.BackgroundColor),  // forgot the text color is an int, need some conversion method here
					255);
			}
		
			// Cursor - this needs fixed
			if (!txb.bCursorBlink && txb.HasFocus)
			{
				int blinkCursorX = crsrx;
				if (txb.IsMultiLine)
				{
					if (txb.Text.WrappedText)
					{
						for (int i = 0; i < crsrdex; i++)
							blinkCursorX += Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.WrappedText.StringAt(crsrline).ByteAt(i));
					}
				}
				else
				{
					for (int i = 0; i < crsrdex; i++)
						blinkCursorX += Font.GetFont(txb.Text.TextFont).GetCharWidth(txb.Text.Text.ByteAt(i));
				}
				screen.DrawLine(blinkCursorX,
								crsry + ((crsrhght * crsrline) * (txb.IsMultiLine && crsrline > 0)),
								blinkCursorX,
								crsry + crsrhght + ((crsrhght * crsrline) * (txb.IsMultiLine && crsrline > 0)),
								txb.InvertColor(txb.BackgroundColor),  // forgot the text color is an int, need some conversion method here
								255);
			}
		}
	}
	
	clearscope color GetTranslationColor(int tc)
	{
		//if (tc < 256)
			//return Translation.colors[tc];
		//else
			return 0xffffff;
	}
	
	clearscope color InvertColor(color baseColor)
	{
		return 0xff000000 | ~baseColor;
	}
	
	override bool ValidateCursorLocation()
	{
		// First we need to figure out where the hell the button is
		let nwd = GetParentWindow(self.ControlParent);
		float mx, my;
		[mx, my] = nwd.MoveDifference();
		int sw, sh;
		[sw, sh] = nwd.ScaleDifference();
		
		// Get priority of the parent window
		int searchPriority;
		if (nwd.ControlParent)
			searchPriority = GetParentWindow(self.ControlParent, false).Priority;
		else
			searchPriority = nwd.Priority;
		
		// Look for higher priority windows
		for (int i = 0; i < searchPriority; i++)
		{
			let enwd = GetWindowByPriority(i);
			if (enwd)
			{
				float enwdX, enwdY;
				[enwdX, enwdY] = enwd.RealWindowLocation(enwd);
				int enwdW, enwdH;
				[enwdW, enwdH] = enwd.RealWindowScale(enwd);
				if (enwdX < CursorX && CursorX < enwdX + enwdW &&
					enwdY < CursorY && CursorY < enwdY + enwdH)
					return false;
			}
		}
		
		// Look for other controls
		if (self.Priority > 0)
		{
			for (int i = 0; i < self.Priority; i++)
			{
				let control = ZObjectBase(nwd.GetControlByPriority(i));
				float cx = control.xLocation + nwd.moveAccumulateX + mx,
					cy = control.yLocation + nwd.moveAccumulateY + my;
				int cw, ch;
				if (control is "ZControl")
				{
					cw = control.Width;
					ch = control.Height;
					
					switch (ZControl(control).ScaleType)
					{
						case SCALE_Horizontal:
							cx += nwd.scaleAccumulateX + sw;
							break;
						case SCALE_Vertical:
							cy += nwd.scaleAccumulateY + sh;
							break;
						case SCALE_Both:
							cx += nwd.scaleAccumulateX + sw;
							cy += nwd.scaleAccumulateY + sh;
							break;
						default:
							break;
					}
				}
				else if (control is "ZSWindow")
				{
					[cx, cy] = ZSWindow(control).RealWindowLocation(ZSWindow(control));
					[cw, ch] = ZSWindow(control).RealWindowScale(ZSWindow(control));
				}
				else
					return false;
				
				if (control && 
					cx < CursorX && CursorX < cx + cw &&
					cy < CursorY && CursorY < cy + ch)
					return false;
			}
		}
		
		// Check this control
		float tx = self.xLocation + nwd.moveAccumulateX + mx,
			ty = self.yLocation + nwd.moveAccumulateY + my;
		switch (self.ScaleType)
		{
			case SCALE_Horizontal:
				tx += nwd.scaleAccumulateX + sw;
				break;
			case SCALE_Vertical:
				ty += nwd.scaleAccumulateY + sh;
				break;
			case SCALE_Both:
				tx += nwd.scaleAccumulateX + sw;
				ty += nwd.scaleAccumulateY + sh;
				break;
			// no need for default
		}
		if (tx < CursorX && CursorX < tx + self.Width &&
			ty < CursorY && CursorY < ty + self.Height)
			return super.ValidateCursorLocation();
		return false;
	}
	
	/*
		Pretty standard validation event.
		This just calls for a focus change if the cursor is on the text box
	
	*/
	override void OnLeftMouseDown(int t)
	{
		if (ValidateCursorLocation())
			SetFocus(true);
		super.OnLeftMouseDown(t);
	}
	
	/*
		Again pretty standard.  The only thing here is
		the call to textboxFocusCursorLocation, which sets
		the cursor index to wherever the cursor is.
		
		The cool thing is that you can hold down the left
		mouse button and scroll to a location, let go, and
		the cursor goes there instead of where you clicked.
		
		This could be used for a highlight system.
	
	*/
	override void OnLeftMouseUp(int t)
	{
		if (IsEventInvalid())
			textboxFocusCursorLocation();
		else if (!ValidateCursorLocation())
			LoseFocus(true);
		
		/* 	The rest of this is standard.  Focusing or priority switching causes the object
			to become "invalidated", which means it can't receive events until it is validated
			again by calling EventValidate.
		*/
		EventValidate();
		super.OnLeftMouseUp(t);
	}
	
	/* - END OF METHODS - */
}