/*
	ZSWin_Button.txt
	
	Button Class

*/

class ZButton : ZControl_Base
{
	enum BTNTYPE
	{
		standard, 	// single texture with or without border
		zbtn,		// three textures, no border
		radio,
		check,
	};
	BTNTYPE Type;
	
	int Width, Height;
	
	float xLocation,
		yLocation;
		
	ZText Text;
	ZShape Border;  // only square boxes supported
	bool Stretch;
	Array<TextureSet> btnTextures;
	
	enum BTNSTATE
	{
		idle,			// no interaction
		highlight,		// mouse over
		active,			// clicked on (mouse down, waiting for mouse up)
		doaction,			// was active, now mouse up received, action can be pushed
	};
	BTNSTATE State;
	
	// Constructor defaults to a standard button, which defaults to a thin border - only name and text are required
	ZButton Init (string Name, string btnText,
				// Button Internals
				bool Enabled = true, BTNTYPE Type = standard, int Width = 100, int Height = 25, float btn_xLocation = 0, float btn_yLocation = 0, float btn_Alpha = 1,
				// Background and border - width and height are used to set border dimensions
				bool Stretch = false, string idleTextureName = "", string highlightTextureName = "", string activeTextureName = "",
				SHAPETYPE borderType = box, color borderColor = 0xffffff, float borderAlpha = 1, float borderThickness = 1,
				// Text
				int CRColor = Font.CR_White, TEXTALIGN Alignment = center, name fontName = 'newsmallfont', float txt_xLocation = 0, float txt_yLocation = 0, float txt_Alpha = 1)
	{
		self.Name = Name;
		self.Enabled = Enabled;
		self.Type = Type;
		// Width/Height is overridden by the texture dimensions if the type is radio or check
		self.Width = Width;
		self.Height = Height;
		self.xLocation = btn_xLocation;
		self.yLocation = btn_yLocation;
		self.Alpha = btn_Alpha;
		self.Stretch = Stretch;
		self.State = idle;
		backgroundInit(idleTextureName, highlightTextureName, activeTextureName);
		Border = new("ZShape").Init(string.Format("%s%s", self.Name, "_border"), self.Enabled, borderType == box || borderType == thickbox ? borderType : box, borderColor, self.xLocation, self.yLocation, self.Width, self.Height, borderAlpha, borderThickness);
		Text = new("ZText").Init(string.Format("%s%s", self.Name, "_txt"), self.Enabled, btnText, CRColor, ZText.wrap, self.Width, Alignment, fontName, txt_xLocation, txt_yLocation, txt_Alpha);
		return self;
	}
	
