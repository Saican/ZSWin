/*
	ZSWin_Object_Text.zs
	
	Text Control Class Definition
	
	This control does not need to be inherited from, 
	it should be initialized directly.

*/

class ZText : ZControl
{
	string Text;
	BrokenLines WrappedText;
	
	int WrapWidth;
	
	name TextFont, TextColor;
	
	ZText Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, string Text, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_Parent, SCALETYP ScaleType = SCALE_NONE, TEXTALIGN TextAlignment = TEXTALIGN_Left,
		TXTWRAP TextWrap = TXTWRAP_NONE, int WrapWidth = 0, name TextFont = 'consolefont', name TextColor = 'Black',
		float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		self.Text = Text;
		self.TextWrap = TextWrap;
		self.WrapWidth = WrapWidth;
		self.TextFont = TextFont;
		self.TextColor = TextColor;
		self.xLocation = ControlParent.xLocation + xLocation;
		self.yLocation = ControlParent.yLocation + yLocation;
		self.Alpha = Alpha;
		if (self.TextFont)
			return ZText(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ScaleType, TextAlignment, ClipType));
		else
			return ZText(HCF(" - - TEXT CONTROL DOES NOT HAVE A VALID FONT!"));
	}
	
	override bool ZObj_UiTick()
	{
		// If this control dynamically wraps its text it needs to update its broken lines
		// prior to the next draw.  This is done from sending an AddToUITicker event.
		// This event is actually sending 2 events, AddToUITicker and ControlUpdate.
		// AddToUITicker will put ControlUpdate and everything else into an event packet
		// for processing by the UITicker.
		if (TextWrap == TXTWRAP_Dynamic)
			ZNetCommand(string.Format("zevsys_AddToUITicker,zobj_ControlUpdate,%s", self.Name), self.PlayerClient);
			//ZEvent.SendNetworkEvent(string.Format("zswin_AddToUITicker:zswin_ControlUpdate,%s", self.Name));
		return super.ZObj_UiTick();
	}
	
	override void ObjectUpdate()
	{
		BrokenLines newLines;
		Font fnt = Font.GetFont(self.TextFont);
		switch (TextWrap)
		{
			case TXTWRAP_Wrap:
				if (WrapWidth > 0)
					newLines = fnt.BreakLines(self.Text, self.WrapWidth);
				else
					newLines = fnt.BreakLines(self.Text, self.ControlParent.Width);
				break;
			case TXTWRAP_Dynamic:
				int cw, ch;
				// How does the text want to be clipped?
				switch (self.ClipType)
				{
					// To the Window
					case CLIP_Window:
						[cw, ch] = GetParentWindowScale(self.ControlParent);
						break;
					// To its parent
					case CLIP_Parent:
						// Go ahead and get the window anyway
						let nwd = GetParentWindow(self.ControlParent);
						// Check that the parent is actually a control
						if (self.ControlParent is "ZControl")
						{
							// Ok, how does it scale?
							switch(ZControl(self.ControlParent).ScaleType)
							{
								// Horizontal or Both we need the xscale stuff
								case SCALE_Horizontal:
								case SCALE_Both:
									int diffx, diffy;
									[diffx, diffy] =  nwd.ScaleDifference();
									cw = self.ControlParent.Width + nwd.scaleAccumulateX + diffx;
									break;
								// Not scaling, so just set to the parent width
								default:
									cw = self.ControlParent.Width;
									break;
							}
						}
						// Parent is a window so get the window scale
						else
							[cw, ch] = nwd.RealWindowScale(nwd);
						break;
					// Dynamic but doesn't specify? Well Screen width then.
					default:
						cw = screen.GetWidth();
						break;
				}
				newLines = fnt.BreakLines(self.Text, cw);
				break;
		}
		
		WrappedText = newLines;
	}
	
	override void ObjectDraw(ZObjectBase parent)
	{
		ObjectDraw_Text(parent, self);
	}
	
	clearscope static float GetAlignment (ZText txt, float xLocation, float Width, string line)
	{
		Font fnt = Font.GetFont(txt.TextFont);
		switch (txt.TextAlignment)
		{
			default:
			case TEXTALIGN_Left: 
				return xLocation;
			case TEXTALIGN_Right: 
				return (xLocation + Width) - fnt.StringWidth(line);
			case TEXTALIGN_Center: 
				return xLocation + ((Width - fnt.StringWidth(line)) / 2);
		}
	}
	
	ui static void ObjectDraw_Text(ZObjectBase parent, ZText txt)
	{
		let nwd = GetParentWindow(txt.ControlParent);
		float sxloc, syloc;
		[sxloc, syloc] = nwd.MoveDifference();
		int nsclx, nscly;
		[nsclx, nscly] = nwd.ScaleDifference();
		
		// Get the clipping boundary
		float pclipX, pclipY;
		int pclipWdth = 0, pclipHght;
		bool bClipped = true;
		switch (txt.ClipType)
		{
			case CLIP_Window:
				[pclipX, pclipY] = GetParentWindowLocation(txt.ControlParent);
				[pclipWdth, pclipHght] = GetParentWindowScale(txt.ControlParent);
				break;
			case CLIP_Parent:
				pclipX = parent.xLocation + nwd.moveAccumulateX + sxloc;
				pclipY = parent.yLocation + nwd.moveAccumulateY + syloc;
				if (parent is "ZControl")
				{
					switch (ZControl(parent).ScaleType)
					{
						case SCALE_Horizontal:
							pclipWdth = parent.Width + nwd.scaleAccumulateX + nsclx;
							pclipHght = parent.Height;
							break;
						case SCALE_Vertical:
							pclipWdth = parent.Width;
							pclipHght = parent.Height + nwd.scaleAccumulateY + nscly;
							break;
						case SCALE_Both:
							pclipWdth = parent.Width + nwd.scaleAccumulateX + nsclx;
							pclipHght = parent.Height + nwd.scaleAccumulateY + nscly;
							break;
						default:
							pclipWdth = parent.Width;
							pclipHght = parent.Height;
							break;
					}
				}
				else
					[pclipWdth, pclipHght] = GetParentWindowScale(txt.ControlParent);
				break;
			default:
				bClipped = false;
				break;
		}
		
		sxloc += txt.xLocation + nwd.moveAccumulateX;
		syloc += txt.yLocation + nwd.moveAccumulateY;
		switch (txt.ScaleType)
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
		
		if (txt.Show)
		{
			if (bClipped)
				screen.SetClipRect(pclipX, pclipY, pclipWdth, pclipHght);
			switch (txt.TextWrap)
			{
				case TXTWRAP_Wrap:
				case TXTWRAP_Dynamic:
					if (!txt.WrappedText)
						ZNetCommand(string.Format("zevsys_AddToUITicker,zobj_ControlUpdate,%s", txt.Name), txt.PlayerClient);
						//EventHandler.SendNetworkEvent(string.Format("zswin_AddToUITicker,zswin_ControlUpdate,%s", txt.Name));
					else
					//if (txt.WrappedText)
					{
						for (int i = 0; i < txt.WrappedText.Count(); i++)
							Screen.DrawText(Font.GetFont(txt.TextFont),
											Font.FindFontColor(txt.TextColor),
											GetAlignment(txt, sxloc, pclipWdth, txt.WrappedText.StringAt(i)),
											syloc + (i * Font.GetFont(txt.TextFont).GetHeight()),
											txt.WrappedText.StringAt(i),
											DTA_Alpha, txt.Alpha);
					}
					break;
				default:
					Screen.DrawText(Font.GetFont(txt.TextFont),
									Font.FindFontColor(txt.TextColor),
									GetAlignment(txt, sxloc, pclipWdth, txt.Text),
									syloc,
									txt.Text,
									DTA_Alpha, txt.Alpha);
					break;
			}
			if (bClipped)
				Screen.ClearClipRect();
		}
	}
}