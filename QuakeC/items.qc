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
void() W_SetCurrentAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



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

	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);

		return;
	}
};

/*============
StartItem

Sets the clipping size and plants the object on the floor
============*/
void() StartItem =
{
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*=========================================================================

HEALTH BOX

=========================================================================*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;

	if ((!ignore) && (e.health >= e.max_health))
		return 0;

	healamount = ceil(healamount);

	e.health = e.health + healamount;

	if ((!ignore) && (e.health >= e.max_health))
		e.health = e.max_health;
		
	if (e.health > 250)
		e.health = 250;

	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
.float	healamount, healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{	
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("progs/health_s.mdl");

		precache_sound("items/r_item1.wav");
		setmodel(self, "progs/health_s.mdl");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}

	else if (self.spawnflags & H_MEGA)
	{
		precache_model("progs/health_m.mdl");
		precache_sound("items/r_item2.wav");
		setmodel(self, "progs/health_m.mdl");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}

	else
	{
		precache_model("progs/health_b.mdl");
		precache_sound("items/health1.wav");
		setmodel(self, "progs/health_b.mdl");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}

	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

void() health_touch =
{
	local	string	s;
	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}

	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bfh\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}

	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)
				self.nextthink = time + 20;
			self.think = SUB_regen;
		}
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;

		return;
	}

	// it is possible for a player to die and respawn between rots, so don't
	// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};

/*===============================================================================

ARMOR

===============================================================================*/

void() armor_touch =
{
	local	float	type, value, bit;
	local string str;

	type = 1;
	value = 100;
	bit = IT_ARMOR1;
	
	if (other.health <= 0)
		return;

	if (other.classname != "player")
		return;

	if (self.classname == "item_armor1")
	{
		type = 1;
		value = 50;
		bit = IT_ARMOR1;
		str = "You got the light armor\n";
	}

	if (self.classname == "item_armor2")
	{
		type = 2;
		value = 100;
		bit = IT_ARMOR2;
		str = "You got the combat armor\n";
	}

	if (self.classname == "item_armorInv")
	{
		type = 3;
		value = 200;
		bit = IT_ARMOR3;
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

	other.armortype = 1;
	if (type == 1)
	{
		other.armorvalue += value;
		other.armorvalue = min(100, other.armorvalue);
	}
	else other.armorvalue = value;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

	self.solid = SOLID_NOT;
	self.model = string_null;

	if (deathmatch == 1)
		self.nextthink = time + 20;

	self.think = SUB_regen;

	//sprint(other, "You got armor\n");
	sprint(other, str);
	// armor touch sound
	if (random() > 0.5)
		sound(other, CHAN_ITEM, "items/armorvest1.wav", 1, ATTN_NORM);
	else
		sound(other, CHAN_ITEM, "items/armorvest2.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfar\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
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

void() bound_other_ammo =
{
	if (other.ammo_shells > MAX_SHELLS)
		other.ammo_shells = MAX_SHELLS;

	if (other.ammo_nails > MAX_NAILS)
		other.ammo_nails = MAX_NAILS;

	if (other.ammo_rockets > MAX_ROCKETS)
		other.ammo_rockets = MAX_ROCKETS;		

	if (other.ammo_cells > MAX_CELLS)
		other.ammo_cells = MAX_CELLS;
	
	if (other.ammo_bullets > MAX_BULLETS)
		other.ammo_bullets = MAX_BULLETS;
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
	local	float	hadammo, new, old;
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

		hadammo = other.ammo_nails;			
		new = IT_SMGS;
		other.ammo_nails = other.ammo_nails + 30;
	}

	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && (other.items & IT_CHAINGUN) )
			return;

		hadammo = other.ammo_rockets;			
		new = IT_CHAINGUN;
		other.ammo_bullets = other.ammo_bullets + 21;
	}

	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && (other.items & IT_SUPER_SHOTGUN) )
			return;

		hadammo = other.ammo_rockets;			
		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 10;
	}

	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && (other.items & IT_GAUSS) )
			return;

		hadammo = other.ammo_rockets;			
		new = IT_GAUSS;
		other.ammo_cells = other.ammo_cells + 10;
	}

	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && (other.items & IT_GRENADE_LAUNCHER) )
			return;

		hadammo = other.ammo_rockets;			
		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 6;
	}

	else if (self.classname == "weapon_lightning")
	{
		if (leave && (other.items & IT_SHOCK) )
			return;

		hadammo = other.ammo_rockets;			
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

void() ammo_touch =
{
	float deficit;
	if (!(other.flags & FL_CLIENT))
		return;

	if (other.health <= 0)
		return;
	
	if (self.fA > time) // just took from the box, wait a bit
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
	sprint (other, ftos(deficit));
	sprint (other, " ");
	sprint (other, self.netname);
	sprint (other, "\n");
	// ammo touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// if changed current ammo, update it
	setAmmo(other);
	
	if (!(self.sprawlflags & SFLI_TARGETSFIRED))
	{
	// fire all targets / killtargets
		activator = other;
		SUB_UseTargets();				
		self.sprawlflags |= SFLI_TARGETSFIRED;
	}
	
	if (self.aflag > 0)
	{
		// next time we can touch this
		self.effects |= EF_NOLERP;
		self.fA = time + 0.5;
		return;
	}
		
	// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;

	if (deathmatch == 1)
	{
		self.nextthink = time + 30;
		self.think = SUB_regen;
	}
	else
	{
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
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
		self.aflag = 16;
		self.frame = 0; // 16 - 0
	}

	else
	{
		self.aflag = 8;
		self.frame = 8; // 16 - 8
	}

	self.weapon = 1;
	self.netname = "shotgun shells";
	setsize (self, '0 0 0', '32 32 56');
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
		self.aflag = 100;
	}

	else
	{
		setmodel (self, "progs/ammo/nails.mdl");
		self.aflag = 50;
	}

	self.weapon = 2;
	self.netname = ".45 ACP-AP rounds";
	setsize (self, '0 0 0', '32 32 56');
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
		self.aflag = 6;
		self.frame = 0; // 6 - 0
	}
	else
	{
		self.aflag = 2;
		self.frame = 4; // 6 - 4
	}

	self.weapon = 3;
	self.netname = "40mm grenades";
	setsize (self, '0 0 0', '32 32 56');
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
		self.aflag = 9; // cells provide x3 charges per battery
		self.frame = 0; // 3 - 0
	}

	else
	{
		self.aflag = 3;
		self.frame = 2; // 3 - 2
	}

	self.weapon = 4;
	self.netname = "energy cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_bullets (0 .5 .8) (0 0 0) (32 32 32) big*/

