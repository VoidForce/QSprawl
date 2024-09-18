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

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

/* Copper
void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};
*/


/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};



/*============
PlaceItem

plants the object on the floor
============*/
/*
void() PlaceItem =
{
	local float	oldz;

	//gnounc		--for any items that dont already set their netnames
	if(self.netname == string_null)
	{
		if(self.items)
			self.netname = getNetname(self.items);
		if(self.weapon)
			self.netname = getNetname(self.weapon);	
	}

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;

	if (!droptofloor(0,0))
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);

		return;
	}
};
*/
/*============
StartItem

Sets the clipping size and plants the object on the floor
============*/
/*
void() StartItem =
{
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};
*/
/*=========================================================================

HEALTH BOX

=========================================================================*/


/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
.float	healamount, heallimit;

void() item_health =
{	
	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("progs/health_s.mdl");

		precache_sound("items/r_item1.wav");
		setmodel(self, "progs/health_s.mdl");
		self.noise = "items/r_item1.wav";
		self.healamount = 40; // change string in regenhealth_touch
		self.heallimit = 100;
		self.sprawlflags |= SFLI_REGEN; 
		self.touch = regenhealth_touch;
	}

	else if (self.spawnflags & H_MEGA)
	{
		precache_model("progs/health_m.mdl");
		precache_sound("items/r_item2.wav");
		setmodel(self, "progs/health_m.mdl");
		self.noise = "items/r_item2.wav";
		self.healamount = 100; // change string in megahealth_touch
		self.heallimit = 250;
		self.sprawlflags |= SFLI_MEGA;
		self.touch = megahealth_touch;
	}

	else
	{
		precache_model("progs/health_b.mdl");
		precache_sound("items/health1.wav");
		setmodel(self, "progs/health_b.mdl");
		self.noise = "items/health1.wav";
		self.fB = self.healamount = 30;
		self.heallimit = 100;
		self.touch = health_touch;
	}

	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	
	if (deathmatch == 1 || deathmatch == 3)
		self.wait = 20;
	
	StartItem ();
};
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
void (entity e, float healamount, float limit) T_Heal =
{
	//extra check
	if (e.health < 1)
		return;
	
	healamount = ceil(healamount);
	e.health = min (limit, e.health + healamount);
};

void() megahealth_touch =
{
	if (!CheckValidTouch())
		return;
	
	if (other.health >= self.heallimit)
		return;
	
	other.health = ceil(min (self.heallimit, other.health + self.healamount));
	
	sprint(other, "You receive \b100\b health\n");
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bfh\n");

	ItemTouched();
};

void() regenhealth_touch =
{
	if (!CheckValidTouch())
		return;
	
	if (other.health >= self.heallimit) // Megahealth?  Ignore max_health...
		return;

	entity healer;
	healer = spawn();
	healer.think = item_slowheal;
	healer.nextthink = time + 0.5;
	healer.healamount = self.healamount;
	healer.owner = other;
	setorigin(healer, self.origin);
	sprint(other, "You receive \b40\b health \bregen\b\n");
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bfh\n");

	ItemTouched();
};

