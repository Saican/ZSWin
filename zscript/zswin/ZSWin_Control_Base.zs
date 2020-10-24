/*
	ZSWin_ControlBase.zs
	
	This base class contains members and methods universal to controls

*/

class ZControl : ZObjectBase abstract
{
	SCALETYP ScaleType;
	bool HasFocus;
	
	enum TEXTALIGN
	{
		TEXTALIGN_Left,
		TEXTALIGN_Right,
		TEXTALIGN_Center,
	};
	TEXTALIGN TextAlignment;
	
	enum TXTWRAP
	{
		TXTWRAP_Wrap,
		TXTWRAP_Dynamic,
		TXTWRAP_NONE,
	};
	TXTWRAP TextWrap;

	ZControl Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle, SCALETYP ScaleType = SCALE_NONE, TEXTALIGN TextAlignment = TEXTALIGN_Left, CLIPTYP ClipType = CLIP_Parent)
	{
		self.ScaleType = ScaleType;
		self.TextAlignment = TextAlignment;
		self.HasFocus = false;
		if (ControlParent)
			return ZControl(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
		else
			ZSHandlerUtil.HaltAndCatchFire(" - - CONTROLS REQUIRE VALID PARENT REFERENCE DOES NOT HAVE A VALID FONT!");
		return null;
	}
	
	/*
		Wrapper to trigger a focus change
	
	*/
	void SetFocus(bool fullKeyboard = false)
	{
		GetParentWindow(self.ControlParent).PostControlFocusIndex(self);
		if (fullKeyboard)
			ZNetCommand("zevsys_ControlFullInput", self.PlayerClient, true);
	}
	
	void LoseFocus(bool fullKeyboard = false)
	{
		HasFocus = false;
		if (fullKeyboard)
			ZNetCommand("zevsys_ControlFullInput", self.PlayerClient);
	}
	
	/*
		Returns a ZSWindow with the given priority
	
	*/
	clearscope ZSWindow GetWindowByPriority(int p)
	{
		ThinkerIterator nwdFinder = ThinkerIterator.Create("ZSWindow");
		ZSWindow enwd;
		while (enwd = ZSWindow(nwdFinder.Next()))
		{
			if (enwd.Priority == p)
				return enwd;
		}
		
		return null;
	}
	
	/*
		Recursively searches for the first encountered window and returns it.
		
		Set searchToFirstWindow to false to seach all the way to the end of the ControlParent chain
	
	*/
	clearscope static ZSWindow GetParentWindow(ZObjectBase zobj, bool searchToFirstWindow = true)
	{
		if (!zobj.ControlParent || (zobj is "ZSWindow" && searchToFirstWindow))
			return ZSWindow(zobj);
		else
			return GetParentWindow(zobj.ControlParent, searchToFirstWindow);	
	}
	
	/*
		Recursively looks up the chain of Control Parents for the first ZSWindow it encounters,
		and returns the result of the window's RealWindowLocation method.
	
	*/
	clearscope static float, float GetParentWindowLocation(ZObjectBase zobj, bool searchToFirstWindow = true)
	{
		float retx, rety;
		if (!zobj.ControlParent || (zobj is "ZSWindow" && searchToFirstWindow))
			[retx, rety] = ZSWindow(zobj).RealWindowLocation(ZSWindow(zobj));
		else
			[retx, rety] = GetParentWindowLocation(zobj.ControlParent, searchToFirstWindow);
		return retx, rety;
	}

	/*
		Recursively looks up the chain of Control Parents for the first ZSWindow it encounters,
		and returns the result of the window's RealWindowScale method.
	
	*/	
	clearscope static int, int GetParentWindowScale(ZObjectBase zobj, bool searchToFirstWindow = true)
	{
		float retx, rety;
		if (!zobj.ControlParent || (zobj is "ZSWindow" && searchToFirstWindow))
			[retx, rety] = ZSWindow(zobj).RealWindowScale(ZSWindow(zobj));
		else
			[retx, rety] = GetParentWindowScale(zobj.ControlParent, searchToFirstWindow);
		return retx, rety;
	}
	
	/*
		Recursively looks up the chain of Control Parents for the first ZSWindow it encounters.
		This is then used in determining the real width/height of to be used in a controls clipping
		boundary.
		
		send the ControlParent of the control and the parent of the control
	*/
	/*clearscope static int, int GetFinalControlScale(ZObjectBase zobj, ZObjectBase parent, bool searchToFirstWindow = true)
	{
		if (!zobj.ControlParent || (zobj is "ZSWindow" && searchToFirstWindow))
		{
			int scalediffx, scalediffy;
			[scalediffx, scalediffy] = ZSWindow(zobj).ScaleDifference();
			if (parent is "ZControl")
			{
				switch (ZControl(parent).ScaleType)
				{
					case SCALE_Horizontal:
						return parent.Width + ZSWindow(zobj).scaleAccumulateX + scalediffx, 
							parent.Height;
					case SCALE_Vertical:
						return parent.Width, 
							parent.Height + ZSWindow(zobj).scaleAccumulateY + scalediffy;
					case SCALE_Both:
						return parent.Width + ZSWindow(zobj).scaleAccumulateX + scalediffx, 
							parent.Height + ZSWindow(zobj).scaleAccumulateY + scalediffy;
					default:
						return parent.Width, parent.Height;
				}
			}
			else if (parent is "ZSWindow" && zobj.Name ~== parent.Name)
				return zobj.Width + ZSWindow(zobj).scaleAccumulateX + scalediffx,
					zobj.Height + ZSWindow(zobj).scaleAccumulateY + scalediffy;
			else
				return parent.Width + ZSWindow(zobj).scaleAccumulateX + scalediffx, 
					parent.Height + ZSWindow(zobj).scaleAccumulateY + scalediffy;  // wtf is this thing?
		}
		else
		{
			int retw, reth;
			[retw, reth] = GetFinalControlScale(zobj.ControlParent, parent, searchToFirstWindow);
			return retw, reth;
		}
	}*/
	
	/*clearscope static float, float GetControlLocationByScale(ZSWindow nwd, SCALETYP ScaleType)
	{
		float nwdX, nwdY, xdis, ydis;
		switch(ScaleType)
		{
			case SCALE_Horizontal:
				// X Location is scaled
				[nwdX, ydis] = nwd.RealControlScaledLocation(nwd);
				// Y Location just moves
				[xdis, nwdY] = nwd.RealWindowLocation(nwd);
				break;
			case SCALE_Vertical:
				// Y Location is scaled
				[xdis, nwdY] = nwd.RealControlScaledLocation(nwd);
				// X Location just moves
				[nwdX, ydis] = nwd.RealWindowLocation(nwd);
				break;
			case SCALE_Both:
				// This control can move and be scaled on both axis
				[nwdX, nwdY] = nwd.RealControlScaledLocation(nwd);
				break;
			default:
				// This control just moves - they can always move.
				[nwdX, nwdY] = nwd.RealWindowLocation(nwd);
				break;
		}
		return nwdX, nwdY;
	}*/
	
	/*
		Recursively looks up the chain of ControlParents, adding their x/y locations together.
		Once it hits a null ControlParent or a ZSWindow it adds in that window's move/scale 
		controllers and returns the result.
		
		If searchToFirstWindow is false, the search will run until it runs out of ControlParents.
		This can be used to search from a control in a sub-window to the parent window.
	
	*/
	/*clearscope static float, float GetFinalLocation(ZObjectBase zobj, float finX, float finY, SCALETYP ScaleType, bool searchToFirstWindow = true)
	{
		if (!zobj.ControlParent || (zobj is "ZSWindow" && searchToFirstWindow))
		{
			if (zobj is "ZSWindow")
			{
				int movediffx, movediffy, scalediffx, scalediffy;
				[movediffx, movediffy] = ZSWindow(zobj).MoveDifference();
				[scalediffx, scalediffy] = ZSWindow(zobj).ScaleDifference();
				switch (ScaleType)
				{
					case SCALE_Horizontal:
						return finX + ZSWindow(zobj).moveAccumulateX + movediffx + ZSWindow(zobj).scaleAccumulateX + scalediffx, 
							finY + ZSWindow(zobj).moveAccumulateY + movediffy;
					case SCALE_Vertical:
						return finX + ZSWindow(zobj).moveAccumulateX + movediffx,
							finY + ZSWindow(zobj).moveAccumulateY + movediffy + ZSWindow(zobj).scaleAccumulateY + scalediffy;
					case SCALE_Both:
						return finX + ZSWindow(zobj).moveAccumulateX + movediffx + ZSWindow(zobj).scaleAccumulateX + scalediffx,
							finY + ZSWindow(zobj).moveAccumulateY + movediffy + ZSWindow(zobj).scaleAccumulateY + scalediffy;
					default:
						return finX + ZSWindow(zobj).moveAccumulateX + movediffx, 
							finY + ZSWindow(zobj).moveAccumulateY + movediffy;
				}
			}
			else
				return finX, finY;
		}
		else
		{
			int retx, rety;
			[retx, rety] = GetFinalLocation(zobj.ControlParent, finX + zobj.ControlParent.xLocation, finY + zobj.ControlParent.yLocation, ScaleType, searchToFirstWindow);
			return retx, rety;
		}
	}*/
	
	enum CONTROLTYPE
	{
		CTLTYP_Window,
		CTLTYP_Button,
		CTLTYP_Text,
		CTLTYP_Box,
		CTLTYP_UNKNOWN,
	};
	
	clearscope CONTROLTYPE WhatIsMyParent(ZObjectBase parent)
	{
		if (parent is "ZSWindow")
			return CTLTYP_Window;
		if (parent is "ZButton")
			return CTLTYP_Button;
		if (parent is "ZText")
			return CTLTYP_Text;
		//if (parent is "ZBox")
			//return CTLTYP_Box;
		return CTLTYP_UNKNOWN;
	}
	
	/* - END OF METHODS - */
}