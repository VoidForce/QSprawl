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

$cd /raid/quake/id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19


void(float normal) Enforcer_AttackFinished =
{
	self.attack_finished = time + normal;
};

void (void() thinkst) Enforcer_CheckRefire =
{
	if (self.monster_ammo < 1)
	{
		self.monster_ammo = 2;
		self.attack_finished = time + 1.5;
		return;
	}
	if (!visible (self.enemy))
		return;
	
	self.think = thinkst;
};

void(vector org, vector dir) launchShrapnel = 
{ 
	local entity shrapnel;

	shrapnel = spawn();
	shrapnel.clip = CLIP_PROJECTILE;
	shrapnel.owner = self;
	shrapnel.movetype = MOVETYPE_FLYMISSILE;
	shrapnel.solid = SOLID_BBOX;
	shrapnel.angles = vectoangles(dir);
	shrapnel.touch = spike_touch;
	shrapnel.classname = "spike";
	shrapnel.think = SUB_Remove;
	shrapnel.nextthink = time + 6;
	setmodel(shrapnel, "progs/shrapnel.mdl");
	setsize(shrapnel, '0 0 0', '0 0 0');
	setorigin(shrapnel, org);
	shrapnel.velocity = dir * 1800;
	//shrapnel.avelocity = [random() * 200, random() * 200, random() * 200];
};

void() enforcer_fire =
{
	vector	dir;
	vector org;
	float i;
	float ri,rr; // random index and random radius
	vector pos;
	pos = getPlayerPosition(self.enemy, 0);
	
	ai_face();
	self.effects |= EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);	
	//makevectors2(vectoangles
	vectorvectors([pos_x, pos_y, pos_z + self.enemy.view_ofs_z] - [self.origin_x,self.origin_y,self.origin_z + 16]);
	for (i = 0; i < 10; i++)
	{
		ri = rint(random() * 15);
		if ( i < 5)
			rr = 20;
		else
			rr = 50;
		dir = normalize( v_forward * 1000 + v_up * CIRCLEY[ri] * rr + v_right * CIRCLEX[ri] * rr);
		org = self.origin + v_forward * 23 + v_right * 8 + '0 0 16'; // starting point offset to match gun barrel
		launchShrapnel(org, dir);
	}
	self.monster_ammo--;
};

//============================================================================

