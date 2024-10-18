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

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/r_exp3_far.wav");	// new rocket explosion
	
	precache_sound ("weapons/f_pistol.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	
	// sprawl special
	precache_sound ("weapons/f_chaingun.wav");	// super spikes
	precache_sound ("weapons/chaingun_loop.wav"); //spin motor sounds
	precache_sound ("weapons/chaingun_wu.wav");
	precache_sound ("weapons/chaingun_wd.wav");
	precache_sound ("silence.wav");
	precache_sound ("weapons/f_grenade.wav");	// grenade launcher
	precache_sound ("weapons/f_grenade_far.wav");	// grenade launcher
	//precache_sound ("weapons/f_shotgun.wav");	// super shotgun
	precache_sound ("weapons/f_shotgun.wav");	// super shotgun
	//precache_sound ("weapons/f_shotgun2.wav");	// super shotgun
	precache_sound ("weapons/f_gauss.wav");
	precache_sound ("weapons/f_vector1.wav");	// smg
	precache_sound ("weapons/f_vector2.wav");	// smg
	precache_sound ("weapons/f_vector3.wav");	// smg
	precache_sound ("weapons/f_vector4.wav");	// smg
	precache_sound ("weapons/static.wav"); // shock static discharge
	
	precache_sound ("weapons/gauss_charge1.wav");
	precache_sound ("weapons/gauss_charge2.wav");
	precache_sound ("weapons/gauss_charge3.wav");
	precache_sound ("weapons/gauss_charge4.wav");
	precache_sound ("weapons/gauss_charge5.wav");
	
	precache_sound ("weapons/deploy_chaingun.wav");
	precache_sound ("weapons/deploy_gauss.wav");
	precache_sound ("weapons/deploy_grenade.wav");
	precache_sound ("weapons/deploy_katana.wav");
	precache_sound ("weapons/deploy_pistol.wav");
	precache_sound ("weapons/deploy_shock.wav");
	precache_sound ("weapons/deploy_shotgun.wav");
	precache_sound ("weapons/deploy_smgs.wav");
};

void(float gun) playDeploySound =
{
	switch (gun)
	{
		case IT_KATANA:
			sound (self, CHAN_ITEM, "weapons/deploy_katana.wav", 1, ATTN_NORM);
			break;
		case IT_PISTOL:
			sound (self, CHAN_ITEM, "weapons/deploy_pistol.wav", 1, ATTN_NORM);
			break;
		case IT_SUPER_SHOTGUN:
			sound (self, CHAN_WEAPON, "weapons/deploy_shotgun.wav", 1, ATTN_NORM);
			break;
		case IT_SMGS:
			sound (self, CHAN_ITEM, "weapons/deploy_smgs.wav", 1, ATTN_NORM);
			break;
		case IT_CHAINGUN:
			sound (self, CHAN_ITEM, "weapons/deploy_chaingun.wav", 1, ATTN_NORM);
			break;
		case IT_GRENADE_LAUNCHER:
			sound (self, CHAN_ITEM, "weapons/deploy_grenade.wav", 1, ATTN_NORM);
			break;
		case IT_GAUSS:
			sound (self, CHAN_ITEM, "weapons/deploy_gauss.wav", 1, ATTN_NORM);
			break;
		case IT_SHOCK:
			sound (self, CHAN_ITEM, "weapons/deploy_shock.wav", 1, ATTN_NORM);
			break;		
	}
};

void(vector x, vector y, vector z) makePunch =
{
	self.punch_fast += [-x_x, y_x, z_x];
	self.punch_normal += [-x_y, y_y, z_y];
	self.punch_slow += [-x_z, y_z, z_z];
	self.punch_time = time;
};

void(float x, float y, float z) addPunchVelocity =
{
	self.punchvelocity_x += x;
	self.punchvelocity_y += y;
	self.punchvelocity_z += z;
};

void(float x, float y, float z, entity who) addPunchVelocityEnt =
{
	who.punchvelocity_x += x;
	who.punchvelocity_y += y;
	who.punchvelocity_z += z;
};

void(float x, float y, float z) setPunchVelocity =
{
	self.punchvelocity_x = x;
	self.punchvelocity_y = y;
	self.punchvelocity_z = z;
};

void(float x, float y, float z) addShake =
{
	self.shakevelocity_x += x;
	self.shakevelocity_y += y;
	self.shakevelocity_z += z;
};

vector(float fwd, float right, float vertical) offsetWeapon =
{
	vector offset;
	makevectors(self.v_angle + self.punchangle);
	offset = self.origin + v_forward * fwd + v_right * right;
	offset_z += self.view_ofs_z + vertical;
	return offset;
};

void() resetFlags =
{
	self.sprawlflags -= self.sprawlflags & (SFL_SEMIAUTO | SFL_LEFTHAND | SFL_HOLD | SFL_SPRINT); //SFL_INQUICKMELEE | SFL_STOPMELEE | 
	self.engineflags |= ENF_CHANGESKIN;
	self.weapon_skin = 0;
};

void(float gun) deployGun =
{
	self.lastweapon = self.weapon;
	if (self.weapon == IT_CHAINGUN)
	{
		self.chaingun_speed = 0.1;
		sound (self, 5, "silence.wav", 1, ATTN_NORM); // shutup spin leftover
	}
	self.deploy_time = time;
	
	self.viewmodeloffset_angles_x = -60;
	self.viewmodeloffset_angles_z = -30;
	addPunchVelocity(40, 0, 0);
	
	playDeploySound(gun);
	
	self.attack_finished = time + 0.25;
	
	if (self.shotgun_finished > time)
		self.shotgun_finished = time + 0.4;
	
	self.sprawlflags |= SFL_RESETWEAPONFRAME | SFL_VMOFFSET;
	
	resetFlags();
	
	if (gun == IT_KATANA || self.weapon == IT_KATANA)
		self.sprawlflags |= SFL_NEEDTOSETSPEED;
	
	self.weapon = gun;
	
	if (gun == IT_CHAINGUN)
		self.weaponframe = self.chaingun_frame;
	
	W_SetCurrentAmmo ();
};

void() initGrenadeList =
{
	entity head;

// this shouldn't suppose to happen but we play safe
	if (!grenade_handler)
		grenade_handler = spawn();
	
	grenade_handler.list_previous = world; //reset 
	
	head = findfloat(isgrenade, 1);
	if (!(head))
		return;
	grenade_handler.list_next = head;
	while (head)
	{
		head.list_next = head.chain;
		if (head.chain) // in case of the null
			head.chain.list_previous = head;
		head = head.chain;
	}
};

