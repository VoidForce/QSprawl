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


void() SUB_Null = {};

void(entity attacker, float damage) SUB_NullPain ={};

void() SUB_Remove = {remove(self);};


/*QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';

	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';

	else
	{
		makevectors2 (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
	// trigger angles are used for one-way touches.  An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector	vdestdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
	// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
	// calculate length of vector
	len = vlen (vdestdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
	local vector	destdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
	// calculate length of vector
	len = vlen (destdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};


//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity t, act, stemp, otemp;

//
// check for a delay
//
	if (self.delay)
	{
		// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;

		return;
	}
	
	
//
// print the message
//
	if (activator.classname == "player" && self.message != string_null)
	{
		centerprint (activator, self.message);

		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget != string_null)
	{
		t = world;

		do
		{
			t = find (t, targetname, self.killtarget);

			if (!t)
				return;

			remove (t);
		} while ( 1 );
	}
	
//
// fire targets
//
	if (self.target != string_null)
	{
		act = activator;
		t = world;

		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}

			stemp = self;
			otemp = other;
			self = t;
			other = stemp;

			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}	

};

/*in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare

	if (skill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;

	if (self.cnt == 1)
		return;

	if (!visible (self.enemy))
		return;

	self.cnt = 1;
	self.think = thinkst;
};

//call like getNetName(IT_ARMOR3); and it returns "Red Armor"
//or getNetName(self.items) or getNetname(self.weapon)
//called from dropBackpack() and startItem(). fills in any netnames that are missing. and overrides the others.
string getNetname(float item_number) =
{//gnounc
	switch(item_number) 
	{
		case IT_AXE:
			return "Axe";
		case IT_SHOTGUN:
			return "Shotgun";
		case IT_SUPER_SHOTGUN:
			return "Super Shotgun";
		case IT_NAILGUN:
			return "Nailgun";
		case IT_SUPER_NAILGUN:
			return "Perforator";
		case IT_GRENADE_LAUNCHER:
			return "Grenade Launcher";
		case IT_ROCKET_LAUNCHER:
			return "Rocket Launcher";
		case IT_LIGHTNING:
			return "Lightning Gun";
		case IT_EXTRA_WEAPON:
			return "Extra Weapon";
		case IT_SHELLS:
			return "Shells";
		case IT_NAILS:
			return "Nails";
		case IT_ROCKETS:
			return "Rockets";
		case IT_CELLS:
			return "Cells";
		case IT_ARMOR1:
			return "Green Armor";
		case IT_ARMOR2:
			return "Yellow Armor";
		case IT_ARMOR3:
			return "Red Armor";
		case IT_SUPERHEALTH:
			return "Mega Health";
		case IT_KEY1:
		{	if (world.worldtype == 0)
				return "Silver key";
			if (world.worldtype == 1)
				return "Silver runkey";
			if (world.worldtype == 2)
				return "Silver keycard";
		}
		case IT_KEY2:
		{	if (world.worldtype == 0)
				return "Gold key";
			if (world.worldtype == 1)
				return "Gold runkey";
			if (world.worldtype == 2)
				return "Gold keycard";
		}
		case IT_INVISIBILITY:
			return "Ring of Shadows";
		case IT_INVULNERABILITY:
			return "Pentagram of Protection";
		case IT_SUIT:
			return "Biohazard Suit";
		case IT_QUAD:
			return "Quad Damage";

		default:
			return string_null;
	}
};

string getMapname(string m) =
{
	switch(m) 
	{
		case "start":
			return "Introduction...";
		case "e1m1":
			return "The Slipgate Complex";
		case "e1m2":
			return "Castle of the Damned";
		case "e1m3":
			return "The Necropolis";
		case "e1m4":
			return "The Gristly Grotto";
		case "e1m5":
			return "Gloom Keep";
		case "e1m6":
			return "The Door to Chthon";
		case "e1m7":
			return "The House of Chthon";
		case "e1m8":
			return "Ziggurat Vertigo";

		case "e2m1":
			return "The Installation";
		case "e2m2":
			return "The Ogre Citadel";
		case "e2m3":
			return "The Crypt of Decay";
		case "e2m4":
			return "The Ebon Fortress";
		case "e2m5":
			return "The Wizard's Manse";
		case "e2m6":
			return "The Dismal Oubliette";
		case "e2m7":
			return "The Underearth";

		case "e3m1":
			return "Termination Central";
		case "e3m2":
			return "The Vaults of Zin";
		case "e3m3":
			return "The Tomb of Terror";
		case "e3m4":
			return "Satan's Dark Delight";
		case "e3m5":
			return "The Wind Tunnels";
		case "e3m6":
			return "Chambers of Torment";
		case "e3m7":
			return "The Haunted Halls";

		case "e4m1":
			return "The Sewage System";
		case "e4m2":
			return "The Tower of Despair";
		case "e4m3":
			return "The Elder God Shrine";
		case "e4m4":
			return "The Palace of Hate";
		case "e4m5":
			return "Hell's Atrium";
		case "e4m6":
			return "The Pain Maze";
		case "e4m7":
			return "Azure Agony";
		case "e4m8":
			return "The Nameless City";
		case "end":
			return "Shub-Niggurath's Pit";

		case "dm1":
			return "Place of two Deaths";
		case "dm2":
			return "Claustrophobopolis";
		case "dm3":
			return "The Abandoned Base";
		case "dm4":
			return "The Bad Place";
		case "dm5":
			return "The Cistern";
		case "dm6":
			return "The Dark Zone";

		default:
			return string_null;
	}
};

float getAmmotypeByWeapon(float it_num)
{
	switch(it_num)
	{
		case IT_AXE:
			return 0;
		case IT_SHOTGUN:
			return IT_NAILS;
		case IT_SUPER_SHOTGUN:
			return IT_SHELLS;
		case IT_NAILGUN:
			return IT_NAILS;
		case IT_SUPER_NAILGUN:
			return IT_NAILS;
		case IT_GRENADE_LAUNCHER:
			return IT_ROCKETS;
		case IT_ROCKET_LAUNCHER:
			return IT_CELLS;
		case IT_LIGHTNING:
			return IT_CELLS;
		default:
			return IT_SHELLS;
	}
};

string getModelByNum(float it_num)
{
	switch(it_num)
	{
		case IT_AXE:
			return "progs/v_axe.mdl";
		case IT_SHOTGUN:
			return "progs/v_shot.mdl";
		case IT_SUPER_SHOTGUN:
			return "progs/v_shot2.mdl";
		case IT_NAILGUN:
			return "progs/v_nail.mdl";
		case IT_SUPER_NAILGUN:
			return "progs/v_nail2.mdl";
		case IT_GRENADE_LAUNCHER:
			return "progs/v_rock.mdl";
		case IT_ROCKET_LAUNCHER:
			return "progs/v_rock2.mdl";
		case IT_LIGHTNING:
			return "progs/v_light.mdl";
		case IT_SHELLS:
			return "maps/b_shell0.bsp";	//b_shell1.bsp is big shells.
		case IT_NAILS:
			return "maps/b_nail0.bsp";
		case IT_ROCKETS:
			return "maps/b_rock0.bsp";
		case IT_CELLS:
			return "maps/b_batt0.bsp";
		case IT_ARMOR1:
			return "progs/armor.mdl";
		case IT_ARMOR2:
			return "progs/armor.mdl";
		case IT_ARMOR3:
			return "progs/armor.mdl";
		case IT_SUPERHEALTH:
			return "maps/b_bh100.bsp";
		case IT_KEY1:
		{
			if (world.worldtype == 0)
				return "progs/w_s_key.mdl";

			else if(world.worldtype == 1)
				return "progs/m_s_key.mdl";

			else if(world.worldtype == 2)
				return "progs/b_s_key.mdl";
		}
		case IT_KEY2:
		{
			if (world.worldtype == 0)
				return "progs/w_g_key.mdl";

			else if(world.worldtype == 1)
				return "progs/m_g_key.mdl";

			else if(world.worldtype == 2)
				return "progs/b_g_key.mdl";
		}
		case IT_INVISIBILITY:
			return "progs/invisibl.mdl";
		case IT_INVULNERABILITY:
			return "progs/invulner.mdl";
		case IT_SUIT:
			return "progs/suit.mdl";
		case IT_QUAD:
			return "progs/quaddama.mdl";
		default :
			return string_null;
	}
};

// copper mod's code for easier dprints (by Lunaran)
void(string s, string ss) dprint2 = 
	{ dprint(s); dprint(ss); }
void(string s, string ss, string sss) dprint3 = 
	{ dprint(s); dprint(ss); dprint(sss); }
void(string s, string ss, string sss, string ssss) dprint4 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); }
void(string s, string ss, string sss, string ssss, string sssss) dprint5 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); }
void(string s1, string s2, string s3, string s4, string s5, string s6) dprint6 = 
	{ dprint(s1); dprint(s2); dprint(s3); dprint(s4); dprint(s5); dprint(s6); dprint("\n"); }
void() endl =
	{ dprint("\n");}
	
void(vector a, vector b, float flag, vector c) sendMessageImpact =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_IMPACT);
	WriteCoord (MSG_BROADCAST, a_x);
	WriteCoord (MSG_BROADCAST, a_y);
	WriteCoord (MSG_BROADCAST, a_z);
	WriteCoord (MSG_BROADCAST, b_x);
	WriteCoord (MSG_BROADCAST, b_y);
	WriteCoord (MSG_BROADCAST, b_z);
	WriteByte (MSG_BROADCAST, flag);
	if (flag && flag < 4)
	{
		WriteCoord (MSG_BROADCAST, c_x);
		WriteCoord (MSG_BROADCAST, c_y);
		WriteCoord (MSG_BROADCAST, c_z);
	}
};

void(vector a, vector b, float flag, float type) sendMessageVecVecFlag =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, type);
	WriteCoord (MSG_BROADCAST, a_x);
	WriteCoord (MSG_BROADCAST, a_y);
	WriteCoord (MSG_BROADCAST, a_z);
	WriteCoord (MSG_BROADCAST, b_x);
	WriteCoord (MSG_BROADCAST, b_y);
	WriteCoord (MSG_BROADCAST, b_z);
	WriteByte (MSG_BROADCAST, flag);
};

void(vector a, vector b, float type) sendMessageVecVec =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, type);
	WriteCoord (MSG_BROADCAST, a_x);
	WriteCoord (MSG_BROADCAST, a_y);
	WriteCoord (MSG_BROADCAST, a_z);
	WriteCoord (MSG_BROADCAST, b_x);
	WriteCoord (MSG_BROADCAST, b_y);
	WriteCoord (MSG_BROADCAST, b_z);
};

void(vector a, float type) sendMessageVec =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, type);
	WriteCoord (MSG_BROADCAST, a_x);
	WriteCoord (MSG_BROADCAST, a_y);
	WriteCoord (MSG_BROADCAST, a_z);
};

void(vector offset) setHead =
{
	//self.origin_old = self.origin;
	//self.lasttick_time = time;
	//self.head_offset_old = self.head_offset;
	self.head_offset = offset;
};

vector(entity target) findHeadPosition =
{
	vector result;
	/*
	vector old_pos, new_pos, result;
	
	makevectors2(target.angles_old); // fucking inverted x in makevectors, always forgeting about it, cost me half of the day
	old_pos = target.origin_old + v_forward * target.head_offset_old_x + v_right * target.head_offset_old_y;
	old_pos_z += target.head_offset_old_z;
	
	makevectors2(target.angles);
	new_pos = target.origin + v_forward * target.head_offset_x + v_right * target.head_offset_y;
	new_pos_z += target.head_offset_z;
	result = new_pos;
	result = lerpVector(old_pos, new_pos, (0.1 - (time - target.lasttick_time)) * 10);
	*/
	
	makevectors2(target.angles);
	result = target.origin + v_forward * target.head_offset_x + v_right * target.head_offset_y;
	result_z += target.head_offset_z;
	
	return result;
};

void weaponThink(void() thinkfunc, float timer) =
{
	if (self.sprawlflags & SFL_INQUICKMELEE)
	{
		// somehow we get into think after quickmelee started, reset frame and cancel current think
		self.weaponframe = 1;
		return;
	}
	self.think = thinkfunc;
	self.nextthink = time + timer;
};