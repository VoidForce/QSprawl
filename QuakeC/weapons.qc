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

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

void(vector x, vector y, vector z, float relax) makePunch =
{
	self.punch_fast += [-x_x, y_x, z_x];
	self.punch_normal += [-x_y, y_y, z_y];
	self.punch_slow += [-x_z, y_z, z_z];
	self.punch_time = time;
	self.punch_relaxtime = time + relax;
};

/*void() initGrenadeList =
{
	local entity head;

// this shouldn't suppose to happen but we play safe
	if (!grenade_handler)
		grenade_handler = spawn();
	
	grenade_handler.list_previous = world; //reset 
	
	head = findfloat(isgrenade, 1);
	grenade_handler.list_next = head;
	while (head)
	{
		head.list_next = head.chain;
		if (head.chain) // in case of the null
			head.chain.list_previous = head;
		head = head.chain;
	}
};*/

// insert to the beggining, works with 0 objects in the list
void(entity new) appendToList =
{
	new.list_previous = world; // be sure to erase any info here
	if (grenade_handler.list_next)
		grenade_handler.list_next.list_previous = new; // <-
	new.list_next = grenade_handler.list_next; // ->
	grenade_handler.list_next = new; // new became head
};

void(entity who) removeFromList =
{
	if (!who.isgrenade)
		return;

	if (who.list_previous)
		who.list_previous.list_next = who.list_next; // connect -> // works with null too
	else
		grenade_handler.list_next = who.list_next; // ok we were the very first item in the list, update handler
	if (who.list_next)
		who.list_next.list_previous = who.list_previous; // connect <- // works with null
	
	who.list_next = world;
	who.list_previous = world;
	who.isgrenade = 0; // don't let it back again with list init search
};

void(vector direction, float hitdistance) checkCollision
{
	entity head;
	entity next;
	float distance;
	vector gunpoint;
	
	if (!grenade_handler.list_next)
		return;

	gunpoint = getGunPoint(self);
	head = grenade_handler.list_next;
	while (head)
	{
		distance = DistanceToLine(gunpoint, direction, head.origin);
		next = head.list_next;// we will remove head in case of success so, keep the chain
		if (distance < hitdistance)
		{
			
			traceline(gunpoint, gunpoint + direction * vlen(head.origin - gunpoint), FALSE, self);
			if (trace_fraction > 0.95)
			{
				removeFromList(head);
				if (head.classname == "grenade")
					head.think = GrenadeExplode;
				else
					head.think = OgreGrenadeExplode;
				head.nextthink = time;
			}
		}
		head = next;
	}
};
vector(entity who) getGunPoint =
{
	return [who.origin_x, who.origin_y, who.origin_z + who.view_ofs_z];
};
/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors	(self.v_angle + self.punchangle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*96, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 30);
	}

	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors2 (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
	// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;

	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}

	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread, float damage) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors	(self.v_angle + self.punchangle);

	src = self.origin + v_forward*10;
	src_z = self.origin_z + self.view_ofs_z;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (damage, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

void(vector dir, float offset_x, float offset_y, float damage) FireBulletAim =
{
	local	vector direction;
	local	vector	src;
	
	makevectors	(self.v_angle + self.punchangle);

	src = self.origin + v_forward*10;
	src_z = self.origin_z + self.view_ofs_z;

	direction = dir + offset_x*v_right + offset_y*v_up;

	traceline (src, src + direction*2048, FALSE, self);
	if (trace_fraction != 1.0)
		TraceAttack (damage, direction);
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x -= 10;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0', 4);
};

void() W_FirePistol =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (1, dir, '0 0 0', 40);
	checkCollision(dir, 32);
	makePunch([4,6,2],[crandom()*2,crandom()*3,0],[0,0,0],0.0);
};

/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;
	local float i;
	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	
	ClearMultiDamage ();
	for (i = 0; i < 14; i++)
		FireBulletAim (dir, SSGX[i]*0.2, SSGY[i]*0.2, 10);
	ApplyMultiDamage ();
	checkCollision(dir, 48);
	makePunch([8,2,1],[1+random()*2,-3*random()*3,3],[crandom()*3,0,0],0.2);
};

