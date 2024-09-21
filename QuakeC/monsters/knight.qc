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

$cd /raid/quake/id1/models/knight
$origin 0 0 24
$base base
$skin badass3

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8

$frame runattack1 runattack2 runattack3 runattack4 runattack5
$frame runattack6 runattack7 runattack8 runattack9 runattack10
$frame runattack11

$frame pain1 pain2 pain3

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9
$frame painb10 painb11

$frame attackb1 attackb2 attackb3 attackb4 attackb5 attackb6
$frame attackb7 attackb8 attackb9 attackb10 attackb11

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14

$frame kneel1 kneel2 kneel3 kneel4 kneel5

$frame standing2 standing3 standing4 standing5

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11

void() knight_trail =
{
	entity trail;
	trail = spawn();
	
	trail.solid = SOLID_NOT;
	trail.movetype = MOVETYPE_NONE;
	if (skill > 1)
		setmodel (trail, "progs/knight.mdl");// less noticable
	else
		setmodel (trail, "progs/knight_trail.mdl");//
	setsize (trail, '-16 -16 -24', '16 16 32'); //28
	setorigin(trail, self.origin);
	trail.angles = self.angles;
	trail.alpha = 0.01;
	trail.cnt = 1;
	trail.frame = self.frame;
	trail.think = knight_trail_fade;
	trail.nextthink = time + 0.1;
};

void() knight_trail_fade =
{
	if (self.cnt)
	{
		self.alpha = 0.5;
		self.cnt = 0;
	}
	else
	{
		self.alpha -= 0.2;
		if (self.alpha < 0.2)
		{
			self.alpha = 0.01;
			self.think = SUB_Remove;
			self.nextthink = time + 0.1;
			return;
		}
	}
	self.think = knight_trail_fade;
	self.nextthink = time + 0.1;
};

void() knight_attack =
{
	local float	len;
	
	if (self.fA > time)
		knight_runatk1 ();
	else
	{
		//decide if now is a good swing time
		len = vlen(getPlayerPosition(self.enemy, 0) + self.enemy.view_ofs - (self.origin + self.view_ofs));
		
		if (len<40)
			knight_atk1 ();
		else
			knight_runatk1 ();
	}
};

void()	knight_stand1	=[	$stand1,	knight_stand2	] {setHead('2 0 22');ai_stand();}; // 1
void()	knight_stand2	=[	$stand2,	knight_stand3	] {setHead('2 0 22');ai_stand();}; // 2
void()	knight_stand3	=[	$stand3,	knight_stand4	] {setHead('2 0 22');ai_stand();}; // 3
void()	knight_stand4	=[	$stand4,	knight_stand5	] {setHead('2 0 22');ai_stand();}; // 4
void()	knight_stand5	=[	$stand5,	knight_stand6	] {setHead('2 0 22');ai_stand();}; // 5
void()	knight_stand6	=[	$stand6,	knight_stand7	] {setHead('2 0 22');ai_stand();}; // 6
void()	knight_stand7	=[	$stand7,	knight_stand8	] {setHead('2 0 22');ai_stand();}; // 7
void()	knight_stand8	=[	$stand8,	knight_stand9	] {setHead('2 0 22');ai_stand();}; // 8
void()	knight_stand9	=[	$stand9,	knight_stand1	] {setHead('2 0 22');ai_stand();}; // 9

void()	knight_walk1	=[	$walk1,		knight_walk2	] {setHead('3 0 23'); // 54
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	ai_walk(3);
};
void()	knight_walk2	=[	$walk2,		knight_walk3	] {setHead('3 0 23');ai_walk(2);}; // 55
void()	knight_walk3	=[	$walk3,		knight_walk4	] {setHead('3 0 22');ai_walk(3);}; // 56
void()	knight_walk4	=[	$walk4,		knight_walk5	] {setHead('2 0 24');ai_walk(4);}; // 57
void()	knight_walk5	=[	$walk5,		knight_walk6	] {setHead('2 0 24');ai_walk(3);}; // 58
void()	knight_walk6	=[	$walk6,		knight_walk7	] {setHead('2 0 25');ai_walk(3);}; // 59
void()	knight_walk7	=[	$walk7,		knight_walk8	] {setHead('2 0 25');ai_walk(3);}; // 60
void()	knight_walk8	=[	$walk8,		knight_walk9	] {setHead('3 0 25');ai_walk(4);}; // 61
void()	knight_walk9	=[	$walk9,		knight_walk10	] {setHead('4 0 24');ai_walk(3);}; // 62
void()	knight_walk10	=[	$walk10,	knight_walk11	] {setHead('5 0 22');ai_walk(3);}; // 63
void()	knight_walk11	=[	$walk11,	knight_walk12	] {setHead('4 0 24');ai_walk(2);}; // 64
void()	knight_walk12	=[	$walk12,	knight_walk13	] {setHead('4 0 25');ai_walk(3);}; // 65
void()	knight_walk13	=[	$walk13,	knight_walk14	] {setHead('3 0 25');ai_walk(4);}; // 66
void()	knight_walk14	=[	$walk14,	knight_walk1	] {setHead('2 0 25');ai_walk(3);}; // 67

