/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// prototypes
float	modelindex_eyes, modelindex_player;

/*=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================*/

float	intermission_running;
float	intermission_exittime;

void() trigger_movementflags_use =
{
	if (activator.classname != "player")
		return;
	
	if (!self.state) // set
	{
		activator.movementflags = self.movementflags;
		return;
	}
	
	if (self.state == 1) // add
	{
		activator.movementflags |= self.movementflags;
		return;
	}
	
	if (self.state == 2) // remove
	{
		activator.movementflags -= activator.movementflags & self.movementflags;
		return;
	}
};

void() trigger_movementflags =
{
	self.use = trigger_movementflags_use;
};

entity() get_closest_client =
{
	if (coop == 0 || clients == 1)
		return nextent(world);
		
	entity next, best;
	float close, dist;
	close = A_SHITLOAD;
	next = nextent(world);
	while (next.flags & FL_CLIENT)
	{
		dist = vlen(self.origin - next.origin);
		if (dist < close)
		{
			best = next;
			close = dist;
		}
		next = nextent(next);
	}
	return best;
}

entity(entity start) get_next_client =
{
	// nice trick from necros: clients are always the first entities after world
	entity next;
	next = nextent(start);
	if (next.flags & FL_CLIENT == 0)
		next = nextent(world);
	return next;
}

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'*/
/*
void() info_intermission =
{
};
*/
// should this use localcmd()?
void(entity client, string savename) autosave =
{
	stuffcmd(client, "echo Autosaving...; wait; save ");
	stuffcmd(client, savename);
	stuffcmd(client, "\n");
}

void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}
 
// remove items
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	
// cap super health
	if (self.health > 100)
		self.health = 100;

	if (self.health < 75)
		self.health = 75;

	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	parm4 = self.ammo_shells;
	if (self.ammo_nails < 25)
		parm5 = 25;
	else
		parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.ammo_bullets;
};

void() SetNewParms =
{
	parm1 = IT_PISTOL | IT_KATANA;
	parm2 = 100;
	parm3 = 0;
	parm4 = 0;
	parm5 = 50;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
};

void() DecodeLevelParms =
{
	if (!deathmatch)	
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.ammo_bullets = parm9;
};

/*============
FindIntermission

Returns the entity to view from
============*/
/* copper
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");

			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}

		return spot;
	}

	// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");

	return world;
};

*/
string nextmap;
/* copper
void() GotoNextMap =
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);

	else
		changelevel (nextmap);
};

void() ExitIntermission =
{
	// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
	
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
	
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
	
			return;
		}
	
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
	
			return;
		}
	
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
	
			return;
		}
	
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
	
			return;
		}

		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
	
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
	
			return;
		}
		
	}

	GotoNextMap();
};
*/
/*============
IntermissionThink

When the player presses attack or jump, change to the next level
============*/
/*
void() IntermissionThink =
{
	self.sprawlflags |= SFL_CHANGESCREENTINT;
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};*/
void() IntermissionThink =
{
	self.sprawlflags |= SFL_CHANGESCREENTINT; // change to cleanUpClientShit?
	// this was for coop pre-exit camera spectating, but it shudders really badly 
	// on non-server clients, so players just get to look around while waiting
//	self.angles = self.v_angle = self.goalentity.mangle;
//	self.fixangle = TRUE;
	self.flags = not(self.flags, FL_ONGROUND);

	if (self.impulse)
	{
		// cycle forward or back in the intermissions with weapnext/weapprev
		if (self.attack_finished < time)
		{
			// stay on cameras twice as long if player cycles to them manually
			if (self.impulse == 10)
			{
				move_player_to_next_intermission();
				self.attack_finished = time + 0.2;
				self.lifetime_finished = time + 12;
			}
			else if (self.impulse == 12)
			{
				move_player_to_previous_intermission();
				self.attack_finished = time + 0.2;
				self.lifetime_finished = time + 12;
			}
		}
		self.impulse = 0;
	}
	
	if (!intermission) return;
	
	// auto-cycle intermission camera after six seconds
	else if (time > self.lifetime_finished)
	{
		move_player_to_next_intermission();
		self.lifetime_finished = time + 6;
	}
	
	if (time < intermission_exittime)
		return;

	// start listening for input to leave
	if (!self.button0 && !self.button1 && !self.button2) {
		if (self.wait) ExitIntermission ();
		self.wait = 0;
		return;
	}
	
	self.wait = 1;
}
/*
void() execute_changelevel =
{
	local entity	pos;
	
	ResetSlowmotion();
	intermission_running = 1;

	// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;

	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");

	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};
*/
/* copper
void() changelevel_touch =
{
	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000, DF_INSTAGIB);
		return;
	}

	bprint (other.netname);
	bprint (" exited the level\n");
	
	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();

		return;
	}
	
	self.touch = SUB_Null;

	// we can't move people right now, because touch functions are called
	// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};
*/
/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  
Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission 
spot and display stats.*/
/*
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	//gnounc
	self.netname = "changelevel";
	self.killstring = " tried to leave\n";
	
	InitTrigger ();
	self.touch = changelevel_touch;
};
*/

/*=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQueue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}

	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQueue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}

	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*============
SelectSpawnPoint

Returns the entity to spawn at
============*/
entity() SelectSpawnPoint =
{
	local   entity spot, thing;
	local   float   numspots, totalspots;
	local   float   pcount;
	local entity spots;

	numspots = 0;
	totalspots = 0;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
	// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{

		// ok, find all spots that don't have players nearby
		spots = world;
		spot = find (world, classname, "info_player_deathmatch");       

		while (spot)
		{
			totalspots = totalspots + 1;

			thing=findradius(spot.origin, 84);
			pcount=0;               

			while (thing)
			{
				if (thing.classname == "player")
					pcount=pcount + 1;                      

				thing=thing.chain;      
			}

			if (pcount == 0) 
			{
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}

			// Get the next spot in the chain
			spot = find (spot, classname, "info_player_deathmatch");                
		}
		totalspots=totalspots - 1;

		if (!numspots) 
		{
			// ack, they are all full, just pick one at random
			totalspots = rint((random() * totalspots));
			spot = find (world, classname, "info_player_deathmatch");       

			while (totalspots > 0) 
			{
				totalspots = totalspots - 1;
				spot = find (spot, classname, "info_player_deathmatch");
			}
			return spot;
		}
		
		// We now have the number of spots available on the map in numspots
		// Generate a random number between 1 and numspots
		numspots = numspots - 1;
	
		numspots = rint((random() * numspots ) );

		spot = spots;
		while (numspots > 0) 
		{
			spot = spot.goalentity;
			numspots = numspots - 1;
		}
	
		return spot;
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
	
		if (spot)
			return spot;
	}
	
	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	return spot;
};