void() health_touch =
{
	float spent;
	float deficit;
	
	if (!CheckValidTouch())
		return;
	
	if (other.health >= self.heallimit)
		return;
	
	if (other.health + self.healamount <= self.heallimit)
	{
		other.health += self.healamount;
		deficit = self.healamount;
		self.healamount = 0; 
	}
	else
	{
		deficit = self.heallimit - other.health;
		
		spent = ceil(deficit/5) * 5; // step of 5hp minimum gonna be used to heal anything from 1 to 5 of deficit
		other.health = self.heallimit;
		self.healamount -= spent;
		self.healamount = floor(self.healamount);
		
		self.touch = SUB_Null;
		self.nextthinkA = time + 1;
		self.thinkA = restoreTouch_health;
	}
		
	sprint(other, "You receive ");
	printgoldnum(other, deficit);
	sprint(other, " health\n");
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bfh\n");

	if (!(self.sprawlflags & SFLI_TARGETSFIRED))
	{
		self.sprawlflags |= SFLI_TARGETSFIRED;
		activator = other;
		SUB_UseTargets(); // fire all targets / killtargets
	}
	
	// wait > 0 == item respawns, either from deathmatch rules or entity keyvalue
	if (self.wait > 0)
	{
		if (self.healamount < 1)
		{
			self.alpha = 0.2;
			self.solid = SOLID_NOT;
		}
		
		self.sprawlflags |= SFLI_SETHEALTH;
		self.think = ItemPrespawn;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished - FLICK_TIME;
	}
	// wait -1 == respawn every time the item is triggered
	else if (self.wait < 0 || self.use == SUB_regen)	// maintain old respawn hacks
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		if (self.use != SUB_regen)
			self.use = ItemUse;
	}
	else if (self.healamount < 1)
		SUB_RemoveSoon();

	playercount_convert(count);
	if (self.count > 0)		// only respawn 'count' more times
		self.count = self.count - 1;

	if (self.wait > 0 && self.count < 1)
		SUB_RemoveSoon();	// can't remove during c touch/movement code
};	

void() restoreTouch_health =
{
	self.touch = health_touch;
};

void() item_slowheal =
{
	if (self.owner.deadflag || self.healamount < 1)
	{
		remove(self);
		return;
	}
	
	if (self.owner.health < self.owner.max_health)
		self.owner.health++;

	self.healamount--;
	self.nextthink = time + 0.5;
	self.think = item_slowheal;
};

/*===============================================================================

ARMOR

===============================================================================*/

void() armor_touch =
{
	float type, value;
	string str;

	if ( !CheckValidTouch() ) return;
	type = 1;
	value = 100;
	
	if (other.health <= 0)
		return;

	if (other.classname != "player")
		return;

	if (self.classname == "item_armor1")
	{
		type = 1;
		value = 50;
		str = "You got the light armor\n";
	}

	if (self.classname == "item_armor2")
	{
		type = 2;
		value = 100;
		str = "You got the combat armor\n";
	}

	if (self.classname == "item_armorInv")
	{
		type = 3;
		value = 200;
		str = "You got the assault armor\n";
	}

	if (type == 1 || type == 2)
	{
		if (other.armorvalue >= 100)
			return;
	}
	else if (type == 3)
	{
		if (other.armorvalue >= 200)
			return;
	}

	if (type == 1)
	{
		other.armorvalue += value;
		other.armorvalue = min(100, other.armorvalue);
	}
	else other.armorvalue = value;
	other.items |= IT_ARMOR;

	//sprint(other, "You got armor\n");
	sprint(other, str);
	// armor touch sound
	if (random() > 0.5)
		sound(other, CHAN_ITEM, "items/armorvest1.wav", 1, ATTN_NORM);
	else
		sound(other, CHAN_ITEM, "items/armorvest2.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfar\n");
	
	ItemTouched();
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)*/

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)*/

void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)*/

void() item_armorInv =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/
void(entity who)bound_ammo =
{
	if (who.ammo_shells > MAX_SHELLS)
		who.ammo_shells = MAX_SHELLS;

	if (who.ammo_nails > MAX_NAILS)
		who.ammo_nails = MAX_NAILS;

	if (who.ammo_rockets > MAX_ROCKETS)
		who.ammo_rockets = MAX_ROCKETS;		

	if (who.ammo_cells > MAX_CELLS)
		who.ammo_cells = MAX_CELLS;
	
	if (who.ammo_bullets > MAX_BULLETS)
		who.ammo_bullets = MAX_BULLETS;
};

void() bound_other_ammo =
{
	bound_ammo(other);
};


float(float w) RankForWeapon =
{
	if (w == IT_SHOCK)
		return 1;

	if (w == IT_GAUSS)
		return 2;

	if (w == IT_CHAINGUN)
		return 3;

	if (w == IT_GRENADE_LAUNCHER)
		return 4;

	if (w == IT_SUPER_SHOTGUN)
		return 5;

	if (w == IT_SMGS)
		return 6;

	return 7;
};

