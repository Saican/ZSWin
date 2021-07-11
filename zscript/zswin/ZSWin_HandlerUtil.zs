/*
	ZSWin_HandlerUtil.zs
	
	Base class for EventSystem

*/

class ZSHandlerUtil : EventHandler
{
	// This is the ZScript Windows Version
	const ZVERSION = "0.4.1";
	
	/*
		Returns a value equal to the lowest possible
		Event Handler Order not used by another handler.
		
		What?  It automates the call to SetOrder and works
		like getting a unique TID.  The number returned is
		not used by any other event handler.
		
		Per the wiki, for inputs, a higher number receives the event first,
		for render events, a higher number receives the event last.
		
		What's not known is what happens if two event handlers share the same order.
		This method is an attempt to give the ZScript Windows handlers unique order
		numbers should other event handlers be present and set order numbers to
		avoid any potential conflicts.
	
	*/
	static int GetLowestPossibleOrder()
	{
		int highestOrder = 0;
		array<string> handlerNames;
		for (int i = 0; i < AllClasses.Size(); i++)
		{
			if (AllClasses[i] is "StaticEventHandler")
				handlerNames.Push(AllClasses[i].GetClassName());
		}
		
		for (int i = 0; i < handlerNames.Size(); i++)
		{
			let handler = EventHandler.Find(handlerNames[i]);
			if (handler && handler.Order > highestOrder)
				highestOrder = handler.Order;
		}
		
		return highestOrder + 1;
	}
	
	/*
		Just for fun, crash scenarios that can't be
		escaped can call this method for a fun VM abort message.
		
		The message argument can be formatted to whatever output you can get.
	
	*/
	clearscope static void HaltAndCatchFire(string message)
	{
		ThrowAbortException("\n - - WAR, WAR NEVER CHANGES - -\n\n%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
										"    _.-^^---....,,--_\n",
										" _--                  --\n",
										"<                        >)\n",
										"|                         |\n",
										" \._                   _./\n",
										"    ```--. . , ; .--'''\n",   
										"          | |   |\n",
										"       .-=||  | |=-.\n",
										"       `-=#$%&%$#=-'\n",
										"          | ;  :|\n", 
										" _____.,-#%&$@%#&#~,._____\n\n",
										" - - YES YOU DID THAT!  YOU!  IDK WHAT YOU DID BUT IT'S ALL YOUR FAULT!\n",
										message,
										"\n - - FULL NUCLEAR ARSENAL UNLEASHED - GOODBYE VM!");		
	}
	
	/*
		This method is a very bad way to check that a given
		name corresponds to a known class.  It's bad because
		of the time complexity, even though it's linear, the
		size of the array it searches may be quite large.
		What this means is that use of this method when loaded
		with large mods will be less efficient than with the
		base games.
		
	*/
	clearscope static bool ClassNameIsAClass(string classname)
	{
		for (int i = 0; i < AllClasses.Size(); i++)  // The vm gods have to hate me
		{
			if (AllClasses[i].GetClassName() == classname)
				return true;
		}
		// This search is bad enough that while I'm not going to VM crash for failure, I'm still going to send a console message.
		console.Printf(string.Format(" - - ZScript Windows, ClassNameIsAClass usage failed looking for a class named, %s.\n - - Please note that this method is costly on processing time and should not be used in conditions where failure is likely.", classname));
		return false;
	}
	
	/* - END OF METHODS - */
}