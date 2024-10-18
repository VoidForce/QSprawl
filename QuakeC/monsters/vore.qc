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

const vector SIZE_SHIELD = '32 32 48';
const vector SIZE_NORMAL = '32 32 20';

// SHIELD ----------------------------------------------------------
void() shieldOn =
{
	if (self.health < 0)
		return;
	self.monsterflags |= MFL_SHIELD;
	self.eA.frame = 1;
	self.eA.effects |= EF_NOLERP;
	self.eA.touch = pushAway;

	setsize (self, VEC_HULL2_MIN, SIZE_SHIELD);
};

void(float timer) shieldOff =
{
	if (self.health < 0)
		return;
	setsize (self, VEC_HULL2_MIN, SIZE_NORMAL);
	self.monsterflags -= self.monsterflags & MFL_SHIELD;
	self.eA.frame = 0;
	self.eA.effects |= EF_NOLERP;
	self.eA.touch = SUB_Null;

	self.nextthinkA = time + timer;
	self.thinkA = shieldOn;
};

// GRENADE -----------------------------------------------------------------------
void() ShalGrenadeExplode =
{
	removeFromList(self);
	T_RadiusDamagePlayer(self, self.owner, 10, world, 320, 128, 1);
	sound (self, CHAN_VOICE, "weapons/pl_explode.wav", 1, ATTN_NORM);
	sendMessageVec(self.origin, TE_EXPLOSION_PLASMA);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	setmodel (self, "progs/p_explode.spr");
	s_explode1();
};

void() ShalGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.takedamage == DAMAGE_AIM)
	{
		T_Damage (other, self, self.owner, 5, NOFLAGS);
		T_Push (other, self, 100, 0);
		self.nextthink = time + 0.1;
		//ShalGrenadeExplode();
		return;
	}
	self.nextthink = time + 0.3;
	self.touch = SUB_Null;
	
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void(vector offset) ShalGrenade =
{
	entity missile;
	vector dir;
	vector start, end, end_forward;
	float distance, height;
	vector pos;
	
	pos = getPlayerPosition(self.enemy, 2);

	makevectors2(self.angles);
	distance = vlen(pos - self.origin);
	height = pos_z - self.origin_z;
	// too far and too high
	/*
	if (distance > 1024 && height > 32)
	{
		self.attack_finished = time + 2;
		return;
	}*/
		
	start = self.origin + v_forward * offset_x + v_right * offset_y + [0, 0, offset_z];
	end = pos + [random() * 8, random() * 8, 0] + [0, 0, distance*0.8 + height];
	end_forward = pos;
	end = lerpVector(end_forward, end, (distance - 256) / 768);
	dir = normalize((end - start) );

	missile = spawn ();
	missile.clip = CLIP_PROJECTILE;
	missile.classname = "plasma";
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.velocity = dir * OGRE_NADE_VEL;
	missile.avelocity = '300 -300 -300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = ShalGrenadeTouch;
	missile.nextthink = time + 2.5;
	missile.think = ShalGrenadeExplode;
	setmodel (missile, "progs/p_grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, start);
	//missile.isgrenade = 1;
	appendToList(missile);
	self.effects = self.effects | EF_MUZZLEFLASH;
	//sound (self, CHAN_WEAPON, "shalrath/attack.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "weapons/f_grenade.wav", 1, ATTN_NORM);
};

// MISSILE ------------------------------------------------------------------------------------------
void(vector offset, float trail) ShalMissile =
{
	entity 	missile;
	float distance;

	self.effects = self.effects | EF_MUZZLEFLASH;
	//sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
	missile = spawn ();
	missile.clip = CLIP_PROJECTILE;
	missile.classname = "vore_ball";	//gnounc
	missile.owner = self;

	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_BOUNCE;
	setmodel (missile, "progs/missle_notrail.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

	missile.origin = self.origin + '0 0 10' + offset;
	sendMessageVec(missile.origin + '0 0 -8', TE_ROBOTHEAD_EXPLOSION);
	sound (self, CHAN_AUTO, "weapons/r_exp3_far.wav", 1, ATTN_NONE);
	
	missile.velocity = [0, 0, 400];
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = [crandom() * 20, crandom()* 20, crandom()* 20 ];
	distance = vlen(self.origin - getPlayerPosition(self.enemy, trail));
	missile.fA = -2;
	distance *= 0.05;
	missile.vA = getPlayerPosition(self.enemy, trail) + [crandom() * distance, crandom() * distance, -64 ];
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
	
	self.vC = self.velocity;
	if (self.angles_x > 260 && self.angles_x < 280)
		return;

	self.nextthink = time + 0.02;
	self.think = ShalHome;	
};

void() ShalMissileTouch =
{
	vector start;

	if (other == self.owner)
		return;		// don't explode on owner

	T_RadiusDamagePlayer(self, self.owner, 30, world, 320, 32);
	sendMessageVec(self.origin, TE_EXPLOSION);
	
	start = self.origin + (-16 * normalize(self.vC));
	explodeShrapnel(start, self.owner, skill + rint(random() * 6));
	
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void(vector org, entity ownr, float count = 1) explodeShrapnel = 
{ 
	entity shrapnel;
	vector dir;
	float i;
	float A,B;
	
	if (count > 1)
		for (i=0; i < count; i++)
		{	
			A = rint(random() * 15); //bounds check?
			B = rint(random() * 15);
			// spherecal coordinates
			// x = sin A cos B
			// y = sin A sin B
			// z = cos A
			dir = normalize([CIRCLEX[A] * CIRCLEY[B], CIRCLEX[A] * CIRCLEX[B], CIRCLEY[A]] * 100);
			shrapnel = spawn();
			shrapnel.owner = ownr;
			shrapnel.movetype = MOVETYPE_BOUNCE;
			shrapnel.solid = SOLID_BBOX;
			shrapnel.angles = vectoangles(dir);
			shrapnel.touch = shal_shrapnel_touch;
			shrapnel.classname = "shrapnel";
			shrapnel.think = SUB_Remove;
			shrapnel.nextthink = time + 2;
			shrapnel.thinkA = shrapnelSkinChange;
			shrapnel.nextthinkA = time + 0.2;
			setmodel(shrapnel, "progs/shrapnel.mdl");
			setsize(shrapnel, '0 0 0', '0 0 0');
			shrapnel.scale = 2;
			setorigin(shrapnel, org);
			shrapnel.velocity = dir * (1200 + crandom() * 600);
			shrapnel.avelocity = [crandom()*100,crandom()*100,crandom()*100];
		}
	//shrapnel.avelocity = [random() * 200, random() * 200, random() * 200];
};

void() shrapnelSkinChange =
{
	if (self.skin < 7)
	{
		self.skin++;
		self.thinkA = shrapnelSkinChange;
		self.nextthinkA = time + 0.1;
	}
};

void() shal_shrapnel_touch =
{
	vector direction;
	if (other.solid == SOLID_TRIGGER || self.skin == 7) // assuming our velocity is super low already
		return;	// trigger field, do nothing
	
	if (pointcontents(self.origin) == CONTENT_SKY || self.velocity == '0 0 0')
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage == DAMAGE_AIM)
	{
		if (other.monsterflags & MFL_SHIELD)
			sendMessageImpact(self.origin, other.origin, IMPACT_SHIELD, VEC_ORIGIN); 
		else
		{
			direction = normalize(other.origin - self.origin);
			// make blood
			if (other.monsterflags & MFL_ROBOT)
				sendMessageImpact(self.origin, -direction, IMPACT_ROBOT, VEC_ORIGIN); 
			else
				sendMessageImpact(self.origin, -direction, IMPACT_FLESH, VEC_ORIGIN); 
			T_Damage (other, self, self.owner, lerp(2, 20, vlen(self.velocity)/1000), 0);
		}
		remove(self);
	}
	//self.angles = vectoangles(self.velocity);
};


void() shal_stand     =[      $walk1,       shal_stand    ] {ai_stand();};

void() shal_walk1     =[      $walk2,       shal_walk2    ] 
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);

	ai_walk(6);
};

