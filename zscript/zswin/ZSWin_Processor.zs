/*
	ZSWin_Processor.txt
	
	- Nothing for users here, this class
	  contains the methods for drawing
	  windows.

*/

class zsys
{
	ui static void WindowProcess_Background(ZSWindow nwd)
	{
		if (nwd.BackgroundTexture.IsValid())
		{
			if (nwd.Stretch)
				Screen.DrawTexture(nwd.BackgroundTexture, false,
					nwd.xLocation, nwd.yLocation,
					DTA_Alpha, nwd.BackgroundAlpha,
					DTA_DestWidth, nwd.Width,
					DTA_DestHeight, nwd.Height);
			else
			{
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
							nwd.xLocation + (tx * w),
							nwd.yLocation + (ty * h),
							DTA_Alpha, nwd.BackgroundAlpha,
							DTA_DestWidth, tx,
							DTA_DestHeight, ty);
						h++;
					} while ((((h - 1) * ty) + ty)  < nwd.Height);
					w++;
				} while ((((w -1) * tx) + tx) <= nwd.Width);
				nwd.zHandler.WindowClip(set:false);
			}
		}
	}
	
	ui static void WindowProcess_Border(ZSWindow nwd)
	{
		switch (nwd.BorderType)
		{
			case nwd.Game:
				Screen.DrawFrame(nwd.xLocation, nwd.yLocation, nwd.Width, nwd.Height);
				break;
			case nwd.Line:
				Screen.DrawLine(nwd.xLocation, nwd.yLocation, nwd.xLocation + nwd.Width, nwd.yLocation, nwd.BorderColor, int(255 * nwd.BorderAlpha));
				Screen.DrawLine(nwd.xLocation, nwd.yLocation + nwd.Height, nwd.xLocation + nwd.Width, nwd.yLocation + nwd.Height, nwd.BorderColor, int(255 * nwd.BorderAlpha));
				Screen.DrawLine(nwd.xLocation, nwd.yLocation, nwd.xLocation, nwd.yLocation + nwd.Height, nwd.BorderColor, int(255 * nwd.BorderAlpha));
				Screen.DrawLine(nwd.xLocation + nwd.Width, nwd.yLocation, nwd.xLocation + nwd.Width, nwd.yLocation + nwd.Height, nwd.BorderColor, int(255 * nwd.BorderAlpha));
				break;
			case nwd.ThickLine:
				// Top
				Screen.DrawThickLine(nwd.xLocation - nwd.BorderThickness, 
									nwd.yLocation - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwd.xLocation + nwd.Width + nwd.BorderThickness, 
									nwd.yLocation - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * nwd.BorderAlpha));
				// Bottom
				Screen.DrawThickLine(nwd.xLocation - nwd.BorderThickness, 
									nwd.yLocation + nwd.Height + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwd.xLocation + nwd.Width + nwd.BorderThickness, 
									nwd.yLocation + nwd.Height + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * nwd.BorderAlpha));
				// Left
				Screen.DrawThickLine(nwd.xLocation - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwd.yLocation, 
									nwd.xLocation - (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : (nwd.BorderThickness - 1) / 2) : nwd.BorderThickness), 
									nwd.yLocation + nwd.Height, 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * nwd.BorderAlpha));
				// Right
				Screen.DrawThickLine(nwd.xLocation + nwd.Width + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwd.yLocation, 
									nwd.xLocation + nwd.Width + (nwd.BorderThickness > 1 ? (nwd.BorderThickness % 2 == 0 ? nwd.BorderThickness / 2 : ((nwd.BorderThickness - 1) / 2) + 1) : nwd.BorderThickness), 
									nwd.yLocation + nwd.Height, 
									nwd.BorderThickness, 
									nwd.BorderColor, 
									int(255 * nwd.BorderAlpha));
				break;
			case nwd.ZWin_Border:
				// Top Left Corner
				Screen.DrawTexture(nwd.gfxBorder.Corner_TopLeft, false,
					nwd.xLocation - nwd.gfxBorder.BorderWidth, 
					nwd.yLocation - nwd.gfxBorder.BorderHeight,
					DTA_Alpha, nwd.BorderAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Top Right Corner	
				Screen.DrawTexture(nwd.gfxBorder.Corner_TopRight, false,
					nwd.xLocation + nwd.Width, 
					nwd.yLocation - nwd.gfxBorder.BorderHeight,
					DTA_Alpha, nwd.BorderAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Bottom Left Corner
				Screen.DrawTexture(nwd.gfxBorder.Corner_BottomLeft, false,
					nwd.xLocation - nwd.gfxBorder.BorderWidth, 
					nwd.yLocation + nwd.Height,
					DTA_Alpha, nwd.BorderAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				// Bottom Right Corner	
				Screen.DrawTexture(nwd.gfxBorder.Corner_BottomRight, false,
					nwd.xLocation + nwd.Width, 
					nwd.yLocation + nwd.Height,
					DTA_Alpha, nwd.BorderAlpha,
					DTA_DestWidth, nwd.gfxBorder.BorderWidth,
					DTA_DestHeight, nwd.gfxBorder.BorderHeight);
				
				Screen.SetClipRect(nwd.xLocation,
								nwd.yLocation - nwd.gfxBorder.BorderHeight,
								nwd.Width,
								nwd.Height + (nwd.gfxBorder.BorderHeight * 2));				
				int w = 0;
				do
				{
					Screen.DrawTexture(nwd.gfxBorder.Side_Top, false,
									nwd.xLocation + (nwd.gfxBorder.BorderWidth * w),
									nwd.yLocation - nwd.gfxBorder.BorderHeight,
									DTA_Alpha, nwd.BorderAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					Screen.DrawTexture(nwd.gfxBorder.Side_Bottom, false,
									nwd.xLocation + (nwd.gfxBorder.BorderWidth * w),
									nwd.yLocation + nwd.Height,
									DTA_Alpha, nwd.BorderAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					w++;
				} while (((w - 1) * nwd.gfxBorder.BorderWidth) + nwd.gfxBorder.BorderWidth <= nwd.Width);
				nwd.zHandler.WindowClip(set:false);
				
				Screen.SetClipRect(nwd.xLocation - nwd.gfxBorder.BorderWidth,
								nwd.yLocation,
								nwd.Width + (nwd.gfxBorder.BorderWidth * 2),
								nwd.Height);
				int h = 0;
				do
				{
					Screen.DrawTexture(nwd.gfxBorder.Side_Left, false,
									nwd.xLocation - nwd.gfxBorder.BorderWidth,
									nwd.yLocation + (nwd.gfxBorder.BorderHeight * h),
									DTA_Alpha, nwd.BorderAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					Screen.DrawTexture(nwd.gfxBorder.Side_Right, false,
									nwd.xLocation + nwd.Width,
									nwd.yLocation + (nwd.gfxBorder.BorderHeight * h),
									DTA_Alpha, nwd.BorderAlpha,
									DTA_DestWidth, nwd.gfxBorder.BorderWidth,
									DTA_DestHeight, nwd.gfxBorder.BorderHeight);
					h++;
				} while (((h - 1) * nwd.gfxBorder.BorderHeight) + nwd.gfxBorder.BorderHeight <= nwd.Height);
				nwd.zHandler.WindowClip(set:false);
				break;
		}	
	}
	
	ui static void WindowProcess_Text(ZSWindow nwd)
	{
		nwd.zHandler.WindowClip(nwd);
		BrokenLines blText;
		// Title
		int wrapWidth = 0;
		if (nwd.Title.WrapWidth > 0)
			wrapWidth = nwd.Title.WrapWidth;
		else if (nwd.Title.ShapeWidth != "") // be nice to have a string.empty equivalent in zscript
		{
			ZShape shpref = nwd.FindShape(nwd.Title.ShapeWidth);
			if (shpref)
				wrapWidth = shpref.x_End - shpref.x_Start;
		}
		else
			wrapWidth = nwd.Width;
		
		switch (nwd.Title.TextWrap)
		{
			case ZText.wrap:
				blText = nwd.Title.font.BreakLines(nwd.Title.Text, wrapWidth);
				for (int i = 0; i < blText.Count(); i++)
					Screen.DrawText(nwd.Title.font,
								nwd.Title.CRColor,
								nwd.Title.GetAlignment(nwd.xLocation, wrapWidth, blText.StringAt(i)),
								nwd.yLocation + nwd.Title.yLocation + (i * nwd.Title.font.GetHeight()),
								blText.StringAt(i),
								DTA_Alpha, nwd.Title.Alpha);
				break;
			case ZText.dynwrap:
				blText = nwd.Title.font.BreakLines(nwd.Title.Text, wrapWidth /* + resize handlers*/);
				for (int i = 0; i < blText.Count(); i++)
					Screen.DrawText(nwd.Title.font,
								nwd.Title.CRColor,
								nwd.Title.GetAlignment(nwd.xLocation, wrapWidth, blText.StringAt(i)),
								nwd.yLocation + nwd.Title.yLocation + (i * nwd.Title.font.GetHeight()),
								blText.StringAt(i),
								DTA_Alpha, nwd.Title.Alpha);
				break;
			default:
				Screen.DrawText(nwd.Title.font, 
							nwd.Title.CRColor, 
							nwd.Title.GetAlignment(nwd.xLocation, nwd.Width, nwd.Title.Text), 
							nwd.yLocation + nwd.Title.yLocation, 
							nwd.Title.Text, 
							DTA_Alpha, nwd.Title.Alpha);
				break;
		}
		
		// Window Text Array
		for (int i = 0; i < nwd.GetTextSize(); i++)
		{
			wrapWidth = 0;
			if (nwd.GetText(i).WrapWidth > 0)
				wrapWidth = nwd.GetText(i).WrapWidth;
			else if (nwd.GetText(i).ShapeWidth != "") // be nice to have a string.empty equivalent in zscript
			{
				ZShape shpref = nwd.FindShape(nwd.GetText(i).ShapeWidth);
				if (shpref)
					wrapWidth = shpref.x_End - shpref.x_Start;
				//else
					//EventHandler.SendNetworkEvent(string.Format("zswin_debugOut:%s:%s", "txtProcess", string.Format("ERROR! - ZText, %s, references an unknown ZShape, %s!", nwd.GetText(i).Name, nwd.GetText(i).ShapeWidth)));
			}
			else
				wrapWidth = nwd.Width;
			switch (nwd.GetText(i).TextWrap)
			{
				case ZText.wrap:
					blText = nwd.GetText(i).font.BreakLines(nwd.GetText(i).Text, wrapWidth);
					for (int j = 0; j < blText.Count(); j++)
						Screen.DrawText(nwd.GetText(i).font,
									nwd.GetText(i).CRColor,
									nwd.GetText(i).GetAlignment(nwd.xLocation, wrapWidth, blText.StringAt(i)),
									nwd.yLocation + nwd.GetText(i).yLocation + (j * nwd.Title.font.GetHeight()),
									blText.StringAt(j),
									DTA_Alpha, nwd.GetText(i).Alpha);
					break;
				case ZText.dynwrap:
					blText = nwd.GetText(i).font.BreakLines(nwd.GetText(i).Text, wrapWidth /* + resize handlers*/);
					for (int j = 0; j < blText.Count(); j++)
						Screen.DrawText(nwd.GetText(i).font,
									nwd.GetText(i).CRColor,
									nwd.GetText(i).GetAlignment(nwd.xLocation, wrapWidth, blText.StringAt(i)),
									nwd.yLocation + nwd.GetText(i).yLocation + (j * nwd.Title.font.GetHeight()),
									blText.StringAt(j),
									DTA_Alpha, nwd.GetText(i).Alpha);
					break;
				default:
					Screen.DrawText(nwd.GetText(i).font, 
								nwd.GetText(i).CRColor, 
								nwd.GetText(i).GetAlignment(nwd.xLocation, nwd.Width, nwd.Title.Text), 
								nwd.yLocation + nwd.GetText(i).yLocation, 
								nwd.GetText(i).Text, 
								DTA_Alpha, nwd.GetText(i).Alpha);
					break;
			}
		}
		nwd.zHandler.WindowClip(set:false);
	}
	
	/*
		This method is a mess of insanity, but Z-Windows was too...the whole thing
	
	*/
	ui static void WindowProcess_Shapes(ZSWindow nwd)
	{
		int originx, originy,
			cxstart, cystart, 
			cxend, cyend, 
			ang;
		
		nwd.zHandler.WindowClip(nwd);
		for (int i = 0; i < nwd.GetShapeSize(); i++)
		{	
			switch (nwd.GetShape(i).Type)
			{
				//
				// Thin Line
				//
				case ZShape.thinline:
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start, 
									nwd.yLocation + nwd.GetShape(i).y_Start, 
									nwd.xLocation + nwd.GetShape(i).x_End, 
									nwd.yLocation + nwd.GetShape(i).y_End, 
									nwd.GetShape(i).Color, 
									int(nwd.GetShape(i).Alpha * 255));
					break;
				//
				// Thick Line
				//
				case ZShape.thickline:
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start, 
										nwd.yLocation + nwd.GetShape(i).y_Start, 
										nwd.xLocation + nwd.GetShape(i).x_End, 
										nwd.yLocation + nwd.GetShape(i).y_End, 
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color, 
										int(nwd.GetShape(i).Alpha * 255));
					break;
				//
				// Thin Box
				//
				case ZShape.box:
					// Top
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
									nwd.yLocation + nwd.GetShape(i).y_Start - 1,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start - 1,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					break;
				//
				// Thick Box
				//
				case ZShape.thickbox:
					// Top
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									nwd.GetShape(i).Thickness, 
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.GetShape(i).Thickness, 
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_Start,
									(nwd.xLocation + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_Start,
									(nwd.xLocation + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					break;
				//
				// Thin Round Box
				//
				case ZShape.roundbox:
					// Top
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
									
					ang = 90 / nwd.GetShape(i).Vertices;
					// Upper Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;
					}
					
					// Upper Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}					
					break;
				//
				// Thick Round Box
				//
				case ZShape.roundthickbox:
					// Top
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
									
					ang = 90 / nwd.GetShape(i).Vertices;
					// Upper Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius; 
					originy = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;
					}
					
					// Upper Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
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
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										nwd.yLocation + nwd.GetShape(i).y_Start);
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
						// Text
						int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
						nwd.zHandler.WindowClip(nwd);
						Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
							nwd.GetShape(i).GroupTitle.CRColor,
							nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
							nwd.yLocation + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
							nwd.GetShape(i).GroupTitle.Text,
							DTA_Alpha, nwd.GetShape(i).GroupTitle.Alpha);
						nwd.zHandler.WindowClip(set:false);
						// Right side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.xLocation + nwd.GetShape(i).x_End,
										nwd.yLocation + nwd.GetShape(i).y_Start);
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.xLocation + nwd.GetShape(i).x_End,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.GetShape(i).color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
					}
					// Normal line if the text isn't found
					else
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.xLocation + nwd.GetShape(i).x_End,
										nwd.yLocation + nwd.GetShape(i).y_Start - 1,
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));					
					break;
				//
				// Thick Groupbox
				//
				case ZShape.thickgroupbox:
					// Top split line
					if (nwd.GetShape(i).GroupTitle)
					{
						// Left side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start - 1,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										(nwd.yLocation + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
						Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
						// Text
						int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
						nwd.zHandler.WindowClip(nwd);
						Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
							nwd.GetShape(i).GroupTitle.CRColor,
							nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
							nwd.yLocation + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
							nwd.GetShape(i).GroupTitle.Text,
							DTA_Alpha, nwd.GetShape(i).GroupTitle.Alpha);
						nwd.zHandler.WindowClip(set:false);
						// Right side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).x_End,
										(nwd.yLocation + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
						Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
					}
					// Normal line if the text isn't found
					else
						Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness,
									(nwd.yLocation + nwd.GetShape(i).y_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.GetShape(i).Thickness, 
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_Start,
									(nwd.xLocation + nwd.GetShape(i).x_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : (nwd.GetShape(i).Thickness - 1) / 2) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_Start,
									(nwd.xLocation + nwd.GetShape(i).x_End) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					break;
				//
				// Thin Round Groupbox
				//
				case ZShape.thinroundgroupbox:
					// Top split line
					if (nwd.GetShape(i).GroupTitle)
					{
						// Left side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										nwd.yLocation + nwd.GetShape(i).y_Start);
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
						// Text
						int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
						nwd.zHandler.WindowClip(nwd);
						Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
							nwd.GetShape(i).GroupTitle.CRColor,
							nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation,
							nwd.yLocation + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2),
							nwd.GetShape(i).GroupTitle.Text,
							DTA_Alpha, nwd.GetShape(i).GroupTitle.Alpha);
						nwd.zHandler.WindowClip(set:false);
						// Right side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start);
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.GetShape(i).color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
					}
					// Normal line if the text isn't found
					else
						Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										nwd.yLocation + nwd.GetShape(i).y_Start,
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
									
					ang = 90 / nwd.GetShape(i).Vertices;
					// Upper Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;
					}
					
					// Upper Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
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
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										(nwd.yLocation + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
						Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius) - nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).GroupTitle.xLocation - 3,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
						// Text
						int txtWidth = nwd.GetShape(i).GroupTitle.font.StringWidth(nwd.GetShape(i).GroupTitle.Text);
						nwd.zHandler.WindowClip(nwd);
						Screen.DrawText(nwd.GetShape(i).GroupTitle.font,
							nwd.GetShape(i).GroupTitle.CRColor,
							nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation - 1,
							nwd.yLocation + nwd.GetShape(i).y_Start - (nwd.GetShape(i).GroupTitle.font.GetHeight() / 2) - 1,
							nwd.GetShape(i).GroupTitle.Text,
							DTA_Alpha, nwd.GetShape(i).GroupTitle.Alpha);
						nwd.zHandler.WindowClip(set:false);
						// Right side
						Screen.SetClipRect(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
										(nwd.yLocation + nwd.GetShape(i).y_Start) + (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness));
						Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).GroupTitle.xLocation + txtWidth - 1,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness - nwd.GetShape(i).Radius,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
						Screen.ClearClipRect();
					}
					// Normal line if the text isn't found
					else
						Screen.DrawThickLine((nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius) - nwd.GetShape(i).Thickness,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										(nwd.xLocation + nwd.GetShape(i).x_End) + nwd.GetShape(i).Thickness - nwd.GetShape(i).Radius,
										(nwd.yLocation + nwd.GetShape(i).y_Start) - (nwd.GetShape(i).Thickness > 1 ? (nwd.GetShape(i).Thickness % 2 == 0 ? nwd.GetShape(i).Thickness / 2 : ((nwd.GetShape(i).Thickness - 1) / 2) + 1) : nwd.GetShape(i).Thickness),
										nwd.GetShape(i).Thickness, 
										nwd.GetShape(i).Color,
										int(nwd.GetShape(i).Alpha * 255));
					// Bottom
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius,
									nwd.yLocation + nwd.GetShape(i).y_End,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Left
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_Start,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
					// Right
					Screen.DrawThickLine(nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius,
									nwd.xLocation + nwd.GetShape(i).x_End,
									nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius,
									nwd.GetShape(i).Thickness,
									nwd.GetShape(i).Color,
									int(nwd.GetShape(i).Alpha * 255));
									
					ang = 90 / nwd.GetShape(i).Vertices;
					// Upper Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius; 
					originy = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
						cyend = originy - sin(ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;
					}
					
					// Upper Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_Start + nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_Start;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(90 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(90 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_Start + nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Left
					originx = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_Start + nwd.GetShape(i).Radius;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(270 + ang * j) * nwd.GetShape(i).Radius;
						cyend = originy - sin(270 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cyend = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					// Lower Right
					originx = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
					originy = nwd.yLocation + nwd.Getshape(i).y_End - nwd.GetShape(i).Radius;
					cxstart = nwd.xLocation + nwd.GetShape(i).x_End;
					cystart = nwd.yLocation + nwd.GetShape(i).y_End - nwd.GetShape(i).Radius;
					for (int j = 0; j < nwd.GetShape(i).Vertices; j++)
					{
						cxend = originx - cos(180 + ang * j) * nwd.GetShape(i).Radius;
						if (j == nwd.GetShape(i).Vertices - 1)
							cxend = nwd.xLocation + nwd.GetShape(i).x_End - nwd.GetShape(i).Radius;
						cyend = originy - sin(180 + ang * j) * nwd.GetShape(i).Radius;
						Screen.DrawThickLine(cxstart, cystart, cxend, cyend, nwd.GetShape(i).Thickness, nwd.GetShape(i).Color, int(nwd.GetShape(i).Alpha * 255));
						cxstart = cxend;
						cystart = cyend;					
					}
					break;
			}
		}
		nwd.zHandler.WindowClip(set:false);
	}
	
	ui static void WindowProcess_Buttons(ZSWindow nwd)
	{
		for (int i = 0; i < nwd.Buttons.Size(); i++)
		{							
			int clipx = 0, 
				clipy = 0, 
				wdth = 0, 
				hght = 0;

			// Check if button is beyond right edge
			if (nwd.xLocation + nwd.Buttons[i].xLocation > nwd.xLocation + nwd.Width)
				break; // This button cannot be seen so don't bother drawing it
			// Check if button is beyond left edge
			else if (nwd.xLocation + nwd.Buttons[i].xLocation < nwd.xLocation)
			{
				// Now check if there's anything of the button to draw
				if (nwd.xLocation + nwd.Buttons[i].xLocation + nwd.Buttons[i].Width > nwd.xLocation)
				{
					clipx = nwd.xLocation; // There is, so the left edge is set to the window edge
					wdth = nwd.Buttons[i].Width - (nwd.xLocation - nwd.Buttons[i].xLocation);
				}
				else
					break; // This button cannot be seen so don't bother drawing it
			}
			// Button is within the window
			else
			{
				clipx = nwd.xLocation + nwd.Buttons[i].xLocation;
				wdth = nwd.Buttons[i].Width;
			}
			
			// Check if button is beyond bottom edge
			if (nwd.yLocation + nwd.Buttons[i].yLocation > nwd.yLocation + nwd.Height)
				break; // Button can't be seen, skip it
			// Check if button is beyond top edge
			else if (nwd.yLocation + nwd.Buttons[i].yLocation < nwd.yLocation)
			{
				// Is anything visable?
				if (nwd.yLocation + nwd.Buttons[i].yLocation + nwd.Buttons[i].Height > nwd.yLocation)
				{
					clipy = nwd.yLocation;
					hght = nwd.Buttons[i].Height - (nwd.Buttons[i].yLocation - nwd.yLocation);
				}
				else
					break;  // Button can't be seen, skip it
			}
			// Button is within the window
			else
			{
				clipy = nwd.yLocation + nwd.Buttons[i].yLocation;
				hght = nwd.Buttons[i].Height;
			}				

			switch (nwd.Buttons[i].Type)
			{
				case ZButton.standard:					
					screen.SetClipRect(clipx, clipy, wdth, hght);
					if (nwd.Buttons[i].Stretch)
						screen.DrawTexture(nwd.Buttons[i].btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.Buttons[i].btnTextures[0].dar_TextureSet[nwd.Buttons[i].State].txtId : nwd.Buttons[i].btnTextures[0].dar_TextureSet[0].txtId,
										false, 
										nwd.xLocation + nwd.Buttons[i].xLocation, 
										nwd.yLocation + nwd.Buttons[i].yLocation,
										DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
										DTA_DestWidth, nwd.Buttons[i].Width,
										DTA_DestHeight, nwd.Buttons[i].Height);
					else
					{
						int tx, ty, w = 0;
						Vector2 txy = TexMan.GetScaledSize(nwd.Buttons[i].btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.Buttons[i].btnTextures[0].dar_TextureSet[nwd.Buttons[i].State].txtId : nwd.Buttons[i].btnTextures[0].dar_TextureSet[0].txtId);
						tx = txy.x;
						ty = txy.y;
						do
						{
							int h = 0;
							do
							{
								Screen.DrawTexture (nwd.Buttons[i].btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.Buttons[i].btnTextures[0].dar_TextureSet[nwd.Buttons[i].State].txtId : nwd.Buttons[i].btnTextures[0].dar_TextureSet[0].txtId, 
									false,
									nwd.xLocation + nwd.Buttons[i].xLocation + (tx * w),
									nwd.yLocation + nwd.Buttons[i].yLocation + (ty * h),
									DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
									DTA_DestWidth, tx,
									DTA_DestHeight, ty);
								h++;
							} while ((((h - 1) * ty) + ty) < nwd.Buttons[i].Height);
							w++;
						} while ((((w - 1) * tx) + tx) <= nwd.Buttons[i].Width);
					}
					nwd.zHandler.WindowClip(set:false);
					break;
				case ZButton.radio:
				case ZButton.check:
					screen.SetClipRect(clipx, clipy, wdth, hght);
					screen.DrawTexture(nwd.Buttons[i].btnTextures[0].dar_TextureSet.Size() > 1 ? nwd.Buttons[i].btnTextures[0].dar_TextureSet[nwd.Buttons[i].State].txtId : nwd.Buttons[i].btnTextures[0].dar_TextureSet[0].txtId,
									false, 
									nwd.xLocation + nwd.Buttons[i].xLocation, 
									nwd.yLocation + nwd.Buttons[i].yLocation,
									DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
									DTA_DestWidth, nwd.Buttons[i].Width,
									DTA_DestHeight, nwd.Buttons[i].Height);
					nwd.zHandler.WindowClip(set:false); // this is the same as calling screen.ClearClipRect()
					break;
				case ZButton.zbtn:
					TextureId leftSide, middle, rightSide;
					// Do we have more at least one TextureSet?
					if (nwd.Buttons[i].btnTextures.Size() > 0)
					{
						// We do, so check if there's 3 sets with exactly 3 textures each
						if (nwd.Buttons[i].btnTextures.Size() == 3 &&
							nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet.Size() == 3)
						{
							leftSide = nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet[0].txtId;
							middle = nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet[1].txtId;
							rightSide = nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet[2].txtId;
						}
						// There's not, so check if there's 3 sets with at least one texure each
						else if (nwd.Buttons[i].btnTextures.Size() == 3 &&
								nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet.Size() > 0)
							leftSide = middle = rightSide = nwd.Buttons[i].btnTextures[nwd.Buttons[i].State].dar_TextureSet[0].txtId;
						// Ok, theres at least one texture set, so check it has something in it and use it!
						else if (nwd.Buttons[i].btnTextures[0].dar_TextureSet.Size() > 0)
							leftSide = middle = rightSide = nwd.Buttons[i].btnTextures[0].dar_TextureSet[0].txtId;
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
									nwd.xLocation + nwd.Buttons[i].xLocation, 
									nwd.yLocation + nwd.Buttons[i].yLocation,
									DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
									DTA_DestWidth, lx,
									DTA_DestHeight, ly);	
					Vector2 rxy = TexMan.GetScaledSize(rightSide);
					rx = rxy.x;
					ry = rxy.y;	
					screen.DrawTexture(rightSide,
									false, 
									nwd.xLocation + nwd.Buttons[i].xLocation + nwd.Buttons[i].Width - rx, 
									nwd.yLocation + nwd.Buttons[i].yLocation,
									DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
									DTA_DestWidth, rx,
									DTA_DestHeight, ry);										
					nwd.zHandler.WindowClip(set:false);
						
					int midclipx, midwdth;
					// The button clipping boundary is beyond the button location
					if (clipx > nwd.xLocation + nwd.Buttons[i].xLocation)
					{
						midclipx = (clipx - (nwd.xLocation + nwd.Buttons[i].xLocation)) + lx;
						// The middle clip x is greater than the button clipx, subtract the left and right dimensions from the width to get the middle width
						if (midclipx > clipx)
							midwdth = nwd.Buttons[i].Width - lx - rx;
						// Other way around, do the same thing, but now subtract the different between the clipping edges
						else
							midwdth = (nwd.Buttons[i].Width - lx - rx) - (clipx - midclipx);
					}
					// The button is within the window, so left edge is edge of the left texture
					else
					{
						midclipx = nwd.xLocation + nwd.Buttons[i].xLocation + lx;
						midwdth = nwd.Buttons[i].Width - lx - rx;
					}
					
					int mx, my;
					Vector2 mxy = TexMan.GetScaledSize(middle);
					mx = mxy.x;
					my = mxy.y;
					screen.SetClipRect(midclipx, clipy, midwdth, my);
					int w = 0;
					// No height loop because the height is the height of the textures
					do
					{
						Screen.DrawTexture (middle, 
							false,
							nwd.xLocation + nwd.Buttons[i].xLocation + lx + (mx * w),
							nwd.yLocation + nwd.Buttons[i].yLocation,
							DTA_Alpha, int(nwd.Buttons[i].Alpha * 255),
							DTA_DestWidth, mx,
							DTA_DestHeight, my);
						w++;
					} while ((((w - 1) * mx) + mx) <= midwdth);
					nwd.zHandler.WindowClip(set:false);
					break;
			}
			// Text
			// Border
		}
	}
	
	ui static void WindowProcess_Graphics(ZSWindow nwd)
	{
		nwd.zHandler.WindowClip(nwd);
		nwd.zHandler.WindowClip(set:false);
	}
}