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

void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============*/

float(entity targ, entity inflictor) CanDamage =
{
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;

		if (trace_ent == targ)
			return TRUE;

		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);

	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);

	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);

	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);

	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);

	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*============
Killed
============*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;

	if (self.entity_type == TYPE_PLAYER && self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;

		return;
	}

	self.enemy = attacker;

	// bump the monster counter
	if (self.flags & FL_MONSTER && !(self.sprawlflags & MFL_NOTMONSTER))
	{
		self.skin = 0;
		self.skinchange = 0;
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die ();
	
	self = oself;
};

void(entity victim, entity attacker, float force, float verticalForce) T_Push =
{
	vector direction;
	float modifiedForce;
	
	if (victim.pushback_time > time)
		return;
	modifiedForce = force;
	
	if ( victim.movetype == MOVETYPE_WALK )
	{
	// heavy monsters
		if (victim.monstertype == TYPE_SHAMBLER)
			modifiedForce *= 0.5;
		
		direction = victim.origin - (attacker.absmin + attacker.absmax) * 0.5;
		direction = normalize(direction);

		victim.velocity = victim.velocity + (direction * modifiedForce);
		victim.velocity_z = victim.velocity_z + verticalForce;
		
		if (victim.flags & FL_ONGROUND)
			victim.flags = victim.flags - FL_ONGROUND;
	}
};

int (float type)fillArmorStats = 
{
	switch(type)
	{
		case TYPE_SOLDIER:
			armorstats = A_SOLDIER;
			return 0;
		case TYPE_ENFORCER:
			armorstats = A_ENFORCER;
			return 0;
		case TYPE_SCRAG:
			armorstats = A_SCRAG;
			return 0;
		case TYPE_OGRE:
			armorstats = A_OGRE;
			return 0;
		case TYPE_DOG:
			armorstats = A_DOG;
			return 0;
		case TYPE_FIEND:
			armorstats = A_FIEND;
			return 0;
		case TYPE_KNIGHT:
			armorstats = A_KNIGHT;
			return 0;
		case TYPE_HELLKNIGHT:
			armorstats = A_HELLKNIGHT;
			return 0;
		case TYPE_VORE:
			armorstats = A_VORE;
			return 0;
		case TYPE_ZOMBIE:
			armorstats = A_ZOMBIE;
			return 0;
		case TYPE_SHAMBLER:
			armorstats = A_SHAMBLER;
			return 0;
	}
	dprint3("Unknown armor stats:", ftos(type), "\n");
	return 1;
};

/*============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============*/
void(entity targ, entity inflictor, entity attacker, float damage, float dflags, float penetration = 0, float count = 1) T_Damage=
{
	vector dir;
	entity oldself;
	float save;
	float take;

	if (!targ.takedamage)
		return;

	//gnounc -- shub kill crash fix.
	if (targ.classname == "monster_oldone" && damage < 9999)
		return;
	dprint2("penetration: ",ftos(penetration)); endl();
	if (attacker.entity_type == TYPE_PLAYER && attacker != targ)
	{
		if (dflags & DF_HEADSHOT && targ.monsterflags & MFL_HASHEAD)
		{
			attacker.engineflags |= ENF_HITHEAD;
			sound (attacker, CHAN_AUTO, "weapons/hitmarker_head.wav", 1, ATTN_NORM);
			attacker.headmarker_time = time + 0.2;
		}
		//sound (attacker, CHAN_AUTO, "weapons/hitmarker.wav", 1, ATTN_NORM);
		attacker.engineflags |= ENF_HITMARKER;
		attacker.hitmarker_time = time + 0.2;
	}

	// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

	// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
	{
		damage = damage * 3;
		if (penetration < 1)
			penetration = 1;
	}
	
	if (targ.entity_type == TYPE_PLAYER)
	{
		// save damage based on the target's armor level
		save = ceil(targ.armortype*damage);

		if (save >= targ.armorvalue)
		{
			save = targ.armorvalue;
			targ.armortype = 0;	// lost all armor
			targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		}
		
		targ.armorvalue = targ.armorvalue - save;
		take = ceil(damage-save);
	}
	else 
		take = ceil(damage);
	
	if (targ.flags & FL_MONSTER)
	{
		float res;
		float mit;
	// minimal damage is lower on headshots
		if (dflags & DF_HEADSHOT)
			save = take * 0.1;
		else
			save = take * 0.2;
		
		if (fillArmorStats(targ.monstertype))
			armorstats = A_NULL; // couldn't find proper type
		
	// player does more damage when shooting from behind
	// we do this by increasing penetration power by 80% (addition, not multiplication)
		if (attacker.entity_type == TYPE_PLAYER)
		{
		// i'm gonna use res here for angles difference, it's ugly but who cares
			res = anglemod(targ.angles_y - attacker.angles_y); //
			if (res < 75 || res > 285)
			{
			// hit back
				penetration += 0.8;
				sound (attacker, CHAN_AUTO, "weapons/hitmarker.wav", 1, ATTN_NORM);
			// mark as critical hit 
				attacker.engineflags |= ENF_HITHEAD;
				attacker.headmarker_time = time + 0.2;
			}
			res = 0;
		}
		penetration = 1 - penetration;

		if (targ.monsterflags & MFL_SHIELD)
		{
			res = 2;
			mit = 200;
			save = 0;
		}
		else
		{
			if (dflags & DF_HEADSHOT)
			{
				res = armorstats.head_resistance * penetration;
				mit = armorstats.head_mitigation * penetration;
			}
			else
			{	
				res = armorstats.body_resistance * penetration;
				mit = armorstats.body_mitigation * penetration;
			}
			
			if ( dflags & DF_EXPLOSION)
			{
				res = armorstats.explosives_resistance;
				mit = 0;
			}
		}

		//dprint5("mit: ",ftos(mit)," res: ", ftos(res), "\n");
		take -= mit * count;
		if (take < save)
			take = save;
		//dprint3("Damage mit: ",ftos(take), "\n");
		take *= (1 - res);
		//dprint3("Damage res: ",ftos(take), "\n");
		if (take < save)
			take = save;
		take = ceil(take);
	}
	if (attacker.entity_type == TYPE_PLAYER)
	{
		dprint(targ.classname);
		dprint4(" HP:",ftos(targ.health), " head:",ftos(targ.health_head)); endl();
		dprint3("Damage: ",ftos(take), "\n");
	}

	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;
	}

	// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

	// team play damage avoidance
	if ( teamplay == 1 && targ.team > 0 && targ.team == attacker.team )
		return;
	
	if (dflags & DF_NEVERGIB)
		targ.lasthit_damage = 1; // prevent gib death
	else
		targ.lasthit_damage = take;
	// do the damage
	if (dflags & DF_HEADSHOT && targ.monsterflags & MFL_HASHEAD)
	{
		targ.health_head -= take;
		targ.health -= rint(take * 0.4);
		targ.monsterflags |= MFL_PAIN_HEADSHOT;
	}
	else
		targ.health -= take;

	if (targ.health <= 0)
	{
	// actually will not drop the head, but will not apply velocity to the body when killed with katana
		if (dflags & DF_KATANA)
			targ.monsterflags |= MFL_DROP_HEAD;
		Killed (targ, attacker);
		return;
	}
	
	if (targ.monsterflags & MFL_HASHEAD && targ.health_head <= 0)
	{
		targ.skin = 0;
		targ.skinchange = 0;
		targ.monsterflags |= MFL_LOST_HEAD;
		targ.monsterflags -= targ.monsterflags & MFL_HASHEAD;
		
		if (dflags & DF_KATANA)
			targ.monsterflags |= MFL_DROP_HEAD;
		
		targ.pain_finished = 0;
		if (targ.monsterflags & MFL_HEADKILLS)
		{
			//targ.health = -1;
			Killed (targ, attacker);
			return;
		}
	}

	//react to the damage
	oldself = self;
	self = targ;

	if (self.flags & FL_MONSTER && attacker.entity_type == TYPE_PLAYER)
	{
		if (self.enemy != attacker)
		{
			self.oldenemy = self.enemy;		
			self.enemy = attacker;
			FoundTarget ();
		}
		
		/*
		//get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if ( (self.classname != attacker.classname) || (self.classname == "monster_army" ) )
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				
				self.enemy = attacker;
				FoundTarget ();
			}
		}
		*/
	}
	
	if (dflags & DF_EPICENTER && self.monstertype == TYPE_OGRE && !(self.state & OGRE_NOWEAPON))
	{
			self.monsterflags |= MFL_LOSTWEAPON;
	}
	
	if (self.th_pain)
	{
		self.th_pain (attacker, take);
		// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;		
	}

	self = oldself;
};

