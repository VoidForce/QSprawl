/*
Copyright (C) 1996-2001 Id Software, Inc.
Copyright (C) 2002-2009 John Fitzgibbons and others
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
// cl_tent.c -- client side temporary entities

#include "quakedef.h"

int			num_temp_entities;
entity_t	cl_temp_entities[MAX_TEMP_ENTITIES];
beam_t		cl_beams[MAX_BEAMS];

sfx_t			*cl_sfx_wizhit;
sfx_t			*cl_sfx_knighthit;
sfx_t			*cl_sfx_tink1;
sfx_t			*cl_sfx_ric1;
sfx_t			*cl_sfx_ric2;
sfx_t			*cl_sfx_ric3;
sfx_t			*cl_sfx_r_exp3;

/*
=================
CL_ParseTEnt
=================
*/
void CL_InitTEnts (void)
{
	cl_sfx_wizhit = S_PrecacheSound ("wizard/hit.wav");
	cl_sfx_knighthit = S_PrecacheSound ("hknight/hit.wav");
	cl_sfx_tink1 = S_PrecacheSound ("weapons/tink1.wav");
	cl_sfx_ric1 = S_PrecacheSound ("weapons/ric1.wav");
	cl_sfx_ric2 = S_PrecacheSound ("weapons/ric2.wav");
	cl_sfx_ric3 = S_PrecacheSound ("weapons/ric3.wav");
	cl_sfx_r_exp3 = S_PrecacheSound ("weapons/r_exp3.wav");
}

/*
=================
CL_ParseBeam
=================
*/
void CL_ParseBeam (qmodel_t *m, float staytime)
{
	int		ent;
	vec3_t	start, end, offset;
	beam_t	*b;
	int		i;
	short flag;

	ent = MSG_ReadShort ();

	start[0] = MSG_ReadCoord (cl.protocolflags);
	start[1] = MSG_ReadCoord (cl.protocolflags);
	start[2] = MSG_ReadCoord (cl.protocolflags);

	end[0] = MSG_ReadCoord (cl.protocolflags);
	end[1] = MSG_ReadCoord (cl.protocolflags);
	end[2] = MSG_ReadCoord (cl.protocolflags);

	// qSprawl: extra data, v_angle of player, to offset lightning gun lightning model
	flag = MSG_ReadByte();
	if (flag)
	{
		offset[0] = MSG_ReadCoord(cl.protocolflags);
		offset[1] = MSG_ReadCoord(cl.protocolflags);
		offset[2] = MSG_ReadCoord(cl.protocolflags);
	}

// override any beam with the same entity
	for (i=0, b=cl_beams ; i< MAX_BEAMS ; i++, b++)
		if (b->entity == ent)
		{
			b->entity = ent; //why? it's the same entity
			b->model = m;
			b->starttime = cl.time - 0.001;
			b->endtime = cl.time + staytime;
			VectorCopy(start, b->start);
			VectorCopy (end, b->end);
			VectorCopy(offset, b->offset);
			return;
		}

// find a free beam
	for (i=0, b=cl_beams ; i< MAX_BEAMS ; i++, b++)
	{
		if (!b->model || b->starttime > cl.time || b->endtime < cl.time)
		{
			b->entity = ent;
			b->model = m;
			b->starttime = cl.time - 0.001;
			b->endtime = cl.time + staytime;
			VectorCopy (start, b->start);
			VectorCopy (end, b->end);
			VectorCopy(offset, b->offset);
			return;
		}
	}

	//johnfitz -- less spammy overflow message
	if (!dev_overflows.beams || dev_overflows.beams + CONSOLE_RESPAM_TIME < realtime )
	{
		Con_Printf ("Beam list overflow!\n");
		dev_overflows.beams = realtime;
	}
	//johnfitz
}

