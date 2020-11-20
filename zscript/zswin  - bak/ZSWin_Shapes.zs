/*
	ZSWin_Lines.txt
	
	Interface for the creation of lines and boxes in a window

*/

class ZShape : ZControl_Base
{
	SHAPETYPE Type;
	
	color Color;
	
	int x_Start, 
		y_Start, 
		x_End, 
		y_End,
		Radius,
		Vertices;
		
	float LineThickness;
	
	/*
		If this instance of ZText is not null, and the shape type is one of the group box types,
		only the xLocation will be utilized and will be an offset from the left side of the box.
	
	*/
	ZText GroupTitle;
	
	ZShape Init (string ControlName, bool Enabled, bool Show, SHAPETYPE Type, color Color, int x_Start, int y_Start, int x_End, int y_End, float Alpha = 1.0, float LineThickness = 1.0, SCALETYP ScaleType = noscale, int Radius = 0, int Vertices = 0, ZText GroupTitle = null)
	{
		self.ControlName = ControlName;
		self.Enabled = Enabled;
		self.Show = Show;
		self.Type = Type;
		self.Color = Color;
		self.x_Start = x_Start;
		self.y_Start = y_Start;
		self.x_End = x_End;
		self.y_End = y_End;
		self.Alpha = Alpha;
		self.LineThickness = LineThickness;
		self.ScaleType = ScaleType;
		self.Radius = Radius;
		self.Vertices = Vertices;
		self.GroupTitle = GroupTitle;
		return self;
	}
}