/*
	ZSWin_Object_GroupBox.zs
	
	GroupBox Control Base Class Definition

*/

class ZBox : ZObjectBase
{
	string Text;
	
	virtual ZSWindow Init(bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		self.Text = Text;
		return ZSWindow(super.Init(Enabled, Show, Name, PlayerClient, UiToggle));
	}
}