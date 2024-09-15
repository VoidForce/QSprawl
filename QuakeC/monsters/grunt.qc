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

SOLDIER / PLAYER

==============================================================================
*/

$cd /raid/quake/id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11

$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9

$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24

/*
==============================================================================
SOLDIER CODE
==============================================================================
*/

void() army_fire;

void()	army_stand1	=[ $stand1, army_stand2	] {setHead('7 0 20');ai_stand();}; // 1
void()	army_stand2	=[ $stand2, army_stand3	] {setHead('7 0 20');ai_stand();}; // 2
void()	army_stand3	=[ $stand3, army_stand4	] {setHead('7 0 20');ai_stand();}; // 3
void()	army_stand4	=[ $stand4, army_stand5	] {setHead('7 0 20');ai_stand();}; // 4
void()	army_stand5	=[ $stand5, army_stand6	] {setHead('7 0 20');ai_stand();}; // 5
void()	army_stand6	=[ $stand6, army_stand7	] {setHead('7 0 20');ai_stand();}; // 6
void()	army_stand7	=[ $stand7, army_stand8	] {setHead('7 0 20');ai_stand();}; // 7
void()	army_stand8	=[ $stand8, army_stand1	] {setHead('7 0 20');ai_stand();}; // 8

void()	army_walk1	=[	$prowl_1,	army_walk2	] {setHead('7 0 20'); // 91
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_walk(1);
};

void()	army_walk2	=[	$prowl_2,	army_walk3	] {setHead('7 0 18');ai_walk(1);}; // 92
void()	army_walk3	=[	$prowl_3,	army_walk4	] {setHead('9 0 17');ai_walk(1);}; // 93
void()	army_walk4	=[	$prowl_4,	army_walk5	] {setHead('9 0 17');ai_walk(1);}; // 94
void()	army_walk5	=[	$prowl_5,	army_walk6	] {setHead('10 0 18');ai_walk(2);}; // 95
void()	army_walk6	=[	$prowl_6,	army_walk7	] {setHead('10 1 21');ai_walk(3);}; // 96
void()	army_walk7	=[	$prowl_7,	army_walk8	] {setHead('9 1 22');ai_walk(4);}; // 97
void()	army_walk8	=[	$prowl_8,	army_walk9	] {setHead('8 1 23');ai_walk(4);}; // 98 
void()	army_walk9	=[	$prowl_9,	army_walk10	] {setHead('6 0 23');ai_walk(2);}; // 99
void()	army_walk10	=[	$prowl_10,	army_walk11	] {setHead('5 0 22');ai_walk(2);}; // 100
void()	army_walk11	=[	$prowl_11,	army_walk12	] {setHead('5 0 22');ai_walk(2);}; // 101
void()	army_walk12	=[	$prowl_12,	army_walk13	] {setHead('5 0 21');ai_walk(1);}; // 102
void()	army_walk13	=[	$prowl_13,	army_walk14	] {setHead('6 0 20');ai_walk(0);}; // 103
void()	army_walk14	=[	$prowl_14,	army_walk15	] {setHead('6 0 19');ai_walk(1);}; // 104
void()	army_walk15	=[	$prowl_15,	army_walk16	] {setHead('7 0 18');ai_walk(1);}; // 105
void()	army_walk16	=[	$prowl_16,	army_walk17	] {setHead('9 0 17');ai_walk(1);}; // 106
void()	army_walk17	=[	$prowl_17,	army_walk18	] {setHead('9 0 17');ai_walk(3);}; // 107
void()	army_walk18	=[	$prowl_18,	army_walk19	] {setHead('11 1 19');ai_walk(3);}; // 108
void()	army_walk19	=[	$prowl_19,	army_walk20	] {setHead('11 1 20');ai_walk(3);}; // 109
void()	army_walk20	=[	$prowl_20,	army_walk21	] {setHead('10 1 21');ai_walk(3);}; // 110
void()	army_walk21	=[	$prowl_21,	army_walk22	] {setHead('8 1 22');ai_walk(2);}; // 111
void()	army_walk22	=[	$prowl_22,	army_walk23	] {setHead('7 1 22');ai_walk(1);}; // 112
void()	army_walk23	=[	$prowl_23,	army_walk24	] {setHead('7 1 22');ai_walk(1);}; // 113
void()	army_walk24	=[	$prowl_24,	army_walk1	] {setHead('7 1 21');ai_walk(1);}; // 114

