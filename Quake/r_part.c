/*
Copyright (C) 1996-2001 Id Software, Inc.
Copyright (C) 2002-2009 John Fitzgibbons and others
Copyright (C) 2007-2008 Kristian Duske
Copyright (C) 2010-2014 QuakeSpasm developers

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "quakedef.h"

#define MAX_PARTICLES			16384	// default max # of particles at one
										//  time
#define ABSOLUTE_MIN_PARTICLES	512		// no fewer than this no matter what's
										//  on the command line
// sin table 10 degrees per step
static float circlex[36] = { 0.00000, 0.17365, 0.34202, 0.50000, 0.64279, 0.76604, 0.86603, 0.93969, 0.98481,
							 1.00000, 0.98481, 0.93969, 0.86603, 0.76604, 0.64279, 0.50000, 0.34202, 0.17365,
							-0.00000,-0.17365,-0.34202,-0.50000,-0.64279,-0.76604,-0.86603,-0.93969,-0.98481,
							-1.00000,-0.98481,-0.93969,-0.86603,-0.76604,-0.64279,-0.50000,-0.34202,-0.17365 };
// cos table 10 degrees per step
static float circley[36] = { 1.00000, 0.98481, 0.93969, 0.86603, 0.76604, 0.64279, 0.50000, 0.34202, 0.17365,
							-0.00000,-0.17365,-0.34202,-0.50000,-0.64279,-0.76604,-0.86603,-0.93969,-0.98481,
							-1.00000,-0.98481,-0.93969,-0.86603,-0.76604,-0.64279,-0.50000,-0.34202,-0.17365,
							 0.00000, 0.17365, 0.34202, 0.50000, 0.64279, 0.76604, 0.86603, 0.93969, 0.98481 };

static int	ramp1[8] = {0x6f, 0x6d, 0x6b, 0x69, 0x67, 0x65, 0x63, 0x61};
static int	ramp2[8] = {0x6f, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x68, 0x66};
static int	ramp3[8] = {0x6d, 0x6b, 6, 5, 4, 3};
static int	rampgrenade[8] = { 0xeb, 0xe6, 0xe2, 5, 4, 3 };
static int	rampinner[10] = {0x6f, 0x6d, 0xeb, 0xe8, 0xe6, 0xe4, 0xe2, 0x04, 0x02, 0x00};
static int	plasma[10] = { 0xf6, 0xf5, 0xf4, 0xd0, 0xd2, 0xd6, 0xd8, 0xda, 0xdc, 0xde }; // d2 d8
static int	plasma_inner[10] = { 0xf6, 0xf5, 0xf4, 0x0a, 8, 6, 5, 4, 2, 0 };
static int	rampcore[11] = {0xf6 ,0xf5, 0xf4, 0xef, 0xed, 0xeb, 0xe9, 0xe7, 0xe5, 0xe3, 0xe1};//gauss core
static int	smoke[16] = {0x0f, 0x0e, 0x0d, 0x0c, 0x0b, 0x0a, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0};
static int	spark[16] = {0xef, 0xee, 0xed, 0xec, 0xeb, 0xea, 0xe9, 0xe8, 0xe7, 0xe6, 0xe5, 0xe4, 0xe3, 0xe2, 0xe1, 0xe0 };
static int	robotspark[16] = { 0xf4, 0xf5, 0xf6, 0xfc, 0xef, 0xee, 0xed, 0xec, 0xeb, 0xea, 0xe9, 0xe8, 0xe7, 0xe6, 0xe5, 0xe4 };
//static int	synthblood[6] = {0x2f, 0x2e, 0x2d, 0x2c, 0x2b, 0x2a};

#define	MF_PISTOL 1
#define MF_SHOTGUN 2
#define MF_SMG 3
#define MF_GAUSS 4
#define MF_CHAINGUN 5
#define MF_GRENADE 6
#define MF_LG 7

#define IMPACT_NORMAL 0
#define IMPACT_GAUSS_FINAL 1
#define IMPACT_GAUSS_ENTRANCE 2
#define IMPACT_GAUSS_EXIT 3
#define IMPACT_GAUSS_FLESH 4
#define IMPACT_GAUSS_ROBOT 5
#define IMPACT_FLESH_HEADSHOT 6
#define IMPACT_ROBOT_HEADSHOT 7
#define IMPACT_FLESH 8
#define IMPACT_ROBOT 9
#define IMPACT_WALL 10
#define IMPACT_LASER 11
#define IMPACT_SHIELD 12
#define IMPACT_SHOCK 13

particle_t	*particles;
int			r_numparticles, r_numactiveparticles;

static float uvscale;
static float texturescalefactor; //johnfitz -- compensate for apparent size of different particle textures

cvar_t	r_particles = {"r_particles","2", CVAR_ARCHIVE}; //johnfitz

typedef struct particlevert_t {
	vec3_t		pos;
	GLubyte		color[4];
} particlevert_t;

static particlevert_t partverts[MAX_PARTICLES];
static int numpartverts = 0;

/*
===============
R_SetParticleTexture_f -- johnfitz
===============
*/
static void R_SetParticleTexture_f (cvar_t *var)
{
	switch ((int)(r_particles.value))
	{
	case 1:
		uvscale = 1.0; // 1.0
		texturescalefactor = 1.1; // 1.27
		break;
	case 2:
		uvscale = 0.25; // 0.25
		texturescalefactor = 0.75; // 1.0
		break;
	}
}

/*
===============
R_AllocParticle
===============
*/
particle_t *R_AllocParticle (void)
{
	if (r_numactiveparticles < r_numparticles)
	{
		particle_t *p = &particles[r_numactiveparticles++];
		p->spawn = cl.time - 0.001;
		return p;
	}
	Con_DPrintf("Out of Particles\n");
	return NULL;
}

/*
===============
R_InitParticles
===============
*/
void R_InitParticles (void)
{
	int		i;

	i = COM_CheckParm ("-particles");

	if (i && i < com_argc - 1)
	{
		r_numparticles = atoi(com_argv[i + 1]);
		if (r_numparticles < ABSOLUTE_MIN_PARTICLES)
			r_numparticles = ABSOLUTE_MIN_PARTICLES;
	}
	else
	{
		r_numparticles = MAX_PARTICLES;
	}

	particles = (particle_t *)
			Hunk_AllocName (r_numparticles * sizeof(particle_t), "particles");
	r_numactiveparticles = 0;

	Cvar_RegisterVariable (&r_particles); //johnfitz
	Cvar_SetCallback (&r_particles, R_SetParticleTexture_f);
	R_SetParticleTexture_f (&r_particles); // set default
}

