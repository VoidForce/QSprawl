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
// sv_user.c -- server code for moving users

#include "quakedef.h"

edict_t	*sv_player;

extern	cvar_t	sv_friction;
cvar_t	sv_edgefriction = {"edgefriction", "2", CVAR_NONE};
extern	cvar_t	sv_stopspeed;

static	vec3_t		forward, right, up;

// world
float	*angles;
float	*origin;
float	*velocity;

qboolean	onground;

usercmd_t	cmd;

cvar_t	sv_idealpitchscale = {"sv_idealpitchscale","0.8",CVAR_NONE};
cvar_t	sv_altnoclip = {"sv_altnoclip","1",CVAR_ARCHIVE}; //johnfitz

/*
===============
SV_SetIdealPitch
===============
*/
#define	MAX_FORWARD	6
void SV_SetIdealPitch (void)
{
	float	angleval, sinval, cosval;
	trace_t	tr;
	vec3_t	top, bottom;
	float	z[MAX_FORWARD];
	int		i, j;
	int		step, dir, steps;

	if (!((int)sv_player->v.flags & FL_ONGROUND))
		return;

	angleval = sv_player->v.angles[YAW] * M_PI*2 / 360;
	sinval = sin(angleval);
	cosval = cos(angleval);

	for (i=0 ; i<MAX_FORWARD ; i++)
	{
		top[0] = sv_player->v.origin[0] + cosval*(i+3)*12;
		top[1] = sv_player->v.origin[1] + sinval*(i+3)*12;
		top[2] = sv_player->v.origin[2] + sv_player->v.view_ofs[2];

		bottom[0] = top[0];
		bottom[1] = top[1];
		bottom[2] = top[2] - 160;

		tr = SV_Move (top, vec3_origin, vec3_origin, bottom, 1, sv_player);
		if (tr.allsolid)
			return;	// looking at a wall, leave ideal the way is was

		if (tr.fraction == 1)
			return;	// near a dropoff

		z[i] = top[2] + tr.fraction*(bottom[2]-top[2]);
	}

	dir = 0;
	steps = 0;
	for (j=1 ; j<i ; j++)
	{
		step = z[j] - z[j-1];
		if (step > -ON_EPSILON && step < ON_EPSILON)
			continue;

		if (dir && ( step-dir > ON_EPSILON || step-dir < -ON_EPSILON ) )
			return;		// mixed changes

		steps++;
		dir = step;
	}

	if (!dir)
	{
		sv_player->v.idealpitch = 0;
		return;
	}

	if (steps < 2)
		return;
	sv_player->v.idealpitch = -dir * sv_idealpitchscale.value;
}


/*
==================
SV_UserFriction

==================
*/
void SV_UserFriction(float friction)
{
	float	*vel;
	float	speed, newspeed;

	vel = velocity;

	speed = sqrt(vel[0]*vel[0] +vel[1]*vel[1]);
	if (!speed)
		return;

// apply friction
	newspeed = speed - host_frametime * speed * friction;

	if (newspeed < 10)
		newspeed = 0;
	newspeed /= speed;

	vel[0] = vel[0] * newspeed;
	vel[1] = vel[1] * newspeed;
}

void SV_FrictionVector(vec3_t velocity_in, float friction, vec3_t velocity_out)
{
	float	speed, newspeed;

	speed = sqrt(velocity_in[0] * velocity_in[0] + velocity_in[1] * velocity_in[1]);
	if (!speed)
		return;

	// apply friction
	newspeed = speed - host_frametime * speed * friction;

	if (newspeed < 10)
		newspeed = 0;
	newspeed /= speed;

	velocity_out[0] = velocity_in[0] * newspeed;
	velocity_out[1] = velocity_in[1] * newspeed;
}
/*
==============
SV_Accelerate
==============
*/
//cvar_t	sv_maxspeed = {"sv_maxspeed", "320", CVAR_NOTIFY|CVAR_SERVERINFO};
//cvar_t	sv_accelerate = {"sv_accelerate", "10", CVAR_NONE};
//Qsprawl
void SV_Accelerate (float wish_speed, vec3_t wish_direction)
{
	int			i;
	float		addspeed, accelspeed, dotspeed;

	dotspeed = DotProduct(velocity, wish_direction);
	addspeed = wish_speed - dotspeed;
	if (addspeed <= 0)
		return;
	accelspeed = sv_player->v.phys_acceleration * host_frametime * wish_speed;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (i = 0; i < 3; i++)
		velocity[i] += accelspeed * wish_direction[i];
}

