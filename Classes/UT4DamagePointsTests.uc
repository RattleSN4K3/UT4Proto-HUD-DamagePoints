class UT4DamagePointsTests extends Object;

Const MAX_RESULTS = 20;

var bool bTimerProcessing;

var Actor TimerActor;

var int TimedCounter;
var int TimedLoopI;
var int TimedLoopMax;
var UT4DamagePointsPawn TimedPawn;
var array<string> TimedResults;

var int TimedResultsCount;

var delegate<TestResults> TimedResultsCallback;

//**********************************************************************************
// Delegates
//**********************************************************************************

delegate static function ApplyLife(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1);
delegate static function bool TestResults(array<string> FailedTests, int FailedCount);

//**********************************************************************************
// Public functions
//**********************************************************************************

static function RunTests(PlayerController PC, optional bool bAbortOnFail)
{
	local array<string> FailedTests;
	local UT4DamagePointsPawn P;

	TestCase1Health(PC, true, FailedTests, P, bAbortOnFail);
	TestCase1Vest(PC, true, FailedTests, P, bAbortOnFail);
	TestCase1Thighs(PC, true, FailedTests, P, bAbortOnFail);
	TestCase1Helmet(PC, true, FailedTests, P, bAbortOnFail);
	TestCase1Shield(PC, true, FailedTests, P, bAbortOnFail);

	//TestCase2VestThighs(FailedTests, P, bAbortOnFail);
	//TestCase2VestHelmet();
	//TestCase2ThighsHelmet();

	//TestCase3ShieldVest();
	//TestCase3ShieldThighs();
	//TestCase3ShieldHelmet();

	//TestCase4ShieldVestThighs();
	//TestCase4ShieldVestHelmet();
	//TestCase4ShieldThighsHelmet();

	//TestCase5Mixed();

	FinishedTestCase(PC, "", FailedTests, FailedTests.Length);
}

//**********************************************************************************
// Tests
//**********************************************************************************

static function TestCase1Health(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health;

	if (!EnsureTestPawn(P))
		return;

	for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
	{
		if (!CheckDamagingForProper(P, FailedTests, ApplyLife_Health, i_health) && bAbortOnFail)
		{
			return;
		}
	}

	if (!NoResults) FinishedTestCase(PC, "Case-1-Health", FailedTests, FailedTests.Length);
}

static function TestCase1Vest(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health, i_vest;

	if (!EnsureTestPawn(P))
		return;

	for (i_vest=class'UTArmorPickup_Vest'.default.ShieldAmount; i_vest>=0; i_vest--)
	{
		for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
		{
			if (!CheckDamagingForProper(P, FailedTests, ApplyLife_Vest, i_health, i_vest) && bAbortOnFail)
			{
				return;
			}
		}
	}

	if (!NoResults) FinishedTestCase(PC, "Case-1-Vest", FailedTests, FailedTests.Length);
}

static function TestCase1Thighs(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health, i_thighs;

	if (!EnsureTestPawn(P))
		return;

	for (i_thighs=class'UTArmorPickup_Thighpads'.default.ShieldAmount; i_thighs>=0; i_thighs--)
	{
		for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
		{
			if (!CheckDamagingForProper(P, FailedTests, ApplyLife_Vest, i_health,, i_thighs) && bAbortOnFail)
			{
				return;
			}
		}
	}

	if (!NoResults) FinishedTestCase(PC, "Case-1-Thighs", FailedTests, FailedTests.Length);
}

static function TestCase1Helmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health, i_helmet;

	if (!EnsureTestPawn(P))
		return;

	for (i_helmet=class'UTArmorPickup_Helmet'.default.ShieldAmount; i_helmet>=0; i_helmet--)
	{
		for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
		{
			if (!CheckDamagingForProper(P, FailedTests, ApplyLife_Vest, i_health,,, i_helmet) && bAbortOnFail)
			{
				return;
			}
		}
	}

	if (!NoResults) FinishedTestCase(PC, "Case-1-Helmet", FailedTests, FailedTests.Length);
}

static function TestCase1Shield(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health, i_shield;

	if (!EnsureTestPawn(P))
		return;

	for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
	{
		for (i_shield=0; i_shield<=class'UTArmorPickup_ShieldBelt'.default.ShieldAmount; i_shield++)
		{
			if (!CheckDamagingForProper(P, FailedTests, ApplyLife_ShieldHealth, i_health,,,, i_shield) && bAbortOnFail)
			{
				return;
			}
		}
	}

	if (!NoResults) FinishedTestCase(PC, "Case-1-Shield", FailedTests, FailedTests.Length);
}

