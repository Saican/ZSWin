/*
	ZSWin_Console.txt
	
	This window is an example of a window that inherits from ZSWin_Terminal
	and redefines it.
	
	This window is part of ZSCript Windows and cannot be removed!

*/

class ZSWin_Console : ZSWin_Terminal
{
	override void PostBeginPlay()
	{
		if (GetAge() < 1)
		{
			WindowName = "ZSWinConsole";
			super.PostBeginPlay();
			
			// The title will have been initialized, so just modify to suit
			Title.Text = "ZSWin Console Messages";
			Title.TextWrap = ZText.nowrap;
			
			[xLocation, yLocation] = WindowLocation_Default();
			Width = 1000;
			
			/*
				All object arrays you intend to use need cleared, if they inherit from another window.
				You can call ControlClear() to empty all arrays,
				or clear them individuallly if needed.
				
				(Or modify the contents, etc.)
				
				Here it's done individually because the Terminal Test initializes most of the Z-Windows default behaviors,
				so just the text array needs cleared out so the handler can mess with it dynamically.
			*/
			Text.Clear();
			// This makes the windows be the window the debug output pushes string to.
			SetWindowToConsole();
		}
	}
}