/*
//Qsprawl: Does both acceleration and braking deceleration in one go
void SV_AirAccelerate(vec3_t wish_velocity)
{
	int i;
	vec3_t acceleration = { 0, 0, 0 };
	float result;
	float reach; // distance to reach the wished velocity value

	SV_UserFriction(sv_player->v.phys_airfriction);
	VectorScale(wish_velocity, host_frametime * sv_player->v.phys_airacceleration, acceleration);
	for (i = 0; i < 2; i++)
	{
		// in case of zero, we just skip	
		if (wish_velocity[i] != 0)
		{
			// so, if curent value is more than maximum limit, keep it unchanged.
			result = velocity[i];

			// if reach have opposite sign of wish_velocity, that means that current speed already more 
			// than maximum speed, that's how we know that we don't want to add anything more
			reach = wish_velocity[i] - velocity[i];
			// case in which we have some distance to travel to wished value
			//positive values
			if ((wish_velocity[i] > 0) && reach > 0)
			{
				// add acceleration
				result = velocity[i] + acceleration[i];
				// limit to max speed
				result = q_min_f(result, wish_velocity[i]);
			}
			//negative values
			else if ((wish_velocity[i] < 0) && reach < 0)
			{
				// add acceleration
				result = velocity[i] + acceleration[i];
				// limit to max speed
				result = q_max_f(result, wish_velocity[i]);
			}

			velocity[i] = result;
		}
	}
}*/

void SV_AirAccelerate(float wishspeed, vec3_t wishveloc)
{
	int			i;
	float		addspeed, wishspd, accelspeed, currentspeed;

	wishspd = VectorNormalize(wishveloc);
	if (wishspd > 60)
		wishspd = 60;
	currentspeed = DotProduct(velocity, wishveloc);
	addspeed = wishspd - currentspeed;
	if (addspeed <= 0)
		return;
	//	accelspeed = sv_accelerate.value * host_frametime;
	accelspeed = sv_player->v.phys_airacceleration * wishspeed * host_frametime;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (i = 0; i < 3; i++)
		velocity[i] += accelspeed * wishveloc[i];
}

void SV_Q2AirAccelerate(float wishspeed, vec3_t wishdir)
{
	int			i;
	float		addspeed, accelspeed, currentspeed;

	currentspeed = DotProduct(velocity, wishdir);
	addspeed = wishspeed - currentspeed;
	if (addspeed <= 0)
		return;

	accelspeed = host_frametime * wishspeed;

	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (i = 0; i < 3; i++)
		velocity[i] += accelspeed * wishdir[i];
}