/*===========
PutClientInServer

called each time a player is spawned
============*/

void() PutClientInServer =
{
	local	entity spot;

	self.classname = "player";
	self.entity_type = TYPE_PLAYER;
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.clip = CLIP_CLIENT;
	
	self.phys_speed = 320; // absolute value in units/s
	self.phys_friction = 8; // absolute value
	self.phys_gravity = 1; // 800, this is force multiplyer
	self.current_acceleration = self.phys_acceleration = 1; // 13 in the engine, this is force multiplyer
	self.current_airacceleration = self.phys_airacceleration = 1; // 10 in the engine, this is force multiplyer
	self.phys_airfriction = 0.1;
	self.speedmodifier = 1; // used for axe sprint, force multiplyer for phys_speed
	self.adrenaline = 1;
	//self.touch = playerBump;
	
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.dmg = 2;   		// initial water damage
	self.effects = 0;
	
	self.air_finished = time + 12;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.invincible_time = 0;
	self.viewmodeloffset_angles = '1 1 1';
	self.chaingun_speed = 0.1;

	DecodeLevelParms ();
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
	// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.trail1 = self.trail2 = self.trail3 = self.trail4 = self.origin;
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately
	
	// yet another thing that doesn't work on the first frame
	if (spot.fog_density || spot.fog_color || spot.fog_sky)
		fog_save(self, spot.fog_density, spot.fog_color, spot.fog_sky);
	else if (world.fog_density || world.fog_color || world.fog_sky)
		fog_save(self, world.fog_density, world.fog_color, world.fog_sky);

	if (!self.fog_sky)
		self.fog_sky = cvar("r_skyfog");
	cleanUpClientShit = 2; 

	// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';
	self.sprawlflags |= SFL_CHANGESCREENTINT;
	player_stand1 ();
	
	if (deathmatch || coop)
	{
		makevectors2(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
	
	stuffcmd(self, "-attack\n");            // Supa, prevent shooting after respawning in MP
	
//	centerprint(self, getMapname(mapname));	//gnounc --thought it would be fun. I was at odds about adding an unexpected feature. I may remove it later
	//BAM removed it later. --gnounc

	if (!grenade_handler)
		grenade_handler = spawn();
	grenade_handler.classname = "GrenadeHandler";
	
	self.thinkA = trailPlayer;
	self.nextthinkA = time + 1;
};

void() info_wind =
{
	
};
/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void() NextLevel =
{
	local entity o;

	if (nextmap != string_null)
		return; // already done

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}

		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}

		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}

		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}

		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}
 
		o = spawn();
		o.map = mapname;
	}

	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		if (!o || mapname == "start")
		{       // go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE; // gb

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*============
CheckRules

Exit deathmatch games upon conditions
============*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};

//============================================================================

void() PlayerDeathThink =
{
	float forward;

	if (self.flags & FL_ONGROUND)
	{
		forward = vlen (self.velocity);
		forward = forward - 20;

		if (forward <= 0)
			self.velocity = '0 0 0';

		else	
			self.velocity = forward * normalize(self.velocity);
	}

	//copper -- start
	if (time < self.lifetime_finished) return;
	
	// wait for all buttons released
	if (!self.button0 && !self.button1 && !self.button2) {
		if (self.wait)
			respawn();
		
		self.wait = 0;
		return;
	}
	
	self.wait = 1;
	//copper -- end
};


void() PlayerJump =
{	
	local vector walljump_direction;
	local float z;
	local float jump_force;
	local float speed_fatigue;
	
	if (self.movementflags & MF_JUMPDISABLED)
		return;
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;

		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;

		else
			self.velocity_z = 50;

		// play swimming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;

			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);

			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if ( !(self.flags & FL_ONGROUND) && (!(self.wallrun) || self.jump_timer > time) )
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.button2 = 0;

	if (self.wallrun && (self.jump_timer < time))
	{
		if (self.wall_jumps > 2) 
			return;
		if (self.movementflags & MF_NOWALLJUMPS)
			return;
		
		self.wall_jumps++;
		if (!self.jumpreset_time)
			self.jumpreset_time = time + 1.5;
		
		z = self.velocity_z;
		jump_force = clamp(0, time - self.jump_timer, 1);
		speed_fatigue = clamp(0.25, self.current_speed / 320, 1);
		// magnitude of force away from the wall, and forward
		walljump_direction = self.wall_normal * (125 + (1 - jump_force) * 100) + v_forward * (100 + (1 - jump_force) * 150) * speed_fatigue;
		walljump_direction_z = 0;
		self.velocity += walljump_direction;
		addShake(-100 * (1 - jump_force) - 50, crandom() * 80 * (1 - jump_force), 40  * (1 - jump_force)); // punch before speedfatigue override
		
		speed_fatigue = 1 - clamp(0, self.velocity_z / 600, 1); // we won't let player fly upwards too fast with jump spam
		self.velocity_z += (100 + 320 * jump_force) * speed_fatigue;
		self.velocity_z = max(125, self.velocity_z);
		
		if (self.current_speed < 200 && self.velocity_z < 300)
			self.velocity_z += 200;
		//self.velocity_z = min(500, self.velocity_z);
		self.jump_timer = time + 0.5;
			// player jumping sound
		sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	}
	else // regular jump
	{
		addShake(-50,crandom()*50, 0);
		self.velocity_z = self.velocity_z + 270;
		self.jump_timer = time;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		// player jumping sound
		sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	}
};


/*===========
WaterMove

============*/
.float	dmgtime;

void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;

	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);

		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}

	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;

			if (self.dmg > 15)
				self.dmg = 10;

			T_Damage (self, world, world, self.dmg, 0);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}

		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;

			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel, 0);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel, 0);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	

		// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);

		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);

		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors2 (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);

	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);

		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net

			return;
		}
	}
};

void() trailPlayer =
{
	self.trail4 = self.trail3;
	self.trail3 = self.trail2;
	self.trail2 = self.trail1;
	self.trail1 = self.origin; // no velocity addition
	self.thinkA = trailPlayer;
	self.nextthinkA = time + 0.3;
};

