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

KNIGHT

==============================================================================
*/

$cd /raid/quake/id1/models/knight2
$origin 0 0 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15 walk16 walk17
$frame walk18 walk19 walk20

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame char_a1 char_a2 char_a3 char_a4 char_a5 char_a6 char_a7 char_a8
$frame char_a9 char_a10 char_a11 char_a12 char_a13 char_a14 char_a15 char_a16

$frame magica1 magica2 magica3 magica4 magica5 magica6 magica7 magica8
$frame magica9 magica10 magica11 magica12 magica13 magica14

$frame magicb1 magicb2 magicb3 magicb4 magicb5 magicb6 magicb7 magicb8
$frame magicb9 magicb10 magicb11 magicb12 magicb13

$frame char_b1 char_b2 char_b3 char_b4 char_b5 char_b6

$frame slice1 slice2 slice3 slice4 slice5 slice6 slice7 slice8 slice9 slice10

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 smash8 smash9 smash10
$frame smash11

$frame w_attack1 w_attack2 w_attack3 w_attack4 w_attack5 w_attack6 w_attack7 
$frame w_attack8 w_attack9 w_attack10 w_attack11 w_attack12 w_attack13 w_attack14
$frame w_attack15 w_attack16 w_attack17 w_attack18 w_attack19 w_attack20 
$frame w_attack21 w_attack22 

$frame magicc1 magicc2 magicc3 magicc4 magicc5 magicc6 magicc7 magicc8
$frame magicc9 magicc10 magicc11


void() hellknight_trail =
{
	entity trail;
	trail = spawn();
	
	trail.solid = SOLID_NOT;
	trail.movetype = MOVETYPE_NONE;
	setmodel (trail, "progs/hknight_trail.mdl");
	setsize (trail, '-16 -16 -24', '16 16 40'); //28
	setorigin(trail, self.origin);
	trail.angles = self.angles;
	trail.alpha = 0.01;
	trail.cnt = 1;
	trail.frame = self.frame;
	trail.think = knight_trail_fade;
	trail.nextthink = time + 0.1;
};

void() CheckForCharge =
{
	// check for mad charge
	if (!enemy_vis)
		return;

	if (time < self.attack_finished)
		return;	

	if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
		return;		// too much height change

	if ( vlen (self.origin - self.enemy.origin) < 80)
		return;		// use regular attack

	// charge		
	SUB_AttackFinished (2);
	hknight_char_a1 ();
};

void() hknight_sound =
{
	if (random() > 0.5)
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
};

void() CheckContinueCharge =
{
	if (time > self.attack_finished)
	{
		SUB_AttackFinished (3);
		hknight_run1 ();
		return;		// done charging
	}

	hknight_sound();
};

//===========================================================================

void()	hknight_stand1	=[	$stand1,	hknight_stand2	] {setHead('9 2 32');ai_stand();}; // 1
void()	hknight_stand2	=[	$stand2,	hknight_stand3	] {setHead('9 2 32');ai_stand();}; // 2
void()	hknight_stand3	=[	$stand3,	hknight_stand4	] {setHead('9 2 32');ai_stand();}; // 3
void()	hknight_stand4	=[	$stand4,	hknight_stand5	] {setHead('9 2 32');ai_stand();}; // 4
void()	hknight_stand5	=[	$stand5,	hknight_stand6	] {setHead('9 2 32');ai_stand();}; // 5
void()	hknight_stand6	=[	$stand6,	hknight_stand7	] {setHead('9 2 32');ai_stand();}; // 6
void()	hknight_stand7	=[	$stand7,	hknight_stand8	] {setHead('9 2 32');ai_stand();}; // 7
void()	hknight_stand8	=[	$stand8,	hknight_stand9	] {setHead('9 2 32');ai_stand();}; // 8
void()	hknight_stand9	=[	$stand9,	hknight_stand1	] {setHead('9 2 32');ai_stand();}; // 9

//===========================================================================