	private void backgroundInit(string idleTextureName, string highlightTextureName, string activeTextureName)
	{
		TextureSet newSet = new("TextureSet");
		TextureId idleId, highId, activeId;
		
		switch (Type)
		{
			case standard:
				if (idleTextureName == "" || highlightTextureName == "" || activeTextureName == "")
				{
					switch(gameinfo.gametype)
					{
						case GAME_Doom:
							idleId = highId = TexMan.CheckForTexture("ICKWALL1", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("ICKWALL2", TexMan.TYPE_ANY);
							break;
						case GAME_Heretic:
						case GAME_Hexen:
							idleId = highId = TexMan.CheckForTexture("GRNBLOK1", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("BRWNRCKS", TexMan.TYPE_ANY);
							break;
						case GAME_Strife:
							idleId = highId = TexMan.CheckForTexture("BRKBRN02", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("BRKGRY01", TexMan.TYPE_ANY);
							break;
						case GAME_Chex:
							idleId = highId = TexMan.CheckForTexture("GRAY4", TexMan.TYPE_ANY);
							activeId = TexMan.CheckForTexture("COMPUTE1", TexMan.TYPE_ANY);
							break;
					}
					
					if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
					{
						newSet.dar_TextureSet.Push(new("SetId").Init(idleId));
						newSet.dar_TextureSet.Push(new("SetId").Init(highId));
						newSet.dar_TextureSet.Push(new("SetId").Init(activeId));
					}
					else
						newSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
					btnTextures.Push(newSet);
				}
				else
				{
					idleId = TexMan.CheckForTexture(idleTextureName, TexMan.TYPE_ANY);
					highId = TexMan.CheckForTexture(highlightTextureName, TexMan.TYPE_ANY);
					activeId = TexMan.CheckForTexture(activeTextureName, TexMan.TYPE_ANY);
					if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
					{
						newSet.dar_TextureSet.Push(new("SetId").Init(idleId));
						newSet.dar_TextureSet.Push(new("SetId").Init(highId));
						newSet.dar_TextureSet.Push(new("SetId").Init(activeId));
					}
					else
						newSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
					
					btnTextures.Push(newSet);
				}
				break;
			case zbtn:
				TextureSet idleSet = new("TextureSet");
				TextureSet highSet = new("TextureSet");
				TextureSet activeSet = new("TextureSet");
				
				TextureId idleLeft = TexMan.CheckForTexture("BSIDIL", TexMan.TYPE_ANY);
				TextureId idleMiddle = TexMan.CheckForTexture("BMIDI", TexMan.TYPE_ANY);
				TextureId idleRight = TexMan.CheckForTexture("BSIDIR", TexMan.TYPE_ANY);
				
				TextureId highLeft = TexMan.CheckForTexture("BSIDHL", TexMan.TYPE_ANY);
				TextureId highMiddle = TexMan.CheckForTexture("BMIDH", TexMan.TYPE_ANY);
				TextureId highRight = TexMan.CheckForTexture("BSIDHR", TexMan.TYPE_ANY);
		
				TextureId activeLeft = TexMan.CheckForTexture("BSIDAL", TexMan.TYPE_ANY);
				TextureId activeMiddle = TexMan.CheckForTexture("BMIDA", TexMan.TYPE_ANY);
				TextureId activeRight = TexMan.CheckForTexture("BSIDAR", TexMan.TYPE_ANY);
				
				bool validIdle = false, validHighlight = false, validActive = false;
				if (idleLeft.IsValid() && idleMiddle.IsValid() && idleRight.IsValid())
				{
					idleSet.dar_TextureSet.Push(new("SetId").Init(idleLeft));
					idleSet.dar_TextureSet.Push(new("SetId").Init(idleMiddle));
					idleSet.dar_TextureSet.Push(new("SetId").Init(idleRight));
					validIdle = true;
				}
				else
					idleSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (highLeft.IsValid() && highMiddle.IsValid() && highRight.IsValid())
				{
					highSet.dar_TextureSet.Push(new("SetId").Init(highLeft));
					highSet.dar_TextureSet.Push(new("SetId").Init(highMiddle));
					highSet.dar_TextureSet.Push(new("SetId").Init(highRight));					
					validHighlight = true;
				}
				else
					highSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (activeLeft.IsValid() && activeMiddle.IsValid() && activeRight.IsValid())
				{
					activeSet.dar_TextureSet.Push(new("SetId").Init(activeLeft));
					activeSet.dar_TextureSet.Push(new("SetId").Init(activeMiddle));
					activeSet.dar_TextureSet.Push(new("SetId").Init(activeRight));					
					validActive = true;
				}
				else
					activeSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				if (validIdle && validHighlight && validActive)
				{
					// Height is overwriten here to the size of the idle texture if all textures are accounted for
					let twh = TexMan.GetScaledSize(idleLeft);
					Height = twh.y;
				}
				
				btnTextures.Push(idleSet);
				btnTextures.Push(highSet);
				btnTextures.Push(activeSet);
				break;
			case radio:
				idleId = TexMan.CheckForTexture("BRDCKIS", TexMan.TYPE_ANY);
				highId = TexMan.CheckForTexture("BRDCKHS", TexMan.TYPE_ANY);
				activeId = TexMan.CheckForTexture("BRDIOAS", TexMan.TYPE_ANY);
				
				if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
				{
					newSet.dar_TextureSet.Push(new("SetId").Init(idleId));
					newSet.dar_TextureSet.Push(new("SetId").Init(highId));
					newSet.dar_TextureSet.Push(new("SetId").Init(activeId));
					
					// Width and Height is overwriten here to the size of the idle texture
					// - it's assumed all three textures are the same size
					let twh = TexMan.GetScaledSize(idleId);
					Width = twh.x;
					Height = twh.y;
				}
				else
					newSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				btnTextures.Push(newSet);
				break;
			case check:
				idleId = TexMan.CheckForTexture("BRDCKIS", TexMan.TYPE_ANY);
				highId = TexMan.CheckForTexture("BRDCKHS", TexMan.TYPE_ANY);
				activeId = TexMan.CheckForTexture("BCHCKAS", TexMan.TYPE_ANY);
				
				if (idleId.IsValid() && highId.IsValid() && activeId.IsValid())
				{
					newSet.dar_TextureSet.Push(new("SetId").Init(idleId));
					newSet.dar_TextureSet.Push(new("SetId").Init(highId));
					newSet.dar_TextureSet.Push(new("SetId").Init(activeId));
					
					// Width and Height is overwriten here to the size of the idle texture
					// - it's assumed all three textures are the same size
					let twh = TexMan.GetScaledSize(idleId);
					Width = twh.x;
					Height = twh.y;
				}
				else
					newSet.dar_TextureSet.Push(new("SetId").Init(TexMan.CheckForTexture("TGRAY", TexMan.TYPE_ANY)));
				
				btnTextures.Push(newSet);
				break;
		}
	}
	
}