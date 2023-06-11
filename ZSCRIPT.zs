version "4.8.0"

// Nash Muhandes & AFADoomer
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