void()	hknight_walk1	=[	$walk1,		hknight_walk2	] {setHead('9 1 29');hk_idle_sound(); ai_walk(2);};  // 10
void()	hknight_walk2	=[	$walk2,		hknight_walk3	] {setHead('9 1 30');ai_walk(5);}; // 11
void()	hknight_walk3	=[	$walk3,		hknight_walk4	] {setHead('9 2 31');ai_walk(5);}; // 12
void()	hknight_walk4	=[	$walk4,		hknight_walk5	] {setHead('8 2 33');ai_walk(4);}; // 13
void()	hknight_walk5	=[	$walk5,		hknight_walk6	] {setHead('6 2 35');ai_walk(4);}; // 14
void()	hknight_walk6	=[	$walk6,		hknight_walk7	] {setHead('7 2 35');ai_walk(2);}; // 15
void()	hknight_walk7	=[	$walk7,		hknight_walk8	] {setHead('7 2 35');ai_walk(2);}; // 16
void()	hknight_walk8	=[	$walk8,		hknight_walk9	] {setHead('7 2 34');ai_walk(3);}; // 17
void()	hknight_walk9	=[	$walk9,		hknight_walk10	] {setHead('6 2 33');ai_walk(3);}; // 18
void()	hknight_walk10	=[	$walk10,	hknight_walk11	] {setHead('7 2 31');ai_walk(4);}; // 19
void()	hknight_walk11	=[	$walk11,	hknight_walk12	] {setHead('8 2 29');ai_walk(3);}; // 20
void()	hknight_walk12	=[	$walk12,	hknight_walk13	] {setHead('10 3 31');ai_walk(4);}; // 21
void()	hknight_walk13	=[	$walk13,	hknight_walk14	] {setHead('10 2 33');ai_walk(6);}; // 22
void()	hknight_walk14	=[	$walk14,	hknight_walk15	] {setHead('7 2 34');ai_walk(2);}; // 23
void()	hknight_walk15	=[	$walk15,	hknight_walk16	] {setHead('5 3 35');ai_walk(2);}; // 24
void()	hknight_walk16	=[	$walk16,	hknight_walk17	] {setHead('6 3 35');ai_walk(4);}; // 25
void()	hknight_walk17	=[	$walk17,	hknight_walk18	] {setHead('7 3 34');ai_walk(3);}; // 26
void()	hknight_walk18	=[	$walk18,	hknight_walk19	] {setHead('8 2 33');ai_walk(3);}; // 27
void()	hknight_walk19	=[	$walk19,	hknight_walk20	] {setHead('9 2 32');ai_walk(3);}; // 28
void()	hknight_walk20	=[	$walk20,	hknight_walk1	] {setHead('9 2 31');ai_walk(2);}; // 29

//===========================================================================

void()	hknight_run1	=[	$run1,		hknight_run2	]{Think(0.075);setHead('11 1 29');  // 30 run
	ai_run (18); 
	CheckForCharge (); 
};
void()	hknight_run2	=[	$run2,		hknight_run3	] {Think(0.075);setHead('9 1 29');ai_run(18);}; // 31
void()	hknight_run3	=[	$run3,		hknight_run4	] {Think(0.075);setHead('11 3 33');ai_run(18);}; // 32
void()	hknight_run4	=[	$run4,		hknight_run5	] {Think(0.075);setHead('11 3 28');ai_run(16);}; // 33
void()	hknight_run5	=[	$run5,		hknight_run6	] {Think(0.075);setHead('11 3 28');ai_run(14);}; // 34
void()	hknight_run6	=[	$run6,		hknight_run7	] {Think(0.075);setHead('9 2 28');ai_run(18);}; // 35
void()	hknight_run7	=[	$run7,		hknight_run8	] {Think(0.075);setHead('6 1 33');ai_run(18);}; // 36
void()	hknight_run8	=[	$run8,		hknight_run1	] {Think(0.075);setHead('8 1 32');ai_run(13);}; // 37

//============================================================================

void()	hknight_pain1	=[	$pain1,		hknight_pain2	] {setHead('-4 3 34');   // 38
	sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);
};
void()	hknight_pain2	=[	$pain2,		hknight_pain3	] {setHead('-4 3 34');}; // 39
void()	hknight_pain3	=[	$pain3,		hknight_pain4	] {setHead('-3 3 34');}; // 40
void()	hknight_pain4	=[	$pain4,		hknight_pain5	] {setHead('0 2 33');}; // 41
void()	hknight_pain5	=[	$pain5,		hknight_run1	] {setHead('2 2 33');}; // 42

//============================================================================

