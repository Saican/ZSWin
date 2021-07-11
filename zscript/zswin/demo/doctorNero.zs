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
	private bool isTalking;
	
	override void PostBeginPlay()
	{
		isTalking = false;
	}
	
	/*
		This event ocurrs when the player presses the "use"
		key on the actor.
	
	*/
    override bool Used (Actor user)
    {
		// Check if the window is already initialized
		// Also don't bother if she's dead, oh yeah just shoot the zombie doc that's starring at you and not instantly attacking you.
		if (!isTalking && self.Health > 0)
		{
			A_StartSound("fem/sight");
			self.Init(null, true, true, "DocNero'sConvoWindow", PlayerPawn(user).PlayerNumber(), true);
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
			self.xLocation = 300;
		else
			self.xLocation = xLocation;
		if (yLocation == 0)
			self.yLocation = 300;
		else
			self.yLocation = yLocation;
		
		BackgroundType = BACKTYP_ZWin;
		BackgroundAlpha = 0.8;
		BackgroundStretch = false;
		AnimateBackground = false;
		
		BorderType = BORDERTYP_ZWin;
		BorderAlpha = 1;
		
		bool spawned;
		actor btn_close, btn_move, btn_scale, convo_Nero/*, txt_title, txt_greeting*/;
		// Close Button
		[spawned, btn_close] = AddControl("ZSWin_CloseButton");
		if (spawned && btn_close)
			ZSWin_CloseButton(btn_close).Init(self, Enabled, Show, "DocNeroCloseButton", PlayerClient, UiToggle,
											Width:25, Btn_xLocation:(self.Width - 25), ButtonScaleType:ZControl.SCALE_Horizontal,
											IdleTexture:"BCLSEIS", HighlightTexture:"BCLSEHS", ActiveTexture:"BCLSEAS");
		// Move Button
		[spawned, btn_move] = AddControl("ZSWin_MoveButton");
		if (spawned && btn_move)
			ZSWin_MoveButton(btn_move).Init(self, Enabled, Show, "DocNeroMoveButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 50), ButtonScaleType:ZControl.SCALE_Horizontal,
										IdleTexture:"BMOVEIS", HighlightTexture:"BMOVEHS", ActiveTexture:"BMOVEAS");
		// Scale Button
		[spawned, btn_scale] = AddControl("ZSWin_ScaleButton");
		if (spawned && btn_scale)
			ZSWin_ScaleButton(btn_scale).Init(self, Enabled, Show, "DocNeroScaleButton", PlayerClient, UiToggle,
										Width:25, Btn_xLocation:(self.Width - 25), Btn_yLocation:(self.Height - 25), ButtonScaleType:ZControl.SCALE_Both,
										IdleTexture:"BDRAGIS", HighlightTexture:"BDRAGHS", ActiveTexture:"BDRAGAS");

		// Dialog Control
		[spawned, convo_Nero] = AddControl("ZConversation");
		if (spawned && convo_Nero)
		{
			ZConversation(convo_Nero).Init(self, Enabled, Show, "DocNeroConversation", PlayerClient, UiToggle,
										bDefault_Buttons:true);
			Convo_NeroInit(convo_Nero);
		}
										
		return doctorNero(super.Init(ControlParent, Enabled, Show, Name, PlayerClient, UiToggle, ClipType));
	}

	/*
		This method encapsulates the process of
		initializing the ZConversation control.

		The control will create default sub-controls,
		as shown with the enabling of default buttons.

		But this creates empty sub-controls.  This works
		too, you just have to spend time, line by line,
		setting things up.

		This method allows the user to initialize their
		own sub-controls in the intended way controls
		are initialized.

		Note that we use the ZConversation.CreateSubControl("ControlName")
		method rather than the window's AddControl("ControlName").

		Furthermore we use the ZConversation's Initialization Requirements
		(the first set of variables that aren't defaulted) instead of 
		the window's.  This is due to the fact that the InitReqs have
		not been passed yet to the window, but have been passed to the
		ZConversation.  This is due to the order of operations in class
		initialization.

	*/
	private void Convo_NeroInit(actor a_convo_Nero)
	{
		ZConversation convo_Nero = ZConversation(a_convo_Nero);
		if (convo_Nero != null)
		{
			bool spawned;
			actor npcName, npcDialog;
			// NPC Name - Empty text (the actual string) is ok here since DialogPages get added below to fill the ZText.Text string.
			[spawned, npcName] = convo_Nero.CreateSubControl("ZText");
			if (spawned && npcName && convo_Nero.NPCName == null) 
				convo_Nero.NPCName = ZText(npcName).Init(convo_Nero, convo_Nero.Enabled, convo_Nero.Show, "DocNeroWindowTitle", "", convo_Nero.PlayerClient, false,
										TextWrap:ZText.TXTWRAP_NONE, TextFont:'bigfont', TextColor:'Gold',
										xLocation:5, yLocation:7);
			// NPC Dialog - Same thing here, the string for the actual text can be empty.
			[spawned, npcDialog] = convo_Nero.CreateSubControl("ZText");
			if (spawned && npcDialog)
				convo_Nero.NPCDialog = ZText(npcDialog).Init(convo_Nero, convo_Nero.Enabled, convo_Nero.Show, "DocNeroGreeting", "", convo_Nero.PlayerClient, false,
										TextWrap:ZText.TXTWRAP_Dynamic, TextFont:'newconsolefont', TextColor:'White',
										xLocation:5, yLocation:30);

			/*
				Dialog Pages - The ZScript Windows version of the Page Block in USDF

			*/
			convo_Nero.AddDialogPage(new("ZDialogPage").Init("dialog_Nero_Home", 				// Page name
																"Hi sweetie! I'm Dr. Nero!",	// NPC name
																//PageLink:"dialog_Page",		// Page link
																Dialog:"Hey what's up?",		// Dialog - this is a list that can be filtered
																//DialogChance:0,				// Dialog Chance - this works like a Decorate fail chance.
																//DropClassName:"Chaingun",		// Drop Class Name - string! Not CoversationID - that's not a thing here!
																//DropAmount:1,					// Drop Amount
																//CheckItem_A:,					// ZIfItem - USDF IfItem block equivalent
																//CheckItem_B:,					// ZIfItem - USDF IfItem block equivalent
																//CheckItem_C:,					// ZIfItem - USDF IfItem block equivalent
																PlayerChoice_A:new("ZChoice").Init("I need a crossbow",
																									YesMessage:"I don't have that, but take these plasma cells instead.",
																									GiveClassName:"Cell",
																									GiveItemCount:20,
																									Cost_A:new("ZCost").Init("Shell", 5)),
																PlayerChoice_B:new("ZChoice").Init("Not much"),
																//PlayerChoice_C:,				// ZChoice - USDF Choice block equivalent
																//PlayerChoice_D:,				// ZChoice - USDF Choice block equivalent
																PlayerChoice_E:new("ZChoice").Init("[Remain Silent]"),				
																FilterChoices:false));			// Filter Choices - allows for choices to be filtered by game skill


			/*
				Last step:  call ZConversation.Start()
				The conversation system is set up but isn't doing
				anything.  This method starts everything by pulling
				that first dialog page into the system.  From there
				the object will handle the rest!

			*/
			convo_Nero.Start();
		}
	}


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
		RenderStyle "Normal";
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