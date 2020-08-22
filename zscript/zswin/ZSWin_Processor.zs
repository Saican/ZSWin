/*
	ZSWin_Drawer.zs
	
	- Nothing for users here, this class
	  contains the methods for drawing
	  windows.

*/

class ZDrawer
{
	/*
		Calculates and returns the real window location;
	
	*/
	clearscope float, float realWindowLocation(ZSWindow nwd)
	{
		int diffx, diffy;
		[diffx, diffy] = nwd.MoveDifference();
		return nwd.xLocation + nwd.moveAccumulateX + diffx,
				nwd.yLocation + nwd.moveAccumulateY + diffy;
	}
	
	/*
		Calculates and returns the real width/height of the window
	
	*/
	clearscope int, int realWindowScale(ZSWindow nwd)
	{
		int diffx, diffy;
		[diffx, diffy] = nwd.ScaleDifference();
		return nwd.Width + nwd.scaleAccumulateX + diffx,
			nwd.Height + nwd.scaleAccumulateY + diffy;
	}
	
	/*
		Calculates and returns the control's scaled location
		
		You add this to a control's location - if the control reacts to scaling
	
	*/
	clearscope float, float realControlScaledLocation(ZSWindow nwd)
	{
		float scalediffx, scalediffy,
			movediffx, movediffy;
		[scalediffx, scalediffy] = nwd.ScaleDifference();
		[movediffx, movediffy] = nwd.MoveDifference();
		return nwd.xLocation + nwd.moveAccumulateX + movediffx + nwd.scaleAccumulateX + scalediffx,
			nwd.yLocation + nwd.moveAccumulateY + movediffy + nwd.scaleAccumulateY + scalediffy;
	}
	
	
	/*
		Draws the window background
	
	*/
	ui void WindowProcess_Background(ZSWindow nwd)
	{
		// Check that the textures is valid
		if (nwd.BackgroundTexture.IsValid())
		{
			float nwdX, nwdY;
			[nwdX, nwdY] = realWindowLocation(nwd);
			
			int realWidth, realHeight;
			[realWidth, realHeight] = realWindowScale(nwd);
			
			// Stretch texture
			if (nwd.Stretch)
				Screen.DrawTexture(nwd.BackgroundTexture, false,
					nwdX, nwdY,
					DTA_Alpha, nwd.GlobalEnabled ? nwd.BackgroundAlpha : nwd.GlobalAlpha,
					DTA_DestWidth, realWidth,
					DTA_DestHeight, realHeight);
			// Tile texture
			else
			{
				// Set the clipping boundary to the window
				nwd.zHandler.WindowClip(nwd);
				int tx, ty, w = 0;
				Vector2 txy = TexMan.GetScaledSize(nwd.BackgroundTexture);
				tx = txy.x;
				ty = txy.y;
				do
				{
					int h = 0;
					do
					{
						Screen.DrawTexture (nwd.BackgroundTexture, false,
							nwdX + (tx * w),
							nwdY + (ty * h),
							DTA_Alpha, nwd.GlobalEnabled ? nwd.BackgroundAlpha : nwd.GlobalAlpha,
							DTA_DestWidth, tx,
							DTA_DestHeight, ty);
						h++;
					} while ((((h - 1) * ty) + ty)  < realHeight);
					w++;
				} while ((((w -1) * tx) + tx) <= realWidth);
				nwd.zHandler.WindowClip(set:false);
			}
		}
	}
	
