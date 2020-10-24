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