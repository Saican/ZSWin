/*
	ZSWin_Control_Button.zs
	
	Button Control Base Class Definition

*/

class ZButton : ZControl abstract
{
	enum BTNTYPE
	{
		BTN_Standard, 	// single texture with or without border
		BTN_ZButton,		// three textures, no border
		BTN_Radio,
		BTN_Check,
	};
	BTNTYPE Type;
	
	enum BTNSTATE
	{
		BSTATE_Idle,			// no interaction
		BSTATE_Highlight,		// mouse over
		BSTATE_Active,			// clicked on (mouse down, waiting for mouse up)
		BSTATE_DoAction,		// useful if some other condition besides the state is needed to do an action
	};
	BTNSTATE State;
	
	ZText ButtonText;
	bool StretchTexture, AnimateTexture;
	Array<TextureSet> ButtonTextures;
	
	int CursorX, CursorY;
	
	ZButton Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		BTNTYPE Type = BTN_Standard, int Width = 100, int Height = 25, float Btn_xLocation = 0, float Btn_yLocation = 0, float Btn_Alpha = 1,
		CLIPTYP ButtonClipType = CLIP_Parent, SCALETYP ButtonScaleType = SCALE_NONE, bool StretchTexture = false, bool AnimateTexture = false, 
		string IdleTexture = "", string HighlightTexture = "", string ActiveTexture = "",
		string Text = "", Name FontName = 'consolefont', name TextColor = 'White', 
		CLIPTYP TxtClipType = CLIP_Parent, TEXTALIGN TextAlignment = TEXTALIGN_Left, TXTWRAP TextWrap = TXTWRAP_NONE,
		float Txt_xLocation = 0, float Txt_yLocation = 0, float Txt_Alpha = 1)
	{
		self.CursorX = self.CursorY = 0;
		self.Type = Type;
		self.Width = Width;
		self.Height = Height;
		self.xLocation = ControlParent.xLocation + Btn_xLocation;
		self.yLocation = ControlParent.yLocation + Btn_yLocation;
		self.Alpha = Btn_Alpha;
		self.StretchTexture = StretchTexture;
		self.AnimateTexture = AnimateTexture;
		backgroundInit(IdleTexture, HighlightTexture, ActiveTexture);
		if (Text != "")
		{
			bool spwnd;
			actor actrtxt;
			[spwnd, actrtxt] = A_SpawnItemEx("ZText", self.pos.x, self.pos.y, self.pos.z, self.vel.x, self.vel.y, self.vel.z, self.angle, 0, 0, self.tid);
			if (spwnd && actrtxt)
			{
				self.ButtonText = ZText(actrtxt).Init(self, Enabled, Show, string.Format("%s_txt", Name), Text, PlayerClient, UiToggle,
													TxtClipType, ButtonScaleType, TextAlignment, TextWrap, 0, FontName, TextColor, Txt_xLocation, Txt_yLocation, Txt_Alpha);
			}
		}
		return ZButton(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ButtonScaleType, TextAlignment, ClipType));
	}
	
	private void backgroundInit(string IdleTexture, string HighlightTexture, string ActiveTexture)
	{
		TextureSet newSet = new("TextureSet");
		TextureId idleId, highId, activeId;
		
		switch (Type)
		{
			case BTN_Standard:
				if (IdleTexture == "" || HighlightTexture == "" || ActiveTexture == "")
				{
					switch(gameinfo.gametype)
					{
						case GAME_Doom:
							idleId = highId = TexMan.CheckForTexture("ICKWALL1", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("ICKWALL2", TexMan.TYPE_ANY);
							break;
						case GAME_Heretic:
						case GAME_Hexen:
							idleId = highId = TexMan.CheckForTexture("GRNBLOK1", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("BRWNRCKS", TexMan.TYPE_ANY);
							break;
						case GAME_Strife:
							idleId = highId = TexMan.CheckForTexture("BRKBRN02", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("BRKGRY01", TexMan.TYPE_ANY);
							break;
						case GAME_Chex:
							idleId = highId = TexMan.CheckForTexture("GRAY4", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("COMPUTE1", TexMan.TYPE_ANY);
							break;
					}
					
					if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
					{
						newSet.dar_TextureSet.Push(int(idleId));
						newSet.dar_TextureSet.Push(int(highId));
						newSet.dar_TextureSet.Push(int(activeId));
					}
					else
						newSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
					ButtonTextures.Push(newSet);
				}
				else
				{
					idleId = TexMan.CheckForTexture(IdleTexture, TexMan.TYPE_ANY);
					highId = TexMan.CheckForTexture(HighlightTexture, TexMan.TYPE_ANY);
					activeId = TexMan.CheckForTexture(ActiveTexture, TexMan.TYPE_ANY);
					if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
					{
						newSet.dar_TextureSet.Push(int(idleId));
						newSet.dar_TextureSet.Push(int(highId));
						newSet.dar_TextureSet.Push(int(activeId));
					}
					else
						newSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
					
					ButtonTextures.Push(newSet);
				}
				break;
			case BTN_ZButton:
				TextureSet idleSet = new("TextureSet");
				TextureSet highSet = new("TextureSet");
				TextureSet activeSet = new("TextureSet");
				
				TextureId idleLeft = TexMan.CheckForTexture("BSIDIL", TexMan.TYPE_ANY);
				TextureId idleMiddle = TexMan.CheckForTexture("BMIDI", TexMan.TYPE_ANY);
				TextureId idleRight = TexMan.CheckForTexture("BSIDIR", TexMan.TYPE_ANY);
				
				TextureId highLeft = TexMan.CheckForTexture("BSIDHL", TexMan.TYPE_ANY);
				TextureId highMiddle = TexMan.CheckForTexture("BMIDH", TexMan.TYPE_ANY);
				TextureId highRight = TexMan.CheckForTexture("BSIDHR", TexMan.TYPE_ANY);
		
				TextureId activeLeft = TexMan.CheckForTexture("BSIDAL", TexMan.TYPE_ANY);
				TextureId activeMiddle = TexMan.CheckForTexture("BMIDA", TexMan.TYPE_ANY);
				TextureId activeRight = TexMan.CheckForTexture("BSIDAR", TexMan.TYPE_ANY);
				
				bool validIdle = false, validHighlight = false, validActive = false;
				if (idleLeft.IsValid() && idleMiddle.IsValid() && idleRight.IsValid())
				{
					idleSet.dar_TextureSet.Push(int(idleLeft));
					idleSet.dar_TextureSet.Push(int(idleMiddle));
					idleSet.dar_TextureSet.Push(int(idleRight));
					validIdle = true;
				}
				else
					idleSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (highLeft.IsValid() && highMiddle.IsValid() && highRight.IsValid())
				{
					highSet.dar_TextureSet.Push(int(highLeft));
					highSet.dar_TextureSet.Push(int(highMiddle));
					highSet.dar_TextureSet.Push(int(highRight));					
					validHighlight = true;
				}
				else
					highSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (activeLeft.IsValid() && activeMiddle.IsValid() && activeRight.IsValid())
				{
					activeSet.dar_TextureSet.Push(int(activeLeft));
					activeSet.dar_TextureSet.Push(int(activeMiddle));
					activeSet.dar_TextureSet.Push(int(activeRight));					
					validActive = true;
				}
				else
					activeSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (validIdle && validHighlight && validActive)
				{
					// Height is overwriten here to the size of the idle texture if all textures are accounted for
					let twh = TexMan.GetScaledSize(idleLeft);
					Height = twh.y;
				}
				
				ButtonTextures.Push(idleSet);
				ButtonTextures.Push(highSet);
				ButtonTextures.Push(activeSet);
				break;
			case BTN_Radio:
				idleId = TexMan.CheckForTexture("BRDCKIS", TexMan.TYPE_ANY);
				highId = TexMan.CheckForTexture("BRDCKHS", TexMan.TYPE_ANY);
				activeId = TexMan.CheckForTexture("BRDIOAS", TexMan.TYPE_ANY);
				
				if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
				{
					newSet.dar_TextureSet.Push(int(idleId));
					newSet.dar_TextureSet.Push(int(highId));
					newSet.dar_TextureSet.Push(int(activeId));
					
					// Width and Height is overwriten here to the size of the idle texture
					// - it's assumed all three textures are the same size
					let twh = TexMan.GetScaledSize(idleId);
					Width = twh.x;
					Height = twh.y;
				}
				else
					newSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				ButtonTextures.Push(newSet);
				break;
			case BTN_Check:
				idleId = TexMan.CheckForTexture("BRDCKIS", TexMan.TYPE_ANY);
				highId = TexMan.CheckForTexture("BRDCKHS", TexMan.TYPE_ANY);
				activeId = TexMan.CheckForTexture("BCHCKAS", TexMan.TYPE_ANY);
				
				if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
				{
					newSet.dar_TextureSet.Push(int(idleId));
					newSet.dar_TextureSet.Push(int(highId));
					newSet.dar_TextureSet.Push(int(activeId));
					
					// Width and Height is overwriten here to the size of the idle texture
					// - it's assumed all three textures are the same size
					let twh = TexMan.GetScaledSize(idleId);
					Width = twh.x;
					Height = twh.y;
				}
				else
					newSet.dar_TextureSet.Push(int(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				ButtonTextures.Push(newSet);
				break;
		}
	}
	
	override bool ZObj_UiProcess(ZUIEventPacket e) 
	{ 
		if (e.MouseX != CursorX || e.MouseY != CursorY)
			ZNetCommand(string.Format("zbtn_updateCursorLocation,%s", self.Name), self.PlayerClient, e.MouseX, e.MouseY);

		return super.ZObj_UiProcess(e); 
	}

	enum ZBTNNETCMD
	{
		ZBTNCMD_ShowCheckEnabled,
		ZBTNCMD_UpdateCursorLocation,

		ZBTNCMD_TryString,
	};

	private ZBTNNETCMD stringToZBtnNetCommand(string e)
	{
		if (e ~== "zobj_ShowCheckEnabled")
			return ZBTNCMD_ShowCheckEnabled;
		if (e ~== "zbtn_updateCursorLocation")
			return ZBTNCMD_UpdateCursorLocation;
		else
			return ZBTNCMD_TryString;
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
						if (cmd.Size() >= 2 ? cmd[1] ~== self.Name : false)
						{
							switch (stringToZBtnNetCommand(cmd[0]))
							{
								case ZBTNCMD_UpdateCursorLocation:
									CursorX = e.FirstArg;
									CursorY = e.SecondArg;
									break;
								default:
									ZBtn_NetProcess_String(e);
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

	private void ZBtn_NetProcess_String(ZEventPacket e)
	{
		// Separate the command string from the player number
		Array<string> cmdPlyr;
		e.EventName.Split(cmdPlyr, "?");
		// Check there's two halves and the second half is equal the this object's assigned player
		if (cmdPlyr.Size() == 2 ? (cmdPlyr[1].ToInt() == self.PlayerClient) : false)
		{
			// Split the command string into a command list
			Array<string> cmdc;
			cmdPlyr[0].Split(cmdc, ":");
			// Execute the command ist
			for (int i = 0; i < cmdc.Size(); i++)
			{
				if (cmdc[i] != "")
				{
					// Chop up each command into an argument list
					Array<string> cmd;
					cmdc[i].Split(cmd, ",");
					// There's at least something, right? (no argument command)
					if (cmd.Size() > 0)
					{
						// Index 0 of the command should be the command itself
						switch (stringToZBtnNetCommand(cmd[0]))
						{
							case ZBTNCMD_ShowCheckEnabled:
								if (self.ButtonText)
								{
									self.ButtonText.Show = self.Show;
									self.ButtonText.ShowCheck();
								}
								break;
						}
					}
				}
			}
		}
	}
	
	override void ObjectDraw(ZObjectBase parent)
	{
		ObjectDraw_Button(self);
		if (ButtonText)
			ButtonText.ObjectDraw(self);
	}
	
	ui static TextureId GetButtonTexture(ZButton btn)
	{
		return (btn.ButtonTextures[0].dar_TextureSet.Size() > 1 ? btn.ButtonTextures[0].dar_TextureSet[btn.State] : btn.ButtonTextures[0].dar_TextureSet[0]);
	}
	
	ui static float GetButtonAlpha(ZObjectBase parent, ZButton btn)
	{
		return GetParentWindow(parent).GetFloatAlpha(GetParentWindow(parent)) == 0 ? (btn.Enabled ? btn.Alpha : GetParentWindow(parent).DISABLEDALPHA) : GetParentWindow(parent).GetFloatAlpha(GetParentWindow(parent));
		//return ZSWindow(parent).GetFloatAlpha(ZSWindow(parent)) == 0 ? (btn.Enabled ? btn.Alpha : ZSWindow(parent).DISABLEDALPHA) : ZSWindow(parent).GetFloatAlpha(ZSWindow(parent));
	}
	
	ui static void ObjectDraw_Button(ZButton btn)
	{
		// Get the clipping boundary
		let nwd = GetParentWindow(btn.ControlParent);
		float pclipX, pclipY;
		int pclipWdth, pclipHght;
		bool bClipped = true;
		switch (btn.ClipType)
		{
			case CLIP_Window:
				[pclipX, pclipY] = GetParentWindowLocation(btn.ControlParent);
				[pclipWdth, pclipHght] = GetParentWindowScale(btn.ControlParent);
				break;
			case CLIP_Parent: // This should use the ControlParent's values with moving and scaling accounted for
				float mx, my;
				[mx, my] = nwd.MoveDifference();
				// EVERYTHING MOVES!!!!!!!! - kinda miss C macros - we could just macro this math repitition
				pclipX = btn.ControlParent.xLocation + nwd.moveAccumulateX + mx;
				pclipY = btn.ControlParent.yLocation + nwd.moveAccumulateY + my;
				int sx, sy;
				[sx, sy] = nwd.ScaleDifference();
				if (btn.ControlParent is "ZControl")
				{
					switch (ZControl(btn.ControlParent).ScaleType)
					{
						case SCALE_Horizontal:
							pclipWdth = btn.ControlParent.Width + nwd.scaleAccumulateX + sx;
							pclipHght = btn.ControlParent.Height;
							break;						
						case SCALE_Vertical:
							pclipWdth = btn.ControlParent.Width;
							pclipHght = btn.ControlParent.Height + nwd.scaleAccumulateY + sy;
							break;
						case SCALE_Both:
							pclipWdth = btn.ControlParent.Width + nwd.scaleAccumulateX + sx;
							pclipHght = btn.ControlParent.Height + nwd.scaleAccumulateY + sy;
							break;
						default:
							pclipWdth = btn.ControlParent.Width;
							pclipHght = btn.ControlParent.Height;
							break;
					}
				}
				else
				{
					pclipWdth = btn.ControlParent.Width + nwd.scaleAccumulateX + sx;
					pclipHght = btn.ControlParent.Height + nwd.scaleAccumulateY + sy;
				}
				break;
			default:
				bClipped = false;
				break;
		}
		
		float sxloc, syloc;
		[sxloc, syloc] = nwd.MoveDifference();
		sxloc += btn.xLocation + nwd.moveAccumulateX;
		syloc += btn.yLocation + nwd.moveAccumulateY;
		int nsclx, nscly;
		[nsclx, nscly] = nwd.ScaleDifference();
		switch (btn.ScaleType)
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
		
		int clipx, clipy, 
			wdth, hght;
		bool cliplft = false, 
			cliprht = false, 
			cliptop = false, 
			clipbot = false;
		
		if (btn.Show)
		{			
			if (pclipX > sxloc)
			{
				clipx = pclipX;
				cliplft = true;
			}
			else
				clipx = sxloc;
			
			if (pclipY > syloc)
			{
				clipy = pclipY;
				cliptop = true;
			}
			else
				clipy = syloc;
			
			if (pclipX + pclipWdth < sxloc)
				wdth = 0;
			else if (pclipX + pclipWdth < sxloc + btn.Width)
			{
				wdth = (pclipX + pclipWdth) - sxloc;
				cliprht = true;
			}
			else
				wdth = btn.Width;
			
			if (pclipY + pclipHght < syloc)
				hght = 0;
			else if (pclipY + pclipHght < syloc + btn.Height)
			{
				hght = (pclipY + pclipHght) - syloc;
				clipbot = true;
			}
			else
				hght = btn.Height;

			switch (btn.Type)
			{
				case BTN_Standard:
					// Background
					if (btn.StretchTexture)
					{
						if (bClipped)
							screen.SetClipRect(pclipX, pclipY, pclipWdth, pclipHght);
						screen.DrawTexture(GetButtonTexture(btn),
										btn.AnimateTexture, 
										sxloc, 
										syloc,
										DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
										DTA_DestWidth, btn.Width,
										DTA_DestHeight, btn.Height);
						// Clear the clipping boundary
						if (bClipped)
							screen.ClearClipRect();
					}
					else
					{							
						int tx, ty, w = 0;
						Vector2 txy = TexMan.GetScaledSize(GetButtonTexture(btn));
						tx = txy.x;
						ty = txy.y;
						if (bClipped)
							Screen.SetClipRect(clipx, clipy, wdth, hght);
						do
						{
							int h = 0;
							do
							{
								Screen.DrawTexture (GetButtonTexture(btn), 
									btn.AnimateTexture,
									sxloc + (tx * w),
									syloc + (ty * h),
									DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
									DTA_DestWidth, tx,
									DTA_DestHeight, ty);
								h++;
							} while ((((h - 1) * ty) + ty) < btn.Height);
							w++;
						} while ((((w - 1) * tx) + tx) <= btn.Width);
						if (bClipped)
							screen.ClearClipRect();
					}
					// Border
					// Code enforces box and thickbox types
					/*switch (nwd.GetButton(i).Border.Type)
					{
						case ZShape.box:
							if (!cliptop)
								Screen.DrawLine(clipx - 1, 
												clipy - 1, 
												clipx + wdth, 
												clipy - 1, 
												nwd.GetButton(i).Border.Color, 
												int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!clipbot)
								Screen.DrawLine(clipx - 1, 
												clipy + hght, 
												clipx + wdth, 
												clipy + hght, 
												nwd.GetButton(i).Border.Color, 
												int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!cliplft)
								Screen.DrawLine(clipx, 
												clipy, 
												clipx, 
												clipy + hght, 
												nwd.GetButton(i).Border.Color, 
												int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!cliprht)
								Screen.DrawLine(clipx + wdth, 
												clipy, 
												clipx + wdth, 
												clipy + hght, 
												nwd.GetButton(i).Border.Color, 
												int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							break;
						case ZShape.thickbox:
							if (!cliptop)
								Screen.DrawThickLine(clipx - (!cliplft ? nwd.GetButton(i).Border.LineThickness : 0), 
													clipy - (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : ((nwd.GetButton(i).Border.LineThickness - 1) / 2) + 1) : nwd.GetButton(i).Border.LineThickness), 
													clipx + wdth + (!cliprht ? nwd.GetButton(i).Border.LineThickness : 0), 
													clipy - (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : ((nwd.GetButton(i).Border.LineThickness - 1) / 2) + 1) : nwd.GetButton(i).Border.LineThickness),
													nwd.GetButton(i).Border.LineThickness,
													nwd.GetButton(i).Border.Color,
													int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!clipbot)
								Screen.DrawThickLine(clipx - (!cliplft ? nwd.GetButton(i).Border.LineThickness : 0), 
													clipy + hght + (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : (nwd.GetButton(i).Border.LineThickness - 1) / 2) : nwd.GetButton(i).Border.LineThickness), 
													clipx + wdth + (!cliprht ? nwd.GetButton(i).Border.LineThickness : 0), 
													clipy + hght + (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : (nwd.GetButton(i).Border.LineThickness - 1) / 2) : nwd.GetButton(i).Border.LineThickness),
													nwd.GetButton(i).Border.LineThickness,
													nwd.GetButton(i).Border.Color,
													int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!cliplft)
								Screen.DrawThickLine(clipx - (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : (nwd.GetButton(i).Border.LineThickness - 1) / 2) : nwd.GetButton(i).Border.LineThickness),
													clipy,
													clipx - (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : (nwd.GetButton(i).Border.LineThickness - 1) / 2) : nwd.GetButton(i).Border.LineThickness),
													clipy + hght,
													nwd.GetButton(i).Border.LineThickness,
													nwd.GetButton(i).Border.Color,
													int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							if (!cliprht)
								Screen.DrawThickLine(clipx + wdth + (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : ((nwd.GetButton(i).Border.LineThickness - 1) / 2) + 1) : nwd.GetButton(i).Border.LineThickness),
													clipy,
													clipx + wdth + (nwd.GetButton(i).Border.LineThickness > 1 ? (nwd.GetButton(i).Border.LineThickness % 2 == 0 ? nwd.GetButton(i).Border.LineThickness / 2 : ((nwd.GetButton(i).Border.LineThickness - 1) / 2) + 1) : nwd.GetButton(i).Border.LineThickness),
													clipy + hght,
													nwd.GetButton(i).Border.LineThickness,
													nwd.GetButton(i).Border.Color,
													int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
							break;
						default:
							// need a debug message here - invalid border type for button
						case ZShape.noshape:
							break;
					}*/
					break;
				case BTN_Radio:
				case BTN_Check:
					if (bClipped)
						screen.SetClipRect(clipx, clipy, wdth, hght);
					screen.DrawTexture(GetButtonTexture(btn),
									btn.AnimateTexture, 
									sxloc, 
									syloc,
									DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
									DTA_DestWidth, btn.Width,
									DTA_DestHeight, btn.Height);
					if (bClipped)
						screen.ClearClipRect();
					break;
				case BTN_ZButton:
					TextureId leftSide, middle, rightSide;
					// Do we have more at least one TextureSet?
					if (btn.ButtonTextures.Size() > 0)
					{
						// We do, so check if there's 3 sets with exactly 3 textures each
						if (btn.ButtonTextures.Size() == 3 &&
							btn.ButtonTextures[btn.State].dar_TextureSet.Size() == 3)
						{
							leftSide = btn.ButtonTextures[btn.State].dar_TextureSet[0];
							middle = btn.ButtonTextures[btn.State].dar_TextureSet[1];
							rightSide = btn.ButtonTextures[btn.State].dar_TextureSet[2];
						}
						// There's not, so check if there's 3 sets with at least one texure each
						else if (btn.ButtonTextures.Size() == 3 &&
								btn.ButtonTextures[btn.State].dar_TextureSet.Size() > 0)
							leftSide = middle = rightSide = btn.ButtonTextures[btn.State].dar_TextureSet[0];
						// Ok, theres at least one texture set, so check it has something in it and use it!
						else if (btn.ButtonTextures[0].dar_TextureSet.Size() > 0)
							leftSide = middle = rightSide = btn.ButtonTextures[0].dar_TextureSet[0];
						// Something is really wrong, just stop.
						else
							break;
					}
					// The button doesn't have any textures?! WHAAAT?!
					else
						break;
					
					// Left and right sides are drawn, then the clipping boundary is ammended for the tiled middle
					if (bClipped)
						screen.SetClipRect(clipx, clipy, wdth, hght);
					int lx, ly, rx, ry;
					Vector2 lxy = TexMan.GetScaledSize(leftSide);
					lx = lxy.x;
					ly = lxy.y;
					screen.DrawTexture(leftSide,
									btn.AnimateTexture, 
									sxloc, 
									syloc,
									DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
									DTA_DestWidth, lx,
									DTA_DestHeight, ly);	
					Vector2 rxy = TexMan.GetScaledSize(rightSide);
					rx = rxy.x;
					ry = rxy.y;	
					screen.DrawTexture(rightSide,
									btn.AnimateTexture, 
									sxloc + btn.Width - rx, 
									syloc,
									DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
									DTA_DestWidth, rx,
									DTA_DestHeight, ry);										
					if (bClipped)
						screen.ClearClipRect();
						
					int midclipx, midwdth;
					if (clipx > sxloc + lx)
						midclipx = clipx;
					else
						midclipx = sxloc + lx;
					
					if (clipx + wdth < sxloc + lx)
						midwdth = 0;
					else if (clipx + wdth < sxloc + btn.Width - rx)
						midwdth = btn.Width - lx - ((sxloc + btn.Width) - (clipx + wdth));
					else
						midwdth = btn.Width - lx - rx;
					
					int mx, my;
					Vector2 mxy = TexMan.GetScaledSize(middle);
					mx = mxy.x;
					my = mxy.y;
					if (bClipped)
						screen.SetClipRect(midclipx, clipy, midwdth, hght);
					int w = 0;
					// No height loop because the height is the height of the textures
					do
					{
						Screen.DrawTexture (middle, 
							btn.AnimateTexture,
							sxloc + lx + (mx * w),
							syloc,
							DTA_Alpha, GetButtonAlpha(btn.ControlParent, btn),
							DTA_DestWidth, mx,
							DTA_DestHeight, my);
						w++;
					} while ((((w - 1) * mx) + mx) <= midwdth);
					if (bClipped)
						screen.ClearClipRect();
					break;
			}
		}
	}
	
	override bool ValidateCursorLocation()
	{
		if (self.Enabled)
		{
			// First we need to figure out where the hell the button is
			let nwd = GetParentWindow(self.ControlParent);
			float mx, my;
			[mx, my] = nwd.MoveDifference();
			int sw, sh;
			[sw, sh] = nwd.ScaleDifference();
			
			// Get the cursor location and the priority of the parent window
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
		}
		return false;
	}
	
	/* - END OF METHODS - */
}