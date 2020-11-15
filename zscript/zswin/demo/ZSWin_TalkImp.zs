/*

	ZSWin_TalkImp.zs
	
	This test file replaces the DoomImp with an Imp that can be
	talked to through ZScript Windows

*/

class ZSImp : DoomImp replaces DoomImp
{	
	/*
		This event ocurrs when the player presses the "use"
		key on the actor.
	
	*/
    override bool Used (Actor user)
    {
		A_StartSound("imp/sight");
		/*
			ZWindows are actors too,
			so just spawn them as normal.
		
		*/
		bool spwnd;
		actor impWinA, impWinB;
		[spwnd, impWinA] = A_SpawnItemEx("ZSWin_ImpWindow");
		if (impWinA)
			ZSWin_ImpWindow(impWinA).Init(null, true, true, "WaterWindow", consoleplayer, true, 300, 350);
		[spwnd, impWinB] = A_SpawnItemEx("ZSWin_ImpWindow2");
		if (impWinB)
			ZSWin_ImpWindow2(impWinB).Init(null, true, true, "StoneWindow", consoleplayer, true);
        return false;
    }
	
	/*
		No other changes made,
		all other settings are
		done in the map.
	
	*/
}