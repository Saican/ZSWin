/*
	ZSWin_Text.txt
	
	This is the string management class.
	All text that makes it onto the screen in a Z-Window
	is stored in an instance of this class.

*/

class ZText : ZControl_Base
{
	string Text;
	int CRColor;
	
	enum TXTWRAP
	{
		wrap,
		dynwrap,
		nowrap,
	};
	TXTWRAP TextWrap;
	
	int WrapWidth;
	string ShapeWidth;
	
	TEXTALIGN Alignment;
	
	Font font;
	
	float xLocation, 
		yLocation;
		
	uint Tics;
	bool TicAppend;
	
	ZText Init (string ControlName, bool Enabled, bool Show, string Text, int CRColor, TXTWRAP TextWrap, int WrapWidth, TEXTALIGN Alignment, name fontName, float xLocation, float yLocation = 0.0, float Alpha = 1.0, string ShapeWidth = "", uint Tics = 0, bool TicAppend = false)
	{
		self.ControlName = ControlName;
		self.Enabled = Enabled;
		self.Show = Show;
		self.Text = Text;
		self.CRColor = CRColor;
		self.TextWrap = TextWrap;
		self.WrapWidth = WrapWidth;
		self.Alignment = Alignment;
		self.font = Font.GetFont(fontName);
		self.xLocation = xLocation;
		self.yLocation = yLocation;
		self.Alpha = Alpha;
		self.ShapeWidth = ShapeWidth;
		self.Tics = Tics;
		self.TicAppend = TicAppend;
		self.ScaleType = noscale;

		if (font)
			return self;
		else
			return null;
	}
	
	ZText DebugInit(string ControlName, string Text, int CRColor, uint Tics, bool TicAppend)
	{
		self.ControlName = ControlName;
		self.Enabled = true;
		self.Text = Text;
		self.CRColor = CRColor;
		self.TextWrap = nowrap;
		self.WrapWidth = 0;
		self.Alignment = left;
		self.xLocation = self.yLocation = 0;
		self.Alpha = 1.0;
		self.ShapeWidth = "";
		self.Tics = Tics;
		self.TicAppend = TicAppend;
		self.ScaleType = noscale;
		return self;  // no font check, debugging handles the font.
	}
	
	ui float GetAlignment (float nwd_xLocation, float nwd_Width = 0.0, string line = "")
	{
		switch (Alignment)
		{
			default:
			case left: return nwd_xLocation + xLocation;
			case right: return (nwd_xLocation + nwd_Width) - (font.StringWidth(line) + xLocation);
			case center: return nwd_xLocation + ((nwd_Width - font.StringWidth(line)) / 2);
		}
	}
}