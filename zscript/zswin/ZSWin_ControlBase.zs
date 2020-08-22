/*
	ZSWin_ControlBase.txt
	
	Contains members universal to all controls

*/

class ZControl_Base play abstract
{
	string Name;
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
		Show;
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