void() SetMovementParams_Slide =
{
	self.current_acceleration = 0;
	self.phys_acceleration = 0;
	self.phys_friction = 0.85;
};

void() SetMovementParams_Crouchwalk =
{
	self.current_acceleration = 1;
	if (!(self.movementflags & MF_NOACCELERATION))
		self.phys_acceleration = 1;
	self.phys_friction = 8;
	self.phys_speed = 160;
};

void() SetMovementParams_Standard =
{
	self.current_acceleration = 1;
	if (!(self.movementflags & MF_NOACCELERATION))
		self.phys_acceleration = 1;
	self.phys_friction = 8;
	self.phys_speed = 320 * self.speedmodifier;
};

void(float timer, entity who) StopAcceleration =
{
	if (who.noacceleration_timer > time)
		return;
	who.current_acceleration = who.phys_acceleration;
	who.phys_acceleration = 0;
	who.movementflags |= MF_NOACCELERATION;
	if (timer < 0)
		who.noacceleration_timer = time + 7200; // 2 hours, wait to be manually reset
	else
		who.noacceleration_timer = time + timer;
};

void() StartAcceleration =
{
	if (self.current_acceleration)
		self.phys_acceleration = self.current_acceleration;
	else
		self.phys_acceleration = 1;
	self.noacceleration_timer = 0;
	self.movementflags -= self.movementflags & MF_NOACCELERATION;	
};

void(float timer, entity who) StopAirAcceleration =
{
	if (who.noairacceleration_timer > time)
		return;
	who.current_airacceleration = who.phys_airacceleration;
	who.phys_airacceleration = 0;
	who.movementflags |= MF_NOAIRACCELERATION;
	if (timer < 0)
		who.noairacceleration_timer = time + 7200; // 2 hours
	else
		who.noairacceleration_timer = time + timer;
};

void() StartAirAcceleration =
{
	if (self.current_airacceleration)
		self.phys_airacceleration = self.current_airacceleration;
	else
		self.phys_airacceleration = 1;

	self.noairacceleration_timer = 0;
	self.movementflags -= self.movementflags & MF_NOAIRACCELERATION;
};

void(float timer, entity who) ForceStartSlide =
{
	if (who.forcedslide_timer > time) 
		return;
	
	who.phys_friction = 0;
	who.movementflags |= MF_FORCEDSLIDE;
	if (timer < 0)
		who.forcedslide_timer = time + 7200;
	else
		who.forcedslide_timer = time + timer;
};

void() StopSlide =
{
	self.phys_friction = 8;
	self.movementflags -= self.movementflags & MF_FORCEDSLIDE;
};

/*
void() StartWallrun =
{
	self.phys_acceleration = self.current_acceleration;
	self.noacceleration_timer = 0;
	self.movementflags -= self.movementflags & MF_NOACCELERATION;	
};

void(float timer) StopWallrun =
{
	self.current_airacceleration = self.phys_airacceleration;
	self.phys_airacceleration = 0;
	self.movementflags |= MF_NOAIRACCELERATION;
	if (timer < 0)
		self.noairacceleration_timer = time + 7200; // 2 hours
	else
		self.noairacceleration_timer = time + timer;
};

nowallrun_timer
*/
void() ResetSlowmotion =
{
	slowmotion_time = 0;
	slowmotion = 0;
	change_timescale(0);
};

float(float amount_frametime, float amount) consumeAdrenaline =
{
	if (self.sprawlflags & SFL_UNLIMITED_ADRENALINE)
		return 1;
	if (self.engineflags & ENF_ADRENALINE_OFF || self.adrenaline_regentimer > time)
		return 1;

	self.adrenaline -= amount_frametime * frametime;
	self.adrenaline -= amount;
	
	if (self.adrenaline <= 0)
	{
		self.adrenaline_regentimer = time + 3;
		self.engineflags |= ENF_ADRENALINE_OFF;
		self.adrenaline = 0;
	}
	return 0;
};

void() regenAdrenaline =
{
	if (self.adrenaline_regentimer < time)
	{
		self.engineflags -= self.engineflags & ENF_ADRENALINE_OFF;
	}
	
	if (self.adrenaline < 0.5 )
	{
		self.adrenaline += frametime * 0.15;
		self.adrenaline = min(self.adrenaline, 0.5);
	}
	else
	{
		self.adrenaline += frametime * 0.1;
		self.adrenaline = min(self.adrenaline, 1);
	}
};

//-------------------------------------------- DASH JUMPS -- BEGIN -------------------------------------

const float BACKJUMP[2] = {MOVE_BACKWARD,MOVE_BACKWARD};
const float FRONTJUMP[2] = {MOVE_FORWARD,MOVE_FORWARD};
const float LEFTJUMP[2] = {MOVE_LEFT, MOVE_LEFT}; // count diagonals too
const float RIGHTJUMP[2] = {MOVE_RIGHT, MOVE_RIGHT};

float (entity who, float distance = -64) traceDown =
{
	traceline(who.origin, who.origin + [0, 0, distance], IGNOREMONSTERS, self);
	if (trace_fraction != 1)
		return 1;
	else 
		return 0;
};

float (entity who, vector dir_forward, vector dir_right) traceWall =
{
	traceline(who.origin, who.origin + dir_forward + dir_right + '0 0 -24', ALLOWMONSTERS, self);
	if (trace_fraction != 1)
		return 1;
	else 
		return 0;
};