void()	army_run1	=[	$run1,		army_run2	] {Think(0.06);setHead('7 1 21'); // 74
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_run(11);
};

void()	army_run2	=[	$run2,		army_run3	] {Think(0.075);setHead('6 0 22');ai_run(15);}; // 75
void()	army_run3	=[	$run3,		army_run4	] {Think(0.075);setHead('6 0 21');ai_run(12);}; // 76
void()	army_run4	=[	$run4,		army_run5	] {Think(0.075);setHead('6 0 21');ai_run(12);}; // 77
void()	army_run5	=[	$run5,		army_run6	] {Think(0.075);setHead('6 0 21');ai_run(10);}; // 78
void()	army_run6	=[	$run6,		army_run7	] {Think(0.075);setHead('6 1 22');ai_run(15);}; // 79
void()	army_run7	=[	$run7,		army_run8	] {Think(0.075);setHead('6 1 21');ai_run(12);}; // 80
void()	army_run8	=[	$run8,		army_run1	] {Think(0.075);setHead('6 1 20');ai_run(10);}; // 81

void()	army_atk1	=[	$shoot1,	army_atk2	] {setHead('5 0 24');ai_face();};  // 82
void()	army_atk2	=[	$shoot2,	army_atk3	] {setHead('2 1 24');ai_face();};  // 83
void()	army_atk3	=[	$shoot3,	army_atk4	] {setHead('-1 1 24');ai_face();}; // 84
void()	army_atk4	=[	$shoot4,	army_atk5	] {setHead('-2 1 24');ai_face();}; // 85
void()	army_atk5	=[	$shoot5,	army_atk6	] {setHead('-2 1 24');			   // 86
	ai_face();
	army_fire();
	self.effects = self.effects | EF_MUZZLEFLASH;
};
void()	army_atk6	=[	$shoot6,	army_atk7	] {setHead('-12 2 21');ai_face();}; // 87
void()	army_atk7	=[	$shoot7,	army_atk8	] {setHead('-11 2 22');ai_face(); SUB_CheckRefire (army_atk1);}; // 88
void()	army_atk8	=[	$shoot8,	army_atk9	] {setHead('-7 2 23');ai_face();}; //89
void()	army_atk9	=[	$shoot9,	army_run1	] {setHead('-3 2 24');ai_face();}; //90


void()	army_pain1	=[	$pain1,		army_pain2	] {setHead('0 1 20');}; // 41
void()	army_pain2	=[	$pain2,		army_pain3	] {setHead('-16 -1 23');}; // 42 
void()	army_pain3	=[	$pain3,		army_pain4	] {setHead('-23 4 21');}; // 43 
void()	army_pain4	=[	$pain4,		army_pain5	] {setHead('-12 0 25');}; // 44 
void()	army_pain5	=[	$pain5,		army_pain6	] {setHead('-1 1 25');}; // 45
void()	army_pain6	=[	$pain6,		army_run1	] {setHead('5 0 22');ai_pain(1);}; // 46

void()	army_painb1	=[	$painb1,	army_painb2	] {setHead('-1 -2 25');}; // 47
void()	army_painb2	=[	$painb2,	army_painb3	] {setHead('-1 -1 18');ai_painforward(13);}; // 48
void()	army_painb3	=[	$painb3,	army_painb4	] {setHead('-5 -1 15');ai_painforward(9);}; // 49
void()	army_painb4	=[	$painb4,	army_painb5	] {setHead('2 -1 14');}; // 50
void()	army_painb5	=[	$painb5,	army_painb6	] {setHead('15 -3 5');}; // 51
void()	army_painb6	=[	$painb6,	army_painb7	] {setHead('18 -3 -5');}; // 52
void()	army_painb7	=[	$painb7,	army_painb8	] {setHead('14 -2 -11');}; // 53
void()	army_painb8	=[	$painb8,	army_painb9	] {setHead('13 -2 -11');}; // 54
void()	army_painb9	=[	$painb9,	army_painb10] {setHead('14 -2 -9');}; // 55
void()	army_painb10=[	$painb10,	army_painb11] {setHead('14 -2 -7');}; // 56
void()	army_painb11=[	$painb11,	army_painb12] {setHead('14 -2 1');}; // 57
void()	army_painb12=[	$painb12,	army_painb13] {setHead('14 0 5');ai_pain(2);}; // 58
void()	army_painb13=[	$painb13,	army_painb14] {setHead('14 0 11');}; // 59
void()	army_painb14=[	$painb14,	army_run1	] {setHead('11 0 17');}; // 60