void() item_bullets =
{
	self.touch = ammo_touch;

	precache_model ("progs/ammo/bullets.mdl");
	setmodel (self, "progs/ammo/bullets.mdl");
	
	if (self.spawnflags & WEAPON_BIG2)
		self.aflag = 40;
	else
		self.aflag = 20;

	self.weapon = 5;
	self.netname = ".50 BMG rounds";
	setsize (self, '0 0 0', '32 32 56');
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

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/

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

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base*/

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



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

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


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

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

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{

	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

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
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

	// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}	

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
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

/*
	// if the player was using his best weapon, change up to the new one if better  
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;
*/

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
	
	// change to the weapon
	/*
		if (self.flags & FL_INWATER)
		{
			if (new != IT_SHOCK)
			{
				Deathmatch_Weapon (old, new);
			}
		}

		else
		{                
			Deathmatch_Weapon (old, new);
		}
	*/
	//W_SetCurrentAmmo ();

};


/*===============
DropBackpack
===============*/
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

#define DROP_SHELLS 1
#define DROP_NAILS 2
#define DROP_ROCKETS 3
#define DROP_CELLS 4
#define DROP_BULLETS 5

void(vector pos, float type, float easy, float normal, float hard, float nightmare) dropAmmo =
{
	entity item;
	float amount;
	
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
			other.ammo_shells = min(other.ammo_shells, MAX_SHELLS);
			break;
		case DROP_NAILS:
			if (other.ammo_nails < MAX_NAILS)
				other.ammo_nails += self.ammo_nails;
			else 
				return;
			other.ammo_nails = min(other.ammo_nails, MAX_NAILS);
			break;
		case DROP_ROCKETS:
			if (other.ammo_rockets < MAX_ROCKETS)
				other.ammo_rockets += self.ammo_rockets;
			else 
				return;
			other.ammo_rockets = min(other.ammo_rockets, MAX_ROCKETS);
			break;
		case DROP_CELLS:
			if (other.ammo_cells < MAX_CELLS)
				other.ammo_cells += self.ammo_cells;
			else 
				return;
			other.ammo_cells = min(other.ammo_cells, MAX_CELLS);
			break;
		case DROP_BULLETS:
			if (other.ammo_bullets < MAX_BULLETS)
				other.ammo_bullets += self.ammo_bullets;
			else 
				return;
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
	
	if (!self.fA && other.health >= 100) // overheal not allowed
		return;
	
	other.health += self.health;
	if (!self.fA)
	{
		if (other.health > 100)
			other.health = 100;
	}

	sound (other, CHAN_ITEM, "items/health2.wav", 1, ATTN_NORM);
	stuffcmd (other, "bfh\n");
	SUB_Remove();
};

void() armor_drop_touch =
{
	if (!(other.flags & FL_CLIENT))
		return;
	
	if (!self.fA && other.armorvalue >= 100) // overheal not allowed
		return;
	
	other.armorvalue += self.health;
	other.armortype = 1;
	if (!self.fA)
	{
		if (other.armorvalue > 100)
			other.armorvalue = 100;
	}
	
	removeflag(other.items, IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);

	if (other.armorvalue < 50)
		other.items |= IT_ARMOR1;
	else if (other.armorvalue > 100)
		other.items |= IT_ARMOR3;
	else
		other.items |= IT_ARMOR2;

	//other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
	if (self.health == 1)
		sound (other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	else 
	{
		if (random() > 0.5)
			sound (other, CHAN_ITEM, "items/armor2.wav", 1, ATTN_NORM);
		else
			sound (other, CHAN_ITEM, "items/armor3.wav", 1, ATTN_NORM);
	}
	stuffcmd (other, "bfar\n");
	SUB_Remove();
};