/*
=================
CL_ParseTEnt
=================
*/
void CL_ParseTEnt (void)
{
	int		type;
	int		flag;
	vec3_t	pos, pos2, pos3;
	dlight_t	*dl;
	int		rnd;
	const char* str; //qsprawl
	float	staytime;

	type = MSG_ReadByte ();
	switch (type)
	{
	case TE_SPIKE:			// spike hitting wall
		pos[0] = MSG_ReadCoord (cl.protocolflags);
		pos[1] = MSG_ReadCoord (cl.protocolflags);
		pos[2] = MSG_ReadCoord (cl.protocolflags);
		R_RunParticleEffect (pos, vec3_origin, 0, 20);
		if ( rand() % 5 )
			S_StartSound (-1, 0, cl_sfx_tink1, pos, 1, 1);
		else
		{
			rnd = rand() & 3;
			if (rnd == 1)
				S_StartSound (-1, 0, cl_sfx_ric1, pos, 1, 1);
			else if (rnd == 2)
				S_StartSound (-1, 0, cl_sfx_ric2, pos, 1, 1);
			else
				S_StartSound (-1, 0, cl_sfx_ric3, pos, 1, 1);
		}
		break;

	case TE_EXPLOSION:			// rocket explosion
		pos[0] = MSG_ReadCoord (cl.protocolflags);
		pos[1] = MSG_ReadCoord (cl.protocolflags);
		pos[2] = MSG_ReadCoord (cl.protocolflags);
		R_ParticleExplosion (pos);
		dl = CL_AllocDlight (0);
		VectorCopy (pos, dl->origin);
		dl->radius = 350;
		dl->die = cl.time + 0.5;
		dl->decay = 300;
		S_StartSound (-1, 0, cl_sfx_r_exp3, pos, 1, 1);
		break;

	case TE_LIGHTNING1:				// lightning bolts
		CL_ParseBeam (Mod_ForName("progs/bolt.mdl", true), 0.2);
		break;

	case TE_LIGHTNING2:				// lightning bolts
		CL_ParseBeam (Mod_ForName("progs/bolt2.mdl", true), 0.2);
		break;

	case TE_LIGHTNING3:				// lightning bolts
		CL_ParseBeam (Mod_ForName("progs/bolt3.mdl", true), 0.2);
		break;

//qsprawl
	case TE_BEAMBYNAME:
		str = MSG_ReadString ();
		staytime = MSG_ReadCoord(cl.protocolflags);
		CL_ParseBeam(Mod_ForName(str, true), staytime);
		break;

	case TE_GAUSSTRACE:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		pos2[0] = MSG_ReadCoord(cl.protocolflags);
		pos2[1] = MSG_ReadCoord(cl.protocolflags);
		pos2[2] = MSG_ReadCoord(cl.protocolflags);
		R_GaussTrail(pos, pos2);
		break;
		
	case TE_BULLETTRACE:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		pos2[0] = MSG_ReadCoord(cl.protocolflags);
		pos2[1] = MSG_ReadCoord(cl.protocolflags);
		pos2[2] = MSG_ReadCoord(cl.protocolflags);
		flag = MSG_ReadByte();
		R_BulletTrail(pos, pos2, flag);
		break;

	case TE_LASERTRACE:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		pos2[0] = MSG_ReadCoord(cl.protocolflags);
		pos2[1] = MSG_ReadCoord(cl.protocolflags);
		pos2[2] = MSG_ReadCoord(cl.protocolflags);
		flag = MSG_ReadByte();
		R_LaserTrace(pos, pos2, flag);
		break;

	case TE_IMPACT:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		pos2[0] = MSG_ReadCoord(cl.protocolflags);
		pos2[1] = MSG_ReadCoord(cl.protocolflags);
		pos2[2] = MSG_ReadCoord(cl.protocolflags);
		flag = MSG_ReadByte();
		if (flag && flag < 4)
		{
			pos3[0] = MSG_ReadCoord(cl.protocolflags);
			pos3[1] = MSG_ReadCoord(cl.protocolflags);
			pos3[2] = MSG_ReadCoord(cl.protocolflags);
			R_GaussImpact(pos, pos2, pos3, flag);
		}
		else
			R_Impact(pos, pos2, flag);
		break;

	case TE_LAVASPLASH:
		pos[0] = MSG_ReadCoord (cl.protocolflags);
		pos[1] = MSG_ReadCoord (cl.protocolflags);
		pos[2] = MSG_ReadCoord (cl.protocolflags);
		R_LavaSplash (pos);
		break;

	case TE_TELEPORT:
		pos[0] = MSG_ReadCoord (cl.protocolflags);
		pos[1] = MSG_ReadCoord (cl.protocolflags);
		pos[2] = MSG_ReadCoord (cl.protocolflags);
		R_TeleportSplash (pos);
		break;

	case TE_HEAD:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		R_ParticleHead(pos, 1); // 1 means flesh
		break;

	case TE_SYNTHHEAD_EXPLOSION:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		R_ParticleHead(pos, 2); // 2 means synth
		break;

	case TE_ROBOTHEAD_EXPLOSION:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		R_ParticleHead(pos, 0); // 0 means robotic

		dl = CL_AllocDlight(0);
		VectorCopy(pos, dl->origin);
		dl->radius = 350;
		dl->die = cl.time + 0.5;
		dl->decay = 300;
		S_StartSound(-1, 0, cl_sfx_r_exp3, pos, 1, 1);
		break;

	/*
	case TE_ROBOT_EXPLOSION:
		pos[0] = MSG_ReadCoord(cl.protocolflags);
		pos[1] = MSG_ReadCoord(cl.protocolflags);
		pos[2] = MSG_ReadCoord(cl.protocolflags);
		R_ParticleRobotExplosion(pos);

		dl = CL_AllocDlight(0);
		VectorCopy(pos, dl->origin);
		dl->radius = 350;
		dl->die = cl.time + 0.5;
		dl->decay = 300;
		S_StartSound(-1, 0, cl_sfx_r_exp3, pos, 1, 1);
		break;
	*/
	default:
		Sys_Error ("CL_ParseTEnt: bad type");
	}
}


