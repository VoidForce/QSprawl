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

$cd /raid/quake/id1/models/a_wizard
$origin 0 0 24
$base wizbase	
$skin wizbase

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12 fly13 fly14

$frame magatt1 magatt2 magatt3 magatt4 magatt5 magatt6 magatt7
$frame magatt8 magatt9 magatt10 magatt11 magatt12 magatt13

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7 death8

//---------------------------------------------------------------------------------
/*
void(entity missile, float mspeed, float accuracy) LaunchMissile =
{
	local	vector	vec, move;
	local	float	fly;

	makevectors2 (self.angles);
		
	// set missile speed
	vec = self.enemy.origin + self.enemy.mins + self.enemy.size * 0.7 - missile.origin;

	// calc aproximate time for missile to reach vec
	fly = vlen (vec) / mspeed;
	
	// get the entities xy velocity
	move = self.enemy.velocity;
	move_z = 0;

	// project the target forward in time
	vec = vec + move * fly;
	
	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);
	
	missile.velocity = vec * mspeed;
	missile.angles = '0 0 0';
	missile.angles_y = vectoyaw(missile.velocity);

	// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;	
};
*/
void() wizzard_laser =
{
	traceline (self.origin + '0 0 10', self.enemy.origin, ALLOWMONSTERS, self);
	sendMessageVecVecFlag(self.origin + '0 0 10', trace_endpos, LASER_RED, TE_LASERTRACE);
};

void(float offset) wizzard_fire =
{
	vector dir;
	vector start;
	
	sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);	

	makevectors2(self.angles);
	start = self.origin + v_right * offset + '0 0 8';
	dir = getPlayerPosition(self.enemy, 1);
	dir = normalize (dir - start);
	FireBullets (1, dir, '0.04 0.04 0', 4);
	sendMessageVecVecFlag(start, trace_endpos, MF_SMG, TE_BULLETTRACE);
};


float()	WizardCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;

	if (!enemy_vis)
		return FALSE;

	if (enemy_range == RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}
		
	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}

	if (enemy_range == RANGE_MELEE)
		chance = 0.9;

	else if (enemy_range == RANGE_NEAR)
		chance = 0.6;

	else if (enemy_range == RANGE_MID)
		chance = 0.2;

	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
	}
	else
	{
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			wiz_side1 ();
		}
	}
	
	return FALSE;
};