void()	hknight_die1	=[	$death1,	hknight_die2	] {hellknight_trail();ai_forward(10);}; 
void()	hknight_die2	=[	$death2,	hknight_die3	] {hellknight_trail();ai_forward(8);};
void()	hknight_die3	=[	$death3,	hknight_die4	] {hellknight_trail();ai_forward(7);};
void()	hknight_die4	=[	$death4,	hknight_die5	] {hellknight_trail();};
void()	hknight_die5	=[	$death5,	hknight_die6	] {hellknight_trail();};
void()	hknight_die6	=[	$death6,	hknight_die7	] {hellknight_trail();};
void()	hknight_die7	=[	$death7,	hknight_die8	] {};
void()	hknight_die8	=[	$death8,	hknight_die9	] {ai_forward(10);};
void()	hknight_die9	=[	$death9,	hknight_die10	] {ai_forward(11);};
void()	hknight_die10	=[	$death10,	hknight_die11	] {};
void()	hknight_die11	=[	$death11,	hknight_die12	] {};
void()	hknight_die12	=[	$death12,	decay	] {};

void()	hknight_dieb1	=[	$deathb1,	hknight_dieb2	] {hellknight_trail();};
void()	hknight_dieb2	=[	$deathb2,	hknight_dieb3	] {hellknight_trail();};
void()	hknight_dieb3	=[	$deathb3,	hknight_dieb4	] {hellknight_trail();};
void()	hknight_dieb4	=[	$deathb4,	hknight_dieb5	] {hellknight_trail();};
void()	hknight_dieb5	=[	$deathb5,	hknight_dieb6	] {hellknight_trail();};
void()	hknight_dieb6	=[	$deathb6,	hknight_dieb7	] {hellknight_trail();};
void()	hknight_dieb7	=[	$deathb7,	hknight_dieb8	] {};
void()	hknight_dieb8	=[	$deathb8,	hknight_dieb9	] {};
void()	hknight_dieb9	=[	$deathb9,	decay	] {};

//============================================================================

void()	hknight_magica1 =[	$magica1,	hknight_magica2	] {setHead('4 2 32');ai_face();}; // 80
void()	hknight_magica2 =[	$magica2,	hknight_magica3	] {setHead('1 2 34');ai_face();}; // 81
void()	hknight_magica3 =[	$magica3,	hknight_magica4	] {setHead('-2 2 35');ai_face();}; // 82
void()	hknight_magica4 =[	$magica4,	hknight_magica5	] {setHead('-6 1 35');ai_face();}; // 83
void()	hknight_magica5 =[	$magica5,	hknight_magica6	] {setHead('-10 0 33');ai_face();}; // 84
void()	hknight_magica6 =[	$magica6,	hknight_magica7	] {setHead('-13 0 31');ai_face();}; // 85
void()	hknight_magica7 =[	$magica7,	hknight_magica8	] {setHead('-14 0 30');}; // 86
void()	hknight_magica8 =[	$magica8,	hknight_magica9	] {setHead('-1 2 34');}; // 87
void()	hknight_magica9 =[	$magica9,	hknight_magica10] {setHead('17 2 27');}; // 88
void()	hknight_magica10 =[	$magica10,	hknight_magica11] {setHead('25 2 18');}; // 89
void()	hknight_magica11 =[	$magica11,	hknight_magica12] {setHead('26 2 17');}; // 90
void()	hknight_magica12 =[	$magica12,	hknight_magica13] {setHead('18 1 25');}; // 91
void()	hknight_magica13 =[	$magica13,	hknight_magica14] {setHead('14 1 28');ai_face();}; // 92
void()	hknight_magica14 =[	$magica14,	hknight_run1	] {setHead('9 2 30');ai_face();}; // 93

//============================================================================

