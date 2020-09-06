/*
	ZSWin_ScaleButton.zs

*/

class ZSWin_ScaleButton : ZButton
{
	// Use this for mouse-over
	override void OnMouseMove()
	{
		if (self.State != BSTATE_Active)
		{
			if (ValidateCursorLocation())
				self.State = BSTATE_Highlight;
			else
				self.State = BSTATE_Idle;
		}
	}

	// Use this to set the button state to active
	override void OnLeftMouseDown()
	{
		// The button uses the OnMouseMove event, which sets the state to highlight,
		// so it's safe to check the state here.
		// Under other circumstances you might validate the cursor location or check some
		// other bit of data.
		if (self.State == BSTATE_Highlight)
		{
			self.State = BSTATE_Active;
			GetParentWindow(self.ControlParent).LockScaleCursorOrigin();
		}
	}
	
	// Use this to do the action
	override void OnLeftMouseUp()
	{
		/* 
			It's not 100% safe with either moving or scaling things to rely on
			the button's state to be the expected state.  If the user releases
			the mouse button while moving, PassiveGibZoning may reset the state
			to idle before this event has a chance to react.
			
			So, with that in mind, call IsMove or IsScaleLocked() instead.
		*/
		if (self.State == BSTATE_Active || GetParentWindow(self.ControlParent).IsScaleLocked())
		{
			// Reset the button's state to idle, passive GibZoning will reset it to highlight if needed.
			self.State = BSTATE_Idle;
			GetParentWindow(self.ControlParent).ScaleAccumulate();
		}
	}
}