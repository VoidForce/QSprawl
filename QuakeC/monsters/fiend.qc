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
/*==============================================================================

DEMON

==============================================================================*/

$cd /raid/quake/id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================

void()	Demon_JumpTouch;
									  
void()	demon1_stand1	=[	$stand1,  demon1_stand2	] {setHead('19 3 3');ai_stand();}; // 1
void()	demon1_stand2	=[	$stand2,  demon1_stand3	] {setHead('19 3 3');ai_stand();}; // 2
void()	demon1_stand3	=[	$stand3,  demon1_stand4	] {setHead('19 3 3');ai_stand();}; // 3
void()	demon1_stand4	=[	$stand4,  demon1_stand5	] {setHead('19 3 3');ai_stand();}; // 4
void()	demon1_stand5	=[	$stand5,  demon1_stand6	] {setHead('19 3 3');ai_stand();}; // 5
void()	demon1_stand6	=[	$stand6,  demon1_stand7	] {setHead('19 3 3');ai_stand();}; // 6
void()	demon1_stand7	=[	$stand7,  demon1_stand8	] {setHead('19 3 3');ai_stand();}; // 7
void()	demon1_stand8	=[	$stand8,  demon1_stand9	] {setHead('19 3 3');ai_stand();}; // 8
void()	demon1_stand9	=[	$stand9,  demon1_stand10] {setHead('19 3 3');ai_stand();}; // 9
void()	demon1_stand10	=[	$stand10, demon1_stand11] {setHead('19 3 3');ai_stand();}; // 10
void()	demon1_stand11	=[	$stand11, demon1_stand12] {setHead('19 3 3');ai_stand();}; // 11
void()	demon1_stand12	=[	$stand12, demon1_stand13] {setHead('19 3 3');ai_stand();}; // 12
void()	demon1_stand13	=[	$stand13, demon1_stand1	] {setHead('19 3 3');ai_stand();}; // 13

void()	demon1_walk1	=[	$walk1,		demon1_walk2	] {setHead('27 3 5'); // 14
	if (random() < 0.2)
	    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_walk(8);
};

void()	demon1_walk2	=[	$walk2,	demon1_walk3 ] {setHead('24 3 5');ai_walk(6);}; // 15
void()	demon1_walk3	=[	$walk3,	demon1_walk4 ] {setHead('22 3 6');ai_walk(6);}; // 16
void()	demon1_walk4	=[	$walk4,	demon1_walk5 ] {setHead('24 3 5');ai_walk(7);}; // 17
void()	demon1_walk5	=[	$walk5,	demon1_walk6 ] {setHead('25 3 5');ai_walk(4);}; // 18
void()	demon1_walk6	=[	$walk6,	demon1_walk7 ] {setHead('23 3 5');ai_walk(6);}; // 19
void()	demon1_walk7	=[	$walk7,	demon1_walk8 ] {setHead('23 3 5');ai_walk(10);}; // 20
void()	demon1_walk8	=[	$walk8,	demon1_walk1 ] {setHead('23 3 5');ai_walk(10);}; // 21

void()	demon1_run1	=[	$run1,		demon1_run2	] {setHead('28 5 18'); // 22
	if (random() < 0.2)
	    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_run(20);
};

void()	demon1_run2	=[	$run2, demon1_run3	] {setHead('28 3 18');ai_run(15);}; // 23
void()	demon1_run3	=[	$run3, demon1_run4	] {setHead('25 3 25');ai_run(36);}; // 24
void()	demon1_run4	=[	$run4, demon1_run5	] {setHead('28 2 16');ai_run(20);}; // 25
void()	demon1_run5	=[	$run5, demon1_run6	] {setHead('27 3 16');ai_run(15);}; // 26
void()	demon1_run6	=[	$run6, demon1_run1	] {setHead('26 4 23');ai_run(36);}; // 27

