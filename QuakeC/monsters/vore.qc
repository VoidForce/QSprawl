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
/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd /raid/quake/id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11

$frame pain1 pain2 pain3 pain4 pain5 

$frame death1 death2 death3 death4 death5 death6 death7

$frame	walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame	walk11 walk12

/*
================
ShalMissile
================
*/


void() shieldOn =
{
	self.monsterflags |= MFL_SHIELD;
	self.eA.frame = 1;
	self.eA.effects |= EF_NOLERP;
	self.eA.touch = pushAway;
};

void(float timer) shieldOff =
{
	self.monsterflags -= self.monsterflags & MFL_SHIELD;
	self.eA.frame = 0;
	self.eA.effects |= EF_NOLERP;
	self.eA.touch = SUB_Null;
	self.nextthinkA = time + timer;
	self.thinkA = shieldOn;
};

void(vector offset) ShalGrenade =
{
	entity missile;
	vector dir;
	vector start, end, end_forward;
	float distance, height;

	makevectors2(self.angles);
	distance = vlen(self.enemy.trail2 - self.origin);
	height = self.enemy.trail2_z - self.origin_z;
	// too far and too high
	if (distance > 1024 && height > 32)
	{
		self.attack_finished = time + 2;
		return;
	}
		
	start = self.origin + v_forward * offset_x + v_right * offset_y + [0, 0, offset_z];
	end = self.enemy.trail2 + [random() * 8, random() * 8, 0] + [0, 0, distance*0.8 + height];
	end_forward = self.enemy.trail2;
	end = lerpVector(end_forward, end, (distance - 256) / 768);
	dir = normalize((end - start) );

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.velocity = dir * OGRE_NADE_VEL;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = OgreGrenadeTouch;
	missile.nextthink = time + 2.5;
	missile.think = OgreGrenadeExplode;
	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, start);
	missile.isgrenade = 1;
	appendToList(missile);
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
};

void(vector offset) ShalMissile =
{
	entity 	missile;
	float distance;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
	missile = spawn ();
	missile.classname = "vore_ball";	//gnounc
	missile.owner = self;

	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_BOUNCE;
	setmodel (missile, "progs/missle_notrail.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

	missile.origin = self.origin + '0 0 10' + offset;
	sendMessageVec(missile.origin + '0 0 -8', TE_ROBOTHEAD_EXPLOSION);

	missile.velocity = [0, 0, 400];
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = [crandom() * 20, crandom()* 20, crandom()* 20 ];
	distance = vlen(self.origin - self.enemy.origin);
	missile.fA = -2;
	distance *= 0.05;
	missile.vA = self.enemy.trail2 + [crandom() * distance, crandom() * distance, -64 ];
	missile.vB = '0 0 -800';
	missile.nextthink = time + 0.3;
	missile.think = ShalIgnition;
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
};

void() ShalIgnition =
{
	self.movetype = MOVETYPE_FLYMISSILE;
	self.avelocity = VEC_ORIGIN;
	setmodel (self, "progs/missle.mdl");
	setsize (self, '0 0 0', '0 0 0');	
	self.nextthink = time + 0.01;
	self.think = ShalHome;
};

#define FL_STOPCLIMB 1

void() ShalHome =
{
	self.fD = max(self.fD, self.origin_z - self.vA_z);
	if (!(self.sprawlflags & FL_STOPCLIMB) && self.origin_z < self.vA_z + 64)
		self.velocity = '0 0 800';
	else
	{
		self.sprawlflags |= FL_STOPCLIMB;
		reflectVector(self.vB, self.vA - self.origin, self.fA);
		self.velocity = normalize(reflect) * 800;
	}
	self.angles = vectoangles(self.velocity);
	
	if (self.angles_x > 260 && self.angles_x < 280)
		return;

	self.nextthink = time + 0.02;
	self.think = ShalHome;	
};

void() ShalMissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	T_RadiusDamage (self, self.owner, 40, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() shal_stand     =[      $walk1,       shal_stand    ] {ai_stand();};

void() shal_walk1     =[      $walk2,       shal_walk2    ] 
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);

	ai_walk(6);
};

