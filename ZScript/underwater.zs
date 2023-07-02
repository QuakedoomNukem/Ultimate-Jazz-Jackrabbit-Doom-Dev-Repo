/*
 * Copyright (c) 2018-2020 AFADoomer
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

class JJWaterHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	
	{
		// set the player's timer up correctly (more-than-1-tick precision)
		PlayerInfo p = players[consoleplayer];
		Shader.SetUniform1f(p, "watershader", "timer", gametic + e.FracTic);

		if (p.mo.waterlevel >= 3) {
			Shader.SetEnabled(p, "watershader", true);
			Shader.SetEnabled(p, "waterzoomshader", true);
			double effectSize = CVar.GetCVar("jj_uweffectsize", p).GetFloat();
			Shader.SetUniform1f(p, "watershader", "waterFactor", effectSize);
			Shader.SetUniform1f(p, "waterzoomshader", "zoomFactor", 1 - (effectSize * 2));
		}
		else {
			Shader.SetEnabled(p, "watershader", false);
			Shader.SetEnabled(p, "waterzoomshader", false);
		}
	}
}

class JJPlayerBubble : ParticleBase
{
	int ticker;
	
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Alpha 0.9;
		RenderStyle "Add";
		Projectile;
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOCLIP
	}
	
	States
	{
	Spawn:
		SBUB A 1;
		Loop;
	Death:
		"####" "#" 1;
		Stop;
	}

	override void Tick()
	{
		if (!waterlevel) { Destroy(); } // Disappear at water surface
		else if (pos.z + height == ceilingz) // Fade out on ceilings
		{
			ticker++;

			if (ticker > 70)
			{
				alpha -= 0.01;
				if (alpha <= 0) { Destroy(); }
			}
		}

		if (Random() < 32) // Randomly move slightly on x/y axis
		{
			angle = Random(0, 360);
			vel.xy = RotateVector((-0.1, 0), angle);
		}

		Super.Tick();
	}
	
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		vel.z += FRandom(1.0, 3.0);
	}
}

//Player related
class JJ_Underwater : CustomInventory
{
	int underwatertimer;
	int oldwaterlevel;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	void DoWaterEffects()
	{
		if (underwatertimer > 0) { underwatertimer--; }

		// Spawn bubbles
		if (level.time % 7 == 0)
		{
			if(owner.waterlevel >= 3) //check also stored cvar for custom tweaks
			{
				Actor bubble = Spawn("JJPlayerBubble", owner.pos + (Random(4, 8), 0, Random(48, 52)));
				if (bubble) { bubble.angle = Random(0, 359); }
			}
		}

		oldwaterlevel = owner.waterlevel;
	}

	override void Tick(void)
	{
		if (Owner && level.time % 5 == 0) // This doesn't need to run every tick...
		{
			DoWaterEffects();
		}

		Super.Tick();
	}

	States
	{
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0
			{
				return true;
			}
			Stop;
	}
}