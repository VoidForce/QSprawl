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

OGRE

==============================================================================
*/

$cd /raid/quake/id1/models/ogre_c
$origin 0 0 24
$base base		
$skin base

$frame	stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7
$frame walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame swing1 swing2 swing3 swing4 swing5 swing6 swing7
$frame swing8 swing9 swing10 swing11 swing12 swing13 swing14

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7
$frame smash8 smash9 smash10 smash11 smash12 smash13 smash14

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6

$frame pain1 pain2 pain3 pain4 pain5

$frame painb1 painb2 painb3

$frame painc1 painc2 painc3 painc4 painc5 painc6

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8 paind9 paind10
$frame paind11 paind12 paind13 paind14 paind15 paind16

$frame paine1 paine2 paine3 paine4 paine5 paine6 paine7 paine8 paine9 paine10
$frame paine11 paine12 paine13 paine14 paine15

$frame death1 death2 death3 death4 death5 death6
$frame death7 death8 death9 death10 death11 death12
$frame death13 death14

$frame bdeath1 bdeath2 bdeath3 bdeath4 bdeath5 bdeath6
$frame bdeath7 bdeath8 bdeath9 bdeath10

$frame pull1 pull2 pull3 pull4 pull5 pull6 pull7 pull8 pull9 pull10 pull11

//=============================================================================


void() OgreGrenadeExplode =
{
	removeFromList(self);
	T_RadiusDamage (self, self.owner, 40, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

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

void() OgreGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode();
		return;
	}

	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
OgreFireGrenade
================
*/
void() OgreFireGrenade =
{
	local	entity missile;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.classname = "ogre_grenade";	//gnounc
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
		
// set missile speed	

	makevectors2 (self.angles);

	missile.velocity = normalize(self.enemy.origin - self.origin);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = OgreGrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = OgreGrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward * 70 + v_up * 37);
	missile.isgrenade = 1;
	appendToList(missile);
};


//=============================================================================

/*
================
chainsaw

FIXME
================
*/
void(float side) chainsaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;

	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 4;
	T_Damage (self.enemy, self, self, ldmg, 0);
	
	if (side)
	{
		makevectors2 (self.angles);
		if (side == 1)
			SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
		else
			SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};


void() ogre_stand1	=[	$stand1,	ogre_stand2	] {setHead('3 2 45');ai_stand();}; // frame 1 stand
void() ogre_stand2	=[	$stand2,	ogre_stand3	] {setHead('3 2 45');ai_stand();}; // 2
void() ogre_stand3	=[	$stand3,	ogre_stand4	] {setHead('3 2 45');ai_stand();}; // 3
void() ogre_stand4	=[	$stand4,	ogre_stand5	] {setHead('3 2 45');ai_stand();}; // 4
void() ogre_stand5	=[	$stand5,	ogre_stand6	] {setHead('3 2 45'); // 5
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);

	ai_stand();
};

void() ogre_stand6	=[	$stand6,	ogre_stand7	] {setHead('3 2 45');ai_stand();}; // 6
void() ogre_stand7	=[	$stand7,	ogre_stand8	] {setHead('3 2 45');ai_stand();}; // 7
void() ogre_stand8	=[	$stand8,	ogre_stand9	] {setHead('3 2 45');ai_stand();}; // 8
void() ogre_stand9	=[	$stand9,	ogre_stand1	] {setHead('3 2 45');ai_stand();}; // 9

void() ogre_walk1	=[	$walk1,		ogre_walk2	] {setHead('7 4 43');ai_walk(3);}; // 10 walk
void() ogre_walk2	=[	$walk2,		ogre_walk3	] {setHead('7 4 42');ai_walk(2);}; // 11
void() ogre_walk3	=[	$walk3,		ogre_walk4	] {setHead('11 4 42'); // 12
	ai_walk(2);

	if (random() < 0.2)
		sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
};