void()	knight_run1	=[	$runb1,		knight_run2	] {Think(0.04);self.alpha = 0.4; setHead('10 -2 23'); // 10
	if (random() < 0.05)
		sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	ai_run(16);
};
void()	knight_run2	=[	$runb2,		knight_run3	] {Think(0.04);setHead('8 -2 23');ai_run(20);};  // 11
void()	knight_run3	=[	$runb3,		knight_run4	] {Think(0.04);setHead('6 -2 24');ai_run(13);};  // 12
void()	knight_run4	=[	$runb4,		knight_run5	] {Think(0.04);setHead('8 1 22');ai_run(7);};   // 13
void()	knight_run5	=[	$runb5,		knight_run6	] {Think(0.04);setHead('9 2 23');ai_run(16);};  // 14
void()	knight_run6	=[	$runb6,		knight_run7	] {Think(0.04);setHead('7 2 23');ai_run(20);};  // 15
void()	knight_run7	=[	$runb7,		knight_run8	] {Think(0.04);setHead('7 0 24');ai_run(14);};  // 16
void()	knight_run8	=[	$runb8,		knight_run1	] {Think(0.04);setHead('8 1 22');ai_run(6);};   // 17

void()	knight_runatk1	=[	$runattack1, knight_runatk2	] {Think(0.04);setHead('2 1 25');  // 18
	if (random() > 0.5)
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
	
	makevectors2 (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 500 + '0 0 150';

	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	
	ai_charge(20);
};

void()	knight_runatk2	=[	$runattack2,	knight_runatk3	] {Think(0.04);setHead('-2 9 23');ai_charge_side();};  // 19
void()	knight_runatk3	=[	$runattack3,	knight_runatk4	] {Think(0.04);setHead('-2 8 21');ai_charge_side();};  // 20
void()	knight_runatk4	=[	$runattack4,	knight_runatk5	] {Think(0.04);setHead('1 7 24');ai_charge_side();};  // 21
void()	knight_runatk5	=[	$runattack5,	knight_runatk6	] {Think(0.04);setHead('5 10 23');ai_melee_side(1);knight_trail();self.alpha = 1;};   // 22
void()	knight_runatk6	=[	$runattack6,	knight_runatk7	] {Think(0.04);setHead('9 -7 20');knight_trail();};   // 23
void()	knight_runatk7	=[	$runattack7,	knight_runatk8	] {Think(0.04);setHead('8 -13 18');ai_melee_side(1);knight_trail();};   // 24
void()	knight_runatk8	=[	$runattack8,	knight_runatk9	] {Think(0.04);setHead('5 -10 23');knight_trail();};   // 25
void()	knight_runatk9	=[	$runattack9,	knight_runatk10	] {Think(0.04);setHead('2 -7 25');ai_melee_side(1);knight_trail();};   // 26
void()	knight_runatk10	=[	$runattack10,	knight_runatk11	] {Think(0.04);setHead('2 -3 24');ai_charge_side();};  // 27
void()	knight_runatk11	=[	$runattack11,	knight_run1	]	  {Think(0.04);setHead('2 0 23');ai_charge(10);self.alpha = 0.4;};     // 28

void()	knight_atk1	=[	$attackb1,		knight_atk2	] {
	if (self.fA > time)
		
	Think(0.04);setHead('1 1 24');
	self.alpha = 1;							// 43
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(0);
	self.fA = time + 1;
};
void()	knight_atk2	=[	$attackb2,		knight_atk3	] {Think(0.04);setHead('1 1 24');ai_charge(7);};              // 44
void()	knight_atk3	=[	$attackb3,		knight_atk4	] {Think(0.04);setHead('-4 2 24');ai_charge(4);};              // 45
void()	knight_atk4	=[	$attackb4,		knight_atk5	] {Think(0.04);setHead('-2 2 23');ai_charge(0);};              // 46
void()	knight_atk5	=[	$attackb5,		knight_atk6	] {Think(0.04);setHead('-6 1 21');ai_charge(3);};              // 47
void()	knight_atk6	=[	$attackb6,		knight_atk7	] {Think(0.04);setHead('5 0 22');ai_charge(4); ai_melee(1);knight_trail();};  // 48
void()	knight_atk7	=[	$attackb7,		knight_atk8	] {Think(0.04);setHead('13 -3 19');ai_charge(1); knight_trail();};  // 49
void()	knight_atk8	=[	$attackb8,		knight_atk9	] {Think(0.04);setHead('12 -4 18');ai_charge(3); ai_melee(1);knight_trail();};  // 50
void()	knight_atk9	=[	$attackb9,		knight_atk10] {Think(0.04);setHead('19 -3 7');ai_charge(1);};              // 51
void()	knight_atk10=[	$attackb10,		knight_run1	] {Think(0.04);setHead('17 -5 11');ai_charge(5);self.alpha = 0.4;};              // 52

//===========================================================================

void()	knight_pain1	=[	$pain1,		knight_pain2	] {setHead('-4 1 26'); self.alpha = 0.01;};					 // 29
void()	knight_pain2	=[	$pain2,		knight_pain3	] {setHead('-7 2 25');};					 // 30
void()	knight_pain3	=[	$pain3,		knight_run1	] 	  {setHead('-13 1 20');self.alpha = 0.4;};					 // 31

void()	knight_painb1	=[	$painb1,	knight_painb2	] {setHead('-3 -3 24');ai_painforward(0);self.alpha = 0.01;};  // 32
void()	knight_painb2	=[	$painb2,	knight_painb3	] {setHead('-4 -2 23');ai_painforward(3);};  // 33
void()	knight_painb3	=[	$painb3,	knight_painb4	] {setHead('2 -5 19');};                    // 34
void()	knight_painb4	=[	$painb4,	knight_painb5	] {setHead('10 -5 16');};                    // 35
void()	knight_painb5	=[	$painb5,	knight_painb6	] {setHead('12 -5 16');ai_painforward(2);};  // 36
void()	knight_painb6	=[	$painb6,	knight_painb7	] {setHead('14 -5 16');ai_painforward(4);};  // 37
void()	knight_painb7	=[	$painb7,	knight_painb8	] {setHead('15 -4 12');ai_painforward(2);};  // 38
void()	knight_painb8	=[	$painb8,	knight_painb9	] {setHead('15 -3 11');ai_painforward(5);};  // 39
void()	knight_painb9	=[	$painb9,	knight_painb10	] {setHead('17 0 9');ai_painforward(5);};  // 40
void()	knight_painb10	=[	$painb10,	knight_painb11	] {setHead('16 4 15');ai_painforward(0);};  // 41
void()	knight_painb11	=[	$painb11,	knight_run1	] 	  {setHead('11 4 20');self.alpha = 0.4;};                    // 42

void(entity attacker, float damage)	knight_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;
	
	playPainSound("knight/khurt.wav");
	
	r = random();
	if (r < 0.85)
	{
		knight_pain1 ();
		self.pain_finished = time + 1;
	}

	else
	{
		knight_painb1 ();
		self.pain_finished = time + 1;
	}
	
};