/*
=================
CL_NewTempEntity
=================
*/
entity_t *CL_NewTempEntity (void)
{
	entity_t	*ent;

	if (cl_numvisedicts == MAX_VISEDICTS)
		return NULL;
	if (num_temp_entities == MAX_TEMP_ENTITIES)
		return NULL;
	ent = &cl_temp_entities[num_temp_entities];
	memset (ent, 0, sizeof(*ent));
	num_temp_entities++;
	cl_visedicts[cl_numvisedicts] = ent;
	cl_numvisedicts++;
	ent->scale = ENTSCALE_DEFAULT;
	ent->colormap = vid.colormap;
	return ent;
}


/*
=================
CL_UpdateTEnts
=================
*/
void CL_UpdateTEnts (void)
{
	int			i, j; //johnfitz -- use j instead of using i twice, so we don't corrupt memory
	beam_t		*b;
	vec3_t		dist, org;
	float		d;
	entity_t	*ent;
	float		yaw, pitch;
	float		forward;
	// qsprawl
	//vec3_t		fwd, right, up, offset;

	num_temp_entities = 0;

	srand ((int) (cl.time * 1000)); //johnfitz -- freeze beams when paused

// update lightning
	for (i=0, b=cl_beams ; i< MAX_BEAMS ; i++, b++)
	{
		if (!b->model || b->starttime > cl.time || b->endtime < cl.time)
			continue;

	// if coming from the player, update the start position
		/*
		if (b->entity == cl.viewentity)
		{
			AngleVectors(cl_entities[cl.viewentity].angles, fwd, right, up);
			VectorCopy (cl_entities[cl.viewentity].origin, offset ); // qSprawl fix this to use offset
			for (j = 0; j < 3; j++)
				offset[j] += fwd[j] * 24 + right[j] * 8;
			offset[2] += 16;
			VectorCopy(offset, b->start);
		}
		*/

	// calculate pitch and yaw
		VectorSubtract (b->end, b->start, dist);

		if (dist[1] == 0 && dist[0] == 0)
		{
			yaw = 0;
			if (dist[2] > 0)
				pitch = 90;
			else
				pitch = 270;
		}
		else
		{
			yaw = (int) (atan2(dist[1], dist[0]) * 180 / M_PI);
			if (yaw < 0)
				yaw += 360;

			forward = sqrt (dist[0]*dist[0] + dist[1]*dist[1]);
			pitch = (int) (atan2(dist[2], forward) * 180 / M_PI);
			if (pitch < 0)
				pitch += 360;
		}

	// add new entities for the lightning
		VectorCopy (b->start, org);
		d = VectorNormalize(dist);
		while (d > 0)
		{
			ent = CL_NewTempEntity ();
			if (!ent)
				return;
			VectorCopy (org, ent->origin);
			ent->model = b->model;
			ent->angles[0] = pitch;
			ent->angles[1] = yaw;
			ent->angles[2] = rand()%360;

			//johnfitz -- use j instead of using i twice, so we don't corrupt memory
			for (j=0 ; j<3 ; j++)
				org[j] += dist[j]*30;
			d -= 30;
		}
	}
}