void()	hknight_magicb1 =[	$magicb1,	hknight_magicb2	] {setHead('4 2 32');ai_face();}; // 94
void()	hknight_magicb2 =[	$magicb2,	hknight_magicb3	] {setHead('1 2 34');ai_face();}; // 95
void()	hknight_magicb3 =[	$magicb3,	hknight_magicb4	] {setHead('-1 2 35');ai_face();}; // 96
void()	hknight_magicb4 =[	$magicb4,	hknight_magicb5	] {setHead('-2 2 35');ai_face();}; // 97
void()	hknight_magicb5 =[	$magicb5,	hknight_magicb6	] {setHead('-3 2 35');ai_face();}; // 98
void()	hknight_magicb6 =[	$magicb6,	hknight_magicb7	] {setHead('-3 2 34');ai_face();}; // 99
void()	hknight_magicb7 =[	$magicb7,	hknight_magicb8	] {setHead('-1 2 33');}; // 100
void()	hknight_magicb8 =[	$magicb8,	hknight_magicb9	] {setHead('-1 2 33');}; // 101
void()	hknight_magicb9 =[	$magicb9,	hknight_magicb10] {setHead('-3 3 33');}; // 102
void()	hknight_magicb10 =[	$magicb10,	hknight_magicb11] {setHead('-3 3 33');}; // 103
void()	hknight_magicb11 =[	$magicb11,	hknight_magicb12] {setHead('-3 3 33');}; // 104
void()	hknight_magicb12 =[	$magicb12,	hknight_magicb13] {setHead('-1 3 33');}; // 105
void()	hknight_magicb13 =[	$magicb13,	hknight_run1] 	  {setHead('2 3 33');ai_face();}; // 106

//============================================================================

void()	hknight_magicc1 =[	$magicc1,	hknight_magicc2	] {setHead('9 2 30');ai_face();}; // 156
void()	hknight_magicc2 =[	$magicc2,	hknight_magicc3	] {setHead('7 5 26');ai_face();}; // 157
void()	hknight_magicc3 =[	$magicc3,	hknight_magicc4	] {setHead('5 10 21');ai_face();}; // 158
void()	hknight_magicc4 =[	$magicc4,	hknight_magicc5	] {setHead('5 14 16');ai_face();}; // 159
void()	hknight_magicc5 =[	$magicc5,	hknight_magicc6	] {setHead('8 5 23');ai_face();}; // 160
void()	hknight_magicc6 =[	$magicc6,	hknight_magicc7	] {setHead('12 1 26');  }; // 161
void()	hknight_magicc7 =[	$magicc7,	hknight_magicc8	] {setHead('10 -3 29'); }; // 162
void()	hknight_magicc8 =[	$magicc8,	hknight_magicc9	] {setHead('5 -8 30');  }; // 163
void()	hknight_magicc9 =[	$magicc9,	hknight_magicc10] {setHead('13 -11 28');}; // 164
void()	hknight_magicc10 =[	$magicc10,	hknight_magicc11] {setHead('13 -9 28'); }; // 165
void()	hknight_magicc11 =[	$magicc11,	hknight_run1] 	  {setHead('13 -2 30'); }; // 166

//===========================================================================

void()	hknight_char_a1	=[	$char_a1,	hknight_char_a2	] {ai_charge_side(); setHead('11 0 29');ai_charge(20);}; // 64
void()	hknight_char_a2	=[	$char_a2,	hknight_char_a3	] {ai_charge_side(); setHead('10 1 30');ai_charge(25);}; // 65
void()	hknight_char_a3	=[	$char_a3,	hknight_char_a4	] {ai_charge_side(); setHead('11 3 33');ai_charge(18);}; // 66
void()	hknight_char_a4	=[	$char_a4,	hknight_char_a5	] {ai_charge_side(); setHead('6 3 30');ai_charge(16);}; // 67
void()	hknight_char_a5	=[	$char_a5,	hknight_char_a6	] {ai_charge_side(); setHead('11 -1 29');ai_charge(14);}; // 68
void()	hknight_char_a6	=[	$char_a6,	hknight_char_a7	] {ai_charge_side(); setHead('12 -1 26');ai_charge(20); ai_melee();}; // 69
void()	hknight_char_a7	=[	$char_a7,	hknight_char_a8	] {ai_charge_side(); setHead('14 -3 27');ai_charge(21);hknight_sound(); ai_melee();}; // 70
void()	hknight_char_a8	=[	$char_a8,	hknight_char_a9	] {ai_charge_side(); setHead('12 -1 30');ai_charge(13); ai_melee();}; // 71
void()	hknight_char_a9	=[	$char_a9,	hknight_char_a10] {ai_charge_side(); setHead('11 0 29');ai_charge(20); ai_melee();}; // 72
void()	hknight_char_a10=[	$char_a10,	hknight_char_a11] {ai_charge_side(); setHead('8 0 30');ai_charge(20); ai_melee();}; // 73
void()	hknight_char_a11=[	$char_a11,	hknight_char_a12] {ai_charge_side(); setHead('9 -1 34');ai_charge(18); ai_melee();}; // 74
void()	hknight_char_a12=[	$char_a12,	hknight_char_a13] {ai_charge_side(); setHead('10 0 29');ai_charge(16);}; // 75
void()	hknight_char_a13=[	$char_a13,	hknight_char_a14] {ai_charge_side(); setHead('7 0 30');ai_charge(14);}; // 76
void()	hknight_char_a14=[	$char_a14,	hknight_char_a15] {ai_charge_side(); setHead('8 2 28');ai_charge(25);}; // 77
void()	hknight_char_a15=[	$char_a15,	hknight_char_a16] {ai_charge_side(); setHead('9 3 31');ai_charge(21);}; // 78
void()	hknight_char_a16=[	$char_a16,	hknight_run1	] {ai_charge_side(); setHead('11 3 29');ai_charge(13);}; // 79