//static function TestCase2VestThighs(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail)
static function TestCase2VestThighs(Actor Other, delegate<TestResults> ResultsDelegate)
{
	local UT4DamagePointsPawn P;
	local UT4DamagePointsTests Tester;

	if (!EnsureTestPawn(P))
		return;

	Tester = new default.class;
	Tester.TimerActor = Other;

	Tester.TimedLoopI=1;
	Tester.TimedLoopMax=10; //P.SuperHealthMax;
	Tester.TimedPawn = P;

	Tester.TimedResultsCallback = ResultsDelegate;

	// start timer
	Other.SetTimer(0.01, true, 'TimerTestCase', Tester);

	//for (i_health=1; i_health<=P.SuperHealthMax; i_health++)
	//{
	//	TestCase2VestThighs_Inner(FailedTests, P, bAbortOnFail);
	//}
}

function TimerTestCase()
{
	if (!bTimerProcessing)
	{
		bTimerProcessing = true;

		TestCase2VestThighs_Outer(TimerActor, self, TimedLoopI, TimedResults, TimedPawn);
		TimedLoopI++;
		if (TimedLoopI > TimedLoopMax)
		{
			TimerActor.ClearTimer(GetFuncName(), self);
			TimedResultsCallback(TimedResults, TimedResultsCount);
		}
	}
}

static function TestCase2VestThighs_Outer(Actor Other, UT4DamagePointsTests OuterTester, int loopcounter, out array<string> FailedTests, out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local UT4DamagePointsTests Tester;

	//local int i_health, i_vest, i_thighs;

	if (PlayerController(OuterTester.TimerActor) != none)
	{
		PlayerController(OuterTester.TimerActor).ClientMessage("Case-2-Vest-Thighs:"@loopcounter$"/"$OuterTester.TimedLoopMax);
	}

	Tester = new default.class;
	Tester.TimerActor = Other;

	Tester.TimedLoopI=0;
	Tester.TimedLoopMax=class'UTArmorPickup_Vest'.default.ShieldAmount;
	Tester.TimedPawn = P;

	Tester.TimedCounter = loopcounter;

	Tester.TimedResultsCallback = OuterTester.TimedLoopEnd;

	// start timer
	Other.SetTimer(0.001, true, 'TimerTestCase2', Tester);

	

	//i_health = loopcounter;
	//for (i_vest=class'UTArmorPickup_Vest'.default.ShieldAmount; i_vest>=0; i_vest--)
	//{
	//	for (i_thighs=class'UTArmorPickup_Thighpads'.default.ShieldAmount; i_thighs>=0; i_thighs--)
	//	{
	//		if (!CheckDamagingForProper(P, FailedTests, ApplyLife_VestThighs, i_health, i_vest, i_thighs) && bAbortOnFail)
	//		{
	//			return;
	//		}
	//	}
	//}
}

function TimerTestCase2()
{
	if (!bTimerProcessing)
	{
		bTimerProcessing = true;

		TestCase2VestThighs_Inner(TimedCounter, TimedLoopI, TimedResults, TimedPawn);
		bTimerProcessing = false;

		TimedLoopI++;
		if (TimedLoopI > TimedLoopMax)
		{
			TimerActor.ClearTimer(GetFuncName(), self);
			TimedResultsCallback(TimedResults, TimedResults.Length);
		}
	}
}

function bool TimedLoopEnd(out array<string> FailedTests, int FailedCount)
{
	local int i;

	for (i=0; i<MAX_RESULTS && i<FailedTests.Length; i++)
	{
		TimedResults.AddItem(FailedTests[i]);
	}

	TimedResultsCount += FailedTests.Length;
	
	bTimerProcessing = false;
	return true;
}

static function TestCase2VestThighs_Inner(int outercounter, int innercounter, out array<string> FailedTests, out UT4DamagePointsPawn P, optional bool bAbortOnFail)
{
	local int i_health, i_vest, i_thighs;

	i_health = outercounter;
	i_vest = innercounter;
	for (i_thighs=class'UTArmorPickup_Thighpads'.default.ShieldAmount; i_thighs>=0; i_thighs--)
	{
		if (!CheckDamagingForProper(P, FailedTests, ApplyLife_VestThighs, i_health, i_vest, i_thighs) && bAbortOnFail)
		{
			return;
		}
	}
}


static function TestCase2VestHelmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);
static function TestCase2ThighsHelmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);

static function TestCase3ShieldVest(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);
static function TestCase3ShieldThighs(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);
static function TestCase3ShieldHelmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);

static function TestCase4ShieldVestThighs(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);
static function TestCase4ShieldVestHelmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);
static function TestCase4ShieldThighsHelmet(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);

static function TestCase5Mixed(PlayerController PC, optional bool NoResults, optional out array<string> FailedTests, optional out UT4DamagePointsPawn P, optional bool bAbortOnFail);

//**********************************************************************************
// Delegate callbacks
//**********************************************************************************

static function ApplyLife_Health(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;}
static function ApplyLife_Vest(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;}
static function ApplyLife_Thighs(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.ThighpadArmor = ArmorThighs;}
static function ApplyLife_Helmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorHelmet;}

