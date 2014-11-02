class UT4DamagePointsHUD extends UTHUD;

Const MAX_INT = 2147483647;
Const MAX_MODES = 2;

/** 0: Minimal; 1: Shield */
var() int CurrentHudMode;
var() bool MinimalBars;

//var() float HealthBGOffsetX;   //position of the health bg relative to overall lower left position
//var() float HealthBGOffsetY;
//var() float HealthIconX;	   //position of the health + icon relative to the overall left position
//var() float HealthIconY;
//var() float HealthTextX;	  //position of the health text relative to the overall left position
//var() float HealthTextY;

//var() float ArmorBGOffsetX;	//position of the armor bg relative to overall lower left position
//var() float ArmorBGOffsetY;
//var() float ArmorIconX;	   //position of the armor shield icon relative to the overall left position
//var() float ArmorIconY;
//var() float ArmorTextX;	   //position of the armor text relative to the overall left position
//var() float ArmorTextY;

var() float HealthScaleX;
var() float HealthScaleY;
var() float HealthIconScale;

var() float ArmorScaleX;
var() float ArmorScaleY;
var() float ArmorIconScale;

var() TextureCoordinates ShieldBGCoords;
var() float ShieldBGOffsetX;	//position of the armor bg relative to overall lower left position
var() float ShieldBGOffsetY;
var() float ShieldTextX;	   //position of the armor text relative to the overall left position
var() float ShieldTextY;
var() TextureCoordinates ShieldIconCoords;
var() float ShieldIconX;	   //position of the armor shield icon relative to the overall left position
var() float ShieldIconY;

var() float ShieldScaleX;
var() float ShieldScaleY;
var() float ShieldIconScale;

var int LastShieldAmount;
var float ShieldPulseTime;

var float DamagePulseTime;

var() byte HealthAlphaWithShield;

var() float MinimalDamageTextX;
var() float MinimalDamageTextY;
var() float MinimalDamageSize;

var() float MinimalHealthTextX;
var() float MinimalHealthTextY;
var() float MinimalHealthScaleX;
var() float MinimalHealthScaleY;
var() float MinimalHealthSize;

var() float MinimalArmorTextX;
var() float MinimalArmorTextY;
var() float MinimalArmorScaleX;
var() float MinimalArmorScaleY;
var() float MinimalArmorSize;

var() float MinimalShieldTextX;
var() float MinimalShieldTextY;
var() float MinimalShieldScaleX;
var() float MinimalShieldScaleY;
var() float MinimalShieldSize;

var() float MiniBarHealthY;
var() float MiniBarHeight;
var() float MiniBarDamageTextX;
var() float MiniBarDamageSize;
var() float MiniBarDamageOffest;

exec function HudMinimalBars()
{
	MinimalBars = !MinimalBars;
	PlayerOwner.ClientMessage("Minimal bars:"@MinimalBars);
}

exec function HudMode()
{
	CurrentHudMode = (CurrentHudMode + 1) % MAX_MODES;
	PlayerOwner.ClientMessage("Hud Mode:"@CurrentHudMode);
}

function DisplayPawnDoll()
{
	if (CurrentHudMode == 0)
		DisplayHudMinimal();
	else if (CurrentHudMode == 1)
		DisplayPawnDoll_NewShield();
}

function DisplayHudMinimal()
{
	local int AmountDamagePoints, AmountHealth, AmountArmor, AmountShield;

	AmountHealth = UTPawnOwner.Health;
	AmountArmor = UTPawnOwner.VestArmor + UTPawnOwner.ThighpadArmor + UTPawnOwner.HelmetArmor;
	AmountShield = UTPawnOwner.ShieldBeltArmor;

	AmountDamagePoints = class'UT4DamagePoints'.static.GetMaxDamage(UTPawnOwner);
	
	DrawPawnDoll();
	DrawMinimal(AmountDamagePoints, AmountHealth, AmountArmor, AmountShield);
}

