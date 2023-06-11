class FlashHandler : EventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		let enemy = e.Thing;
		if(enemy.bShootable)
		{
			enemy.GiveInventory("FlashItem",1);
		}
	}
}

class FlashItem : Inventory
{
	int flash;
	int storedhealth;
	int storedstyle;
	float storedalpha;
	
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		flash = 0;
		storedhealth = owner.Health;
	}
	
	override void DoEffect()
	{
	if(flash < 1)
		{
			storedstyle = owner.GetRenderStyle();
			storedalpha = owner.Alpha;
		}
	if(owner.Health > storedhealth)
		{
			storedhealth = owner.health;
		}
	if(owner.Health < storedhealth)
		{
			owner.A_SetRenderStyle(storedalpha, STYLE_STENCIL);
			owner.SetShade("White");
			owner.A_StartSound("HITFLSH",CHAN_BODY);
			owner.bBRIGHT = true;
			storedhealth = owner.health;
			flash = 1;
		}
	if(flash > 0){flash += 1; if(flash > 2){flash = 0; owner.bBRIGHT = false; owner.A_SetRenderStyle(storedalpha,storedstyle);}}
	if(health <= 0){flash = 0; owner.bBRIGHT = false; owner.A_SetRenderStyle(storedalpha,storedstyle); Destroy();}
	}

}