static function ApplyLife_VestThighs(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;P.ThighpadArmor = ArmorThighs;}
static function ApplyLife_VestHelmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;P.HelmetArmor = ArmorHelmet;}
static function ApplyLife_ThighsHelmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.ThighpadArmor = ArmorThighs;P.VestArmor = ArmorHelmet;}

static function ApplyLife_ShieldHealth(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.ShieldBeltArmor = Shield;}
static function ApplyLife_ShieldVest(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;P.ShieldBeltArmor = Shield;}
static function ApplyLife_ShieldThighs(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.ThighpadArmor = ArmorThighs;P.ShieldBeltArmor = Shield;}
static function ApplyLife_ShieldHelmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorHelmet;P.ShieldBeltArmor = Shield;}

static function ApplyLife_ShieldVestThighs(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;P.ThighpadArmor = ArmorThighs;P.ShieldBeltArmor = Shield;}
static function ApplyLife_ShieldVestHelmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.VestArmor = ArmorVest;P.VestArmor = ArmorHelmet;P.ShieldBeltArmor = Shield;}
static function ApplyLife_ShieldThighsHelmet(UT4DamagePointsPawn P, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1) {P.Health = HP;P.ThighpadArmor = ArmorThighs;P.VestArmor = ArmorHelmet;P.ShieldBeltArmor = Shield;}

//**********************************************************************************
// Private functions
//**********************************************************************************

static function FinishedTestCase(PlayerController PC, string TestName, array<string> FailedTests, int FailedCount)
{
	local string s;

	if (FailedTests.Length == 0)
	{
		if (TestName != "")
			PC.ClientMessage("All "$TestName$" tests passed.");
		else
			PC.ClientMessage("All tests passed.");
	}
	else
	{
		PC.ClientMessage(FailedCount@"tests failed:"$(FailedTests.Length > MAX_RESULTS ? " (Selection of "$MAX_RESULTS$")" : ""));
		if (FailedTests.Length > MAX_RESULTS) FailedTests.Length = MAX_RESULTS;
		JoinArray(FailedTests, s, "\n");
		PC.ClientMessage(s);
	}
}

static function bool CheckDamagingForProper(UT4DamagePointsPawn P, out array<string> FailedTests, delegate<ApplyLife> ApplyLifeDelegate, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1)
{
	local int maxdamage;
	local string s;
	ApplyLifeDelegate(P, HP, ArmorVest, ArmorThighs, ArmorHelmet, Shield);
	maxdamage = class'UT4DamagePoints'.static.GetMaxDamage(P);

	// reduce max damage by 1 and check if still alive
	P.TakeDamage(maxdamage-1, none, P.Location, vect(1,0,0), class'DamageType');
	if (P.Health >= 1)
	{
		// still alive as expected, now deal the full maxdamage. Players should be killed
		ApplyLifeDelegate(P, HP, ArmorVest, ArmorThighs, ArmorHelmet, Shield);
		P.TakeDamage(maxdamage, none, P.Location, vect(1,0,0), class'DamageType');
		if (P.Health >= 1)
		{
			s = "Still on - ";
			s @= BuildLifeStatusString(maxdamage, true, HP, ArmorVest, ArmorThighs, ArmorHelmet, Shield);
			FailedTests.AddItem(s);
			return false;
		}
	}
	else
	{
		s = "Too early - ";
		s @= BuildLifeStatusString(maxdamage-1, false, HP, ArmorVest, ArmorThighs, ArmorHelmet, Shield);
		FailedTests.AddItem(s);
		return false;
	}

	return true;
}

static function string BuildLifeStatusString(int Damage, bool IsMaxDamage, int HP, optional float ArmorVest = -1, optional float ArmorThighs = -1, optional float ArmorHelmet = -1, optional float Shield = -1)
{
	local string s;

	s = "Inflicting damage:"@Damage$(IsMaxDamage ? " (Is max)" : "")$":";
	s @= HP$"HP";
	if (ArmorVest >= 0) s @= ArmorVest$"V";
	if (ArmorThighs >= 0) s @= ArmorThighs$"T";
	if (ArmorHelmet >= 0) s @= ArmorHelmet$"H";
	if (Shield >= 0) s @= Shield$"S";

	return s;
}

static function bool EnsureTestPawn(out UT4DamagePointsPawn TestPawn)
{
	local WorldInfo WorldInfo;
	if (TestPawn == none)
	{
		WorldInfo = class'Engine'.static.GetCurrentWorldInfo();
		TestPawn = WorldInfo.Spawn(class'UT4DamagePointsPawn',,, vect(0,0,0),,, true);
		if (TestPawn == none)
		{
			WorldInfo.Game.Broadcast(none, "Unable to spawn Pawn. Aborting test run!");
			return false;
		}
	}

	TestPawn.bTesting = true;
	return true;
}

DefaultProperties
{
}