/*
===============
R_EntityParticles
===============
*/
static vec3_t	avelocities[NUMVERTEXNORMALS];
static float	beamlength = 16;

void R_EntityParticles (entity_t *ent)
{
	int		i;
	particle_t	*p;
	float		angle;
	float		sp, sy, cp, cy;
//	float		sr, cr;
//	int		count;
	vec3_t		forward;
	float		dist;

	dist = 64;
//	count = 50;

	if (!avelocities[0][0])
	{
		for (i = 0; i < NUMVERTEXNORMALS; i++)
		{
			avelocities[i][0] = (rand() & 255) * 0.01;
			avelocities[i][1] = (rand() & 255) * 0.01;
			avelocities[i][2] = (rand() & 255) * 0.01;
		}
	}

	for (i = 0; i < NUMVERTEXNORMALS; i++)
	{
		angle = cl.time * avelocities[i][0];
		sy = sin(angle);
		cy = cos(angle);
		angle = cl.time * avelocities[i][1];
		sp = sin(angle);
		cp = cos(angle);
		angle = cl.time * avelocities[i][2];
	//	sr = sin(angle);
	//	cr = cos(angle);

		forward[0] = cp*cy;
		forward[1] = cp*sy;
		forward[2] = -sp;

		if (!(p = R_AllocParticle ()))
			return;

		p->die = cl.time + 0.01;
		p->color = 0x6f;
		p->type = pt_explode;

		p->org[0] = ent->origin[0] + r_avertexnormals[i][0]*dist + forward[0]*beamlength;
		p->org[1] = ent->origin[1] + r_avertexnormals[i][1]*dist + forward[1]*beamlength;
		p->org[2] = ent->origin[2] + r_avertexnormals[i][2]*dist + forward[2]*beamlength;
	}
}

/*
===============
R_ClearParticles
===============
*/
void R_ClearParticles (void)
{
	r_numactiveparticles = 0;
}

/*
===============
R_ReadPointFile_f
===============
*/
void R_ReadPointFile_f (void)
{
	FILE	*f;
	vec3_t	org;
	int		r;
	int		c;
	particle_t	*p;
	char	name[MAX_QPATH];

	if (cls.state != ca_connected)
		return;			// need an active map.

	q_snprintf (name, sizeof(name), "maps/%s.pts", cl.mapname);

	COM_FOpenFile (name, &f, NULL);
	if (!f)
	{
		Con_Printf ("couldn't open %s\n", name);
		return;
	}

	Con_Printf ("Reading %s...\n", name);
	c = 0;
	org[0] = org[1] = org[2] = 0; // silence pesky compiler warnings
	for ( ;; )
	{
		r = fscanf (f,"%f %f %f\n", &org[0], &org[1], &org[2]);
		if (r != 3)
			break;
		c++;

		if (!(p = R_AllocParticle ()))
		{
			Con_Printf ("Not enough free particles\n");
			break;
		}

		p->die = 99999;
		p->color = (-c)&15;
		p->type = pt_static;
		VectorCopy (vec3_origin, p->vel);
		VectorCopy (org, p->org);
	}

	fclose (f);
	Con_Printf ("%i points read\n", c);
}

/*
===============
R_ParseParticleEffect

Parse an effect out of the server message
===============
*/
void R_ParseParticleEffect (void)
{
	vec3_t		org, dir;
	int			i, count, msgcount, color;

	for (i=0 ; i<3 ; i++)
		org[i] = MSG_ReadCoord (cl.protocolflags);
	for (i=0 ; i<3 ; i++)
		dir[i] = MSG_ReadChar () * (1.0/16);
	msgcount = MSG_ReadByte ();
	color = MSG_ReadByte ();

	if (msgcount == 255)
		count = 1024;
	else
		count = msgcount;

	R_RunParticleEffect (org, dir, color, count);
}

/*
===============
R_ParticleExplosion
===============
*/
void R_ParticleExplosion (vec3_t org, short type)
{
	int			i, j;
	int	indexA, indexB;
	particle_t	*p;
	float lvelocity;
	float extraspeed;
	int color, color2, process, process2;
	// spherecal coordinates
	// x = sin A cos B
	// y = sin A sin B
	// z = cos A
	if (type)
	{
		color = plasma[0];
		color2 = plasma_inner[0];
		process = pt_explode_plasma;
		process2 = pt_explode_plasma2;
		extraspeed = 1400;
	}
	else
	{
		color = rampinner[0];
		color2 = ramp1[0];
		process = pt_explode;
		process2 = pt_explode2;
		extraspeed = 900;
	}
	for (i = 0; i < 18; i++)
	{
		indexA = i * 2+1;
		for (j = 0; j < 18; j++)
		{
			indexB = j * 2+1;
			// inner slower ring
			if (!(p = R_AllocParticle()))
				return;
			p->die = cl.time + 5;
			p->color = color;
			p->ramp = rand() & 3;
			p->type = process;

			lvelocity = (rand() % 512) - 256;
			p->org[0] = org[0] + ((rand() % 16) - 8);
			p->org[1] = org[1] + ((rand() % 16) - 8);
			p->org[2] = org[2] + ((rand() % 16) - 8);

			p->vel[0] = circlex[indexA] * circley[indexB] * lvelocity;
			p->vel[1] = circlex[indexA] * circlex[indexB] * lvelocity;
			p->vel[2] = circley[indexA] * lvelocity;
			
			// outer/faster ring
			if (!(p = R_AllocParticle()))
				return;
			p->die = cl.time + 5;
			p->color = color2;
			p->ramp = rand() & 3;
			p->type = process2;

			lvelocity = extraspeed + (1 - type) * ((rand() % 512) - 256);
			p->org[0] = org[0];
			p->org[1] = org[1];
			p->org[2] = org[2];

			p->vel[0] = circlex[indexA] * circley[indexB] * lvelocity;
			p->vel[1] = circlex[indexA] * circlex[indexB] * lvelocity;
			p->vel[2] = circley[indexA] * lvelocity;
		}
	}
}