// insert to the begining, works with 0 objects in the list
void(entity new) appendToList =
{
	if (!new)
	{
		dprint("\n WORLD in Append\n");
		return;
	}
	new.isgrenade = 1;

	/*
	dprint("\n Append to the list \n");
	float i;
	entity head;
	head = grenade_handler;
	while (head)
	{
		i++;
		dprint3("Ent ",ftos(i),":\n");
		dprint3("head is: ",head.classname,"\n");
		dprint3("previous: ",head.list_previous.classname,"\n");
		dprint3("next: ",head.list_next.classname,"\n");
		head = head.list_next;
	}
	*/
	
	if (grenade_handler.list_next)
	{
		new.list_next = grenade_handler.list_next; // ->
		new.list_next.list_previous = new;// <-
	}
	grenade_handler.list_next = new; // new became head
	new.list_previous = grenade_handler;
	if (new == new.list_next || new == new.list_previous)
	{
		dprint("appendToList: New loops to itself\n");
		new.list_next = world;
		new.list_previous = world;
	}
};

void(entity who) removeFromList =
{
	if (!who || who == who.list_next || who == who.list_previous || !who.isgrenade)
	{
		dprint("\n Wrong grenade list remove, rebuilding\n");
		initGrenadeList();
		return;
	}

	/*
	dprint("\n Remove from the list \n");
	float i;
	entity head;
	head = grenade_handler;

	while (head)
	{
		i++;
		dprint3("Ent ",ftos(i),":\n");
		dprint3("head is: ",head.classname,"\n");
		dprint3("previous: ",head.list_previous.classname,"\n");
		dprint3("next: ",head.list_next.classname,"\n");
		head = head.list_next;
	}
	*/
	if (who.list_previous)
		who.list_previous.list_next = who.list_next; // connect -> // works with null too

	if (who.list_next)
		who.list_next.list_previous = who.list_previous; // connect <- // works with null
	
	who.list_next = world;
	who.list_previous = world;
	who.isgrenade = 0;
};

void(vector direction, float hitdistance) checkGrenadeCollision
{
	entity head;
	entity next;
	float distance;
	vector gunpoint;
	float i;
	
	if (!grenade_handler.list_next)
		return;

	gunpoint = getGunPoint(self);
	head = grenade_handler.list_next;
	i = 0;
	while (head)
	{
		i++;
	
		next = head.list_next;// we will remove head in case of success so, keep the chain
		if (head.isgrenade) //safety check
		{
			distance = distancetoray(gunpoint, direction, head.origin);
			if (distance < hitdistance)
			{
				traceline(gunpoint, gunpoint + direction * vlen(head.origin - gunpoint), FALSE, self);
				if (trace_fraction > 0.95)
				{
					if (head.owner.flags & FL_CLIENT)
					{
						head.think = GrenadeExplode;
						head.nextthink = time;
					}
					else if (head.sprawlflags & SFLP_OGRE)
					{
						head.think = OgreGrenadeExplode;
						head.nextthink = time;
					}
					else if (head.classname == "plasma")
					{
						head.think = ShalGrenadeExplode;
						head.nextthink = time;
					}
					else
					{
						dprint("\n\n Non-grenade entity in the list \n\n");
						head.list_next = world;
						head.list_previous = world;
						head.isgrenade = 0;
						initGrenadeList();
						return;
					}
				}
			}
		}
		
		head = next;
		if (i > 1024)
		{
			dprint("i > 1024, Loop runaway in checkGrenadeCollision\n");
			initGrenadeList();
			return;
		}
	}
};

vector(entity who) getGunPoint =
{
	return [who.origin_x, who.origin_y, who.origin_z + who.view_ofs_z];
};

void(vector porigin, vector poffset, float ptype) launchCasing =
{
	newmis = spawn ();
	newmis.clip = CLIP_PROJECTILE;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_NOT;
	newmis.angles = [random()*360, random()*360, random()*360];
	newmis.avelocity = [random()*100, random()*100, random()*100];
	newmis.touch = SUB_Null;
	newmis.classname = "casing";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 2;
	switch (ptype)
	{
		case 2:
			setmodel (newmis, "progs/case_mg.mdl");
			break;
		case 1:
			setmodel (newmis, "progs/case_shell.mdl");
			break;
		case 0:
			setmodel (newmis, "progs/case_pistol.mdl");
			break;
	}

	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN); // 0 0 0		
	setorigin (newmis, porigin + poffset);
	if (!ptype)
		newmis.velocity = v_forward * crandom() * 5 + v_right * (200 + crandom()*50) + v_up * (200 + crandom()*100);
	else
		newmis.velocity = v_forward * random() * 20 + v_right * (100 + random()*50) + v_up * (300 + crandom()*100);
};

vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};

void(vector org, vector vel, entity targ) SpawnMeatSpray =
{
	entity gib;

	gib = spawn ();
	gib.clip = CLIP_PROJECTILE;
	gib.owner = self;
	gib.movetype = MOVETYPE_BOUNCE;
	gib.solid = SOLID_NOT;

	makevectors2 (self.angles);

	gib.velocity = vel;
	gib.velocity_z = gib.velocity_z + 250 + 50*random();

	gib.avelocity = '3000 1000 2000';
	
	// set gib duration
	gib.nextthink = time + 1;
	gib.think = SUB_Remove;
	if (targ.flags & FL_CLIENT)
		setmodel (gib, "progs/smallgib.mdl");
	else
	{
		if (targ.monsterflags & MFL_SYNTH)
			setmodel (gib, "progs/smallgib_synth.mdl");
		else if (targ.monsterflags & MFL_ROBOT)
		{
			float r = random();
			if (r < 0.3)
				setmodel (gib, "progs/m_gib_02.mdl");
			else if (r > 0.6)
				setmodel (gib, "progs/m_gib_04.mdl");
			else 
				setmodel (gib, "progs/m_gib_05.mdl");
		}
		else
			setmodel (gib, "progs/smallgib.mdl");
	}
		
	setsize (gib, '0 0 0', '0 0 0');		
	setorigin (gib, org);
};

void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};

void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};
//-----------------------------------
void() ClearMultiDamage =
{
	local entity chain;
	
	if (!multi_head)
		return;
	
	chain = multi_head;
	while (chain)
	{
		chain.multi_damage = VEC_ORIGIN; // 0 0 0
		
		if (chain.multi_chain)
		{
			multi_head = chain.multi_chain;
			chain.multi_chain = world;
			chain = multi_head;
		}
		else 
		{
			chain = world;
			multi_head = world;
		}
	}
};

