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

SHAMBLER

==============================================================================
*/

$cd /raid/quake/id1/models/shams
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() sham_stand1	=[	$stand1,	sham_stand2	] {setHead('16 2 43');ai_stand();}; // 1
void() sham_stand2	=[	$stand2,	sham_stand3	] {setHead('16 2 43');ai_stand();}; // 2
void() sham_stand3	=[	$stand3,	sham_stand4	] {setHead('16 2 43');ai_stand();}; // 3
void() sham_stand4	=[	$stand4,	sham_stand5	] {setHead('16 2 43');ai_stand();}; // 4
void() sham_stand5	=[	$stand5,	sham_stand6	] {setHead('16 2 43');ai_stand();}; // 5
void() sham_stand6	=[	$stand6,	sham_stand7	] {setHead('16 2 43');ai_stand();}; // 6
void() sham_stand7	=[	$stand7,	sham_stand8	] {setHead('16 2 43');ai_stand();}; // 7
void() sham_stand8	=[	$stand8,	sham_stand9	] {setHead('16 2 43');ai_stand();}; // 8
void() sham_stand9	=[	$stand9,	sham_stand10] {setHead('16 2 43');ai_stand();}; // 9
void() sham_stand10	=[	$stand10,	sham_stand11] {setHead('16 2 43');ai_stand();}; // 10
void() sham_stand11	=[	$stand11,	sham_stand12] {setHead('16 2 43');ai_stand();}; // 11
void() sham_stand12	=[	$stand12,	sham_stand13] {setHead('16 2 43');ai_stand();}; // 12
void() sham_stand13	=[	$stand13,	sham_stand14] {setHead('16 2 43');ai_stand();}; // 13
void() sham_stand14	=[	$stand14,	sham_stand15] {setHead('16 2 43');ai_stand();}; // 14
void() sham_stand15	=[	$stand15,	sham_stand16] {setHead('16 2 43');ai_stand();}; // 15
void() sham_stand16	=[	$stand16,	sham_stand17] {setHead('16 2 43');ai_stand();}; // 16
void() sham_stand17	=[	$stand17,	sham_stand1	] {setHead('16 2 43');ai_stand();}; // 17

void() sham_walk1		=[      $walk1,        sham_walk2 ] {setHead('17 2 37');ai_walk(10);};  // 18
void() sham_walk2       =[      $walk2,        sham_walk3 ] {setHead('17 2 41');ai_walk(9);};   // 19
void() sham_walk3       =[      $walk3,        sham_walk4 ] {setHead('18 2 44');ai_walk(9);};   // 20
void() sham_walk4       =[      $walk4,        sham_walk5 ] {setHead('18 1 44');ai_walk(5);};   // 21
void() sham_walk5       =[      $walk5,        sham_walk6 ] {setHead('18 0 44');ai_walk(6);};   // 22
void() sham_walk6       =[      $walk6,        sham_walk7 ] {setHead('19 -1 35');ai_walk(12);};  // 23
void() sham_walk7       =[      $walk7,        sham_walk8 ] {setHead('18 0 30');ai_walk(8);};   // 24
void() sham_walk8       =[      $walk8,        sham_walk9 ] {setHead('17 0 37');ai_walk(3);};   // 25
void() sham_walk9       =[      $walk9,        sham_walk10] {setHead('16 -1 43');ai_walk(13);};  // 26
void() sham_walk10      =[      $walk10,       sham_walk11] {setHead('16 1 41');ai_walk(9);};   // 27
void() sham_walk11      =[      $walk11,       sham_walk12] {setHead('17 2 38');ai_walk(7);};   // 28
void() sham_walk12      =[      $walk12,       sham_walk1 ] {setHead('17 1 36');                // 29
	ai_walk(7);

	if (random() > 0.8)
		sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
};

void() sham_run1  =[ $run1, sham_run2  ] {setHead('15 1 41');ai_run(20);}; // 30
void() sham_run2  =[ $run2, sham_run3  ] {setHead('12 -1 39');ai_run(20);}; // 31
void() sham_run3  =[ $run3, sham_run4  ] {setHead('12 2 39');ai_run(20);}; // 32
void() sham_run4  =[ $run4, sham_run5  ] {setHead('13 2 43');ai_run(20);}; // 33
void() sham_run5  =[ $run5, sham_run6  ] {setHead('14 2 40');ai_run(20);}; // 34
void() sham_run6  =[ $run6, sham_run1  ] {setHead('5 0 40');  // 35
	ai_run(20);
	self.nextthink = time + 0.05;
	if (random() > 0.8)
		sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
};

void() sham_smash1     =[      $smash1,       sham_smash2    ] {setHead('19 2 39');  // 36
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(2);
};