void R_ParticleHead(vec3_t org, byte flesh)
{
	int			i, j;
	int	indexA, indexB;
	particle_t* p;
	float lvelocity;
	vec3_t offset;

	if (flesh)
	{
		for (i = 0; i < 100; i++)
		{
			if (!(p = R_AllocParticle()))
				return;

			p->ramp = - (i / 10);
			if (flesh == 1)
				p->color = 0x4a + (rand() & 5);
			else
				p->color = 0x25 + (rand() & 6);
			p->type = pt_blood;
			p->die = cl.time + 7200;
			p->flag = 0;

			VectorCopy(org, p->org);
			offset[0] = i + (rand() % 30) - 15;
			offset[1] = i + (rand() % 30) - 15;
			offset[2] = 200 + (rand() % 100) - 50;
			VectorCopy(vec3_origin, p->vel);
			VectorCopy(offset, p->wish_vel);
		}
	}
	else
	{
		for (i = 0; i < 36; i++)
		{
			if (!(p = R_AllocParticle()))
				return;
			p->die = cl.time + 5;
			p->color = rampinner[0];
			p->ramp = rand() & 3;
			p->type = pt_explode;

			lvelocity = 400 + (rand() % 512) - 256;
			VectorCopy(org, p->org);
			p->vel[0] = (rand() % 100) - 50;
			p->vel[1] = (rand() % 100) - 50;
			p->vel[2] = lvelocity;
		}

		for (i = 0; i < 9; i++)
		{
			indexA = i * 4;
			for (j = 0; j < 9; j++)
			{
				indexB = j * 4;
				// inner slower ring
				if (!(p = R_AllocParticle()))
					return;
				p->die = cl.time + 5;
				p->color = rampinner[0];
				p->ramp = rand() & 3;
				p->type = pt_explode;

				lvelocity = (rand() % 512) - 256;
				p->org[0] = org[0] + ((rand() % 16) - 8);
				p->org[1] = org[1] + ((rand() % 16) - 8);
				p->org[2] = org[2] + ((rand() % 16) - 8);

				p->vel[0] = circlex[indexA] * circley[indexB] * lvelocity;
				p->vel[1] = circlex[indexA] * circlex[indexB] * lvelocity;
				p->vel[2] = circley[indexA] * lvelocity;
			}
		}
	}
}

/*
===============
R_RunParticleEffect
===============
*/
void R_RunParticleEffect (vec3_t org, vec3_t dir, int color, int count)
{
	int			i, j;
	particle_t	*p;

	for (i=0 ; i<count ; i++)
	{
		if (!(p = R_AllocParticle ()))
			return;

			p->die = cl.time + 0.1*(rand()%5);
			p->color = (color&~7) + (rand()&7);
			p->type = pt_grav;
			for (j=0 ; j<3 ; j++)
			{
				p->org[j] = org[j] + ((rand()&15)-8);
				p->vel[j] = dir[j]*15;// + (rand()%300)-150;
			}
	}
}

/*
===============
R_LavaSplash
===============
*/
void R_LavaSplash (vec3_t org)
{
	int			i, j, k;
	particle_t	*p;
	float		vel;
	vec3_t		dir;

	for (i=-16 ; i<16 ; i++)
		for (j=-16 ; j<16 ; j++)
			for (k=0 ; k<1 ; k++)
			{
				if (!(p = R_AllocParticle ()))
					return;

				p->die = cl.time + 2 + (rand()&31) * 0.02;
				p->color = 224 + (rand()&7);
				p->type = pt_grav;

				dir[0] = j*8 + (rand()&7);
				dir[1] = i*8 + (rand()&7);
				dir[2] = 256;

				p->org[0] = org[0] + dir[0];
				p->org[1] = org[1] + dir[1];
				p->org[2] = org[2] + (rand()&63);

				VectorNormalize (dir);
				vel = 50 + (rand()&63);
				VectorScale (dir, vel, p->vel);
			}
}

/*
===============
R_TeleportSplash
===============
*/
void R_TeleportSplash (vec3_t org)
{
	int			i, j, k;
	particle_t	*p;
	float		vel;
	vec3_t		dir;

	for (i=-16 ; i<16 ; i+=4)
	{
		for (j=-16 ; j<16 ; j+=4)
		{
			for (k=-24 ; k<32 ; k+=4)
			{
				if (!(p = R_AllocParticle ()))
					return;

				p->die = cl.time + 0.2 + (rand()&7) * 0.02;
				p->color = 7 + (rand()&7);
				p->type = pt_grav;

				dir[0] = j*8;
				dir[1] = i*8;
				dir[2] = k*8;

				p->org[0] = org[0] + i + (rand()&3);
				p->org[1] = org[1] + j + (rand()&3);
				p->org[2] = org[2] + k + (rand()&3);

				VectorNormalize (dir);
				vel = 50 + (rand()&63);
				VectorScale (dir, vel, p->vel);
			}
		}
	}
}