function DrawPawnDoll()
{
	local vector2d POS;
	local float xl,yl;
	local float ArmorAmount;
	local linearcolor ScaledWhite, ScaledTeamHUDColor;

	// should doll be visible?	
	ArmorAmount = UTPawnOwner.ShieldBeltArmor + UTPawnOwner.VestArmor + UTPawnOwner.HelmetArmor + UTPawnOwner.ThighpadArmor;

	if ( (ArmorAmount > 0) || (UTPawnOwner.JumpbootCharge > 0) )
	{
		DollVisibility = FMin(DollVisibility + 3.0 * (WorldInfo.TimeSeconds - LastDollUpdate), 1.0);
	}
	else
	{
		DollVisibility = FMax(DollVisibility - 3.0 * (WorldInfo.TimeSeconds - LastDollUpdate), 0.0);
	}
	LastDollUpdate = WorldInfo.TimeSeconds;

	// handle the Pawn Doll
	if ( DollVisibility > 0.0 )
	{
		POS = ResolveHudPosition(DollPosition,216, 115);
		POS.X = POS.X + (DollVisibility - 1.0)*HealthOffsetX*ResolutionScale;

		ScaledWhite = LC_White;
		ScaledWhite.A = DollVisibility;
		ScaledTeamHUDColor = TeamHUDColor;
		ScaledTeamHUDColor.A = FMin(DollVisibility, TeamHUDColor.A);

		Canvas.DrawColor = WhiteColor;

		// The Background
		Canvas.SetPos(POS.X,POS.Y);
		Canvas.DrawColorizedTile(AltHudTexture, PawnDollBGCoords.UL * ResolutionScale, PawnDollBGCoords.VL * ResolutionScale, PawnDollBGCoords.U, PawnDollBGCoords.V, PawnDollBGCoords.UL, PawnDollBGCoords.VL, ScaledTeamHUDColor);

		// The ShieldBelt/Default Doll
		Canvas.SetPos(POS.X + (DollOffsetX * ResolutionScale), POS.Y + (DollOffsetY * ResolutionScale));
		if ( UTPawnOwner.ShieldBeltArmor > 0.0f )
		{
			DrawTileCentered(AltHudTexture, DollWidth * ResolutionScale, DollHeight * ResolutionScale, 71, 224, 56, 109,ScaledWhite);
		}
		else
		{
			DrawTileCentered(AltHudTexture, DollWidth * ResolutionScale, DollHeight * ResolutionScale, 4, 224, 56, 109, ScaledTeamHUDColor);
		}

		if ( UTPawnOwner.VestArmor > 0.0f )
		{
			Canvas.SetPos(POS.X + (VestX * ResolutionScale), POS.Y + (VestY * ResolutionScale));
			DrawTileCentered(AltHudTexture, VestWidth * ResolutionScale, VestHeight * ResolutionScale, 132, 220, 46, 28, ScaledWhite);
		}

		if (UTPawnOwner.ThighpadArmor > 0.0f )
		{
			Canvas.SetPos(POS.X + (ThighX * ResolutionScale), POS.Y + (ThighY * ResolutionScale));
			DrawTileCentered(AltHudTexture, ThighWidth * ResolutionScale, ThighHeight * ResolutionScale, 134, 263, 42, 28, ScaledWhite);
		}

		if (UTPawnOwner.HelmetArmor > 0.0f )
		{
			Canvas.SetPos(POS.X + (HelmetX * ResolutionScale), POS.Y + (HelmetY * ResolutionScale));
			DrawTileCentered(AltHudTexture, HelmetHeight * ResolutionScale, HelmetWidth * ResolutionScale, 193, 265, 22, 25, ScaledWhite);
		}

		if (UTPawnOwner.JumpBootCharge > 0 )
		{
			Canvas.SetPos(POS.X + BootX*ResolutionScale, POS.Y + BootY*ResolutionScale);
			DrawTileCentered(AltHudTexture, BootWidth * ResolutionScale, BootHeight * ResolutionScale, 222, 263, 54, 26, ScaledWhite);

			Canvas.Strlen(string(UTPawnOwner.JumpBootCharge),XL,YL);
			Canvas.SetPos(POS.X + (BootX-1)*ResolutionScale - 0.5*XL, POS.Y + (BootY+3)*ResolutionScale - 0.5*YL);
			Canvas.DrawTextClipped( UTPawnOwner.JumpBootCharge, false, 1.0, 1.0 );
		}
	}
}

