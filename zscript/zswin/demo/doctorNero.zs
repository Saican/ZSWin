/*
	doctorNero.zs
	
	The UI doctor is in, and she will see you now :P
	
	Amazingly there's female scientist zombies,
	and a red headed one to boot!  It's almost
	like my avatar was made just for me!
	
	This file borrows the female scientist code
	and adds in the ZScript Windows stuff.
	
	All credit to the original authors for
	the female scientist code, refer to
	documentation.

*/

class doctorNero : ZSWindow
{
	Default
	{
		obituary "%o was poisoned by a zombie scientist.";
		health 30;
		mass 90;
		speed 10;
		Radius 19;
		Height 52;
		painchance 200;
		seesound "fem/sight";
		painsound "fem/pain";
		deathsound "fem/death";
		activesound "fem/active";
		MONSTER;
		+FLOORCLIP
	}
	
	/*
		This event ocurrs when the player presses the "use"
		key on the actor.
	
	*/
	private bool isTalking;
	
	override void PostBeginPlay()
	{
		isTalking = false;
	}
	
    override bool Used (Actor user)
    {
		if (!isTalking && self.Health > 0)
		{
			A_StartSound("fem/sight");
			self.Init(null, true, true, "DocNero'sConvoWindow", 0, true);
			isTalking = true;
		}
		
		return false;
    }
	
	doctorNero Init(ZObjectBase ControlParent, bool Enabled, bool Show, string Name, int PlayerClient, bool UiToggle,
		CLIPTYP ClipType = CLIP_NONE, float xLocation = 0, float yLocation = 0, float Alpha = 1)
	{
		// Starting dimensions
		Width = 350;
		Height = 380;
		
		if (xLocation == 0)
			self.xLocation = 200;
		else
			self.xLocation = xLocation;
		if (yLocation == 0)
			self.yLocation = 200;
		else
			self.yLocation = yLocation;
		
		BackgroundType = BACKTYP_ZWin;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = false;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		bool spawned;
		actor btn_close, btn_move, btn_scale, txt_title, txt_greeting;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "DocNeroCloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "DocNeroMoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 70), Btn_yLocation:10, ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "DocNeroScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 35), Btn_yLocation:(self.Height - 35), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");										
		// Title
		[spawned, txt_title] = AddControl("ZText");
		if (spawned && txt_title)
			ZText(txt_title).Init(self, Enabled, Show, "DocNeroWindowTitle", "Hello, I'm Dr. Nero", PlayerClient, UiToggle,
								TextWrap:ZText.TXTWRAP_Dynamic,TextFont:'bigfont', TextColor:'Gold');
								
		// Greetings
		[spawned, txt_greeting] = AddControl("ZText");
		if (spawned && txt_greeting)
			ZText(txt_greeting).Init(self, Enabled, Show, "DocNeroGreeting",
			"Greetings, Slayer, and welcome to my UI testing laboratory.  Suprisingly the radiation emitted from the BFG9000 has mutagenic properties.  I used this to combine the robust, interactivity of a windowing interface, with that Imp I have caged up behind a force field.  Oh, since you're the Slayer and all, you probably want that BFG, you can access it from the console behind me.  I'll be here if you need anything, although I don't think this syringe is sterile so don't expect medical doctoring.",
			PlayerClient, UiToggle,
			TextWrap:ZText.TXTWRAP_Dynamic, TextFont:'newconsolefont', TextColor:'White',
			xLocation:5, yLocation:25);
										
		return doctorNero(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
	}

	States
	{
		Spawn:
			FSZS AB 10 A_Look();
			loop;
			See:
			FSZS AABB 4 A_Chase();
			TNT1 A 0 A_JumpIfCloser (128, "Squirt");
			FSZS CCDD 4 A_Chase();
			TNT1 A 0 A_JumpIfCloser (128, "Squirt");
			loop;
			Melee:
			FSZS E 4 A_FaceTarget();
			FSZS E 0 A_SkelWhoosh();
			FSZS F 8 A_CustomMeleeAttack (random (1, 5) *3, "knifehit", "skeleton/swing");
			FSZS F 0 A_SpawnProjectile("PoisonDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			goto See;
		Squirt:
			FSZS E 4 A_FaceTarget();
			FSZS F 0 A_PlaySound ("skeleton/swing");
			FSZS F 1 A_SpawnProjectile("PoisonDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("PoisonDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS F 1 A_SpawnProjectile("DummyDrop", 32, 8, 0, CMF_OFFSETPITCH, -12);
			FSZS D 4;
			goto See;
		Pain:
			FSZS G 3;
			FSZS G 3 A_Pain();
			goto See;
		Death:
			FSZS H 5;
			FSZS I 5 A_Scream();
			FSZS J 5 A_NoBlocking();
			FSZS K 5;
			FSZS L 5;
			FSZS M 5;
			FSZS N -1;
			stop;
		XDeath:
			FSZS O 5;
			FSZS P 5 A_XScream();
			FSZS Q 5 A_NoBlocking();
			FSZS RSTUV 5;
			FSZS W -1;
			stop;
			Raise:
			FSZS MLKJIH 5;
			goto See;
	}	
}

class PoisonDrop : actor
{
	Default
	{
		Radius 3;
		Height 3;
		Scale 0.5;
		Speed 10;
		FastSpeed 15;
		Damage 1;
		PoisonDamage 5;
		Alpha 1.0;
		bloodcolor "DarkGreen";
		Decal "BloodSplat";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
	}

	states
	{
		Spawn:
			POIS ABCD 4;
			goto Active;
		Active:
			POIS D 4;
			loop;
		Death:
			TNT1 A 0;
			stop;
	}
}

class DummyDrop : actor
{
	Default
	{
		Radius 3;
		Height 3;
		Scale 0.5;
		Speed 10;
		FastSpeed 15;
		Damage 0;
		Alpha 1;
		bloodcolor "DarkGreen";
		Decal "BloodSplat";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
	}

	states
	{
		Spawn:
			POIS ABCD 4;
			goto Active;
		Active:
			POIS D 4;
			loop;
		Death:
			TNT1 A 0;
			stop;
	}
}