void SV_WallRunDetection()
{
	trace_t	trace;
	vec3_t w_forward, w_backward, w_left, w_right;
	vec3_t half_mins, half_maxs;
	int i;
	float WallDetectionDistance;

	if (onground)
	{
		sv_player->v.wallrun = 0; //reset
		return;
	}
	sv_player->v.wallrun = 0; //reset
	WallDetectionDistance = 32;
	//let us define tracing vectors
	for (i = 0; i < 3; i++)
	{
		sv_player->v.wall_normal[i] = 0; //reset
		w_forward[i] = origin[i] + forward[i] * WallDetectionDistance;
		w_backward[i] = origin[i] - forward[i] * WallDetectionDistance;
		w_right[i] = origin[i] + right[i] * WallDetectionDistance;
		w_left[i] = origin[i] - right[i] * WallDetectionDistance;
	}

	i = 0;
	VectorCopy(sv_player->v.mins, half_mins);
	VectorCopy(sv_player->v.maxs, half_maxs);
	//idk if there is a point in this? sv_move should use closest hull size instead of custom box size?
	half_mins[2] += 12;
	half_maxs[2] -= 16;

	trace = SV_Move(origin, half_mins, half_maxs, w_forward, true, sv_player);
	if (trace.fraction != 1.0 && trace.plane.normal[2] > -0.001)
	{
		sv_player->v.wallrun += 1;
		VectorAdd(sv_player->v.wall_normal, trace.plane.normal, sv_player->v.wall_normal);
	}
	trace = SV_Move(origin, half_mins, half_maxs, w_backward, true, sv_player);
	if (trace.fraction != 1.0 && trace.plane.normal[2] > -0.001)
	{
		sv_player->v.wallrun += 2;
		VectorAdd(sv_player->v.wall_normal, trace.plane.normal, sv_player->v.wall_normal);
	}

	trace = SV_Move(origin, half_mins, half_maxs, w_right, true, sv_player);
	if (trace.fraction != 1.0 && trace.plane.normal[2] > -0.001)
	{
		sv_player->v.wallrun += 4;
		VectorAdd(sv_player->v.wall_normal, trace.plane.normal, sv_player->v.wall_normal);
	}
	trace = SV_Move(origin, half_mins, half_maxs, w_left, true, sv_player);
	if (trace.fraction != 1.0 && trace.plane.normal[2] > -0.001)
	{
		sv_player->v.wallrun += 8;
		VectorAdd(sv_player->v.wall_normal, trace.plane.normal, sv_player->v.wall_normal);
	}

	// we don't want any vertical momentum added into wall suction velocity
	sv_player->v.wall_normal[2] = 0;
	VectorNormalize(sv_player->v.wall_normal);

	//Con_DPrintf("wallrun = %f \n", sv_player->v.wallrun);
	//Con_DPrintf("wall_normal = [%f,%f,%f] \n", sv_player->v.wall_normal[0], sv_player->v.wall_normal[1], sv_player->v.wall_normal[2]);
}

void DropPunchAngle (void)
{
	float	len;

	// find the length, normalize
	len = VectorNormalize (sv_player->v.punchangle);

	//Con_DPrintf("frametime = %f, raw = %f \n", host_frametime*72, host_fpsframetime*250);
	len -= (30 + len * 2) * host_frametime;
	if (len < 0)
		len = 0;
	VectorScale (sv_player->v.punchangle, len, sv_player->v.punchangle);
}

/*
===================
SV_WaterMove

===================
*/
void SV_WaterMove (void)
{
	int		i;
	vec3_t	wishvel;
	float	speed, newspeed, wishspeed, addspeed, accelspeed;

//
// user intentions
//
	AngleVectors (sv_player->v.v_angle, forward, right, up);

	for (i=0 ; i<3 ; i++)
		wishvel[i] = forward[i]*cmd.forwardmove + right[i]*cmd.sidemove;

	if (!cmd.forwardmove && !cmd.sidemove && !cmd.upmove)
		wishvel[2] -= 60;		// drift towards bottom
	else
		wishvel[2] += cmd.upmove;

	wishspeed = VectorLength(wishvel);
	if (wishspeed > sv_player->v.phys_speed)
	{
		VectorScale(wishvel, sv_player->v.phys_speed / wishspeed, wishvel);
		wishspeed = sv_player->v.phys_speed;
	}
	wishspeed *= 0.7;

//
// water friction
//
	speed = VectorLength (velocity);
	if (speed)
	{
		newspeed = speed - host_frametime * speed * sv_player->v.phys_friction;
		if (newspeed < 0)
			newspeed = 0;
		VectorScale (velocity, newspeed/speed, velocity);
	}
	else
		newspeed = 0;

//
// water acceleration
//
	if (!wishspeed)
		return;

	addspeed = wishspeed - newspeed;
	if (addspeed <= 0)
		return;

	VectorNormalize (wishvel);
	accelspeed = sv_player->v.phys_acceleration * wishspeed * host_frametime;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	for (i=0 ; i<3 ; i++)
		velocity[i] += accelspeed * wishvel[i];
}

void SV_WaterJump (void)
{
	if (qcvm->time > sv_player->v.teleport_time
	|| !sv_player->v.waterlevel)
	{
		sv_player->v.flags = (int)sv_player->v.flags & ~FL_WATERJUMP;
		sv_player->v.teleport_time = 0;
	}
	sv_player->v.velocity[0] = sv_player->v.movedir[0];
	sv_player->v.velocity[1] = sv_player->v.movedir[1];
}

