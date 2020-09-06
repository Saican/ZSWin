/*

	ZSWin_TalkImp.zs
	
	This test file replaces the DoomImp with an Imp that can be
	talked to through ZScript Windows

*/

class ZSImp : DoomImp replaces DoomImp
{
	ZSWin_ImpWindow zwina;
	ZSWin_ImpWindow2 zwinb;
	
    override bool Used (Actor user)
    {
		A_StartSound("imp/sight");
		ZSWin_ImpWindow(new("ZSWin_ImpWindow").Init(null, true, true, "WaterWindow", consoleplayer, true, 300, 350));
		ZSWin_ImpWindow2(new("ZSWin_ImpWindow2").Init(null, true, true, "StoneWindow", consoleplayer, true));
        return false;
    }
}