void() ApplyMultiDamage =
{
	local entity chain;

	if (!multi_head)
		return;
	
	chain = multi_head;
	while (chain)
	{
	// head damage first
		if (chain.multi_damage[M_HEAD])
			T_Damage (chain, self, self, chain.multi_damage[M_HEAD], DF_HEADSHOT, SHOTGUN_PENETRATION, chain.multi_damage[M_COUNT]);
			
		if (chain.multi_damage[M_BODY])
		{
			T_Damage (chain, self, self, chain.multi_damage[M_BODY], 0, SHOTGUN_PENETRATION, chain.multi_damage[M_COUNT]);
			T_PushDirection(chain, chain.lasthit_direction, chain.multi_damage[M_COUNT] * 30); 
		}
		
		chain.multi_damage = VEC_ORIGIN; // 0 0 0
		chain = chain.multi_chain;
	}

	ClearMultiDamage();
};

void(entity hit, float damage, float ishead) AddMultiDamage =
{
	local entity chain;
	
// no ents in the list
	if (!multi_head)
	{
		multi_head = hit;
		goto multidamageadd;
	}

	chain = multi_head;
// search if our intended target is in the list, add to it if so
	while (chain)
	{
		if (chain == hit)
			goto multidamageadd;
		
		chain = chain.multi_chain;
	}
	
// no match found, insert new member in front
	hit.multi_chain = multi_head;
	multi_head = hit;
	
	multidamageadd:
	if (ishead)
		multi_head.multi_damage[M_HEAD] += damage;
	else
		multi_head.multi_damage[M_BODY] += damage;
		multi_head.multi_damage[M_COUNT]++;
};

//--------------------
void(float damage, vector dir) TraceAttack =
{
	if (trace_ent.takedamage)
		AddMultiDamage (trace_ent, damage,0);
	else
		sendMessageImpact(trace_endpos, trace_plane_normal, IMPACT_WALL, VEC_ORIGIN); 
};

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

#define FBA_ISMULTIDAMAGE 1
//#define FBA_GRENADE 2
#define FBA_IMPACT 8
#define FBA_NOSHIELD_IMPACT 16
//  DF_ALWAYSGIB 4

void(vector dir, float offset_x, float offset_y, float damage, float penetration, float lflags) FireBulletAim =
{
	vector direction;
	vector src, head_origin;
	float dflags;
	float head_size_factor;
	
	makevectors	(self.v_angle + self.punchangle);
	
// offset of source point
	src = self.origin;
	src_z = self.origin_z + self.view_ofs_z;
// offset for shotgun
	if (offset_x || offset_y)
		direction = normalize(dir + offset_x*v_right + offset_y*v_up);
	else
		direction = dir;
// trace
	traceline (src, src + direction*2048, FALSE, self);

	if (trace_fraction != 1.0)
	{
	//decide what we hit
		if (trace_ent.takedamage)
		{
		// something that takes damage
		// check if it was a headshot
			dflags = 0;
			if (lflags & DF_ALWAYSGIB)
				dflags |= DF_ALWAYSGIB;
			if (trace_ent.flags & FL_MONSTER)
			{
				if (trace_ent.monsterflags & MFL_HASHEAD)
				{
				// calculate if it's a headshot or not
					head_origin = findHeadPosition(trace_ent);
				// make head smaller the closer we are to the target, so it's not that easy to hit head in close combat
					head_size_factor = trace_ent.head_size;
					
					if (distancetoray(src, direction, head_origin) < head_size_factor)
						dflags |= DF_HEADSHOT;
				}
				
				if (lflags & FBA_IMPACT)
				{
					if (trace_ent.monsterflags & MFL_SHIELD && !(lflags & FBA_NOSHIELD_IMPACT))
						sendMessageImpact(trace_endpos, trace_ent.origin, IMPACT_SHIELD, VEC_ORIGIN); 
					else
					{
						// make blood
						if (dflags & DF_HEADSHOT)
						{
							if (trace_ent.monsterflags & MFL_ROBOT)
								sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT_HEADSHOT, VEC_ORIGIN); 
							else
								sendMessageImpact(trace_endpos, -direction, IMPACT_FLESH_HEADSHOT, VEC_ORIGIN); 
						}
						else
						{
							if (trace_ent.monsterflags & MFL_ROBOT)
								sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT, VEC_ORIGIN); 
							else
								sendMessageImpact(trace_endpos, -direction, IMPACT_FLESH, VEC_ORIGIN); 
						}
					}
				}
			}
			else if (lflags & FBA_IMPACT)
				sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT, VEC_ORIGIN);  // hit shootable solid

			trace_ent.lasthit_direction = direction;
		// add damage
			if (lflags & FBA_ISMULTIDAMAGE)
				AddMultiDamage (trace_ent, damage, dflags);
			else
				T_Damage (trace_ent, self, self, damage, dflags, penetration);
		}
		else
		{
		// hit solid, make particle fx
			if (lflags & FBA_IMPACT)
				sendMessageImpact(trace_endpos, trace_plane_normal, IMPACT_WALL, VEC_ORIGIN); 
		}
	}
};

void() W_SwingKatana =
{
	vector source, direction, org, head_origin;
	entity previous;
	float i;
	SuperDamageSound ();
	makevectors	(self.v_angle + self.punchangle);
	source = self.origin + '0 0 16';
	direction = v_forward;
		
	for (i = 0; i < 3; i++)
	{
		switch (i)
		{
			case 2:
				traceline (source + v_right * (-32), source + direction * 96 + v_right * 16, FALSE, self); // trace from the left side of the player into front, immitating swing
				break;
			case 1:
				traceline (source, source + direction * 96 + v_right * -16, FALSE, self);
				break;
			case 0:
				traceline (source, source + direction * 96, FALSE, self);
				break;
		}
		if (trace_fraction == 1.0)
			continue;
		if (trace_ent && trace_ent == previous)
			continue;
		
		org = trace_endpos - v_forward*4;
	
		if (trace_ent.takedamage)
		{
			trace_ent.axhitme = 1;
			if (trace_ent.flags & FL_MONSTER)
			{
				trace_ent.lasthit_direction = direction; // set this before T_Damage, otherwise it's too late
				head_origin = findHeadPosition(trace_ent);
	
				if (distancetoray(source, direction, head_origin) < trace_ent.head_size*2) // bigger heads for katana
					T_Damage (trace_ent, self, self, KATANA_DAMAGE, DF_HEADSHOT | DF_KATANA);
				else
					T_Damage (trace_ent, self, self, KATANA_DAMAGE, DF_KATANA);
				
				if (trace_ent.monsterflags & MFL_SHIELD)
					sendMessageImpact(trace_endpos, trace_ent.origin, IMPACT_SHIELD, VEC_ORIGIN); 
				else if (trace_ent.monsterflags & MFL_ROBOT)
					sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT, VEC_ORIGIN); 
				else
					sendMessageImpact(trace_endpos, -direction, IMPACT_FLESH, VEC_ORIGIN); 
			}
			else
			{
				sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT, VEC_ORIGIN); 
				T_Damage (trace_ent, self, self, KATANA_DAMAGE, 0);
			}
			previous = trace_ent;
		}
		else
		{	// hit wall
			if (self.katanasound_finished < time)
			{
				sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
				sendMessageImpact(trace_endpos, trace_plane_normal, IMPACT_WALL, VEC_ORIGIN); 
				self.katanasound_finished = time + 0.4;
			}
		}
	}
};

