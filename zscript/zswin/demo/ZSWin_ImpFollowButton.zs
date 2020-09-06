/*
	ZSWin_BFGButton.zs
	
	This is a demonstration button that shows how
	to use mouse events.

*/

class ImpFollowButton : ZButton
{
	// We don't really need to do anything here except
	// override event methods, however you could initialize
	// and define things as needed here as well.
	
	// Use this for mouse-over
	override void OnMouseMove(ZSWindow nwd)
	{
		if (ValidateCursorLocation(nwd, xLocation, yLocation, Width, Height))
			self.State = ZButton.highlight;
		else
			self.State = ZButton.idle;
	}

	// Use this to set the button state to active
	override void OnLeftMouseDown(ZSWindow nwd)
	{
		// The button uses the OnMouseMove event, which sets the state to highlight,
		// so it's safe to check the state here.
		// Under other circumstances you might validate the cursor location or check some
		// other bit of data.
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
			
			CallACS("TalkImpTeleport");  // total playism change here, this alters the level itself so yeah, has to be acs
			
			// The following are the only valid ways for closing a window.
			// That is to say deleting it from every player's window stack.
			// Just setting bStackPurged to true does not work anymore!
			//
			nwd.Close(); // this is a wrapper for zHandler.SetWindowForPurge, so the ui toggle bool defaults to true here
			//EventHandler.SendNetworkEvent(string.Format("zswin_windowPurge:%s", nwd.name));
			//nwd.zHandler.SetWindowForPurge(WindowName); // there's an optional bool to toggle the ui with this call as well
		}
	}
}