/*
===============
R_RocketTrail

FIXME -- rename function and use #defined types instead of numbers
===============
*/
void R_RocketTrail (vec3_t start, vec3_t end, int type)
{
	vec3_t		vec;
	float		len;
	int			j;
	particle_t	*p;
	int			dec;
	static int	tracercount;

	VectorSubtract (end, start, vec);
	len = VectorNormalize (vec);
	if (type < 128)
		dec = 3;
	else
	{
		dec = 1;
		type -= 128;
	}

	while (len > 0)
	{
		len -= dec;

		if (!(p = R_AllocParticle ()))
			return;

		VectorCopy (vec3_origin, p->vel);
		p->die = cl.time + 2;

		switch (type)
		{
			case 0:	// rocket trail
				p->ramp = (rand()&3);
				p->color = ramp3[(int)p->ramp];
				p->type = pt_fire;
				for (j=0 ; j<3 ; j++)
					p->org[j] = start[j] + ((rand()%6)-3);
				break;

			case 6: // vore
			case 1:	// smoke smoke
				p->flag = 1;
				p->ramp = rand() & 2;
				p->color = rampgrenade[(int)p->ramp];
				p->type = pt_fire;
				for (j = 0; j < 3; j++)
					p->org[j] = start[j] + ((rand() % 6) - 3);
				break;

			case 2:	// blood
				p->type = pt_grav;
				p->color = 67 + (rand()&6);
				for (j=0 ; j<3 ; j++)
					p->org[j] = start[j] + ((rand()%6)-3);
				len -= 2;
				break;

			case 3:
			case 5:	// tracer
				p->die = cl.time + 0.5;
				p->type = pt_static;
				if (type == 3)
					p->color = 52 + ((tracercount&4)<<1);
				else
					p->color = 230 + ((tracercount&4)<<1);

				tracercount++;

				VectorCopy (start, p->org);
				if (tracercount & 1)
				{
					p->vel[0] = 30*vec[1];
					p->vel[1] = 30*-vec[0];
				}
				else
				{
					p->vel[0] = 30*-vec[1];
					p->vel[1] = 30*vec[0];
				}
				break;

			case 4:	// synth blood
				p->type = pt_grav;
				p->color = 0x25 + (rand() & 6);
				for (j=0 ; j<3 ; j++)
					p->org[j] = start[j] + ((rand()%6)-3);
				len -= 3;
				break;
		}

		VectorAdd (start, vec, start);
	}
}
/*
===============
R_BulletTrail
===============
*/
//static vec3_t tr_direction = { 0,0,0 };

void R_BulletTrail(vec3_t start, vec3_t end, int type)
{
	particle_t* p;
	vec3_t vec, org, dir;
	float len;
	int i, amount;

	VectorSubtract(end, start, vec);
	len = VectorNormalize(vec);
	// trail
	while (len > 0)
	{
		if (!(p = R_AllocParticle()))
			return;

		p->die = 99999;
		p->ramp = 8 + (rand() & 4);
		p->color = smoke[(int)p->ramp];
		p->type = pt_bullet;
		VectorCopy(vec3_origin, p->vel); // zero velocity
		VectorScale(vec, len, dir);
		VectorAdd(start, dir, org);
		VectorCopy(org, p->org);
		p->org[0] += (rand() % 2) - 1;
		p->org[1] += (rand() % 2) - 1;
		p->org[2] += (rand() % 2) - 1;

		len-=10;
	}

	if (type == MF_SMG)
		amount = 3;
	else if (type == MF_CHAINGUN)
		amount = 8;
	else if (type == MF_SHOTGUN)
		amount = 6;
	else
		amount = 5;
	// muzzle sparks
	for (i = 0; i < amount; i++)
	{
		if (!(p = R_AllocParticle()))
			return;

		p->die = cl.time + 0.15;
		p->ramp = (rand() & 3);
		p->color = spark[(int)p->ramp];
		p->type = pt_muzzle;
		if (type == MF_SMG)
		{
			dir[0] = vec[0] * 200 + (rand() % 400) - 200; // 
			dir[1] = vec[1] * 200 + (rand() % 400) - 200; // 
			dir[2] = vec[2] * 200 + (rand() % 400) - 200; // 
		}
		else
		{
			dir[0] = vec[0] * 1400 + (rand() % 600) - 300; // 
			dir[1] = vec[1] * 1400 + (rand() % 600) - 300; // 
			dir[2] = vec[2] * 1400 + (rand() % 600) - 300; // 
		}
		VectorCopy(dir, p->vel);
		VectorCopy(start, p->org);
	}
}

void R_LaserTrace(vec3_t start, vec3_t end, int color)
{
	particle_t* p;
	vec3_t vec, org, dir;
	float len;

	if (color < 0 || color > 255)
		color = 0;
	VectorSubtract(end, start, vec);
	len = VectorNormalize(vec);
	// trail
	while (len > 0)
	{
		if (!(p = R_AllocParticle()))
			return;

		p->die = cl.time + 0.1;
		p->color = color;
		p->type = pt_static;
		VectorCopy(vec3_origin, p->vel); // zero velocity
		VectorScale(vec, len, dir);
		VectorAdd(start, dir, org);
		VectorCopy(org, p->org);
		len -= 4;
	}
}

void R_GaussTrail(vec3_t start, vec3_t end)
{
	//return; // turned off for debugging purposes, remove this later
	particle_t* p;
	vec3_t vec, org, dir, side, up, offset_side, offset_up;
	float len;
	//int i;
	int circle = 0;

	VectorSubtract(end, start, vec);
	len = VectorNormalize(vec);

	VectorCopy(start, side);
	VectorPerpendicular(vec, side);
	VectorNormalize(side);
	CrossProduct(side, vec, up); //second vector orthogonal to trail's direction
	VectorNormalize(up);

	while (len > 0)
	{
		if (!(p = R_AllocParticle()))
			return;

		// smoke-ish part
		p->die = 99999;
		p->ramp = 0;
		p->color = ramp3[0];
		p->type = pt_gauss;//pt_gauss;//pt_static;
		p->flag = 0;
		VectorCopy(vec3_origin, p->vel); // zero velocity
		VectorScale(vec, len, dir);
		VectorAdd(start, dir, org);

		circle++;
		if (circle > 35)
			circle = 0;

		VectorScale(side, circlex[circle]*20, offset_side);
		VectorScale(up, circley[circle]*20, offset_up);
		VectorAdd(offset_side, offset_up, offset_side);
		VectorAdd(org, offset_side, p->org);
		p->vel[0] = (rand() % 200) - 100;
		p->vel[1] = (rand() % 200) - 100;
		p->vel[2] = (rand() % 200) - 100;

		// central beam
		if (!(p = R_AllocParticle()))
			return;

		p->ramp = (rand() & 3);
		p->color = rampcore[(int)p->ramp];
		p->die = 99999;
		p->type = pt_gaussmain;
		p->flag = 0;
		VectorCopy(vec3_origin, p->vel); // zero velocity
		VectorScale(side, circlex[circle], offset_side);
		VectorScale(up, circley[circle], offset_up);
		VectorAdd(offset_side, offset_up, offset_side);
		VectorScale(offset_side, 20, p->wish_vel);
		VectorCopy(org, p->org);

		len -= 10;
		//Con_DPrintf("trail particle = [%f %f %f] count:%d \n", org[0], org[1], org[2], count);
	}
	
}