void()	enf_stand1	=[	$stand1,	enf_stand2	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand2	=[	$stand2,	enf_stand3	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand3	=[	$stand3,	enf_stand4	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand4	=[	$stand4,	enf_stand5	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand5	=[	$stand5,	enf_stand6	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand6	=[	$stand6,	enf_stand7	] {ai_stand();setHead('-4 2 29');};
void()	enf_stand7	=[	$stand7,	enf_stand1	] {ai_stand();setHead('-4 2 29');};

void()	enf_walk1	=[	$walk1 ,	enf_walk2	]
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_walk(2);
	self.head_offset = '-3 0 27'; //8
};

void()	enf_walk2	=[	$walk2 ,	enf_walk3	] {ai_walk(4);setHead('-2 0 28'); };
void()	enf_walk3	=[	$walk3 ,	enf_walk4	] {ai_walk(4);setHead('-1 1 29');};
void()	enf_walk4	=[	$walk4 ,	enf_walk5	] {ai_walk(3);setHead('-2 1 29.5');};
void()	enf_walk5	=[	$walk5 ,	enf_walk6	] {ai_walk(1);setHead('-2 2 30.5');};
void()	enf_walk6	=[	$walk6 ,	enf_walk7	] {ai_walk(2);setHead('-2 2 30');};
void()	enf_walk7	=[	$walk7 ,	enf_walk8	] {ai_walk(2);setHead('-2 2.5 29');};
void()	enf_walk8	=[	$walk8 ,	enf_walk9	] {ai_walk(1);setHead('-2 2.5 28');};
void()	enf_walk9	=[	$walk9 ,	enf_walk10	] {ai_walk(2);setHead('-2 3 28');};
void()	enf_walk10	=[	$walk10,	enf_walk11	] {ai_walk(4);setHead('-2 3 28');};
void()	enf_walk11	=[	$walk11,	enf_walk12	] {ai_walk(4);setHead('-1.5 2.5 28.5');};
void()	enf_walk12	=[	$walk12,	enf_walk13	] {ai_walk(1);setHead('-1.5 2 29.5');};
void()	enf_walk13	=[	$walk13,	enf_walk14	] {ai_walk(2);setHead('-2 1.5 30.5');};
void()	enf_walk14	=[	$walk14,	enf_walk15	] {ai_walk(3);setHead('-2 1 30.5');};
void()	enf_walk15	=[	$walk15,	enf_walk16	] {ai_walk(4);setHead('-2 0.5 29.5');};
void()	enf_walk16	=[	$walk16,	enf_walk1	] {ai_walk(2);setHead('-2 0.5 28.5');};

void()	enf_run1	=[	$run1  ,	enf_run2	] 
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_run(18);
	self.head_offset = '3 -1 29';
};

void()	enf_run2	=[	$run2  ,	enf_run3	] {Think(0.06); ai_run(14);setHead('3 -1 27');};
void()	enf_run3	=[	$run3  ,	enf_run4	] {Think(0.06); ai_run(7); setHead('4 -1 26');}; //26;
void()	enf_run4	=[	$run4  ,	enf_run5	] {Think(0.06); ai_run(12);setHead('3 1.5 26.5');};
void()	enf_run5	=[	$run5  ,	enf_run6	] {Think(0.06); ai_run(14);setHead('2.5 3 28');};
void()	enf_run6	=[	$run6  ,	enf_run7	] {Think(0.06); ai_run(14);setHead('3 3 27');};
void()	enf_run7	=[	$run7  ,	enf_run8	] {Think(0.06); ai_run(7); setHead('5 3 26');};
void()	enf_run8	=[	$run8  ,	enf_run1	] {Think(0.06); ai_run(11);setHead('3 1 27');};

void()	enf_atk1	=[	$attack1,	enf_atk2	] {ai_face();setHead('-9 4 29');};
void()	enf_atk2	=[	$attack2,	enf_atk3	] {ai_face();setHead('-9 3 27');}; //33
void()	enf_atk3	=[	$attack3,	enf_atk4	] {ai_face();setHead('-9 2 26');};
void()	enf_atk4	=[	$attack4,	enf_atk5	] {ai_face();setHead('-8 2 26');};
void()	enf_atk5	=[	$attack5,	enf_atk6	] {ai_face();setHead('-6 2 26');}; //36
void()	enf_atk6	=[	$attack6,	enf_atk11	] {enforcer_fire();setHead('-5 1 26');};
//void()	enf_atk7	=[	$attack7,	enf_atk8	] {ai_face();setHead('-15 1 23');};
//void()	enf_atk8	=[	$attack8,	enf_atk9	] {ai_face();setHead('-15 1 23');}; // 39
//void()	enf_atk9	=[	$attack5,	enf_atk10	] {ai_face();setHead('-6 2 26');}; // frame 36 repeats
//void()	enf_atk10	=[	$attack6,	enf_atk11	] {enforcer_fire();setHead('-5 1 26');};
void()	enf_atk11	=[	$attack7,	enf_atk12	] {ai_face();setHead('-15 1 23');};
void()	enf_atk12	=[	$attack8,	enf_atk13	] {ai_face();setHead('-15 1 23');};
void()	enf_atk13	=[	$attack9,	enf_atk14	] {ai_face();setHead('-11.5 1.5 24');}; //40
void()	enf_atk14	=[	$attack10,	enf_run1	] {ai_face();setHead('-8 2 25');Enforcer_CheckRefire (enf_atk1);}; //41
// 42- 66 death
void()	enf_paina1	=[	$paina1,	enf_paina2	] {setHead('-15 5 27');}; //67
void()	enf_paina2	=[	$paina2,	enf_paina3	] {setHead('-17 5 27');};
void()	enf_paina3	=[	$paina3,	enf_paina4	] {setHead('-15 5 28');};
void()	enf_paina4	=[	$paina4,	enf_run1	] {setHead('-10 3 29');}; //70

void()	enf_painb1	=[	$painb1,	enf_painb2	] {setHead('-13 6 24');}; //71
void()	enf_painb2	=[	$painb2,	enf_painb3	] {setHead('-15 7 22');};
void()	enf_painb3	=[	$painb3,	enf_painb4	] {setHead('-14 7 22');}; //73
void()	enf_painb4	=[	$painb4,	enf_painb5	] {setHead('-15 7 22');};
void()	enf_painb5	=[	$painb5,	enf_run1	] {setHead('-11 5 26');}; //75

void()	enf_painc1	=[	$painc1,	enf_painc2	] {setHead('-11 -11 23');}; //77
void()	enf_painc2	=[	$painc2,	enf_painc3	] {setHead('-11 -11 23');};
void()	enf_painc3	=[	$painc3,	enf_painc4	] {setHead('-8 -8 27');};
void()	enf_painc4	=[	$painc4,	enf_painc5	] {setHead('-5 -5 28');};
void()	enf_painc5	=[	$painc5,	enf_painc6	] {setHead('-5 -3 29');}; //81
void()	enf_painc6	=[	$painc6,	enf_painc7	] {setHead('-5 -1 29');};
void()	enf_painc7	=[	$painc7,	enf_painc8	] {setHead('-5 1 29');};
void()	enf_painc8	=[	$painc8,	enf_run1	] {setHead('-5 1 29');};

void()	enf_paind1	=[	$paind1,	enf_paind2	] {setHead('-16 1 27');}; //84
void()	enf_paind2	=[	$paind2,	enf_paind3	] {setHead('-9 -1 30');};
void()	enf_paind3	=[	$paind3,	enf_paind4	] {setHead('-3 -1 28');};
void()	enf_paind4	=[	$paind4,	enf_paind5	] {setHead('8 -1 23');ai_painforward(2);}; //87
void()	enf_paind5	=[	$paind5,	enf_paind6	] {setHead('11 -1 18');ai_painforward(1);};
void()	enf_paind6	=[	$paind6,	enf_paind7	] {setHead('15 -3 6');};
void()	enf_paind7	=[	$paind7,	enf_paind8	] {setHead('15 3 1');};
void()	enf_paind8	=[	$paind8,	enf_paind9	] {setHead('15 2 -1');}; // ouch
void()	enf_paind9	=[	$paind9,	enf_paind10	] {setHead('15 2 0');}; //92
void()	enf_paind10	=[	$paind10,	enf_paind11	] {setHead('15 3 2');};
void()	enf_paind11	=[	$paind11,	enf_paind12	] {setHead('15 3 4');ai_painforward(1);};
void()	enf_paind12	=[	$paind12,	enf_paind13	] {setHead('15 3 6');ai_painforward(1);};
void()	enf_paind13	=[	$paind13,	enf_paind14	] {setHead('15 3 7');ai_painforward(1);};
void()	enf_paind14	=[	$paind14,	enf_paind15	] {setHead('15 3 8');}; //97
void()	enf_paind15	=[	$paind15,	enf_paind16	] {setHead('14 3 12');};
void()	enf_paind16	=[	$paind16,	enf_paind17	] {setHead('11 2 19');ai_pain(1);};
void()	enf_paind17	=[	$paind17,	enf_paind18	] {setHead('1 1 27');ai_pain(1);};
void()	enf_paind18	=[	$paind18,	enf_paind19	] {setHead('-6 1 28');};
void()	enf_paind19	=[	$paind19,	enf_run1	] {setHead('-5 3 29');};

void(entity attacker, float damage)	enf_pain =
{
	local float r;

	r = random ();
	if (self.pain_finished > time)
		return;

	if (r < 0.5)
		playPainSound("enforcer/pain1.wav");
	else
		playPainSound("enforcer/pain2.wav");
	
	if (self.monsterflags & MFL_PAIN_HEADSHOT)
	{
		if (r < 0.5)
		{
			self.pain_finished = time + 2;
			enf_paind1 ();
		}
		else
		{
			self.pain_finished = time + 1;
			enf_painc1 ();
		}
		return;
	}
	
	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		enf_paina1 ();
	}

	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		enf_painb1 ();
	}

	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		enf_painc1 ();
	}
};

