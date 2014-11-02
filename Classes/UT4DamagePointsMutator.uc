class UT4DamagePointsMutator extends UTMutator;

//**********************************************************************************
// Inherited funtions
//**********************************************************************************

function InitMutator(string Options, out string ErrorMessage)
{
	super.InitMutator(Options, ErrorMessage);

	// early out
	if (WorldInfo.Game == none)
		return;

	// Replace Pawn and HUD classes
	WorldInfo.Game.HUDType = class'UT4DamagePointsHUD';
	WorldInfo.Game.DefaultPawnClass = class'UT4DamagePointsPawn';
}

DefaultProperties
{
}