void(float fwall, float rwall, float fvel, float rvel, float type) makeDodge =
{
	if (self.b_slide)
		return;
	if (self.engineflags & ENF_ADRENALINE_OFF)
		return;
	if (self.jump_timer > time)
		return;
	if (self.wall_jumps > 2) 
		return;
		
// shift trail further into the past, so monsters looks confused
	if (skill > 1)
	{
		self.trail++; 
		self.trail_time = time + (1 - 0.5 * (skill - 2)); // 0.5 on skill 3, 1 second on skill 2
	}
	else if (skill < 2)
	{
		self.trail += 2; 
		self.trail_time = time + 1;
	}
	
	if (self.flags & FL_ONGROUND || traceDown(self)) // on ground, slightly above ground
	{
		makevectors(self.angles);
		self.flags -= self.flags & FL_ONGROUND;
		self.velocity += v_forward * fvel + v_right * rvel + [0,0, 160];
		self.dodge_time = time + 0.5;
		consumeAdrenaline(0, 0.2);
		addShake(-fvel * 0.2,rvel * 0.2, rvel * 0.4);
		self.jump_timer = time + 0.5;
		StopAirAcceleration(0.4, self);
		//StopAcceleration(0.4);
		sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
		if (self.weapon == IT_KATANA)
			self.speedmodifier = 2;
		self.wall_jumps++;
	}
	else 
	{
	//wall in the opposite side of dodge direction
		makevectors(self.angles);
		if (!(self.flags & FL_ONGROUND) && traceWall(self, fwall * v_forward, rwall * v_right))
		{
			//extra velocity for wall dodges to differentiate regular jumps and dodges
			self.velocity += v_forward * (fvel * 1.25) + v_right * (rvel * 1.25); // + '0 0 -100'
			if (self.velocity_z < 150) //270
				self.velocity_z = 150;
			// limit maximum upwards momentum, so it's more about moving to the side
			if (self.velocity_z > 270)
				self.velocity_z = 270;
			self.dodge_time = time + 0.5;
			consumeAdrenaline(0, 0.2);
			addShake(-fvel * 0.2,rvel * 0.2, rvel * 0.4);
			//addShake(100,rvel * 0.2, rvel * 0.1);
			self.jump_timer = time + 0.5;
			StopAirAcceleration(0.4, self);
			sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
			if (self.weapon == IT_KATANA)
				self.speedmodifier = 2;
			self.wall_jumps++; // not met requirements increment fixed
		}
	}
};
#define DODGE_SPEED 500
void() checkPressCombo =
{
	float i;
	float action;
	float combo1, combo2, combo3, combo4; 

	for (i = 0; i < 3; i++)
	{
		action = readQueue(i);
	// no more actions to read, cancel
		if (!action)
			return;
	// forward and backwards jumps allowed only on lower skills
	if (skill < 2)
	{
	// front jump, combo1
		if ( FRONTJUMP[combo1] == action)
			combo1++;
		else
			combo1 = 0;
		
		if (combo1 == 2)
		{
			if (self.dodge_time < time)
				makeDodge(-96, 0, DODGE_SPEED, 0, MOVE_FORWARD); // forward wall, righ wall, forward velocity, right velocity
			resetQueue();
			return;
		}
		
	// back jump, combo2	
		if ( BACKJUMP[combo2] == action)
			combo2++;
		else
			combo2 = 0;
		
		if (combo2 == 2)
		{
			if (self.dodge_time < time)
				makeDodge(96, 0, -DODGE_SPEED, 0, MOVE_BACKWARD); // backwards dodge allowed on the ground
			resetQueue();
			return;
		}
	}
	// left jump, combo3	
		if (LEFTJUMP[combo3] & action)
			combo3++;
		else
			combo3 = 0;

		if (combo3 == 2)
		{		
			if (self.dodge_time < time)
				makeDodge(0, 96, 0, -DODGE_SPEED, MOVE_LEFT);
			resetQueue();
			return;
		}
	// right jump, combo4
		if (RIGHTJUMP[combo4] & action)
			combo4++;
		else
			combo4 = 0;
		
		if (combo4 == 2)
		{
			if (self.dodge_time < time)
				makeDodge(0, -96, 0, DODGE_SPEED, MOVE_RIGHT);
			resetQueue();
			return;
		}
	}
};

void() resetQueue =
{
	self.combo_timer = 0;
	self.combo_index = 0;
	self.combo_index_head = 0;
	self.combo_queue = [0,0,0];
};

float(float i) readQueue =
{
	local float j; // keep i untouched
// playing safe here, ok?
	if (self.combo_index_head < 0 || self.combo_index_head > 2)
	{
		dprint(" ERROR! .combo_index_head out of range (client.qc, pushQueue) \n");
		self.combo_index = 0;
		self.combo_index_head = 0;
		self.combo_queue = [0,0,0];
		return 0;
	}
	
	j = self.combo_index_head + i;
	
	if (j > 2)
		j -= 3;

	return self.combo_queue[j];
};

// 0..2 is boundaries of vector array
void(float value) pushQueue =
{
// playing safe here, ok?
	if (self.combo_index < 0 || self.combo_index > 2)
	{
		dprint(" ERROR! .combo_index out of range (client.qc, pushQueue) \n");
		self.combo_index = 0;
		self.combo_index_head = 0;
		self.combo_queue = [0,0,0];
		return;
	}

	self.combo_queue[self.combo_index] = value;
	self.combo_index++;
	
// loop i
	if (self.combo_index > 2)
		self.combo_index = 0;
	if (self.combo_queue[2])
		self.combo_index_head = self.combo_index; // head remains untouched until first loop (queue[2] filled)
};

void() catchComboInput =
{
	local float i;
	local float current_bit;
	local float changed_bits;
// we not pressing buttons fast enough, reset
	if (self.combo_timer && self.combo_timer < time)
		resetQueue();
	
	if (self.player_inputs && (self.saved_inputs != self.player_inputs))
	{
		for (i = 0; i < 4; i++)
		{
			//current_bit = (1 << i); -- why does bit shift not working???
			current_bit = pow (2,i);
			if ( !(current_bit & self.saved_inputs) && current_bit & self.player_inputs) // bit was 0 became 1
				changed_bits |= current_bit; //store it
		}
		if (changed_bits)
		{
			pushQueue(changed_bits); // push all bits that was changed, this way we can check both perfect (1 key) and non-perfect combos
			self.combo_timer = time + cvar("dodge_tap_speed");//COMBO_RESET_TIME;
			checkPressCombo();
		}
	}
};

void() checkMovementInput =
{
// allow dodges with katana on any skill, and with any weapon on hard and nightmare
// since now we have adjustable tap speed, we can allow dodges on any difficulty
	//if (self.weapon != IT_KATANA && skill < 2)
	//	return;
	if (self.movementflags & MF_NODODGES)
		return;
	
	catchComboInput();
// Important! must be set after all the input/combo checks
// any of this shouldn't be modified outside of body of this procedure
	self.saved_inputs = self.player_inputs;
};

//------------------------------------------------------ DASH JUMPS -- END -----------------------------------

