# ZScript Windows v0.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Receiving Mouse Events

**Controls Have Their Own Event Methods**

Whether it is a ZText, ZShape, ZButton, or some other class, all ZControls inherit from the same base class, ZControl_Base.  Defined inside of this base class are eleven virtual methods that correspond to each of the eleven supported mouse events.  Users should override these methods by inheriting from a control, and defining what actions should be taken by the control should the given mouse event be received.

**Note:** ZScript Windows does not filter the events.  If the mouse event is received and, for example, a button overrides the corresponding action event, that method will be called.  Therefore it is up to the implementation to decide what conditions beyond the reception of the event control the button's actions; again, for example, the action event should check that the mouse cursor is actually on top of the button before executing actions.

When overriding control event methods, you do not need to call the Super of the base class.  The virtual defintions are basically just empty prototypes.

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
    	override void OnLeftMouseDown()
    	{
    		// The window's passive GibZoning will set the button's state to
    		// highlight if the cursor is on the button and the button isn't
    		// blocked by by another window.
    		if (self.State == ZButton.highlight)
    			self.State = ZButton.active;
    	}
    	
    	// Use this to do the action
    	override void OnLeftMouseUp()
    	{
    		if (self.State == ZButton.active)
    		{
    			self.State = ZButton.idle;  // reset the button's state, passive gibzoning will reset it
    			// You don't have to call ACS, just this example does to deactivate the force field
    			// in the demo map.
    			self.Text.Text = "Ha ha!";
    			CallACS("TerminalTest_ForceFieldDeactivator", 0);
    		}
    		else
    			console.printf(string.format("state is : %d", State));
    	}
    }

[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")