/* 
impact - point of impact, no offset away from a wall
shooter - trace start coordinates
*/

void R_GaussImpact(vec3_t impact, vec3_t shooter, vec3_t normal, int type)
{
	particle_t* p;
	dlight_t* dl;
	vec3_t direction, inversed_direction, offset, offset2;
	vec3_t side, up;
	//vec3_t offset;
	int i, j, k, odd, lookup_index, count;

	float degree;
	vec3_t reflect;

	// dynamic light effect
	dl = CL_AllocDlight(0);
	VectorCopy(impact, dl->origin);
	dl->radius = 100;
	dl->die = cl.time + 0.6;
	dl->decay = 180;
	dl->color[0] = 1.4; //orange-ish
	dl->color[1] = 1.16;
	dl->color[2] = 0.81;
	dl->flag = 1;

// find direction vector from the impact point towards player
	VectorSubtract(shooter, impact, direction);
	VectorNormalize(direction);
// inverse direction vector, which is forward of view angle
	VectorCopy(direction, inversed_direction);
	VectorInverse(inversed_direction);
// find orthogonal normalized vectors of the plane that we are hit
	VectorCopy(impact, side); // point on the plane
	VectorPerpendicular(normal, side); // normal of the plane and point on the plane
	VectorNormalize(side);
	CrossProduct(side, normal, up); //second vector orthogonal to normal
	VectorNormalize(up);

// wall marks -----------------------------------------------------------
	for (i = 0; i < 4; i++)
	{
		odd = i % 1;
		for (j = 0; j < 18; j++)
		{
			if (!(p = R_AllocParticle()))
				return;

			p->die = cl.time + 5;
			p->type = pt_holegauss;
			lookup_index = j * 2 + odd;

			switch (type)
			{
			default:
			case IMPACT_GAUSS_FINAL: // solid, endpoint
				p->ramp = i - 36;
				p->color = spark[0] - i;
				break;
			case IMPACT_GAUSS_EXIT:
				p->ramp = i - 32;
				p->color = spark[0] - i;
				break;
			case IMPACT_GAUSS_ENTRANCE:
				p->ramp = i - 28;
				p->color = spark[0] - i;
				break;
			}

			for (k = 0; k < 3; k++)
			{
				p->org[k] = impact[k] + up[k] * circley[lookup_index] * i * 0.4
					+ side[k] * circlex[lookup_index] * i * 0.4
					+ normal[k];
			}
			VectorCopy(vec3_origin, p->vel);
		}
	}
// sparks -----------------------------------------------------
	switch (type)
	{
		default:
		case IMPACT_GAUSS_FINAL: // solid, endpoint
			//r = d−2(d⋅n)n
			// reflecting direction over normal, Use reflect vector as new direction for explosion effects
			VectorCopy(vec3_origin, reflect);
			degree = DotProduct(direction, normal);
			VectorScale(normal, degree * (-2.5), reflect); // 2 is default value, more means reflecting at lesser angle
			VectorAdd(direction, reflect, reflect);
			VectorInverse(reflect); //why?
			VectorNormalize(reflect);
			VectorCopy(reflect, offset2);
			VectorScale(offset2, 400, offset2); // speed of which particles will fly
			short spread;
			short half;
			// if angle of impact is less than 30, spawn less particles
			if (degree < 0.86)
				count = 4;
			else
				count = 1;

			for (j = 0; j < 18; j++)
			{
				lookup_index = j * 2;
				for (k = 0; k < 3; k++)
				{
					offset[k] = impact[k] + up[k] * circley[lookup_index] * 2
						+ side[k] * circlex[lookup_index] * 2
						+ normal[k];
				}
				for (i = 0; i < count; i++)
				{
					if (!(p = R_AllocParticle()))
						return;

					p->ramp = -18 + j;
					p->flag = 0;
					p->color = spark[(int)(rand() & 3)];
					p->type = pt_gaussexit;
					p->die = cl.time + 100;
				
					VectorCopy(offset, p->org); // impact
					VectorCopy(vec3_origin, p->vel);
					VectorCopy(offset2, p->wish_vel);
					
					half = (i+1) * 25;
					spread = half * 2;
					p->wish_vel[0] += (rand() % spread) - half;
					p->wish_vel[1] += (rand() % spread) - half;
					p->wish_vel[2] += (rand() % spread) - half;
				}
			}
			break;
		case IMPACT_GAUSS_ENTRANCE:
			VectorCopy(inversed_direction, offset2);
			for (i = 0; i < 36; i++)
			{
				if (!(p = R_AllocParticle()))
					return;

				for (k = 0; k < 3; k++)
				{
					offset[k] = impact[k] + up[k] * circley[i]
						+ side[k] * circlex[i]
						+ normal[k];
				}
				p->ramp = -((rand() & 6) + 1);
				p->flag = 0;
				p->color = spark[(int)((rand() & 5) + 5)];
				p->type = pt_gaussexit;
				p->die = cl.time + 100;

				VectorCopy(offset, p->org); // impact
				VectorCopy(vec3_origin, p->vel);
				VectorCopy(offset2, p->wish_vel);

				p->wish_vel[0] += (rand() % 200) - 100;
				p->wish_vel[1] += (rand() % 200) - 100;
				p->wish_vel[2] += (rand() % 200) - 100;
			}
			break;
		case IMPACT_GAUSS_EXIT: // solid, penetrating, exit hole
			// high intensity forward blast with gravity, glow

			VectorCopy(inversed_direction, offset);
			for (i = 0; i < 32; i++)
			{
				if (!(p = R_AllocParticle()))
					return;

				p->ramp = -32 + i;
				p->color = spark[(int)(rand() & 3)];
				p->type = pt_gaussexit;
				p->die = cl.time + 100;
				p->flag = 1;

				VectorCopy(impact, p->org);
				VectorCopy(vec3_origin, p->vel);
				VectorScale(offset, ((rand() % 10) + 1) * 60, p->wish_vel);
			}
			break;
	}
}