void(float svolume) soundFootsteps =
{
	if (self.flags & FL_INWATER)
		return;
	float r;
	
	svolume = clamp(0.25, svolume, 1);
// don't repeat same sound twice in a row
	while (self.laststep == r)
		r = rint(random()*5);
	
	self.laststep = r;
	
	switch (r)
	{
		default:
		case 0:
			sound (self, CHAN_BODY, "player/step1.wav", svolume, ATTN_IDLE);
			break;
		case 1:
			sound (self, CHAN_BODY, "player/step2.wav", svolume, ATTN_IDLE);
			break;
		case 2:
			sound (self, CHAN_BODY, "player/step3.wav", svolume, ATTN_IDLE);
			break;
		case 3:
			sound (self, CHAN_BODY, "player/step4.wav", svolume, ATTN_IDLE);
			break;
		case 4:
			sound (self, CHAN_BODY, "player/step5.wav", svolume, ATTN_IDLE);
			break;
		case 5:
			sound (self, CHAN_BODY, "player/step6.wav", svolume, ATTN_IDLE);
			break;
	}
};

void() sprintFootsteps =
{
	local float intensity;
	
	if (self.footstep_timer > time)
		return;
	
	intensity = self.speedmodifier - 1.0;
	
	self.footstep_timer = time + 0.4 - (0.15 * intensity);
	
	if (self.movementflags & MF_LEFTLEG)
		addShake(-60*intensity,-30*intensity,-10*intensity);
	else
		addShake(-60*intensity,30*intensity,10*intensity);
	
	soundFootsteps(1); // full volume
	self.movementflags ^= MF_LEFTLEG;
};

void() basicFootsteps =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	
	if (self.footstep_timer > time)
		return;
	
	if (self.wallrun)
		self.footstep_timer = time + 0.25;
	else
		self.footstep_timer = time + 0.4;
	soundFootsteps(0.4); // full volume
};

// touch procedure
void() playerBump =
{
	vector direction;
	float angle_difference;

	if (other.flags & FL_MONSTER && other.takedamage)
	{
		makevectors(self.v_angle);
		direction = normalize(other.origin - self.origin);
		angle_difference = direction * v_forward;
		if (angle_difference > 0.5)
		{
			T_Damage (other, self, self, 100, DF_HEADSHOT | DF_KATANA);
			self.touch = SUB_Null;
		}
	}
};