void() ogre_walk4	=[	$walk4,		ogre_walk5	] {setHead('12 3 43');ai_walk(2);}; // 13
void() ogre_walk5	=[	$walk5,		ogre_walk6	] {setHead('11 2 44');ai_walk(2);}; // 14
void() ogre_walk6	=[	$walk6,		ogre_walk7	] {setHead('9 1 45'); // 15
	ai_walk(5);

	if (random() < 0.1)
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
};

void() ogre_walk7	=[	$walk7,		ogre_walk8	] {setHead('9 1 45');ai_walk(3);}; // 16
void() ogre_walk8	=[	$walk8,		ogre_walk9	] {setHead('8 2 44');ai_walk(2);}; // 17
void() ogre_walk9	=[	$walk9,		ogre_walk10	] {setHead('9 3 42');ai_walk(3);}; // 18
void() ogre_walk10	=[	$walk10,	ogre_walk11	] {setHead('13 3 41');ai_walk(1);}; // 19
void() ogre_walk11	=[	$walk11,	ogre_walk12	] {setHead('14 4 41');ai_walk(2);}; // 20
void() ogre_walk12	=[	$walk12,	ogre_walk13	] {setHead('13 3 43');ai_walk(3);}; // 21
void() ogre_walk13	=[	$walk13,	ogre_walk14	] {setHead('11 5 44');ai_walk(3);}; // 22
void() ogre_walk14	=[	$walk14,	ogre_walk15	] {setHead('9 4 44');ai_walk(3);}; // 23
void() ogre_walk15	=[	$walk15,	ogre_walk16	] {setHead('6 4 44');ai_walk(3);}; // 24
void() ogre_walk16	=[	$walk16,	ogre_walk1	] {setHead('6 4 44');ai_walk(4);}; // 25

void() ogre_run1	=[	$run1,		ogre_run2	] {setHead('11 -2 42'); // 26 run
	ai_run(9);

	if (random() < 0.2)
		sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};

void() ogre_run2	=[	$run2,		ogre_run3	] {setHead('14 -2 40');ai_run(12);}; // 27
void() ogre_run3	=[	$run3,		ogre_run4	] {setHead('16 -3 42');ai_run(8);};  // 28
void() ogre_run4	=[	$run4,		ogre_run5	] {setHead('14 -2 45');ai_run(22);}; // 29
void() ogre_run5	=[	$run5,		ogre_run6	] {setHead('13 -2 41');ai_run(16);}; // 30
void() ogre_run6	=[	$run6,		ogre_run7	] {setHead('13 0 40');ai_run(4);};  // 31
void() ogre_run7	=[	$run7,		ogre_run8	] {setHead('15 -1 41');ai_run(13);}; // 32
void() ogre_run8	=[	$run8,		ogre_run1	] {setHead('13 1 44');ai_run(24);}; // 33

void() ogre_swing1	=[	$swing1,		ogre_swing2	] {setHead('-1 2 40');ai_charge(11); // 34 swing
sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);};
void() ogre_swing2	=[	$swing2,		ogre_swing3	] {setHead('1 2 41');ai_charge(1);}; // 35
void() ogre_swing3	=[	$swing3,		ogre_swing4	] {setHead('4 2 42');ai_charge(4);}; // 36
void() ogre_swing4	=[	$swing4,		ogre_swing5	] {setHead('7 1 44');ai_charge(13);}; // 37
void() ogre_swing5	=[	$swing5,		ogre_swing6	] {setHead('8 -2 42'); // 38
	ai_charge(9); 
	chainsaw(0);
	self.angles_y = self.angles_y + random()*25;
};