void(float leftgun) W_FireSMG =
{
	local vector dir;
	local float seedx,seedy;
	
	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
	if (leftgun)
		launchCasing(self.origin, v_forward * 24 + v_right * -8 + v_up * (self.view_ofs_z - 8), 0);
	else
		launchCasing(self.origin, v_forward * 24 + v_right * 15 + v_up * (self.view_ofs_z - 8), 0);
	//case_shell.mdl
	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 100000);
	FireBullets (1, dir, '0.02 0.02 0', 10);
	checkCollision(dir, 16);

	seedx = rint(random()*8);
	seedy = CIRCLEY[seedx];
	seedx = CIRCLEX[seedx];
	makePunch([seedx,seedx*2,0.5],[seedy,seedy*1.5,0],[0,crandom()*0.5,0],0.1);
};

void() W_FireGauss =
{
	local float timetoend;
	local	vector	vel, org, dir, src,  destination, loopsrc;
	local entity thedude;

	makevectors(self.v_angle);
	
	sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	
	org = self.origin + '0 0 16';

	dir = v_forward;
	src = self.origin + v_forward * 10;
	src_z = self.origin_z + self.view_ofs_z;
	destination = src + (dir * 1536);
		
	loopsrc = src;
	thedude = self;
	
	while ( !timetoend )
	{
		traceline (loopsrc, destination, FALSE, thedude);
		if (trace_fraction != 1.0)
		{
			vel = normalize(dir);
			vel = vel + 2 * trace_plane_normal;
			vel = vel * 200;

			org = trace_endpos - dir*4;

			if (trace_ent.takedamage && trace_ent.sprawlflags & SFL_MONSTER)
			{
				thedude = trace_ent;
				SpawnBlood (org, vel*0.2, 200);
				T_Damage (trace_ent, self, self, 240);
				loopsrc = trace_endpos + (dir * 2);
			}
			else
			{
				if (trace_ent.takedamage)
					T_Damage (trace_ent, self, self, 100); // buttons etc
					particle (org, trace_plane_normal * 300, 8, 50);
				
				timetoend = 1;
			}
		}
		else 
			timetoend = 1;
	}
	makePunch([4,6,2],[crandom()*2,crandom()*3,0],[0,0,0],0.0);
};
/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};



/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
	// set missile speed	
	makevectors	(self.v_angle + self.punchangle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
	// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}

	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}

	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local   float           cells;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
	
	// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world);
		return;
	}
	
	makevectors(self.v_angle);
	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	org = self.origin + v_forward*24 + v_right*8;
	org_z += self.view_ofs_z - 6;
	//org = [24, 8, self.view_ofs_z - 6]; // forward, right, verticall offset
	
	traceline (org, org + v_forward*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================


void() GrenadeExplode =
{
	removeFromList(self);
	T_RadiusDamage (self, self.owner, 120, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors	(self.v_angle + self.punchangle);
	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
	missile.isgrenade = 1;
	appendToList(missile);
	makePunch([3,4,4],[0,crandom()*2,0],[0,0,0],0.2);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.classname = "super_spike";	//so we know the difference --gnounc
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	
	local float seedx,seedy;
	seedx = rint(random()*12);
	seedy = CIRCLEY[seedx];
	seedx = CIRCLEX[seedx];
	makePunch([seedx*4,seedx*2,random()*(-2)],[seedy*4 + crandom() * 4,seedy*2 + crandom() * 4,0],[0,crandom()*2,0],0.1);
};

void(vector porigin, vector poffset, float ptype) launchCasing =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_NOT;
	newmis.angles = [random()*360, random()*360, random()*360];
	newmis.avelocity = [random()*100, random()*100, random()*100];
	newmis.touch = SUB_Null;
	newmis.classname = "casing";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 2;
	setmodel (newmis, "progs/case_shell.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN); // 0 0 0		
	setorigin (newmis, porigin + poffset);
	if (!ptype)
		newmis.velocity = v_forward * crandom() * 5 + v_right * (200 + crandom()*50) + v_up * (200 + crandom()*100);
	else
		newmis.velocity = v_forward * random() * 20 + v_right * (100 + random()*50) + v_up * (300 + crandom()*100);
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	
	makevectors	(self.v_angle + self.punchangle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};

void() spike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}

	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizard_spike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);

		else if (self.classname == "knight_spike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);

		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);

		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	if (self.sprawlflags & SFL_RESETWEAPONFRAME)
	{
		player_run ();		// get out of any weapon firing states
		self.weaponframe = 0;
		self.sprawlflags -= self.sprawlflags & SFL_RESETWEAPONFRAME;
	}

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = string_null;
	}
	
	self.quickmelee_model = self.weaponmodel;
	self.quickmelee_weapon = self.weapon;
};

