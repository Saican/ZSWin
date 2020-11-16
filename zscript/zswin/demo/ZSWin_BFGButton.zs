/*
	ZSWin_BFGButton.zs
	
	This is a demonstration button that shows how
	to use mouse events.

*/

class BFGButton : ZButton
{
	// Use this for mouse-over
	override void OnMouseMove(int t)
	{
		if (ValidateCursorLocation())
			self.State = BSTATE_Highlight;
		else
			self.State = BSTATE_Idle;
	}

	// Use this to set the button state to active
	override void OnLeftMouseDown(int t)
	{
		// The button uses the OnMouseMove event, which sets the state to highlight,
		// so it's safe to check the state here.
		// Under other circumstances you might validate the cursor location or check some
		// other bit of data.
		if (self.State == BSTATE_Highlight)
			self.State = BSTATE_Active;
	}
	
	// Use this to do the action
	override void OnLeftMouseUp(int t)
	{
		if (self.State == BSTATE_Active)
		{
			// Reset the button's state to idle, passive GibZoning will reset it to highlight if needed.
			self.State = BSTATE_Idle;			
			EventHandler.SendNetworkEvent("zevsys_CallACS,BFGTerminal_Activate");
			//GetParentWindow(self.ControlParent).Close();
		}
	}
}