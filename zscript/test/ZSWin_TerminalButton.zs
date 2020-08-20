/*
	ZSWin_TerminalButton.zs
	
	This is a demonstration button that shows how
	to use mouse events.

*/

class TerminalButton : ZButton
{
	// We don't really need to do anything here except
	// override event methods, however you could initialize
	// and define things as needed here as well.

	// Use this to set the button state to active
	override void OnLeftMouseDown(ZSWindow nwd)
	{
		// The window's passive GibZoning will set the button's state to
		// highlight if the cursor is on the button and the button isn't
		// blocked by by another window.
		if (self.State == ZButton.highlight)
			self.State = ZButton.active;
	}
	
	// Use this to do the action
	override void OnLeftMouseUp(ZSWindow nwd)
	{
		if (self.State == ZButton.active)
		{
			// Reset the button's state to idle, passive GibZoning will reset it to highlight if needed.
			self.State = ZButton.idle;
			
			// All three of the following are valid methods of closing a window
			// That is to say deleting it from every player's window stack.
			//
			nwd.Close();
			//EventHandler.SendNetworkEvent(string.Format("zswin_windowPurge:%s", nwd.name));
			//nwd.bStackPurged = true;
		}
	}
}