#define TYPE_BLOOD 1
#define TYPE_ROBOT 2
#define TYPE_GAUSS 4
#define TYPE_HEAD 8
#define TYPE_LASER 16
#define TYPE_WALL 32

void R_ImpactSparks(vec3_t org, vec3_t dir, int color, int color_rand, int count, int count2, int velocity)
{
	int			i, j;
	particle_t* p;
	float half_vel;
	float duration;
	half_vel = (float)velocity / 2;
	duration = 32.0 / velocity; // particle should live for 32 units of distance traveled

	if (count > 0)
	{
		for (i = 0; i < count; i++)
		{
			if (!(p = R_AllocParticle()))
				return;

			p->die = cl.time + duration;
			p->color = color + (rand() & color_rand);
			p->type = pt_grav;
			for (j = 0; j < 3; j++)
			{
				p->org[j] = org[j] + dir[j] * 4;// +((rand() & 8) - 4);
				p->vel[j] = dir[j] + (rand() % velocity) - half_vel;
			}
			p->vel[2] += 100;
		}
	}
	// another set of particles, no offset on origin and hardcoded velocity
	if (count2 > 0)
	{
		for (i = 0; i < count2; i++)
		{
			if (!(p = R_AllocParticle()))
				return;

			p->die = cl.time + 0.1 * (rand() % 5);
			p->color = color + (rand() & color_rand);
			p->type = pt_static;
			for (j = 0; j < 3; j++)
			{
				p->org[j] = org[j];
				p->vel[j] = dir[j] + (rand() % 50) - 25;
			}
		}
	}
}

void R_ImpactShield(vec3_t impact, vec3_t host_org)
{
	particle_t* p;
	dlight_t* dl;
	vec3_t normal, side, up;
	int j, k;
	float angle;
	
	dl = CL_AllocDlight(0);
	VectorCopy(impact, dl->origin);
	dl->radius = 200;
	dl->die = cl.time + 0.2;
	dl->decay = 250;
	dl->color[0] = 0.48; //blue-ish
	dl->color[1] = 1.26;
	dl->color[2] = 1.96;

	// find direction vector from the impact point towards player
	VectorSubtract(host_org, impact, normal);
	VectorNormalize(normal);

	// find orthogonal normalized vectors of the plane that we are hit
	VectorCopy(impact, side); // point on the plane
	VectorPerpendicular(normal, side); // normal and point on the plane
	VectorNormalize(side);
	CrossProduct(side, normal, up); //second vector orthogonal to normal
	VectorNormalize(up);

	for (j = 0; j < 60; j++)
	{
		if (!(p = R_AllocParticle()))
			return;

		p->die = cl.time + 0.35;
		p->type = pt_static;
		p->ramp = 0;
		p->color = 0xf4;
		angle = DEG2RAD(j * 6);// radiants?

		for (k = 0; k < 3; k++)
		{
			p->org[k] = impact[k] + up[k] * cos(angle) * 1
				+ side[k] * sin(angle) * 1
				+ normal[k];
		}
		p->vel[0] = (impact[0] - p->org[0])*70;
		p->vel[1] = (impact[1] - p->org[1])*70;
		p->vel[2] = (impact[2] - p->org[2])*70;
	}
	R_ImpactSparks(impact, normal, 0xf4, 0, 20, 10, 800);
}

void R_Impact(vec3_t org, vec3_t dir, int type)
{
	particle_t* p;
	vec3_t offset;
	float color;
	int	i;
	color = 0;
	switch (type)
	{
		case IMPACT_GAUSS_FLESH: // gauss flesh, red
			color = 0x4a;
		case IMPACT_GAUSS_ROBOT:
			if (color == 0)
				color = 0xea;

			for (i = 0; i < 36; i++)
			{
				if (!(p = R_AllocParticle()))
					return;

					p->ramp = -(rand() % 10);
					p->color = color + (rand() & 5);
					p->type = pt_grav;
					p->die = cl.time + 1;
					p->flag = 1;

				VectorScale(dir, i*2, offset);
				VectorCopy(org, p->org);
				VectorAdd(p->org, offset, p->org);
				VectorCopy(dir, p->vel);
				p->vel[0] += (rand() % 100) - 50;
				p->vel[1] += (rand() % 100) - 50;
				p->vel[2] += (rand() % 100) - 50;
			}
			break;
		// color, color shift, count sparks, count dust, velocity sparks
		case IMPACT_FLESH_HEADSHOT:
			R_ImpactSparks(org, dir, 0x48, 5, 8, 20, 150);
			R_ImpactSparks(org, dir, 0xeb, 4, 2, 0, 600);
			break;

		case IMPACT_ROBOT_HEADSHOT:
			//R_ImpactSparks(org, dir, 0xeb, 4, 5, 0, 600);
			R_ImpactSparks(org, dir, 0xfa, 1, 12, 6, 600); // red 
			break;

		case IMPACT_FLESH:
			R_ImpactSparks(org, dir, 0x48, 5, 15, 25, 150);
			break;

		case IMPACT_ROBOT:
			R_ImpactSparks(org, dir, 0xeb, 4, 20, 6, 600);
			break;

		case IMPACT_WALL:
			R_ImpactSparks(org, dir, 0x03, 5, 10, 20, 500);
			break;

		case IMPACT_LASER:
			R_ImpactSparks(org, dir, 0xfa, 1, 4, 40, 200);
			break;

		case IMPACT_SHIELD:
			R_ImpactShield(org, dir);
			break;

		case IMPACT_SHOCK:
			R_ImpactSparks(org, dir, 0xf5, 1, 20, 5, 200);
			R_ImpactSparks(org, dir, 0xeb, 4, 4, 0, 600);
			break;
	}
}

