class UT4DamagePointsPawn extends UTPawn;

var bool bTesting;
var int TestShotCount;
var bool bTestProcessing;

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if (bTesting)
		return false;

	ClientMessage("Shots neeed:"@TestShotCount);
	return super.Died(Killer, damageType, HitLocation);
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	if (bTesting)
		return;

	super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo);
}

exec function TestSetHealth(int InHealth, int InVest, int InThigh, int InHelmt, int InShield)
{
	Health = Min(SuperHealthMax, InHealth);
	ShieldBeltArmor = InShield;
	VestArmor = InVest;
	ThighpadArmor = InThigh;
	HelmetArmor = InHelmt;
}

exec function TestSetBoots(int Charges)
{
	ServerTestSetBoots(Charges);
}

server reliable function ServerTestSetBoots(int Charges)
{
	local Inventory Inv;
	
	Inv = FindInventoryType(class'UTJumpBoots', true);
	if (Inv == none && Charges > 0)
	{
		Inv = Spawn(class'UTJumpBoots');
		UTJumpBoots(Inv).Charges = Charges;
		InvManager.AddInventory(inv);
	}
	else if (Inv != none)
	{
		if (Charges > 0)
		{
			UTJumpBoots(Inv).Charges = Charges;
			if (WorldInfo.NetMode != NM_DedicatedServer) UTJumpBoots(Inv).ReplicatedEvent('Charges');
		}
		else
		{
			InvManager.RemoveFromInventory(Inv);
		}
	}
}

exec function TestKill()
{
	ServerTestKill();
}

server reliable function ServerTestKill()
{
	if (bTestProcessing)
		return;

	bTestProcessing = true;
	while(Health > 0 && !bPlayedDeath)
	{
		TestShotCount += 1;
		ServerTestShot();
	}

	bTestProcessing = false;
}

exec function TestShot()
{
	ServerTestShot();
}

exec function TestRocket()
{
	ServerTestRocket();
}

exec function TestDamage(int damage)
{
	ServerTestDamage(damage);
}

server reliable function ServerTestShot()
{
	TakeDamage( class'UTWeap_Enforcer'.default.InstantHitDamage[0], none,
					Location, class'UTWeap_Enforcer'.default.InstantHitMomentum[0]*vect(1,0,0),
					class'UTWeap_Enforcer'.default.InstantHitDamageTypes[0]);
}

server reliable function ServerTestDamage(int damage)
{
	TakeDamage(damage, none, Location, vect(1,0,0), class'UTDamageType');
}

server reliable function ServerTestRocket()
{
	TakeDamage(class'UTProj_Rocket'.default.Damage, none, Location, vect(1,0,0), class'UTDmgType_Rocket');
}

exec function TestAddHP(int HP)
{
	ServerTestAddHP(HP);
}

server reliable function ServerTestAddHP(int HP)
{
	Health += Min(Health+HP, SuperHealthMax);
}

exec function TestAddArmor(int type, int AP)
{
	ServerTestAddArmor(type, AP);
}

server reliable function ServerTestAddArmor(int type, int AP)
{
	switch (type)
	{
	case 0:
		VestArmor = FMin(class'UTArmorPickup_Vest'.default.ShieldAmount, VestArmor+AP);
		break;
	case 1:
		ThighpadArmor = FMin(class'UTArmorPickup_Vest'.default.ShieldAmount, ThighpadArmor+AP);
		break;
	case 2:
		HelmetArmor = FMin(class'UTArmorPickup_Vest'.default.ShieldAmount, HelmetArmor+AP);
		break;
	case 3:
		ShieldBeltArmor = FMin(class'UTArmorPickup_ShieldBelt'.default.ShieldAmount, ShieldBeltArmor+AP);
		break;
	}
}

exec function TestRunTests(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.RunTests(PlayerController(Controller));
}

exec function RunCase1Health(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase1Health(PlayerController(Controller));
}

exec function RunCase1Vest(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase1Vest(PlayerController(Controller));
}

exec function RunCase1Thighs(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase1Thighs(PlayerController(Controller));
}

exec function RunCase1Helmet(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase1Helmet(PlayerController(Controller));
}

exec function RunCase1Shield(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase1Shield(PlayerController(Controller));
}

exec function RunCase2VestThighs(optional bool bAbortOnFail)
{
	class'UT4DamagePointsTests'.static.TestCase2VestThighs(Controller, FinishedCase2VestThighs);
}

function bool FinishedCase2VestThighs(array<string> FailedTests, int FailedCount)
{
	local string s;

	if (FailedTests.Length == 0)
	{
		PlayerController(Controller).ClientMessage("All Case-2-Vest-Thighs tests passed.");
		return true;
	}
	else
	{
		PlayerController(Controller).ClientMessage(FailedCount@"tests failed:"$(FailedTests.Length > 20 ? " (Selection of 20)" : ""));
		if (FailedTests.Length > 40) FailedTests.Length = 40;
		JoinArray(FailedTests, s, "\n");
		PlayerController(Controller).ClientMessage(s);
		return false;
	}
}

defaultproperties
{
}