void() shal_walk2     =[ $walk3, 	shal_walk3	] {ai_walk(4);};
void() shal_walk3     =[ $walk4, 	shal_walk4	] {ai_walk(0);};
void() shal_walk4     =[ $walk5, 	shal_walk5	] {ai_walk(0);};
void() shal_walk5     =[ $walk6, 	shal_walk6	] {ai_walk(0);};
void() shal_walk6     =[ $walk7, 	shal_walk7	] {ai_walk(0);};
void() shal_walk7     =[ $walk8, 	shal_walk8	] {ai_walk(5);};
void() shal_walk8     =[ $walk9, 	shal_walk9	] {ai_walk(6);};
void() shal_walk9     =[ $walk10,	shal_walk10	] {ai_walk(5);};
void() shal_walk10    =[ $walk11,	shal_walk11	] {ai_walk(0);};
void() shal_walk11    =[ $walk12,	shal_walk12	] {ai_walk(4);};
void() shal_walk12    =[ $walk1, 	shal_walk1	] {ai_walk(5);};

void() shal_run1     =[      $walk2,       shal_run2    ] 
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
	ai_run(6);
};

void() shal_run2     =[ $walk3, 	shal_run3  ] {ai_run(4);};
void() shal_run3     =[ $walk4, 	shal_run4  ] {ai_run(0);};
void() shal_run4     =[ $walk5, 	shal_run5  ] {ai_run(0);};
void() shal_run5     =[ $walk6, 	shal_run6  ] {ai_run(0);};
void() shal_run6     =[ $walk7, 	shal_run7  ] {ai_run(0);};
void() shal_run7     =[ $walk8, 	shal_run8  ] {ai_run(5);};
void() shal_run8     =[ $walk9, 	shal_run9  ] {ai_run(6);};
void() shal_run9     =[ $walk10,	shal_run10 ] {ai_run(5);};
void() shal_run10    =[ $walk11,	shal_run11 ] {ai_run(0);};
void() shal_run11    =[ $walk12,	shal_run12 ] {ai_run(4);};
void() shal_run12    =[ $walk1, 	shal_run1  ] {ai_run(5);};

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
	vector pos;
	
	if (self.attack_finished > time)
		return;
	
	pos = getPlayerPosition(self.enemy, 2);
	
// shield stuff
	shieldOff(5 - skill); // 4 seconds down
	
	// 0.87 sin 60
	// 0.5 cos 60
// distance without height component
	distance = vlen([self.origin_x, self.origin_y, 0] - [pos_x, pos_y, 0]);
	if (distance < 256)
	{
		shal_grenade1();
		return;
	}
// direction without height component
	direction = pos - self.origin;
	direction_z = 0;
	direction = normalize(direction);
// if player is above vore, compensate
	if (self.origin_z < pos_z)
		A = self.origin + [0, 0, pos_z - self.origin_z];
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
			traceline(C, pos, IGNOREMONSTERS, world);
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
	self.pain_finished = time + 1;
};

void() shal_missile2     =[      $attack2,       shal_missile3    ] {Think(0.05);ai_face();};
void() shal_missile3     =[      $attack3,       shal_missile4    ] {Think(0.05);ai_face();};
void() shal_missile4     =[      $attack4,       shal_missile5    ] {Think(0.05);ai_face();};
void() shal_missile5     =[      $attack5,       shal_missile6    ] {ShalMissile('-16 -16 0',4);};
void() shal_missile6     =[      $attack6,       shal_missile7    ] {ShalMissile('-8 -8 0',3);};
void() shal_missile7     =[      $attack7,       shal_missile8    ] {ShalMissile('0 0 0',2);};
void() shal_missile8     =[      $attack8,       shal_missile9    ] {ShalMissile('8 8 0',1);};
void() shal_missile9     =[      $attack9,       shal_missile10   ] {ShalMissile('16 16 0',0);self.attack_finished = time + 4;};
void() shal_missile10    =[      $attack10,      shal_missile11   ] {ai_face();};
void() shal_missile11    =[      $attack11,      shal_run1   ] {};

