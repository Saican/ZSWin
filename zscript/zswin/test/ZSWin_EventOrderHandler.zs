/*
	ZSWin_StackHandler.zs
	
	Input handler

*/

/*
	What this test does:
	
	This test tries to produce 100 messages from both UITick and RenderOverlay
	in order to determine event order.
	
	Furthermore this test attempts to create an array that is modified each
	tick by UITick and then read by RenderOverlay.


	Conclusions of test:
	
	The UITick event occurs before the RenderOverlay event.
	RenderOverlay will be called multiple times before the next UITick
	
	It is safe to modify data read from RenderOverlay from the UITick method.
	Data changes from UITick will complete before RenderOverlay.

*/
class ZSWin_StackHandler : EventHandler
{
	array<int> messwith;
	int messagecount, rendercalls;
	bool printedtotal;
	override void OnRegister()
	{
		console.printf("ZScript Windows - The Biggest Pain in the Ass is here!");
		messagecount = 0;
		rendercalls = 0;
		printedtotal = false;
		messwith.push(0);
		messwith.push(0);
		messwith.push(0);
		messwith.push(0);
	}
	
	override void RenderOverlay(RenderEvent e)
	{
		if (messagecount < 100)
		{
			console.printf(string.format("I'm the render event, time is %f", e.FracTic));
			for (int i = 0; i < messwith.size(); i++)
				console.printf(string.format("messwith index %d is : %d", i, messwith[i]));
			SendNetworkEvent("messageIterate", 1);
		}
	}
	
	override void UiTick()
	{
		if (messagecount < 100)
		{
			console.printf("I'm the ui ticker");
			for (int i = 0; i < messwith.size(); i++)
				SendNetworkEvent("messwith", i);
			SendNetworkEvent("messageIterate");
		}
		else if (!printedtotal)
			SendNetworkEvent("printtotal");
	}
	
	override void NetworkProcess(ConsoleEvent e)
	{
		// Count the message
		if (e.Name ~== "messageIterate")
		{
			if (e.Args[0] > 0)
				rendercalls++;
			messagecount++;
		}
		
		// Change something in the array
		if (e.Name ~== "messwith")
			messwith[e.Args[0]] += messagecount;
		
		// Print out how many message were created and how many came from RenderOverlay
		if(e.Name ~== "printtotal")
		{
			printedtotal = true;
			console.printf(string.Format("Made %d messages, %d of them were from renderoverlay", messagecount, rendercalls));
		}
	}
}