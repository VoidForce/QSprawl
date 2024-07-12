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

void() wizzard_fire =
{
	local	vector	dir;
	local	entity	en;
	
	ai_face();
	
	sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);	

	// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	
	dir = en.origin - en.velocity*0.2;
	dir = normalize (dir - self.origin);
	
	FireBullets (1, dir, '0.1 0.1 0', 4);
	sendMessageVecVecFlag(self.origin, trace_endpos, MF_SMG, TE_BULLETTRACE);
};

void() Wiz_StartFast =
{
	local	entity	missile;
	
	sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
	self.v_angle = self.angles;
	makevectors2 (self.angles);

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 0.6;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.8;
	missile.think = Wiz_FastFire;
	missile.movedir = v_right;

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 1;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right* -14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.3;
	missile.think = Wiz_FastFire;
	missile.movedir = VEC_ORIGIN - v_right;
};

void() Wiz_FastFire =
{
	local vector		vec;
	local vector		dst;

	if (self.owner.health > 0)
	{
		self.owner.effects = self.owner.effects | EF_MUZZLEFLASH;

		makevectors2 (self.enemy.angles);	
		dst = self.enemy.origin - 13*self.movedir;
	
		vec = normalize(dst - self.origin);
		sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
		launch_spike (self.origin, vec);
		newmis.velocity = vec*600;
		newmis.owner = self.owner;
		newmis.classname = "wizard_spike";		//changed it to be consistant --gnounc
		setmodel (newmis, "progs/w_spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	}

	remove (self);
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

void()	wiz_stand1	=[	$hover1,		wiz_stand2	] {ai_stand();};
void()	wiz_stand2	=[	$hover2,		wiz_stand3	] {ai_stand();};
void()	wiz_stand3	=[	$hover3,		wiz_stand4	] {ai_stand();};
void()	wiz_stand4	=[	$hover4,		wiz_stand5	] {ai_stand();};
void()	wiz_stand5	=[	$hover5,		wiz_stand6	] {ai_stand();};
void()	wiz_stand6	=[	$hover6,		wiz_stand7	] {ai_stand();};
void()	wiz_stand7	=[	$hover7,		wiz_stand8	] {ai_stand();};
void()	wiz_stand8	=[	$hover8,		wiz_stand1	] {ai_stand();};

void()	wiz_walk1	=[	$hover1,		wiz_walk2	] {ai_walk(8); Wiz_idlesound();};
void()	wiz_walk2	=[	$hover2,		wiz_walk3	] {ai_walk(8);};
void()	wiz_walk3	=[	$hover3,		wiz_walk4	] {ai_walk(8);};
void()	wiz_walk4	=[	$hover4,		wiz_walk5	] {ai_walk(8);};
void()	wiz_walk5	=[	$hover5,		wiz_walk6	] {ai_walk(8);};
void()	wiz_walk6	=[	$hover6,		wiz_walk7	] {ai_walk(8);};
void()	wiz_walk7	=[	$hover7,		wiz_walk8	] {ai_walk(8);};
void()	wiz_walk8	=[	$hover8,		wiz_walk1	] {ai_walk(8);};

void()	wiz_side1	=[	$hover1,		wiz_side2	] {ai_run(8); Wiz_idlesound();};
void()	wiz_side2	=[	$hover2,		wiz_side3	] {ai_run(8);};
void()	wiz_side3	=[	$hover3,		wiz_side4	] {ai_run(8);};
void()	wiz_side4	=[	$hover4,		wiz_side5	] {ai_run(8);};
void()	wiz_side5	=[	$hover5,		wiz_side6	] {ai_run(8);};
void()	wiz_side6	=[	$hover6,		wiz_side7	] {ai_run(8);};
void()	wiz_side7	=[	$hover7,		wiz_side8	] {ai_run(8);};
void()	wiz_side8	=[	$hover8,		wiz_side1	] {ai_run(8);};

void()	wiz_run1	=[ $hover1, wiz_run2 ] {ai_run(16); Wiz_idlesound();};
void()	wiz_run2	=[ $hover2, wiz_run3 ] {ai_run(16);};
void()	wiz_run3	=[ $hover3, wiz_run4 ] {ai_run(16);};
void()	wiz_run4	=[ $hover4, wiz_run5 ] {ai_run(16);};
void()	wiz_run5	=[ $hover5, wiz_run6 ] {ai_run(16);};
void()	wiz_run6	=[ $hover6, wiz_run7 ] {ai_run(16);};
void()	wiz_run7	=[ $hover7, wiz_run8 ] {ai_run(16);};
void()	wiz_run8	=[ $hover8, wiz_run1 ] {ai_run(16);};

void()	wiz_fast1	=[ $hover1, wiz_fast2 ] {ai_face(); Wiz_StartFast();};
void()	wiz_fast2	=[ $hover2, wiz_fast3 ] {ai_face();};
void()	wiz_fast3	=[ $hover3, wiz_fast4 ] {ai_face();};
void()	wiz_fast4	=[ $hover4, wiz_fast5 ] {ai_face();};
void()	wiz_fast5	=[ $hover5, wiz_fast6 ] {ai_face();};
void()	wiz_fast6	=[ $hover6, wiz_fast9 ] {ai_face();};
void()	wiz_fast9	=[ $hover7, wiz_fast10] {ai_face();};
void()	wiz_fast10	=[ $hover8, wiz_run1  ] {ai_face(); SUB_AttackFinished(2);WizardAttackFinished ();};

void()	wiz_pain1	=[	$pain1,		wiz_pain2	] {};
void()	wiz_pain2	=[	$pain2,		wiz_pain3	] {};
void()	wiz_pain3	=[	$pain3,		wiz_pain4	] {};
void()	wiz_pain4	=[	$pain4,		wiz_run1	] {};

void()	wiz_death1	=[	$death1,		wiz_death2	] 
{
	vector temp;
	temp = vectoangles(self.enemy.origin - self.origin);
	makevectors2(temp);

	self.velocity = v_forward * 600;
	self.velocity_z = 200;
	self.avelocity_z = 900;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
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


void() Wiz_Missile =
{
	wiz_fast1();
};

/*
	QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/

void() monster_wizard =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/wizard.mdl");

	//gnounc
	self.noise = "wizard/wsight.wav";	//gnounc
	self.netname = "Scrag";
	self.killstring = " couldn't handle this air superiority\n";

	setsize (self, '-16 -16 -24', '16 16 24');// 24 48
	//self.head_offset = '0 0 28';
	self.head_size = 0;
	self.health = SCRAG_HEALTH;
	self.max_health = SCRAG_HEALTH;
	self.gib_threshold = 80;
	self.monstertype = TYPE_SCRAG;
	self.fA = 2; // amoung of rockets to fire, will be depleted fully

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wizzard_fire;//Wiz_Missile;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;
	self.yaw_speed = 75;
		
	flymonster_start ();
};