function DrawMinimal(int InDP, int InHP, int InAP, int InSP)
{
	local vector2d POS;
	local int Health, CurrentValue, MaxValue;
	local string Amount;
	local float BarWidth, PercValue, BarHeight, BarTop;
	local Color C;

	Canvas.DrawColor = WhiteColor;

	// align health/armor widgets to the pawn doll
	POS = ResolveHudPosition(DollPosition,216, 115);
	POS.X = POS.X + DollVisibility*PawnDollBGCoords.UL*ResolutionScale;

	// Draw the Health Text
	Health = UTPawnOwner.Health;

	// Figure out if we should be pulsing
	if ( Health > LastHealth )
	{
		HealthPulseTime = WorldInfo.TimeSeconds;
	}
	LastHealth = Health;

	Amount = (Health > 0) ? ""$Health : "0";

	if (MinimalBars)
	{
		BarHeight = MiniBarHeight * ResolutionScale;
		BarWidth = MiniBarDamageTextX * ResolutionScale;
		BarTop = Canvas.ClipY - BarHeight;

		// health
		PercValue = float(Health)/float(UTPawnOwner.HealthMax);
		//BarWidth = 70 * ResolutionScale;
		DrawHealth( POS.X, BarTop, BarWidth * PercValue, BarWidth, BarHeight, Canvas);

		Canvas.DrawColor = WhiteColor;
		BarTop -= (MiniBarDamageSize+MiniBarDamageOffest) * ResolutionScale;
		DrawGlowText(""$InDP, POS.X + MiniBarDamageTextX * ResolutionScale, BarTop, MinimalDamageSize * ResolutionScale, DamagePulseTime, true);

		if (InAP > 0)
		{
			CurrentValue = UTPawnOwner.VestArmor+UTPawnOwner.ThighpadArmor+UTPawnOwner.HelmetArmor;
			MaxValue = 0;
			if (UTPawnOwner.VestArmor > 0) MaxValue += class'UTArmorPickup_Vest'.default.ShieldAmount;
			if (UTPawnOwner.ThighpadArmor > 0) MaxValue += class'UTArmorPickup_Thighpads'.default.ShieldAmount;
			if (UTPawnOwner.HelmetArmor > 0) MaxValue += class'UTArmorPickup_Helmet'.default.ShieldAmount;
			
			PercValue = float(CurrentValue)/float(MaxValue);

			C = Default.GrayColor;
			C.B = 16;
			C = 1.4*C; 
			if (PercValue < 0.4 )
			{
				C.G = 80;
			}

			BarTop -= BarHeight*0.5; // only half the size due to the glow text
			DrawBarGraph( POS.X, BarTop, BarWidth * PercValue, BarWidth, BarHeight, Canvas, C, default.GrayColor);
		}

		if (InSP > 0)
		{
			BarTop -= BarHeight;
			CurrentValue = UTPawnOwner.ShieldBeltArmor;
			MaxValue = class'UTArmorPickup_ShieldBelt'.default.ShieldAmount;
			
			PercValue = float(CurrentValue)/float(MaxValue);
			C = MakeColor(128,128,255, 255);
			
			DrawBarGraph(POS.X, BarTop, BarWidth * PercValue, BarWidth, BarHeight, Canvas, C, default.GrayColor);
			//DrawHealth( POS.X, BarTop, BarWidth * PercValue, BarWidth, BarHeight, Canvas);
			BarTop -= BarHeight;
		}
	}
	else
	{
		DrawGlowText(""$InDP, POS.X + MinimalDamageTextX * ResolutionScale, POS.Y + MinimalDamageTextY * ResolutionScale, MinimalDamageSize * ResolutionScale, DamagePulseTime, true);

		if (InAP > 0)
		{
			DrawGlowText(""$InAP, POS.X + MinimalArmorTextX * ResolutionScale, POS.Y + MinimalArmorTextY * ResolutionScale, MinimalArmorSize * ResolutionScale, ArmorPulseTime, true);
			DrawGlowText(Amount, POS.X + MinimalHealthTextX * ResolutionScale, POS.Y + MinimalHealthTextY * ResolutionScale, MinimalHealthSize * ResolutionScale, HealthPulseTime, true);
		}

		if (InSP > 0)
		{
			DrawGlowText(""$InSP, POS.X + MinimalShieldTextX * ResolutionScale, POS.Y + MinimalShieldTextY * ResolutionScale, MinimalShieldSize * ResolutionScale, HealthPulseTime, true);
		}
	}
}

