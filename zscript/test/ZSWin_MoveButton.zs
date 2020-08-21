/*
	ZSWin_MoveButton.zs

*/

class ZSWin_MoveButton : ZButton
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
		{
			self.State = ZButton.active;
			nwd.LockMoveOrigin();
		}
	}
	
	// Use this to do the action
	override void OnLeftMouseUp(ZSWindow nwd)
	{
		if (self.State == ZButton.active)
		{
			// Reset the button's state to idle, passive GibZoning will reset it to highlight if needed.
			self.State = ZButton.idle;
			nwd.MoveAccumulate();
		}
	}
}