float() W_BestWeapon =
{
	local	float	it;
	
	it = self.items;

	if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
		return IT_LIGHTNING;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;

	return IT_AXE;
};
//gnounc
//wanted to get rid of the horrible triple negative when reading the call to checkNoAmmo. 
//also it was unclear what checkNoAmmo should return for no ammo
float() W_hasNoAmmo =
{
	if (self.currentammo)
		return FALSE;	//player has ammo	--gnounc

	if (self.weapon == IT_AXE)
		return FALSE;	//the axe doesnt need ammo. so we lie. Player Totally has ammo..Promise! --gnounc
	
	W_DelpoyGun(W_BestWeapon ());
	
	// drop the weapon down
	return TRUE;
};


/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;

void() W_Attack =
{
	//local	float	r;

	if (W_hasNoAmmo())
		return;
	
	makevectors	(self.v_angle + self.punchangle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		katanaSwingStart();
		/*r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();*/
		self.attack_finished = time + 0.5;
	}

	else if (self.weapon == IT_SHOTGUN)
	{
		if (self.pistol_finished > time ) 
			return;
		
		if (self.sprawlflags & SFL_SEMIAUTO && (self.pistol_finished + 0.3 > time))
			return;
		
		self.sprawlflags |= SFL_SEMIAUTO;
		animatePistolFire();
		W_FirePistol ();
		
		self.pistol_finished = time + 0.3;
		self.attack_finished = time + 0.15;
	}

	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		if (self.shotgun_finished > time ) 
			return;
		//player_shot1 ();
		if (!self.wallrun) 
			self.velocity += normalize(v_forward) * (-400);
			
		animateShotgunFire();
		W_FireSuperShotgun ();
		self.shotgun_finished = time + 1.2;
		self.attack_finished = time + 0.35;
	}

	else if (self.weapon == IT_NAILGUN)
	{
		animateSMGFire();
		self.attack_finished = time + 0.05;
		//player_nail1 ();
	}

	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}

	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		if (self.grenade_finished > time ) 
			return;

		animateGrenadeFire();
		W_FireGrenade();
		self.grenade_finished = time + 0.6;
		self.attack_finished = time + 0.3;
	}

	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		if (self.gauss_finished > time ) 
			return;

		heatupGauss();
	}

	else if (self.weapon == IT_LIGHTNING)
	{
		self.weaponframe = 1;
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
};