void() W_FirePistol =
{
	vector dir;
	
	SuperDamageSound ();
// play sound
	sound (self, CHAN_WEAPON, "weapons/f_pistol.wav", 1, ATTN_NORM);	
// ammo
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
// find shot direction
	makevectors(self.v_angle + self.punchangle);
	dir = aim (self, 100000);
//
	FireBulletAim (dir, NULL_OFFSET, NULL_OFFSET, PISTOL_DAMAGE, PISTOL_PENETRATION, FBA_IMPACT);
	//ApplyMultiDamage ();

// particle fx trace and muzzle flash
	sendMessageVecVecFlag(offsetWeapon(24,6,-4), trace_endpos, MF_PISTOL, TE_BULLETTRACE);
// blow up grenades
	checkGrenadeCollision(dir, 12);

	//sendMessageVecVecFlag(start, dir, MF_PISTOL, TE_MUZZLE);
// recoil
	makePunch([3, 0, 0], [0, 0, 0], [0, 0, 0]);
	addPunchVelocity(-20, 0, 0);
	addShake(-60, 0, 0);
	//makePunch([8,0,0], [0,-4 + crandom()*2,0],[0,0,0]);
};

void() W_FireSuperShotgun =
{
	vector dir, start;
	float i;
	float lflag;
	
	SuperDamageSound ();
	sound (self, CHAN_WEAPON, "weapons/f_shotgun.wav", 1, ATTN_NORM);	// shot part
	//sound (self, CHAN_ITEM, "weapons/f_shotgun2.wav", 1, ATTN_NORM); // reload part
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	
	start = offsetWeapon(24,6,-4); // do this once, instead of doing it in the cycle below
	
	ClearMultiDamage ();
	for (i = 0; i < 14; i++)
	{
		lflag = FBA_ISMULTIDAMAGE; // means that we have to use ApplyMultiDamage after cycle
		if (i > 2)
			lflag |= FBA_IMPACT | FBA_NOSHIELD_IMPACT;

		FireBulletAim (dir, SSGX[i]*0.2, SSGY[i]*0.4, SHOTGUN_DAMAGE, SHOTGUN_PENETRATION, lflag); 
		if (i < 3)
		{
			sendMessageVecVecFlag(start, trace_endpos, MF_SHOTGUN, TE_BULLETTRACE); // 3 messages in total, have to be done after trace ofc
			if (trace_ent.monsterflags & MFL_SHIELD)
				sendMessageImpact(trace_endpos, trace_ent.origin, IMPACT_SHIELD, VEC_ORIGIN); 
		}
	}
	ApplyMultiDamage ();
	
	//sendMessageVecVecFlag(start, trace_endpos, MF_SHOTGUN, TE_BULLETTRACE);
	checkGrenadeCollision(dir, 16);
	makePunch([20,2,1],[1+random()*2,-3*random()*3,3],[crandom()*3,0,0]);
	addShake(-80, 0, 0);
};

