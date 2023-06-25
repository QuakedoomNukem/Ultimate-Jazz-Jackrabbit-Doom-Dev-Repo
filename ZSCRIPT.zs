version "4.7.1" //minor regression to let the mod work under 4.8.0 or higher without warnings - ozy81

// AFADoomer

/*
	Shader controller base class

	This allows mappers to control shaders using the GiveInventory/TakeInventory
	ACS functions.

	Do not use this directly! Instead, make an actor class that inherits from
	ShaderControl. Set the ShaderControl.Shader property to the name of the
	shader to control. The shader must be defined in GLDEFS.

	To enable a shader, give 2 of the ShaderControl subclass item to the player.
	For example:

	GiveInventory("ShakeShaderControl", 2);

	To disable a shader, take 1 of the shader control item away so that the
	player only has 1 of said item. For example:

	TakeInventory("ShakeShaderControl", 1);
	or
	SetInventory("ShakeShaderControl", 1);

	Note that the latter requires you to define the SetInventory function in
	your ACS code.
*/

class ShaderControl : Inventory
{
	string ShaderToControl;
	property Shader: ShaderToControl;
	
	Default
	{
		Inventory.MaxAmount 0x7fffffff;
	}

	virtual ui void SetUniforms(PlayerInfo p, RenderEvent e) {}
}

class CustomShaderHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		ThinkerIterator shaderIter = ThinkerIterator.Create("ShaderControl");

		ShaderControl shaderControl;

		while (shaderControl = ShaderControl(shaderIter.Next()))
		{
			if (shaderControl.Owner && shaderControl.Owner == p.mo) {
				//Console.Printf("Shader: %s", shaderControl.ShaderToControl);
				if (shaderControl.amount >= 2)
				{
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "timer", gametic + e.FracTic);
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "amount", shaderControl.amount - 1);
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "alpha", shaderControl.alpha);
					shaderControl.SetUniforms(p, e);
					Shader.SetEnabled(p, shaderControl.ShaderToControl, true);
				}
				else
				{
					Shader.SetEnabled(p, shaderControl.ShaderToControl, false);
				}
			}
		}
	}
}

// Nash Muhandes
// Actor that does the bare minumum of ticking
// Use for static, non-interactive actors
//
// Derived from bits and pieces of p_mobj.cpp
class SimpleActor : Actor
{
	Vector2 floorxy;
	Vector3 oldpos;

	override void Tick()
	{
		if (IsFrozen()) { return; }

		Vector2 curfloorxy = (curSector.GetXOffset(sector.floor), curSector.GetYOffset(sector.floor)); // Hacky scroll check because MF8_INSCROLLSEC not externalized to ZScript?
		bool dotick = (curfloorxy != floorxy) || curSector.flags & sector.SECF_PUSH || (pos != oldpos);

		if (dotick) // Only run a full Tick once; or if we are on a carrying floor, pushers are enabled in the sector (wind), or if we moved by some external force
		{
			oldpos = pos;
			Super.Tick();
			floorxy = curfloorxy;
			return;
		}

		if (vel != (0, 0, 0)) // Apply velocity as required
		{
			SetXYZ(Vec3Offset(vel.X, vel.Y, vel.Z)); // Vec3Offset is portal-aware; use instead of just pos + vel, which is not
		}

		// Tick through actor states as normal
		if (tics == -1) { return; }
		else if (--tics <= 0)
		{
			SetState(CurState.NextState);
		}
	}
}

#include "ZScript/Flash.zs"
#include "ZScript/Menu.zs"
#include "ZScript/underwater.zs"