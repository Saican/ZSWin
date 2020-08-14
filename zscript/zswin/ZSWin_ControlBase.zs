/*
	ZSWin_ControlBase.txt
	
	Contains members universal to all controls

*/

class ZControl_Base abstract
{
	string Name;
	bool Enabled;
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
}