void()	army_painc1	=[	$painc1,	army_painc2	] {setHead('2 0 22');}; // 61
void()	army_painc2	=[	$painc2,	army_painc3	] {setHead('-17 1 24');ai_pain(1);}; // 62
void()	army_painc3	=[	$painc3,	army_painc4	] {setHead('-13 1 25');}; // 63
void()	army_painc4	=[	$painc4,	army_painc5	] {setHead('-4 -1 24');}; // 64
void()	army_painc5	=[	$painc5,	army_painc6	] {setHead('7 -1 19');ai_painforward(1);}; // 65
void()	army_painc6	=[	$painc6,	army_painc7	] {setHead('13 1 12');ai_painforward(1);}; // 66
void()	army_painc7	=[	$painc7,	army_painc8	] {setHead('15 2 9');}; // 67
void()	army_painc8	=[	$painc8,	army_painc9	] {setHead('15 2 13');ai_pain(1);}; // 68
void()	army_painc9	=[	$painc9,	army_painc10] {setHead('15 1 14');ai_painforward(4);}; // 69 nice
void()	army_painc10=[	$painc10,	army_painc11] {setHead('15 1 14');ai_painforward(3);}; // 70 
void()	army_painc11=[	$painc11,	army_painc12] {setHead('14 1 17');ai_painforward(6);}; // 71
void()	army_painc12=[	$painc12,	army_painc13] {setHead('11 1 18');ai_painforward(8);}; // 72
void()	army_painc13=[	$painc13,	army_run1] 	  {setHead('9 0 20');}; // 73

void(entity attacker, float damage)	army_pain =
{
	local float r;
	
	if (self.pain_finished > time)
		return;

	r = random();

	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		army_pain1 ();
		playPainSound("soldier/pain1.wav");
	}

	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		army_painb1 ();
		playPainSound("soldier/pain2.wav");
	}

	else
	{
		self.pain_finished = time + 1.1;
		army_painc1 ();
		playPainSound("soldier/pain2.wav");
	}
};

void() Laser_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, self.velocity*0.2, 15);
		T_Damage (other, self, self.owner, 15, 0);
	}
	else
	{
		sendMessageImpact(org, VEC_ORIGIN, IMPACT_LASER, VEC_ORIGIN); 
	}
	
	remove(self);	
};

void(vector org, vector vec) LaunchLaser =
{		
	if (self.classname == "monster_army")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.clip = CLIP_PROJECTILE;
	newmis.classname = "army_laser";	//gnounc
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 900;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

void() army_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors2 (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchLaser(org, getPlayerPosition(self.enemy, 0) - self.origin);
};

void()	army_die1	=[	$death1,	army_die2	] {};
void()	army_die2	=[	$death2,	army_die3	] {};
void()	army_die3	=[	$death3,	army_die4	] {};
void()	army_die4	=[	$death4,	army_die5	] {};
void()	army_die5	=[	$death5,	army_die6	] {};
void()	army_die6	=[	$death6,	army_die7	] {};
void()	army_die7	=[	$death7,	army_die8	] {};
void()	army_die8	=[	$death8,	army_die9	] {};
void()	army_die9	=[	$death9,	army_die10	] {};
void()	army_die10	=[	$death10,	decay	] {};

void()	army_cdie1	=[	$deathc1,	army_cdie2	] {};
void()	army_cdie2	=[	$deathc2,	army_cdie3	] {};
void()	army_cdie3	=[	$deathc3,	army_cdie4	] {};
void()	army_cdie4	=[	$deathc4,	army_cdie5	] {};
void()	army_cdie5	=[	$deathc5,	army_cdie6	] {};
void()	army_cdie6	=[	$deathc6,	army_cdie7	] {};
void()	army_cdie7	=[	$deathc7,	army_cdie8	] {};
void()	army_cdie8	=[	$deathc8,	army_cdie9	] {};
void()	army_cdie9	=[	$deathc9,	army_cdie10	] {};
void()	army_cdie10	=[	$deathc10,	army_cdie11	] {};
void()	army_cdie11	=[	$deathc11,	decay	] {};

/*===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============*/
float() SoldierCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
		return FALSE;	// don't have a clear shot
			
	
// missile attack
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
		chance = 0.9;

	else if (enemy_range == RANGE_NEAR)
		chance = 0.4;

	else if (enemy_range == RANGE_MID)
		chance = 0.05;

	else
		chance = 0;

	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (1 + random());

		if (random() < 0.3)
			self.lefty = !self.lefty;

		return TRUE;
	}

	return FALSE;
};

