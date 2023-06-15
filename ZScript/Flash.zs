/*
 * Copyright (c) 2022-2023 AFADoomer, QuakeDoomNukem, RichardDS90, Ozymandias81
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

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