/*================
PlayerPreThink

Called every frame before physics are run
================*/
void() PlayerPreThink =
{
	if (self.sprawlflags & SFL_CHANGESCREENTINT)
	{
		if (!(self.copperflags & CFL_PLUNGE))
		{
			if (self.cshift_value)
			{
				stuffcmd(self, "v_cshift 40 100 170");
				stuffcmd(self, ftos(self.cshift_value)); // [0 .. 30]
				stuffcmd(self, "\n");
				self.cshift_value = 0;
			}
			else
				stuffcmd(self,"\nv_cshift 0 0 0 0\n");
			
			self.sprawlflags -= self.sprawlflags & SFL_CHANGESCREENTINT;
		}
	}
// todo: look closer to this 
	if (cleanUpClientShit)
	{
		fog_setFromEnt(self, self);
		if (!(self.copperflags & ( CFL_PLUNGE | CFL_LIMBO )))
			TintScreen(self, 0);
		else if ( self.copperflags & CFL_LIMBO )
			TintScreen(self, 255);
	}
	
	if (intermission_running || intermission || self.deadflag == DEAD_SPECTATING )
	{
		if (slowmotion)
		{
			ResetSlowmotion();
			self.sprawlflags |= SFL_CHANGESCREENTINT;
		}
		
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	if (self.deadflag >= DEAD_DEAD)
	{
		if (slowmotion)
		{
			ResetSlowmotion();
			self.sprawlflags |= SFL_CHANGESCREENTINT;
		}

		PlayerDeathThink ();
		return;
	}

	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing
	
	if (self.health > 125)
	{
		if (self.overheal_decay < time)
		{
			self.health--;
			self.overheal_decay = time + 2.5;
		}
	}
// move trail back to origin, until we reach it
	if (self.trail && self.trail_time < time)
	{
		self.trail--;
		self.trail = clamp(0, self.trail, 4);
		if (self.trail)
			self.trail_time = time + 0.5;
	}
//--------------------------------------------------------------------------------
// reset jumps 
	if (!(self.flags & FL_ONGROUND))
	{
		if (self.jumpreset_time < time && self.jumpreset_time)
		{
			if (self.wall_jumps > 0)
			{
				self.wall_jumps--;
				sound (self, CHAN_AUTO, "player/jump_recharged.wav", 1, ATTN_NORM);
			}
				
			if (self.wall_jumps > 0)
				self.jumpreset_time = time + 1.5;
			else
				self.jumpreset_time = 0;
		}
	}
	else
	{
		self.jumpreset_time = 0;
	}
	
	if (self.movementflags & MF_NOAIRACCELERATION)
	{
		if (self.noairacceleration_timer < time)
		{
			StartAirAcceleration();
			//self.movementflags -= self.movementflags & MF_NOAIRACCELERATION;
			//self.phys_airacceleration = self.current_airacceleration;
		}
	}
	
	if (self.movementflags & MF_NOACCELERATION)
	{
		if (self.noacceleration_timer < time)
		{
			StartAcceleration();
			//self.movementflags -= self.movementflags & MF_NOACCELERATION;
			//self.phys_acceleration = self.current_acceleration;
		}
	}
	
	if (self.movementflags & MF_FORCEDSLIDE)
	{
		if (self.forcedslide_timer < time)
		{
			self.movementflags -= self.movementflags & MF_FORCEDSLIDE;
			self.phys_friction = 8;
			self.forcedslide_timer = 0;
		}
	}
	
	checkMovementInput();
	
	self.current_speed = vlen([self.velocity_x,self.velocity_y, 0]);
	
	if (self.movementflags & MF_JUMPDISABLED)
	{
		if (self.katana_finished < time)
		{
			self.touch = SUB_Null;
			self.movementflags -= self.movementflags & MF_JUMPDISABLED;
			if (!self.b_slide)
				SetMovementParams_Standard(); // not ok
			StartAcceleration();
		}
	}
// swap to and away from Katana
	if (self.sprawlflags & SFL_NEEDTOSETSPEED)
	{
		if (self.weapon == IT_KATANA)
			self.speedmodifier = 1.25;
		else
			self.speedmodifier = 1;
		self.sprawlflags -= self.sprawlflags & SFL_NEEDTOSETSPEED;
		SetMovementParams_Standard(); // not ok
	}
	
//	Katana sprint
	if (self.weapon == IT_KATANA && self.flags & FL_ONGROUND && !(self.movementflags & MF_NOSPRINT))
	{
		if (self.wallrun || self.b_slide)
			self.speedmodifier = 1.25;
		else
		{
			if (!(self.engineflags & ENF_ADRENALINE_OFF) && self.sprawlflags & SFL_SPRINT)
			{
				if (self.player_inputs == MOVE_FORWARD)
				{
					sprintFootsteps();
					self.speedmodifier += frametime; // +100% per second
					consumeAdrenaline(0.2, 0);
					if (self.speedmodifier > 2)
					{
						self.speedmodifier = min(2, self.speedmodifier);
						consumeAdrenaline(0.2, 0);
					}
				}
				else
					self.speedmodifier = 1.25;
			}
			else
				self.speedmodifier = 1.25;
			
			if (self.speedmodifier > 1.25 && self.current_speed < 320 * self.speedmodifier * 0.8 && self.dodge_time < time)
				self.speedmodifier = 1.25;
			
			self.phys_speed = 320 * self.speedmodifier;
			if (!(self.movementflags & MF_NOACCELERATION))
				self.phys_acceleration = 1 - (self.speedmodifier - 1)*0.25;
		}
	}
// step sounds are executed after sprint so it has higher priority
	if (!self.b_slide)
	{
		if ((self.flags & FL_ONGROUND || self.wallrun) && self.current_speed > 150)
			basicFootsteps();
	}
	
	float i;
	float delta;
	float progress;
	float angle_combined;
	float velocity_combined;
	
	if (self.punch_time)
	{
		progress = time - self.punch_time;
		
		for (i=0; i < 3; i++)
		{
			velocity_combined = 0;
			angle_combined = 0;
		
			delta = self.punch_slow[i] * min(1, progress * 4);
			self.punch_slow[i] -= delta;
			velocity_combined += delta;

			delta = self.punch_normal[i] * min(1, progress * 10);
			self.punch_normal[i] -= delta;
			velocity_combined += delta;

			delta = self.punch_fast[i] * min(1, progress * 10);
			self.punch_fast[i] -= delta;
			angle_combined += delta;
			
			self.punchvelocity[i] += velocity_combined * 10;
			self.punchangle[i] += angle_combined;
			//self.punchangle[i] = clamp (-15, self.punchangle[i], 15);
		}
		
		if (self.punch_time + 2.0 < time)
		{
			self.punch_fast = [0,0,0];
			self.punch_normal = [0,0,0];
			self.punch_slow = [0,0,0];
			self.punch_time = 0;
		}
	}
	
	makevectors (self.v_angle);		// is this still used

	if (deathmatch || coop)	// gb, this is a waste in SP
		CheckRules ();

	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.button2)
		PlayerJump();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	float interpolation;
	float cshift_val;
	// catch in and out
	// player can release button during transition phase, so we need to know how deep into transition we was
	// then start new transition back from that point
	if (slowmotion)
	{
		if (!self.b_adrenaline)
		{
			if (slowmotion_time > 0) // use the length of previous fade
				slowmotion_time = time + (SLOWMO_FADE_TIME - (slowmotion_time - time));
			else
				slowmotion_time = time + SLOWMO_FADE_TIME; //start fade out 
			
			slowmotion = 0;
			changeSkinsSlowmo(0);
		}
	}
	else
	{
		if (self.b_adrenaline)
		{
			if (slowmotion_time > 0) // use the length of previous fade
				slowmotion_time = time + (SLOWMO_FADE_TIME - (slowmotion_time - time));
			else
				slowmotion_time = time + SLOWMO_FADE_TIME/2; //start fade in
			
			slowmotion = 1;
			changeSkinsSlowmo(1);
		}
	}
	
	if (slowmotion)
		consumeAdrenaline(0.5, 0);
	
	if (self.engineflags & ENF_ADRENALINE_OFF)
	{
		slowmotion = 0;
		slowmotion_time = time;
		changeSkinsSlowmo(0);
	}
	// make changes to timescale
	if (slowmotion_time > 0)
	{
		if (slowmotion)
			interpolation = lerp(SLOWMO_VALUE, 1.0, (slowmotion_time - time) * SLOWMO_FADE_HELPER*2); // helper is const of 1/SLOWMO_FADE_TIME to save calculation time
		else 
			interpolation = lerp(1.0, SLOWMO_VALUE, (slowmotion_time - time) * SLOWMO_FADE_HELPER);
		
		cshift_val = 1 - interpolation;
		interpolation = (ceil(interpolation * 10)) * 0.1; // round to 0.1
		change_timescale(interpolation);
		
		self.cshift_value = cshift_val * 50;
		self.sprawlflags |= SFL_CHANGESCREENTINT;
		
		if (slowmotion_time < time)
			slowmotion_time = 0;
	}
	
	vector velocity2d;
	float boostspeed;

	// Slide button pressed
	if (!(self.movementflags & MF_NOSLIDES)) // new tutorial flag
	{
		if (self.b_slide)
		{
			// catch all events on the ground
			if (self.flags & FL_ONGROUND)
			{
				// we not yet in the slide state, so dicide what to do
				if (!(self.movementflags & MF_INSLIDE) && self.slide_time < time) 
				{
					// set slide movement params first
					self.movementflags |= MF_INSLIDE;
					self.crouch_timer = time + 0.2;
					self.slide_time = time + 0.3;
					SetMovementParams_Slide();
					//StopAcceleration(-1);
					
					// we on the ground and it's first frame when we press the slide button, so do the slide initial boost
					if (self.current_speed > SLIDE_STOPSPEED) //!(self.movementflags & MF_CROUCHINAIR) && 
					{
						velocity2d = self.velocity;
						velocity2d_z = 0;
						velocity2d = normalize(velocity2d);
						if (!(self.movementflags & MF_CROUCHINAIR))
						{
							boostspeed = 270;
							addShake(-60,0,0);
						}
						else
						{
							boostspeed = 150 * self.speedmodifier;
							addShake(-30,0,0);
							//boost after we land while holding crouch
							//already have viewpunch from landing
						}
						if (boostspeed + self.current_speed > 720)
							boostspeed = 720 - self.current_speed;
							
						self.velocity_x += velocity2d_x * boostspeed;
						self.velocity_y += velocity2d_y * boostspeed;
					}
				}
				// we sliding too slow, so stop slide and start crouch-walk
				else if (self.current_speed < SLIDE_STOPSPEED)
				{
					SetMovementParams_Crouchwalk();
					//StartAcceleration();
				}
			}
			
			else
			{
			// we trying to crouch in the air, mark it
				if (!(self.movementflags & MF_INSLIDE))
					self.movementflags |= MF_CROUCHINAIR;
			}
		}
		else
		{
			// slide button is not pressed anymore, but we still in the slide state
			// so reset movement parameters, and get rid of the slide state
			if (self.movementflags & MF_INSLIDE)
			{
				SetMovementParams_Standard(); //ok
				//StartAcceleration();
				self.movementflags -= self.movementflags & MF_INSLIDE; 
				self.crouch_timer = time + 0.2; // save time for view offset lerping
			}

			// reset crouch in the air flag
			if (self.movementflags & MF_CROUCHINAIR)
				self.movementflags -= self.movementflags & MF_CROUCHINAIR; 
			
		}
	}
	// View offset lerping when in/out of crouch
	if ((self.movementflags & MF_INSLIDE) && self.view_ofs_z > SLIDE_OFFSET)
		self.view_ofs_z = lerp( SLIDE_OFFSET, STANDART_OFFSET, (self.crouch_timer - time)*5);
	else if (!(self.movementflags & MF_INSLIDE) && self.view_ofs_z < STANDART_OFFSET)
		self.view_ofs_z = lerp( STANDART_OFFSET, SLIDE_OFFSET, (self.crouch_timer - time)*5);
	/*
	if (self.button1)
	{
		dprint("Use\n");
	}
	*/

	// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_KATANA)
	{
		deployGun(W_BestWeapon());
	}
};