/*
=================
WizardAttackFinished
=================
*/
void()	WizardAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = wiz_run1;
	}

	else
	{
		self.attack_state = AS_SLIDING;
		self.think = wiz_side1;
	}
};

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() Wiz_idlesound =
{
	if (self.waitmin < time)
	{
	 	self.waitmin = time + 2;
	 	if (random() > 0.5) 
	 		sound (self, CHAN_VOICE, "wizard/widle1.wav", 1, ATTN_IDLE);
	 	else 
	 		sound (self, CHAN_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
	return;
};

void()	wiz_stand1	=[ $hover1, wiz_stand2 ] {ai_stand();};
void()	wiz_stand2	=[ $hover2, wiz_stand3 ] {ai_stand();};
void()	wiz_stand3	=[ $hover3, wiz_stand4 ] {ai_stand();};
void()	wiz_stand4	=[ $hover4, wiz_stand5 ] {ai_stand();};
void()	wiz_stand5	=[ $hover5, wiz_stand6 ] {ai_stand();};
void()	wiz_stand6	=[ $hover6, wiz_stand7 ] {ai_stand();};
void()	wiz_stand7	=[ $hover7, wiz_stand8 ] {ai_stand();};
void()	wiz_stand8	=[ $hover8, wiz_stand1 ] {ai_stand();};
										   
void()	wiz_walk1	=[ $hover1, wiz_walk2 ] {ai_walk(8); Wiz_idlesound();};
void()	wiz_walk2	=[ $hover2, wiz_walk3 ] {ai_walk(8);};
void()	wiz_walk3	=[ $hover3, wiz_walk4 ] {ai_walk(8);};
void()	wiz_walk4	=[ $hover4, wiz_walk5 ] {ai_walk(8);};
void()	wiz_walk5	=[ $hover5, wiz_walk6 ] {ai_walk(8);};
void()	wiz_walk6	=[ $hover6, wiz_walk7 ] {ai_walk(8);};
void()	wiz_walk7	=[ $hover7, wiz_walk8 ] {ai_walk(8);};
void()	wiz_walk8	=[ $hover8, wiz_walk1 ] {ai_walk(8);};
										   
void()	wiz_side1	=[ $hover1, wiz_side2 ] {ai_run(16); Wiz_idlesound();};
void()	wiz_side2	=[ $hover2, wiz_side3 ] {ai_run(16);};
void()	wiz_side3	=[ $hover3, wiz_side4 ] {ai_run(16);};
void()	wiz_side4	=[ $hover4, wiz_side1 ] {ai_run(16);};
//void()	wiz_side5	=[ $hover5, wiz_side6 ] {ai_run(16);};
//void()	wiz_side6	=[ $hover6, wiz_side7 ] {ai_run(16);};
//void()	wiz_side7	=[ $hover7, wiz_side8 ] {ai_run(16);};
//void()	wiz_side8	=[ $hover8, wiz_side1 ] {ai_run(16);};

void()	wiz_run1	=[ $hover1, wiz_run2 ] {ai_run(20); Wiz_idlesound();};
void()	wiz_run2	=[ $hover2, wiz_run3 ] {ai_run(20);};
void()	wiz_run3	=[ $hover3, wiz_run4 ] {ai_run(20);};
void()	wiz_run4	=[ $hover4, wiz_run5 ] {ai_run(20);};
void()	wiz_run5	=[ $hover5, wiz_run6 ] {ai_run(20);};
void()	wiz_run6	=[ $hover6, wiz_run7 ] {ai_run(20);};
void()	wiz_run7	=[ $hover7, wiz_run8 ] {ai_run(20);};
void()	wiz_run8	=[ $hover8, wiz_run1 ] {ai_run(20);};

void()	wiz_fast1	=[ $hover1, wiz_fast22 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast22	=[ $hover2, wiz_fast23 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast23	=[ $hover3, wiz_fast24 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast24	=[ $hover4, wiz_fast11 ] {wizzard_laser(); ai_face(); };

void()	wiz_fast11	=[ $hover1, wiz_fast2 ] {wizzard_laser(); ai_face(); wizzard_fire(-16);};
void()	wiz_fast2	=[ $hover2, wiz_fast3 ] {wizzard_laser(); ai_face(); wizzard_fire(-16);};
void()	wiz_fast3	=[ $hover3, wiz_fast4 ] {wizzard_laser(); ai_face(); wizzard_fire(-16);};
void()	wiz_fast4	=[ $hover4, wiz_fast5 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast5	=[ $hover5, wiz_fast6 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast6	=[ $hover4, wiz_fast7 ] {wizzard_laser(); ai_face(); };
void()	wiz_fast7	=[ $hover5, wiz_fast8 ] {wizzard_laser(); ai_face(); wizzard_fire(16);};
void()	wiz_fast8	=[ $hover6, wiz_fast9 ] {wizzard_laser(); ai_face(); wizzard_fire(16);};
void()	wiz_fast9	=[ $hover7, wiz_fast10] {wizzard_laser(); ai_face(); wizzard_fire(16);};
void()	wiz_fast10	=[ $hover8, wiz_run1  ] {wizzard_laser(); ai_face(); SUB_AttackFinished(2);WizardAttackFinished ();};

void()	wiz_pain1	=[	$pain1,		wiz_pain2	] {};
void()	wiz_pain2	=[	$pain2,		wiz_pain3	] {};
void()	wiz_pain3	=[	$pain3,		wiz_pain4	] {};
void()	wiz_pain4	=[	$pain4,		wiz_run1	] {};

void()	wiz_death1	=[	$death1,		wiz_death2	] 
{
	makevectors2(self.angles);

	self.velocity = v_forward * 300;
		self.movetype = MOVETYPE_BOUNCE;
	self.avelocity = [crandom() * 300, crandom() * 300, crandom() * 300];
	self.flags -= self.flags & FL_ONGROUND;
	sound (self, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
};

void()	wiz_death2	=[ $death2, wiz_death3 ] {};
void()	wiz_death3	=[ $death3, wiz_death4 ] {};
void()	wiz_death4	=[ $death4, wiz_death5 ] {};
void()	wiz_death5	=[ $death5, wiz_death6 ] {};
void()	wiz_death6	=[ $death6, wiz_death7 ] {};
void()	wiz_death7	=[ $death7, wiz_death8 ] {};
void()	wiz_death8	=[ $death8, decay ] {};		

void() wiz_explode =
{
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

void() wiz_die =
{
	//self.solid = SOLID_NOT;
// check for gib
	dropAmmo(self.origin, DROP_NAILS, 30, 20, 10, 4);
	dropHealth(self.origin, DROP_ARMOR_ONE, 4, 2, 2, 2);
	if (self.lasthit_damage > self.gib_threshold)
	{
		wiz_explode();
		return;
	}

	wiz_death1 ();
	self.touch = wiz_explode;
};


void(entity attacker, float damage) Wiz_Pain =
{
	playPainSound("wizard/wpain.wav");
	if (random()*70 > damage)
		return;		// didn't flinch

	wiz_pain1 ();
};

/*
	QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/

void() monster_wizard_spawn =
{
	self.skin = 0; // custom mods skin reset
	self.classname = "monster_wizard";
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.clip = CLIP_MONSTER;
	setmodel (self, "progs/wizard.mdl");
	setsize (self, '-16 -16 0', '16 16 24');
	
	self.noise = "wizard/wsight.wav";	//gnounc
	self.netname = "Drone";
	self.killstring = " couldn't handle this air superiority\n";
	self.head_size = 0;
	self.health = SCRAG_HEALTH;
	self.max_health = SCRAG_HEALTH;
	self.gib_threshold = 40;
	self.monstertype = TYPE_SCRAG;
	self.monsterflags |= MFL_ROBOT;
	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wiz_fast1;//Wiz_Missile;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;
	self.yaw_speed = 75;
		
	flymonster_start ();
};

void() monster_wizard_spawner = 
{
	mon_spawner_use(monster_wizard_spawn);
};

void() monster_wizard =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

	setsize (self, '-16 -16 0', '16 16 24');// set for telefrag check
	self.health = SCRAG_HEALTH;
	if ( monster_spawnsetup( monster_wizard_spawner ) )
		return;
	
	addmonster(1);
	monster_wizard_spawn();
};