void(float leftgun) W_FireSMG =
{
	vector dir;
	vector start;
	float r;
	static float dirchange = 1;
	
	SuperDamageSound ();
	
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
	
	r = random();
	if (r < 0.25)
		sound (self, CHAN_AUTO, "weapons/f_vector1.wav", 1, ATTN_NORM);
	else if (r <  0.5)
		sound (self, CHAN_AUTO, "weapons/f_vector2.wav", 1, ATTN_NORM);
	else if (r <  0.75)
		sound (self, CHAN_AUTO, "weapons/f_vector3.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_AUTO, "weapons/f_vector4.wav", 1, ATTN_NORM);
	
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	
	dir = aim (self, 100000);
	FireBulletAim (dir, crandom()*0.02, crandom()*0.02, SMG_DAMAGE, SMG_PENETRATION, FBA_IMPACT);
	
	if (leftgun)
		start = offsetWeapon(34,-8,-4);
	else
		start = offsetWeapon(34,8,-4);

	sendMessageVecVecFlag(start, trace_endpos, MF_SMG, TE_BULLETTRACE);
	checkGrenadeCollision(dir, 8);

	//punch_relaxtime
	if (random() < 0.15)
		dirchange *= -1;
	makePunch([0.5 + random()*1.5, 0.5, 2], [random() * dirchange, 0, 0], [0, 0, 0]); // 
	addPunchVelocity(0,crandom()*4,0);
};

// sendMessageImpact is: impact coordinates, shooter coordinates, type flag, impact plane normal vector
// prepare for the ride -_-
void() W_FireGauss =
{
	float power, penetration_depth;
	vector start, direction, destination, startposition_loop, impact, wall_normal;
	entity current_ignored;
	float isworld;
	
// misc stuff
	SuperDamageSound ();
	sound (self, CHAN_AUTO, "weapons/f_gauss.wav", 1, ATTN_NORM);
	self.show_hostile = time + 1;	// wake monsters up	
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	
// preparations before trace
	start = getGunPoint(self);  // start position should remain unchanged for all the non-trace checks
	makevectors(self.v_angle + self.punchangle);
	direction = v_forward;
	destination = start + (direction * 4096);
		
	startposition_loop = start; // this would be moved along direction ray to perfrom next trace after hiting something
	current_ignored = self; // trace could start from inside player's bounding box, exclude him from collision detection
	
// apply recoil	
	makePunch([10, -20, 0], [rint(crandom() * 2) * 4, -4, 0], [0, 0, 0]);
// viewshake 
	if (self.flags & FL_ONGROUND) 
	{
		self.velocity += v_forward * (-400); // push back
		addShake(-80, crandom()*60, crandom()*60);
	}
	else
	{
	// more shake when in the air, less velocity
		self.velocity += v_forward * (-200); // push back
		addShake(-120, crandom()*90, crandom()*90);
	}

	power = 1;
	while (1) // walls
	{
		while (1) 	// monsters
		{
		// cast new trace with updated position
			traceline (startposition_loop, destination, ALLOWMONSTERS, current_ignored);
		
		// no collisions with anything, abort both loops	
			if (trace_fraction == 1.0)
			{
				// main trail effect message
				sendMessageVecVec(offsetWeapon(16,6,-8), trace_endpos, TE_GAUSSTRACE);
				return;
			}
		
		// hit monster
			if (trace_ent.flags & FL_MONSTER || trace_ent.flags & FL_EXPLOBOX || trace_ent.monsterflags & MFL_BOSS)
			{
			// [A] apply damage and effects, if target can recieve damage
				if (trace_ent.takedamage)
				{
					float ishead = 0;
				// check for head collision
					if (distancetoray(start, direction, findHeadPosition(trace_ent)) < trace_ent.head_size * 1.2) // bigger heads for gauss
					{
					// hit head
						ishead = DF_HEADSHOT;
					}

					// hit body, send particle effect message
					if (trace_ent.monsterflags & MFL_SHIELD)
					{
						sendMessageVec(trace_endpos, TE_EXPLOSION_PLASMA);
						sendMessageImpact(trace_endpos, trace_ent.origin, IMPACT_SHIELD, VEC_ORIGIN); 
					}
					else if (trace_ent.monsterflags & MFL_ROBOT)
						sendMessageImpact(trace_endpos, direction, IMPACT_GAUSS_ROBOT, VEC_ORIGIN); 
					else 
						sendMessageImpact(trace_endpos, direction, IMPACT_GAUSS_FLESH, VEC_ORIGIN); 

					trace_ent.lasthit_direction = direction;
					if (trace_ent)
						T_PushDirection(trace_ent, direction, 400); 
					T_Damage (trace_ent, self, self, GAUSS_DAMAGE, ishead, 1);
				}
			// ^[A] otherwise just continue loop while ignoring current hit entity
				current_ignored = trace_ent;
				startposition_loop = trace_endpos + (direction * 4);
			}
		//hit shootable solid, break monsters cycle
			else if (trace_ent.takedamage)
			{
				T_Damage (trace_ent, self, self, GAUSS_DAMAGE, 0); // buttons etc
				break;
			}
		// hit solid
			else 
				break;
		}
// end of monsters loop
	// we hit solid, now we need to decide what to do
	// first of all, save current trace data, so we can use it for entrance hole effects later
		impact = trace_endpos;
		wall_normal = trace_plane_normal;
	// check doors/buttons
		if (trace_ent.sprawlflags & SFL_MOVINGSOLID)
			isworld = 1;
		else
		{
			if (pointcontents(trace_endpos + direction * 4) == CONTENT_SKY) // this is not working i have no idea why, returns solid(-2)
			{
				isworld = 1;
				goto final;
			}
			else
				isworld = 0;
		}
	
	// already run out of gas, finish
		if (power < 1)
			goto final;
	// let's see if our solid object is penetratable
		penetration_depth = 0;
		while(1)
		{
		// ok, this is a weird ass fuckery, but it works
			penetration_depth += 24;
			if (penetration_depth > 128)
				break;
			
			if (!(pointcontents(impact + direction * penetration_depth) == CONTENT_SOLID)) 
			{
			// in the better world this would be enough, but pointcontents doesn't check for any entity, solid or point type
			// so to check if we inside of such we use trace, max 5 traces (128/24) per shot, and only if it's deep enough solid entity
				traceline (impact + direction * penetration_depth, destination, IGNOREMONSTERS, world);
				if (!trace_startsolid)
					break;
			}
		}
		
		if (penetration_depth < 128)
		{
		// we punch through the wall and there is air here, trace back to find the exit hole
			traceline (impact + direction * (penetration_depth + 4), impact, IGNOREMONSTERS, world);

		// exit hole particle effect
		// in case of we hit non-solid object, we will recieve all zeroes normal, which is not good for on engine calculations
			if (!(trace_ent.sprawlflags & SFL_MOVINGSOLID))
				sendMessageImpact(trace_endpos, start, IMPACT_GAUSS_EXIT, trace_plane_normal); 
		// don't forget about entrance hole, use old info
			if (!isworld)
				sendMessageImpact(impact, start, IMPACT_GAUSS_ENTRANCE, wall_normal); // entrance hole particle effect
			
			power -= 1;//(penetration_depth / 128) * 0.5;
			// trace from inside the wall to hit someone who touch the wall 
			// usually monsters on platforms being ignored whet shot from underneath
			startposition_loop = trace_endpos - direction * 4; 
		}
		else 
		{
		// end of line, send final impact and trail messages, 
		final:
			if (!isworld)
				sendMessageImpact(impact, start, IMPACT_GAUSS_FINAL, wall_normal); 
			sendMessageVecVec(offsetWeapon(16,6,-8), impact, TE_GAUSSTRACE); // trail
			return;
		}
	}
};

void() W_FireChaingun =
{
	vector dir;
	vector new_vel;
	
	SuperDamageSound ();
	self.show_hostile = time + 1;	// wake monsters up	
	self.currentammo = self.ammo_bullets = self.ammo_bullets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/f_chaingun.wav", 1, ATTN_NORM);	
	
	makevectors(self.v_angle + self.punchangle);
	dir = aim (self, 100000);
	FireBulletAim (dir, crandom()*0.02, crandom()*0.02, CHAINGUN_DAMAGE, CHAINGUN_PENETRATION, FBA_IMPACT | DF_ALWAYSGIB);
	float r = random();
	if (trace_ent.flags & FL_MONSTER && r > 0.66 && !(trace_ent.monsterflags & MFL_SHIELD))
		SpawnMeatSpray(trace_ent.origin + [crandom() * 16, crandom() * 16, crandom() * 16], crandom() * 150 * v_right, trace_ent);
	
	launchCasing(self.origin, v_forward * 12 + v_right * 16 + v_up * (self.view_ofs_z - 8), 2);
	sendMessageVecVecFlag(offsetWeapon(48,4,-10), trace_endpos, MF_CHAINGUN, TE_BULLETTRACE);
	checkGrenadeCollision(dir, 8);

	new_vel = VEC_ORIGIN;
	if (self.wallrun) 
		new_vel += v_forward * (-50);
	else
		new_vel += v_forward * (-75);
	new_vel_z *= 0.5;
	self.velocity += new_vel;
	
	makePunch([0, 0, 2], [0, 0, 0], [0, 0, 0]);
	//makePunch([2+random()*2, 0.5, 0], [crandom(), 0, 0], [0, 0, 0]); //crandom() * crandom() * 4
	addPunchVelocity(crandom()*5,crandom()*5,0);
	addShake(0,0,crandom()*50);
};

void() GrenadeExplode =
{
	removeFromList(self);
	T_RadiusDamagePlayer(self, self.owner, GRENADE_EXPLOSION, world, 256, 64);
	sendMessageVec(self.origin, TE_EXPLOSION);
	
	BecomeExplosion ();
};

void (entity who) traceGrenade =
{
	float dflags;
	
	if (!(who.flags & FL_MONSTER))
		return;
	
	dflags = 0;
	if (who.monsterflags & MFL_HASHEAD)
	{
	// calculate if it's a headshot or not
		if (distancetoray(self.origin, self.vA, findHeadPosition(who)) < who.head_size * 1.25)
			dflags |= DF_HEADSHOT;
	}
	
	T_Damage (who, self, self.owner, GRENADE_CUMULATIVE, dflags, GRENADE_PENETRATION);
};

void() GrenadeTouch =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		removeFromList(self);
		remove(self);
		return;
	}
	
	if (other == self.owner)
		return;		// don't explode on owner
	
	if ((self.sprawlflags & SFLP_GRENADE_CHARGED && !(self.sprawlflags & SFLP_GRENADE_NOTOUCH)) 
		|| (self.sprawlflags & SFLP_GRENADE_CANTOUCHSOFT && other.takedamage == DAMAGE_AIM))
	{
		self.thinkA = SUB_Null;
		self.nextthinkA = -1;
		self.velocity = '0 0 0';
		traceGrenade(other);
		GrenadeExplode();
		return;
	}
	else
	{
		self.sprawlflags |= SFLP_GRENADE_NOTOUCH;
	}
	
	float oldz;
	oldz = self.velocity_z;
	
	if (other.takedamage == DAMAGE_AIM)
	{
		if (!(other.monstertype & (TYPE_FIEND | TYPE_OGRE | TYPE_SHAMBLER | TYPE_HELLKNIGHT)))
		{
			T_PushDirection(other, normalize(other.origin - [self.origin_x, self.origin_y, other.origin_z]), 400); // don't push target down or up, use it's z coordinate
			T_Damage (other, self, self.owner, 50, 0);
		}
		else
			T_Damage (other, self, self.owner, 1, 0);
		self.velocity = 0.5 * vlen(self.velocity) * normalize(self.velocity); //slowdown by 50%
		
		self.sprawlflags -= self.sprawlflags & SFLP_GRENADE_CANTOUCHSOFT;
	}
	else
		self.velocity = 0.8 * vlen(self.velocity) * normalize(self.velocity); //slowdown by 20%

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	self.velocity_z = oldz;
	
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() AngleGrenade = 
{
	if (!self.velocity)
		return;
	self.angles = vectoangles(self.velocity);	
	self.vA = self.angles; // save cumulative trace direction
	self.thinkA = AngleGrenade;
	self.nextthinkA = time + 0.05;
};