	/*
		Window Border Drawer
	
	*/
	ui void WindowProcess_Border(ZSWindow nwd)
	{
		float nwdX, nwdY;
		[nwdX, nwdY] = realWindowLocation(nwd);
		
		int realWidth, realHeight;
		[realWidth, realHeight] = realWindowScale(nwd);
		
		switch (nwd.BorderType)
		{
			case nwd.Game:
				Screen.DrawFrame(nwdX, nwdY, realWidth, realHeight);
				break;
			case nwd.Line:
				Screen.DrawLine(nwdX, nwdY, nwdX + realWidth, nwdY, nwd.BorderColor, int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				Screen.DrawLine(nwdX, nwdY + realHeight, nwdX + realWidth, nwdY + realHeight, nwd.BorderColor, int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				Screen.DrawLine(nwdX, nwdY, nwdX, nwdY + realHeight, nwd.BorderColor, int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				Screen.DrawLine(nwdX + realWidth, nwdY, nwdX + realWidth, nwdY + realHeight, nwd.BorderColor, int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				break;
			case nwd.ThickLine:
				// Top
				Screen.DrawThickLine(nwdX - nwd.BorderThickness, 
									nwdY - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwdX + realWidth + nwd.BorderThickness, 
									nwdY - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				// Bottom
				Screen.DrawThickLine(nwdX - nwd.BorderThickness, 
									nwdY + realHeight + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwdX + realWidth + nwd.BorderThickness, 
									nwdY + realHeight + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				// Left
				Screen.DrawThickLine(nwdX - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwdY, 
									nwdX - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwdY + realHeight, 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				// Right
				Screen.DrawThickLine(nwdX + realWidth + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwdY, 
									nwdX + realWidth + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwdY + realHeight, 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * (nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha)));
				break;
			case nwd.ZWin_Border:
				// Top Left Corner
				Screen.DrawTexture(nwd.gfxBorder.Corner_TopLeft, false,
					nwdX - nwd.gfxBorder.BorderWidth, 
					nwdY - nwd.gfxBorder.BorderHeight,
					DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Top Right Corner	
				Screen.DrawTexture(nwd.gfxBorder.Corner_TopRight, false,
					nwdX + realWidth, 
					nwdY - nwd.gfxBorder.BorderHeight,
					DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Bottom Left Corner
				Screen.DrawTexture(nwd.gfxBorder.Corner_BottomLeft, false,
					nwdX - nwd.gfxBorder.BorderWidth, 
					nwdY + realHeight,
					DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Bottom Right Corner	
				Screen.DrawTexture(nwd.gfxBorder.Corner_BottomRight, false,
					nwdX + realWidth, 
					nwdY + realHeight,
					DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				
				Screen.SetClipRect(nwdX,
								nwdY - nwd.gfxBorder.BorderHeight,
								realWidth,
								realHeight + (nwd.gfxBorder.BorderHeight * 2));				
				int w = 0;
				do
				{
					Screen.DrawTexture(nwd.gfxBorder.Side_Top, false,
									nwdX + (nwd.gfxBorder.BorderWidth * w),
									nwdY - nwd.gfxBorder.BorderHeight,
									DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					Screen.DrawTexture(nwd.gfxBorder.Side_Bottom, false,
									nwdX + (nwd.gfxBorder.BorderWidth * w),
									nwdY + realHeight,
									DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					w++;
				} while (((w - 1) * nwd.gfxBorder.BorderWidth) + nwd.gfxBorder.BorderWidth <= realWidth);
				nwd.zHandler.WindowClip(set:false);
				
				Screen.SetClipRect(nwdX - nwd.gfxBorder.BorderWidth,
								nwdY,
								realWidth + (nwd.gfxBorder.BorderWidth * 2),
								realHeight);
				int h = 0;
				do
				{
					Screen.DrawTexture(nwd.gfxBorder.Side_Left, false,
									nwdX - nwd.gfxBorder.BorderWidth,
									nwdY + (nwd.gfxBorder.BorderHeight * h),
									DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					Screen.DrawTexture(nwd.gfxBorder.Side_Right, false,
									nwdX + realWidth,
									nwdY + (nwd.gfxBorder.BorderHeight * h),
									DTA_Alpha, nwd.GlobalEnabled ? nwd.BorderAlpha : nwd.GlobalAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					h++;
				} while (((h - 1) * nwd.gfxBorder.BorderHeight) + nwd.gfxBorder.BorderHeight <= realHeight);
				nwd.zHandler.WindowClip(set:false);
				break;
			default:
				EventHandler.SendNetworkEvent(string.Format("zswin_debugOut:%s:%s", "badBorderProcess", string.Format("ERROR! - Window, %s, uses invalid border type, %d.  Valid type range: %d - %d", nwd.name, nwd.BorderType, nwd.Game, nwd.noBorder)));
				// intentional fall-through here
			case nwd.noBorder:
				break;
		}	
	}
	
	/*
		Text Drawer
	
	*/
	ui void WindowProcess_Text(ZSWindow nwd)
	{
		nwd.zHandler.WindowClip(nwd);
		BrokenLines blText;
		
		float nwdX, nwdY, xdis, ydis;
		[nwdX, nwdY] = realWindowLocation(nwd);
		
		int realWidth, realHeight;
		[realWidth, realHeight] = realWindowScale(nwd);
		
		// Title
		int wrapWidth = 0;
		if (nwd.Title.Show)
		{			
			/*switch(nwd.Title.ScaleType)
			{
				case ZControl_Base.scalex:
					[nwdX, ydis] = realControlScaledLocation(nwd);
					[xdis, nwdY] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaley:
					[xdis, nwdY] = realControlScaledLocation(nwd);
					[nwdX, ydis] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaleboth:
					[nwdX, nwdY] = realControlScaledLocation(nwd);
					break;
				default:
					[nwdX, nwdY] = realWindowLocation(nwd);
					break;
			}*/
	
			if (nwd.Title.WrapWidth > 0)
				wrapWidth = nwd.Title.WrapWidth;
			else if (nwd.Title.ShapeWidth != "") // be nice to have a string.empty equivalent in zscript
			{
				ZShape shpref = nwd.FindShape(nwd.Title.ShapeWidth);
				if (shpref)
					wrapWidth = shpref.x_End - shpref.x_Start;
			}
			
			switch (nwd.Title.TextWrap)
			{
				case ZText.wrap:
					if (wrapWidth == 0)
						wrapWidth = nwd.Width - nwd.Title.xLocation;
					blText = nwd.Title.font.BreakLines(nwd.Title.Text, wrapWidth);
					for (int i = 0; i < blText.Count(); i++)
						Screen.DrawText(nwd.Title.font,
									nwd.Title.CRColor,
									nwd.Title.GetAlignment(nwdX, wrapWidth, blText.StringAt(i)),
									nwdY + nwd.Title.yLocation + (i * nwd.Title.font.GetHeight()),
									blText.StringAt(i),
									DTA_Alpha, nwd.GlobalEnabled ? nwd.Title.Enabled ? nwd.Title.Alpha : 0.5 : nwd.GlobalAlpha);
					break;
				case ZText.dynwrap:
					if (wrapWidth == 0)
						wrapWidth = realWidth - nwd.Title.xLocation;
					blText = nwd.Title.font.BreakLines(nwd.Title.Text, wrapWidth /* + resize handlers*/);
					for (int i = 0; i < blText.Count(); i++)
						Screen.DrawText(nwd.Title.font,
									nwd.Title.CRColor,
									nwd.Title.GetAlignment(nwdX, wrapWidth, blText.StringAt(i)),
									nwdY + nwd.Title.yLocation + (i * nwd.Title.font.GetHeight()),
									blText.StringAt(i),
									DTA_Alpha, nwd.GlobalEnabled ? nwd.Title.Enabled ? nwd.Title.Alpha : 0.5 : nwd.GlobalAlpha);
					break;
				default:
					Screen.DrawText(nwd.Title.font, 
								nwd.Title.CRColor, 
								nwd.Title.GetAlignment(nwdX, realWidth, nwd.Title.Text), 
								nwdY + nwd.Title.yLocation, 
								nwd.Title.Text, 
								DTA_Alpha, nwd.GlobalEnabled ? nwd.Title.Enabled ? nwd.Title.Alpha : 0.5 : nwd.GlobalAlpha);
					break;
			}
		}
		
		// Window Text Array
		for (int i = 0; i < nwd.GetTextSize(); i++)
		{
			switch(nwd.GetText(i).ScaleType)
			{
				case ZControl_Base.scalex:
					[nwdX, ydis] = realControlScaledLocation(nwd);
					[xdis, nwdY] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaley:
					[xdis, nwdY] = realControlScaledLocation(nwd);
					[nwdX, ydis] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaleboth:
					[nwdX, nwdY] = realControlScaledLocation(nwd);
					break;
				default:
					[nwdX, nwdY] = realWindowLocation(nwd);
					break;
			}
			
			if (nwd.GetText(i).Show)
			{
				wrapWidth = 0;
				if (nwd.GetText(i).WrapWidth > 0)
					wrapWidth = nwd.GetText(i).WrapWidth;
				else if (nwd.GetText(i).ShapeWidth != "") // be nice to have a string.empty equivalent in zscript
				{
					ZShape shpref = nwd.FindShape(nwd.GetText(i).ShapeWidth);
					if (shpref)
						wrapWidth = shpref.x_End - shpref.x_Start;
					// This EventHandler call appears to be causing the ZScript VSCode Extension to choke.
					// Since this is just debugging code it's perfectly safe to comment it out if working in VSCode with the ZScript Extension
					// - There is another line in the ZHandler RenderOverlay method which causes the same issue.
					else
						EventHandler.SendNetworkEvent(string.Format("zswin_debugOut:%s:%s", "txtProcess", string.Format("ERROR! - ZText, %s, references an unknown ZShape, %s!", nwd.GetText(i).Name, nwd.GetText(i).ShapeWidth)));
				}
					
				switch (nwd.GetText(i).TextWrap)
				{
					case ZText.wrap:
						if (wrapWidth == 0)
							wrapWidth = nwd.Width - nwd.GetText(i).xLocation;
						blText = nwd.GetText(i).font.BreakLines(nwd.GetText(i).Text, wrapWidth);
						for (int j = 0; j < blText.Count(); j++)
							Screen.DrawText(nwd.GetText(i).font,
										nwd.GetText(i).CRColor,
										nwd.GetText(i).GetAlignment(nwdX, wrapWidth, blText.StringAt(i)),
										nwdY + nwd.GetText(i).yLocation + (j * nwd.Title.font.GetHeight()),
										blText.StringAt(j),
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetText(i).Enabled ? nwd.GetText(i).Alpha : 0.5 : nwd.GlobalAlpha);
						break;
					case ZText.dynwrap:
						if (wrapWidth == 0)
							wrapWidth = realWidth - nwd.GetText(i).xLocation;
						blText = nwd.GetText(i).font.BreakLines(nwd.GetText(i).Text, wrapWidth /* + resize handlers*/);
						for (int j = 0; j < blText.Count(); j++)
							Screen.DrawText(nwd.GetText(i).font,
										nwd.GetText(i).CRColor,
										nwd.GetText(i).GetAlignment(nwdX, wrapWidth, blText.StringAt(i)),
										nwdY + nwd.GetText(i).yLocation + (j * nwd.Title.font.GetHeight()),
										blText.StringAt(j),
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetText(i).Enabled ? nwd.GetText(i).Alpha : 0.5 : nwd.GlobalAlpha);
						break;
					default:
						Screen.DrawText(nwd.GetText(i).font, 
									nwd.GetText(i).CRColor, 
									nwd.GetText(i).GetAlignment(nwdX, realWidth, nwd.Title.Text), 
									nwdY + nwd.GetText(i).yLocation, 
									nwd.GetText(i).Text, 
									DTA_Alpha, nwd.GlobalEnabled ? nwd.GetText(i).Enabled ? nwd.GetText(i).Alpha : 0.5 : nwd.GlobalAlpha);
						break;
				}
			}
		}
		nwd.zHandler.WindowClip(set:false);
	}
	
	/*
		This method draws the contents of ZShape classes
	
	*/
	ui void WindowProcess_Shapes(ZSWindow nwd)
	{
		int originx, originy,
			cxstart, cystart, 
			cxend, cyend, 
			ang;
			
		float nwdX, nwdY, xdis, ydis;	
		[nwdX, nwdY] = realWindowLocation(nwd);
		
		// This is pointless since lines aren't effected by SetClipRect - hopefully someday they will
		nwd.zHandler.WindowClip(nwd);
		for (int i = 0; i < nwd.GetShapeSize(); i++)
		{	
			switch(nwd.GetShape(i).ScaleType)
			{
				case ZControl_Base.scalex:
					[nwdX, ydis] = realControlScaledLocation(nwd);
					[xdis, nwdY] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaley:
					[xdis, nwdY] = realControlScaledLocation(nwd);
					[nwdX, ydis] = realWindowLocation(nwd);
					break;
				case ZControl_Base.scaleboth:
					[nwdX, nwdY] = realControlScaledLocation(nwd);
					break;
				default:
					[nwdX, nwdY] = realWindowLocation(nwd);
					break;
			}
	
			if (nwd.GetShape(i).Show)
			{
				switch (nwd.GetShape(i).Type)
				{
					//
					// Thin Line
					//
					case ZShape.thinline:
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start, 
										nwdY + nwd.GetShape(i).y_Start, 
										nwdX + nwd.GetShape(i).x_End, 
										nwdY + nwd.GetShape(i).y_End, 
										nwd.GetShape(i).Color, 
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						break;
					//
					// Thick Line
					//
					case ZShape.thickline:
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start, 
											nwdY + nwd.GetShape(i).y_Start, 
											nwdX + nwd.GetShape(i).x_End, 
											nwdY + nwd.GetShape(i).y_End, 
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color, 
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						break;
					//
					// Thin Box
					//
					case ZShape.box:
						// Top
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start - 1,
										nwdY + nwd.GetShape(i).y_Start - 1,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start - 1,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start - 1,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						break;
					//
					// Thick Box
					//
					case ZShape.thickbox:
						// Top
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_Start,
										(nwdX + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_Start,
										(nwdX + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						break;
					//
					// Thin Round Box
					//
					case ZShape.roundbox:
						// Top
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_Start,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
										
						ang = 90 / nwd.GetShape(i).Vertices;
						// Upper Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start;
						cystart = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
							cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;
						}
						
						// Upper Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_Start;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_End;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End;
						cystart = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
							cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}					
						break;
					//
					// Thick Round Box
					//
					case ZShape.roundthickbox:
						// Top
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_Start,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
										
						ang = 90 / nwd.GetShape(i).Vertices;
						// Upper Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius; 
						originy = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start;
						cystart = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
							cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;
						}
						
						// Upper Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_Start;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_End;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End;
						cystart = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
							cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						break;
					//
					// Thin Groupbox
					//
					case ZShape.thingroupbox:
						// Top split line
						if (nwd.GetShape(i).GroupTitle)
						{
							// Left side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start - 1,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											nwdY + nwd.GetShape(i).y_Start);
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start - 1,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
							// Text
							int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
							nwd.zHandler.WindowClip(nwd);
							Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
								nwd.GetShape(i).GroupTitle.CRColor,
								nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
								nwdY + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
								nwd.GetShape(i).GroupTitle.Text,
								DTA_Alpha, nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).GroupTitle.Enabled ? nwd.GetShape(i).GroupTitle.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha);
							nwd.zHandler.WindowClip(set:false);
							// Right side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwdX + nwd.GetShape(i).x_End,
											nwdY + nwd.GetShape(i).y_Start);
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwdX + nwd.GetShape(i).x_End,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwd.GetShape(i).color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
						}
						// Normal line if the text isn't found
						else
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start - 1,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwdX + nwd.GetShape(i).x_End,
											nwdY + nwd.GetShape(i).y_Start - 1,
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start - 1,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));					
						break;
					//
					// Thick Groupbox
					//
					case ZShape.thickgroupbox:
						// Top split line
						if (nwd.GetShape(i).GroupTitle)
						{
							// Left side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start - 1,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											(nwdY + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
							Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
							// Text
							int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
							nwd.zHandler.WindowClip(nwd);
							Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
								nwd.GetShape(i).GroupTitle.CRColor,
								nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
								nwdY + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
								nwd.GetShape(i).GroupTitle.Text,
								DTA_Alpha, nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).GroupTitle.Enabled ? nwd.GetShape(i).GroupTitle.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha);
							nwd.zHandler.WindowClip(set:false);
							// Right side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).x_End,
											(nwdY + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
							Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
						}
						// Normal line if the text isn't found
						else
							Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
										(nwdY + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_Start,
										(nwdX + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_Start,
										(nwdX + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						break;
					//
					// Thin Round Groupbox
					//
					case ZShape.thinroundgroupbox:
						// Top split line
						if (nwd.GetShape(i).GroupTitle)
						{
							// Left side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start,
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											nwdY + nwd.GetShape(i).y_Start);
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start,
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											nwdY + nwd.GetShape(i).y_Start,
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
							// Text
							int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
							nwd.zHandler.WindowClip(nwd);
							Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
								nwd.GetShape(i).GroupTitle.CRColor,
								nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation,
								nwdY + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2),
								nwd.GetShape(i).GroupTitle.Text,
								DTA_Alpha, nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).GroupTitle.Enabled ? nwd.GetShape(i).GroupTitle.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha);
							nwd.zHandler.WindowClip(set:false);
							// Right side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth,
											nwdY + nwd.GetShape(i).y_Start,
											nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start);
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth,
											nwdY + nwd.GetShape(i).y_Start,
											nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start,
											nwd.GetShape(i).color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
						}
						// Normal line if the text isn't found
						else
							Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start,
											nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
											nwdY + nwd.GetShape(i).y_Start,
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
										
						ang = 90 / nwd.GetShape(i).Vertices;
						// Upper Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start;
						cystart = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
							cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;
						}
						
						// Upper Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_Start;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_End;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End;
						cystart = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
							cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						break;
					//
					// Thick Round Groupbox
					//
					case ZShape.thickroundgroupbox:
						// Top split line
						if (nwd.GetShape(i).GroupTitle)
						{
							// Left side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											(nwdY + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
							Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius) - nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).GroupTitle.xLocation - 3,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
							// Text
							int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
							nwd.zHandler.WindowClip(nwd);
							Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
								nwd.GetShape(i).GroupTitle.CRColor,
								nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
								nwdY + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
								nwd.GetShape(i).GroupTitle.Text,
								DTA_Alpha, nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).GroupTitle.Enabled ? nwd.GetShape(i).GroupTitle.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha);
							nwd.zHandler.WindowClip(set:false);
							// Right side
							Screen.SetClipRect(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
											(nwdY + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
							Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness - nwd.GetShape(i).Radius,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							Screen.ClearClipRect();
						}
						// Normal line if the text isn't found
						else
							Screen.DrawThickLine((nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius) - nwd.GetShape(i).Thickness,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											(nwdX + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness - nwd.GetShape(i).Radius,
											(nwdY + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
											nwd.GetShape(i).Thickness, 
											nwd.GetShape(i).Color,
											int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Bottom
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwdY + nwd.GetShape(i).y_End,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Left
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_Start,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
						// Right
						Screen.DrawThickLine(nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
										nwdX + nwd.GetShape(i).x_End,
										nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
										nwd.GetShape(i).Thickness,
										nwd.GetShape(i).Color,
										int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
										
						ang = 90 / nwd.GetShape(i).Vertices;
						// Upper Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius; 
						originy = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start;
						cystart = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
							cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;
						}
						
						// Upper Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_Start;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Left
						originx = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cystart = nwdY + nwd.GetShape(i).y_End;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
							cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cyend = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						// Lower Right
						originx = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						originy = nwdY + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
						cxstart = nwdX + nwd.GetShape(i).x_End;
						cystart = nwdY + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
						{
							cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
							if (j == nwd.GetShape(i).Vertices - 1)
								cxend = nwdX + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
							cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
							Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int((nwd.GlobalEnabled ? nwd.GetShape(i).Enabled ? nwd.GetShape(i).Alpha : 0.5 : nwd.GlobalAlpha) * 255));
							cxstart = cxend;
							cystart = cyend;					
						}
						break;
				}
			}
		}
		nwd.zHandler.WindowClip(set:false);
	}
	
	/*
		Draws the window's buttons.
		
		! Known bugs - ZButton middle textures do not clip property at the momement.
	
	*/
	ui void WindowProcess_Buttons(ZSWindow nwd)
	{
		// This does a lot of the math for locating the control
		// based on its ScaleType
		float nwdX, nwdY, xdis, ydis;
		int realWidth, realHeight;
		// What is the real width and height of the window?
		// Any usage of the window's width/height needs the real width/height
		[realWidth, realHeight] = realWindowScale(nwd);		
		
		for (int i = 0; i < nwd.Buttons.Size(); i++)
		{
			if (nwd.GetButton(i).Show)
			{
				switch(nwd.GetButton(i).ScaleType)
				{
					case ZControl_Base.scalex:
						// X Location is scaled
						[nwdX, ydis] = realControlScaledLocation(nwd);
						// Y Location just moves
						[xdis, nwdY] = realWindowLocation(nwd);
						break;
					case ZControl_Base.scaley:
						// Y Location is scaled
						[xdis, nwdY] = realControlScaledLocation(nwd);
						// X Location just moves
						[nwdX, ydis] = realWindowLocation(nwd);
						break;
					case ZControl_Base.scaleboth:
						// This control can move and be scaled on both axis
						[nwdX, nwdY] = realControlScaledLocation(nwd);
						break;
					default:
						// This control just moves - they can always move.
						[nwdX, nwdY] = realWindowLocation(nwd);
						break;
				}
				
				int clipx, clipy, 
					wdth, hght;
				bool cliplft = false, 
					cliprht = false, 
					cliptop = false, 
					clipbot = false;
					
				float rlx, rly;
				[rlx, rly] = realWindowLocation(nwd);
				if (rlx > nwdX + nwd.GetButton(i).xLocation)
				{
					clipx = rlx;
					cliplft = true;
				}
				else
					clipx = nwdX + nwd.GetButton(i).xLocation;
				
				if (rly > nwdY + nwd.GetButton(i).yLocation)
				{
					clipy = rly;
					cliptop = true;
				}
				else
					clipy = nwdY + nwd.GetButton(i).yLocation;
				
				if (rlx + realWidth < nwdX + nwd.GetButton(i).xLocation)
					wdth = 0;
				else if (rlx + realWidth < nwdX + nwd.GetButton(i).xLocation + nwd.GetButton(i).Width)
				{
					wdth = (rlx + realWidth) - (nwdX + nwd.GetButton(i).xLocation);
					cliprht = true;
				}
				else
					wdth = nwd.GetButton(i).Width;
				
				if (rly + realHeight < nwdY + nwd.GetButton(i).yLocation)
					hght = 0;
				else if (rly + realHeight < nwdY + nwd.GetButton(i).yLocation + nwd.GetButton(i).Height)
				{
					hght = (rly + realHeight) - (nwdY + nwd.GetButton(i).yLocation);
					clipbot = true;
				}
				else
					hght = nwd.GetButton(i).Height;

				switch (nwd.GetButton(i).Type)
				{
					case ZButton.standard:
						// Background
						if (nwd.GetButton(i).Stretch)
						{
							// WindowClip takes into account both moving and scaling of the window
							nwd.zHandler.WindowClip(nwd);
							screen.DrawTexture(nwd.GetButton(i).btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.GetButton(i).btnTextures[0].dar_TextureSet[nwd.GetButton(i).State].txtId : nwd.GetButton(i).btnTextures[0].dar_TextureSet[0].txtId,
											false, 
											nwdX + nwd.GetButton(i).xLocation, 
											nwdY + nwd.GetButton(i).yLocation,
											DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
											DTA_DestWidth, nwd.GetButton(i).Width,
											DTA_DestHeight, nwd.GetButton(i).Height);
							// Clear the clipping boundary
							nwd.zHandler.WindowClip(set:false);
						}
						else
						{							
							int tx, ty, w = 0;
							Vector2 txy = TexMan.GetScaledSize(nwd.GetButton(i).btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.GetButton(i).btnTextures[0].dar_TextureSet[nwd.GetButton(i).State].txtId : nwd.GetButton(i).btnTextures[0].dar_TextureSet[0].txtId);
							tx = txy.x;
							ty = txy.y;
							Screen.SetClipRect(clipx, clipy, wdth, hght);
							do
							{
								int h = 0;
								do
								{
									Screen.DrawTexture (nwd.GetButton(i).btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.GetButton(i).btnTextures[0].dar_TextureSet[nwd.GetButton(i).State].txtId : nwd.GetButton(i).btnTextures[0].dar_TextureSet[0].txtId, 
										false,
										nwdX + nwd.GetButton(i).xLocation + (tx * w),
										nwdY + nwd.GetButton(i).yLocation + (ty * h),
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
										DTA_DestWidth, tx,
										DTA_DestHeight, ty);
									h++;
								} while ((((h - 1) * ty) + ty) < nwd.GetButton(i).Height);
								w++;
							} while ((((w - 1) * tx) + tx) <= nwd.GetButton(i).Width);
							nwd.zHandler.WindowClip(set:false);
						}
						// Border
						// Code enforces box and thickbox types
						switch (nwd.GetButton(i).Border.Type)
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
									Screen.DrawThickLine(clipx - (!cliplft ? nwd.GetButton(i).Border.Thickness : 0), 
														clipy - (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : ((nwd.GetButton(i).Border.Thickness - 1) / 2) + 1) : nwd.GetButton(i).Border.Thickness), 
														clipx + wdth + (!cliprht ? nwd.GetButton(i).Border.Thickness : 0), 
														clipy - (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : ((nwd.GetButton(i).Border.Thickness - 1) / 2) + 1) : nwd.GetButton(i).Border.Thickness),
														nwd.GetButton(i).Border.Thickness,
														nwd.GetButton(i).Border.Color,
														int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
								if (!clipbot)
									Screen.DrawThickLine(clipx - (!cliplft ? nwd.GetButton(i).Border.Thickness : 0), 
														clipy + hght + (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : (nwd.GetButton(i).Border.Thickness - 1) / 2) : nwd.GetButton(i).Border.Thickness), 
														clipx + wdth + (!cliprht ? nwd.GetButton(i).Border.Thickness : 0), 
														clipy + hght + (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : (nwd.GetButton(i).Border.Thickness - 1) / 2) : nwd.GetButton(i).Border.Thickness),
														nwd.GetButton(i).Border.Thickness,
														nwd.GetButton(i).Border.Color,
														int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
								if (!cliplft)
									Screen.DrawThickLine(clipx - (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : (nwd.GetButton(i).Border.Thickness - 1) / 2) : nwd.GetButton(i).Border.Thickness),
														clipy,
														clipx - (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : (nwd.GetButton(i).Border.Thickness - 1) / 2) : nwd.GetButton(i).Border.Thickness),
														clipy + hght,
														nwd.GetButton(i).Border.Thickness,
														nwd.GetButton(i).Border.Color,
														int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
								if (!cliprht)
									Screen.DrawThickLine(clipx + wdth + (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : ((nwd.GetButton(i).Border.Thickness - 1) / 2) + 1) : nwd.GetButton(i).Border.Thickness),
														clipy,
														clipx + wdth + (nwd.GetButton(i).Border.Thickness > 1 ? (nwd.GetButton(i).Border.Thickness % 2 == 0 ? nwd.GetButton(i).Border.Thickness / 2 : ((nwd.GetButton(i).Border.Thickness - 1) / 2) + 1) : nwd.GetButton(i).Border.Thickness),
														clipy + hght,
														nwd.GetButton(i).Border.Thickness,
														nwd.GetButton(i).Border.Color,
														int(255 * (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Border.Enabled ? nwd.GetButton(i).Border.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha)));
								break;
							default:
								// need a debug message here - invalid border type for button
							case ZShape.noshape:
								break;
						}
						break;
					case ZButton.radio:
					case ZButton.check:
						nwd.zHandler.WindowClip(nwd);
						screen.SetClipRect(clipx, clipy, wdth, hght);
						screen.DrawTexture(nwd.GetButton(i).btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.GetButton(i).btnTextures[0].dar_TextureSet[nwd.GetButton(i).State].txtId : nwd.GetButton(i).btnTextures[0].dar_TextureSet[0].txtId,
										false, 
										nwdX + nwd.GetButton(i).xLocation, 
										nwdY + nwd.GetButton(i).yLocation,
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
										DTA_DestWidth, nwd.GetButton(i).Width,
										DTA_DestHeight, nwd.GetButton(i).Height);
						nwd.zHandler.WindowClip(set:false); // this is the same as calling screen.ClearClipRect()
						break;
					case ZButton.zbtn:
						TextureId leftSide, middle, rightSide;
						// Do we have more at least one TextureSet?
						if (nwd.GetButton(i).btnTextures.Size() > 0)
						{
							// We do, so check if there's 3 sets with exactly 3 textures each
							if (nwd.GetButton(i).btnTextures.Size() == 3 &&
								nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet.Size() == 3)
							{
								leftSide = nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet[0].txtId;
								middle = nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet[1].txtId;
								rightSide = nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet[2].txtId;
							}
							// There's not, so check if there's 3 sets with at least one texure each
							else if (nwd.GetButton(i).btnTextures.Size() == 3 &&
									nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet.Size() > 0)
								leftSide = middle = rightSide = nwd.GetButton(i).btnTextures[nwd.GetButton(i).State].dar_TextureSet[0].txtId;
							// Ok, theres at least one texture set, so check it has something in it and use it!
							else if (nwd.GetButton(i).btnTextures[0].dar_TextureSet.Size() > 0)
								leftSide = middle = rightSide = nwd.GetButton(i).btnTextures[0].dar_TextureSet[0].txtId;
							// Something is really wrong, just stop.
							else
								break;
						}
						// The button doesn't have any textures?! WHAAAT?!
						else
							break;
						
						// Left and right sides are drawn, then the clipping boundary is ammended for the tiled middle
						screen.SetClipRect(clipx, clipy, wdth, hght);
						int lx, ly, rx, ry;
						Vector2 lxy = TexMan.GetScaledSize(leftSide);
						lx = lxy.x;
						ly = lxy.y;
						screen.DrawTexture(leftSide,
										false, 
										nwdX + nwd.GetButton(i).xLocation, 
										nwdY + nwd.GetButton(i).yLocation,
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
										DTA_DestWidth, lx,
										DTA_DestHeight, ly);	
						Vector2 rxy = TexMan.GetScaledSize(rightSide);
						rx = rxy.x;
						ry = rxy.y;	
						screen.DrawTexture(rightSide,
										false, 
										nwdX + nwd.GetButton(i).xLocation + nwd.GetButton(i).Width - rx, 
										nwdY + nwd.GetButton(i).yLocation,
										DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
										DTA_DestWidth, rx,
										DTA_DestHeight, ry);										
						nwd.zHandler.WindowClip(set:false);
							
						int midclipx, midwdth;
						if (clipx > nwdX + nwd.GetButton(i).xLocation + lx)
							midclipx = clipx;
						else
							midclipx = nwdX + nwd.GetButton(i).xLocation + lx;
						
						if (clipx + wdth < nwdX + nwd.GetButton(i).xLocation + lx)
							midwdth = 0;
						else if (clipx + wdth < nwdX + nwd.GetButton(i).xLocation + nwd.GetButton(i).Width - rx)
							midwdth = nwd.GetButton(i).Width - lx - ((nwdX + nwd.GetButton(i).xLocation + nwd.GetButton(i).Width) - (clipx + wdth));
						else
							midwdth = nwd.GetButton(i).Width - lx - rx;
						
						int mx, my;
						Vector2 mxy = TexMan.GetScaledSize(middle);
						mx = mxy.x;
						my = mxy.y;
						screen.SetClipRect(midclipx, clipy, midwdth, hght);
						int w = 0;
						// No height loop because the height is the height of the textures
						do
						{
							Screen.DrawTexture (middle, 
								false,
								nwdX + nwd.GetButton(i).xLocation + lx + (mx * w),
								nwdY + nwd.GetButton(i).yLocation,
								DTA_Alpha, nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Alpha : 0.5 : nwd.GlobalAlpha,
								DTA_DestWidth, mx,
								DTA_DestHeight, my);
							w++;
						} while ((((w - 1) * mx) + mx) <= midwdth);
						nwd.zHandler.WindowClip(set:false);
						break;
				}
				// Text
				BrokenLines blText;
				int wrapWidth = 0;
				if (nwd.GetButton(i).Text.WrapWidth > 0)
					wrapWidth = nwd.GetButton(i).Text.WrapWidth;
				else
					wrapWidth = nwd.GetButton(i).Width - nwd.GetButton(i).Text.xLocation;
				screen.SetClipRect(clipx, clipy, wdth, hght);
				switch (nwd.GetButton(i).Text.TextWrap)
				{
					case ZText.wrap:
						blText = nwd.GetButton(i).Text.font.BreakLines(nwd.GetButton(i).Text.Text, wrapWidth);
						for (int j = 0; j < blText.Count(); j++)
							Screen.DrawText(nwd.GetButton(i).Text.font,
										nwd.GetButton(i).Text.CRColor,
										nwd.GetButton(i).Text.GetAlignment(nwdX + nwd.GetButton(i).xLocation, wrapWidth, blText.StringAt(j)),
										nwdY + nwd.GetButton(i).yLocation + nwd.GetButton(i).Text.yLocation + (j * nwd.GetButton(i).Text.font.GetHeight()),
										blText.StringAt(j),
										DTA_Alpha, (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Text.Enabled ? nwd.GetButton(i).Text.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha));
						break;
					case ZText.dynwrap:
						blText = nwd.GetButton(i).Text.font.BreakLines(nwd.GetButton(i).Text.Text, wrapWidth /* + resize handlers*/);
						for (int j = 0; j < blText.Count(); j++)
							Screen.DrawText(nwd.GetButton(i).Text.font,
										nwd.GetButton(i).Text.CRColor,
										nwd.GetButton(i).Text.GetAlignment(nwdX + nwd.GetButton(i).xLocation, wrapWidth, blText.StringAt(j)),
										nwdY + nwd.GetButton(i).yLocation + nwd.GetButton(i).Text.yLocation + (j * nwd.GetButton(i).Text.font.GetHeight()),
										blText.StringAt(j),
										DTA_Alpha, (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Text.Enabled ? nwd.GetButton(i).Text.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha));
						break;
					default:
						Screen.DrawText(nwd.GetButton(i).Text.font, 
									nwd.GetButton(i).Text.CRColor, 
									nwd.GetButton(i).Text.GetAlignment(nwdX + nwd.GetButton(i).xLocation, realWidth, nwd.GetButton(i).Text.Text), 
									nwdY + nwd.GetButton(i).yLocation + nwd.GetButton(i).Text.yLocation, 
									nwd.GetButton(i).Text.Text, 
									DTA_Alpha, (nwd.GlobalEnabled ? nwd.GetButton(i).Enabled ? nwd.GetButton(i).Text.Enabled ? nwd.GetButton(i).Text.Alpha : 0.5 : 0.5 : nwd.GlobalAlpha));
						break;
				}
				nwd.zHandler.WindowClip(set:false);
			}
		}
	}
	
	ui void WindowProcess_Graphics(ZSWindow nwd)
	{
		nwd.zHandler.WindowClip(nwd);
		nwd.zHandler.WindowClip(set:false);
	}
}