/*============
T_RadiusDamage
============*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head == ignore || !head.takedamage)
		{
			head = head.chain;
			continue;
		}

		org = head.origin + (head.mins + head.maxs)*0.5;
		points = 0.5*vlen (inflictor.origin - org);

		if (points < 0)
			points = 0;

		points = damage - points;

		if (head == attacker)
			points = points * 0.5;

		if (points > 0)
		{
			if (CanDamage (head, inflictor))
				T_Damage (head, inflictor, attacker, points, DF_EXPLOSION);
		}
		head = head.chain;
	}
};

void(entity inflictor, entity attacker, float damage, entity ignore, float radius, float epicenter) T_RadiusDamagePlayer =
{
	float 	points;
	entity	head;
	vector	org;
	float	distancetotarget, distoutepicenter,fall,fallfraction;
	float	dflags;

	head = findradius(inflictor.origin, radius);
	
	while (head)
	{
	//reset
		dflags = DF_EXPLOSION;
		if ((head != ignore) && (head != attacker) && head.takedamage)
		{
			org = head.origin + (head.mins + head.maxs)*0.5;
			distancetotarget = vlen (inflictor.origin - org);
			
			if ( distancetotarget <= epicenter ) 
			{
				points = damage;
				dflags |= DF_EPICENTER;
			}
			else
			{
				fall = radius - epicenter;
				distoutepicenter = distancetotarget - epicenter;
				fallfraction = 1 - ( distoutepicenter / fall);
				
			// bug: fix for that stupid bug that heals monster for 1000 hp	
				if (fallfraction < 0) 
					fallfraction = 0; 
				points = damage * fallfraction;
			}

			if (CanDamage (head, inflictor))
				T_Damage (head, inflictor, attacker, points, dflags);
		}
		head = head.chain;
	}
};

/*============
T_BeamDamage
============*/
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;

			points = damage - points;

			if (head == attacker)
				points = points * 0.5;

			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					if (head.classname == "monster_shambler")						
						T_Damage (head, attacker, attacker, points*0.5, 0);

					else
						T_Damage (head, attacker, attacker, points, 0);
				}
			}
		}
		head = head.chain;
	}
};

void(vector epicenter, float radius, vector amount) shakeViewRadius =
{
	entity	head;
	entity oldself;
	head = findradius(epicenter, radius);
	
	while (head)
	{
		if (!(head.flags & FL_CLIENT))
		{
			head = head.chain;
			continue;
		}

		oldself = self;
		self = head;
		addShake(amount_x, amount_y, amount_z);
		amount *= 0.2;
		addPunchVelocity(amount_x, amount_y, amount_z);
		self = oldself;
		head = head.chain;
	}
};