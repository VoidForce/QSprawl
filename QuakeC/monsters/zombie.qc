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

ZOMBIE

==============================================================================
*/
$cd /raid/quake/id1/models/zombie

$origin	0 0 24

$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10 stand11 stand12 stand13 stand14 stand15

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11
$frame walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12
$frame run13 run14 run15 run16 run17 run18

$frame atta1 atta2 atta3 atta4 atta5 atta6 atta7 atta8 atta9 atta10 atta11
$frame atta12 atta13

$frame attb1 attb2 attb3 attb4 attb5 attb6 attb7 attb8 attb9 attb10 attb11
$frame attb12 attb13 attb14

$frame attc1 attc2 attc3 attc4 attc5 attc6 attc7 attc8 attc9 attc10 attc11
$frame attc12

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14 painb15 painb16 painb17 painb18 painb19
$frame painb20 painb21 painb22 painb23 painb24 painb25 painb26 painb27 painb28

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13 painc14 painc15 painc16 painc17 painc18

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8 paind9 paind10
$frame paind11 paind12 paind13

$frame paine1 paine2 paine3 paine4 paine5 paine6 paine7 paine8 paine9 paine10
$frame paine11 paine12 paine13 paine14 paine15 paine16 paine17 paine18 paine19
$frame paine20 paine21 paine22 paine23 paine24 paine25 paine26 paine27 paine28
$frame paine29 paine30

$frame cruc_1 cruc_2 cruc_3 cruc_4 cruc_5 cruc_6

float	SPAWN_CRUCIFIED	= 1;

//=============================================================================

.float inpain;

void() zombie_stand1	=[	$stand1,		zombie_stand2	] {setHead('-2 -1 23');ai_stand();}; //1 
void() zombie_stand2	=[	$stand2,		zombie_stand3	] {setHead('-1 -1 23');ai_stand();}; //2
void() zombie_stand3	=[	$stand3,		zombie_stand4	] {setHead('0 -1 22');ai_stand();}; //3
void() zombie_stand4	=[	$stand4,		zombie_stand5	] {setHead('1 -2 22');ai_stand();}; //4
void() zombie_stand5	=[	$stand5,		zombie_stand6	] {setHead('1 -2 22');ai_stand();}; //5
void() zombie_stand6	=[	$stand6,		zombie_stand7	] {setHead('1 -2 22');ai_stand();}; //6
void() zombie_stand7	=[	$stand7,		zombie_stand8	] {setHead('0 -2 22');ai_stand();}; //7
void() zombie_stand8	=[	$stand8,		zombie_stand9	] {setHead('0 -1 22');ai_stand();}; //8
void() zombie_stand9	=[	$stand9,		zombie_stand10	] {setHead('-1 -1 23');ai_stand();}; //9
void() zombie_stand10	=[	$stand10,		zombie_stand11	] {setHead('-1 -1 23');ai_stand();}; //10
void() zombie_stand11	=[	$stand11,		zombie_stand12	] {setHead('-3 -1 23');ai_stand();}; //11
void() zombie_stand12	=[	$stand12,		zombie_stand13	] {setHead('-4 -1 23');ai_stand();}; //12
void() zombie_stand13	=[	$stand13,		zombie_stand14	] {setHead('-4 -2 23');ai_stand();}; //13
void() zombie_stand14	=[	$stand14,		zombie_stand15	] {setHead('-4 -1 23');ai_stand();}; //14
void() zombie_stand15	=[	$stand15,		zombie_stand1	] {setHead('-3 -1 23');ai_stand();}; //15

void() zombie_cruc1	=	[	$cruc_1,		zombie_cruc2	] {
if (random() < 0.1)
	sound (self, CHAN_VOICE, "zombie/idle_w2.wav", 1, ATTN_STATIC);};
void() zombie_cruc2	=	[	$cruc_2,		zombie_cruc3	] {self.nextthink = time + 0.1 + random()*0.1;};
void() zombie_cruc3	=	[	$cruc_3,		zombie_cruc4	] {self.nextthink = time + 0.1 + random()*0.1;};
void() zombie_cruc4	=	[	$cruc_4,		zombie_cruc5	] {self.nextthink = time + 0.1 + random()*0.1;};
void() zombie_cruc5	=	[	$cruc_5,		zombie_cruc6	] {self.nextthink = time + 0.1 + random()*0.1;};
void() zombie_cruc6	=	[	$cruc_6,		zombie_cruc1	] {self.nextthink = time + 0.1 + random()*0.1;};