void() ChargeGrenade =
{
	if (!(self.sprawlflags & SFLP_GRENADE_CANTOUCHSOFT))
	{
		self.sprawlflags |= SFLP_GRENADE_CANTOUCHSOFT;
		self.thinkB = ChargeGrenade;
		self.nextthinkB = time + 0.15;
	}
	else
		self.sprawlflags |= SFLP_GRENADE_CHARGED;
};

void() W_FireGrenade =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	SuperDamageSound ();
	sound (self, CHAN_WEAPON, "weapons/f_grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.clip = CLIP_PROJECTILE;
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors	(self.v_angle + self.punchangle);
	if (self.v_angle_x)
		missile.velocity = v_forward*1200 + v_up * 100 + v_right * (-8); //+ crandom()*v_right*30 + crandom()*v_up*30
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '0 25 50';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	
	// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, offsetWeapon(15,8,4)); // fixed grenades spawned inside walls
	//missile.isgrenade = 1;
	appendToList(missile);
	makePunch([6, 0, 0], [0, 0, 0], [0, 0, 0]);
	addPunchVelocity(-40,-20 + random()*20,0);
	addShake(-60, 0, 0);
	missile.thinkA = AngleGrenade;
	missile.nextthinkA = time + 0.1;
	missile.thinkB = ChargeGrenade;
	missile.nextthinkB = time + 0.1;
};

void()	s_explode1	=	[0,		s_explode2] {self.nextthink = time + 0.05;};
void()	s_explode2	=	[1,		s_explode3] {self.nextthink = time + 0.05;};
void()	s_explode3	=	[2,		s_explode4] {self.nextthink = time + 0.05;};
void()	s_explode4	=	[3,		s_explode5] {self.nextthink = time + 0.05;};
void()	s_explode5	=	[4,		s_explode6] {self.nextthink = time + 0.05;};
void()	s_explode6	=	[5,		SUB_Remove] {self.nextthink = time + 0.05;};

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
		T_Damage (other, self, self.owner, damg, 0);
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
		T_Damage (trace_ent, from, from, damage, NOFLAGS, 1);
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
		T_Damage (trace_ent, from, from, damage, NOFLAGS, 1);
	}

	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage, NOFLAGS, 1);
	}
};