/*================
PlayerPostThink

Called every frame after physics are run
================*/
void() PlayerPostThink =
{
	if (self.view_ofs == '0 0 0' || intermission || self.deadflag)
		return;		// intermission or finale

	regenAdrenaline();
	
	if (self.sprawlflags & SFL_VMOFFSET)
	{
		float progress;
		
		progress = clamp(0, (time - self.deploy_time) * 4, 1); // 0.4 sec

		if (progress == 1)
		{
			self.deploy_time = 0;
			self.sprawlflags -= self.sprawlflags & SFL_VMOFFSET;
		}
	}
	
	if (self.engineflags & ENF_HITMARKER)
	{
		if (self.hitmarker_time < time )
			self.engineflags -= self.engineflags & ENF_HITMARKER;
	}
	
	if (self.engineflags & ENF_HITHEAD)
	{
		if (self.headmarker_time < time )
			self.engineflags -= self.engineflags & ENF_HITHEAD;
	}
		
	if (self.sprawlflags & SFL_SEMIAUTO)
	{
		if (!self.button0)
			self.sprawlflags -= self.sprawlflags & SFL_SEMIAUTO;
	}

	W_WeaponFrame (); // do weapon stuff

	// check to see if player landed and play landing sound	
	if ((self.jump_flag < -100) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			addShake(-150,-40,0);
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			//T_Damage (self, world, world, 5, 0); // no fall damage in qsprawl
			//self.deathtype = "falling";
		}
		else if (self.jump_flag < -300)
		{
			addShake(-50,-10,0);
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
		}
		else
			addShake(0,0,-20);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups ();
};

/*================
CheckPowerups

Check for turning off powerups
================*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

	// invisibility
	if (self.invisible_finished)
	{
		// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}

	else
		self.modelindex = modelindex_player;	// don't use eyes

	// invincibility
	if (self.invincible_finished)
	{
	// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;

		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

	// super damage
	if (self.super_damage_finished)
	{

		// sound and screen flash when items starts to run out
		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;

		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}	

	// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

		// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

};

/*===========
ClientConnect

called when a player connects to a server
============*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");

	// a client connecting during an intermission can cause problems
	if (intermission_running || intermission)
		ExitIntermission ();
};


/*===========
ClientDisconnect

called when a player disconnects from a server
============*/
void() ClientDisconnect =
{
	if (gameover)
		return;

	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*===========
ClientObituary

called when a player dies
============*/
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string deathstring, deathstring2;
	deathstring = deathstring2 = string_null;
	// From GPL QW source
	local   float  attackerteam, targteam;	// gb
	
	// gb
	attackerteam = attacker.team;
	targteam = targ.team;

	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;

			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;

			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					if (targ.watertype == CONTENT_SLIME)
						bprint (" discharges into the slime\n");

					else if (targ.watertype == CONTENT_LAVA)
						bprint (" discharges into the lava\n");

					else
						bprint (" discharges into the water.\n");

					return;
				}
				if (targ.weapon == 16)
					bprint (" tries to put the pin back in\n");
				else if (rnum)
					bprint (" becomes bored with life\n");
				else
					bprint (" checks if his weapon is loaded\n");
				return;
			}
			else if ( (teamplay == 2) && (targteam == attackerteam) &&
				(attackerteam != 0) )	// gb
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";

				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";

				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";

				else
					deathstring = " loses another friend\n";

				bprint (attacker.netname);
				bprint (deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}

			else
			{
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;

				if (rnum == IT_KATANA)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}

				if (rnum == IT_PISTOL)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}

				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}

				if (rnum == IT_SMGS)
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}

				if (rnum == IT_CHAINGUN)
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}

				if (rnum == IT_GRENADE_LAUNCHER)
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";

					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}

				if (rnum == IT_GAUSS)
				{
					if (attacker.super_damage_finished > 0 && targ.health < -40)
					{
						rnum = random();

						if (rnum < 0.3)
							deathstring = " was brutalized by ";

						else if (rnum < 0.6)
							deathstring = " was smeared by ";

						else
						{
							bprint (attacker.netname);
							bprint (" rips ");
							bprint (targ.netname);
							bprint (" a new one\n");

							return;
						}
						deathstring2 = "'s quad rocket\n";
					}

					else
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";

						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n" ;
						}
					}
				}

				if (rnum == IT_SHOCK)
				{
					deathstring = " accepts ";

					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";

					else
						deathstring2 = "'s shaft\n";
				}

				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;		// killed self
			rnum = targ.watertype;

			bprint (targ.netname);

			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");

				else
					bprint (" sucks it down\n");

				return;
			}

			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");

				else
					bprint (" can't exist on slime alone\n");

				return;
			}

			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}

				if (random() < 0.5)
					bprint (" turned into hot slag\n");

				else
					bprint (" visits the Volcano God\n");

				return;
			}

			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}

			if (targ.deathtype == "falling")
			{
				targ.deathtype = string_null;
				bprint (" fell to his death\n");
				return;
			}

			//FIXME string_nul ??? maybe not necessary	//gnounc
			if(attacker.killstring)
			{//gnounc
				bprint (attacker.killstring);
				return;
			}

			bprint (" died\n");
		}
	}
};