void R_ParticleShockwave(vec3_t org, int amplitude)
{
	particle_t* p;
	//vec3_t offset;
	int angle, height, i;
	byte shift = 0;
	for (height = 0; height < 32; height += 2)
	{
		for (angle = 0; angle < 36; angle++)
		{
			if (!(p = R_AllocParticle()))
				return;

			p->color = 0x02 + rand() & 6;
			p->type = pt_static;
			p->die = cl.time + 1;

			p->org[0] = org[0] + circlex[angle] + (rand() % 16) - 8;
			p->org[1] = org[1] + circley[angle] + (rand() % 16) - 8;
			p->org[2] = org[2] + ((rand() % 16) - 8) + height;

			p->vel[0] = (org[0] - p->org[0]) * (amplitude + height);
			p->vel[1] = (org[1] - p->org[1]) * (amplitude + height);
			p->vel[2] = (rand() % 64) - 32;
		}
	}

	for (i = 0; i < 32; i++)
	{
		if (!(p = R_AllocParticle()))
			return;

		p->color = 0x06 + rand() & 6;
		p->type = pt_grav;
		p->die = cl.time + 2;

		p->org[0] = org[0] + (rand() % 48) - 24;
		p->org[1] = org[1] + (rand() % 48) - 24;
		p->org[2] = org[2] + (rand() % 48) - 24;

		p->vel[0] = (rand() % 64) - 32;
		p->vel[1] = (rand() % 64) - 32;
		p->vel[2] = rand() % 96;
	}
}

/*
void CL_RailTrail(vec3_t start, vec3_t end)
{
	vec3_t		move;
	vec3_t		vec;
	float		len;
	int			j;
	particle_t* p;
	float		dec;
	vec3_t		right, up;
	int			i;
	float		d, c, s;
	vec3_t		dir;
	byte		clr = 0x74;

	VectorCopy(start, move);
	VectorSubtract(end, start, vec);
	len = VectorNormalize(vec);

	MakeNormalVectors(vec, right, up);

	for (i = 0; i < len; i++)
	{
		d = i * 0.1;
		c = cos(d);
		s = sin(d);

		VectorScale(right, c, dir);
		VectorMA(dir, s, up, dir);

		p->color = clr + (rand() & 7);
		for (j = 0; j < 3; j++)
		{
			p->org[j] = move[j] + dir[j] * 3;
			p->vel[j] = dir[j] * 6;
		}

		VectorAdd(move, vec, move);
	}

	dec = 0.75;
	VectorScale(vec, dec, vec);
	VectorCopy(start, move);

	while (len > 0)
	{
		len -= dec;

		if (!free_particles)
			return;
		p = free_particles;
		free_particles = p->next;
		p->next = active_particles;
		active_particles = p;

		p->time = cl.time;
		VectorClear(p->accel);

		p->alpha = 1.0;
		p->alphavel = -1.0 / (0.6 + frand() * 0.2);
		p->color = 0x0 + rand() & 15;

		for (j = 0; j < 3; j++)
		{
			p->org[j] = move[j] + crand() * 3;
			p->vel[j] = crand() * 3;
			p->accel[j] = 0;
		}

		VectorAdd(move, vec, move);
	}
}*/

/*
===============
CL_RunParticles -- johnfitz -- all the particle behavior, separated from R_DrawParticles
===============
*/
void CL_RunParticles (void)
{
	particle_t		*p;
	int				cur, active;
	float			time1, time2, time3, time4, time5, dvel, frametime, grav;
	extern	cvar_t	sv_gravity;

	frametime = cl.time - cl.oldtime;
	time5 = frametime * 60;
	time4 = frametime * 30;
	time3 = frametime * 15;
	time2 = frametime * 10;
	time1 = frametime * 5;
	grav = frametime * sv_gravity.value * 0.05;
	dvel = 4*frametime;

	for (cur = active = 0, p = particles; cur < r_numactiveparticles; cur++, p++)
	{
		if (p->die < cl.time || p->spawn > cl.time)
			continue;

		p->org[0] += p->vel[0]*frametime;
		p->org[1] += p->vel[1]*frametime;
		p->org[2] += p->vel[2]*frametime;

		switch (p->type)
		{
		case pt_static:
			break;

		case pt_changevel:
			p->ramp += time3;
			if (p->ramp >= 20)
				p->die = -1;

			if ((int)p->ramp == 0)
			{
				p->vel[0] = p->wish_vel[0];
				p->vel[1] = p->wish_vel[1];
				p->vel[2] = p->wish_vel[2];
				p->ramp = 1;
			}
			break;

		case pt_bullet:
			p->ramp += time3;
			if (p->ramp >= 12)
				p->die = -1;
			else
				p->color = smoke[(int)p->ramp];
			break;

		case pt_muzzle:
			p->ramp += time3;
			if (p->ramp >= 8)
				p->die = -1;
			else
				p->color = spark[(int)p->ramp];
			break;

		case pt_gauss:
			p->ramp += time1;
			if (p->ramp >= 6)
				p->die = -1;
			else
				p->color = ramp3[(int)p->ramp];
			break;

		case pt_gaussmain:

			p->ramp += time1;
			if (p->ramp >= 10)
				p->die = -1;
			else
				p->color = rampcore[(int)p->ramp];

			if ((int)p->ramp == 5)
			{
				p->vel[0] = p->wish_vel[0];
				p->vel[1] = p->wish_vel[1];
				p->vel[2] = p->wish_vel[2];
				p->ramp = 6;
			}
			break;

		case pt_holegauss:
			p->ramp += time3;
			if (p->ramp >= 15)
				p->die = -1;
			else if ((int)p->ramp > 0)
				p->color = spark[(int)p->ramp];
			break;

		case pt_gaussexit:
			if (p->flag == 1)
			{
				p->ramp += time5;
				if (p->ramp > 80)
					p->die = -1;
				if ((int)p->ramp == 0)
				{
					p->ramp = 1; //be sure to execute only once
					VectorCopy(p->wish_vel, p->vel);
					p->vel[0] += (rand() % (10 * 2)) - 10;
					p->vel[1] += (rand() % (10 * 2)) - 10;
					p->vel[2] += (rand() % (10 * 2)) - 10;
				}
				if (p->ramp > 0)
				{
					p->vel[2] -= grav * 2;
					p->color = spark[(int)p->ramp / 6]; // shouldn't run over 15 which is max index for sparks array, right?
				}
			}
			else
			{
				p->ramp += time5;
				if (p->ramp > 60)
					p->die = -1;
				if ((int)p->ramp == 0)
				{
					p->ramp = 1; //be sure to execute only once
					VectorCopy(p->wish_vel, p->vel);
				}
				if (p->ramp > 0)
				{
					p->vel[2] -= grav * 4;
					p->color = spark[(int) p->ramp / 4]; // shouldn't run over 15 which is max index for sparks array, right?
				}
			}
			break;

		case pt_blood:
			p->ramp += time5;
			if (p->ramp > 60)
				p->die = -1;
			if ((int)p->ramp == 0)
			{
				p->ramp = 1;
				p->vel[0] = p->wish_vel[0];
				p->vel[1] = p->wish_vel[1];
				p->vel[2] = p->wish_vel[2];
			}
			p->vel[2] -= grav*4;
			break;

		case pt_fire:
			
			if (p->flag)
			{
				p->vel[0] += (rand() % 100) - 50;
				p->vel[1] += (rand() % 100) - 50;
				p->vel[2] += (rand() % 100) - 50;
				p->ramp += time4;
				if (p->ramp >= 6)
					p->die = -1;
				else
					p->color = rampgrenade[(int)p->ramp];
			}
			else
			{
				p->ramp += time2;
				if (p->ramp >= 6)
					p->die = -1;
				else
					p->color = ramp3[(int)p->ramp];
			}

			p->vel[2] += grav;
			break;

		case pt_explode:
			p->ramp += time2;
			if (p->ramp >=9)
				p->die = -1;
			else
				p->color = rampinner[(int)p->ramp];
			break;

		case pt_explode2:
			p->ramp += time3;
			if (p->ramp >=8)
				p->die = -1;
			else
				p->color = ramp2[(int)p->ramp];
			break;

		case pt_explode_plasma:
			p->ramp += time2;
			if (p->ramp >= 10)
				p->die = -1;
			else
				p->color = plasma[(int)p->ramp];
			break;

		case pt_explode_plasma2:
			p->ramp += time3;
			if (p->ramp >= 10)
				p->die = -1;
			else
				p->color = plasma_inner[(int)p->ramp];
			p->vel[2] -= grav;
			break;

		case pt_grav:
			p->vel[2] -= grav;
			break;

		}

		if (cur != active)
			particles[active] = *p;
		active++;
	}

	r_numactiveparticles = active;
}