void() zombie_walk1		=[	$walk1,		zombie_walk2	] {setHead('14 -2 13');ai_walk(0);}; //16
void() zombie_walk2		=[	$walk2,		zombie_walk3	] {setHead('13 -2 14');ai_walk(2);}; //17
void() zombie_walk3		=[	$walk3,		zombie_walk4	] {setHead('13 -3 15');ai_walk(3);}; //18
void() zombie_walk4		=[	$walk4,		zombie_walk5	] {setHead('12 -3 16');ai_walk(2);}; //19
void() zombie_walk5		=[	$walk5,		zombie_walk6	] {setHead('11 -3 17');ai_walk(1);}; //20
void() zombie_walk6		=[	$walk6,		zombie_walk7	] {setHead('9 -4 19');ai_walk(0);}; //21
void() zombie_walk7		=[	$walk7,		zombie_walk8	] {setHead('6 -4 21');ai_walk(0);}; //22
void() zombie_walk8		=[	$walk8,		zombie_walk9	] {setHead('3 -4 22');ai_walk(0);}; //23
void() zombie_walk9		=[	$walk9,		zombie_walk10	] {setHead('2 -4 23');ai_walk(0);}; //24
void() zombie_walk10	=[	$walk10,	zombie_walk11	] {setHead('1 -4 23');ai_walk(0);}; //25
void() zombie_walk11	=[	$walk11,	zombie_walk12	] {setHead('5 -3 21');ai_walk(2);}; //26
void() zombie_walk12	=[	$walk12,	zombie_walk13	] {setHead('9 -2 18');ai_walk(2);}; //27
void() zombie_walk13	=[	$walk13,	zombie_walk14	] {setHead('11 -2 16');ai_walk(1);}; //28
void() zombie_walk14	=[	$walk14,	zombie_walk15	] {setHead('12 -2 15');ai_walk(0);}; //29
void() zombie_walk15	=[	$walk15,	zombie_walk16	] {setHead('13 -2 13');ai_walk(0);}; //30
void() zombie_walk16	=[	$walk16,	zombie_walk17	] {setHead('14 -2 12');ai_walk(0);}; //31
void() zombie_walk17	=[	$walk17,	zombie_walk18	] {setHead('14 -2 12');ai_walk(0);}; //32
void() zombie_walk18	=[	$walk18,	zombie_walk19	] {setHead('14 -2 12');ai_walk(0);}; //33
void() zombie_walk19	=[	$walk19,	zombie_walk1	] {setHead('14 -2 12');ai_walk(0);	 //34
if (random() < 0.2)
	sound (self, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);};
void() zombie_run1		=[	$run1,		zombie_run2	]	  {setHead('5 3 18');ai_run(1);self.inpain = 0;}; //35
void() zombie_run2		=[	$run2,		zombie_run3	]	  {setHead('6 4 17');ai_run(1);}; //36
void() zombie_run3		=[	$run3,		zombie_run4	]	  {setHead('6 5 17');ai_run(0);}; //37
void() zombie_run4		=[	$run4,		zombie_run5	]	  {setHead('6 4 18');ai_run(1);}; //38
void() zombie_run5		=[	$run5,		zombie_run6	]	  {setHead('3 3 20');ai_run(2);}; //39
void() zombie_run6		=[	$run6,		zombie_run7	]	  {setHead('0 1 21');ai_run(3);}; //40
void() zombie_run7		=[	$run7,		zombie_run8	]	  {setHead('-1 -1 21');ai_run(4);}; //41
void() zombie_run8		=[	$run8,		zombie_run9	]	  {setHead('0 -2 20');ai_run(4);}; //42
void() zombie_run9		=[	$run9,		zombie_run10	] {setHead('2 -4 18');ai_run(2);}; //43
void() zombie_run10		=[	$run10,		zombie_run11	] {setHead('6 -3 17');ai_run(0);}; //44
void() zombie_run11		=[	$run11,		zombie_run12	] {setHead('8 -1 16');ai_run(0);}; //45
void() zombie_run12		=[	$run12,		zombie_run13	] {setHead('9 -1 15');ai_run(0);}; //46
void() zombie_run13		=[	$run13,		zombie_run14	] {setHead('6 -1 17');ai_run(2);}; //47
void() zombie_run14		=[	$run14,		zombie_run15	] {setHead('-1 -1 20');ai_run(4);}; //48
void() zombie_run15		=[	$run15,		zombie_run16	] {setHead('-4 0 21');ai_run(6);}; //49
void() zombie_run16		=[	$run16,		zombie_run17	] {setHead('-1 1 21');ai_run(7);}; //50
void() zombie_run17		=[	$run17,		zombie_run18	] {setHead('3 2 19');ai_run(3);}; //51
void() zombie_run18		=[	$run18,		zombie_run1	] 	  {setHead('5 4 18');ai_run(8);	//52
if (random() < 0.2)
	sound (self, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "zombie/z_idle1.wav", 1, ATTN_IDLE);
};