//===========================================================================

void()	hknight_char_b1	=[	$char_b1,	hknight_char_b2	] {ai_charge_side(); setHead('1 3 31');CheckContinueCharge (); ai_charge(23); ai_melee();}; // 107
void()	hknight_char_b2	=[	$char_b2,	hknight_char_b3	] {Think(0.08);ai_charge_side(); setHead('9 2 32');ai_charge(17);hknight_sound(); ai_melee();}; // 108
void()	hknight_char_b3	=[	$char_b3,	hknight_char_b4	] {Think(0.06);ai_charge_side(); setHead('10 2 31');ai_charge(12); ai_melee();}; // 109
void()	hknight_char_b4	=[	$char_b4,	hknight_char_b5	] {Think(0.04);ai_charge_side(); setHead('10 0 29');ai_charge(22); ai_melee();}; // 110
void()	hknight_char_b5	=[	$char_b5,	hknight_char_b6	] {ai_charge_side(); setHead('15 -2 29');ai_charge(18); ai_melee();}; // 111
void()	hknight_char_b6	=[	$char_b6,	hknight_char_b1	] {ai_charge_side(); setHead('12 -3 32');ai_charge(8); ai_melee();}; // 112

//===========================================================================

void()	hknight_slice1	=[	$slice1,	hknight_slice2	] {ai_charge_side(); setHead('3 3 34');ai_charge(9);}; // 113
void()	hknight_slice2	=[	$slice2,	hknight_slice3	] {ai_charge_side(); setHead('2 7 30');ai_charge(6);}; // 114
void()	hknight_slice3	=[	$slice3,	hknight_slice4	] {ai_charge_side(); setHead('-5 10 34');ai_charge(13);}; // 115
void()	hknight_slice4	=[	$slice4,	hknight_slice5	] {ai_charge_side(); setHead('-4 9 28');ai_charge(4);}; // 116
void()	hknight_slice5	=[	$slice5,	hknight_slice6	] {ai_charge_side(); setHead('5 9 27');ai_charge(7); ai_melee();}; // 117
void()	hknight_slice6	=[	$slice6,	hknight_slice7	] {ai_charge_side(); setHead('6 -5 32');ai_charge(15);hknight_sound(); ai_melee();}; // 118
void()	hknight_slice7	=[	$slice7,	hknight_slice8	] {ai_charge_side(); setHead('4 -11 27');ai_charge(8); ai_melee();}; // 119
void()	hknight_slice8	=[	$slice8,	hknight_slice9	] {ai_charge_side(); setHead('2 -18 22');ai_charge(2); ai_melee();}; // 120
void()	hknight_slice9	=[	$slice9,	hknight_slice10	] {ai_charge_side(); setHead('8 -6 30');ai_melee();}; // 121
void()	hknight_slice10	=[	$slice10,	hknight_run1	] {ai_charge_side(); setHead('8 -3 30');ai_charge(3);}; // 122

//===========================================================================

void() hknight_jumpsmash	=[	$smash1,	hknight_jumpsmash2	] 
{
	vector dir;
	setHead('3 6 29');
	ai_face_instant(); 
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	dir = SUB_GetPlayerDirection(self.origin, self.enemy);
	self.velocity = normalize (dir);
	self.velocity = self.velocity * 582; // 600, 15 degree, 0.97
	self.velocity_z = 156; // 0.26
	self.vA = self.velocity;
	hellknight_trail();
	self.pain_finished = time + 2;
};  // 123