//===========================================================================

void()	knight_bow1	=[	$kneel1,		knight_bow2	] {setHead('3 1 25');ai_turn();}; // 68
void()	knight_bow2	=[	$kneel2,		knight_bow3	] {setHead('7 0 25');ai_turn();}; // 69
void()	knight_bow3	=[	$kneel3,		knight_bow4	] {setHead('6 1 23');ai_turn();}; // 70
void()	knight_bow4	=[	$kneel4,		knight_bow5	] {setHead('9 1 23');ai_turn();}; // 71
void()	knight_bow5	=[	$kneel5,		knight_bow5	] {setHead('16 1 16');ai_turn();}; // 72
void()	knight_bow6	=[	$kneel4,		knight_bow7	] {setHead('9 1 23');ai_turn();}; // 71
void()	knight_bow7	=[	$kneel3,		knight_bow8	] {setHead('6 1 23');ai_turn();}; // 70
void()	knight_bow8	=[	$kneel2,		knight_bow9	] {setHead('7 0 25');ai_turn();}; // 69
void()	knight_bow9	=[	$kneel1,		knight_bow10] {setHead('3 1 25');ai_turn();}; // 68
void()	knight_bow10	=[	$walk1,		knight_walk1] {setHead('3 0 23');ai_turn();}; // 54

void()	knight_die1	=[	$death1,	knight_die2	] {ai_velocity(50);};
void()	knight_die2	=[	$death2,	knight_die3	] {ai_velocity(40);};
void()	knight_die3	=[	$death3,	knight_die4	] {ai_velocity(30);};
void()	knight_die4	=[	$death4,	knight_die5	] {ai_velocity(20);};
void()	knight_die5	=[	$death5,	knight_die6	] {ai_velocity(20);};
void()	knight_die6	=[	$death6,	knight_die7	] {};
void()	knight_die7	=[	$death7,	knight_die8	] {};
void()	knight_die8	=[	$death8,	knight_die9	] {};
void()	knight_die9	=[	$death9,	knight_die10] {};
void()	knight_die10=[	$death10,	decay] {};