/*
===================
SV_NoclipMove -- johnfitz

new, alternate noclip. old noclip is still handled in SV_AirMove
===================
*/
void SV_NoclipMove (void)
{
	AngleVectors (sv_player->v.v_angle, forward, right, up);

	velocity[0] = forward[0]*cmd.forwardmove + right[0]*cmd.sidemove;
	velocity[1] = forward[1]*cmd.forwardmove + right[1]*cmd.sidemove;
	velocity[2] = forward[2]*cmd.forwardmove + right[2]*cmd.sidemove;
	velocity[2] += cmd.upmove*2; //doubled to match running speed

	if (VectorLength (velocity) > sv_player->v.phys_speed)
	{
		VectorNormalize (velocity);
		VectorScale (velocity, sv_player->v.phys_speed, velocity);
	}
}
//----------------------------------------------------------------------------------------------------------------------------------------------------
/*
===================
SV_AirMove
===================
*/
void SV_AirMove (void)
{
	int			i;
	vec3_t		wish_velocity, wish_direction;
	float		wish_speed;
	vec3_t		current_velocity;
	//vec3_t		current_direction;
	vec3_t		down = { 0, 0, -1 };//how do we define constant array without assigning it to a variable?
	float		wall_direction;
	vec3_t		wall_vector;
	float		speed2d;
	float		gravity_multiplier;
	float		fmove, smove;

	AngleVectors (sv_player->v.angles, forward, right, up);

	fmove = cmd.forwardmove;
	smove = cmd.sidemove;

// hack to not let you back into teleporter
	if (qcvm->time < sv_player->v.teleport_time && fmove < 0)
		fmove = 0;

	for (i=0 ; i<3 ; i++)
		wish_velocity[i] = forward[i]*fmove + right[i]*smove;

	if ( (int)sv_player->v.movetype != MOVETYPE_WALK)
		wish_velocity[2] = cmd.upmove;
	else
		wish_velocity[2] = 0;

	VectorCopy (wish_velocity, wish_direction);
	wish_speed = VectorNormalize(wish_direction);
	//VectorCopy (velocity, current_direction);
	//VectorNormalize(current_direction);

	//limiting wish velocity to max speed
	if (wish_speed > sv_player->v.phys_speed)
	{
		VectorScale(wish_velocity, sv_player->v.phys_speed / wish_speed, wish_velocity);
		wish_speed = sv_player->v.phys_speed;
	}

	if ( sv_player->v.movetype == MOVETYPE_NOCLIP)
	{	// noclip
		VectorCopy (wish_velocity, velocity);
	}
	else
	{
		sv_player->v.wallrun = 0; //reset
		if (onground)
		{
			if (sv_player->v.wall_jumps)
				sv_player->v.wall_jumps = 0;
			SV_UserFriction(sv_player->v.phys_friction);
			SV_Accelerate(wish_speed, wish_direction);
		}
		else // in the air
		{
			VectorCopy(velocity, current_velocity);
			current_velocity[2] = 0;
			speed2d = VectorNormalize(current_velocity);
			speed2d = speed2d / sv_player->v.phys_speed;
			//speed2d = clamp_f(0, speed2d, 1);

			SV_WallRunDetection();
			if (sv_player->v.wallrun)
			{
				// slide along the wall				 
				CrossProduct(sv_player->v.wall_normal, down, wall_vector); // find a vector along the wall
				VectorNormalize(wall_vector);
				wall_direction = DotProduct(wish_direction, wall_vector); //decide at which direction we want to go
				if (wall_direction < 0)
				{
					VectorScale(wall_vector, -1, wall_vector);
				}
				VectorAdd(wall_vector, wish_direction, wall_vector);
				VectorNormalize(wall_vector);
				VectorScale(wall_vector, wish_speed, wish_velocity);

				//gravity

				sv_player->v.phys_gravity = 1 * (1 - (clamp_f(0, speed2d, 1) *0.55));

				//wall S U C C
				// i used current velocity here to store the sucction vector, don't be confused
				VectorScale(sv_player->v.wall_normal, -1 * host_frametime * 160, current_velocity);
				velocity[0] += current_velocity[0];
				velocity[1] += current_velocity[1];

				//move and fall faster when holding crouch
				if (sv_player->v.b_slide)
				{
					if (velocity[2] < 0)
					{
						gravity_multiplier = 1 + CLAMP(0, -velocity[2] / 300, 0.6);
						wish_speed *= 1 + gravity_multiplier;
						//VectorScale(wish_velocity, gravity_multiplier, wish_velocity);
					}
					sv_player->v.phys_gravity = 1 * (1 - (clamp_f(0, speed2d, 1) * 0.4));
				}
			}
			else // not wallrunning
			{
				sv_player->v.phys_gravity = 1; // 0.9
			}

			//Con_DPrintf("wish_speed = %f, wish_direction = [%f,%f,%f] \n", wish_speed, wish_direction[0], wish_direction[1], wish_direction[2]);
			SV_UserFriction(clamp_f(0, speed2d, 5) * 0.1);
			SV_AirAccelerate(wish_speed, wish_velocity);
			SV_Q2AirAccelerate(wish_speed, wish_direction);
		}
	}
}