/*
=============================================================================

ATTACKS

=============================================================================
*/

void() ZombieGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.takedamage)
	{
		T_Damage (other, self, self.owner, 10, 0);
		sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
		remove (self);
		return;
	}

	sound (self, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);	// bounce sound
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.touch = SUB_Remove;
};

/*
================
ZombieFireGrenade
================
*/
void(vector st, float lflag) ZombieFireHead =
{
	local	entity missile;
	local	vector	org;
	self.monsterflags -= self.monsterflags & MFL_HASHEAD;
	self.health_head = 0;
	self.skinchange = 0;
	self.skin = 0;
	setmodel (self, "progs/zombie_headless.mdl");
	setsize (self, '-16 -16 -24', '16 16 32');
	
	// gp into one of the fast pain animations	
	self.pain_finished = time + 3;
	self.inpain = 2;
	//self.solid = SOLID_NOT;
	zombie_paine1 ();

	missile = spawn ();
	missile.clip = CLIP_PROJECTILE;
	missile.classname = "zombie_head";	//gnounc
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

	// calc org
	org = self.origin + st_x * v_forward + st_y * v_right + (st_z - 24) * v_up;
	
	// set missile speed	
	if (lflag)
		missile.velocity = [crandom()* 100, crandom()* 100, 200 + random()* 100];
	else
	{
		makevectors2 (self.angles);
		missile.velocity = normalize(getPlayerPosition(self.enemy, 0) - org);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}
	
	missile.nextthink = time + 2.5;
	missile.sprawlflags |= SFLP_OGRE; // mark explosion type
	//missile.isgrenade = 1;
	appendToList(missile);
	missile.touch = OgreGrenadeExplode;
	missile.avelocity = '300 100 200';
	missile.think = SUB_Remove;
	setmodel (missile, "progs/h_zombie.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void(vector st) ZombieFireGrenade =
{
	entity missile;
	vector	org, pos;
	
	pos = getPlayerPosition(self.enemy, 0);

	sound (self, CHAN_WEAPON, "zombie/z_shot1.wav", 1, ATTN_NORM);
	if (self.monsterflags & MFL_HASHEAD && self.health < ZOMBIE_THROWHEADHP)
	{
		ZombieFireHead(st, 0);
		return;
	}
	missile = spawn ();
	missile.clip = CLIP_PROJECTILE;
	missile.classname = "zombie_grenade";	//gnounc
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

	// calc org
	org = self.origin + st_x * v_forward + st_y * v_right + (st_z - 24) * v_up;
	
	// set missile speed	

	makevectors2 (self.angles);
	if (self.monsterflags & MFL_HASHEAD)
		missile.velocity = normalize(pos - org);
	else
		missile.velocity = normalize([pos_x + crandom() * 64, pos_y + crandom() * 64, pos_z + crandom() * 64] - org);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '3000 1000 2000';

	missile.touch = ZombieGrenadeTouch;
	
	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};


void() zombie_atta1		=[	$atta1,		zombie_atta2	] {setHead('-1 -1 21');ai_face();}; //53
void() zombie_atta2		=[	$atta2,		zombie_atta3	] {setHead('4 2 19');ai_face();}; //54
void() zombie_atta3		=[	$atta3,		zombie_atta4	] {setHead('9 4 15');ai_face();}; //55
void() zombie_atta4		=[	$atta4,		zombie_atta5	] {setHead('12 5 11');ai_face();}; //56
void() zombie_atta5		=[	$atta5,		zombie_atta6	] {setHead('12 5 8');ai_face();}; //57
void() zombie_atta6		=[	$atta6,		zombie_atta7	] {setHead('11 5 11');ai_face();}; //58
void() zombie_atta7		=[	$atta7,		zombie_atta8	] {setHead('8 4 17');ai_face();}; //59
void() zombie_atta8		=[	$atta8,		zombie_atta9	] {setHead('6 4 19');ai_face();}; //60
void() zombie_atta9		=[	$atta9,		zombie_atta10	] {setHead('6 4 19');ai_face();}; //61
void() zombie_atta10	=[	$atta10,	zombie_atta11	] {setHead('3 2 19');ai_face();}; //62
void() zombie_atta11	=[	$atta11,	zombie_atta12	] {setHead('0 0 17');ai_face();}; //63
void() zombie_atta12	=[	$atta12,	zombie_atta13	] {setHead('7 0 14');ai_face();}; //64
void() zombie_atta13	=[	$atta13,	zombie_run1	] 	  {setHead('13 2 6');ai_face();ZombieFireGrenade('9 -8 31');}; //65

void() zombie_attb1		=[	$attb1,		zombie_attb2	] {setHead('-1 0 21');ai_face();}; //66
void() zombie_attb2		=[	$attb2,		zombie_attb3	] {setHead('-5 -2 20');ai_face();}; //67
void() zombie_attb3		=[	$attb3,		zombie_attb4	] {setHead('-6 -6 16');ai_face();}; //68
void() zombie_attb4		=[	$attb4,		zombie_attb5	] {setHead('-6 -7 12');ai_face();}; //69
void() zombie_attb5		=[	$attb5,		zombie_attb6	] {setHead('-6 -8 10');ai_face();}; //70
void() zombie_attb6		=[	$attb6,		zombie_attb7	] {setHead('-5 -6 11');ai_face();}; //71
void() zombie_attb7		=[	$attb7,		zombie_attb8	] {setHead('-3 -4 11');ai_face();}; //72
void() zombie_attb8		=[	$attb8,		zombie_attb9	] {setHead('-1 -2 12');ai_face();}; //73
void() zombie_attb9		=[	$attb9,		zombie_attb10	] {setHead('-1 2 13');ai_face();}; //74
void() zombie_attb10	=[	$attb10,	zombie_attb11	] {setHead('-1 4 13');ai_face();}; //75
void() zombie_attb11	=[	$attb11,	zombie_attb12	] {setHead('-2 5 14');ai_face();}; //76
void() zombie_attb12	=[	$attb12,	zombie_attb13	] {setHead('-2 5 14');ai_face();}; //77
void() zombie_attb13	=[	$attb13,	zombie_attb14	] {setHead('7 2 12');ai_face();}; //78
void() zombie_attb14	=[	$attb13,	zombie_run1	] 	  {setHead('13 1 7');ai_face();ZombieFireGrenade('3 6 31');}; //79

void() zombie_attc1		=[	$attc1,		zombie_attc2	] {setHead('-1 0 21');ai_face();}; //80
void() zombie_attc2		=[	$attc2,		zombie_attc3	] {setHead('-2 1 21');ai_face();}; //81
void() zombie_attc3		=[	$attc3,		zombie_attc4	] {setHead('-2 3 21');ai_face();}; //82
void() zombie_attc4		=[	$attc4,		zombie_attc5	] {setHead('-2 4 21');ai_face();}; //83
void() zombie_attc5		=[	$attc5,		zombie_attc6	] {setHead('0 3 20');ai_face();}; //84
void() zombie_attc6		=[	$attc6,		zombie_attc7	] {setHead('0 6 19');ai_face();}; //85
void() zombie_attc7		=[	$attc7,		zombie_attc8	] {setHead('0 9 18');ai_face();}; //86
void() zombie_attc8		=[	$attc8,		zombie_attc9	] {setHead('-1 9 20');ai_face();}; //87
void() zombie_attc9		=[	$attc9,		zombie_attc10	] {setHead('-1 -1 20');ai_face();}; //88
void() zombie_attc10	=[	$attc10,	zombie_attc11	] {setHead('-7 0 19');ai_face();}; //89
void() zombie_attc11	=[	$attc11,	zombie_attc12	] {setHead('10 3 11');ai_face();}; //90
void() zombie_attc12	=[	$attc12,	zombie_run1		] {setHead('14 3 2');ai_face();ZombieFireGrenade('-12 -15 29');}; //91

void() zombie_missile =
{
	local float	r;
	
	r = random();
	if (r < 0.3)
		zombie_atta1 ();
	else if (r < 0.6)
		zombie_attb1 ();
	else
		zombie_attc1 ();
};

/*
=============================================================================

PAIN

=============================================================================
*/

void() zombie_paina1	=[	$paina1,	zombie_paina2	] {setHead('0 0 24');sound (self, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);}; //92
void() zombie_paina2	=[	$paina2,	zombie_paina3	] {setHead('-14 0 5');ai_painforward(3);}; //93
void() zombie_paina3	=[	$paina3,	zombie_paina4	] {setHead('-15 1 4');ai_painforward(1);}; //94
void() zombie_paina4	=[	$paina4,	zombie_paina5	] {setHead('-17 2 9');ai_pain(1);}; //95
void() zombie_paina5	=[	$paina5,	zombie_paina6	] {setHead('-17 2 13');ai_pain(3);}; //96
void() zombie_paina6	=[	$paina6,	zombie_paina7	] {setHead('-16 1 16');ai_pain(1);}; //97
void() zombie_paina7	=[	$paina7,	zombie_paina8	] {setHead('-13 -1 18');}; //98
void() zombie_paina8	=[	$paina8,	zombie_paina9	] {setHead('-11 -3 21');}; //99
void() zombie_paina9	=[	$paina9,	zombie_paina10	] {setHead('-2 -1 24');}; //100
void() zombie_paina10	=[	$paina10,	zombie_paina11	] {setHead('5 2 23');}; //101
void() zombie_paina11	=[	$paina11,	zombie_paina12	] {setHead('4 1 23');}; //102
void() zombie_paina12	=[	$paina12,	zombie_run1		] {setHead('3 1 23');}; //103

void() zombie_painb1	=[	$painb1,	zombie_painb2	] {setHead('0 0 24');sound (self, CHAN_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM);}; //104
void() zombie_painb2	=[	$painb2,	zombie_painb3	] {setHead('-18 0 15');ai_pain(2);}; //105
void() zombie_painb3	=[	$painb3,	zombie_painb4	] {setHead('-21 0 10');ai_pain(8);}; //106
void() zombie_painb4	=[	$painb4,	zombie_painb5	] {setHead('-20 0 6');ai_pain(6);}; //107
void() zombie_painb5	=[	$painb5,	zombie_painb6	] {setHead('-21 0 -6');ai_pain(2);}; //108
void() zombie_painb6	=[	$painb6,	zombie_painb7	] {setHead('-20 0 -14');}; //109
void() zombie_painb7	=[	$painb7,	zombie_painb8	] {setHead('-21 0 -17');}; //110
void() zombie_painb8	=[	$painb8,	zombie_painb9	] {setHead('-21 0 -19');}; //111
void() zombie_painb9	=[	$painb9,	zombie_painb10	] {setHead('-22 0 -20');sound (self, CHAN_BODY, "zombie/z_fall.wav", 1, ATTN_NORM);}; //112
void() zombie_painb10	=[	$painb10,	zombie_painb11	] {setHead('-22 0 -20');}; //113
void() zombie_painb11	=[	$painb11,	zombie_painb12	] {setHead('-22 -1 -19');}; //114
void() zombie_painb12	=[	$painb12,	zombie_painb13	] {setHead('-22 -1 -19');}; //115
void() zombie_painb13	=[	$painb13,	zombie_painb14	] {setHead('-23 -2 -18');}; //116
void() zombie_painb14	=[	$painb14,	zombie_painb15	] {setHead('-22 -1 -13');}; //117
void() zombie_painb15	=[	$painb15,	zombie_painb16	] {setHead('-17 -1 -7');}; //118
void() zombie_painb16	=[	$painb16,	zombie_painb17	] {setHead('-12 -2 -6');}; //119
void() zombie_painb17	=[	$painb17,	zombie_painb18	] {setHead('-10 -4 -4');}; //120
void() zombie_painb18	=[	$painb18,	zombie_painb19	] {setHead('-3 -6 -2');}; //121
void() zombie_painb19	=[	$painb19,	zombie_painb20	] {setHead('2 -7 -2');}; //122
void() zombie_painb20	=[	$painb20,	zombie_painb21	] {setHead('6 -6 -1');}; //123
void() zombie_painb21	=[	$painb21,	zombie_painb22	] {setHead('8 -3 0');}; //124
void() zombie_painb22	=[	$painb22,	zombie_painb23	] {setHead('9 0 -1');}; //125
void() zombie_painb23	=[	$painb23,	zombie_painb24	] {setHead('6 0 9');}; //126
void() zombie_painb24	=[	$painb24,	zombie_painb25	] {setHead('-3 0 18');}; //127
void() zombie_painb25	=[	$painb25,	zombie_painb26	] {setHead('-8 0 20');ai_painforward(1);}; //128
void() zombie_painb26	=[	$painb26,	zombie_painb27	] {setHead('-6 0 22');}; //129
void() zombie_painb27	=[	$painb27,	zombie_painb28	] {setHead('-3 0 24');}; //130
void() zombie_painb28	=[	$painb28,	zombie_run1		] {setHead('0 0 24');}; //131

void() zombie_painc1	=[	$painc1,	zombie_painc2	] {setHead('0 0 24');sound (self, CHAN_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM);}; //132
void() zombie_painc2	=[	$painc2,	zombie_painc3	] {setHead('-11 -6 14');}; // 133
void() zombie_painc3	=[	$painc3,	zombie_painc4	] {setHead('-14 -7 -2');ai_pain(3);}; //134
void() zombie_painc4	=[	$painc4,	zombie_painc5	] {setHead('-12 -5 -9');ai_pain(1);}; //135
void() zombie_painc5	=[	$painc5,	zombie_painc6	] {setHead('-12 -4 -11');}; //136
void() zombie_painc6	=[	$painc6,	zombie_painc7	] {setHead('-12 -2 -10');}; //137
void() zombie_painc7	=[	$painc7,	zombie_painc8	] {setHead('-12 -2 -10');}; //138
void() zombie_painc8	=[	$painc8,	zombie_painc9	] {setHead('-12 -2 -10');}; //139
void() zombie_painc9	=[	$painc9,	zombie_painc10	] {setHead('-12 -4 -11');}; //140
void() zombie_painc10	=[	$painc10,	zombie_painc11	] {setHead('-12 -5 -9');}; //141
void() zombie_painc11	=[	$painc11,	zombie_painc12	] {setHead('-14 -6 0');ai_painforward(1);}; //142
void() zombie_painc12	=[	$painc12,	zombie_painc13	] {setHead('-14 -2 9');ai_painforward(1);}; //143
void() zombie_painc13	=[	$painc13,	zombie_painc14	] {setHead('-12 -2 14');}; //144
void() zombie_painc14	=[	$painc14,	zombie_painc15	] {setHead('-11 -2 18');}; //145
void() zombie_painc15	=[	$painc15,	zombie_painc16	] {setHead('-10 -2 21');}; //146
void() zombie_painc16	=[	$painc16,	zombie_painc17	] {setHead('-8 -2 23');}; //147
void() zombie_painc17	=[	$painc17,	zombie_painc18	] {setHead('-4 -2 25');}; //148
void() zombie_painc18	=[	$painc18,	zombie_run1	] 	  {setHead('1 -1 24');}; //149

void() zombie_paind1	=[	$paind1,	zombie_paind2	] {setHead('0 0 24');sound (self, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);}; //150
void() zombie_paind2	=[	$paind2,	zombie_paind3	] {setHead('-6 1 23');}; //151
void() zombie_paind3	=[	$paind3,	zombie_paind4	] {setHead('-8 0 21');}; //152
void() zombie_paind4	=[	$paind4,	zombie_paind5	] {setHead('-9 1 20');}; //153
void() zombie_paind5	=[	$paind5,	zombie_paind6	] {setHead('-9 1 20');}; //154
void() zombie_paind6	=[	$paind6,	zombie_paind7	] {setHead('-9 1 20');}; //155
void() zombie_paind7	=[	$paind7,	zombie_paind8	] {setHead('-8 1 22');}; //156
void() zombie_paind8	=[	$paind8,	zombie_paind9	] {setHead('-7 1 23');}; //157
void() zombie_paind9	=[	$paind9,	zombie_paind10	] {setHead('0 1 24');ai_pain(1);}; //158
void() zombie_paind10	=[	$paind10,	zombie_paind11	] {setHead('6 0 22');}; //159
void() zombie_paind11	=[	$paind11,	zombie_paind12	] {setHead('6 0 23');}; //160
void() zombie_paind12	=[	$paind12,	zombie_paind13	] {setHead('4 0 24');}; //161
void() zombie_paind13	=[	$paind13,	zombie_run1	] 	  {setHead('3 0 24');}; //162

void() zombie_paine1	=[	$paine1,	zombie_paine2	] {setHead('0 0 24');   //163
sound (self, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);};
void() zombie_paine2	=[	$paine2,	zombie_paine3	] {setHead('6 0 26');ai_pain(8);}; //164
void() zombie_paine3	=[	$paine3,	zombie_paine4	] {setHead('5 0 26');ai_pain(5);}; //165
void() zombie_paine4	=[	$paine4,	zombie_paine5	] {setHead('1 0 23');self.nextthink = time + 0.05; ai_pain(3);}; //166
void() zombie_paine5	=[	$paine5,	zombie_paine6	] {setHead('-1 0 17');self.nextthink = time + 0.05;ai_pain(1);}; //167
void() zombie_paine6	=[	$paine6,	zombie_paine7	] {setHead('-4 0 10');self.nextthink = time + 0.05;ai_pain(2);}; //168
void() zombie_paine7	=[	$paine7,	zombie_paine8	] {setHead('-8 0 1');self.nextthink = time + 0.05;ai_pain(1);}; //169
void() zombie_paine8	=[	$paine8,	zombie_paine9	] {setHead('-12 0 -6');self.nextthink = time + 0.05;ai_pain(1);}; //170
void() zombie_paine9	=[	$paine9,	zombie_paine10	] {setHead('-15 0 -11');self.nextthink = time + 0.05;ai_pain(2);}; //171
void() zombie_paine10	=[	$paine10,	zombie_paine11	] {setHead('-16 1 -17');				 //172
sound (self, CHAN_BODY, "zombie/z_fall.wav", 1, ATTN_NORM);};
void() zombie_paine11	=[	$paine11,	zombie_paine12	] {setHead('-16 1 -21'); self.nextthink = self.nextthink + 0.1;}; //173
void() zombie_paine12	=[	$paine12,	zombie_paine13	] {setHead('-16 1 -22');}; //174
void() zombie_paine13	=[	$paine13,	zombie_paine14	] {setHead('-16 1 -22');self.solid = SOLID_SLIDEBOX;}; //175
void() zombie_paine14	=[	$paine14,	zombie_paine15	] {setHead('-16 1 -22');}; //176
void() zombie_paine15	=[	$paine15,	zombie_paine16	] {setHead('-16 1 -22');}; //177
void() zombie_paine16	=[	$paine16,	zombie_paine17	] {setHead('-16 1 -22');}; //178
void() zombie_paine17	=[	$paine17,	zombie_paine18	] {setHead('-16 1 -22');}; //179
void() zombie_paine18	=[	$paine18,	zombie_paine19	] {setHead('-15 1 -17');}; //180
void() zombie_paine19	=[	$paine19,	zombie_paine20	] {setHead('-10 1 -11');}; //181
void() zombie_paine20	=[	$paine20,	zombie_paine21	] {setHead('-5 1 -8');}; //182
void() zombie_paine21	=[	$paine21,	zombie_paine22	] {setHead('-4 1 -8');}; //183
void() zombie_paine22	=[	$paine22,	zombie_paine23	] {setHead('-3 1 -8');}; //184
void() zombie_paine23	=[	$paine23,	zombie_paine24	] {setHead('-3 1 -7');}; //185
void() zombie_paine24	=[	$paine24,	zombie_paine25	] {setHead('2 1 -4');}; //186
void() zombie_paine25	=[	$paine25,	zombie_paine26	] {setHead('8 0 -5');ai_painforward(5);}; //187
void() zombie_paine26	=[	$paine26,	zombie_paine27	] {setHead('9 0 -8');ai_painforward(3);}; //188
void() zombie_paine27	=[	$paine27,	zombie_paine28	] {setHead('9 0 -1');ai_painforward(1);}; //189
void() zombie_paine28	=[	$paine28,	zombie_paine29	] {setHead('7 0 12');ai_pain(1);}; //190
void() zombie_paine29	=[	$paine29,	zombie_paine30	] {setHead('3 0 21');}; //191
void() zombie_paine30	=[	$paine30,	zombie_run1		] {setHead('0 0 24');}; //192

void() zombie_die =
{
	//sound (self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	sendMessageVec(self.origin, TE_EXPLOSION);
	
	if (self.monsterflags & MFL_HASHEAD)
	{
		ThrowHead ("progs/h_zombie.mdl", self.lasthit_damage);
		dropAmmo(self.origin, DROP_CELLS, 1, 1, 1, 0);
	}
	else
	{
		ThrowHead ("progs/m_gib_02.mdl", self.lasthit_damage);
		dropAmmo(self.origin, DROP_SHELLS, 6, 4, 2, 2);
	}
	dropHealth(self.origin, DROP_ARMOR_ONE, 8, 4, 2, 2);
	ThrowGib ("progs/m_gib_03.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_04.mdl", self.lasthit_damage);
	ThrowGib ("progs/m_gib_05.mdl", self.lasthit_damage);
};

/*
=================
zombie_pain

Zombies can only be killed (gibbed) by doing 60 hit points of damage
in a single frame (rockets, grenades, quad shotgun, quad nailgun).

A hit of 25 points or more (super shotgun, quad nailgun) will allways put it
down to the ground.

A hit of from 10 to 40 points in one frame will cause it to go down if it
has been twice in two seconds, otherwise it goes into one of the four
fast pain frames.

A hit of less than 10 points of damage (winged by a shotgun) will be ignored.

FIXME: don't use pain_finished because of nightmare hack
=================
*/
void(entity attacker, float take) zombie_pain =
{
	float r;
	if (self.lasthit_damage > 150)
	{
		self.health = 0;
		self.pain_finished = 72000;
		zombie_die();
		return;
	}
	
	if (self.monsterflags & MFL_LOST_HEAD)
	{
		self.monsterflags -= self.monsterflags & MFL_LOST_HEAD;
		setmodel (self, "progs/zombie_headless.mdl");
		setsize (self, '-16 -16 -24', '16 16 32');
		
		if (self.health > ZOMBIE_HEADLESS)
			self.health = ZOMBIE_HEADLESS;

		// gp into one of the fast pain animations	
		self.pain_finished = time + 3;
		self.inpain = 2;
		zombie_paine1 ();
		// head was sliced with katana, throw it away
		if (self.monsterflags & MFL_DROP_HEAD)
			ZombieFireHead(self.head_offset,1);
		else
		{
		// head was destroyed, blow up
			T_RadiusDamage (self, self, 40, self);
			sendMessageVec(findHeadPosition(self), TE_ROBOTHEAD_EXPLOSION); // particle effect
		}
		return;
	}
	
	if (self.inpain == 2)
		return;			// down on ground, so don't reset any counters

	// gp into one of the fast pain animations	
	if (self.pain_finished > time)
		return;
	self.inpain = 1;
	self.pain_finished = time + 3;

	r = random();
	if (r < 0.25)
		zombie_paina1 ();
	else if (r <  0.5)
		zombie_painb1 ();
	else if (r <  0.75)
		zombie_painc1 ();
	else
		zombie_paind1 ();
};

//============================================================================

/*QUAKED monster_zombie (1 0 0) (-16 -16 -24) (16 16 32) Crucified ambush

If crucified, stick the bounding box 12 pixels back into a wall to look right.
*/
void() monster_zombie_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_zombie";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/zombie.mdl");
	setsize (self, '-16 -16 -24', '16 16 28');
	
	self.noise = "zombie/z_idle.wav";	//gnounc
	self.netname = "zombie";
	self.killstring = " joins the Zombies\n";
	self.head_offset = '-2 -1 23';
	self.head_size = 8;
	self.health = ZOMBIE_HEALTH;
	self.max_health = ZOMBIE_HEALTH;
	self.health_head = ZOMBIE_HEAD;
	self.health_head_max = ZOMBIE_HEAD;
	self.skinchange = 1;
	self.monsterflags |= MFL_HASHEAD | MFL_ROBOT;
	self.monstertype = TYPE_ZOMBIE;
	self.th_stand = zombie_stand1;
	self.th_walk = zombie_walk1;
	self.th_run = zombie_run1;
	self.th_pain = zombie_pain;
	self.th_die = zombie_die;
	self.th_missile = zombie_missile;

	if (self.spawnflags & SPAWN_CRUCIFIED)
	{
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
		zombie_cruc1 ();
	}
	else
		walkmonster_start();
};

void() monster_zombie_spawner = 
{
	mon_spawner_use(monster_zombie_spawn);
};

void() monster_zombie =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/zombie.mdl");
	precache_model ("progs/zombie_headless.mdl");
	precache_model ("progs/h_zombie.mdl");
	precache_model ("progs/zom_gib.mdl");
	precache_sound ("zombie/z_idle.wav");
	precache_sound ("zombie/z_idle1.wav");
	precache_sound ("zombie/z_shot1.wav");
	precache_sound ("zombie/z_gib.wav");
	precache_sound ("zombie/z_pain.wav");
	precache_sound ("zombie/z_pain1.wav");
	precache_sound ("zombie/z_fall.wav");
	precache_sound ("zombie/z_miss.wav");
	precache_sound ("zombie/z_hit.wav");
	precache_sound ("zombie/idle_w2.wav");
	
	setsize (self, '-16 -16 -24', '16 16 28');
	self.health = ZOMBIE_HEALTH;
	if ( !(self.spawnflags & SPAWN_CRUCIFIED) )
	{
		if ( monster_spawnsetup( monster_zombie_spawner ) ) 
			return;
		
		addmonster(1);
	}
	monster_zombie_spawn();
};