//============================================================================

void()	enf_die1	=[	$death1,	enf_die2	] {ai_velocity(40);};
void()	enf_die2	=[	$death2,	enf_die3	] {ai_velocity(30);};
void()	enf_die3	=[	$death3,	enf_die4	] {ai_velocity(20);};
void()	enf_die4	=[	$death4,	enf_die5	] {ai_velocity(20);};
void()	enf_die5	=[	$death5,	enf_die6	] {ai_velocity(20);};
void()	enf_die6	=[	$death6,	enf_die7	] {};
void()	enf_die7	=[	$death7,	enf_die8	] {};
void()	enf_die8	=[	$death8,	enf_die9	] {};
void()	enf_die9	=[	$death9,	enf_die10	] {};
void()	enf_die10	=[	$death10,	enf_die11	] {};
void()	enf_die11	=[	$death11,	enf_die12	] {};
void()	enf_die12	=[	$death12,	enf_die13	] {};
void()	enf_die13	=[	$death13,	enf_die14	] {};
void()	enf_die14	=[	$death14,	decay	] {};

void()	enf_fdie1	=[	$fdeath1,	enf_fdie2	] {ai_velocity(40);};
void()	enf_fdie2	=[	$fdeath2,	enf_fdie3	] {ai_velocity(30);};
void()	enf_fdie3	=[	$fdeath3,	enf_fdie4	] {ai_velocity(20);};
void()	enf_fdie4	=[	$fdeath4,	enf_fdie5	] {ai_velocity(20);};
void()	enf_fdie5	=[	$fdeath5,	enf_fdie6	] {ai_velocity(20);};
void()	enf_fdie6	=[	$fdeath6,	enf_fdie7	] {};
void()	enf_fdie7	=[	$fdeath7,	enf_fdie8	] {};
void()	enf_fdie8	=[	$fdeath8,	enf_fdie9	] {};
void()	enf_fdie9	=[	$fdeath9,	enf_fdie10	] {};
void()	enf_fdie10	=[	$fdeath10,	enf_fdie11	] {};
void()	enf_fdie11	=[	$fdeath11,	decay ] {};