/*
===============
R_FlushParticleBatch
===============
*/
static void R_FlushParticleBatch (void)
{
	GLuint buf;
	GLbyte *ofs;

	if (!numpartverts)
		return;

	GL_Upload (GL_ARRAY_BUFFER, partverts, sizeof(partverts[0]) * numpartverts, &buf, &ofs);
	GL_BindBuffer (GL_ARRAY_BUFFER, buf);
	GL_VertexAttribPointerFunc (0, 3, GL_FLOAT, GL_FALSE, sizeof(partverts[0]), ofs + offsetof(particlevert_t, pos));
	GL_VertexAttribPointerFunc (1, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(partverts[0]), ofs + offsetof(particlevert_t, color));

	GL_DrawArraysInstancedFunc (GL_TRIANGLE_STRIP, 0, 4, numpartverts);

	numpartverts = 0;
}

/*
===============
R_DrawParticles_Real -- johnfitz -- moved all non-drawing code to CL_RunParticles
===============
*/
static void R_DrawParticles_Real(qboolean alpha, qboolean showtris)
{
	particle_t* p;
	particlevert_t* v;
	GLubyte			color[4] = { 255, 255, 255, 255 }, * c; //johnfitz -- particle transparency
	extern	cvar_t	r_particles; //johnfitz
	extern	cvar_t	r_oit;
	//float			alpha; //johnfitz -- particle transparency
	float			scalex, scaley;
	qboolean		dither, oit;
	int				i;

	if (!r_particles.value)
		return;

	if (!r_numactiveparticles)
		return;

	// square particles are drawn opaque (avoiding alpha sorting issues)
	if (!showtris && alpha != ((int)r_particles.value != 2))
		return;

	GL_BeginGroup("Particles");

	dither = (softemu == SOFTEMU_COARSE && !showtris);
	oit = (alpha && r_oit.value != 0.f);
	GL_UseProgram(glprogs.particles[oit][dither]);

	// compensate for apparent size of different particle textures
	// this bakes in the additional scaling of vup and vright by 1.5f for billboarding,
	// then down by 0.25f for quad particles
	scalex = scaley = texturescalefactor * 0.375f;
	// projection factors (see GL_FrustumMatrix), negated to make things easier in the shader
	scalex *= r_matproj[1 * 4 + 0]; // -1 / tan (fovx/2)
	scaley *= -r_matproj[2 * 4 + 1]; // -1 / tan (fovy/2)
	GL_Uniform3fFunc(0, scalex, scaley, uvscale);

	if (alpha)
		GL_SetState(GLS_BLEND_ALPHA_OIT | GLS_NO_ZWRITE | GLS_CULL_NONE | GLS_ATTRIBS(2) | GLS_INSTANCED_ATTRIBS(2));
	else
		GL_SetState(GLS_BLEND_OPAQUE | GLS_CULL_NONE | GLS_ATTRIBS(2) | GLS_INSTANCED_ATTRIBS(2));

	numpartverts = 0;
	for (i = 0, p = particles; i < r_numactiveparticles; i++, p++)
	{
		if (numpartverts == countof(partverts))
			R_FlushParticleBatch();

		v = &partverts[numpartverts++];
		VectorCopy(p->org, v->pos);

		//johnfitz -- particle transparency and fade out
		c = showtris ? color : (GLubyte*)&d_8to24table[(int)p->color];
		*(uint32_t*)&v->color = *(uint32_t*)c;
		v->color[0] = c[0];
		v->color[1] = c[1];
		v->color[2] = c[2];
		//alpha = CLAMP(0, p->die + 0.5 - cl.time, 1);
		v->color[3] = c[3]; //(int)(alpha * 255);
		//johnfitz
	}

	R_FlushParticleBatch();

	GL_EndGroup();
}

/*
===============
R_DrawParticles -- johnfitz -- moved all non-drawing code to CL_RunParticles
===============
*/
void R_DrawParticles (qboolean alpha)
{
	R_DrawParticles_Real (alpha, false);
}
/*
===============
R_DrawParticles_ShowTris -- johnfitz
===============
*/
void R_DrawParticles_ShowTris (void)
{
	R_DrawParticles_Real (false, true);
}