void()	knight_dieb1  =[ $deathb1,	knight_dieb2 ] {ai_velocity(50);};
void()	knight_dieb2  =[ $deathb2,	knight_dieb3 ] {ai_velocity(40);};
void()	knight_dieb3  =[ $deathb3,	knight_dieb4 ] {ai_velocity(30);};
void()	knight_dieb4  =[ $deathb4,	knight_dieb5 ] {ai_velocity(20);};
void()	knight_dieb5  =[ $deathb5,	knight_dieb6 ] {ai_velocity(20);};
void()	knight_dieb6  =[ $deathb6,	knight_dieb7 ] {};
void()	knight_dieb7  =[ $deathb7,	knight_dieb8 ] {};
void()	knight_dieb8  =[ $deathb8,	knight_dieb9 ] {};
void()	knight_dieb9  =[ $deathb9,	knight_dieb10] {};
void()	knight_dieb10 =[ $deathb10,	knight_dieb11] {};
void()	knight_dieb11 =[ $deathb11,	decay] {};


void() knight_die =
{
	self.alpha = 1;
	self.solid = SOLID_NOT;
	if (!(self.monsterflags & MFL_DROP_HEAD)) // if we chop the head off with katana body should stay and head fly
		self.velocity = self.lasthit_direction;
	// check for gib
	if (self.health <= 0 && self.lasthit_damage > self.gib_threshold || self.monsterflags & MFL_GIB_ME)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_knight.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib1.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib2.mdl", self.lasthit_damage);
		ThrowGib ("progs/synth_gib3.mdl", self.lasthit_damage);
		
		return;
	}
	
	if (self.health_head <= 0)
	{
		dropAmmo(self.origin, DROP_NAILS, 20, 10, 5, 5);
		dropHealth(self.origin, DROP_ARMOR_ONE, 6, 4, 2, 2);
		
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		setmodel (self, "progs/knight_headless.mdl");
		setsize (self, '-16 -16 -24', '16 16 32');
		self.angles_y += crandom() * 30;
		sendMessageVec(findHeadPosition(self), TE_SYNTHHEAD_EXPLOSION); // particle effect
		if (self.monsterflags & MFL_DROP_HEAD)
		{
			self.monsterflags -= self.monsterflags & MFL_DROP_HEAD;
			ThrowHeadGib ("progs/h_knight.mdl", self.lasthit_direction * 200 + '0 0 100', 1);
		}
		else
		{
			for (float i = 0; i < 5; i++)
				ThrowHeadGib ("progs/smallgib.mdl", self.lasthit_direction * (100 + random()*50) + [crandom() * 100, crandom() * 100, random() * 200], 0);
		}
	}
	else
		sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);

	if (random() < 0.5)
		knight_die1 ();
	
	else
		knight_dieb1 ();
};


/*QUAKED monster_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush*/
void() monster_knight_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_knight";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/knight.mdl");
	setsize (self, '-16 -16 -24', '16 16 32'); //28

	self.noise = "knight/ksight.wav";	//gnounc
	self.netname = "Knight";
	self.killstring = " was slashed by a Junta's Cyborg\n";
	self.head_offset = '2 0 22';
	self.head_size = 12;
	self.health = KNIGHT_HEALTH;
	self.max_health = KNIGHT_HEALTH;
	self.health_head = KNIGHT_HEAD;
	self.health_head_max = KNIGHT_HEAD;
	self.monsterflags |= MFL_HASHEAD | MFL_HEADKILLS | MFL_SYNTH;
	self.copperflags |= CFL_MELEEONLY;
	self.monstertype = TYPE_KNIGHT;
	self.skinchange = 1;
	self.gib_threshold = 75;
	self.th_stand = knight_stand1;
	self.th_walk = knight_walk1;
	self.th_run = knight_run1;
	self.th_melee = knight_atk1;
	self.th_pain = knight_pain;
	self.th_die = knight_die;
	
	walkmonster_start ();
};

void() monster_knight_spawner = 
{
	mon_spawner_use(monster_knight_spawn);
};

void() monster_knight =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/knight.mdl");
	precache_model ("progs/knight_trail.mdl");
	precache_model ("progs/knight_headless.mdl");
	precache_model ("progs/h_knight.mdl");
	precache_sound ("knight/kdeath.wav");
	precache_sound ("knight/khurt.wav");
	precache_sound ("knight/ksight.wav");
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	precache_sound ("knight/idle.wav");
	
	setsize (self, '-16 -16 -24', '16 16 32'); // set for telefrag check
	self.health = KNIGHT_HEALTH;
	if ( monster_spawnsetup( monster_knight_spawner ) )
		return;
	
	addmonster(1);
	monster_knight_spawn();
};