void() ogre_swing6	=[	$swing6,		ogre_swing7	] {setHead('7 -4 40'); // 39
	chainsaw(200);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing7	=[	$swing7,		ogre_swing8	] {setHead('4 -7 39');  // 40
	chainsaw(0);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing8	=[	$swing8,		ogre_swing9	] {setHead('1 -11 38'); // 41
	chainsaw(0);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing9	=[	$swing9,		ogre_swing10 ] {setHead('0 -12 39'); // 42
	chainsaw(0);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing10	=[	$swing10,		ogre_swing11 ] {setHead('-2 -10 40'); // 43
	chainsaw(-200);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing11	=[	$swing11,		ogre_swing12 ] {setHead('-2 -9 40'); // 44
	chainsaw(0);
	self.angles_y = self.angles_y + random()* 25;
};

void() ogre_swing12	=[	$swing12,		ogre_swing13 ] {setHead('3 -7 41');ai_charge(3);}; // 45
void() ogre_swing13	=[	$swing13,		ogre_swing14 ] {setHead('8 -3 40');ai_charge(8);}; // 46
void() ogre_swing14	=[	$swing14,		ogre_run1	] {setHead('7 2 42');ai_charge(9);}; // 47

void() ogre_smash1	=[	$smash1,		ogre_smash2	] {setHead('3 1 40');ai_charge(6);  // 48 smash
sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);
};
void() ogre_smash2	=[	$smash2,		ogre_smash3	] {setHead('1 -1 40');ai_charge(0);}; // 49
void() ogre_smash3	=[	$smash3,		ogre_smash4	] {setHead('-1 -3 39');ai_charge(0);}; // 50
void() ogre_smash4	=[	$smash4,		ogre_smash5	] {setHead('-3 -6 41');ai_charge(1);}; // 51
void() ogre_smash5	=[	$smash5,		ogre_smash6	] {setHead('-5 -6 43');ai_charge(4);}; // 52
void() ogre_smash6	=[	$smash6,		ogre_smash7	] {setHead('-5 -5 45');ai_charge(4); chainsaw(0);}; // 53
void() ogre_smash7	=[	$smash7,		ogre_smash8	] {setHead('-4 -5 46');ai_charge(4); chainsaw(0);}; // 54
void() ogre_smash8	=[	$smash8,		ogre_smash9	] {setHead('4 1 41');ai_charge(10); chainsaw(0);}; // 55
void() ogre_smash9	=[	$smash9,		ogre_smash10 ] {setHead('22 -1 27');ai_charge(13); chainsaw(0);}; // 56
void() ogre_smash10	=[	$smash10,		ogre_smash11 ] {setHead('25 -3 22');chainsaw(1);}; // 57
void() ogre_smash11	=[	$smash11,		ogre_smash12 ] {setHead('26 -1 24');  // 58
	ai_charge(2); 
	chainsaw(0);
	self.nextthink = self.nextthink + random()*0.2;
};	// slight variation

void() ogre_smash12	=[	$smash12,		ogre_smash13 ] {setHead('21 0 30');ai_charge(0);}; // 59
void() ogre_smash13	=[	$smash13,		ogre_smash14 ] {setHead('14 4 37');ai_charge(4);}; // 60
void() ogre_smash14	=[	$smash14,		ogre_run1	] {setHead('7 7 42');ai_charge(12);}; // 61

void() ogre_nail1	=[	$shoot1,		ogre_nail2	] {setHead('9 4 41');ai_face();}; // 62 fire
void() ogre_nail2	=[	$shoot2,		ogre_nail3	] {setHead('10 1 39');ai_face();}; // 63
void() ogre_nail3	=[	$shoot2,		ogre_nail4	] {setHead('10 1 39');ai_face();}; // 63 - double 
void() ogre_nail4	=[	$shoot3,		ogre_nail5	] {setHead('10 -1 38');ai_face();OgreFireGrenade();}; // 64
void() ogre_nail5	=[	$shoot4,		ogre_nail6	] {setHead('-17 -6 41');ai_face();}; // 65
void() ogre_nail6	=[	$shoot5,		ogre_nail7	] {setHead('-5 2 43');ai_face();}; // 66
void() ogre_nail7	=[	$shoot6,		ogre_run1	] {setHead('5 2 43');ai_face();}; // 67

void()	ogre_pain1	=[	$pain1,		ogre_pain2	] {setHead('4 2 43');}; // 68
void()	ogre_pain2	=[	$pain2,		ogre_pain3	] {setHead('-2 2 42');}; // 69
void()	ogre_pain3	=[	$pain3,		ogre_pain4	] {setHead('-19 1 38');}; // 70
void()	ogre_pain4	=[	$pain4,		ogre_pain5	] {setHead('-13 2 41');}; // 71
void()	ogre_pain5	=[	$pain5,		ogre_run1	] {setHead('-3 4 44');}; // 72

void()	ogre_painb1	=[	$painb1,	ogre_painb2	] {setHead('5 2 42');}; // 73
void()	ogre_painb2	=[	$painb2,	ogre_painb3	] {setHead('0 3 43');}; // 74
void()	ogre_painb3	=[	$painb3,	ogre_run1	] {setHead('-16 1 42');}; // 75

void()	ogre_painc1	=[	$painc1,	ogre_painc2	] {setHead('5 5 42');}; // 76
void()	ogre_painc2	=[	$painc2,	ogre_painc3	] {setHead('-12 1 42');}; // 77
void()	ogre_painc3	=[	$painc3,	ogre_painc4	] {setHead('-13 -14 45');}; // 78
void()	ogre_painc4	=[	$painc4,	ogre_painc5	] {setHead('-11 11 37');}; // 79
void()	ogre_painc5	=[	$painc5,	ogre_painc6	] {setHead('-4 -2 41');}; // 80
void()	ogre_painc6	=[	$painc6,	ogre_run1	] {setHead('2 4 40');}; // 81

void()	ogre_paind1	=[	$paind1,	ogre_paind2	] {setHead('-12 2 44');}; // 82
void()	ogre_paind2	=[	$paind2,	ogre_paind3	] {setHead('-15 2 39');ai_pain(10);}; // 83
void()	ogre_paind3	=[	$paind3,	ogre_paind4	] {setHead('-18 2 27');ai_pain(9);}; // 84
void()	ogre_paind4	=[	$paind4,	ogre_paind5	] {setHead('-15 2 19');ai_pain(4);}; // 85
void()	ogre_paind5	=[	$paind5,	ogre_paind6	] {setHead('-12 1 17');}; // 86
void()	ogre_paind6	=[	$paind6,	ogre_paind7	] {setHead('-5 1 12');}; // 87
void()	ogre_paind7	=[	$paind7,	ogre_paind8	] {setHead('-6 1 13');}; // 88
void()	ogre_paind8	=[	$paind8,	ogre_paind9	] {setHead('-10 0 15');}; // 89
void()	ogre_paind9	=[	$paind9,	ogre_paind10] {setHead('-9 -2 17');}; // 90
void()	ogre_paind10=[	$paind10,	ogre_paind11] {setHead('-2 -5 18');}; // 91
void()	ogre_paind11=[	$paind11,	ogre_paind12] {setHead('5 -9 19');}; // 92
void()	ogre_paind12=[	$paind12,	ogre_paind13] {setHead('12 -9 18');}; // 93
void()	ogre_paind13=[	$paind13,	ogre_paind14] {setHead('14 -10 19');}; // 94
void()	ogre_paind14=[	$paind14,	ogre_paind15] {setHead('15 -9 23');}; // 95
void()	ogre_paind15=[	$paind15,	ogre_paind16] {setHead('13 -6 32');}; // 96
void()	ogre_paind16=[	$paind16,	ogre_run1	] {setHead('8 0 40');}; // 97

void()	ogre_paine1	=[	$paine1,	ogre_paine2	] {setHead('-10 4 41');}; // 98
void()	ogre_paine2	=[	$paine2,	ogre_paine3	] {setHead('-20 3 37');ai_pain(10);}; // 99
void()	ogre_paine3	=[	$paine3,	ogre_paine4	] {setHead('-22 0 35');ai_pain(9);}; // 100
void()	ogre_paine4	=[	$paine4,	ogre_paine5	] {setHead('-27 3 25');ai_pain(4);}; // 101
void()	ogre_paine5	=[	$paine5,	ogre_paine6	] {setHead('-27 6 24');}; // 102
void()	ogre_paine6	=[	$paine6,	ogre_paine7	] {setHead('-19 9 26');}; // 103
void()	ogre_paine7	=[	$paine7,	ogre_paine8	] {setHead('-11 13 27');}; // 104
void()	ogre_paine8	=[	$paine8,	ogre_paine9	] {setHead('-4 14 26');}; // 105
void()	ogre_paine9	=[	$paine9,	ogre_paine10] {setHead('0 15 25');}; // 106
void()	ogre_paine10=[	$paine10,	ogre_paine11] {setHead('1 15 25');}; // 107
void()	ogre_paine11=[	$paine11,	ogre_paine12] {setHead('6 12 26');}; // 108
void()	ogre_paine12=[	$paine12,	ogre_paine13] {setHead('10 8 31');}; // 109
void()	ogre_paine13=[	$paine13,	ogre_paine14] {setHead('10 4 35');}; // 110
void()	ogre_paine14=[	$paine14,	ogre_paine15] {setHead('5 1 40');}; // 111
void()	ogre_paine15=[	$paine15,	ogre_run1	] {setHead('0 0 42');}; // 112


void(entity attacker, float damage)	ogre_pain =
{
	local float	r;

	// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	r = random();
	
	if (r < 0.25)
	{
		ogre_pain1 ();
		self.pain_finished = time + 1;
	}

	else if (r < 0.5)
	{
		ogre_painb1 ();
		self.pain_finished = time + 1;
	}

	else if (r < 0.75)
	{
		ogre_painc1 ();
		self.pain_finished = time + 1;
	}

	else if (r < 0.88)
	{
		ogre_paind1 ();
		self.pain_finished = time + 2;
	}

	else
	{
		ogre_paine1 ();
		self.pain_finished = time + 2;
	}
};

void()	ogre_die1	=[	$death1,	ogre_die2	] {};
void()	ogre_die2	=[	$death2,	ogre_die3	] {};
void()	ogre_die3	=[	$death3,	ogre_die4	] {};

void()	ogre_die4	=[	$death4,	ogre_die5	] {};
void()	ogre_die5	=[	$death5,	ogre_die6	] {};
void()	ogre_die6	=[	$death6,	ogre_die7	] {};
void()	ogre_die7	=[	$death7,	ogre_die8	] {};
void()	ogre_die8	=[	$death8,	ogre_die9	] {};
void()	ogre_die9	=[	$death9,	ogre_die10	] {};
void()	ogre_die10	=[	$death10,	ogre_die11	] {};
void()	ogre_die11	=[	$death11,	ogre_die12	] {};
void()	ogre_die12	=[	$death12,	ogre_die13	] {};
void()	ogre_die13	=[	$death13,	ogre_die14	] {};
void()	ogre_die14	=[	$death14,	ogre_die14	] {};

void()	ogre_bdie1	=[	$bdeath1,	ogre_bdie2	] {};
void()	ogre_bdie2	=[	$bdeath2,	ogre_bdie3	] {ai_forward(5);};
void()	ogre_bdie3	=[	$bdeath3,	ogre_bdie4	] {};

void()	ogre_bdie4	=[	$bdeath4,	ogre_bdie5	] {ai_forward(1);};
void()	ogre_bdie5	=[	$bdeath5,	ogre_bdie6	] {ai_forward(3);};
void()	ogre_bdie6	=[	$bdeath6,	ogre_bdie7	] {ai_forward(7);};
void()	ogre_bdie7	=[	$bdeath7,	ogre_bdie8	] {ai_forward(25);};
void()	ogre_bdie8	=[	$bdeath8,	ogre_bdie9	] {};
void()	ogre_bdie9	=[	$bdeath9,	ogre_bdie10	] {};
void()	ogre_bdie10	=[	$bdeath10,	ogre_bdie10	] {};

void() ogre_die =
{
	self.solid = SOLID_NOT;
	// check for gib
	if (self.health <= 0 && self.lasthit_damage > self.gib_threshold)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_ogre.mdl", self.health);
		ThrowGib ("progs/m_gib_01.mdl", self.health);
		ThrowGib ("progs/ogre_gib_hand.mdl", self.health);
		ThrowGib ("progs/m_gib_03.mdl", self.health);
		ThrowGib ("progs/ogre_gib_leg.mdl", self.health);
		ThrowGib ("progs/ogre_gib_plate.mdl", self.health);
		return;
	}
	
	if (self.health_head <= 0)
	{
		setmodel (self, "progs/ogre_headless.mdl");
		setsize (self, '-32 -32 -24', '32 32 48');
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHeadGib ("progs/m_gib_02.mdl", self.lasthit_direction * (300 + random()*100) + [crandom()* 200,crandom()* 200,random()* 200], 0);
		ThrowHeadGib ("progs/m_gib_04.mdl", self.lasthit_direction * (300 + random()*100) + [crandom()* 200,crandom()* 200,random()* 200], 0);
		ThrowHeadGib ("progs/m_gib_05.mdl", self.lasthit_direction * (300 + random()*100) + [crandom()* 200,crandom()* 200,random()* 200], 0);
	}
	else
		sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	
	if (random() < 0.5)
		ogre_die1 ();
	else
		ogre_bdie1 ();
};

void() ogre_melee =
{
	if (random() > 0.5)
		ogre_smash1 ();

	else
		ogre_swing1 ();
};

/*===========
OgreCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============*/
float() OgreCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

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

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}

	// missile attack
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	else if (enemy_range == RANGE_NEAR)
		chance = 0.10;

	else if (enemy_range == RANGE_MID)
		chance = 0.05;

	else
		chance = 0;

	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (1 + 2*random());

	return TRUE;
};

/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_ogre =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/ogre.mdl");
	precache_model ("progs/h_ogre.mdl");
	precache_model ("progs/ogre_headless.mdl");
	precache_model ("progs/ogre_gib_hand.mdl");
	precache_model ("progs/ogre_gib_leg.mdl");
	precache_model ("progs/ogre_gib_plate.mdl");

	precache_model ("progs/grenade.mdl");

	precache_sound ("ogre/ogdrag.wav");
	precache_sound ("ogre/ogdth.wav");
	precache_sound ("ogre/ogidle.wav");
	precache_sound ("ogre/ogidle2.wav");
	precache_sound ("ogre/ogpain1.wav");
	precache_sound ("ogre/ogsawatk.wav");
	precache_sound ("ogre/ogwake.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/ogre.mdl");

	//gnounc
	self.noise = "ogre/ogwake.wav";	//gnounc
	self.netname = "Ogre";
	self.killstring = " was destroyed by the ohGr\n";

	setsize (self, '-32 -32 -24', '32 32 48');
	self.head_offset = '3 2 45';
	self.head_size = 16;
	self.health = 400;
	self.max_health = 400;
	self.health_head = 150;
	self.armorclass_body = 50;
	self.armorclass_head = 25;
	self.gib_threshold = 180;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS | MFL_ROBOT;
	self.monstertype = TYPE_OGRE;
	
	self.th_stand = ogre_stand1;
	self.th_walk = ogre_walk1;
	self.th_run = ogre_run1;
	self.th_die = ogre_die;
	self.th_melee = ogre_melee;
	self.th_missile = ogre_nail1;
	self.th_pain = ogre_pain;

	walkmonster_start();
};

void() monster_ogre_marksman =
{
	monster_ogre ();
};