void() enf_die =
{
	self.solid = SOLID_NOT;
	if (!(self.monsterflags & MFL_DROP_HEAD)) // if we chop the head off with katana body should stay and head fly
		self.velocity = self.lasthit_direction;

	// check for gib
	if (self.health <= 0 && self.lasthit_damage > self.gib_threshold || self.monsterflags & MFL_GIB_ME)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_enf.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib1.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib2.mdl", self.lasthit_damage);
		ThrowGib ("progs/gib3.mdl", self.lasthit_damage);
		return;
	}
	
	if (self.health_head <= 0)
	{
		dropAmmo(self.origin, DROP_SHELLS, 4, 3, 2, 1);
		dropHealth(self.origin, DROP_ARMOR, 1, 1, 0, 0);
		dropHealth(self.origin, DROP_HEALTH_ONE, 4, 2, 2, 2);
		dropHealth(self.origin, DROP_ARMOR_ONE, 0, 0, 2, 2);
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		setmodel (self, "progs/enforcer_headless.mdl");
		setsize (self, '-16 -16 -24', '16 16 36');
		self.angles_y += crandom() * 30;
		
		sendMessageVec(findHeadPosition(self), TE_HEAD); // particle effect
		if (self.monsterflags & MFL_DROP_HEAD)
		{
			self.monsterflags -= self.monsterflags & MFL_DROP_HEAD;
			ThrowHeadGib ("progs/h_enf.mdl", self.lasthit_direction * 200 + '0 0 100', 1);
		}
		else
		{
			for (float i = 0; i < 5; i++)
				ThrowHeadGib ("progs/smallgib.mdl", self.lasthit_direction * (100 + random()*50) + [crandom() * 100, crandom() * 100, random() * 200], 0);
		}
	}
	else
		sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	
	enf_fdie1 ();
};

/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush*/

void() monster_enforcer_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_enforcer";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/enforcer.mdl");
	setsize (self, '-16 -16 -24', '16 16 36');//40
	
	self.netname = "enforcer";
	self.killstring = " was terminated by Oni Squad\n";
	self.noise = "enforcer/sight1.wav";	//gnounc
	self.noise1 = "enforcer/sight2.wav";	//gnounc
	self.noise2 = "enforcer/sight3.wav";	//gnounc
	self.noise3 = "enforcer/sight4.wav";	//gnounc
	self.head_offset = '-4 2 29';//'-4 2 29';
	self.head_size = 12;
	self.health = ENFORCER_HEALTH;
	self.max_health = ENFORCER_HEALTH;
	self.health_head = ENFORCER_HEAD;
	self.health_head_max = ENFORCER_HEAD;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS;
	self.monstertype = TYPE_ENFORCER;
	self.monster_ammo = 2;
	self.gib_threshold = 75;
	self.skinchange = 1; // why this is not a flag tho? // Because it's used by findfloat
	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_pain = enf_pain;
	self.th_die = enf_die;
	self.th_missile = enf_atk1;
		
	walkmonster_start();
};

void() monster_enforcer_spawner = 
{
	mon_spawner_use(monster_enforcer_spawn);
};

void() monster_enforcer =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model2 ("progs/enforcer.mdl");
	precache_model2 ("progs/enforcer_headless.mdl");
	precache_model2 ("progs/h_enf.mdl");
	precache_sound ("soldier/sattck1.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");

	setsize (self, '-16 -16 -24', '16 16 36'); // set for telefrag check
	self.health = ENFORCER_HEALTH;
	if ( monster_spawnsetup( monster_enforcer_spawner ) )
		return;
	
	addmonster(1);
	monster_enforcer_spawn();
};