void() sham_smash2     =[      $smash2,       sham_smash3    ] {setHead('11 2 48');ai_charge(6);}; // 37
void() sham_smash3     =[      $smash3,       sham_smash4    ] {setHead('3 1 48');ai_charge(6);}; // 38
void() sham_smash4     =[      $smash4,       sham_smash5    ] {setHead('-2 1 48');ai_charge(5);}; // 39
void() sham_smash5     =[      $smash5,       sham_smash6    ] {setHead('2 1 48');ai_charge(4);}; // 40
void() sham_smash6     =[      $smash6,       sham_smash7    ] {setHead('8 1 47');ai_charge(1);}; // 41
void() sham_smash7     =[      $smash7,       sham_smash8    ] {setHead('16 1 42');ai_charge(0);}; // 42
void() sham_smash8     =[      $smash8,       sham_smash9    ] {setHead('19 2 39');ai_charge(0);}; // 43
void() sham_smash9     =[      $smash9,       sham_smash10   ] {setHead('24 2 36');ai_charge(0);}; // 44
void() sham_smash10    =[      $smash10,      sham_smash11   ] {setHead('31 1 26');                // 45
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;

	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;

	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = (random() + random() + random()) * 40;
	T_Damage (self.enemy, self, self, ldmg, 0);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
};

void() sham_smash11    =[      $smash11,      sham_smash12   ] {setHead('30 1 29');ai_charge(5);}; // 46
void() sham_smash12    =[      $smash12,      sham_run1	   ] {setHead('22 1 34');ai_charge(4);}; // 47

