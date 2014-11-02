class UT4DamagePoints extends Object;

static function int GetMaxDamage(UTPawn P)
{
	local int AmountDamagePoints, AmountHealth, AmountShield;
	local int NewHealth;

	AmountHealth = P.Health;
	AmountShield = P.ShieldBeltArmor;

	//AmountHealth = UTPawnOwner.Health;
	//AmountDamagePoints = 0; //AmountArmor;
	//AmountDamagePoints = AmountHealth;
	CalculatePossibleDamage(P, AmountHealth, AmountDamagePoints, P.VestArmor, 0.75);
	CalculatePossibleDamage(P, AmountHealth, AmountDamagePoints, P.ThighpadArmor, 0.5);
	CalculatePossibleDamage(P, AmountHealth, AmountDamagePoints, P.HelmetArmor, 0.5);

	AmountDamagePoints += AmountHealth+AmountShield;

	return AmountDamagePoints;
}

static function CalculatePossibleDamage(UTPawn P, out int Health, out int Damage, int CurrentShieldStrength, float AbsorptionRate)
{
	local int total, rest;
	local float maxabsorb;

	if (CurrentShieldStrength <= 0)
	{
		return;
	}

	total = (Health+CurrentShieldStrength)*AbsorptionRate;
	if (total > CurrentShieldStrength)
	{
		Damage += CurrentShieldStrength;
		return;
	}

	total = Health-1;
	if (total > 0)
	{
		rest = (float(total)/(1.0-AbsorptionRate))+1.0;
		Damage += rest-health;

		//maxabsorb = CurrentShieldStrength*AbsorptionRate;
		//rest = total/(1.0-AbsorptionRate);
		//rest = FMin(rest, maxabsorb);
		//Damage += FMin(rest, maxabsorb);

		//maxabsorb = CurrentShieldStrength*AbsorptionRate;
		//rest = (float(total)/(1.0-AbsorptionRate))+1.0;
		//rest = FMin(rest, maxabsorb);
		//Damage += FMax(rest-health, 0);
	}

	//Health = rest*AbsorptionRate;
}

Defaultproperties
{
}