/*
===================
SV_ClientThink

the move fields specify an intended velocity in pix/sec
the angle fields specify an exact angular motion in degrees
===================
*/
void SV_ClientThink (void)
{
	vec3_t		v_angle;

	if (sv_player->v.movetype == MOVETYPE_NONE)
		return;

	onground = (int)sv_player->v.flags & FL_ONGROUND;

	origin = sv_player->v.origin;
	velocity = sv_player->v.velocity;

	DropPunchAngle ();

//
// if dead, behave differently
//
	if (sv_player->v.health <= 0)
		return;

//
// angles
// show 1/3 the pitch angle and all the roll angle
	cmd = host_client->cmd;
	angles = sv_player->v.angles;

	VectorAdd (sv_player->v.v_angle, sv_player->v.punchangle, v_angle);
	angles[ROLL] = V_CalcRoll (sv_player->v.angles, sv_player->v.velocity) * 4;

	if (!sv_player->v.fixangle)
	{
		angles[PITCH] = -v_angle[PITCH]/3;
		angles[YAW] = v_angle[YAW];
	}

	if ( (int)sv_player->v.flags & FL_WATERJUMP )
	{
		SV_WaterJump ();
		return;
	}
//
// walk
//
	//johnfitz -- alternate noclip

	if (sv_player->v.movetype == MOVETYPE_NOCLIP && sv_altnoclip.value)
		SV_NoclipMove ();
	else if (sv_player->v.waterlevel >= 2 && sv_player->v.movetype != MOVETYPE_NOCLIP)
		SV_WaterMove ();
	else
		SV_AirMove ();
	//johnfitz
}


/*
===================
SV_ReadClientMove
===================
*/
void SV_ReadClientMove (usercmd_t *move)
{
	int		i;
	vec3_t	angle;
	int		bits;

// read ping time
	host_client->ping_times[host_client->num_pings%NUM_PING_TIMES]
		= qcvm->time - MSG_ReadFloat ();
	host_client->num_pings++;

// read current angles
	for (i=0 ; i<3 ; i++)
		//johnfitz -- 16-bit angles for PROTOCOL_FITZQUAKE
		if (sv.protocol == PROTOCOL_NETQUAKE)
			angle[i] = MSG_ReadAngle (sv.protocolflags);
		else
			angle[i] = MSG_ReadAngle16 (sv.protocolflags);
		//johnfitz

	VectorCopy (angle, host_client->edict->v.v_angle);

// read movement
	move->forwardmove = MSG_ReadShort ();
	move->sidemove = MSG_ReadShort ();
	move->upmove = MSG_ReadShort ();

// read buttons
	bits = MSG_ReadShort ();
	host_client->edict->v.button0 = bits & 1; //attack
	host_client->edict->v.button2 = (bits & 2) >> 1; //jump
// qsprawl new buttons
	host_client->edict->v.button1 = (bits & 4) >> 2; // use
	host_client->edict->v.b_attack2 = (bits & 8) >> 3;
	host_client->edict->v.b_slide = (bits & 16) >> 4;
	host_client->edict->v.b_reload = (bits & 32) >> 5;
	host_client->edict->v.b_melee = (bits & 64) >> 6;
	host_client->edict->v.b_kick = (bits & 128) >> 7;
	host_client->edict->v.b_adrenaline = (bits & 256) >> 8;

	i = MSG_ReadByte ();
	if (i)
		host_client->edict->v.impulse = i;
}