void() shal_walk2     =[      $walk3,       shal_walk3    ] {ai_walk(4);};
void() shal_walk3     =[      $walk4,       shal_walk4    ] {ai_walk(0);};
void() shal_walk4     =[      $walk5,       shal_walk5    ] {ai_walk(0);};
void() shal_walk5     =[      $walk6,       shal_walk6    ] {ai_walk(0);};
void() shal_walk6     =[      $walk7,       shal_walk7    ] {ai_walk(0);};
void() shal_walk7     =[      $walk8,       shal_walk8    ] {ai_walk(5);};
void() shal_walk8     =[      $walk9,       shal_walk9    ] {ai_walk(6);};
void() shal_walk9     =[      $walk10,       shal_walk10    ] {ai_walk(5);};
void() shal_walk10    =[      $walk11,       shal_walk11    ] {ai_walk(0);};
void() shal_walk11    =[      $walk12,       shal_walk12    ] {ai_walk(4);};
void() shal_walk12    =[      $walk1,       shal_walk1    ] {ai_walk(5);};

void() shal_run1     =[      $walk2,       shal_run2    ] 
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
	ai_run(6);
};

void() shal_run2     =[      $walk3,       shal_run3    ] {ai_run(4);};
void() shal_run3     =[      $walk4,       shal_run4    ] {ai_run(0);};
void() shal_run4     =[      $walk5,       shal_run5    ] {ai_run(0);};
void() shal_run5     =[      $walk6,       shal_run6    ] {ai_run(0);};
void() shal_run6     =[      $walk7,       shal_run7    ] {ai_run(0);};
void() shal_run7     =[      $walk8,       shal_run8    ] {ai_run(5);};
void() shal_run8     =[      $walk9,       shal_run9    ] {ai_run(6);};
void() shal_run9     =[      $walk10,       shal_run10    ] {ai_run(5);};
void() shal_run10    =[      $walk11,       shal_run11    ] {ai_run(0);};
void() shal_run11    =[      $walk12,       shal_run12    ] {ai_run(4);};
void() shal_run12    =[      $walk1,       shal_run1    ] {ai_run(5);};

// -- decide attack type
/*
	Average height of rocket trajectory would be ~0.52 of distance
	we calculate three points that are represent 60 degree up, a bit forward, 60 degree down to the target
	then we trace between this points, if some traces fail then we use grenade attack.
	
	if target is above the Vore, we put A point up to the same height as player, then missile will start to turn, cause that's how rocket flies in ShalHome
*/
void() shal_attack =
{
	float distance;
	vector direction;
	vector A,B,C;
	
// shield stuff
	shieldOff(5 - skill); // 4 seconds down
	
	// 0.87 sin 60
	// 0.5 cos 60
// distance without height component
	distance = vlen([self.origin_x, self.origin_y, 0] - [self.enemy.trail2_x, self.enemy.trail2_y, 0]);
// direction without height component
	direction = self.enemy.trail2 - self.origin;
	direction_z = 0;
	direction = normalize(direction);
// if player is above vore, compensate
	if (self.origin_z < self.enemy.trail2_z)
		A = self.origin + [0,0,self.enemy.trail2_z - self.origin_z];
	else
		A = self.origin;
// 60 degrees up
	B = A + direction * (0.3 * distance) + [0, 0, 0.52 * distance]; // 0.52 is 0.87 of 60 degrees, 0.3 is 0.5 of 60 degrees
// forward
	C = B + direction * (0.4 * distance); // 0.4 is distance left after we subtract 2 60 degrees projections (1 - 0.3 x 2)
// we ignore monsters, cause it's fun when rockets hit them
	traceline(A, B, IGNOREMONSTERS, self);
	if (trace_fraction == 1)
	{
		traceline(B,C, IGNOREMONSTERS, world);
		if (trace_fraction == 1)
		{
			traceline(C, self.enemy.trail2, IGNOREMONSTERS, world);
			if (trace_fraction == 1)
				shal_missile1();
			return;
		}
	}
	shal_grenade1();
	
	//if (!(self.sprawlflags & MFL_HASDRONE))
	//	spawn_drone( self.origin + '0 0 64');	
};

void() shal_missile1     =[      $attack1,       shal_missile2    ] {Think(0.05);
	sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
	ai_face();
};