void() W_ResetFlags =
{
	self.sprawlflags -= self.sprawlflags & (SFL_SEMIAUTO | SFL_LEFTHAND | SFL_INQUICKMELEE | SFL_STOPMELEE | SFL_HOLD);
};
void(float gun) W_DelpoyGun =
{
	self.sprawlflags |= SFL_RESETWEAPONFRAME;
	W_ResetFlags();
	self.weapon = gun;
	W_SetCurrentAmmo ();
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	fl = it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
		fl = IT_AXE;
	}

	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;

		if (self.ammo_shells < 1)
			am = 1;
	}

	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;

		if (self.ammo_shells < 2)
			am = 1;
	}		

	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;

		if (self.ammo_nails < 1)
			am = 1;
	}

	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;

		if (self.ammo_nails < 2)
			am = 1;
	}

	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;

		if (self.ammo_rockets < 1)
			am = 1;
	}

	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}

	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	if (self.weapon != fl)
		W_DelpoyGun(fl);
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;
	self.sprawlflags |= SFL_RESETWEAPONFRAME;
	W_DelpoyGun(IT_ROCKET_LAUNCHER);
	self.impulse = 0;
	//W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am, w;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			w = IT_AXE;
		}

		else if (self.weapon == IT_AXE)
		{
			w = IT_SHOTGUN;

			if (self.ammo_shells < 1)
				am = 1;
		}

		else if (self.weapon == IT_SHOTGUN)
		{
			w = IT_SUPER_SHOTGUN;

			if (self.ammo_shells < 2)
				am = 1;
		}		

		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			w = IT_NAILGUN;

			if (self.ammo_nails < 1)
				am = 1;
		}

		else if (self.weapon == IT_NAILGUN)
		{
			w = IT_SUPER_NAILGUN;

			if (self.ammo_nails < 2)
				am = 1;
		}

		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			w = IT_GRENADE_LAUNCHER;

			if (self.ammo_rockets < 1)
				am = 1;
		}

		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			w = IT_ROCKET_LAUNCHER;

			if (self.ammo_rockets < 1)
				am = 1;
		}

		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			w = IT_LIGHTNING;

			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if (self.weapon != w)
			W_DelpoyGun(w);
			
		if ( (self.items & w) && am == 0 )
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local float it, am, w;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			w = IT_ROCKET_LAUNCHER;

			if (self.ammo_rockets < 1)
			am = 1;
		}
	
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			w = IT_GRENADE_LAUNCHER;

			if (self.ammo_rockets < 1)
			am = 1;
		}

		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			w = IT_SUPER_NAILGUN;

			if (self.ammo_nails < 2)
			am = 1;
		}

		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			w = IT_NAILGUN;

			if (self.ammo_nails < 1)
			am = 1;
		}

		else if (self.weapon == IT_NAILGUN)
		{
			w = IT_SUPER_SHOTGUN;

			if (self.ammo_shells < 2)
			am = 1;
		}

		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			w = IT_SHOTGUN;

			if (self.ammo_shells < 1)
			am = 1;
		}

		else if (self.weapon == IT_SHOTGUN)
		{
			w = IT_AXE;
		}

		else if (self.weapon == IT_AXE)
		{
			w = IT_LIGHTNING;

			if (self.ammo_cells < 1)
			am = 1;
		}

		if (self.weapon != w)
			W_DelpoyGun(w);
			
		if ( (self.items & w) && am == 0 )
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;

	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();
	if (self.impulse == 9)
		CheatCommand ();
	if (self.impulse == 10)
		CycleWeaponCommand ();
	if (self.impulse == 11)
		ServerflagsCommand ();
	if (self.impulse == 12)
		CycleWeaponReverseCommand();
	if (self.impulse == 255)
		QuadCheat ();
		
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	//dprint("flags = ");
	//dprint(ftos(self.sprawlflags));
	//dprint("\n");
	/*
	if (self.b_attack2)
	{
		dprint("Attack2\n");
	}
	if (self.b_kick)
	{
		dprint("Kick\n");
	}
	if (self.b_reload)
	{
		dprint("Reload\n");
	}
	*/
	if (self.sprawlflags & SFL_INQUICKMELEE)
		return;
	
// quickmelee button suppose to work as semi-auto and perform only one action per press
	if (!self.b_melee) 
		self.sprawlflags -= self.sprawlflags & SFL_STOPMELEE;
	
	if (self.b_melee && !(self.sprawlflags & SFL_STOPMELEE))
	{
		if (self.weapon == IT_AXE && time > self.attack_finished)
		{
			sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
			katanaSwingStart();
			self.attack_finished = time + 0.5;
		// this is copy paste, should it be a separate method?
		}
		else
		{
			quickMeleeStart();
		}
	}
	
	if (self.impulse)	// gb, stop wasting performance
		ImpulseCommands ();
	
	if (self.sprawlflags & SFL_HOLD)
	{
		if (self.button0)
			return;
		else
			self.sprawlflags -= self.sprawlflags & SFL_HOLD;
	}
		
	if (time < self.attack_finished)
		return;
	
	// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