void(float side) ShamClaw =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;

	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 20;
	T_Damage (self.enemy, self, self, ldmg, 0);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if (side)
	{
		makevectors2 (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};

void() sham_swingl1	=[      $swingl1,      sham_swingl2   ] {setHead('18 2 40');  				 // 57
	sound(self, CHAN_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
	ai_charge(5);
};

void() sham_swingl2 =[      $swingl2,      sham_swingl3   ] {setHead('12 -2 44');ai_charge(3);}; // 58
void() sham_swingl3 =[      $swingl3,      sham_swingl4   ] {setHead('1 -5 47');ai_charge(7);}; // 59
void() sham_swingl4 =[      $swingl4,      sham_swingl5   ] {setHead('-6 -3 45');ai_charge(3);}; // 60
void() sham_swingl5 =[      $swingl5,      sham_swingl6   ] {setHead('3 -2 45');ai_charge(7);}; // 61
void() sham_swingl6 =[      $swingl6,      sham_swingl7   ] {setHead('12 9 40');ai_charge(9);}; // 62
void() sham_swingl7 =[      $swingl7,      sham_swingl8   ] {setHead('7 18 35');ai_charge(5); ShamClaw(250);}; // 63
void() sham_swingl8 =[      $swingl8,      sham_swingl9   ] {setHead('12 15 36');ai_charge(4);}; // 64
void() sham_swingl9 =[      $swingl9,      sham_run1  ] {setHead('20 7 38'); // 65
	ai_charge(8);
	if (random()<0.5)
		self.think = sham_swingr1;
};
void() sham_swingr1	=[      $swingr1,      sham_swingr2   ] {setHead('19 2 40'); // 48
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() sham_swingr2	=[      $swingr2,      sham_swingr3   ] {setHead('12 5 44');ai_charge(8);}; // 49
void() sham_swingr3 =[      $swingr3,      sham_swingr4   ] {setHead('4 9 46');ai_charge(14);}; // 50
void() sham_swingr4 =[      $swingr4,      sham_swingr5   ] {setHead('-2 10 47');ai_charge(7);}; // 51
void() sham_swingr5 =[      $swingr5,      sham_swingr6   ] {setHead('6 6 46');ai_charge(3);}; // 52
void() sham_swingr6 =[      $swingr6,      sham_swingr7   ] {setHead('9 -7 41');ai_charge(6);}; // 53
void() sham_swingr7 =[      $swingr7,      sham_swingr8   ] {setHead('5 -17 36');ai_charge(6); ShamClaw(-250);}; // 54
void() sham_swingr8 =[      $swingr8,      sham_swingr9   ] {setHead('10 -14 37');ai_charge(3);}; // 55
void() sham_swingr9 =[      $swingr9,      sham_run1  ] {setHead('14 -4 39'); // 56
	ai_charge(1);
	ai_charge(10);
	if (random()<0.5)
		self.think = sham_swingl1;
};

void() sham_melee =
{
	local float chance;
	chance = random();

	if (chance > 0.6 || self.health == 600)
		sham_smash1 ();

	else if (chance > 0.3)
		sham_swingr1 ();

	else
		sham_swingl1 ();
};


//============================================================================

void() CastLightning =
{
	local	vector	org, dir;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	ai_face ();

	org = self.origin + '0 0 40';

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	traceline (org, self.origin + dir*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteByte (MSG_BROADCAST, 0);

	LightningDamage (org, trace_endpos, self, 10);
};

void() sham_magic1     =[      $magic1,       sham_magic2    ] {setHead('17 3 40');ai_face();  // 66
	sound (self, CHAN_WEAPON, "shambler/sattck1.wav", 1, ATTN_NORM);
};
void() sham_magic2     =[      $magic2,       sham_magic3    ] {setHead('-5 5 45');ai_face();}; // 67
void() sham_magic3     =[      $magic3,       sham_magic4    ] {setHead('-8 5 44');ai_face();}; // 68
void() sham_magic4     =[      $magic4,       sham_magic5    ] {setHead('-8 5 44');}; // 69
void() sham_magic5     =[      $magic5,       sham_magic6    ] {setHead('10 6 42');}; // 70
void() sham_magic6     =[      $magic6,       sham_magic7    ] {setHead('10 -6 35');}; // 71
void() sham_magic7     =[      $magic7,       sham_magic8    ] {setHead('12 -8 35');}; // 72
void() sham_magic8     =[      $magic8,       sham_magic9    ] {setHead('12 -8 36');}; // 73
void() sham_magic9     =[      $magic9,       sham_magic10   ] {setHead('11 -6 40');}; // 74
void() sham_magic10    =[      $magic10,      sham_magic11   ] {setHead('-26 -7 42');}; // 75
void() sham_magic11    =[      $magic11,      sham_magic12   ] {setHead('-2 2 45');}; // 76
void() sham_magic12    =[      $magic12,      sham_run1	   ]   {setHead('1 2 49');}; // 77

void() sham_pain1       =[      $pain1, sham_pain2      ] {setHead('17 2 39');}; // 78
void() sham_pain2       =[      $pain2, sham_pain3      ] {setHead('-13 4 46');}; // 79
void() sham_pain3       =[      $pain3, sham_pain4      ] {setHead('-12 5 45');}; // 80
void() sham_pain4       =[      $pain4, sham_pain5      ] {setHead('-7 6 45');}; // 81
void() sham_pain5       =[      $pain5, sham_pain6      ] {setHead('3 6 46');}; // 82
void() sham_pain6       =[      $pain6, sham_run1       ] {setHead('12 3 41');}; // 83

void(entity attacker, float damage)	sham_pain =
{
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if (self.health <= 0)
		return;		// already dying, don't go into pain frame

	if (random()*400 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;		
	sham_pain1 ();
};


//============================================================================

void() sham_death1      =[      $death1,       sham_death2     ] {};
void() sham_death2      =[      $death2,       sham_death3     ] {};
void() sham_death3      =[      $death3,       sham_death4     ] {};
void() sham_death4      =[      $death4,       sham_death5     ] {};
void() sham_death5      =[      $death5,       sham_death6     ] {};
void() sham_death6      =[      $death6,       sham_death7     ] {};
void() sham_death7      =[      $death7,       sham_death8     ] {};
void() sham_death8      =[      $death8,       sham_death9     ] {};
void() sham_death9      =[      $death9,       sham_death10    ] {};
void() sham_death10     =[      $death10,      sham_death11    ] {};
void() sham_death11     =[      $death11,      sham_death11    ] {};

void() sham_die =
{
	self.solid = SOLID_NOT;
	// check for gib
	if (self.lasthit_damage > self.gib_threshold)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shams.mdl", self.health);
		ThrowGib ("progs/m_gib_01.mdl", self.health);
		ThrowGib ("progs/m_gib_02.mdl", self.health);
		ThrowGib ("progs/m_gib_03.mdl", self.health);
		ThrowGib ("progs/m_gib_04.mdl", self.health);
		ThrowGib ("progs/m_gib_05.mdl", self.health);
		ThrowGib ("progs/shambler_gib_leg_up.mdl", self.health);
		ThrowGib ("progs/shambler_gib_leg_bottom.mdl", self.health);
		ThrowGib ("progs/shambler_gib_shield.mdl", self.health);
		return;
	}

	// regular death
	sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
	sham_death1 ();
};

//============================================================================

/*===========
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============*/
float() ShamCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;
		
	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	if (vlen(spot1 - spot2) > 600)
		return FALSE;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}

	// missile attack
	if (enemy_range == RANGE_FAR)
		return FALSE;
	
	return FALSE;
	/*
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (2 + 2*random());

	return TRUE;
	*/
};

/*QUAKED monster_shambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
void() monster_shambler =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/shambler.mdl");
	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/shambler_gib_leg_up.mdl");
	precache_model ("progs/shambler_gib_leg_bottom.mdl");
	precache_model ("progs/shambler_gib_shield.mdl");
	
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/shambler.mdl");
	
	//gnounc
	self.noise = "shambler/ssight.wav";	//gnounc
	self.netname = "Shambler";
	self.killstring = " was obliterated by the Berzerker\n";


	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 1000;
	self.max_health = 1000;
	self.monstertype = TYPE_SHAMBLER;
	self.head_offset = '16 2 43';
	self.head_size = 24;
	self.health_head = 300;
	self.armorclass_body = 60;
	self.armorclass_head = 80;
	self.gib_threshold = 300;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS | MFL_ROBOT;

	self.th_stand = sham_stand1;
	self.th_walk = sham_walk1;
	self.th_run = sham_run1;
	self.th_die = sham_die;
	self.th_melee = sham_melee;
	self.th_missile = sham_magic1;
	self.th_pain = sham_pain;
	
	walkmonster_start();
};