float (float w) WeaponCode = //copypasta'd directly from gpl'd qw source on github.
{
	if (w == IT_SUPER_SHOTGUN)
		return 3;

	if (w == IT_SMGS)
		return 4;

	if (w == IT_CHAINGUN)
		return 5;

	if (w == IT_GRENADE_LAUNCHER)
		return 6;

	if (w == IT_GAUSS)
		return 7;

	if (w == IT_SHOCK)
		return 8;

	return 1;
};

/*=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============*/
void(float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

	// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);

	if ( nr < or )
		deployGun(new);
};

/*=============
weapon_touch
=============*/
float() W_BestWeapon;

void() weapon_touch =
{
	local	float	new, old;
	local	float	leave;

	new = other.items;

	if (!(other.flags & FL_CLIENT))
		return;

	if (deathmatch == 2 || coop)
		leave = 1;

	else
		leave = 0;
	
	if (self.classname == "weapon_nailgun")
	{
		if (leave && (other.items & IT_SMGS) )
			return;

		new = IT_SMGS;
		other.ammo_nails = other.ammo_nails + 100;
	}

	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && (other.items & IT_CHAINGUN) )
			return;

		new = IT_CHAINGUN;
		other.ammo_bullets = other.ammo_bullets + 50;
	}
	
	else if (self.classname == "weapon_shotgun")
	{
		if (leave && (other.items & IT_PISTOL) )
			return;

		new = IT_PISTOL | IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 10;
		other.ammo_nails = other.ammo_nails + 50;
	}
	
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && (other.items & IT_SUPER_SHOTGUN) )
			return;

		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 10;
	}

	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && (other.items & IT_GAUSS) )
			return;

		new = IT_GAUSS;
		other.ammo_cells = other.ammo_cells + 10;
	}

	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && (other.items & IT_GRENADE_LAUNCHER) )
			return;

		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 6;
	}

	else if (self.classname == "weapon_lightning")
	{
		if (leave && (other.items & IT_SHOCK) )
			return;

		new = IT_SHOCK;
		other.ammo_cells = other.ammo_cells + 16;
	}

	else
		objerror ("weapon_touch: unknown classname");

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
	// weapon touch sound
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfw\n");

	bound_other_ammo ();
	setAmmo(other);
	// change to the weapon
	old = other.items;
	other.items = other.items | new;
	
	if (leave)
		return;

	// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;

	if (deathmatch == 1)
		self.nextthink = time + 30;

	self.think = SUB_regen;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)*/
