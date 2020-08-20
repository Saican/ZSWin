/*

	ZSWin_TalkImp.zs
	
	This test file replaces the DoomImp with an Imp that can be
	talked to through ZScript Windows

*/

class ZSImp : DoomImp replaces DoomImp
{
	ZSWin_Terminal zterm;
	
    override bool Used (Actor user)
    {
		A_Pain();
		if (!zterm)
		{
			zterm = new ("ZSWin_Terminal");
			if (zterm)
				zterm.Init(true, true, "TalkImpTerminal", consoleplayer, true);
		}
		else
			zterm.bStackPurged = true;
        return false;
    }
}