void()  hknight_jumpsmash2	=[	$smash2,	hknight_jumpsmash3	] {hellknight_trail();setHead('-1 6 33'); self.velocity = self.vA;}; // 124
void()	hknight_jumpsmash3	=[	$smash3,	hknight_jumpsmash4	] {hellknight_trail();ai_charge_side(); setHead('-8 8 30');ai_charge(9);}; // 125
void()	hknight_jumpsmash4	=[	$smash4,	hknight_jumpsmash5	] {hellknight_trail();ai_charge_side(); setHead('-5 4 30');ai_charge(11);}; // 126
void()	hknight_jumpsmash5	=[	$smash5,	hknight_jumpsmash6	] {hellknight_trail();ai_charge_side(); setHead('5 3 30');ai_charge(10); ai_melee();hknight_sound();}; // 127
void()	hknight_jumpsmash6	=[	$smash6,	hknight_jumpsmash7	] {hellknight_trail();ai_charge_side(); setHead('10 -1 32');ai_charge(7); ai_melee();}; // 128
void()	hknight_jumpsmash7	=[	$smash7,	hknight_jumpsmash8	] {Think(0.05);hellknight_trail();ai_charge_side(); setHead('11 -2 31');ai_charge(12); ai_melee();}; // 129
void()	hknight_jumpsmash8	=[	$smash8,	hknight_jumpsmash9	] {Think(0.05);hellknight_trail();ai_charge_side(); setHead('17 -4 23');ai_charge(2); ai_melee();}; // 130
void()	hknight_jumpsmash9	=[	$smash9,	hknight_jumpsmash10	] {Think(0.05);hellknight_trail();ai_charge_side(); setHead('18 -5 14');ai_charge(3); ai_melee();}; // 131
void()	hknight_jumpsmash10	=[	$smash10,	hknight_jumpsmash11	] {ai_charge_side(); setHead('19 -5 13');ai_charge(0);}; // 132
void()	hknight_jumpsmash11	=[	$smash11,	hknight_run1	] {ai_charge_side(); setHead('12 0 23');ai_charge(0);}; // 133

void()	hknight_smash1	=[	$smash1,	hknight_smash2	] {ai_charge_side(); setHead('3 6 29');ai_charge(1);}; // 123
void()	hknight_smash2	=[	$smash2,	hknight_smash3	] {ai_charge_side(); setHead('-1 6 33');ai_charge(13);}; // 124
void()	hknight_smash3	=[	$smash3,	hknight_smash4	] {ai_charge_side(); setHead('-8 8 30');ai_charge(9);}; // 125
void()	hknight_smash4	=[	$smash4,	hknight_smash5	] {ai_charge_side(); setHead('-5 4 30');ai_charge(11);}; // 126
void()	hknight_smash5	=[	$smash5,	hknight_smash6	] {ai_charge_side(); setHead('5 3 30');ai_charge(10); ai_melee();}; // 127
void()	hknight_smash6	=[	$smash6,	hknight_smash7	] {ai_charge_side(); setHead('10 -1 32');ai_charge(7);hknight_sound(); ai_melee();}; // 128
void()	hknight_smash7	=[	$smash7,	hknight_smash8	] {Think(0.05);ai_charge_side(); setHead('11 -2 31');ai_charge(12); ai_melee();}; // 129
void()	hknight_smash8	=[	$smash8,	hknight_smash9	] {Think(0.05);ai_charge_side(); setHead('17 -4 23');ai_charge(2); ai_melee();}; // 130
void()	hknight_smash9	=[	$smash9,	hknight_smash10	] {Think(0.05);ai_charge_side(); setHead('18 -5 14');ai_charge(3); ai_melee();}; // 131
void()	hknight_smash10	=[	$smash10,	hknight_smash11	] {ai_charge_side(); setHead('19 -5 13');ai_charge(0);}; // 132
void()	hknight_smash11	=[	$smash11,	hknight_run1	] {ai_charge_side(); setHead('12 0 23');ai_charge(0);}; // 133

//============================================================================

