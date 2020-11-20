/*
	ZSWin_WindowUtil.zs
	
	Utility Struct for window information passing

*/

class WindowStats
{
	int Priority, Width, Height;
	float xLocation, yLocation;
	
	WindowStats Init (int Priority = 0, int Width = 0, int Height = 0, float xLocation = 0, float yLocation = 0)
	{
		self.Priority = Priority;
		self.Width = Width;
		self.Height = Height;
		self.xLocation = xLocation;
		self.yLocation = yLocation;
		return self;
	}
}