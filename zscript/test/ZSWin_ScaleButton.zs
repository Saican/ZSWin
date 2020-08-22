/*
	ZSWin_ScaleButton.zs

*/

class ZSWin_ScaleButton : ZButton
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
			nwd.LockScaleCursorOrigin();
		}
	}
	
	// Use this to do the action
	override void OnLeftMouseUp(ZSWindow nwd)
	{
		/* 
			It's not 100% safe with either moving or scaling things to rely on
			the button's state to be the expected state.  If the user releases
			the mouse button while moving, PassiveGibZoning may reset the state
			to idle before this event has a chance to react.
			
			So, with that in mind, call IsMove or IsScaleLocked() instead.
		*/
		if (self.State == ZButton.active || nwd.IsScaleLocked())
		{
			// Reset the button's state to idle, passive GibZoning will reset it to highlight if needed.
			self.State = ZButton.idle;
			nwd.ScaleAccumulate();
		}
	}
}