void()	hknight_watk1	=[	$w_attack1,	hknight_watk2	] {ai_charge_side(); setHead('4 2 33');ai_charge(2);}; // 134
void()	hknight_watk2	=[	$w_attack2,	hknight_watk3	] {ai_charge_side(); setHead('-5 6 31');ai_charge(0);}; // 135
void()	hknight_watk3	=[	$w_attack3,	hknight_watk4	] {ai_charge_side(); setHead('-10 9 29');ai_charge(0);}; // 136
void()	hknight_watk4	=[	$w_attack4,	hknight_watk5	] {ai_charge_side(); setHead('-1 7 30');ai_melee();}; // 137
void()	hknight_watk5	=[	$w_attack5,	hknight_watk6	] {ai_charge_side(); setHead('9 4 31');ai_melee();}; // 138
void()	hknight_watk6	=[	$w_attack6,	hknight_watk7	] {ai_charge_side(); setHead('13 0 31');ai_melee();}; // 139
void()	hknight_watk7	=[	$w_attack7,	hknight_watk8	] {ai_charge_side(); setHead('19 -4 29');ai_charge(1);}; // 140
void()	hknight_watk8	=[	$w_attack8,	hknight_watk9	] {ai_charge_side(); setHead('23 -3 24');ai_charge(4);}; // 141
void()	hknight_watk9	=[	$w_attack9,	hknight_watk10	] {ai_charge_side(); setHead('24 -3 19');ai_charge(5);}; // 142
void()	hknight_watk10	=[	$w_attack10,hknight_watk11	] {ai_charge_side(); setHead('24 -5 20');ai_charge(3); ai_melee();}; // 143
void()	hknight_watk11	=[	$w_attack11,hknight_watk12	] {ai_charge_side(); setHead('20 -9 25');ai_charge(2);hknight_sound(); ai_melee();}; // 144
void()	hknight_watk12	=[	$w_attack12,hknight_watk13	] {ai_charge_side(); setHead('11 -11 27');ai_charge(2); ai_melee();}; // 145
void()	hknight_watk13	=[	$w_attack13,hknight_watk14	] {ai_charge_side(); setHead('3 -11 27');ai_charge(0);}; // 146
void()	hknight_watk14	=[	$w_attack14,hknight_watk15	] {ai_charge_side(); setHead('-2 -6 30');ai_charge(0);}; // 147
void()	hknight_watk15	=[	$w_attack15,hknight_watk16	] {ai_charge_side(); setHead('-4 -1 31');ai_charge(0);}; // 148
void()	hknight_watk16	=[	$w_attack16,hknight_watk17	] {ai_charge_side(); setHead('5 -2 31');ai_charge(1);}; // 149
void()	hknight_watk17	=[	$w_attack17,hknight_watk18	] {ai_charge_side(); setHead('12 -3 29');ai_charge(1); ai_melee();}; // 150
void()	hknight_watk18	=[	$w_attack18,hknight_watk19	] {ai_charge_side(); setHead('15 0 29');ai_charge(3);hknight_sound(); ai_melee();}; // 151
void()	hknight_watk19	=[	$w_attack19,hknight_watk20	] {ai_charge_side(); setHead('14 4 29');ai_charge(4); ai_melee();}; // 152
void()	hknight_watk20	=[	$w_attack20,hknight_watk21	] {ai_charge_side(); setHead('9 5 31');ai_charge(6);}; // 153
void()	hknight_watk21	=[	$w_attack21,hknight_watk22	] {ai_charge_side(); setHead('3 4 32');ai_charge(7);}; // 154
void()	hknight_watk22	=[	$w_attack22,hknight_run1	] {ai_charge_side(); setHead('3 3 33');ai_charge(3);}; // 155

//============================================================================

void() hk_idle_sound =
{
	if (random() < 0.05)
		sound (self, CHAN_VOICE, "hknight/idle.wav", 1, ATTN_NORM);
};

void(entity attacker, float damage)	hknight_pain =
{
	if (self.pain_finished > time)
		return;
	
	playPainSound("hknight/pain1.wav");

	if (time - self.pain_finished > 5)
	{	// always go into pain frame if it has been a while
		hknight_pain1 ();
		self.pain_finished = time + 1;

		return;
	}
	
	if ((random()*30 > damage) )
		return;		// didn't flinch

	self.pain_finished = time + 1;
	hknight_pain1 ();
};