void() army_die =
{
	self.solid = SOLID_NOT;
	if (!(self.monsterflags & MFL_DROP_HEAD)) // if we chop the head off with katana body should stay and head fly
		self.velocity = self.lasthit_direction;
	// check for gib
	if (self.health <= 0 && self.lasthit_damage > self.gib_threshold || self.monsterflags & MFL_GIB_ME)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib1.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib2.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib3.mdl", self.lasthit_damage);
		ThrowGib ("progs/smallgib.mdl", self.lasthit_damage);
		ThrowGib ("progs/smallgib.mdl", self.lasthit_damage);
		return;
	}
	
	if (self.health_head <= 0)
	{
		dropAmmo(self.origin, DROP_NAILS, 6, 4, 3, 2);
		dropHealth(self.origin, DROP_HEALTH, 1, 0, 0, 0);
		dropHealth(self.origin, DROP_HEALTH_ONE, 0, 4, 3, 2);
			
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		setmodel (self, "progs/soldier_headless.mdl");
		setsize (self, '-16 -16 -24', '16 16 32');
		sendMessageVec(findHeadPosition(self), TE_HEAD); // particle effect
		self.angles_y += crandom() * 30;
		if (self.monsterflags & MFL_DROP_HEAD)
		{
			self.monsterflags -= self.monsterflags & MFL_DROP_HEAD;
			ThrowHeadGib ("progs/h_guard.mdl", self.lasthit_direction * 200 + '0 0 100', 1);
		}
		else
		{
			for (float i = 0; i < 5; i++)
				ThrowHeadGib ("progs/smallgib.mdl", self.lasthit_direction * (100 + random()*50) + [crandom() * 100, crandom() * 100, random() * 200], 0);
		}
	}
	else
		sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	
	flyDeath(self); // i believe i can fly
	if (random() < 0.5)
		army_die1 ();
	else
		army_cdie1 ();
};


/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush*/
void() monster_army_spawn =
{	
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_army";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/soldier.mdl");
	setsize (self, '-16 -16 -24', '16 16 32');//40
	
	self.noise = "soldier/sight1.wav";	//gnounc
	self.netname = "Grunt";
	self.killstring = " was shot by Junta's MP\n";
	self.head_offset = '7 0 20';
	self.head_size = 12;
	self.health = SOLDIER_HEALTH;
	self.max_health = SOLDIER_HEALTH;
	self.health_head = SOLDIER_HEAD;
	self.health_head_max = SOLDIER_HEAD;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS;
	self.monstertype = TYPE_SOLDIER;
	self.gib_threshold = 75;
	self.skinchange = 1;

	self.th_stand = army_stand1;
	self.th_walk = army_walk1;
	self.th_run = army_run1;
	self.th_missile = army_atk1;
	self.th_pain = army_pain;
	self.th_die = army_die;
	
	walkmonster_start ();
};

void() monster_army_spawner = 
{
	mon_spawner_use(monster_army_spawn);
};

void() monster_army =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_model2 ("progs/laser.mdl");
	precache_model ("progs/soldier.mdl");
	precache_model ("progs/soldier_headless.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");
	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");
	precache_sound ("player/udeath.wav");		// gib death
	
	setsize (self, '-16 -16 -24', '16 16 32');
	self.health = SOLDIER_HEALTH;
	if ( monster_spawnsetup( monster_army_spawner ) )
		return;
	
	addmonster(1);
	monster_army_spawn();
};