function DisplayPawnDoll_NewShield()
{
	local vector2d POS;
	local string Amount;
	local int Health;
	local float ArmorAmount, ShieldAmount;
	local linearcolor ScaledWhite;
	local linearcolor ProtectedHUDColor, ShieldHUDColor;

	//shield
	ShieldAmount = UTPawnOwner.ShieldBeltArmor;
	if (ShieldAmount > 0)
		ProtectedHUDColor = DMLinearColor;
	else
		ProtectedHUDColor = TeamHUDColor;
	ShieldHUDColor = (WorldInfo.GRI != none && WorldInfo.GRI.Teams.Length > 1) ? TeamHUDColor : GoldLinearColor;
	
	// should doll be visible?	
	DrawPawnDoll();

	POS = ResolveHudPosition(DollPosition,216, 115);
	POS.X = POS.X + (DollVisibility - 1.0)*HealthOffsetX*ResolutionScale;
	Canvas.DrawColor = WhiteColor;

	ScaledWhite = LC_White;
	ScaledWhite.A = DollVisibility;

	// Next, the health and Armor widgets
	ArmorAmount = UTPawnOwner.VestArmor + UTPawnOwner.HelmetArmor + UTPawnOwner.ThighpadArmor;

   	// Draw the Health Background
	Canvas.SetPos(POS.X + HealthBGOffsetX * ResolutionScale * HealthScaleX, POS.Y + HealthBGOffsetY * ResolutionScale * HealthScaleY);
	
	Canvas.DrawColorizedTile(AltHudTexture, HealthBGCoords.UL * ResolutionScale * HealthScaleX, HealthBGCoords.VL * ResolutionScale * HealthScaleY, HealthBGCoords.U, HealthBGCoords.V, HealthBGCoords.UL, HealthBGCoords.VL, ProtectedHUDColor);
	Canvas.DrawColor = WhiteColor;
	if (ShieldAmount > 0) Canvas.DrawColor.A = HealthAlphaWithShield;

	// Draw the Health Text
	Health = UTPawnOwner.Health;

	// Figure out if we should be pulsing
	if ( Health > LastHealth )
	{
		HealthPulseTime = WorldInfo.TimeSeconds;
	}
	LastHealth = Health;

	Amount = (Health > 0) ? ""$Health : "0";
	DrawGlowText(Amount, POS.X + HealthTextX * ResolutionScale, POS.Y + HealthTextY * ResolutionScale, 60 * ResolutionScale * HealthScaleY, HealthPulseTime,true);

	// restore color
	Canvas.DrawColor = WhiteColor;

	// Draw the Health Icon
	Canvas.SetPos(POS.X + HealthIconX * ResolutionScale, POS.Y + HealthIconY * ResolutionScale);
	DrawTileCentered(AltHudTexture, 42 * ResolutionScale * HealthIconScale , 30 * ResolutionScale * HealthIconScale, 216, 102, 56, 40, LC_White);

	// Only Draw the Armor if there is any
	// TODO - Add fading
	if ( ArmorAmount > 0 )
	{
		if (ArmorAmount > LastArmorAmount)
		{
			ArmorPulseTime = WorldInfo.TimeSeconds;
		}
		LastArmorAmount = ArmorAmount;

		// set color
		if (ShieldAmount > 0) Canvas.DrawColor.A = HealthAlphaWithShield;

    	// Draw the Armor Background
		Canvas.SetPos(POS.X + ArmorBGOffsetX * ResolutionScale,POS.Y + ArmorBGOffsetY * ResolutionScale);
		Canvas.DrawColorizedTile(AltHudTexture, ArmorBGCoords.UL * ResolutionScale * ArmorScaleX, ArmorBGCoords.VL * ResolutionScale * ArmorScaleY, ArmorBGCoords.U, ArmorBGCoords.V, ArmorBGCoords.UL, ArmorBGCoords.VL, ProtectedHUDColor);
		//Canvas.DrawColorizedTile(AltHudTexture, ArmorBGCoords.UL * ResolutionScale, ArmorBGCoords.VL * ResolutionScale, ArmorBGCoords.U, ArmorBGCoords.V, ArmorBGCoords.UL, ArmorBGCoords.VL, ScaledTeamHudColor);
		//Canvas.DrawColor = WhiteColor;
		//Canvas.DrawColor.A = 255.0 * DollVisibility;

		// Draw the Armor Text
		DrawGlowText(""$INT(ArmorAmount), POS.X + ArmorTextX * ResolutionScale * ArmorScaleX, POS.Y + ArmorTextY * ResolutionScale * ArmorScaleY, 45 * ResolutionScale * ArmorScaleY, ArmorPulseTime,true);

		// restore color
		Canvas.DrawColor = WhiteColor;

		// Draw the Armor Icon
		Canvas.SetPos(POS.X + ArmorIconX * ResolutionScale, POS.Y + ArmorIconY * ResolutionScale);
		DrawTileCentered(AltHudTexture, (33 * ResolutionScale) * ArmorIconScale, (24 * ResolutionScale) * ArmorIconScale, 225, 68, 42, 32, ScaledWhite);
	}

	// Only Draw the Shield if there is any
	// TODO - Add fading
	if ( ShieldAmount > 0 )
	{
		if (ShieldAmount > LastShieldAmount)
		{
			ShieldPulseTime = WorldInfo.TimeSeconds;
		}
		LastShieldAmount = ShieldAmount;

    	// set color
		if (ShieldAmount > 0) Canvas.DrawColor.A = HealthAlphaWithShield;

		// Draw the Shield Background
		Canvas.SetPos(POS.X + ShieldBGOffsetX * ResolutionScale,POS.Y + ShieldBGOffsetY * ResolutionScale);
		Canvas.DrawColorizedTile(AltHudTexture, ArmorBGCoords.UL * ResolutionScale * ShieldScaleX, ArmorBGCoords.VL * ResolutionScale * ShieldScaleY, ArmorBGCoords.U, ArmorBGCoords.V, ArmorBGCoords.UL, ArmorBGCoords.VL, ShieldHUDColor);
		Canvas.DrawColor = WhiteColor;
		Canvas.DrawColor.A = 255.0 * DollVisibility;

		// Draw the Shield Text
		DrawGlowText(""$INT(ShieldAmount), POS.X + ShieldTextX * ResolutionScale, POS.Y + ShieldTextY * ResolutionScale, 45 * ResolutionScale * ShieldScaleY, ShieldPulseTime,true);

		// restore color
		Canvas.DrawColor = WhiteColor;

		// Draw the Shield Icon
		Canvas.SetPos(POS.X + ShieldIconX * ResolutionScale, POS.Y + ShieldIconY * ResolutionScale);
		DrawTileCentered(IconHudTexture, (24 * ResolutionScale) * ShieldIconScale, (24 * ResolutionScale) * ShieldIconScale, ShieldIconCoords.U, ShieldIconCoords.V, ShieldIconCoords.UL, ShieldIconCoords.VL, ScaledWhite);
	}
}

