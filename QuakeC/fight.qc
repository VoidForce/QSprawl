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

/*A monster is in fight mode if it thinks it can effectively attack itsenemy.
When it decides it can't attack, it goes into hunt mode.*/

float(float v) anglemod;
void(vector dest) ChooseTurn;

void() ai_face;

float	enemy_vis, enemy_infront, enemy_range;
float	enemy_yaw;

//=============================================================================

/*===========
CheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============*/
float() CheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot
			
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{	// melee attack
		if (self.th_melee)
		{
			if (self.classname == "monster_knight")
				knight_attack ();

			else
				self.th_melee ();

			return TRUE;
		}
	}
	
// missile attack
	if (!self.th_missile)
		return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		self.attack_finished = 0;
	}

	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;

		else
			chance = 0.4;
	}

	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;

		else
			chance = 0.1;
	}

	else
		chance = 0;

	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (2*random());

		return TRUE;
	}

	return FALSE;
};


/*=============
ai_face

Stay facing the enemy
=============*/
void() ai_face =
{
	if (self.monsterflags & MFL_CONFUSED)
		self.ideal_yaw = vectoyaw(getPlayerPosition(self.enemy, 4) - self.origin);
	else
		self.ideal_yaw = vectoyaw(getPlayerPosition(self.enemy, 0) - self.origin);
	ChangeYaw ();
};

void() ai_face_instant =
{
	float oldyawspd;
	oldyawspd = self.yaw_speed;
	self.yaw_speed = 360;
	self.ideal_yaw = vectoyaw(getPlayerPosition(self.enemy, 0) - self.origin);
	ChangeYaw ();
	self.yaw_speed = oldyawspd;
};

/*=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============*/
float (entity targ) visible;
float(entity targ) infront;
float(entity targ) range;

void(float d) ai_charge_noface =
{
	movetogoal (d);		// done in C code...
};

void(float d) ai_charge =
{
	ai_face ();	
	movetogoal (d);		// done in C code...
};

void() ai_charge_side =
{
	vector	dtemp;
	float	heading;
	vector pos;
	pos = getPlayerPosition(self.enemy, 0);
	
	// aim to the left of the enemy for a flyby
	self.ideal_yaw = vectoyaw(pos - self.origin);
	ChangeYaw ();

	makevectors2 (self.angles);
	dtemp = pos - 30*v_right;
	heading = vectoyaw(dtemp - self.origin);
	
	walkmove(heading, 20);
};


/*=============
ai_melee

=============*/
void(float weak = 0) ai_melee =
{
	float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke

	if (vlen(self.enemy.origin - self.origin) > 80)// exact world position to check for damage
		return;
		
	ldmg = random() + random() + random();
	if (weak)
		ldmg *= 2;
	else 
		ldmg *= 4;
	
	T_Damage (self.enemy, self, self, ldmg, 0);
};


void(float weak = 0) ai_melee_side =
{
	float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	ai_charge_side();

	if (vlen(self.enemy.origin - self.origin) > 60)// exact world position to check for damage
		return;

	if (!CanDamage (self.enemy, self))
		return;
	
	ldmg = random() + random() + random();
	if (weak)
		ldmg *= 2;
	else 
		ldmg *= 4;
	
	T_Damage (self.enemy, self, self, ldmg, 0);
};