/*
	ZSWin_HandlerUtil.zs
	
	Base class for EventSystem

*/

class ZSHandlerUtil : EventHandler
{
	// This is the ZScript Windows Version
	const ZVERSION = "0.3";
	
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
	
	/* - END OF METHODS - */
}