void()	demon1_jump1	=[	$leap1,		demon1_jump2	] {setHead('22 4 4');ai_face();}; // 28
void()	demon1_jump2	=[	$leap2,		demon1_jump3	] {setHead('25 2 22');ai_face();}; // 29
void()	demon1_jump3	=[	$leap3,		demon1_jump4	] {setHead('13 3 37');ai_face();}; // 30
void()	demon1_jump4	=[	$leap4,		demon1_jump5	] {setHead('11 3 38');  // 31
	ai_face();
	
	self.touch = Demon_JumpTouch;
	makevectors2 (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 250';

	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};

void()	demon1_jump5	=[	$leap5,		demon1_jump6	] {setHead('13 3 37');}; // 32
void()	demon1_jump6	=[	$leap6,		demon1_jump7	] {setHead('11 3 42');}; // 33
void()	demon1_jump7	=[	$leap7,		demon1_jump8	] {setHead('11 3 42');}; // 34
void()	demon1_jump8	=[ 	$leap8,		demon1_jump9	] {setHead('11 3 43');}; // 35
void()	demon1_jump9	=[ 	$leap9,		demon1_jump10	] {setHead('12 3 42');}; // 36
void()	demon1_jump10	=[ 	$leap10,	demon1_jump1	] {setHead('20 3 35');	 // 37
self.nextthink = time + 3; // if three seconds pass, assume demon is stuck and jump again
};
void()	demon1_jump11	=[ 	$leap11,	demon1_jump12	] {setHead('20 3 29');};  // 38
void()	demon1_jump12	=[ 	$leap12,	demon1_run1	] {setHead('22 3 28');}; // 39


void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {setHead('21 3 22');ai_charge(4);}; // 55
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {setHead('18 -2 25');ai_charge(0);}; // 56
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {setHead('15 -2 26');ai_charge(0);}; // 57
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {setHead('15 -2 26');ai_charge(1);}; // 58
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {setHead('17 1 25');ai_charge(2); Demon_Melee(200);}; // 59
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {setHead('21 2 19');ai_charge(1);}; // 60
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {setHead('22 9 19');ai_charge(6);}; // 61
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {setHead('22 9 19');ai_charge(8);}; // 62
void()	demon1_atta9	=[	$attacka9,		demon1_atta10] {setHead('21 9 19');ai_charge(4);}; // 63
void()	demon1_atta10	=[	$attacka10,		demon1_atta11] {setHead('22 7 17');ai_charge(2);}; // 64
void()	demon1_atta11	=[	$attacka11,		demon1_atta12] {setHead('22 4 15');Demon_Melee(-200);}; // 65
void()	demon1_atta12	=[	$attacka12,		demon1_atta13] {setHead('20 -3 15');ai_charge(5);}; // 66
void()	demon1_atta13	=[	$attacka13,		demon1_atta14] {setHead('19 -6 15');ai_charge(8);}; // 67
void()	demon1_atta14	=[	$attacka14,		demon1_atta15] {setHead('19 -5 12');ai_charge(4);}; // 68
void()	demon1_atta15	=[	$attacka15,		demon1_run1] {setHead('19 -2 15');ai_charge(4);}; // 69

void()	demon1_pain1	=[	$pain1,		demon1_pain2	] {setHead('6 -3 24');}; // 40
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {setHead('2 -2 25');}; // 41
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {setHead('2 -2 25');}; // 42
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {setHead('5 -2 24');}; // 43
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {setHead('9 0 22');}; // 44
void()	demon1_pain6	=[	$pain6,		demon1_run1	] {setHead('14 1 20');}; // 45

void(entity attacker, float damage)	demon1_pain =
{
	if (self.touch == Demon_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
    sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if (random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1 ();
};

void()	demon1_die1		=[	$death1,		demon1_die2	] 
{
	sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
};

void()	demon1_die2		=[	$death2,		demon1_die3	] {};
void()	demon1_die3		=[	$death3,		demon1_die4	] {};
void()	demon1_die4		=[	$death4,		demon1_die5	] {};
void()	demon1_die5		=[	$death5,		demon1_die6	] {};
void()	demon1_die6		=[	$death6,		demon1_die7	] {};
void()	demon1_die7		=[	$death7,		demon1_die8	] {};
void()	demon1_die8		=[	$death8,		demon1_die9	] {};
void()	demon1_die9		=[	$death9,		demon1_die9 ] {};

void() demon_die =
{
	self.solid = SOLID_NOT;
	// check for gib
	if (self.lasthit_damage > self.gib_threshold)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_demon.mdl", self.health);
		ThrowGib ("progs/m_gib_01.mdl", self.health);
		ThrowGib ("progs/m_gib_02.mdl", self.health);
		ThrowGib ("progs/m_gib_03.mdl", self.health);
		ThrowGib ("progs/demon_gib_claw.mdl", self.health);
		ThrowGib ("progs/demon_gib_leg.mdl" , self.health);
		ThrowGib ("progs/demon_gib_ass.mdl" , self.health);
		return;
	}

	// regular death
	demon1_die1 ();
};


void() Demon_MeleeAttack =
{
	demon1_atta1 ();
};


/*==============================================================================

DEMON

==============================================================================*/

/*==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============*/
float()	CheckDemonMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;

		return TRUE;
	}

	return FALSE;
};

/*==============
CheckDemonJump

==============*/
float()	CheckDemonJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z + 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z + 0.25 * self.enemy.size_z)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return FALSE;
		
	if (d > 200)
	{
		if (random() < 0.9)
			return FALSE;
	}
		
	return TRUE;
};

float()	DemonCheckAttack =
{	
	// if close enough for slashing, go for it
	if (CheckDemonMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckDemonJump ())
	{
		self.attack_state = AS_MISSILE;
        sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);

		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void(float side)	Demon_Melee =
{
	local	float	ldmg;
	local vector	delta;
	
	ai_face ();
	walkmove (self.ideal_yaw, 12);	// allow a little closing

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;

	if (!CanDamage (self.enemy, self))
		return;
		
    sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	ldmg = 10 + 5*random();
	T_Damage (self.enemy, self, self, ldmg, 0);	

	makevectors2 (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void()	Demon_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = 40 + 10*random();
			T_Damage (other, self, self, ldmg, 0);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			self.touch = SUB_Null;
			self.think = demon1_jump1;
			self.nextthink = time + 0.1;
		}

		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};


/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush*/
void() monster_demon1 =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/demon.mdl");
	precache_model ("progs/h_demon.mdl");
	precache_model ("progs/demon_gib_claw.mdl");
	precache_model ("progs/demon_gib_leg.mdl");
	precache_model ("progs/demon_gib_ass.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	//gnounc
	setmodel (self, "progs/demon.mdl");
	self.noise = "demon/sight2.wav";
	self.killstring = " was eviscerated by a Fiend\n";

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 350;
	self.max_health = 350;
	self.head_offset = '19 3 6';
	self.health_head = 100;
	self.armorclass_body = 40;
	self.armorclass_head = 75;
	self.gib_threshold = 180;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS | MFL_ROBOT;

	self.monstertype = TYPE_FIEND;
	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;		// one of two attacks
	self.th_missile = demon1_jump1;			// jump attack
	self.th_pain = demon1_pain;
		
	walkmonster_start();
};