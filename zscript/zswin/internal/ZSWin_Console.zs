/*
	ZSWin_Console.zs
	
	This window is the console window created by activating debugging
	from the ZScript Windows Options Menu
	
	This window is part of ZSCript Windows and cannot be removed!

*/

class ZSWin_Console : ZSWindow
{
	override ZSWin_Base Init(bool GlobalEnabled, bool GlobalShow, string name, int player, bool uiToggle)
	{
		TrueZero();
		BorderType = ZWin_Border;
		[xLocation, yLocation] = WindowLocation_Default();
		Width = 1000;
		Height = 500;
		
		BackgroundType = ZWin_Default;
		BackgroundAlpha = 0.8;
		Stretch = true;
		
		Title = new("ZText").Init("consoleTitle", true, true, string.Format("ZScript Windows v%s : Console Messages", ZSHandlerUtil.ZVERSION),
			Font.CR_Gold,
			ZText.nowrap,
			0,
			ZText.left,
			"bigfont",
			0);
		

		// Move Button
		Buttons.Push(new("ZSWin_MoveButton").Init("moveButton", "", Width:25, btn_xLocation:(self.Width - 55), scaleType:ZControl_Base.scalex, Stretch:true,
						idleTextureName:"BMOVEIS", highlightTextureName:"BMOVEHS", activeTextureName:"BMOVEAS", borderType:ZControl_Base.noshape));
						
		// Close Button
		Buttons.Push(new("ZSWin_ConsoleCloseButton").Init("closeButton", "", Width:25, btn_xLocation:(self.Width - 25), scaleType:ZControl_Base.scalex, Stretch:true,
						idleTextureName:"BCLSEIS", highlightTextureName:"BCLSEHS", activeTextureName:"BCLSEAS", borderType:ZControl_Base.noshape));
						
		// Resize Button
		Buttons.Push(new("ZSWin_ScaleButton").Init("scaleButton", "", Width:25, btn_xLocation:(self.Width - 25), btn_yLocation:(self.Height - 25), scaleType:ZControl_Base.scaleboth, Stretch:true,
						idleTextureName:"BDRAGIS", highlightTextureName:"BDRAGHS", activeTextureName:"BDRAGAS", borderType:ZControl_Base.noshape));

		super.Init(GlobalEnabled, GlobalShow, name, player, uiToggle);
		SetWindowToConsole();		
		return self;
	}
}

class ZSWin_ConsoleCloseButton : ZSWin_CloseButton
{
	override void OnLeftMouseUp(ZSWindow nwd)
	{
		EventHandler.SendNetworkEvent("zswin_debugToggle");
		super.OnLeftMouseUp(nwd);
	}
}