/*
===================
SV_ReadClientMessage

Returns false if the client should be killed
===================
*/
qboolean SV_ReadClientMessage (void)
{
	int		ret;
	int		ccmd;
	const char	*s;

	do
	{
nextmsg:
		ret = NET_GetMessage (host_client->netconnection);
		if (ret == -1)
		{
			Sys_Printf ("SV_ReadClientMessage: NET_GetMessage failed\n");
			return false;
		}
		if (!ret)
			return true;

		MSG_BeginReading ();

		while (1)
		{
			if (!host_client->active)
				return false;	// a command caused an error

			if (msg_badread)
			{
				Sys_Printf ("SV_ReadClientMessage: badread\n");
				return false;
			}

			ccmd = MSG_ReadChar ();

			switch (ccmd)
			{
			case -1:
				goto nextmsg;		// end of message

			default:
				Sys_Printf ("SV_ReadClientMessage: unknown command char\n");
				return false;

			case clc_nop:
//				Sys_Printf ("clc_nop\n");
				break;

			case clc_stringcmd:
				s = MSG_ReadString ();
				if (q_strncasecmp(s, "spawn", 5) && q_strncasecmp(s, "begin", 5) && q_strncasecmp(s, "prespawn", 8) && qcvm->extfuncs.SV_ParseClientCommand)
				{	//the spawn/begin/prespawn are because of numerous mods that disobey the rules.
					//at a minimum, we must be able to join the server, so that we can see any sprints/bprints (because dprint sucks, yes there's proper ways to deal with this, but moders don't always know them).
					client_t *ohc = host_client;
					qboolean checked = GetBit (qcvm->checked_ext, KRIMZON_SV_PARSECLIENTCOMMAND);
					// disable warnings for KRIMZON_SV_PARSECLIENTCOMMAND temporarily
					// by marking the extension as checked and advertised
					SetBit (qcvm->checked_ext, KRIMZON_SV_PARSECLIENTCOMMAND);
					SetBit (qcvm->advertised_ext, KRIMZON_SV_PARSECLIENTCOMMAND);
					G_INT(OFS_PARM0) = PR_SetEngineString(s);
					pr_global_struct->time = qcvm->time;
					pr_global_struct->self = EDICT_TO_PROG(host_client->edict);
					PR_ExecuteProgram(qcvm->extfuncs.SV_ParseClientCommand);
					// re-enable warnings
					ClearBit (qcvm->advertised_ext, KRIMZON_SV_PARSECLIENTCOMMAND);
					if (!checked)
						ClearBit (qcvm->checked_ext, KRIMZON_SV_PARSECLIENTCOMMAND);
					host_client = ohc;
					break;
				}
				ret = 0;
				if (q_strncasecmp(s, "status", 6) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "god", 3) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "notarget", 8) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "fly", 3) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "name", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "noclip", 6) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "setpos", 6) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "say", 3) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "say_team", 8) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "tell", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "color", 5) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "kill", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "pause", 5) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "spawn", 5) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "begin", 5) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "prespawn", 8) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "kick", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "ping", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "give", 4) == 0)
					ret = 1;
				else if (q_strncasecmp(s, "ban", 3) == 0)
					ret = 1;

				if (ret == 1)
					Cmd_ExecuteString (s, src_client);
				else
					Con_DPrintf("%s tried to %s\n", host_client->name, s);
				break;

			case clc_disconnect:
			//	Sys_Printf ("SV_ReadClientMessage: client disconnected\n");
				return false;

			case clc_move:
				SV_ReadClientMove (&host_client->cmd);
				break;
			}
		}
	} while (ret == 1);

	return true;
}


/*
==================
SV_RunClients
==================
*/
void SV_RunClients (void)
{
	int				i;

	for (i=0, host_client = svs.clients ; i<svs.maxclients ; i++, host_client++)
	{
		if (!host_client->active)
			continue;

		sv_player = host_client->edict;

		if (!SV_ReadClientMessage ())
		{
			SV_DropClient (false);	// client misbehaved...
			continue;
		}

		if (!host_client->spawned)
		{
		// clear client movement until a new packet is received
			memset (&host_client->cmd, 0, sizeof(host_client->cmd));
			continue;
		}

// always pause in single player if in console or menus
		if (!sv.paused && (svs.maxclients > 1 || key_dest == key_game) )
			SV_ClientThink ();
	}
}

