/*
	ZSWin_ControlBase.txt
	
	Contains members universal to all controls

*/

class ZControl_Base play abstract
{
	string ControlName;
	private bool wasEnabled;
	void ShowCheck()
	{
		if (!Show)
		{
			wasEnabled = Enabled;
			Enabled = false;
		}
		else if (wasEnabled && !Enabled)
			Enabled = true;
	}
	bool Enabled,
		Show,
		Animate;
	float Alpha;
	
	enum SCALETYP
	{
		scalex,
		scaley,
		scaleboth,
		noscale,
	};
	SCALETYP ScaleType;
	
	enum TEXTALIGN
	{
		left,
		right,
		center,
	};
	
	enum SHAPETYPE
	{
		thinline,
		thickline,
		box,
		thickbox,
		roundbox,
		roundthickbox,
		thingroupbox,
		thickgroupbox,
		thinroundgroupbox,
		thickroundgroupbox,
		noshape,
	};

	bool ValidateCursorLocation(ZSWindow nwd, float controlX, float controlY, int controlWidth, int controlHeight)
	{
		int CursorX = nwd.zHandler.CursorX,
			CursorY = nwd.zHandler.CursorY;
		Array<WindowStats> higherStats;
		float cposx, cposy;
		[cposx, cposy] = ZDrawer.realWindowLocation(ZSWindow(nwd));
		cposx += controlX;
		cposy += controlY;
		bool mouseOver = true;
		if (nwd.Priority > 0)
		{
			for (int i = 0; i < nwd.zHandler.GetStackSize(); i++)
			{
				WindowStats newStats = nwd.zHandler.GetWindowStats(i);
				if (newStats && newStats.Priority < nwd.Priority)
					higherStats.Push(newStats);
			}
			for (int i = 0; i < higherStats.Size(); i++)
			{
				if (higherStats[i].xLocation < CursorX && CursorX < higherStats[i].xLocation + higherStats[i].Width &&
					higherStats[i].yLocation < CursorY && CursorY < higherStats[i].yLocation + higherStats[i].Height)
				{
					mouseOver = false;
					break;
				}
			}
		}
		if (mouseOver && nwd.GlobalShow && nwd.GlobalEnabled && self.Show && self.Enabled &&
				cposx < CursorX && CursorX < cposx + controlWidth &&
				cposy < CursorY && CursorY < cposy + controlHeight)
			return true;
		else
			return false;
	}
	
	virtual void WhileMouseIdle(ZSWindow nwd) {}
	virtual void OnMouseMove(ZSWindow nwd) {}
	
	virtual void OnLeftMouseDown(ZSWindow nwd) {}
	virtual void OnLeftMouseUp(ZSWindow nwd) {}
	virtual void OnLeftMouseClick(ZSWindow nwd) {}
	
	virtual void OnMiddleMouseDown(ZSWindow nwd) {}
	virtual void OnMiddleMouseUp(ZSWindow nwd) {}
	virtual void OnMiddleMouseClick(ZSWindow nwd) {}
	
	virtual void OnRightMouseDown(ZSWindow nwd) {}
	virtual void OnRightMouseUp(ZSWindow nwd) {}
	virtual void OnRightMouseClick(ZSWindow nwd) {}
	
	virtual void OnWheelMouseDown(ZSWindow nwd) {}
	virtual void OnWheelMouseUp(ZSWindow nwd) {}
}