/*
=============================================================================

	SPAWNPOINTS

=============================================================================
*/

/*FGD
@baseclass base(Appearflags, Angle, Fog, Target) size(-16 -16 -24, 16 16 32) 
	color(0 255 0) model({ "path": ":progs/player.mdl" }) = PlayerClass []
*/

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) 
The normal starting point for a level. Only one is allowed. Will fire its targets when a player is spawned here, with player as activator.

"angle" viewing angle when spawning
"fog_color"/"fog_density"/"fog_sky" set the fog when spawning at this spot (fog_sky 0 = no change, -1 = clear to 0)
*/
/*FGD
@PointClass base(PlayerClass) = info_player_start : "Player 1 start. Fires targets when a player spawns here." []
*/
void() info_player_start =
{
	setsize(self,VEC_HULL_MIN,VEC_HULL_MAX);	// for telefrag testing
	self.mangle = self.angles;
	fog_fixKeys();
}


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24) 
Only used on start map for the return point from an episode. Will fire its targets when a player is spawned here, with player as activator.

"angle" viewing angle when spawning
"fog_color"/"fog_density"/"fog_sky" set the fog when spawning at this spot (fog_sky 0 = no change, -1 = clear to 0)
"svflags" set the bits for a specific set of runes/serverflags you want to test
"style" how to interpret svflags:
	0: player will spawn here if they have any of the runes in svflags
	1: player will only spawn here if they have all of them
	2: player will NOT spawn here if they have any of them
*/
/*FGD
@PointClass base(PlayerClass) = info_player_start2 : "Player episode return point. Fires targets when a player spawns here." [
	svflags(Flags) =
	[
		1		: "Episode 1" : 0
		2		: "Episode 2" : 0
		4		: "Episode 3" : 0
		8		: "Episode 4" : 0
		16		: "Bit 5" :  0
		32		: "Bit 6" :  0
		64		: "Bit 7" :  0
		128		: "Bit 8" :  0
		256		: "Bit 9" :  0
		512		: "Bit 10" : 0
		1024	: "Bit 11" : 0
		2048	: "Bit 12" : 0
		4096	: "Bit 13" : 0
		8192	: "Bit 14" : 0
		16384	: "Bit 15" : 0
		32768	: "Bit 16" : 0
		65536	: "Bit 17" : 0
		131072	: "Bit 18" : 0
		262144	: "Bit 19" : 0
		524288	: "Bit 20" : 0
		1048576	: "Bit 21" : 0
	]
	style(Choices) : "Requirement" : 0 =
	[
		0 : "Have Any"
		1 : "Must Have All"
		2 : "Must Not Have Any"
	]
]
*/
void() info_player_start2 =
{
	setsize(self,VEC_HULL_MIN,VEC_HULL_MAX);	// for telefrag testing
	self.mangle = self.angles;
	fog_fixKeys();
	
	if (!self.svflags)
		self.svflags = 2097151;	// all bits up to 21
	if (self.style < 0 || self.style > 2)
		self.style = 0;
}


/*QUAKED info_player_start_test (1 0 0) (-16 -16 -24) (16 16 24) USE
Debug starting point for a level.  Overrides info_player_start if present and 'USE' is checked, does nothing if 'USE' is not checked. Will fire its targets when a player is spawned, here with player as activator.

"angle" viewing angle when spawning
"fog_color"/"fog_density"/"fog_sky" set the fog when spawning at this spot (fog_sky 0 = no change, -1 = clear to 0)
*/
/*FGD
@PointClass base(PlayerClass) = info_player_start_test : "Developer-only spawn point" [
	spawnflags(flags) = [
		1 : "Spawn at this one plz" : 0
	]
]
*/
void() info_player_start_test =
{
	if (!(self.spawnflags & 1))
	{
		remove(self);
		return;
	}
	self.mangle = self.angles;
	fog_fixKeys();
}
void() testplayerstart = {info_player_start_test();}	// back compat with old editors that use regioned compiles

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games

"angle" viewing angle when spawning
"fog_color"/"fog_density"/"fog_sky" set the fog when spawning at this spot (fog_sky 0 = no change, -1 = clear to 0)
*/
/*FGD
@PointClass base(PlayerClass) = info_player_deathmatch : "Deathmatch start" []
*/
void() info_player_deathmatch =
{
	fog_fixKeys();
}

// dumb way to make coop starts visible/invisible to the cyclical spawnpoint search 
// code without making that code overly complex
void(float unlock) coop_lock =
{
	if (unlock)
		self.classname = "info_player_coop";
	else
		self.classname = "info_player_coop_notyet";
}

void() coop_enable =
{
	self.classname = "info_player_coop";
	self.use = SUB_Null;
}

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) TRIGGER_FIRST
Potential spawning position(s) for coop games. Will fire its targets when a player is spawned here, with player as activator.

"angle" viewing angle when spawning
"fog_color"/"fog_density"/"fog_sky" set the fog when spawning at this spot (fog_sky 0 = no change, -1 = clear to 0)

TRIGGER_FIRST - this start won't be used to spawn coop players until triggered, so respawning players don't have to walk all the way back to the action
*/
/*FGD
@PointClass base(PlayerClass, Targetname) = info_player_coop : "Player cooperative start" [
	spawnflags(flags) = [
		1 : "Trigger first" : 0
	]
]
*/
void() info_player_coop =
{
	self.mangle = self.angles;
	if (self.spawnflags & 1)
	{
		self.classname = "info_player_coop_notyet";
		self.use = coop_enable;
	}
	self.lock = coop_lock;
	fog_fixKeys();
	setsize(self,VEC_HULL_MIN,VEC_HULL_MAX);	// for telefrag testing
}