void() shal_missile2     =[      $attack2,       shal_missile3    ] {Think(0.05);ai_face();};
void() shal_missile3     =[      $attack3,       shal_missile4    ] {Think(0.05);ai_face();};
void() shal_missile4     =[      $attack4,       shal_missile5    ] {Think(0.05);ai_face();};
void() shal_missile5     =[      $attack5,       shal_missile6    ] {ShalMissile('-16 -16 0');};
void() shal_missile6     =[      $attack6,       shal_missile7    ] {ShalMissile('-8 -8 0');};
void() shal_missile7     =[      $attack7,       shal_missile8    ] {ShalMissile('0 0 0');};
void() shal_missile8     =[      $attack8,       shal_missile9    ] {ShalMissile('8 8 0');};
void() shal_missile9     =[      $attack9,       shal_missile10   ] {ShalMissile('16 16 0');};
void() shal_missile10    =[      $attack10,      shal_missile11   ] {self.attack_finished = time + 4; ai_face();};
void() shal_missile11    =[      $attack11,      shal_run1   ] {};

void() shal_grenade1     =[      $attack1,       shal_grenade2    ] {Think(0.05);
	sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
	ai_face();
};

void() shal_grenade2     =[      $attack2,       shal_grenade3    ] {Think(0.05);ai_face();};
void() shal_grenade3     =[      $attack3,       shal_grenade4    ] {Think(0.05);ai_face();};
void() shal_grenade4     =[      $attack4,       shal_grenade5    ] {Think(0.05);ai_face();};
void() shal_grenade5     =[      $attack5,       shal_grenade6    ] {ai_face();ShalGrenade('-16 -16 0');};
void() shal_grenade6     =[      $attack6,       shal_grenade7    ] {ai_face();};
void() shal_grenade7     =[      $attack7,       shal_grenade8    ] {ai_face();ShalGrenade('0 0 0');};
void() shal_grenade8     =[      $attack8,       shal_grenade9    ] {ai_face();};
void() shal_grenade9     =[      $attack9,       shal_grenade10   ] {ai_face();ShalGrenade('16 16 0');};
void() shal_grenade10    =[      $attack10,      shal_grenade11   ] {self.attack_finished = time + 4; ai_face();};
void() shal_grenade11    =[      $attack11,      shal_run1   ] {};

void() shal_pain1       =[      $pain1, shal_pain2      ] {};
void() shal_pain2       =[      $pain2, shal_pain3      ] {};
void() shal_pain3       =[      $pain3, shal_pain4      ] {};
void() shal_pain4       =[      $pain4, shal_pain5      ] {};
void() shal_pain5       =[      $pain5, shal_run1      ] {};

void() shal_death1      =[      $death1,        shal_death2     ] {};
void() shal_death2      =[      $death2,        shal_death3     ] {};
void() shal_death3      =[      $death3,        shal_death4     ] {};
void() shal_death4      =[      $death4,        shal_death5     ] {};
void() shal_death5      =[      $death5,        shal_death6     ] {};
void() shal_death6      =[      $death6,        shal_death7     ] {};
void() shal_death7      =[      $death7,        decay    ] {};


void(entity attacker, float damage) shalrath_pain =
{
	if (self.pain_finished > time)
		return;
	playPainSound("shalrath/pain.wav");
	shal_pain1();
	self.pain_finished = time + 3;
};

void() shalrath_die =
{
// remove shield! it's important
	self.eA.think = SUB_Remove;
	self.eA.nextthink = time + 0.01;
	
	dropAmmo(self.origin, DROP_ROCKETS, 4);
	dropAmmo(self.origin, DROP_CELLS, 4);
	// check for gib
	if (self.health < -90)
	{
		sendMessageVec(self.origin, TE_EXPLOSION); // before throwhead, which changes origin
		ThrowHead ("progs/h_shal.mdl",  self.lasthit_damage);
		ThrowGib ("progs/m_gib_01.mdl", self.lasthit_damage);
		ThrowGib ("progs/m_gib_02.mdl", self.lasthit_damage);
		ThrowGib ("progs/m_gib_03.mdl", self.lasthit_damage);
		ThrowGib ("progs/shalrath_gib_leg.mdl", self.lasthit_damage);
		ThrowGib ("progs/shalrath_gib_leg.mdl", self.lasthit_damage);
		ThrowGib ("progs/shalrath_gib_leg.mdl", self.lasthit_damage);

		return;
	}

	sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	shal_death1();
	self.solid = SOLID_NOT;
	// insert death sounds here
};