void() W_FireLightning =
{
	vector	org, direction, head_origin;
	float dflags, damage;
	
	SuperDamageSound ();
	// explode if under water
	if (self.waterlevel > 1)
	{
		T_Damage (self, self, self, 5, 0, 1);
		return;
	}
	
	//makevectors(self.v_angle);

	sound (self, CHAN_AUTO, "weapons/static.wav", 1, ATTN_NORM);

	org = offsetWeapon(24,8,-6); // CALL OF MAKEVECTORS with punchangle
	direction = v_forward;
	
	traceline (org, org + direction * 600, TRUE, self);
	self.effects |= EF_MUZZLEFLASH;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteByte (MSG_BROADCAST, 0);
	//WriteCoord (MSG_BROADCAST, self.v_angle_x);
	//WriteCoord (MSG_BROADCAST, self.v_angle_y);
	//WriteCoord (MSG_BROADCAST, self.v_angle_z);
	
	// offset of source point
	org = self.origin;
	org_z = self.origin_z + self.view_ofs_z;
	
	// trace
	traceline (org, org + direction * 640, FALSE, self);
	if (trace_fraction != 1.0)
	{
		if (trace_ent.takedamage)
		{
			dflags |= DF_SHOCK;
			if (trace_ent.flags & FL_MONSTER)
			{
				if (trace_ent.monsterflags & MFL_HASHEAD)
				{
					head_origin = findHeadPosition(trace_ent);
					if (distancetoray(org, direction, head_origin) < trace_ent.head_size)
						dflags |= DF_HEADSHOT;
				}
				
				if (trace_ent.monsterflags & MFL_SHIELD)
					sendMessageImpact(trace_endpos, trace_ent.origin, IMPACT_SHIELD, VEC_ORIGIN); 
				else 
					sendMessageImpact(trace_endpos, -direction, IMPACT_SHOCK, VEC_ORIGIN); 
			}
			else
				sendMessageImpact(trace_endpos, -direction, IMPACT_ROBOT, VEC_ORIGIN);  // hit shootable solid like a button

			trace_ent.lasthit_direction = direction;
			trace_fraction *= 640;
			if (trace_fraction < 128)
				damage = SHOCK_DAMAGE_MIN;
			else if (trace_fraction > 512)
				damage = SHOCK_DAMAGE_MAX;
			else
				damage = lerp(SHOCK_DAMAGE_MIN, SHOCK_DAMAGE_MAX, (trace_fraction - 128) / 384);
			T_Damage (trace_ent, self, self, damage, dflags, 1);
		}
		else
			sendMessageImpact(trace_endpos, trace_plane_normal, IMPACT_SHOCK, VEC_ORIGIN); 
	}
	float amplitude;
	amplitude = 1 - (rint(self.current_speed / 10) / 100); // 1 - speed/1000, rounded to x.xx
	amplitude = max(0.3, amplitude);
	makePunch([random()*3 * amplitude, 0, 0], [randomsign() * random() * amplitude, randomsign() * 1.5 * amplitude, randomsign() * 3 * amplitude], [0, 0, 0]); // 
};

void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.clip = CLIP_PROJECTILE;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/shrapnel.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
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
		T_Damage (other, self, self.owner, 5, 0);
	}

	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
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
		T_Damage (other, self, self.owner, 18, 0);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*
===============================================================================
===============================================================================
*/

void() W_SetCurrentAmmo =
{
	if (self.sprawlflags & SFL_RESETWEAPONFRAME)
	{
		player_run ();		// get out of any weapon firing states
		self.weaponframe = 0;
		if (self.weapon & IT_CHAINGUN && self.chaingun_frame)
			self.weaponframe = self.chaingun_frame;
		self.sprawlflags -= self.sprawlflags & SFL_RESETWEAPONFRAME;
	}

self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS | IT_BULLETS) );
	
	if (self.weapon == IT_KATANA)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_katana.mdl";
	}
	else if (self.weapon == IT_PISTOL)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_pistol.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shotgun.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SMGS)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_smgs.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_CHAINGUN)
	{
		self.currentammo = self.ammo_bullets;
		self.weaponmodel = "progs/v_chaingun.mdl";
		self.items = self.items | IT_BULLETS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_grenade.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_GAUSS)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_gauss.mdl";
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_SHOCK)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_shock.mdl";
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

	if(self.ammo_bullets > 1 && (it & IT_CHAINGUN) )
		return IT_CHAINGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_SMGS) )
		return IT_SMGS;
	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_SHOCK) )
		return IT_SHOCK;
	else if(self.ammo_nails >= 1 && (it & IT_PISTOL) )
		return IT_PISTOL;

	return IT_KATANA;
};

float() W_hasNoAmmo =
{
	if (self.currentammo)
		return FALSE;	//player has ammo	--gnounc

	if (self.weapon == IT_KATANA)
		return FALSE;	//the axe doesnt need ammo. so we lie. Player Totally has ammo..Promise! --gnounc
	
	deployGun(W_BestWeapon ());
	
	// drop the weapon down
	return TRUE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/

void() W_Attack =
{
	//local	float	r;

	if (W_hasNoAmmo())
		return;
	
	makevectors	(self.v_angle + self.punchangle);		// calculate forward angle for velocity
	
	switch (self.weapon)
	{
		case IT_KATANA:
			if (self.katana_finished > time)
				return;
			
			katanaSwingStart();
			break;
			
		case IT_PISTOL:
			if (self.pistol_finished > time ) 
				return;
			
			if (self.sprawlflags & SFL_SEMIAUTO && (self.pistol_finished + 0.3 > time))
				return;
			
			self.sprawlflags |= SFL_SEMIAUTO;
			animatePistolFire();
			W_FirePistol ();
			self.show_hostile = time + 1;	// wake monsters up	
			
			self.pistol_finished = time + 0.3;
			self.attack_finished = time + 0.25;
			break;
			
		case IT_SUPER_SHOTGUN:
			if (self.shotgun_finished > time ) 
				return;
			//player_shot1 ();
			if (self.wallrun) 
				self.velocity += v_forward * (-200);
			else
				self.velocity += v_forward * (-400);
			
			animateShotgunFire();
			W_FireSuperShotgun ();
			self.show_hostile = time + 1;	// wake monsters up	
			self.shotgun_finished = time + 1.2;
			self.attack_finished = time + 0.35;
			break;
			
		case IT_SMGS:
			animateSMGFire();
			self.show_hostile = time + 1;	// wake monsters up	
			self.attack_finished = time + 0.05;
			break;
			
		case IT_CHAINGUN:
			animateChaingun();
			break;
			
		case IT_GRENADE_LAUNCHER:
			if (self.grenade_finished > time ) 
				return;
			
			if (self.sprawlflags & SFL_SEMIAUTO && (self.grenade_finished + 0.4 > time))
				return;
			
			self.sprawlflags |= SFL_SEMIAUTO;

			animateGrenadeFire();
			W_FireGrenade();
			self.show_hostile = time + 1;	// wake monsters up	
			self.grenade_finished = time + 0.3;
			self.attack_finished = time + 0.3;
			break;
			
		case IT_GAUSS:
			if (self.gauss_finished > time ) 
				return;

			heatupGauss();
			break;
			
		case IT_SHOCK:
			if (self.ammo_cells < 1)
			{
				self.weapon = W_BestWeapon ();
				W_SetCurrentAmmo ();
				return;
			}
			self.weaponframe = 59;
			animateShock();
			self.show_hostile = time + 1;	// wake monsters up	
			self.attack_finished = time + 1.0;
			self.sprawlflags |= SFL_HOLD;
			sound (self, CHAN_WEAPON, "weapons/f_shock_loop.wav", 1, ATTN_NORM);
			self.currentammo = --self.ammo_cells;
			break;
	}
};

void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	fl = it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
		fl = IT_KATANA;
	}

	else if (self.impulse == 2)
	{
		fl = IT_PISTOL;

		if (self.ammo_nails < 1)
			am = 1;
	}

	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;

		if (self.ammo_shells < 1)
			am = 1;
	}		

	else if (self.impulse == 4)
	{
		fl = IT_SMGS;

		if (self.ammo_nails < 1)
			am = 1;
	}

	else if (self.impulse == 5)
	{
		fl = IT_CHAINGUN;

		if (self.ammo_bullets < 1)
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
		fl = IT_GAUSS;
		if (self.ammo_cells < 1)
			am = 1;
	}

	else if (self.impulse == 8)
	{
		fl = IT_SHOCK;
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
		deployGun(fl);
};

void() CheatCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = MAX_ROCKETS;
	self.ammo_nails = MAX_NAILS;
	self.ammo_shells = MAX_SHELLS;
	self.ammo_bullets = MAX_BULLETS;
	self.items |= IT_KATANA |
		IT_PISTOL |
		IT_SUPER_SHOTGUN |
		IT_SMGS |
		IT_CHAINGUN |
		IT_GRENADE_LAUNCHER |
		IT_GAUSS;

	self.ammo_cells = MAX_CELLS;
	self.items = self.items | IT_SHOCK;
	self.sprawlflags |= SFL_RESETWEAPONFRAME;
	deployGun(IT_GAUSS);
	self.impulse = 0;
	//W_SetCurrentAmmo ();
};
void() CheatKeys =
{
	self.items |= IT_KEY1 | IT_KEY2;
};

void() LastInv =
{
	if (self.lastweapon)
		deployGun(self.lastweapon);
	else
		deployGun(IT_KATANA);
}

void() CycleWeaponCommand =
{
	local	float	it, am, w;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_SHOCK)
		{
			w = IT_KATANA;
		}

		else if (self.weapon == IT_KATANA)
		{
			w = IT_PISTOL;

			if (self.ammo_nails < 1)
				am = 1;
		}

		else if (self.weapon == IT_PISTOL)
		{
			w = IT_SUPER_SHOTGUN;

			if (self.ammo_shells < 1)
				am = 1;
		}		

		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			w = IT_SMGS;

			if (self.ammo_nails < 1)
				am = 1;
		}

		else if (self.weapon == IT_SMGS)
		{
			w = IT_CHAINGUN;

			if (self.ammo_bullets < 1)
				am = 1;
		}

		else if (self.weapon == IT_CHAINGUN)
		{
			w = IT_GRENADE_LAUNCHER;

			if (self.ammo_rockets < 1)
				am = 1;
		}

		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			w = IT_GAUSS;

			if (self.ammo_rockets < 1)
				am = 1;
		}

		else if (self.weapon == IT_GAUSS)
		{
			w = IT_SHOCK;

			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if (self.weapon != w)
			deployGun(w);
			
		if ( (self.items & w) && am == 0 )
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

void() CycleWeaponReverseCommand =
{
	local float it, am, w;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_SHOCK)
		{
			w = IT_GAUSS;

			if (self.ammo_cells < 1)
			am = 1;
		}
	
		else if (self.weapon == IT_GAUSS)
		{
			w = IT_GRENADE_LAUNCHER;

			if (self.ammo_rockets < 1)
			am = 1;
		}

		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			w = IT_CHAINGUN;

			if (self.ammo_bullets < 1)
			am = 1;
		}

		else if (self.weapon == IT_CHAINGUN)
		{
			w = IT_SMGS;

			if (self.ammo_nails < 1)
			am = 1;
		}

		else if (self.weapon == IT_SMGS)
		{
			w = IT_SUPER_SHOTGUN;

			if (self.ammo_shells < 1)
			am = 1;
		}

		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			w = IT_PISTOL;

			if (self.ammo_nails < 1)
			am = 1;
		}

		else if (self.weapon == IT_PISTOL)
		{
			w = IT_KATANA;
		}

		else if (self.weapon == IT_KATANA)
		{
			w = IT_SHOCK;

			if (self.ammo_cells < 1)
			am = 1;
		}

		if (self.weapon != w)
			deployGun(w);
			
		if ( (self.items & w) && am == 0 )
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

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
	if (self.impulse == 13)
		CheatKeys();
	if (self.impulse == 14)
		LastInv();
	if (self.impulse == 15)
		self.sprawlflags |= SFL_UNLIMITED_ADRENALINE;
	if (self.impulse == 96)
	{
		self.weaponmodel = "";
		self.items = 0;
	}
	//if (self.impulse == 16)
		
	if (self.impulse == 255)
		QuadCheat ();
		
	self.impulse = 0;
};

void() W_WeaponFrame =
{
// HUD info trace, 4 times / second
	if (self.info_trace_time < time)
	{
		makevectors(self.v_angle + self.punchangle);
		traceline ([self.origin_x, self.origin_y, self.origin_z + self.view_ofs_z], [self.origin_x, self.origin_y, self.origin_z + self.view_ofs_z] + v_forward * 2048, FALSE, self);

		if (trace_ent && trace_ent.flags & FL_MONSTER)
			setInfo(self, trace_ent);

		self.info_trace_time = time + 0.25;
	}
	
	if (self.info_stay_time < time)
	{
		removeflag(self.engineflags, ENF_HUDINFO);
		self.info_ent = world;
		self.info_stay_time = 72000; // 20 hours
	}
	updateInfo(self);
	
	if (self.sprawlflags & SFL_INQUICKMELEE)
	{
		self.think = quickMeleeLoop;
		if (!self.nextthink)
			self.nextthink = time + 0.05;
		return;
	}
	
// quickmelee button suppose to work as semi-auto and perform only one action per press
	if (!self.b_melee) 
		self.sprawlflags -= self.sprawlflags & SFL_STOPMELEE;
	
	if (self.b_melee && !(self.sprawlflags & SFL_STOPMELEE))
	{
		if (self.weapon != IT_KATANA)
		{
			quickMeleeStart();
			self.sprawlflags |= SFL_STOPMELEE;
		}
	}
	
	if (self.sprawlflags & SFL_HOLD)
	{
		if (self.button0)
		{
			self.impulse = 0; // don't store impulse when it's not available, to prevent immediate gun swap after hold flag is stripped
			return;
		}
		else
			self.sprawlflags -= self.sprawlflags & SFL_HOLD;
	}
	
	if (self.impulse)	// gb, stop wasting performance
		ImpulseCommands ();
		
	if (time < self.attack_finished)
		return;
	
	// check for attack
	if (self.button0)
	{
		//SuperDamageSound ();
		W_Attack ();
	}
};

void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 0.2;
			sound (self, CHAN_AUTO, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
};