float	hknight_type;

void() hknight_melee =
{
	hknight_type = hknight_type + 1;

	//hknight_sound();
	
	if (hknight_type == 1)
		hknight_slice1 ();

	else if (hknight_type == 2)
		hknight_smash1 ();

	else if (hknight_type == 3)
	{
		//hknight_watk1 ();
		hknight_smash1 ();
		hknight_type = 0;
	}
};

void() hknight_die =
{
	self.solid = SOLID_NOT;
	// check for gib
	if (self.health <= 0 && self.lasthit_damage > self.gib_threshold)
	{
		hellknight_trail();
		dropAmmo(self.origin, DROP_CELLS, 2, 1, 1, 1);
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_hellkn.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib1.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib2.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib3.mdl", self.lasthit_damage);
		return;
	}
	
	if (self.health_head <= 0)
	{
		dropAmmo(self.origin, DROP_BULLETS, 10, 5, 5, 5);
		dropAmmo(self.origin, DROP_NAILS, 40, 30, 20, 0);
		dropHealth(self.origin, DROP_ARMOR, 2, 2, 1, 1);

		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		setmodel (self, "progs/hknight_headless.mdl");
		setsize (self, '-16 -16 -24', '16 16 40');
		self.angles_y += crandom() * 15;
		sendMessageVec(findHeadPosition(self), TE_SYNTHHEAD_EXPLOSION); // particle effect
		if (self.monsterflags & MFL_DROP_HEAD)
		{
			self.monsterflags -= self.monsterflags & MFL_DROP_HEAD;
			ThrowHeadGib ("progs/h_hellkn.mdl", self.lasthit_direction * 200 + '0 0 100', 1);
		}
		else
		{
			for (float i = 0; i < 5; i++)
				ThrowHeadGib ("progs/smallgib_synth.mdl", self.lasthit_direction * (100 + random()*50) + [crandom() * 100, crandom() * 100, random() * 200], 0);
		}
	}
	else
		sound (self, CHAN_VOICE, "hknight/death1.wav", 1, ATTN_NORM);

	if (random() > 0.5)
		hknight_die1 ();

	else
		hknight_dieb1 ();
};

/*QUAKED monster_hell_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush*/
void() monster_hell_knight_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_hell_knight";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/hknight.mdl");
	setsize (self, '-16 -16 -24', '16 16 40');
	
	self.noise = "hknight/sight1.wav";	//gnounc
	self.netname = "Hell Knight";
	self.killstring = " was slashed to death by Heavy Cyborg\n";
	self.head_offset = '9 2 32';
	self.head_size = 12;
	self.health = HELLKNIGHT_HEALTH;
	self.max_health = HELLKNIGHT_HEALTH;
	self.health_head = HELLKNIGHT_HEAD;
	self.health_head_max = HELLKNIGHT_HEAD;
	self.gib_threshold = 100;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS | MFL_ROBOT | MFL_SYNTH;
	self.monstertype = TYPE_HELLKNIGHT;
	self.skinchange = 1;
	self.th_stand = hknight_stand1;
	self.th_walk = hknight_walk1;
	self.th_run = hknight_run1;
	self.th_melee = hknight_melee;
	self.th_missile = hknight_jumpsmash;//hknight_magicc1;
	self.th_pain = hknight_pain;
	self.th_die = hknight_die;
		
	walkmonster_start ();
};

void() monster_hell_knight_spawner = 
{
	mon_spawner_use(monster_hell_knight_spawn);
};

void() monster_hell_knight =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model2 ("progs/hknight.mdl");
	precache_model2 ("progs/hknight_trail.mdl");
	precache_model2 ("progs/hknight_headless.mdl"); 
	precache_model2 ("progs/h_hellkn.mdl");
	precache_sound2 ("hknight/attack1.wav");
	precache_sound2 ("hknight/death1.wav");
	precache_sound2 ("hknight/pain1.wav");
	precache_sound2 ("hknight/sight1.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("hknight/grunt.wav");
	precache_sound ("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	
	setsize (self, '-16 -16 -24', '16 16 40'); // set for telefrag check
	self.health = HELLKNIGHT_HEALTH;
	if ( monster_spawnsetup( monster_hell_knight_spawner ) )
		return;
	
	addmonster(1);
	monster_hell_knight_spawn();
};