//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void() monster_shalrath =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model2 ("progs/shalrath.mdl");
	precache_model2 ("progs/shalrath_shield.mdl");
	precache_model2 ("progs/h_shal.mdl");
	precache_model ("progs/missle.mdl");
	precache_model ("progs/grenade.mdl");
	
	precache_model2 ("progs/missle_notrail.mdl");
	precache_model2 ("progs/shalrath_gib_leg.mdl");
	
	precache_sound2 ("shalrath/attack.wav");
	precache_sound2 ("shalrath/attack2.wav");
	precache_sound2 ("shalrath/death.wav");
	precache_sound2 ("shalrath/idle.wav");
	precache_sound2 ("shalrath/pain.wav");
	precache_sound2 ("shalrath/sight.wav");
	precache_sound ("weapons/grenade.wav");
	
	// drone
	precache_model ("progs/drone.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	setmodel (self, "progs/shalrath.mdl");

	//gnounc
	self.noise = "shalrath/sight.wav";	//gnounc
	self.netname = "Vore";
	self.killstring = " was exploded by a Vore\n";

	setsize (self, VEC_HULL2_MIN, '32 32 20');
	self.health = VORE_HEALTH;
	self.max_health = VORE_HEALTH;
	self.monsterflags |= MFL_ROBOT | MFL_SHIELD;
	self.monstertype = TYPE_VORE;
	self.th_stand = shal_stand;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shalrath_die;
	self.th_pain = shalrath_pain;
	self.th_missile = shal_attack;

	self.think = walkmonster_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
	
	self.eA = spawn();
	self.eA.owner = self;
	self.eA.solid = SOLID_TRIGGER;
	self.eA.touch = pushAway;
	self.eA.movetype = MOVETYPE_NOCLIP;
	setmodel (self.eA, "progs/shalrath_shield.mdl");
	setsize(self.eA, '-40 -40 -32', '40 40 40');
	setorigin(self.eA, self.origin);
	self.eA.frame = 1;
	self.eA.alpha = 0.1;
	self.eA.think = updateShieldPosition;
	self.eA.nextthink = time + 0.1;
};

void() updateShieldPosition =
{
	setorigin(self, self.owner.origin);
	if (self.fA)
	{
		if (self.alpha < 0.5)
			self.alpha += 0.025;
		else
		{
			self.fA = 0;
			self.alpha = 0.5;
		}
	}
	else
	{
		if (self.alpha > 0.2)
			self.alpha -= 0.025;
		else
		{
			self.fA = 1;
			self.alpha = 0.2;
		}
	}
	
	self.think = updateShieldPosition;
	self.nextthink = time + 0.1;
};

void() pushAway = 
{
	if (!(other.flags & FL_CLIENT))
		return;
	
	T_Push(other, self, 600, 200);
	other.pushback_time = time + 0.3;
}

/*
void() drone_die =
{
	self.owner.sprawlflags -= self.owner.sprawlflags & MFL_HASDRONE;
	self.touch = SUB_Null;
	sendMessageVec(self.origin, TE_EXPLOSION); // before throwhead, which changes origin
	T_RadiusDamage (self, self, 40, world);
	ThrowHead("progs/h_wizard.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_01.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_02.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_03.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_04.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_05.mdl", self.lasthit_damage);
	SUB_Remove();
};

void(vector lorigin) spawn_drone =
{
	entity oldself;

	spawn_tfog (lorigin);
	//spawn_tdeath(lorigin, self);
	self.sprawlflags |= MFL_HASDRONE;
	oldself = self;
	self = spawn();
	self.owner = oldself;
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setorigin (self, lorigin);
	setmodel (self, "progs/drone.mdl");

	//gnounc
	self.noise = "wizard/wsight.wav";	//gnounc
	self.netname = "Drone";
	self.killstring = " couldn't handle this air superiority\n";

	setsize (self, '-16 -16 0', '16 16 24');// 24 48
	//self.head_offset = '0 0 28';
	self.head_size = 0;
	self.health = 40;
	self.max_health = 40;
	self.gib_threshold = 40;
	self.monstertype = TYPE_SCRAG;
	self.fA = 2; // amoung of rockets to fire, will be depleted fully
	self.angles_y = vectoyaw(oldself.enemy.origin - oldself.origin);
	
	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wiz_fast1;//Wiz_Missile;
	self.th_pain = Wiz_Pain;
	self.th_die = drone_die;
	self.yaw_speed = 75;
	self.sprawlflags |= MFL_NOTMONSTER;
		
	flymonster_start ();
	self = oldself;
};
*/