void() weapon_shotgun =
{
	precache_model ("progs/g_shotgun.mdl");
	setmodel (self, "progs/g_shotgun.mdl");
	self.weapon = IT_SUPER_SHOTGUN | IT_PISTOL;
	self.netname = "Megatech A8";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

void() weapon_supershotgun =
{
	precache_model ("progs/g_shotgun.mdl");
	setmodel (self, "progs/g_shotgun.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Megatech A8";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	precache_model ("progs/g_smgs.mdl");
	setmodel (self, "progs/g_smgs.mdl");
	self.weapon = IT_SMGS;
	self.netname = "Seburo-Sendai C390 x 2";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	precache_model ("progs/g_chaingun.mdl");
	setmodel (self, "progs/g_chaingun.mdl");
	self.weapon = IT_CHAINGUN;
	self.netname = "Megatech HAW201";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	precache_model ("progs/g_grenade.mdl");
	setmodel (self, "progs/g_grenade.mdl");
	self.weapon = IT_GRENADE_LAUNCHER;
	self.netname = "Shogo-Kenbishi Auto-Load";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	precache_model ("progs/g_gauss.mdl");
	setmodel (self, "progs/g_gauss.mdl");
	self.weapon = IT_GAUSS;
	self.netname = "Hiro-Enki Y.T. Prototype v2";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	precache_model ("progs/g_shock.mdl");
	setmodel (self, "progs/g_shock.mdl");
	self.weapon = IT_SHOCK;
	self.netname = "Lightning Rod";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
===============================================================================

AMMO

===============================================================================
*/
// this is lame, need to find how exactly i can drew gold/red characters the other way
void (entity who, float number)printgoldnum =
{
	float num_print;
	float current_digit;
	float digits;
	
	if (number < 0 || number > 999)
		return;
	
	if (number > 99)
		digits = 2;
	else if (number > 9)
		digits = 1;

	do
	{
		current_digit = pow(10,digits);
		num_print = floor(number / current_digit);
		number -= num_print * current_digit;
		switch (num_print)
		{
		case 0:
			sprint (who, "\0");
			break;
		case 1:
			sprint (who, "\1");
			break;
		case 2:
			sprint (who, "\2");
			break;
		case 3:
			sprint (who, "\3");
			break;
		case 4:
			sprint (who, "\4");
			break;
		case 5:
			sprint (who, "\5");
			break;
		case 6:
			sprint (who, "\6");
			break;
		case 7:
			sprint (who, "\7");
			break;
		case 8:
			sprint (who, "\8");
			break;
		case 9:
			sprint (who, "\9");
			break;
		default:
			sprint (who, " ");
			break;
		}
		digits--;
	} while(digits > -1);
	
};

void() ammo_touch =
{
	float deficit;
	
	if (!CheckValidTouch())
		return;
	
// we just took some ammo from this box already, wait a bit to try again
	if (self.fA > time) 
		return;

// shotgun
	switch (self.weapon)
	{
		case 1:
			if (other.ammo_shells >= MAX_SHELLS)
				return;
			
			deficit = MAX_SHELLS - other.ammo_shells;
			if (deficit > self.aflag)
			{
				other.ammo_shells += self.aflag;
				deficit = self.aflag; // save amount we took for the message
				self.aflag = 0;
			}
			else
			{
				other.ammo_shells = MAX_SHELLS;
				self.aflag -= deficit;
			}
			if (self.aflag > 0)
				self.frame = 16 - self.aflag;
			break;

		case 2:
			if (other.ammo_nails >= MAX_NAILS)
				return;
			
			deficit = MAX_NAILS - other.ammo_nails;
			if (deficit > self.aflag)
			{
				other.ammo_nails += self.aflag;
				deficit = self.aflag; // save amount we took for the message
				self.aflag = 0;
			}
			else
			{
				other.ammo_nails = MAX_NAILS;
				self.aflag -= deficit;
			}
			if (self.aflag < 51 && !(self.sprawlflags & SFLI_MODELSET))
			{
				setmodel (self, "progs/ammo/nails.mdl");
				setsize (self, '0 0 0', '32 32 56');
				self.sprawlflags |= SFLI_MODELSET;
			}
			break;

		case 3:

			if (other.ammo_rockets >= MAX_ROCKETS)
				return;
			
			deficit = MAX_ROCKETS - other.ammo_rockets;
			if (deficit > self.aflag)
			{
				other.ammo_rockets += self.aflag;
				deficit = self.aflag; // save amount we took for the message
				self.aflag = 0;
			}
			else
			{
				other.ammo_rockets = MAX_ROCKETS;
				self.aflag -= deficit;
			}
			if (self.aflag > 0)
				self.frame = 6 - self.aflag;
			break;

		case 4:
			if (other.ammo_cells >= MAX_CELLS)
				return;
			
			deficit = MAX_CELLS - other.ammo_cells;
			if (deficit > self.aflag)
			{
				other.ammo_cells += self.aflag;
				deficit = self.aflag; // save amount we took for the message
				self.aflag = 0;
			}
			else
			{
				other.ammo_cells = MAX_CELLS;
				self.aflag -= deficit;
			}
			if (self.aflag > 0)
				self.frame = 3 - ceil(self.aflag / 3);
			break;

		case 5:
			if (other.ammo_bullets >= MAX_BULLETS)
				return;
			
			deficit = MAX_BULLETS - other.ammo_bullets;
			if (deficit > self.aflag)
			{
				other.ammo_bullets += self.aflag;
				deficit = self.aflag; // save amount we took for the message
				self.aflag = 0;
			}
			else
			{
				other.ammo_bullets = MAX_BULLETS;
				self.aflag -= deficit;
			}
			break;
	}

	bound_other_ammo ();
	
	sprint (other, "You got: ");
	printgoldnum(other, deficit);
	sprint (other, " ");
	sprint (other, self.netname);
	sprint (other, "\n");
	// ammo touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// if changed current ammo, update it
	setAmmo(other);
		
// we took ammo, set frame, now we need to fire targets and queue the respan
// if all the ammo was taken we have to make entity untouchable

//----------------- ItemTouched() expanded ---------------------------------
	if (!(self.sprawlflags & SFLI_TARGETSFIRED))
	{
		self.sprawlflags |= SFLI_TARGETSFIRED;
		activator = other;
		SUB_UseTargets(); // fire all targets / killtargets
	}
// launch respawn logic
	if (self.wait > 0)
	{
	// no ammo left, become transparent
		if (self.aflag < 1)
		{
			self.frame = self.fC; // reset frame right away
			self.alpha = 0.2;
			self.solid = SOLID_NOT;
		}
	// setup respawn
		self.sprawlflags |= SFLI_SETAMMO;
		self.attack_finished = time + self.wait;
		self.think = ItemPrespawn;
		self.nextthink = self.attack_finished - FLICK_TIME;
	}
// wait -1 == respawn every time the item is triggered
	else if (self.wait < 0 || self.use == SUB_regen)	// maintain old respawn hacks
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		
		if (self.use != SUB_regen)
			self.use = ItemUse;
	}
// no ammo left, remove
	else if (self.aflag < 1)
		SUB_RemoveSoon();
	
// extra count for coop
	playercount_convert(count);
// decrease
	if (self.count > 0)		// only respawn 'count' more times
		self.count = self.count - 1;
// OUT OF CHARGES REMOVE	
	if (self.wait > 0 && self.count < 1)
	{
		self.touch = SUB_Null;
		SUB_RemoveSoon();	// can't remove during c touch/movement code
		return;
	}

// pause touch for a bit
	if (self.aflag > 0)
	{
		self.effects |= EF_NOLERP; // change frame without interpolation
		self.fA = time + 0.5; // next time we can touch this
	}
};

void (entity who)setAmmo =
{
	if (who.items & IT_SHELLS)
	{
		who.currentammo = who.ammo_shells;
		return;
	}
	
	if (who.items & IT_NAILS)
	{
		who.currentammo = who.ammo_nails;
		return;
	}
	
	if (who.items & IT_ROCKETS)
	{
		who.currentammo = who.ammo_rockets;
		return;
	}
	
	if (who.items & IT_CELLS)
	{
		who.currentammo = who.ammo_cells;
		return;
	}
	if (who.items & IT_BULLETS)
	{
		who.currentammo = who.ammo_bullets;
	}
};

float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_shells =
{
	self.touch = ammo_touch;
	
	precache_model ("progs/ammo/shells.mdl");
	setmodel (self, "progs/ammo/shells.mdl");
	
	if (self.spawnflags & WEAPON_BIG2)
	{
		self.fB = self.aflag = 16;
		self.fC = self.frame = 0; // 16 - 0
	}

	else
	{
		self.fB = self.aflag = 8;
		self.fC = self.frame = 8; // 16 - 8
	}

	self.weapon = 1;
	self.netname = "shotgun shells";
	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_spikes =
{
	self.touch = ammo_touch;
	precache_model ("progs/ammo/nails_big.mdl");
	precache_model ("progs/ammo/nails.mdl");
	
	if (self.spawnflags & WEAPON_BIG2)
	{
		setmodel (self, "progs/ammo/nails_big.mdl");
		self.fB = self.aflag = 100;
	}

	else
	{
		setmodel (self, "progs/ammo/nails.mdl");
		self.fB = self.aflag = 50;
	}
	
	self.weapon = 2;
	self.netname = "pistol rounds";
	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_rockets =
{
	self.touch = ammo_touch;

	precache_model ("progs/ammo/rockets.mdl");
	setmodel (self, "progs/ammo/rockets.mdl");
	
	if (self.spawnflags & WEAPON_BIG2)
	{
		self.fB = self.aflag = 6;
		self.fC = self.frame = 0; // 6 - 0
	}
	else
	{
		self.fB = self.aflag = 2;
		self.fC = self.frame = 4; // 6 - 4
	}

	self.weapon = 3;
	self.netname = "grenades";
	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_cells =
{
	self.touch = ammo_touch;
	precache_model ("progs/ammo/cells.mdl");
	setmodel (self, "progs/ammo/cells.mdl");
	if (self.spawnflags & WEAPON_BIG2)
	{
		self.fB = self.aflag = 9; // cells provide x3 charges per battery
		self.fC = self.frame = 0; // 3 - 0
	}

	else
	{
		self.fB = self.aflag = 3;
		self.fC = self.frame = 2; // 3 - 2
	}

	self.weapon = 4;
	self.netname = "energy cells";
	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	StartItem ();
};

/*QUAKED item_bullets (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_bullets =
{
	self.touch = ammo_touch;

	precache_model ("progs/ammo/bullets.mdl");
	setmodel (self, "progs/ammo/bullets.mdl");
	
	if (self.spawnflags & WEAPON_BIG2)
		self.fB = self.aflag = 60;
	else
		self.fB = self.aflag = 30;

	self.weapon = 5;
	self.netname = "high-caiber rounds";
	setsize (self, '0 0 0', '32 32 56');
	self.extra_mins = '0 0 0';
	self.extra_maxs = '32 32 56';
	StartItem ();
};

/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!*/

float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void() item_weapon =
{
	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		self.spawnflags -= self.spawnflags & WEAPON_SHOTGUN;
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags -= self.spawnflags & WEAPON_BIG;
			self.spawnflags |= WEAPON_BIG2;
		}

		item_shells();
		return;
	}

	if (self.spawnflags & WEAPON_SPIKES)
	{
		self.spawnflags -= self.spawnflags & WEAPON_SPIKES;
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags -= self.spawnflags & WEAPON_BIG;
			self.spawnflags |= WEAPON_BIG2;
		}
		
		item_spikes();
		return;
	}

	if (self.spawnflags & WEAPON_ROCKET)
	{
		self.spawnflags -= self.spawnflags & WEAPON_ROCKET;
		if (self.spawnflags & WEAPON_BIG)
		{
			self.spawnflags -= self.spawnflags & WEAPON_BIG;
			self.spawnflags |= WEAPON_BIG2;
		}
		
		item_rockets();
		return;
	}
};

/*
===============================================================================

KEYS

===============================================================================
*/
/*
void() key_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	if (other.items & self.items)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}

	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}

	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};
*/
/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/
/*
void() item_key1 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}

	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}

	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};
*/
/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/
/*
void() item_key2 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}

	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}

	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


*/
/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/
/*
void() sigil_touch =
{

	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = string_null;		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

*/
/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/
/*
void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}

	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}

	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}

	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};
*/
/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch =
{
	if ( !CheckValidTouch() ) return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	sound (other, CHAN_AUTO, self.noise, 1, ATTN_NONE);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	else if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	else if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}
	else if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}	

	ItemTouched();
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;

	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/
/* b b b b b b b b b b b b b b b b b b b b b b b b (my cat sends this)
//the entirety of BackpackTouch
//copypasta'd directly from gpl'd qw source on github.
void() BackpackTouch =
{
	local string    s;
	//local   float   best,
	local   float   old, new;
	//local           entity  stemp;
	local   float   acount;

	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
		
	acount = 0;
 	sprint (other, "You get ");//Netquake does not support print_low

	if (self.items)
	{	
		if ((other.items & self.items) == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}
 	}

	// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;

	old = other.items;
	other.items = other.items | self.items;
	
	bound_other_ammo ();

	if (self.ammo_shells)
	{
		if (acount)
			sprint(other, ", ");	

		acount = 1;
		s = ftos(self.ammo_shells);
		sprint (other, s);
		sprint (other, " shells");
	}

	if (self.ammo_nails)
	{
		if (acount)
			sprint(other, ", ");

		acount = 1;
		s = ftos(self.ammo_nails);
		sprint (other, s);
		sprint (other, " nails");
	}

	if (self.ammo_rockets)
	{
		if (acount)
			sprint(other, ", ");

		acount = 1;
		s = ftos(self.ammo_rockets);
		sprint (other, s);
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (acount)
			sprint(other, ", ");

		acount = 1;
		s = ftos(self.ammo_cells);
		sprint (other, s);
		sprint (other, " cells");
	}
	
	sprint (other, "\n");

	// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	remove(self);
	self = other;
	
	//W_SetCurrentAmmo ();

};


//===============
//DropBackpack
//===============
void() DropBackpack =
{
	local entity    item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return; // nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	item.items = self.weapon;

	//gnounc
	item.netname = getNetname(item.items);

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;    // remove after 2 minutes
	item.think = SUB_Remove;
};
*/
#define DROP_SHELLS 1
#define DROP_NAILS 2
#define DROP_ROCKETS 3
#define DROP_CELLS 4
#define DROP_BULLETS 5

void(vector pos, float type, float easy, float normal, float hard, float nightmare) dropAmmo =
{
	entity item;
	float amount;
	
	if (!cvar("game_pickups"))
		return;
	
	switch (skill)
	{
		case 0:
			amount = easy;
			break;
		default:
		case 1:
			amount = normal;
			break;
		case 2:
			amount = hard;
			break;
		case 3:
			amount = nightmare;
			break;
	}
	
	if (amount < 1)
		return;
	
	item = spawn();
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/ammo/ammo_drop.spr");
	setsize (item, '-16 -16 -4', '16 16 32');
	setorigin (item, pos);
	item.touch = ammo_drop_touch;
	item.fA = type;
	item.velocity_z = 150;
	item.velocity_x = crandom() * 100;
	item.velocity_y = crandom() * 100;
	item.scale = 0.10;
	item.think = SUB_Remove;
	item.nextthink = time + 15;
	switch (type)
	{
		case DROP_SHELLS:
			item.ammo_shells = amount;
			item.frame = 3;
			break;
		case DROP_NAILS:
			item.ammo_nails = amount;
			item.frame = 0;
			break;
		case DROP_ROCKETS:
			item.ammo_rockets = amount;
			item.frame = 2;
			break;
		case DROP_CELLS:
			item.ammo_cells = amount;
			item.frame = 4;
			break;
		case DROP_BULLETS:
			item.ammo_bullets = amount;
			item.frame = 1;
			break;
	}
};

void() ammo_drop_touch =
{
	if (!(other.flags & FL_CLIENT))
		return;
	
	switch (self.fA)
	{
		case DROP_SHELLS:
			if (other.ammo_shells < MAX_SHELLS)
				other.ammo_shells += self.ammo_shells;
			else 
				return;
			sprint(other, "You pick up ");
			sprint(other, ftos( self.ammo_shells));
			sprint(other, " shells\n");
			other.ammo_shells = min(other.ammo_shells, MAX_SHELLS);
			break;
		case DROP_NAILS:
			if (other.ammo_nails < MAX_NAILS)
				other.ammo_nails += self.ammo_nails;
			else 
				return;
			sprint(other, "You pick up ");
			sprint(other, ftos( self.ammo_nails));
			sprint(other, " pistol rounds\n");
			other.ammo_nails = min(other.ammo_nails, MAX_NAILS);
			break;
		case DROP_ROCKETS:
			if (other.ammo_rockets < MAX_ROCKETS)
				other.ammo_rockets += self.ammo_rockets;
			else 
				return;
			sprint(other, "You pick up ");
			sprint(other, ftos( self.ammo_rockets));
			sprint(other, " grenades\n");
			other.ammo_rockets = min(other.ammo_rockets, MAX_ROCKETS);
			break;
		case DROP_CELLS:
			if (other.ammo_cells < MAX_CELLS)
				other.ammo_cells += self.ammo_cells;
			else 
				return;
			sprint(other, "You pick up ");
			sprint(other, ftos( self.ammo_cells));
			sprint(other, " energy cells\n");
			other.ammo_cells = min(other.ammo_cells, MAX_CELLS);
			break;
		case DROP_BULLETS:
			if (other.ammo_bullets < MAX_BULLETS)
				other.ammo_bullets += self.ammo_bullets;
			else 
				return;
			sprint(other, "You pick up ");
			sprint(other, ftos( self.ammo_bullets));
			sprint(other, " high-caliber rounds\n");
			other.ammo_bullets = min(other.ammo_bullets, MAX_BULLETS);
			break;
	}

	setAmmo(other);
	stuffcmd (other, "bfam\n");
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	SUB_Remove();
};

// health/armor drops in predifined amount of points
// Instead it will drop as much instances of drop items as needed to fill requested amount

#define DROP_ARMOR_ONE 		3
#define DROP_ARMOR			2
#define DROP_HEALTH_ONE 	1
#define DROP_HEALTH			0

void(vector pos, float type, float easy, float normal, float hard, float nightmare) dropHealth =
{
	entity item;
	float i, hp, lscale, overheal, amount;
	
	if (!cvar("game_pickups"))
		return;
	
	switch (skill)
	{
		case 0:
			amount = easy;
			break;
		default:
		case 1:
			amount = normal;
			break;
		case 2:
			amount = hard;
			break;
		case 3:
			amount = nightmare;
			break;
	}
	
	if (amount < 1)
		return;
	
	switch (type)
	{
		case DROP_HEALTH:
			hp = 10;
			overheal = 0;
			lscale = 0.10;
			break;
		case DROP_HEALTH_ONE:
			hp = 4 - skill;
			overheal = 1;
			lscale = 0.10;
			break;
		case DROP_ARMOR:
			hp = 10;
			overheal = 0;
			lscale = 0.10;
			break;
		case DROP_ARMOR_ONE:
			hp = 4 - skill;
			overheal = 1;
			lscale = 0.10;
			break;
	}
	
	for (i = 0; i < amount; i++)
	{
		item = spawn();
		item.flags = FL_ITEM;
		item.solid = SOLID_TRIGGER;
		item.movetype = MOVETYPE_TOSS;
		setmodel (item, "progs/health_drop.spr");
		setsize (item, '-16 -16 -4', '16 16 32');
		setorigin (item, pos);
		if (type < 2)
			item.touch = health_drop_touch;
		else
			item.touch = armor_drop_touch;
		item.velocity_z = 150;
		item.velocity_x = crandom() * 100;
		item.velocity_y = crandom() * 100;
		item.scale = lscale;
		item.think = SUB_Remove;
		item.nextthink = time + 15;
		item.frame = type;
		item.fA = overheal;
		item.health = hp;
	}
};

void() health_drop_touch =
{
	if (!(other.flags & FL_CLIENT))
		return;
	
	if (other.deadflag)
		return;
	
	if (!self.fA && other.health >= 100) // overheal not allowed
		return;
	
	other.health += self.health;
	if (!self.fA)
	{
		if (other.health > 100)
			other.health = 100;
	}
	else if (other.health > 250)
		other.health = 250;
	
	sprint(other, "You receive ");
	sprint(other, ftos(self.health));
	sprint(other, " health\n");
	
	stuffcmd (other, "bfh\n");

	sound (other, CHAN_ITEM, "items/health2.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfh\n");
	SUB_Remove();
};

void() armor_drop_touch =
{
	if (!(other.flags & FL_CLIENT))
		return;
	
	if (other.deadflag)
		return;
	
	if (!self.fA && other.armorvalue >= 100) // overheal not allowed
		return;
	
	other.armorvalue += self.health;
	if (!self.fA)
	{
		if (other.armorvalue > 100)
			other.armorvalue = 100;
	}
		else if (other.armorvalue > 250)
		other.armorvalue = 250;
	
	sprint(other, "You receive ");
	sprint(other, ftos(self.health));
	sprint(other, " armor\n");

	if (other.armorvalue > 0)
		other.items |= IT_ARMOR;

	//other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
	sound (other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfar\n");
	SUB_Remove();
};