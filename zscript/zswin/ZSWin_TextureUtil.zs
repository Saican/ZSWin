/*
	ZSWin_TextureUtil.txt
	
	Contains utility classes for managing TextureIds

*/

class TextureSet
{
	Array<SetId> dar_TextureSet;
}

class SetId
{
	TextureId txtId;
	
	SetId Init(TextureId txtId)
	{
		self.txtId = txtId;
		return self;
	}
}