void() shal_grenade1     =[      $attack1,       shal_grenade2    ] {Think(0.05);
	sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
	ai_face();
	self.pain_finished = time + 1;
};

void() shal_grenade2     =[      $attack2,       shal_grenade3    ] {Think(0.05);ai_face();};
void() shal_grenade3     =[      $attack3,       shal_grenade4    ] {Think(0.05);ai_face();};
void() shal_grenade4     =[      $attack4,       shal_grenade5    ] {Think(0.05);ai_face();};
void() shal_grenade5     =[      $attack5,       shal_grenade6    ] {ai_face();ShalGrenade('-16 -16 0');};
void() shal_grenade6     =[      $attack6,       shal_grenade7    ] {ai_face();};
void() shal_grenade7     =[      $attack7,       shal_grenade8    ] {ai_face();ShalGrenade('0 0 0');};
void() shal_grenade8     =[      $attack8,       shal_grenade9    ] {ai_face();};
void() shal_grenade9     =[      $attack9,       shal_grenade10   ] {ai_face();ShalGrenade('16 16 0');self.attack_finished = time + 4;};
void() shal_grenade10    =[      $attack10,      shal_grenade11   ] {ai_face();};
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
	remove(self.eA);
	
	dropAmmo(self.origin, DROP_ROCKETS, 6, 4, 2, 1);
	dropAmmo(self.origin, DROP_CELLS, 4, 4, 4, 6);
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
void() monster_shalrath_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_shalrath";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/shalrath.mdl");
	setsize (self, VEC_HULL2_MIN, SIZE_SHIELD);
	
	self.noise = "shalrath/sight.wav";	//gnounc
	self.netname = "Vore";
	self.killstring = " couldn't survive the artillery strike\n";
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

void() monster_shalrath_spawner = 
{
	mon_spawner_use(monster_shalrath_spawn);
};

void() monster_shalrath =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model2 ("progs/shalrath.mdl");
	precache_model2 ("progs/shalrath_shield.mdl");
	precache_model2 ("progs/h_shal.mdl");
	precache_model ("progs/missle.mdl");
	precache_model ("progs/p_grenade.mdl");
	precache_model2 ("progs/missle_notrail.mdl");
	precache_model2 ("progs/shalrath_gib_leg.mdl");
	precache_sound2 ("shalrath/attack.wav");
	precache_sound2 ("shalrath/attack2.wav");
	precache_sound2 ("shalrath/death.wav");
	precache_sound2 ("shalrath/idle.wav");
	precache_sound2 ("shalrath/pain.wav");
	precache_sound2 ("shalrath/sight.wav");
	precache_sound ("weapons/pl_explode.wav");
	precache_sound ("weapons/f_grenade.wav");

	setsize (self, VEC_HULL2_MIN, SIZE_SHIELD); // set for telefrag check
	self.health = VORE_HEALTH;
	if ( monster_spawnsetup( monster_shalrath_spawner ) ) return;
	
	addmonster(1);
	monster_shalrath_spawn();
};

void() updateShieldPosition =
{
	setorigin(self, self.owner.origin);
	if (self.fA)
	{
		if (self.alpha < 0.4)
			self.alpha += 0.025;
		else
		{
			self.fA = 0;
			self.alpha = 0.4;
		}
	}
	else
	{
		if (self.alpha > 0.15)
			self.alpha -= 0.025;
		else
		{
			self.fA = 1;
			self.alpha = 0.15;
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
	T_Damage (other, self, self, (skill + 1) * 10, 0);
	other.pushback_time = time + 0.3;
}