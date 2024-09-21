// Partial use of this file to fix path corners

/*
float(entity targ) infront =
{
	vector vec;
	float dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
}
*/

/*
float() FindTarget =
{
	local entity	client;
	local float		r;

	// (spawnflags & 3) unhacked by lunaran since I actually want to use spawnflag 2 for something
	// apparently all the mega-enforcers in lunsp1 were ambush because of this ... oops
	if ( sight_entity_time >= time - 0.1 && ( !(self.spawnflags & SPAWN_AMBUSH ) ) )
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return FALSE;
	}
	else
	{
		// to avoid spending too much time, only check a single client (or fakeclient)
		// this means multiplayer games have slightly slower noticing monsters
		client = checkclient();
		if (!client)
			return FALSE;	// no check entities in PVS
	}

	if (client == self.enemy)
		return FALSE;
		
	if (!FilterTarget(client))
		return FALSE;		
	if (client.classname != "player" && !FilterTarget(client.enemy))
		return FALSE;	// don't wake up other monsters in notarget mode
	
	if (!visible (client))
		return FALSE;

	r = range(client);
	
	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront(client))
			return FALSE;
	}
	else if (r == RANGE_MID || r == RANGE_FAR)
	{
		if ( !infront(client) )
			return FALSE;
	}
	
	// the only two things that alert monsters when invisible besides damage:
	// - firing a weapon
	// - bumping into a dog
	if (has_invis(client))
	{
		if (!(r == RANGE_MELEE && self.classname == "monster_dog" && client.classname == "player"))
		{
			if (client.show_hostile < time)
				return FALSE;
			if (r == RANGE_FAR)
				return FALSE;
		}
	}

	// got one
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;	// angered by a monster angering, use its enemy
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
	
	FoundTarget();

	return TRUE;
}
*/

/*
==============================================================================
PATH PATROL CODE

The angle of the pathcorner effects standing and bowing direction, but has 
no effect on movement, which always heads to the next target.
==============================================================================
*/

void() path_corner_touch =
{
	if (other.goalentity != self)
		return;
	if (other.enemy)
		return;		// fighting, not following a path
	
	if (self.target != string_null)
		other.goalentity = findunlocked(world, targetname, self.target);
	else
		other.goalentity = world;

	if (!other.goalentity)
	{
		other.pausetime = time + A_SHITLOAD;
		other.think = other.th_stand;

		if (self.angles_y)
			other.ideal_yaw = self.angles_y;
		return;
	}

	if (other.classname == "monster_ogre")
		sound (other, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

	if (self.wait)
	{
		other.pausetime = time + self.wait;
		other.think = other.th_stand;

		if (self.angles_y)
			other.ideal_yaw = self.angles_y;
		return;
	}
	other.ideal_yaw = vectoyaw(other.goalentity.origin - other.origin);
}

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8) - - - - BEZIER
Waypoint for platforms and monsters. Will stop here for good if no path_corner is targeted by this entity.
Monsters who wait here will turn to face 'angle'.

Keys:
"targetname" must be present.  The name of this pathcorner.
"target" the next spot to move to.  If not present, stop here for good.
"wait" The number of seconds to spend standing here
"angle" direction to face while standing here
"speed" tell a visiting func_train to change its speed. If a path_corner's speed is -1, the func_train's move when LEAVING that corner will be to snap instantly to the next corner.

Spawnflags:
BEZIER	Act as a bilinear control point between the previous and next pathcorner in the chain (train only, no monster patrols)
	"count"	override number of steps of interpolation along the curve the train will make
*/
/*FGD
@PointClass base(Appearflags, Targetname, Angle) size(16 16 16) color(128 80 0) = 
	path_corner : 
"Waypoint for platforms and monsters. Will stop here for good if no path_corner is targeted by this entity.
Monsters who wait here will turn to face 'angle'.
Checking the Bezier spawnflag will make this pathcorner act as a bilinear control point - meaning curved motion - between the previous and next pathcorner in the chain (train only, no monster patrols). 'count' will change the number of steps of interpolation along the curve the train will make."
[
	spawnflags(Flags) = [
		16 : "Bezier point" : 0
	]
	target(target_destination) : "Target: next path_corner to move to" 
	target2(target_destination) : "Target 2: trains will activate all matching on arrival" 
	target3(target_destination) : "Target 3: trains will activate all matching on arrival" 
	target4(target_destination) : "Target 4: trains will activate all matching on arrival" 
	killtarget(target_destination) : "Killtarget: trains will remove all matching on arrival"
	delay(string) : "Delay before activating targets" : "0"
	wait(string) : "Wait time (seconds)" : "0"
	speed(string) : "A visiting func_train to change its speed to this. If 'speed' is -1, the func_train's move when LEAVING that corner will be to snap instantly to the next corner." : "0"
	count(integer) : "override steps of interpolation along this bezier curve segment"
]
*/
void() path_corner =
{
	if (!SUB_ShouldSpawn()) return;
	
	if (self.targetname == string_null)
	{
		dprint3("path_corner with no targetname at ", vtos(self.origin), "\n");
		remove(self);
		return;
	}
	
	if (!self.wait)
	{
		if (self.pausetime)
			self.wait = self.pausetime;
	}
	
	self.solid = SOLID_TRIGGER;
	self.touch = path_corner_touch;
	setsize (self, '-8 -8 -8', '8 8 8');
}

//============================================================================
/*
=============
ai_check_liquid

take damage from slime and lava. returns FALSE if monster died from it.
=============
*/
float() ai_check_liquid =
{
	// there are hacked takedamage cthons out there, and they're all in the lava
	if (self.type == "boss" || self.classname == "monster_rotfish")
		return TRUE;
		
	vector wtt;
	wtt = WaterTest();
	float wl, wt;
	wl = wtt_x;
	wt = wtt_y;
	
	// never do liquid damage for some mild wading, since lots of ep3 has lava
	// the monsters can step into and out of
	if (wl < 3)
		return TRUE;
	
	// monsters that spawn in slime/lava were clearly intended to be there by the
	// mapper, so give them special dispensation to not quietly die before the 
	// player ever finds them. also, revoke their liquid rights once they leave, so 
	// they just die instead of staying lost if they fall back in
	if (!wl)
	{
		self.copperflags = not(self.copperflags, CFL_LIQUID_IMMUNE);
		return TRUE;
	}
	if (self.copperflags & CFL_LIQUID_IMMUNE)
		return TRUE;
		
	if (wt == CONTENT_LAVA)
		T_Damage(self, world, world, wl * 10, NOFLAGS);
	else if (wt == CONTENT_SLIME)
		T_Damage(self, world, world, wl * 5, NOFLAGS);
	
	return self.health > 0;
}