DefaultProperties
{
	CurrentHudMode=0
	MinimalBars=true

	HealthOffsetX=65
	HealthBGOffsetX=64
	HealthBGOffsetY=86
	HealthIconX=88
	HealthIconY=92
	HealthTextX=176
	HealthTextY=65

	HealthScaleX=0.97
	HealthScaleY=0.8
	HealthIconScale=1.0

	ArmorBGOffsetX=64
	ArmorBGOffsetY=35
	ArmorIconX=87
	ArmorIconY=56
	ArmorTextX=147
	ArmorTextY=33

	ArmorScaleX=1.2
	ArmorScaleY=1.0
	ArmorIconScale=1.0

	ShieldBGOffsetX=65
	ShieldBGOffsetY=-4
	ShieldTextX=180
	ShieldTextY=-5

	ShieldIconCoords=(U=669,V=266,UL=75,VL=75)
	ShieldIconX=86
	ShieldIconY=20

	ShieldScaleX=1.2
	ShieldScaleY=1.1
	ShieldIconScale=1.0

	HealthAlphaWithShield=64


	MinimalHealthTextX=140
	MinimalHealthTextY=90
	MinimalHealthScaleX=1.0
	MinimalHealthScaleY=1.0
	MinimalHealthSize=28
	
	MinimalArmorTextX=140
	MinimalArmorTextY=71
	MinimalArmorSize=28

	MinimalShieldTextX=140
	MinimalShieldTextY=2
	MinimalShieldSize=90

	MinimalDamageSize=60
	MinimalDamageTextX=98	
	MinimalDamageTextY=65

	MiniBarHealthY=0
	MiniBarHeight=16
	MiniBarDamageTextX=98
	MiniBarDamageSize=60
	MiniBarDamageOffest=-8
}
